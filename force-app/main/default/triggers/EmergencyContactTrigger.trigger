/**
 * @description       : This Trigger handles update on Emergency_Contact__c object.
 * @author            : Mark Membrino
 * @last modified on  : 10-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   10-01-2020   Mark Membrino         Initial Version - kicks-off PEC re-calculations on update to CareTaker/HouseHold Emergency_Contact__c record.
**/
trigger EmergencyContactTrigger on Emergency_Contact__c (after insert, after update)
{
    if (Trigger.isAfter && Trigger.isInsert)
    {
        EmergencyContactTriggerHandler.handleAfterInsert(Trigger.new,Trigger.newMap);
    }

    if (Trigger.isAfter && Trigger.isUpdate)
    {
        EmergencyContactTriggerHandler.handleAfterUpdate(Trigger.new,Trigger.newMap, Trigger.oldMap);
    }
}