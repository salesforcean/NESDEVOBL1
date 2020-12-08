/*
 * Developed By: Rakesh Ramaswamy (NESS TECHNOLOGIES)
 * User Story #. 164369
 * Description - This is a batch job class used to process the Program Enrollment records to determine whether the related KBAs depending on the School that the LC falls under should be made accessible to the LC Community User.
 *               All the Program Enrollment records will be pulled that were updated on a specific time frame (Historical records processing) and based on that the related Relationships records defined for each Student and Learning Coach,
 *               will be processed to determine whether the LC Community user(s) access should be provisioned or revoked to the School CT permission-set accordingly. This batch chains the invocation of the batch job on the Relationship records 
 *               that will have to be processed subsequently.
*/

global class CS_LCUserCTPermSetsAccessProgEnrBth_v2 implements Database.Batchable<sObject>, Database.Stateful{

    global set<Id> studentRecsIdSet = new set<Id>();
    global map<String, list<PermissionSetAssignment>> permissionSetsAssignMap;
   // global list<PermissionSetAssignment> permsSetAssignInsertList;
    global list<PermissionSetAssignment> permsSetAssignDeleteList;
    
    global CS_LCUserCTPermSetsAccessProgEnrBth_v2() {
        permissionSetsAssignMap = new map<String, list<PermissionSetAssignment>>();
       // permsSetAssignInsertList = new list<PermissionSetAssignment>();
        permsSetAssignDeleteList = new list<PermissionSetAssignment>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {        
        Id recordTypeIdSTD = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CS_Constants.CONTACT_RECTYPE_STUDENTS).getRecordTypeId();
        Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Id, Days__c, Hours__c, Minutes__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.LC_KBA_ACCESS_PROGENROLL_RECS_PROCESS];
        DateTime dateTimeInterval = system.now().addDays(Integer.valueOf(recordProcessInterval.Days__c)).addHours(Integer.valueOf(recordProcessInterval.Hours__c)).addMinutes(Integer.valueOf(recordProcessInterval.Minutes__c));       
        String batchQueryStr = 'SELECT Id, Name, hed__Contact__c, hed__Contact__r.Name, hed__Account__c, Status__c, School_Account_ID__c, School_Name__c FROM hed__Program_Enrollment__c WHERE (Status__c = \''+CS_Constants.PE_WITHDRAWN_STATUS+'\' OR Status__c = \''+CS_Constants.PE_COMPLETE_STATUS+'\') AND hed__Contact__r.RecordTypeId = :recordTypeIdSTD AND LastModifiedDate >= :dateTimeInterval';
        return Database.getQueryLocator(batchQueryStr);
    }
    
    global void execute(Database.BatchableContext bc, List<hed__Program_Enrollment__c> programEnrollRecs){        
         set<Id> studentRecsIdSet = new set<Id>();
        
        for(hed__Program_Enrollment__c programEnrollObj : programEnrollRecs){
           studentRecsIdSet.add(programEnrollObj.hed__Contact__c);                  
        }
        
        // Calling the Batch-Apex handler class to process the revoking and provisioning of the CT permission-sets in relation to the Schools that the Learning Coach comes under.
        if((studentRecsIdSet != null) && !studentRecsIdSet.isEmpty()){
            CS_LCUserAccessToSchoolCTKBAsHandler_v2 handlerObj = new CS_LCUserAccessToSchoolCTKBAsHandler_v2();
            permissionSetsAssignMap.putAll(handlerObj.LCUserSchoolCTPermSetsAccessProgEnroll(studentRecsIdSet));
        }
    }        
    
    global void finish(Database.BatchableContext bc){
    
       // Inserting Permission Set Assignments as deemed necessary after processing Program Enrollment batches.
         // permsSetAssignInsertList.addAll(permissionSetsAssignMap.get('To Insert'));
         // if((permsSetAssignInsertList != null) && !permsSetAssignInsertList.isEmpty()){
             // database.insert(permsSetAssignInsertList, false);
         //    CS_Constants.permsSetAssignFinalInsertList.addAll(permsSetAssignInsertList);
        //  }
       // Deleting Permission Set Assignments as necessary after processing Program Enrollment batches.
          permsSetAssignDeleteList.addAll(permissionSetsAssignMap.get('To Delete'));
          if((permsSetAssignDeleteList != null) && !permsSetAssignDeleteList.isEmpty()){
             // database.delete(permsSetAssignDeleteList, false);
             for(PermissionSetAssignment psaRecObj : permsSetAssignDeleteList){
                 CS_Constants_v2.permsSetAssignFinalDeleteMap.put(psaRecObj.Id, psaRecObj); 
             }
          }
    
       // Chaining call to the Relationship Batch Apex process
       // To handle provisioning and revoking of the CT Permission-Sets for the Learning Coach Community Users.
       Records_Processing_Intervals__mdt recordProcessInterval = [SELECT Batch_Size__c FROM Records_Processing_Intervals__mdt WHERE DeveloperName = :CS_Constants.LC_KBA_ACCESS_RELNSHIP_RECS_PROCESS_INTERVAL];
       Integer batchSize = 200;
       if((recordProcessInterval.Batch_Size__c != null) && (recordProcessInterval.Batch_Size__c > 0)){
           batchSize = Integer.valueOf(recordProcessInterval.Batch_Size__c);
       }
       CS_LCUserCTPermSetsAccessRelnshipBth_v2 batchTempObj = new CS_LCUserCTPermSetsAccessRelnshipBth_v2(studentRecsIdSet);
       database.executeBatch(batchTempObj, batchSize);
    }
}