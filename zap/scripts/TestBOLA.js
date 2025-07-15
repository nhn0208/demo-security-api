// Java class mapping
var HttpSender = Java.type("org.parosproxy.paros.network.HttpSender");
var HttpMessage = Java.type("org.parosproxy.paros.network.HttpMessage");
var URI = Java.type("org.apache.commons.httpclient.URI");
var HttpHeader = Java.type("org.parosproxy.paros.network.HttpHeader");
var FileWriter = Java.type("java.io.FileWriter");
var BufferedWriter = Java.type("java.io.BufferedWriter");
var SimpleDateFormat = Java.type("java.text.SimpleDateFormat");
var Date = Java.type("java.util.Date");

// === Cấu hình ===
var TARGET_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
var loginUrl = "http://localhost:8080/api/auth/login";
var loginBody = '{"username":"client","password":"client123"}';
var formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

// === Log file: đúng workspace Jenkins
var logFile = Java.type("java.lang.System").getProperty("user.dir") + "/zap/zap-reports/zap-bola-log.txt";

// === Hàm chính ===
function init() {
    var writer = new BufferedWriter(new FileWriter(logFile, true));
    writer.write("\n=== BOLA Scan Log - " + formatter.format(new Date()) + " ===\n");

    // Gọi login API để lấy token
    var loginMsg = new HttpMessage(new URI(loginUrl, false));
    loginMsg.getRequestHeader().setMethod("POST");
    loginMsg.getRequestHeader().setHeader(HttpHeader.CONTENT_TYPE, "application/json");
    loginMsg.setRequestBody(loginBody);
    loginMsg.getRequestHeader().setContentLength(loginBody.length);

    var sender = new HttpSender(HttpSender.MANUAL_REQUEST_INITIATOR);
    sender.sendAndReceive(loginMsg, true);

    var response = loginMsg.getResponseBody().toString();
    var parsed = JSON.parse(response);
    var token = parsed.token;

    if (!token) {
        writer.write("[ERROR] Could not get JWT token\n");
        writer.flush(); writer.close();
        return;
    }

    // Gửi 10 request với token
    for (var i = 0; i < TARGET_IDS.length; i++) {
        var id = TARGET_IDS[i];
        var url = "http://localhost:8080/api/users/" + id;
        var req = new HttpMessage(new URI(url, false));
        req.getRequestHeader().setMethod("GET");
        req.getRequestHeader().setHeader("Authorization", "Bearer " + token);

        sender.sendAndReceive(req, true);
        var status = req.getResponseHeader().getStatusCode();
        var log = "[" + formatter.format(new Date()) + "] [*] Tested " + url + " => Status: " + status;
        writer.write(log + "\n");

        if (status === 200) {
            writer.write("[!!] BOLA vulnerability found at: " + url + "\n");
        }
    }

    writer.flush();
    writer.close();
}
