/**
 * Created by Anushka on 22-11-2018.
 * Purpose : Handler class for SpecialEducationTrigger.
 */

public class NES_SpecialEdHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('SpecialEdHandler');

    static final Boolean logicSwitch = NES_TriggerUtility.businessLogicSwitch('SpecialEdTrigger');
    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.businessLogicSwitch('Likelihood to Transition Score');
    static final Boolean whyFlaggedLogicSwitch = NES_TriggerUtility.businessLogicSwitch('Why Flagged');

    public static void handleBeforeUpdate(Map<Id, Special_Education__c> newMap, Map<Id, Special_Education__c> oldMap) {

    }

    public static void handleBeforeInsert(List<Special_Education__c> newList) {

    }

    public static void afterInsert(List<Special_Education__c> newList) {
        //Start: Task #60094 Ashish Sharma December 14, 2018
        if (NES_EntranceAgeUtility.entranceAgeEligibilitySwitch) {
            List<SObject> validRecords = new List<SObject>();

            for (Special_Education__c specialEducation : newList) {
	            validRecords.add(specialEducation);
            }

           if (validRecords.size() > 0) {
                NES_BusinessLogicUtils.calculateEntranceAgeEligibility(validRecords);
            }
        }
        //End Task #60094
        if (likelihoodToTransitionScore) {
            NES_SpecialEdBusinessLogic.calculateLTS(null, newList); // Added by Anushka
        }
        //START - Task #59999 Raju December 24, 2018
        if (whyFlaggedLogicSwitch) {
            NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newList, null) ;
        }

        if (NES_Constants.runAssignment || Test.isRunningTest()) {
            Special_Education__c newObject = new Special_Education__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Special_Education__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Special_Education__c newInfo : newList) {

                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Special_Education__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('afterInsert', e);
                        logger.saveLogs();
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id>();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            if (fieldUpdateList.size()>0) {
                NES_ECACompletion.shouldRunCompletion = true;
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Special_Education__c', peToObjectMap, fieldUpdateList);
            NES_ECACompletion.shouldRunCompletion = false;
        }

    }

    public static void afterUpdate(Map<Id, Special_Education__c> newMap, Map<Id, Special_Education__c> oldMap) {
        Boolean origRunAssignment = NES_Constants.runAssignment;
        NES_Constants.runAssignment = false;
        //Start: Task #60094 Ashish Sharma December 14, 2018
        if (NES_EntranceAgeUtility.entranceAgeEligibilitySwitch) {
            List<SObject> validRecords = new List<SObject>();

            for (Special_Education__c specialEducation : newMap.values()) {
            //    if ( (specialEducation.IEPLastUpdated__c != oldMap.get(specialEducation.Id).IEPLastUpdated__c) ||
			//		 (specialEducation.IEPHistory__c != oldMap.get(specialEducation.Id).IEPHistory__c)  )
			//	{
                    validRecords.add(specialEducation);
           //     }
            }

            if (validRecords.size() > 0) {
                NES_BusinessLogicUtils.calculateEntranceAgeEligibility(validRecords);
            }
        }

        if (likelihoodToTransitionScore) {
            NES_SpecialEdBusinessLogic.calculateLTS(oldMap, newMap.values()); // Added by Anushka
        }
        //START - Task #59999 Raju December 24, 2018
        if (whyFlaggedLogicSwitch) {
            NES_BusinessLogicUtils.invokeCalculateWhyFlagMethod(newMap.values(), oldMap);
        }
        
        /* 11/9/2019 Alex - removed as part of placement redesign
        NES_SpecialEdBusinessLogic.calculatePlacement(newMap.values(), oldMap); */

        NES_Constants.runAssignment = origRunAssignment;
        //END - Task #59999

        if (NES_Constants.runAssignment || Test.isRunningTest()) {
            Special_Education__c newObject = new Special_Education__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Special_Education__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();  //spec ed id to list of changed spec ed fields
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();  //PE to list of updated spec ed ids
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (Special_Education__c newInfo : newMap.values()) {

                Special_Education__c oldInfo = oldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);

                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Special_Education__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('afterUpdate', e);
                        logger.saveLogs();
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id>();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            if (fieldUpdateList.size()>0) {
                NES_ECACompletion.shouldRunCompletion = true;
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Special_Education__c', peToObjectMap, fieldUpdateList); 
            NES_ECACompletion.shouldRunCompletion = false;
        }

    }
}