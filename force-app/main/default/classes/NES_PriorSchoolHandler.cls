/**
 * Created by ajith on 12/12/18.
 */

public with sharing class NES_PriorSchoolHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('PriorSchoolHandler');

    public static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('Last School Type and State');

   // public static void handleAfterInsert(List<Prior_School__c> newList) { //Swapna-Changed signature
      public static void handleAfterInsert(List<Prior_School__c> newList,List<Prior_School__c> actList) {
        System.debug('logicSwitch1' + logicSwitch);
        if (logicSwitch) {
            NES_BusinessLogicUtils.updateLastSchoolStateandType(newList, null);
        }
        /*11/9/2019 Alex - removing as part of the placement redesign 
       // NES_PriorSchoolBusinessLogic.calculatePlacement(newList, null);
        NES_PriorSchoolBusinessLogic.calculatePlacement(actList, null); //Swapna:Changed to active list
        */
        //if (NES_Constants.runAssignment || Test.isRunningTest()) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Prior_School__c newObject = new Prior_School__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Prior_School__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
           //Swapna:Changed to active list
              for (Prior_School__c newInfo : actList) {
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Prior_School__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            newFieldUpdate.schoolYear = newInfo.School_Year__c;
                            newFieldUpdate.questionGroup =  newInfo.Question_Group__c;
                            newFieldUpdate.mostRecent =  newInfo.Most_Recent__c;
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterInsert', e);
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Prior_School__c', peToObjectMap, fieldUpdateList);
        //}


    }

  //  public static void handleAfterUpdate(Map<Id, Prior_School__c> oldMap, Map<Id, Prior_School__c> newMap) {//Swapna -Changed signature

      public static void handleAfterUpdate(Map<Id, Prior_School__c> newMap, Map<Id, Prior_School__c> oldMap,Map<Id, Prior_School__c> actlstnewMap,Map<Id, Prior_School__c> actlstoldMap) {    
        System.debug('logicSwitch2' + logicSwitch);
        if (logicSwitch) {
            NES_BusinessLogicUtils.updateLastSchoolStateandType(newMap.values(), oldMap);
        }
        /*11/9/2019 Alex - removing as part of the placement redesign 
      //  NES_PriorSchoolBusinessLogic.calculatePlacement(newMap.values(), oldMap); 
       NES_PriorSchoolBusinessLogic.calculatePlacement(actlstnewMap.values(), actlstoldMap); //Swapna:Changed to active list
       */
        //if (NES_Constants.runAssignment || Test.isRunningTest()) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Prior_School__c newObject = new Prior_School__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Prior_School__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

            //Swapna:Changed to active list
            for (Prior_School__c newInfo : actlstnewMap.values()) {

                Prior_School__c oldInfo = actlstoldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Prior_School__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
                            newFieldUpdate.schoolYear = newInfo.School_Year__c;
                            newFieldUpdate.questionGroup =  newInfo.Question_Group__c;
                            newFieldUpdate.mostRecent =  newInfo.Most_Recent__c;
                            fieldUpdateList.add(newFieldUpdate);
                        }
                    } catch (Exception e) {
                        System.debug('Error: ' + e);
                        logger.logException('handleAfterUpdate', e);
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Prior_School__c', peToObjectMap, fieldUpdateList);
        //}

    }

}