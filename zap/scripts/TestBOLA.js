// Script type: httpsender
// Target: any
// Enabled: true

// Java class mapping
var HttpSender = Java.type("org.parosproxy.paros.network.HttpSender");
var HttpMessage = Java.type("org.parosproxy.paros.network.HttpMessage");
var URI = Java.type("org.apache.commons.httpclient.URI");
var HttpHeader = Java.type("org.parosproxy.paros.network.HttpHeader");
var SimpleDateFormat = Java.type("java.text.SimpleDateFormat");
var Date = Java.type("java.util.Date");

// === Biến toàn cục ===
var CURRENT_ID = 2;
var TARGET_IDS = [1,2,3,4,5,6,7,8,9,10];
var loginUrl = "http://127.0.0.1:8080/api/auth/login";
var loginBody = '{"username":"client","password":"client123"}';
var token = null;

var formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

// === Gọi API login để lấy JWT
function getJwtToken() {
    var msg = new HttpMessage(new URI(loginUrl, false));
    msg.getRequestHeader().setMethod("POST");
    msg.getRequestHeader().setHeader(HttpHeader.CONTENT_TYPE, "application/json");
    msg.setRequestBody(loginBody);
    msg.getRequestHeader().setContentLength(loginBody.length);

    var sender = new HttpSender(HttpSender.MANUAL_REQUEST_INITIATOR);
    sender.sendAndReceive(msg, true);

    var response = msg.getResponseBody().toString();
    var parsed = JSON.parse(response);
    return parsed.token;
}

// === Hàm xử lý request gốc
function sendingRequest(msg, initiator, helper) {
    var uri = msg.getRequestHeader().getURI().toString();
    if (uri.contains("/api/users/")) {
        if (token == null) {
            token = getJwtToken();
            if (!token) {
                var error = "[" + formatter.format(new Date()) + "] [ERROR] Failed to get token";
                print(error);
                return;
            }
        }

        for (var i = 0; i < TARGET_IDS.length; i++) {
            var id = TARGET_IDS[i];
            if (id === CURRENT_ID) continue;

            var newUri = uri.replace(/\/\d+$/, "/" + id);
            var forgedMsg = new HttpMessage(new URI(newUri, false));
            forgedMsg.getRequestHeader().setMethod("GET");
            forgedMsg.getRequestHeader().setHeader("Authorization", "Bearer " + token);

            var sender = new HttpSender(HttpSender.MANUAL_REQUEST_INITIATOR);
            sender.sendAndReceive(forgedMsg, true);

            var status = forgedMsg.getResponseHeader().getStatusCode();
            if (status === 200 && id !== CURRENT_ID) {
            helper.raiseAlert(
                2,                     // risk: 0-Informational, 1-Low, 2-Medium, 3-High
                2,                     // confidence: 0-Low, 1-Medium, 2-High, 3-Confirmed
                "BOLA vulnerability",  // alert name
                "User enumeration detected via ID tampering", // description
                newUri,                // URI
                "", "", "",            // param, attack, otherInfo
                "Fix object-level access controls.", // solution
                "Consider rate limiting and access control.", // reference
                0, 0,                  // CWE ID, WASC ID
                msg                   // original message (for context in alert tab)
            );
        }

        }
    }
}

function responseReceived(msg, initiator, helper) {
    // Không cần xử lý phản hồi
}
