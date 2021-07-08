/**
 * Created by Ashish Sharma on 01/07/19
 * Class Name: NES_RelationshipTrigger
 * Test Class Name: NES_SharingUtilityTest
 * Purpose : Apex Trigger on hed__Relationship__c
*/
trigger NES_RelationshipTrigger on hed__Relationship__c (after insert, after update) {
    if(trigger.isAfter){
        if(trigger.isInsert){
            NES_RelationshipTriggerHandler.afterInsert(trigger.new);
        }

        if(trigger.isUpdate){
            NES_RelationshipTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        }
    }
}