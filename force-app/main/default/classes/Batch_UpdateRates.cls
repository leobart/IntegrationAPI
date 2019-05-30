/**
 * Created by Leonid Bartenev
 */

public class Batch_UpdateRates implements Database.Batchable<Exchange_Rate__c>, Database.Stateful, Database.AllowsCallouts{
    
    public static final String UPDATE_RATES_JOB_NAME = 'UpdateExchangeRatesJob';
    public Integer intervalInMinutes;
    
    public Batch_UpdateRates(Integer intervalInMinutes){
        this.intervalInMinutes = intervalInMinutes;
    }
    
    public Iterable<Exchange_Rate__c> start(Database.BatchableContext bc){
        return new List<Exchange_Rate__c>{new Exchange_Rate__c()};
    }
    
    public void execute(Database.BatchableContext bc, List<Exchange_Rate__c> dummyRates){
        List<Exchange_Rate__c> rates = [SELECT Id, Currency__c FROM Exchange_Rate__c];
        RemoteCall_GetRates getRatesRemoteCall = new RemoteCall_GetRates();
        Map<String, Decimal> remoteRatesMap = new Map<String, Decimal>();
        try{
            RemoteCall_GetRates.RatesData ratesData = (RemoteCall_GetRates.RatesData) getRatesRemoteCall.execute();
            remoteRatesMap = ratesData.rates;
        }catch (Exception e){
            System.debug('ERROR: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Map<String, Exchange_Rate__c> dbRatesMap = new Map<String, Exchange_Rate__c>();
        for(Exchange_Rate__c rate : rates) {
            dbRatesMap.put(rate.Currency__c, rate);
            if(getRatesRemoteCall.log != null) rate.Integration_Log__c = getRatesRemoteCall.log.Id;
        }
        List<Exchange_Rate__c> ratesForUpdate = new List<Exchange_Rate__c>();
        for(String remoteRateKey : remoteRatesMap.keySet()){
            Exchange_Rate__c dbRate = dbRatesMap.get(remoteRateKey);
            if(dbRate == null) {
                dbRate = new Exchange_Rate__c(
                        Currency__c = remoteRateKey,
                        Integration_Log__c = getRatesRemoteCall.log.Id
                );
            }
            dbRate.Rate__c = remoteRatesMap.get(remoteRateKey);
            ratesForUpdate.add(dbRate);
        }
        upsert ratesForUpdate;
    }
    
    public void finish(Database.BatchableContext param1){
        System.scheduleBatch(new Batch_UpdateRates(intervalInMinutes), UPDATE_RATES_JOB_NAME, intervalInMinutes);

    }
    
    public static void run(Integer intervalInMinutes){
        stop();
        Database.executeBatch(new Batch_UpdateRates(intervalInMinutes));
    }
    
    public static void stop(){
        List<CronTrigger> cronTriggers = [
                SELECT Id
                FROM CronTrigger
                WHERE CronJobDetail.Name =: UPDATE_RATES_JOB_NAME
        ];
        if(!cronTriggers.isEmpty()) {
            for(CronTrigger cronT : cronTriggers) {
                System.abortJob(cronT.Id);
                System.debug('Process: ' + UPDATE_RATES_JOB_NAME + ' stopped');
            }
        }
    }

}