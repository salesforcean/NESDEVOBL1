/**
 * Created by Anushka Bansal on 21-12-2018.
 */

trigger NES_ProgramGradeLevelTrigger on Program_Grade_Level__c (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert)
        {
            NES_ProgramGradeLevelHandler.handleAfterInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            NES_ProgramGradeLevelHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
        }

    }
}