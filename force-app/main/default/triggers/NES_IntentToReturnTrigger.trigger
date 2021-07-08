trigger NES_IntentToReturnTrigger on Intent_To_Return__c (before insert, before update, after insert, after update) {
    if(Trigger.isAfter){   
         if(Trigger.isInsert){
            NES_IntentToReturnHandler.handleAfterInsert(Trigger.new);
        }    
        if(Trigger.isUpdate){
            NES_IntentToReturnHandler.handleAfterUpdate(Trigger.new,  Trigger.oldMap, Trigger.newMap);
        }
       
    }
}