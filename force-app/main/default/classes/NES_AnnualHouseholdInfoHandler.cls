/**
 * Created by Raju on 15-12-2018
 */
public with sharing class NES_AnnualHouseholdInfoHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('AnnualHouseholdInfoHandler');

    static final Boolean federal_Poverty_Eligibility_Switch = NES_TriggerUtility.BusinessLogicSwitch('Federal Poverty Eligibility');
    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.BusinessLogicSwitch('Likelihood to Transition Score');

    public static void handleAfterInsert(List<Annual_Household_Information__c> newList, List<Annual_Household_Information__c> actList) {

        Boolean origRunAssignment = NES_ECACompletion.shouldRunCompletion && NES_Constants.runAssignment;
        // NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;

        //if (origRunAssignment) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            Annual_Household_Information__c newObject = new Annual_Household_Information__c();
            // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Annual_Household_Information__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>> ();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>> ();

            // for new ECA Model...
            hed__Program_Enrollment__c queriedPE;

            // for (Annual_Household_Information__c newInfo : newList) { 
            //Swapna:Changed to active list
            for (Annual_Household_Information__c newInfo : actList) {
                List<String> changedFields = new List<String> ();
                
                // for new ECA Model...
                queriedPE = peMapQueried.get(newInfo.Program_Enrollment__c);

                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str); //This is for the old ECA processing model.

                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Annual_Household_Information__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            newFieldUpdate.schoolYear = newInfo.School_Year__c;
                            newFieldUpdate.studentOrHousehold = (queriedPE.RecordType.Name == 'Student') ? 'Student' : 'Household';
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch(Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterInsert', e);
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id> ();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);

            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Annual_Household_Information__c', peToObjectMap, fieldUpdateList);
        //}

        if (federal_Poverty_Eligibility_Switch)
            NES_AnnualHouseholdInfoBusinessLogic.federalPovertyEligibility(actList, null); // Swapna:Changed to Active list
        if (likelihoodToTransitionScore)
            NES_AnnualHouseholdInfoBusinessLogic.calculateLTS(actList, null); // Swapna:Changed to activelist
    }

    public static void handleAfterUpdate(Map<Id, Annual_Household_Information__c> newMap, Map<Id, Annual_Household_Information__c> oldMap, Map<Id, Annual_Household_Information__c> actlstnewMap, Map<Id, Annual_Household_Information__c> actlstoldMap) {

        Boolean origRunAssignment = NES_ECACompletion.shouldRunCompletion && NES_Constants.runAssignment;
        // NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;

        //if (origRunAssignment) { //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Annual_Household_Information__c newObject = new Annual_Household_Information__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Annual_Household_Information__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>> ();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>> ();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            // for new ECA Model...
            hed__Program_Enrollment__c queriedPE;

            for (Annual_Household_Information__c newInfo : actlstnewMap.values()) {

                Annual_Household_Information__c oldInfo = actlstoldMap.get(newInfo.Id);
                List<String> changedFields = new List<String> ();

                // for new ECA Model...
                queriedPE = peMapQueried.get(newInfo.Program_Enrollment__c);

                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);

                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Annual_Household_Information__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            newFieldUpdate.schoolYear = newInfo.School_Year__c;
                            newFieldUpdate.studentOrHousehold = (queriedPE.RecordType.Name == 'Student') ? 'Student' : 'Household';
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch(Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterUpdate', e);
                        logger.saveLogs();
                    }
                }
                changedFieldsMap.put(newInfo.Id, changedFields);
                List<Id> changedObjects = new List<Id> ();
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);

            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Annual_Household_Information__c', peToObjectMap, fieldUpdateList);
        //}

        System.debug('Calling the federalPovertyEligibility+++');
        if (federal_Poverty_Eligibility_Switch)
            NES_AnnualHouseholdInfoBusinessLogic.federalPovertyEligibility(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
        if (likelihoodToTransitionScore) {
            NES_AnnualHouseholdInfoBusinessLogic.calculateLTS(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
        }

        NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;
    }

    public static Map<Id, hed__Program_Enrollment__c> peMapQueried {
        get {
            if (peMapQueried==null && allPEIds!=null) {
                peMapQueried = new Map<Id, hed__Program_Enrollment__c>([
                    SELECT  Id, hed__Account__r.Use_Updated_ECA_Process__c, Recordtype.Name  
                    FROM    hed__Program_Enrollment__c
                    WHERE   Id IN :allPEIds
                ]);
            }
            return peMapQueried;
        }
        set;
    }

    public static Set<Id> allPEIds {
        get {
            if (allPEIds==null) {
                allPEIds = new Set<Id>();
                for (Annual_Household_Information__c ahi : (List<Annual_Household_Information__c>) Trigger.new) {
                    allPEIds.add(ahi.Program_Enrollment__c);
                }
            }
            return allPEIds;
        }
        set;
    }
}