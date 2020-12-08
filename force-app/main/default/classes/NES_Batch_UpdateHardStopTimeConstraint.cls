/**
* Created by ajith on 26/10/18.
* Modified by Anand on 27/10/18
* Desciption: To update all necessary records to accurately stop a contact from continuing a process that time has expired for
*/

global class NES_Batch_UpdateHardStopTimeConstraint implements DataBase.Batchable<sObject> {
    private static Peak_ApexLog logger = new Peak_ApexLog('UpdateHardStopTimeConstraint');

    public String query;
    public List<String> statusList;
    public DATETIME currentTime;
    public List<Id> enrollmentIdsExpired;

    global NES_Batch_UpdateHardStopTimeConstraint() {

        enrollmentIdsExpired = new List<Id>();
        statusList = new List<String>{
                'Complete', 'Time Expired'
        };
        currentTime = Datetime.now();

        //Query to retreive  affiliations whose status is not equals to TimeExpired or Completed
        query = 'SELECT Enrollment_Component__r.Confirmation_Form__c,Id,Enrollment_Component__r.RecordType.Name,Program_Enrollment__r.hed__Account__r.Enrollment_Stop_Date__c,Status__c,Program_Enrollment__r.hed__Account__r.Confirmation_End_Date__c ,Program_Enrollment__r.Status__c, Program_Enrollment__r.hed__Account__c,Program_Enrollment__c FROM Enrollment_Component_Affiliation__c WHERE Status__c NOT IN:statusList AND  ';
        query = query + '( Program_Enrollment__r.hed__Account__r.Enrollment_Stop_Date__c < :currentTime OR Program_Enrollment__r.hed__Account__r.Confirmation_End_Date__c < :currentTime )';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('Query===>>' + Query);
        Database.QueryLocator enrollmentAffiliations = Database.getQueryLocator(query);
        System.debug('enrollmentAffiliations' + enrollmentAffiliations);
        return enrollmentAffiliations;
    }

    global void execute(Database.BatchableContext BC, List<Enrollment_Component_Affiliation__c> scope) {
        Set<Id> parentEnrollmentIds = new Set<Id>();
        List<Opportunity> opportunitiesList = new LIst<Opportunity>();
        List<hed__Program_Enrollment__c> enrollmentsToUpdate = new List<hed__Program_Enrollment__c>();
        List<sObject> sobjectsToUpdate = new List<sObject>();
        List<Enrollment_Component_Affiliation__c> affiliationsToUpdate = new List<Enrollment_Component_Affiliation__c>();
        Set<Id> setOfProgramEnrollmentIds = new Set<Id>();
        Set<Id> setOfFormProgramEnrollmentIds = new Set<Id>();
        Set<Id> programEnrollmentIds = new Set<Id>();
        Map<Id, List<Enrollment_Component_Affiliation__c>> mapOfprogEnrollmentToECA = new Map<Id, List<Enrollment_Component_Affiliation__c>>();
        for (Enrollment_Component_Affiliation__c affiliation : Scope) {
            System.debug('Component Confirmation ==>>>' + affiliation.Enrollment_Component__r.Confirmation_Form__c);
            System.debug('End Date==>>'+affiliation.Program_Enrollment__r.hed__Account__r.Confirmation_End_Date__c);
            if (affiliation.Enrollment_Component__r.RecordType.Name == 'FORM' && affiliation.Enrollment_Component__r.Confirmation_Form__c == True && affiliation.Program_Enrollment__r.hed__Account__r.Confirmation_End_Date__c < currentTime) {
                System.debug('Form Component==>>' + affiliation);
                affiliation.Status__c = 'Time Expired';
                affiliationsToUpdate.add(affiliation);
                programEnrollmentIds.add(affiliation.Program_Enrollment__c);
            } else if (affiliation.Enrollment_Component__r.RecordType.Name <> 'FORM' && affiliation.Program_Enrollment__r.hed__Account__r.Enrollment_Stop_Date__c < currentTime) {
                System.debug('Non-Form Component==>>' + affiliation);
                affiliation.Status__c = 'Time Expired';
                affiliationsToUpdate.add(affiliation);
                programEnrollmentIds.add(affiliation.Program_Enrollment__c);
            } else if (affiliation.Enrollment_Component__r.RecordType.Name == 'FORM' && affiliation.Enrollment_Component__r.Confirmation_Form__c != True && affiliation.Program_Enrollment__r.hed__Account__r.Enrollment_Stop_Date__c < currentTime) {
                System.debug('Non-Form Component==>>' + affiliation);
                affiliation.Status__c = 'Time Expired';
                affiliationsToUpdate.add(affiliation);
                programEnrollmentIds.add(affiliation.Program_Enrollment__c);
            }
        }

        System.debug('affiliationsToUpdate ===>>>' + affiliationsToUpdate);
        //update the status of ProgramEnrollment object to Time Expired  and Corresponding opportunities Status to closed Won
        for (hed__Program_Enrollment__c proEnrollment : [
                SELECT id,hed__Account__c,Status__c, (Select Id,StageName from Opportunities__r)
                FROM hed__Program_Enrollment__c
                Where Id In:programEnrollmentIds
        ]) {
            System.debug('proEnrollment == >>>' + proEnrollment);

            proEnrollment.Status__c = 'Time Expired';
            if (proEnrollment.Opportunities__r.size() > 0) {
                for (Opportunity opty : proEnrollment.Opportunities__r) {
                    opty.StageName = 'Closed Lost';
                    opportunitiesList.add(opty);
                }
            }
            enrollmentsToUpdate.add(proEnrollment);
        }


        sobjectsToUpdate.addAll((List<sObject>) (affiliationsToUpdate));
        sobjectsToUpdate.addAll((List<sObject>) (enrollmentsToUpdate));
        sobjectsToUpdate.addAll((List<sObject>) opportunitiesList);
        try {
            update sobjectsToUpdate;
        } catch (exception e) {
            System.debug('Dml Exception ::' + e.getMessage());
            logger.logException('execute', e);
            logger.saveLogs();
        }
    }

    global void finish(Database.BatchableContext BC) {

    }

}