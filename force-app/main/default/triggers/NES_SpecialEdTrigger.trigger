trigger NES_SpecialEdTrigger on Special_Education__c(before insert, before update, after insert, after update) {
    if ( Trigger.isBefore ){
        if(Trigger.isUpdate)
        {
            NES_SpecialEdHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        }

        if(Trigger.isInsert){
            NES_SpecialEdHandler.handleBeforeInsert(Trigger.new);
        }
       
    }
    if(Trigger.isAfter){
        if(Trigger.isInsert)
        {
            NES_SpecialEdHandler.afterInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            NES_SpecialEdHandler.afterUpdate(Trigger.newMap, Trigger.oldMap);
        }
       
    }

}