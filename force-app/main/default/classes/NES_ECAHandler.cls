/**
  * Change Log:
  * 2019-08-13 modified for #101935 User Story ,Task 104310 by Anitha P
  * Purpose : This method is used to Set status of Parent ECA and repective ECA stage, when the ECA status of child component changed from 'Completed' to 'In progress' or 'Not started'.
  * Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-06
  * Change Log: 2019-11-21 modified for #119349 User Story by Anitha P
  * Change Log: [142977] : 02-27-2020 : ALI KM : Optimizing the firstRun Flag logic, splitting it to run for multiple method calls.
  * Change Log: Added/changed for User story 123972 by Chinnamanaidu Neerasa 08-04-2020
  * Change Log: Added for User story 184917 by Chinnamanaidu Neerasa 28-05-2020
*/



public class NES_ECAHandler {

    static final Boolean automatedPlacementProcessSwitch = NES_TriggerUtility.BusinessLogicSwitch('Automated Placement Process');
    static final Boolean UpdateAllPareantECAsStatus = NES_TriggerUtility.BusinessLogicSwitch('UpdateAllPareantECAsStatus');
    //Added for #101935 User Story (Task 104310) on 2019-08-13

    // US # [142977] : 02-27-2020 : ALI KM : Optimizing the firstRun Flag logic.
    // static Boolean isFirstTime = true;
    static Boolean updateAllParentECAsStatusFirstRunFlag = true;
    static Boolean runECACompletionForNAStatusFirstRunFlag = true;

    public static void handleAfterInsert(List<Enrollment_Component_Affiliation__c> newList) {
        NES_ECABusinessLogic.filterWaitListECARecords(newList, null);
        //Changed story 123972 by Chinnamanaidu.
        List<hed__Program_Enrollment__c> pesToSetWaitListDateList = new List<hed__Program_Enrollment__c> ();
        Map<Id, hed__Program_Enrollment__c> updatePEMap = new Map<Id, hed__Program_Enrollment__c> ();
        Set<Id> ECAIdSet = new Set<Id> ();
        for (Enrollment_Component_Affiliation__c eca : newList) {
            ECAIdSet.add(eca.Id);
        }
        List<Enrollment_Component_Affiliation__c> affiliations = [

                                                                  SELECT Id, Status__c, Order__c, Enrollment_Component__r.Component_Type__c, Enrollment_Component__r.RecordType.Name,
                                                                  Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c, Program_Enrollment__c,
                                                                  Program_Enrollment__r.Household_Program_Enrollment__r.id,
                                                                  Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id,
                                                                  Enrollment_Component__r.Waitlist__c, Enrollment_Component__r.Name, Program_Enrollment__r.Waitlist_Time_Date_Stamp__c
                                                                  FROM Enrollment_Component_Affiliation__c
                                                                  WHERE Id IN :ECAIdSet];
        for (Enrollment_Component_Affiliation__c eca : affiliations) {
            if (eca.Status__c == 'In Progress') {
                if (eca.Enrollment_Component__r.Waitlist__c) {
                    hed__Program_Enrollment__c PE;
                    if (updatePEMap.containsKey(eca.Program_Enrollment__c)) {
                        PE = updatePEMap.get(eca.Program_Enrollment__c);
                    }
                    else {
                        PE = new hed__Program_Enrollment__c();
                    }
                    PE.Id = eca.Program_Enrollment__c;
                    PE.Waitlist_Time_Date_Stamp__c = System.now();
                    updatePEMap.put(eca.Program_Enrollment__c, PE);
                }
                if (eca.Enrollment_Component__r.RecordType.Name == 'Stage') {
                    hed__Program_Enrollment__c PE;
                    if (updatePEMap.containsKey(eca.Program_Enrollment__c)) {
                        PE = updatePEMap.get(eca.Program_Enrollment__c);
                    }
                    else {
                        PE = new hed__Program_Enrollment__c();
                    }
                    PE.Id = eca.Program_Enrollment__c;
                    PE.Stage__c = eca.Enrollment_Component__r.Name;
                    PE.Stage_Date__c = System.now();
                    updatePEMap.put(eca.Program_Enrollment__c, PE);
                }
            }
        }
        if (!updatePEMap.isEmpty()) {
            update updatePEMap.values();
        }
    }

