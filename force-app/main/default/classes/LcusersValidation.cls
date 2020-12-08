global class LcusersValidation implements Schedulable, Database.Batchable<sObject>  {
global Database.QueryLocator start(Database.BatchableContext bc) {
            Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE MasterLabel = 'LC KBA Programs Interval'];
            DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));
            String batchQueryStr = 'SELECT Id, Name, hed__Contact__c,hed__Contact__r.Account.Parent.School_Id__c,hed__Contact__r.Account.Parent.Name, hed__Status__c, hed__RelatedContact__c,hed__RelatedContact__r.Commuity_User__c FROM hed__Relationship__c WHERE hed__Type__c = '+'\'Learning Coach\' AND Testing_Record__c = true';
            return Database.getQueryLocator(batchQueryStr);
        }
        
        global void execute(Database.BatchableContext bc, List<hed__Relationship__c> relationshipRecs){
                   
            LcusersValidationHandler bhandler = new LcusersValidationHandler();
            bhandler.provDeprovPermissionSet(relationshipRecs); 
        }
        global void execute(SchedulableContext SC) {
            database.executebatch(new CS_ProvisionCTPermsSetToLCUsersBatch_v2());
        }
        
        global void finish(Database.BatchableContext bc){
            // No post-processing operations in this context.
        }
        
}