/**
 * Created by ajith on 12/12/18.
 */

trigger NES_PriorSchoolTrigger on Prior_School__c (before insert, before update, after insert, after update) {

    if(Trigger.isUpdate && Trigger.isAfter){
       // NES_PriorSchoolHandler.handleAfterUpdate( Trigger.newMap, Trigger.oldMap);
       //Swapna:Changed the logic to ensure the business and logic is executed for active students
           
           Map<Id,Prior_School__c> actlstoldMap = new Map<Id,Prior_School__c>();
           Map<Id,Prior_School__c> actlstnewMap = new Map<Id,Prior_School__c>();
           for(Prior_School__c asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
              
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));
           }
           }
           NES_PriorSchoolHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap,actlstnewMap,actlstoldMap);
    }
    if(Trigger.isInsert && Trigger.isAfter){
       // NES_PriorSchoolHandler.handleAfterInsert( Trigger.new);
          //Swapna:Changed the logic to ensure the business and logic is executed for active students
           List<Prior_School__c> actlst = new List<Prior_School__c>();
           for(Prior_School__c pe:Trigger.new)
           {
               if(pe.Student_Act_Status__c  == true)
               actlst.add(pe);   
           }  
          NES_PriorSchoolHandler.handleAfterInsert(Trigger.new,actlst);
    }

}