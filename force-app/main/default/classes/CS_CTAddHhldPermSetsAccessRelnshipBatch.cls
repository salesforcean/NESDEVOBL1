/*
 * Developed By: Sai Rakesh (NESS TECHNOLOGIES)
 * Defect 449010
 * Description - This is a batch job class used to process the Relationship records to determine whether the related KBAs depending on the School that the CT falls under should be made accessible to the other CT members.
 *               All the Relationship records will be pulled that were updated on a specific time frame (Historical records processing) and based on that the related Program Enrollment records defined for each Student and Caretaker,
 *               will be processed to determine whether the LC Community user(s) access should be provisioned or revoked to the School CT permission-set accordingly. 

 * CHANGE-LOG:
 * ==========
 * By SaiRakesh 2021-07-24: 
 * Updated this batch-job's finish( ) and execute( ) methods.
 * This was done in relation to the Defect 449010
 */

global class CS_CTAddHhldPermSetsAccessRelnshipBatch implements Database.Batchable<sObject>, Database.Stateful{

    public set<Id> studRecsIdSet = new set<Id>();
    global map<String, list<PermissionSetAssignment>> permissionSetsRemovalMap;   
    global list<PermissionSetAssignment> permsSetAssignDeleteList;
    
    global CS_CTAddHhldPermSetsAccessRelnshipBatch (){
       
        permissionSetsRemovalMap = new map<String, list<PermissionSetAssignment>>();     
        permsSetAssignDeleteList = new list<PermissionSetAssignment>();
    }            

    global Database.QueryLocator start(Database.BatchableContext bc) {        
        Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
        Id recordTypeIdCT = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_CARETAKER).getRecordTypeId();      
        Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.LC_KBA_ACCESS_RELNSHIP_RECS_PROCESS_INTERVAL];
        DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));
        String batchQueryStr;
        
         batchQueryStr = 'SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Status__c, hed__RelatedContact__c, hed__RelatedContact__r.Name FROM hed__Relationship__c WHERE hed__Type__c != \''+CS_Constants.LEARNING_COACH_TYPE+'\' AND hed__Contact__r.RecordTypeId = :recordTypeIdSTD AND hed__RelatedContact__r.RecordTypeId = :recordTypeIdCT AND LastModifiedDate >= :dateTimeInterval'+(Test.isRunningTest()?' LIMIT 10':'');
 
        return Database.getQueryLocator(batchQueryStr);
    }
    global void execute(Database.BatchableContext bc, List<hed__Relationship__c> relationshipRecs){
        set<Id> studentRecsIdSet = new set<Id>();
        for(hed__Relationship__c releach: relationshipRecs){
              studentRecsIdSet.add(releach.hed__Contact__c);  
        }
         // Calling the Batch-Apex handler class to process the revoking and provisioning of the CT permission-sets in relation to the Schools that the Learning Coach comes under.

        if((studentRecsIdSet != null) && !studentRecsIdSet.isEmpty()){
            CS_LCUserAccessToSchoolCTKBAsHandler handlerObj = new CS_LCUserAccessToSchoolCTKBAsHandler();

            permissionSetsRemovalMap.putAll(handlerObj.LCUserSchoolCTPermSetsAccessProgEnroll(studentRecsIdSet));
        }
        
    }
    global void finish(Database.BatchableContext bc){}
    
      
}