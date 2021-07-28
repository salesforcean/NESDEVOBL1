/*
 * Developed By: Rakesh Ramaswamy (NESS TECHNOLOGIES)
 * User Story #. 164369
 * Description - This is a batch job class used to process the Relationship records to determine whether the related KBAs depending on the School that the LC falls under should be made accessible to the LC Community User.
 *               All the Relationship records will be pulled that were updated on a specific time frame (Historical records processing) and based on that the related Program Enrollment records defined for each Student and Learning Coach,
 *               will be processed to determine whether the LC Community user(s) access should be provisioned or revoked to the School CT permission-set accordingly. This batch chains the invocation of the batch job on the Program Enrollment
 *               records that will have to be processed subsequently (Lines of code commented out currently as Program Enrollment batch has chaining effect on the Relationship batch job.)


 * CHANGE-LOG:
 * ==========
 * By Rakesh 2020-06-24: 
 * Updated this batch-job's finish( ) and execute( ) methods.
 * This was done in relation to the User Story #. 186957 (Task #. 195459)
 */

global class CS_LCUserCTPermSetsAccessRelnshipBatch implements Database.Batchable<sObject>, Database.Stateful{

    public set<Id> studRecsIdSet = new set<Id>();
    global map<String, list<PermissionSetAssignment>> permissionSetsRemovalMap;   
    global list<PermissionSetAssignment> permsSetAssignDeleteList;
    
    global CS_LCUserCTPermSetsAccessRelnshipBatch(set<Id> studentsIdSet){
        studRecsIdSet = studentsIdSet;
        permissionSetsRemovalMap = new map<String, list<PermissionSetAssignment>>();     
        permsSetAssignDeleteList = new list<PermissionSetAssignment>();
    }            

    global Database.QueryLocator start(Database.BatchableContext bc) {        
        Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
        Id recordTypeIdLC = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_LEARNING_COACH).getRecordTypeId();      
        Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.LC_KBA_ACCESS_RELNSHIP_RECS_PROCESS_INTERVAL];
        DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));
        String batchQueryStr;
        if((studRecsIdSet == null) || studRecsIdSet.isEmpty()){
            batchQueryStr = 'SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Status__c, hed__RelatedContact__c, hed__RelatedContact__r.Name FROM hed__Relationship__c WHERE hed__Type__c = \''+CS_Constants.LEARNING_COACH_TYPE+'\' AND hed__Contact__r.RecordTypeId = :recordTypeIdSTD AND hed__RelatedContact__r.RecordTypeId = :recordTypeIdLC AND LastModifiedDate >= :dateTimeInterval';
            
         }
        else {
          batchQueryStr = 'SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Status__c, hed__RelatedContact__c, hed__RelatedContact__r.Name FROM hed__Relationship__c WHERE hed__Contact__c = :studRecsIdSet AND hed__Contact__r.RecordTypeId = :recordTypeIdSTD AND hed__RelatedContact__r.RecordTypeId = :recordTypeIdLC AND hed__Type__c = \''+CS_Constants.LEARNING_COACH_TYPE+'\'';            
          
        
        }


        return Database.getQueryLocator(batchQueryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__Relationship__c> relationshipRecs){
        map<Id, set<Id>> studentIdWithSetOfLCRecIdSetMap = new map<Id, set<Id>>();
        map<String, hed__Relationship__c> studentIdAndLCRecIdWithRelationshipsMap = new map<String, hed__Relationship__c>();
        
        for(hed__Relationship__c relationRecObj : relationshipRecs){
           // To identify the Relationships defined between a Student and associated Learning Coach.
          if(!studentIdAndLCRecIdWithRelationshipsMap.containsKey(String.valueOf(relationRecObj.hed__Contact__c)+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c))){
            studentIdAndLCRecIdWithRelationshipsMap.put(String.valueOf(relationRecObj.hed__Contact__c)+'-'+String.valueOf(relationRecObj.hed__RelatedContact__c), relationRecObj);
          }
          // To identify the related Learning Coaches associated to the respective Students across Schools. 
          if(!studentIdWithSetOfLCRecIdSetMap.containsKey(relationRecObj.hed__Contact__c)){
            set<Id> relatedLCRecsIdSet = new set<Id>();
            relatedLCRecsIdSet.add(relationRecObj.hed__RelatedContact__c);
            studentIdWithSetOfLCRecIdSetMap.put(relationRecObj.hed__Contact__c, relatedLCRecsIdSet);
          }
          else{
            set<Id> relatedLCRecsIdSet = studentIdWithSetOfLCRecIdSetMap.get(relationRecObj.hed__Contact__c);
            relatedLCRecsIdSet.add(relationRecObj.hed__RelatedContact__c);
            studentIdWithSetOfLCRecIdSetMap.put(relationRecObj.hed__Contact__c, relatedLCRecsIdSet);
          }
       }                
        
        // Calling the Batch-Apex handler class to process the revoking and provisioning of the CT permission-sets in relation to the Schools that the Learning Coach comes under.
        if(!studentIdWithSetOfLCRecIdSetMap.isEmpty() && !studentIdAndLCRecIdWithRelationshipsMap.isEmpty()){
            CS_LCUserAccessToSchoolCTKBAsHandler handlerObj = new CS_LCUserAccessToSchoolCTKBAsHandler();            


            permissionSetsRemovalMap.putAll(handlerObj.processRelationshipRecsForCTPermSetsAccess(studentIdWithSetOfLCRecIdSetMap, studentIdAndLCRecIdWithRelationshipsMap));            
        }
    }        
    
    global void finish(Database.BatchableContext bc){
       // Deleting Permission Set Assignments as necessary after processing Program Enrollment batches.
       if((permissionSetsRemovalMap != null) && !permissionSetsRemovalMap.isEmpty()){
            permsSetAssignDeleteList.addAll(permissionSetsRemovalMap.get('To Delete'));
            if((permsSetAssignDeleteList != null) && !permsSetAssignDeleteList.isEmpty()){
                for(PermissionSetAssignment psaDeleteRecObj : permsSetAssignDeleteList ){
                    CS_Constants.permsSetAssignFinalDeleteMap.put(psaDeleteRecObj.Id, psaDeleteRecObj);
                }              
            }
       }

       if(CS_Constants.permsSetAssignFinalDeleteMap != null && !CS_Constants.permsSetAssignFinalDeleteMap.isEmpty()){
          database.delete(CS_Constants.permsSetAssignFinalDeleteMap.values(), false); 
       }
        
        // Chaining call to the Relationship Batch Apex process
       // To handle provisioning and revoking of the CT Permission-Sets for the Learning Coach Community Users.
       Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Batch_Size__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.LC_KBA_ACCESS_RELNSHIP_RECS_PROCESS_INTERVAL];
       Integer batchSize = 200;
       if((recordProcessInterval.Batch_Size__c != null) && (recordProcessInterval.Batch_Size__c > 0)){
           batchSize = Integer.valueOf(recordProcessInterval.Batch_Size__c);
       }
       CS_CTAddHhldPermSetsAccessRelnshipBatch batchTempObjone = new CS_CTAddHhldPermSetsAccessRelnshipBatch();
       database.executeBatch(batchTempObjone, batchSize);
    }
}