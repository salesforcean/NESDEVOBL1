/**
 * Created by Raju on 22-11-2018.
 * Purpose : EnrollmentDocumentTrigger.for Enrollment document
 */

trigger NES_EnrollmentDocTrigger on Enrollment_Document__c (before insert, before update,after insert ,after update) {
    NES_EnrollmentDocHandler handler = new NES_EnrollmentDocHandler();
    if ( Trigger.isUpdate ){
        if(Trigger.isBefore)
        {
           NES_EnrollmentDocHandler.handleBeforeUpdate(Trigger.new,Trigger.newMap, Trigger.oldMap);
         
        }
        if(Trigger.isAfter)
        {
         //   NES_EnrollmentDocHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
            //Swapna:Changed the logic to ensure the business and logic is executed for active students
          
           Map<Id,Enrollment_Document__c> actlstoldMap = new Map<Id,Enrollment_Document__c>();
           Map<Id,Enrollment_Document__c> actlstnewMap = new Map<Id,Enrollment_Document__c>();
           for(Enrollment_Document__c asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
              
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));
           }
           }
           NES_EnrollmentDocHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap,actlstnewMap, actlstoldMap);
        }
       
    }
    if(Trigger.isInsert){
        if(Trigger.isBefore)
        {
           NES_EnrollmentDocHandler.handleBeforeInsert(Trigger.new);
            
        }
        if(Trigger.IsAfter){
          // NES_EnrollmentDocHandler.handleAfterInsert(Trigger.new, Trigger.newMap);
           //Swapna:Changed the logic to ensure the business and logic is executed for active students
           List<Enrollment_Document__c> actlst = new List<Enrollment_Document__c>();
           Map<Id,Enrollment_Document__c> actlstnewMap = new Map<Id,Enrollment_Document__c>();
           for(Enrollment_Document__c asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
               actlst.add(asi);
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
              
           }
           }
           NES_EnrollmentDocHandler.handleAfterInsert(Trigger.new, Trigger.newMap,actlst, actlstnewMap);
        }
       
    }
    
}