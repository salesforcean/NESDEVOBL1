/**
 * Created by Anushka Bansal on 19-12-2018.
 */

trigger NES_PlacementAndElectiveTrigger on Placement_and_Elective__c (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert)
        {
            NES_PlacementAndElectiveHandler.handleAfterInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            NES_PlacementAndElectiveHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }

    }
}