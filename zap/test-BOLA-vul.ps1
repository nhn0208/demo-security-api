Write-Host "[INFO] Starting ZAP with BOLA script..."

$zapJar = "C:\\Xanh\\tttn\\ZAP\\ZAP_2.16.1_Crossplatform\\ZAP_2.16.1\\zap-2.16.1.jar"
$scriptPath = "zap/scripts/TestBOLA.js"

java -Xmx512m -Djava.awt.headless=true `
    -jar $zapJar `
    -cmd `
    -script $scriptFile `
    -scriptType httpsender `
    -scriptEngine ECMAScript `
    -config api.disablekey=true
