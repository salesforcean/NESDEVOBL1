/**
 * Created by triciaigoe on 1/14/19.
 */

trigger NES_ExtendedDataTrigger on Extended_Data__c (after insert, after update, before insert) {

    if ( Trigger.isUpdate ){
        if(Trigger.isAfter)
        {
            NES_ExtendedDataHandler.completionCheck(Trigger.oldMap, Trigger.newMap);
        }
    }

    if(Trigger.isInsert){
        if(Trigger.isBefore){
            NES_ExtendedDataHandler.updateSchoolYear(Trigger.new);
        }
        
        if(Trigger.isAfter){
            NES_ExtendedDataHandler.runCompletion(Trigger.newMap);
        }
    }

}