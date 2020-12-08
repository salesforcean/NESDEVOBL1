/**
 * Created by Ritvik on 19-11-2018.
 */

trigger NES_AnnualStudentInfoTrigger on Annual_Student_Information__c (after insert, after update, before insert, before update) {
    if( Trigger.isInsert ){
        if(Trigger.isBefore){
            NES_AnnualStudentInfoHandler.handleBeforInsert(Trigger.new);
        }
        if(Trigger.isAfter){
           // NES_AnnualStudentInfoHandler.handleAfterInsert(Trigger.new);
           //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
           List<Annual_Student_Information__c> actlst = new List<Annual_Student_Information__c>();
           for(Annual_Student_Information__c asi:Trigger.new){
               if(asi.Student_Act_Status__c == true)
               actlst.add(asi);   
           }  
           NES_AnnualStudentInfoHandler.handleAfterInsert(Trigger.new,actlst);      
        }
    }
    else if ( Trigger.isUpdate ){
        if(Trigger.isBefore){
            NES_AnnualStudentInfoHandler.handleBeforUpdate(Trigger.newMap, Trigger.oldMap);
        }
        if(Trigger.isAfter)
        {
          //  NES_AnnualStudentInfoHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap);
          //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
           List<Annual_Student_Information__c> actlst = new List<Annual_Student_Information__c>();
           Map<Id,Annual_Student_Information__c> actlstoldMap = new Map<Id,Annual_Student_Information__c>();
           Map<Id,Annual_Student_Information__c> actlstnewMap = new Map<Id,Annual_Student_Information__c>();
           for(Annual_Student_Information__c asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
               actlst.add(asi);
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));
           }
           }
           NES_AnnualStudentInfoHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap, Trigger.newMap,actlst, actlstoldMap, actlstnewMap);
           
          
        }
    }
}