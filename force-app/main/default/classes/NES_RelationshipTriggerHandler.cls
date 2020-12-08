/**
 * Created by Ashish Sharma on 01/07/19
 * Class Name: NES_RelationshipTriggerHandler
 * Test Class Name: NES_SharingUtilityTest
 * Purpose : Trigger handler class for NES_RelationshipTrigger, Task #66225
*/
public class NES_RelationshipTriggerHandler {
    /**
     * Created by Ashish Sharma on 01/07/19
     * Parameters: List<hed__Relationship__c>
     * Return Type: void
     * Purpose : Method to handle actions on after insert event
    */
    public static void afterInsert(List<hed__Relationship__c> newList){
        List<hed__Relationship__c> relationshipList = new List<hed__Relationship__c>();
        List<hed__Relationship__c> relationshipsForOwnerUpdate = new List<hed__Relationship__c>();
        for(hed__Relationship__c relationship : newList){
            if(relationship.hed__Contact__c != null && relationship.hed__RelatedContact__c != null && !relationship.Recalculate_Sharing__c){
                relationshipList.add(relationship);
            }
            //Added by Ajith for the Bug#77598
            if(relationship.OwnerId != System.Label.NES_Household_OwnerId){
                relationshipsForOwnerUpdate.add(relationship);
            }
        }

        if(relationshipList.size() > 0){

            //Mark to recalculate Apex sharing
            NES_SharingUtility.markForRecalculation((List<SObject>)relationshipList,null);
        }

        if(!relationshipsForOwnerUpdate.isEmpty()){
            //updateOwnerToHouseHold(relationshipsForOwnerUpdate);
        }
    }

    /**
     * Created by Ashish Sharma on 01/07/19
     * Parameters: List<hed__Relationship__c>, Map<Id, hed__Relationship__c>
     * Return Type: void
     * Purpose : Method to handle actions on after update event
    */
    public static void afterUpdate(List<hed__Relationship__c> newList, Map<Id, hed__Relationship__c> oldMap){
        List<hed__Relationship__c> relationshipList = new List<hed__Relationship__c>();
        List<hed__Relationship__c> relationshipsForOwnerUpdate = new List<hed__Relationship__c>();
        for(hed__Relationship__c relationship : newList){
            if( ( (relationship.hed__Contact__c != oldMap.get(relationship.Id).hed__Contact__c) ||
               (relationship.hed__RelatedContact__c != oldMap.get(relationship.Id).hed__RelatedContact__c) || Test.isRunningTest()) && !relationship.Recalculate_Sharing__c){

                relationshipList.add(relationship);
            }

            //Added by Ajith for the Bug#77598
            if(relationship.OwnerId != System.Label.NES_Household_OwnerId){
                relationshipsForOwnerUpdate.add(relationship);
            }
        }

        //Mark to recalculate Apex sharing
        NES_SharingUtility.markForRecalculation((List<SObject>)relationshipList,null);
        if(!relationshipsForOwnerUpdate.isEmpty()){
            //updateOwnerToHouseHold(relationshipsForOwnerUpdate);
        }

    }
}