    public static void handleAfterUpdate(List<Enrollment_Component_Affiliation__c> newList, Map<Id, Enrollment_Component_Affiliation__c> newMap, Map<Id, Enrollment_Component_Affiliation__c> oldMap) {

        List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliationsToProcess = new List<Enrollment_Component_Affiliation__c> ();
        //added for #101935 User Story (Task 104310) on 2019-08-13
        List<Enrollment_Component_Affiliation__c> statusChangedECAs = new List<Enrollment_Component_Affiliation__c> ();
        //added for #101935 User Story (Task 104310) on 2019-08-13
        //Added Program_Enrollment__r.Status__c field in SOQL query for the bug 328454 on 10/30/2020
        List<Enrollment_Component_Affiliation__c> affiliations = [
                                                                  // added 123972- ECA's EC record type and record name
                                                                  SELECT Id, Status__c, Order__c, Deferral_Date__c, Enrollment_Component__r.Component_Type__c, Enrollment_Component__r.RecordType.Name,

                                                                  Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c,Program_Enrollment__r.Status__c, Program_Enrollment__c,
                                                                  Program_Enrollment__r.Household_Program_Enrollment__r.id, Program_Enrollment__r.WaitlistFlag__c, 
                                                                  Program_Enrollment__r.Household_Program_Enrollment__r.hed__Account__r.id, Enrollment_Component__r.Name,
                                                                  Enrollment_Component__r.Waitlist__c, Program_Enrollment__r.Waitlist_Time_Date_Stamp__c,Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c
                                                                  FROM Enrollment_Component_Affiliation__c

                                                                  WHERE Id IN :newMap.keySet()];

        if (ECA_CriteriaEvaluator.processedECAs!=null && ECA_CriteriaEvaluator.processedECAs.size()>0) 
        {
           ECA_HierarchyStatusUpdate.run(ECA_CriteriaEvaluator.processedECAs);
        }

        // US # [122106] : 01-20-2020 : ALI KM : Added below code for ECA.Status = NotApplicable scenarios.
        List<Enrollment_Component_Affiliation__c> naECAs = new List<Enrollment_Component_Affiliation__c> ();
        // US # [122106] END

        Map<Id, hed__Program_Enrollment__c> pesToUpdateMap = new Map<Id, hed__Program_Enrollment__c> ();

        for (Enrollment_Component_Affiliation__c eca : affiliations) {
            if (eca.Status__c != null && oldMap.get(eca.Id).Status__c != eca.Status__c && eca.Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c) {
                enrollmentComponentAffiliationsToProcess.add(eca);
            }
            //added for #101935 User Story (Task 104310) on 2019-08-13 to check the status of updated ECA changed for 'Complete' to 'In progress' or 'Not started' and collect all those ECA's in list
            //updated for 122106, added oldMap check for ECA.Status = 'Not Applicable'
            //MM 8/26/2020  Added check to only include ECA for PEs in the old ECA process.
            //updated for 227705, added oldMap check for ECA.Status = 'Deferred'

            /*if (eca.Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c == false && (oldMap.get(eca.Id).Status__c == 'Complete' || 
               (oldMap.get(eca.Id).Status__c == 'Not Applicable' || oldMap.get(eca.Id).Status__c == 'Deferred') && 
               oldMap.get(eca.Id).Status__c != eca.Status__c && (eca.Status__c == 'Not Started' || eca.Status__c == 'In Progress'))){
                   statusChangedECAs.add(eca);
            }*/
            
			  //added for #101935 User Story (Task 104310) on 2019-08-13 to check the status of updated ECA changed for 'Complete' to 'In progress' or 'Not started' and collect all those ECA's in list
            //updated for 122106, added oldMap check for ECA.Status = 'Not Applicable'
            //MM 8/26/2020  Added check to only include ECA for PEs in the old ECA process.
            //updated for 227705, added oldMap check for ECA.Status = 'Deferred'
            if (eca.Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c == false && (
               (oldMap.get(eca.Id).Status__c == 'Complete' || oldMap.get(eca.Id).Status__c == 'Not Applicable' || oldMap.get(eca.Id).Status__c == 'Deferred') &&
               oldMap.get(eca.Id).Status__c != eca.Status__c && (eca.Status__c == 'Not Started' || eca.Status__c == 'In Progress'))){
                   system.debug('Old status********'+oldMap.get(eca.Id).Status__c);
                   system.debug('New status********'+eca.Status__c);

                   statusChangedECAs.add(eca);
            }
            //With the ECA rewrite the ECAs we want to track does not include ones that were N/A
            /*if (eca.Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c == true && (
                (oldMap.get(eca.Id).Status__c == 'Complete' || oldMap.get(eca.Id).Status__c == 'Deferred') &&
                oldMap.get(eca.Id).Status__c != eca.Status__c && (eca.Status__c == 'Not Started' || eca.Status__c == 'In Progress'))){
                    statusChangedECAs.add(eca);
            }*/

            //added for #101935 User Story (Task 104310) on 2019-08-13

            // US # [122106] : 01-20-2020 : ALI KM : Added below code for ECA.Status = NotApplicable scenarios.
            // US # [227705] : 09-22-2020 : Krishna Peddanagammol : Added additional condition for ECA.Status = Deferred.
            if (eca.Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c == false && 
               (eca.Status__c == 'Not Applicable' || eca.Status__c == 'Deferred') && eca.Status__c != oldMap.get(eca.Id).Status__c) {
                naECAs.add(eca);
            }
            // US # [122106] END

            //If an ECA is updated to In Progress and it's EC is a waitlist EC, update the Waitlist Date stamp on the PE.
            // Added for story 123972
            if (eca.Status__c == 'In Progress' && oldMap.get(eca.Id).Status__c == 'Not Started' && eca.Enrollment_Component__r.Waitlist__c) {
                hed__Program_Enrollment__c PE;
                if (!pesToUpdateMap.containsKey(eca.Program_Enrollment__c))
                    PE = new hed__Program_Enrollment__c();
                else
                    PE = pesToUpdateMap.get(eca.Program_Enrollment__c);

                PE.id = eca.Program_Enrollment__c;
                PE.Waitlist_Time_Date_Stamp__c = System.now();
                pesToUpdateMap.put(eca.Program_Enrollment__c, PE);
            }
			system.debug('added for debuging waitlist defect**********'+eca.Enrollment_Component__r.Name+'****'+eca.Enrollment_Component__r.RecordType.Name+'*****Status****'+eca.Status__c);
            
            if (eca.Status__c == 'In Progress' && oldMap.get(eca.Id).Status__c<> 'In Progress' && eca.Enrollment_Component__r.RecordType.Name == 'Stage') {
                hed__Program_Enrollment__c PE;
                if (!pesToUpdateMap.containsKey(eca.Program_Enrollment__c))
                    PE = new hed__Program_Enrollment__c();
                else
                    PE = pesToUpdateMap.get(eca.Program_Enrollment__c);

                PE.id = eca.Program_Enrollment__c;
                PE.Stage__c = eca.Enrollment_Component__r.Name;
                PE.Stage_Date__c = System.now();
                pesToUpdateMap.put(eca.Program_Enrollment__c, PE);
            }

            //Stage__c = eca.Enrollment_Component__r.Name
            //if an ECA is of type 'Stage' and is being changed to In Progress, we should the stage on PE.
        }
        // US # [122106] : 01-20-2020 : ALI KM : Added below code for ECA.Status = NotApplicable scenarios.
        System.debug('naECAs=' + JSON.serialize(naECAs));


        NES_ECABusinessLogic.filterWaitListECARecords(newMap.values(), oldMap);
        NES_ECABusinessLogic.validatePhoneType(newMap.values());
        //added for #101935 User Story (Task 104310) on 2019-08-13 to implement functionality which calls UpdateAllPareantECAsStatus on Checking recursive condition

        // US # [142977] : 02-27-2020 : ALI KM : Optimizing the firstRun Flag logic
        // System.debug('isFirstTime=' + isFirstTime);
        if (updateAllParentECAsStatusFirstRunFlag) {
            if (statusChangedECAs.size() > 0) {
                updateAllParentECAsStatusFirstRunFlag = false;
                NES_ECABusinessLogic.updateAllParentECAsStatus(statusChangedECAs);
            }
        }
        if (runECACompletionForNAStatusFirstRunFlag) {
            // US # [122106] : 01-20-2020 : ALI KM : Added below code for ECA.Status = NotApplicable scenarios.
            if (naECAs.size() > 0) {
                runECACompletionForNAStatusFirstRunFlag = false;
                NES_ECABusinessLogic.runECACompletionForNAStatus(naECAs[0]);
            }
            // US # [122106] END
        }
        // US # [142977] : 02-27-2020 : ALI KM : END

        //added for Task 104310
        //If there are any PEs that need the waitlist dates set or to set the stage, set them.
        if (pesToUpdateMap.size() > 0)
            update pesToUpdateMap.values();

        //Start-added for #107180 User Story (Task 108660) on 2019-09-06
        // NES_ECABusinessLogic.updatePAHStatus( newmap ,oldMap); commneted logic as 107180 removed
        //End-added for #107180 User Story (Task 108660) on 2019-09-06
        if (automatedPlacementProcessSwitch) {
            NES_ECABusinessLogic.runPlacementProcess(enrollmentComponentAffiliationsToProcess);
        }
    }

