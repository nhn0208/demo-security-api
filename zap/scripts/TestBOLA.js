// Java class mapping
var HttpSender = Java.type("org.parosproxy.paros.network.HttpSender");
var HttpMessage = Java.type("org.parosproxy.paros.network.HttpMessage");
var URI = Java.type("org.apache.commons.httpclient.URI");
var HttpHeader = Java.type("org.parosproxy.paros.network.HttpHeader");
var FileWriter = Java.type("java.io.FileWriter");
var BufferedWriter = Java.type("java.io.BufferedWriter");
var SimpleDateFormat = Java.type("java.text.SimpleDateFormat");
var Date = Java.type("java.util.Date");

// === Khai báo biến toàn cục ===
var CURRENT_ID = 2;
var TARGET_IDS = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
var loginUrl = "http://localhost:8080/api/auth/login";
var loginBody = '{"username":"client","password":"client123"}';
var token = null;

// === Thông tin log ===
var logFile = "zap/zap-reports/zap-bola-log.txt";
var writer = null;
var formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

// === Khởi tạo log file ===
function initLog() {
    writer = new BufferedWriter(new FileWriter(logFile, true));
    var now = formatter.format(new Date());
    writer.write("\n=== BOLA Scan Log - " + now + " ===\n");
    writer.flush();
}

// === Gọi API để lấy token JWT ===
function getJwtToken() {
    var loginMsg = new HttpMessage(new URI(loginUrl, false));
    loginMsg.getRequestHeader().setMethod("POST");
    loginMsg.getRequestHeader().setHeader(HttpHeader.CONTENT_TYPE, "application/json");
    loginMsg.setRequestBody(loginBody);
    loginMsg.getRequestHeader().setContentLength(loginBody.length);

    var sender = new HttpSender(HttpSender.MANUAL_REQUEST_INITIATOR);
    sender.sendAndReceive(loginMsg, true);

    var response = loginMsg.getResponseBody().toString();
    var parsed = JSON.parse(response);
    return parsed.token;
}

// === Gửi các request giả mạo để kiểm tra BOLA ===
function sendingRequest(msg, initiator, helper) {
    var uri = msg.getRequestHeader().getURI().toString();

    if (uri.contains("/api/users/" + CURRENT_ID)) {
        if (writer === null) {
            initLog();
        }

        if (token == null) {
            token = getJwtToken();
            if (!token) {
                var errTime = formatter.format(new Date());
                var errLog = "[" + errTime + "] [ERROR] Could not get token";
                print(errLog);
                writer.write(errLog + "\n");
                writer.flush();
                return;
            }
        }

        for (var i = 0; i < TARGET_IDS.length; i++) {
            var TARGET_ID = TARGET_IDS[i];
            if (TARGET_ID === CURRENT_ID) continue;

            var newUri = uri.replace("/" + CURRENT_ID, "/" + TARGET_ID);
            var forgedMsg = new HttpMessage(new URI(newUri, false));
            forgedMsg.getRequestHeader().setMethod("GET");
            forgedMsg.getRequestHeader().setHeader("Authorization", "Bearer " + token);

            var sender = new HttpSender(HttpSender.MANUAL_REQUEST_INITIATOR);
            sender.sendAndReceive(forgedMsg, true);

            var status = forgedMsg.getResponseHeader().getStatusCode();
            var timestamp = formatter.format(new Date());
            var log = "[" + timestamp + "] [*] Tested " + newUri + " => Status: " + status;

            print(log);
            writer.write(log + "\n");

            if (status === 200) {
                var vuln = "[" + timestamp + "] [!!] BOLA vulnerability found at: " + newUri;
                print(vuln);
                writer.write(vuln + "\n");
            }

            writer.flush();
        }
    }
}

function responseReceived(msg, initiator, helper) {
    // Không xử lý phản hồi gốc
}
