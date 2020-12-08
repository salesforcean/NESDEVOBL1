public class ProgramEnrollmentCriteriaHandler  {
    public static void handleAfterUpdate(List<Program_Enrollment_Criteria__c> newList, Map<Id, Program_Enrollment_Criteria__c> newMap, Map<Id, Program_Enrollment_Criteria__c> oldMap) {
        List<Program_Enrollment_Criteria__c> allUpdatedPECs = new List<Program_Enrollment_Criteria__c>();
        //Collect all PE Criteria that have a changed result.
        for (Program_Enrollment_Criteria__c pec: newList) {
            if (pec.Result__c <> oldMap.get(pec.id).Result__c)
                allUpdatedPECs.add(pec);
        }

        //Build a set of all the impacted criteria
        set<Id> impactedCriteria = new Set<Id> ();
        set<Id> impactedPEs = new Set<Id> ();
        for (Program_Enrollment_Criteria__c pec: allUpdatedPECs) {
            impactedCriteria.add(pec.Criteria__c);
            impactedPEs.add(pec.Program_Enrollment__c);
        }

        //Use the ECC (Enrollment Component Criteria) object to find all the Enrollment components that could be impacted.
        Set<Id> impactedECs = new Set<Id>();
        for (Enrollment_Component_Criteria__c ecc: [select Enrollment_Component__c from Enrollment_Component_Criteria__c where Criteria__c in :impactedCriteria]) {
            impactedECs.add(ecc.Enrollment_Component__c);
        }

        //Go get all the ECAs for all the PEs that were impacted and then mark the ones dirty that had an EC updated.
        set<Enrollment_Component_Affiliation__c> ECAsToUpdateSet = new set<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca : [select id, Program_Enrollment__c, Enrollment_Component__c 
                                                    from Enrollment_Component_Affiliation__c 
                                                    where Program_Enrollment__c in :impactedPEs  and Enrollment_Component__c in :impactedECs]) {
            ECAsToUpdateSet.add(new Enrollment_Component_Affiliation__c(id = eca.Id, Is_Dirty__c = true));
        }


        //Convert the ECA set to a list for updating.
        list<Enrollment_Component_Affiliation__c> ECAsToUpdateList = new list<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c eca:ECAsToUpdateSet){
            ECAsToUpdateList.add(eca);
        }

        if (ECAsToUpdateList.size() > 0) 
            update ECAsToUpdateList;
    }
}