/**
 * Created by Anand on 12/10/2018.
 */

public with sharing class NES_HomeLanguageSurveyHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('HomeLanguageSurveyHandler');

    static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('HomeLanguageSurveyTrigger');
    static final Boolean hlsStudentFlagSwitch = NES_TriggerUtility.BusinessLogicSwitch('HLS Student Flag');
    static final Boolean hlsLanguageFlagSwitch = NES_TriggerUtility.BusinessLogicSwitch('HLS Language Spoken By Adults');

    public static void afterInsert(List<Home_Language_Survey__c> hlsList,List<Home_Language_Survey__c> actList) {

        if (!logicSwitch) return ;

        //if (NES_Constants.runAssignment) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Home_Language_Survey__c newObject = new Home_Language_Survey__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Home_Language_Survey__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
              for (Home_Language_Survey__c newInfo : actList) {//Swapna:Changed to active list
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Home_Language_Survey__c.' + str;
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Home_Language_Survey__c', peToObjectMap, fieldUpdateList);
        //}

         NES_HomeLanguageSurveyBusinessLogic.calculateELLFlag(actList, null); //Swapna:Changed to active list

        if (!hlsLanguageFlagSwitch) return ;
        NES_HomeLanguageSurveyBusinessLogic.calculateHLSLanguageSpokenByAdults(actList, null);//Swapna:Changed to active list
    }
    public static void afterUpdate(Map<Id, Home_Language_Survey__c> newMap, Map<Id, Home_Language_Survey__c> oldMap,Map<Id, Home_Language_Survey__c> actlstnewMap, Map<Id, Home_Language_Survey__c> actlstoldMap) {

        //if (NES_Constants.runAssignment || Test.isRunningTest()) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Home_Language_Survey__c newObject = new Home_Language_Survey__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Home_Language_Survey__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

            //Swapna:Changed to activelist
            for (Home_Language_Survey__c newInfo : actlstnewMap.values()) {

                Home_Language_Survey__c oldInfo = actlstoldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Home_Language_Survey__c.' + str;
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Home_Language_Survey__c', peToObjectMap, fieldUpdateList);
        //}

        if (!logicSwitch) return ;
            NES_HomeLanguageSurveyBusinessLogic.calculateELLFlag(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list

        //Added by Ritvik 12/14/18
        if (hlsLanguageFlagSwitch)
            NES_HomeLanguageSurveyBusinessLogic.calculateHLSLanguageSpokenByAdults(actlstnewMap.values(), actlstoldMap);//Swapna:Changed to active list
    }

    public static void handleBeforeInsert(List<Home_Language_Survey__c> newList,List<Home_Language_Survey__c> actList) {
        if (hlsStudentFlagSwitch)
         NES_HomeLanguageSurveyBusinessLogic.calculateHLSStudentFlag(actList, null); //Swapna:Changed to active list
          //  NES_HomeLanguageSurveyBusinessLogic.calculateHLSStudentFlag(newList, null); // Added by Anushka 12/14/2018
    }
    public static void handleBeforeUpdate(Map<Id, Home_Language_Survey__c> newMap, Map<Id, Home_Language_Survey__c> oldMap,Map<Id, Home_Language_Survey__c> actlstnewMap, Map<Id, Home_Language_Survey__c> actlstoldMap) {
        if (hlsStudentFlagSwitch)
        NES_HomeLanguageSurveyBusinessLogic.calculateHLSStudentFlag(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
          //  NES_HomeLanguageSurveyBusinessLogic.calculateHLSStudentFlag(newMap.values(), oldMap); // Added by Anushka 12/14/2018
    }

}