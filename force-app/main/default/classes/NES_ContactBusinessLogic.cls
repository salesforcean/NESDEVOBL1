public class NES_ContactBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('ContactBusinessLogic');

    /**
     * Created by Anushka on 22-11-2018.
     * Purpose : This method takes the Program Enrollment Ids of all the contact records where the Age__c field is updated.
     * The Program Enrollment Ids are then passed to NES_AnnualStudentInformationUtilities class to
     * recalculate the Recommended Auto-Placement on the related current Annual student Information record.
     */
    public static void calculatePlacement(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        System.debug('In Contact Business logic for Update');
        Set<Id> contactIds = new Set<Id> ();

        for (Contact con : newMap.values()) {
            //Modified as part of the Bug 78218 - Ajith
            if (con.Birthdate__c != null && con.Birthdate__c != oldMap.get(con.Id).Birthdate__c) {
                contactIds.add(con.Id);
            }
        }

        if (contactIds.size() > 0) {
            List<Enrollment_Component_Affiliation__c> affiliations = [
                                                                      SELECT Id, Program_Enrollment__c, Status__c, Program_Enrollment__r.hed__Contact__c
                                                                      FROM Enrollment_Component_Affiliation__c
                                                                      WHERE Program_Enrollment__r.hed__Contact__c IN :contactIds
                                                                      AND Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = TRUE
                                                                     ];

            Map<Id, List<Enrollment_Component_Affiliation__c>> contactAffiliationMap = new Map<Id, List<Enrollment_Component_Affiliation__c>> ();
            for (Enrollment_Component_Affiliation__c affiliation : affiliations) {
                List<Enrollment_Component_Affiliation__c> tempAffiliations = new List<Enrollment_Component_Affiliation__c> ();
                if (contactAffiliationMap.containsKey(affiliation.Program_Enrollment__r.hed__Contact__c)) {
                    tempAffiliations = contactAffiliationMap.get(affiliation.Program_Enrollment__r.hed__Contact__c);
                }
                tempAffiliations.add(affiliation);
                contactAffiliationMap.put(affiliation.Program_Enrollment__r.hed__Contact__c, tempAffiliations);
            }

            List<Id> finalContactIds = new List<Id> ();
            for (Id contactId : contactAffiliationMap.keySet()) {
                List<Enrollment_Component_Affiliation__c> contactAffiliations = contactAffiliationMap.get(contactId);
                Boolean runPlacement = true;

                for (Enrollment_Component_Affiliation__c contactAffiliation : contactAffiliations) {

                    if (contactAffiliation.Status__c != 'Complete') {
                        runPlacement = false;
                        break;
                    }
                }
                if (runPlacement) {
                    finalContactIds.add(contactId);
                }
            }

            if (finalContactIds.size() > 0) {
                Map<Id, Annual_Student_Information__c> asis = new Map<Id, Annual_Student_Information__c> ([SELECT Id FROM Annual_Student_Information__c WHERE Program_Enrollment__r.hed__Contact__c IN :finalContactIds]);
                List<Id> asiIds = new List<Id> ();
                asiIds.addAll(asis.keySet());
                NES_AnnualStudentInfoBusinessLogic.verifySameYearASI(asiIds);
            }
        }
    }

    /**
     * Created By Anushka on 12/18/2018
     * purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Insert/Update.
     */

    public static void calculateLTS(List<Contact> newList, Map<Id, Contact> oldMap) {
        Set<Id> contactIds = new Set<Id> ();
        for (Contact contact : newlist) {
            if (oldMap != null) {
                System.debug('Why_Is_Your_Child_Attending_CA__c ' + contact.Why_Is_Your_Child_Attending_CA__c);
                System.debug(' oldMap Why_Is_Your_Child_Attending_CA__c ' + oldMap.get(contact.Id).Why_Is_Your_Child_Attending_CA__c);
                if (contact.Why_Is_Your_Child_Attending_CA__c != oldMap.get(contact.Id).Why_Is_Your_Child_Attending_CA__c) { }
                contactIds.add(contact.Id);
            } else {
                if (contact.Why_Is_Your_Child_Attending_CA__c != null)
                contactIds.add(contact.Id);
            }
        }

        if (contactIds.size() > 0) {
            Map<Id, hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id, hed__Program_Enrollment__c> ([Select id from hed__Program_Enrollment__c where hed__Contact__c in :contactIds]);
            List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentMap.keySet());
            try {
                update programEnrollments;
            } catch(Exception ex) {
                System.debug('Exception Thrown :' + ex.getMessage());
                logger.logException('calculateLTS', ex);
                logger.saveLogs();
            }
        }
    }

    //added :Begin -- for the US 185603 by Jagadeesh
    @future //added for US 203078 by Jagadeesh
    public static void CountNoOfContacts(set<Id> acctIds) {
        List<Account> acctsToUpdate = new List<Account> ();
        if(!acctIds.IsEmpty()){
          Map<Id, AggregateResult> results = new Map<Id, AggregateResult>([SELECT AccountId Id, Count(id) ContactCount FROM Contact WHERE AccountId in :acctIds AND RecordType.Name = 'Students' GROUP BY AccountId]);
            for(id accId : acctIds){
                Account acc = new Account();
                if(results.containsKey(accId)){
                   AggregateResult ar = results.get(accId);                
                   acc.id = accId;
                   acc.Number_of_Students__c = (integer) ar.get('ContactCount'); 
                }  
                else{
                   acc.id = accId;
                   acc.Number_of_Students__c = 0; 
                }
                acctsToUpdate.add(acc);
            }
        }
      
        if (acctsToUpdate.size() > 0) {
            try {
                update acctsToUpdate;
            } catch(Exception ex) {
                System.debug('Error: ' + ex.getMessage());
                logger.logException('Errorfound', ex);
                logger.saveLogs();
            }

        }
    }
}
 //Added :End -- for the US 185603 by Jagadeesh