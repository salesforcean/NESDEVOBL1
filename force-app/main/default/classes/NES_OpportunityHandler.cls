/**
 * Created by Anand on 12/3/2018.
 */

public with sharing class NES_OpportunityHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('OpportunityHandler');

    static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('OpportunityTrigger');
    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.BusinessLogicSwitch('Likelihood to Transition Score');

   // public static void beforeInsert(List<Opportunity> opportunityList) { //Swapna changed signature

      public static void beforeInsert(List<Opportunity> opportunityList,List<Opportunity> opportunityactList) {
      
       NES_OpportunityBusinessLogic.populateFinal_SemesterIndicator(opportunityactList);//Swapna:Changed to active list

      //  NES_OpportunityBusinessLogic.populateFinal_SemesterIndicator(opportunityList);//Anand

    }
 //   public static void beforeUpdate(Map<Id, Opportunity> oldMap, List<Opportunity> newList, Map<Id, Opportunity> newMap) {//Swapna-Changed signature
      public static void beforeUpdate(Map<Id, Opportunity> oldMap, List<Opportunity> newList, Map<Id, Opportunity> newMap,Map<Id, Opportunity> actlstoldMap, List<Opportunity> newactList, Map<Id, Opportunity> actlstnewMap) {
     //   NES_OpportunityBusinessLogic.updateFinalSemesterIndicator(oldMap, newMap); //Anand
          NES_OpportunityBusinessLogic.updateFinalSemesterIndicator(actlstoldMap, actlstnewMap); //Swapna Changed to Active list
        // if(!logicSwitch) return ;
        NES_OpportunityBusinessLogic.updateOpportunityConfirmationDate(oldMap, newList);// Added by Raju


    }
   // public static void afterUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap) { //Swapna-Changed signature
      public static void afterUpdate(Map<Id, Opportunity> oldMap, Map<Id, Opportunity> newMap,Map<Id, Opportunity> actlstoldMap, Map<Id, Opportunity> actlstnewMap) {

        if (logicSwitch) {
            NES_OpportunityBusinessLogic.populateEnrollmentDate_Update(oldMap, newMap);
            NES_OpportunityBusinessLogic.householdDateUpdate(oldMap, newMap);
            NES_OpportunityBusinessLogic.markOpenOpportunity(newMap.values());
        }

        if (likelihoodToTransitionScore) {
          NES_OpportunityBusinessLogic.calculateLTS(actlstoldMap, actlstnewMap.values()); // Swapna:Changed to Active list
        }

        System.debug('Opp After Trigger NES_Constants.runAssignment:' + NES_Constants.runAssignment);
        //if (NES_Constants.runAssignment) {  //The run assignment check is now in the competion code.  This change needed for the ECA rewrite.
            Opportunity newObject = new Opportunity(); // This takes all available fields from the required object.
            Schema.SObjectType objType = newObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Opportunity.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            Map<Id, List<Id>> peToObjectMap = new Map<Id, List<Id>>();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.

            for (Opportunity newInfo : actlstnewMap.values()) {

                Opportunity oldInfo = actlstoldMap.get(newInfo.Id);
                List<String> changedFields = new List<String>();
                for (String str : mapFields.keySet()) {
                    try {
                        if (newInfo.get(str) != oldInfo.get(str)) {
                            changedFields.add(str);
                            //These are for the new ECA processing model.  
                            EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                            newFieldUpdate.programEnrollmentId = newInfo.Program_Enrollment__c;
                            newFieldUpdate.objectAndFieldName = 'Opportunity.' + str;
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
            NES_ECACompletion.relatedCompletion(changedFieldsMap, 'Opportunity', peToObjectMap, fieldUpdateList);
        //}

    }

  //  public static void afterInsert(List<Opportunity> newList) { //Swapna-Changed signature
      public static void afterInsert(List<Opportunity> newList,List<Opportunity> actList) {
        if (logicSwitch) {
            NES_OpportunityBusinessLogic.reactivationDateUpdate(newList); //Anand
        }

        if (likelihoodToTransitionScore)
          NES_OpportunityBusinessLogic.calculateLTS(null, actList); // Swapna:Changed to active list
         //   NES_OpportunityBusinessLogic.calculateLTS(null, newList); // Added by Anushka
    }

}