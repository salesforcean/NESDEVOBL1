/**
 * Created by triciaigoe on 1/14/19.
 */

trigger NES_AnnualHouseholdInfoTrigger on Annual_Household_Information__c (after insert, after update) {
    if (Trigger.isAfter && Trigger.isInsert) {
      //  NES_AnnualHouseholdInfoHandler.handleAfterInsert(Trigger.new);
      //Swapna:Changed the logic to ensure the business and logic is executed for active students
           List<Annual_Household_Information__c> actlst = new List<Annual_Household_Information__c>();
           for(Annual_Household_Information__c pe:Trigger.new)
           {
               if(pe.Student_Act_Status__c  == true)
               actlst.add(pe);   
           }  
          NES_AnnualHouseholdInfoHandler.handleAfterInsert(Trigger.new,actlst);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
      //  NES_AnnualHouseholdInfoHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
         //Swapna:Changed the logic to ensure the business and logic is executed for active students
          
           Map<Id,Annual_Household_Information__c> actlstoldMap = new Map<Id,Annual_Household_Information__c>();
           Map<Id,Annual_Household_Information__c> actlstnewMap = new Map<Id,Annual_Household_Information__c>();
           for(Annual_Household_Information__c asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
              
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));
           }
           }
          //  NES_AnnualHouseholdInfoHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap,actlstoldMap, actlstnewMap);
          NES_AnnualHouseholdInfoHandler.handleAfterUpdate(Trigger.newMap,Trigger.oldMap, actlstnewMap, actlstoldMap);
           
    }
}