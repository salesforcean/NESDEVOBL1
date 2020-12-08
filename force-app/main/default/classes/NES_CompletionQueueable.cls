/**
 * Created by triciaigoe on 2019-02-08.
 */

public without sharing class NES_CompletionQueueable implements Queueable  {

    private Id programEnrollmentId;
    private Id processId;

    public void execute(QueueableContext context) {

        Map<Id, Enrollment_Component_Affiliation__c> affiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();

        List<Enrollment_Component_Affiliation__c> studentAffiliations = [
                SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Enrollment_Component__r.Is_Required__c, Enrollment_Component__r.Completion_Logic__c,
                        Enrollment_Component__r.Assignment_Logic__c, Enrollment_Component__r.RecordType.Name, Status__c, Order__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__c = : programEnrollmentId
        ];
        
        list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();//added by anitha p
        for(Enrollment_Component_Affiliation__c affiliation : studentAffiliations) {
            affiliationMap.put(affiliation.Enrollment_Component__c, affiliation);
            thisStudentsECAs.add(affiliation);//added by anitha p
        }
          system.debug('im here'+affiliationMap);
        system.debug('im here'+affiliationMap.size());
        //added
        hed__Program_Enrollment__c  studentEnrollment = [
                SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                FROM hed__Program_Enrollment__c
                WHERE Id = :programEnrollmentId
        ];
        //added
        
        NES_ECACompletion.evaluateCompletion(programEnrollmentId, processId, null, affiliationMap,thisStudentsECAs,studentEnrollment);

    }

    public NES_CompletionQueueable(Id enrollmentId, Id processId) {

        this.programEnrollmentId = enrollmentId;
        this.processId = processId;
    }
}