/**
 * Created by Leonid Bartenev
 */

public class SFLoginDemo {
    
    public static void loginToSalesforce(){
        String sessionId = new RemoteCall_SFLogin('integrationapi@lb.com', 'Samokat26', 'Ect3g4W3TriPKLDWamnfypxP').execute() + '';
        System.debug('SESSION ID: ' + sessionId.substring(1));
    }
}
