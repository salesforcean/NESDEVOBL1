/**
 * Cleanup Batch:
 * Option 1: with hardcoded eca query to delete everything before createdDate = 2020-08-02T00:00:00Z
    StorageCleanUpBatch cleanup = new StorageCleanUpBatch();
    Id batchId = Database.executeBatch(cleanup);
 *
 * Option 2: you can pass your own query to delete records across any object    
    String qry = 'SELECT Id from Enrollment_Component_Affiliation__c WHERE CREATEDDATE < 2020-09-05T00:00:00Z';
    StorageCleanUpBatch cleanup = new StorageCleanUpBatch(qry);
    Id batchId = Database.executeBatch(cleanup);
    // String qry = 'SELECT Id from Enrollment_Component_Affiliation__c WHERE CREATEDDATE < 2020-08-02T00:00:00Z';
 */
global class StorageCleanUpBatch implements Database.Batchable<sObject>, Database.Stateful 
{   
    // instance member to retain state across transactions
    global Integer recordsProcessed = 0;
    //private String qryStr = 'SELECT Id from Enrollment_Component_Affiliation__c WHERE CREATEDDATE < 2020-08-02T00:00:00Z';
    //global String qryStr = 'SELECT Id from Enrollment_Component_Affiliation__c WHERE CREATEDDATE < 2020-11-15T00:00:00Z';
    global String qryStr = 'SELECT Id from Program_Enrollment_Criteria__c WHERE CREATEDDATE < 2020-11-15T00:00:00Z';

    public StorageCleanUpBatch() {}

    public StorageCleanUpBatch(String qry)
    {
        if (String.isNotBlank(qry))
            this.qryStr = qry;
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(qryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        // process each batch of records
        List<SObject> ecas = new List<SObject>();
        for (SObject eca : scope) {
            ecas.add(eca);
            // increment the instance member counter
            recordsProcessed = recordsProcessed + 1;
        }
        delete ecas;
    }  

    global void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed. Shazam!');
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
            JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()];
        // call some utility to send email
        mailJobSummary(job, recordsProcessed, qryStr);
    }
    
    public static void mailJobSummary(AsyncApexJob job, Integer recProcessed, String qryString)
    {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { job.CreatedBy.Email };
        message.optOutPolicy = 'FILTER';
        message.subject = 'StorageCleanUpBatch Job ran successfully!';
        message.plainTextBody = 'qryString:' + qryString + '\n No. of records processed:' + recProcessed;
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
    }
}