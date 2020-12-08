/*
* Created by: Chinnamnaidu N
* Created date: 2019-07-31
* Purpose: Trigger on User object to update custom settings
* Change Log:
*         2019-08-01 initial Chinnamnaidu N for #102150 User Story
*/
trigger NES_UserTrigger on User (after insert, after update) {
    
    if ((Trigger.isAfter && Trigger.isInsert) || (Trigger.isAfter && Trigger.isUpdate)) {
        // call @future trigger handler because of mixed DML
        NES_UserTriggerHandler.afterInsertUpdateFuture(Trigger.newMap.keySet());
    }
}