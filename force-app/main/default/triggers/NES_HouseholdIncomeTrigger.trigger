/**
 * Created by Anushka on 14-12-2018.
 */
trigger NES_HouseholdIncomeTrigger on Household_Income__c(before insert, before update, after insert, after update) {   
   

    if ( Trigger.isUpdate ){
        if(Trigger.isBefore)
        {
          //Commented the unnecessary code and removed the comments for Bug #202908 by (Krishna Peddanagammol)
           Map<Id,Household_Income__c> actlstoldMap = new Map<Id,Household_Income__c>();
           Map<Id,Household_Income__c> actlstnewMap = new Map<Id,Household_Income__c>();
           for(Household_Income__c asi:Trigger.new){           
              actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
              actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));           
           }
           NES_HouseholdIncomeHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap,actlstnewMap,actlstoldMap);
           
        }
        if(Trigger.isAfter){
          Map<Id,Household_Income__c> actlstoldMap = new Map<Id,Household_Income__c>();
           Map<Id,Household_Income__c> actlstnewMap = new Map<Id,Household_Income__c>();
           for(Household_Income__c asi:Trigger.new){
            actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));          
           }
           NES_HouseholdIncomeHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap,actlstnewMap,actlstoldMap);
        }
       
    }
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
           List<Household_Income__c> actlst = new List<Household_Income__c>();
           for(Household_Income__c pe:Trigger.new)
           {
              actlst.add(pe);   
           }  
           NES_HouseholdIncomeHandler.handleAfterInsert(Trigger.new,actlst);
        }
       
    }
  
}