    //Start- Added code for US119349
    //Added by Chinna for user story 184917.
    public static void handleBeforeInsert(List<Enrollment_Component_Affiliation__c> newList) {
        if (newList.size() > 0) {
            //System.debug('SIZE '+newList.size());
            //System.debug('WAITING '+newList[0]);
            Set<Id> ECsReferenced = new Set<Id> ();
            for (Enrollment_Component_Affiliation__c eca : newList) {
                ECsReferenced.add(eca.Enrollment_Component__c);
            }
            List<Enrollment_Component__c> ecList = [select id, Recordtype.name from Enrollment_Component__c where id in :ECsReferenced];
            map<id, string> ecToRecTypeNameMap = new map<id, string> ();
            for (Enrollment_Component__c ec : ecList) {
                ecToRecTypeNameMap.put(ec.id, ec.Recordtype.name);
            }

            for (Enrollment_Component_Affiliation__c eca : newList) {
                if (ecToRecTypeNameMap.get(eca.Enrollment_Component__c) != null) {
                    //System.debug('RECORDTYPE ' +ecToRecTypeNameMap.get(eca.Enrollment_Component__c) );
                    eca.EC_Record_Type__c = ecToRecTypeNameMap.get(eca.Enrollment_Component__c);
                }
            }
        }

        updateMktingDate(newList);

        NES_ECABusinessLogic.completeHouseHoldECAsAlreadyClosed(newList);
    }
    //End- Added code for US119349

    public static void handleBeforeUpdate(List<Enrollment_Component_Affiliation__c> newList, Map<Id, Enrollment_Component_Affiliation__c> newMap, Map<Id, Enrollment_Component_Affiliation__c> oldMap) {
        updateMktingDate(newList);

        ECA_CriteriaEvaluator.processDirtyECAs(newList, newMap, oldMap);
    }

    private static void updateMktingDate(List<Enrollment_Component_Affiliation__c> newList) {
        for (Enrollment_Component_Affiliation__c newInfo : newList) {
            if (newInfo.Date_Became_In_Progress__c == null && newInfo.Status__c == 'In Progress')
            newInfo.Date_Became_In_Progress__c = System.now();

            if (newInfo.Date_Became_Complete__c == null && newInfo.Status__c == 'Complete')
            newInfo.Date_Became_Complete__c = System.now();

            if (newInfo.Date_Became_In_Progress__c == null && newInfo.Status__c == 'Complete')
            newInfo.Date_Became_In_Progress__c = System.now();
        }
    }
}