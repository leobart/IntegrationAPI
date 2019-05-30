/**
 * Created by Leonid Bartenev
 */

public class RemoteCall_GetRates extends RemoteCall{
    
    public class RatesData{
        public Map<String, Decimal> rates;
    }
    
    public RemoteCall_GetRates(){
        endPointURL = 'callout:ExchangeRates';
    }
    
    public override Type getType() {
        return RemoteCall_GetRates.class;
    }
    
    public override String buildRequestBody() {
        return null;
    }
    
    public override Object parseResponse(String responseBody) {
        return JSON.deserialize(responseBody, RatesData.class);
    }
}