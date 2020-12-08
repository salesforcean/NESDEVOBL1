/**
 * Created by Anushka on 14-12-2018.
 * Purpose : Handler class for HouseholdIncomeTrigger.
 */

public class NES_HouseholdIncomeHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('HouseholdIncomeHandler');

    static final Boolean incomeFosterChildSwitch = NES_TriggerUtility.BusinessLogicSwitch('HH Income Foster Child');
    static final Boolean total_Gross_HH_IncomeSwitch = NES_TriggerUtility.BusinessLogicSwitch('Total Gross HH Income');
    static final Boolean federal_Poverty_Eligibility_Switch = NES_TriggerUtility.BusinessLogicSwitch('Federal Poverty Eligibility');

     public static void handleBeforeUpdate(Map<Id, Household_Income__c> newMap, Map<Id, Household_Income__c> oldMap,Map<Id, Household_Income__c> actlstnewMap, Map<Id, Household_Income__c> actlstoldMap) {
        system.debug('in household income handle before update');

        if (incomeFosterChildSwitch)
           NES_HouseholdIncomeBusinessLogic.calculateHHIncomeFosterChild(actlstnewMap.values(), actlstoldMap); // Swapna:Changed to Active list
           
        if (total_Gross_HH_IncomeSwitch)
          NES_HouseholdIncomeBusinessLogic.filterAndCalculateTotalGrossHHIncome(actlstnewMap.values(), actlstoldMap); // Swapna:Changed to Active list
           
    }

   public static void handleAfterInsert(List<Household_Income__c> newList,List<Household_Income__c> actList) {

        system.debug('in household income handle after insert');
        //Start: Moved from before insert for BUG #193197 by Krishna Peddanagammol on 2020-06-12
        if (incomeFosterChildSwitch)
        NES_HouseholdIncomeBusinessLogic.calculateHHIncomeFosterChild(actList, null); // Swapna:Changed to Active list
        if (total_Gross_HH_IncomeSwitch)
        NES_HouseholdIncomeBusinessLogic.filterAndCalculateTotalGrossHHIncome(actList, null); // Swapna:Changed to Active list
       //End: Moved from before insert for BUG #193197 by Krishna Peddanagammol on 2020-06-12

        //Updated by Gourav Nirwal to update the coverage, add Test.isRunningTest()
        //if (NES_Constants.runAssignment || Test.isRunningTest()) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Household_Income__c newObject = new Household_Income__c();
            // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Household_Income__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

         // Swapna:Changed to Active list
            for (Household_Income__c newInfo : actList) {
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != null) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Household_Income__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
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
                System.debug('peToObjectMap::'+peToObjectMap);
                if (peToObjectMap.keySet().contains(newInfo.Program_Enrollment__c)) {
                    changedObjects = peToObjectMap.get(newInfo.Program_Enrollment__c);
                }
                changedObjects.add(newInfo.Id);
                peToObjectMap.put(newInfo.Program_Enrollment__c, changedObjects);
            }
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Household_Income__c', peToObjectMap, fieldUpdateList);
        //}

        if (federal_Poverty_Eligibility_Switch)
         NES_HouseholdIncomeBusinessLogic.federalPovertyEligibility(actList, null); // Swapna:Changed to Active list         
    }
   public static void handleAfterUpdate(Map<Id, Household_Income__c> newMap, Map<Id, Household_Income__c> oldMap,Map<Id, Household_Income__c> actlstnewMap, Map<Id, Household_Income__c> actlstoldMap) {
        system.debug('in household income handle after update');

        //Updated by Gourav Nirwal to update the coverage, add Test.isRunningTest()
        //if (NES_Constants.runAssignment || Test.isRunningTest()) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Household_Income__c newObject = new Household_Income__c(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Household_Income__c.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

              //Swapna:Changed to Active list            
                  for (Household_Income__c newInfo : actlstnewMap.values()) {

                Household_Income__c oldInfo = actlstoldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Household_Income__c.' + str;
                            newFieldUpdate.newValue = newInfo.get(str);
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Household_Income__c', peToObjectMap, fieldUpdateList);
        //}


        if (federal_Poverty_Eligibility_Switch)
         NES_HouseholdIncomeBusinessLogic.federalPovertyEligibility(actlstnewMap.values(), actlstoldMap);// Swapna:Changed to Active list
    }
}