/**
 * Created by Leonid Bartenev
 *
 * SOAP Example of connection to Salesforce
 *
 */

public class RemoteCall_SFLogin extends RemoteCall{
    
    public RemoteCall_SFLogin(String login, String password, String securityToken){
        this.endPointURL = 'callout:SalesforceAPIDev';
        this.httpMethod = METHOD_POST;
        this.headersMap.putAll(new Map<String, String>{
                'Content-Type' => 'text/xml; charset=utf-8',
                'SOAPAction' => 'login',
                'Connection' => 'Keep-Alive'
        });
        if(securityToken == null) securityToken = '';
        this.hiddenParams.putAll(new Map<String, String>{
                'login' => login,
                'password' => password,
                'securityToken' => securityToken
        });

    }
    
    public override Type getType() {
        return RemoteCall_SFLogin.class;
    }
    
    protected override String buildRequestBody() {
        String requestBody =
                '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:enterprise.soap.sforce.com">' +
                '   <soapenv:Header>' +
                '   </soapenv:Header>' +
                '   <soapenv:Body>' +
                '       <urn:login>' +
                '           <urn:username>{!login}</urn:username>' +
                '           <urn:password>{!password}{!securityToken}</urn:password>' +
                '       </urn:login>' +
                '   </soapenv:Body>' +
                '</soapenv:Envelope>';
        return requestBody;
    }
    
    protected override Object parseResponse(String responseBody) {
        try {
            Dom.Document doc = new Dom.Document();
            doc.load(responseBody);
            String soapenv = 'http://schemas.xmlsoap.org/soap/envelope/';
            String urn = 'urn:enterprise.soap.sforce.com';
            String sessionId = (String) doc.getRootElement().
                    getChildElement('Body', soapenv).
                    getChildElement('loginResponse', urn).
                    getChildElement('result', urn).
                    getChildElement('sessionId', urn).getText();
            if (log.Response_Body__c != null) log.Response_Body__c = log.Response_Body__c.replaceAll(sessionId, 'SESSION_ID_REMOVED');
            return sessionId;
        } catch (Exception e) {
            throw new RemoteCallException('Can not parse response');
        }
    }
}