/**
 * Created by Anushka on 19-12-2018.
 * Purpose : Handler class for ProgramGradeLevelTrigger.
 */

public without sharing class NES_ProgramGradeLevelHandler {

    static final Boolean waitListFlagCalSwitch = NES_TriggerUtility.businessLogicSwitch('Waitlist Flag Calculation');
    static final Boolean whyFlaggedLogicSwitch = NES_TriggerUtility.businessLogicSwitch('Why Flagged');

    public static void handleAfterInsert(List<Program_Grade_Level__c> newList) {

        if (waitListFlagCalSwitch) {
            NES_ProgramGradeLevelBusinessLogic.waitListCalculator(null, newList); // Added by Anushka
        }

        if(whyFlaggedLogicSwitch){
            NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newList, null);
        }
    }

    public static void handleAfterUpdate(List<Program_Grade_Level__c> newList, Map<Id, Program_Grade_Level__c> newMap, Map<Id, Program_Grade_Level__c> oldMap) {
        if (waitListFlagCalSwitch) {
            NES_ProgramGradeLevelBusinessLogic.waitListCalculator(oldMap, newList); // Added by Anushka
        }
        if(whyFlaggedLogicSwitch){
           NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newMap.values(), oldMap);
        }
    }

}