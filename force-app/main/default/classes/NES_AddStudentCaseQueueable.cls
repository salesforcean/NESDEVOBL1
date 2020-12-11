/**
 * Author- VaniShravan Katta/ Version 1 /2020-06-03/ U.S 184915/ new Case/Task-Student Registration
 */

public without sharing class NES_AddStudentCaseQueueable implements Queueable {

    private User caretaker;
    private Id newStudentEnrollment;
    private Contact newStudent;
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_AddStudentCaseQueueable');

    public void execute(QueueableContext context) {

        try {
            Case c = new Case();
            c.AccountId = caretaker.Contact.AccountId;
            c.ContactId = caretaker.ContactId;
            c.Origin = 'Enrollment Community'; //Mohammad Shaik-Based on picklist value api name change for US : 183731
            c.Type = 'Enrollment Assistance';
            c.Ticket_Type__c = 'New Applicant Call';

            if (caretaker.contact.account.Family_Enrollment_Counselor__c != null)
                c.ownerid = caretaker.contact.account.Family_Enrollment_Counselor__c; // vani 184915
            else {
                //Go get the default queue that is stored in the label Add_a_Student_Case_Queue.
                list<Group> groups = new list<Group> ([select Id from Group where Type = 'Queue' AND DeveloperName = 'Enrollment_Support_Queue']);
                if (groups.size() > 0) //Should always be 1 but just in case.
                c.ownerid = groups[0].id;
            }

            c.Platform__c = 'Pearson Connexus';
            c.Description = 'New Applicant Call';
            c.Program_Enrollment__c = newStudentEnrollment;
            c.Subject = label.Case_Subject + '-' + newStudent.FirstName + ' ' + newStudent.LastName;  
            c.RecordTypeId = Schema.SObjectType.case.RecordTypeInfosByName.get('Enrollment Support').RecordTypeId; //r.Id;// Vani Changes- 184915
            c.Program_Enrollment__c = newStudentEnrollment; // Vani Changes- 184915
            insert c;
            // Vani Changes- 184915 : Started
            List<FEC_Task_Creation_Rule__mdt> objFECTaskCrRule = [SELECT Id, MasterLabel, DeveloperName, thresholdPercent__c, lowerLimitInDays__c,
                                                                  upperLimitInDays__c, taskTypeDefault__c, taskSubTypeDefault__c, Order__c
                                                                  FROM FEC_Task_Creation_Rule__mdt
                                                                  Where order__c = 0
                                                                  ORDER BY Order__c DESC];
            if (objFECTaskCrRule != null && objFECTaskCrRule.size() > 0) {
                Task objTask = new Task();
                Case objCase = [Select Id, OwnerId, Program_Enrollment__r.Percent_Complete__c, Program_Enrollment__r.hed__Contact__c From Case WHERE ID = :c.Id];
                objTask = Batch_FECTaskCreation.setNewTask(objCase, objFECTaskCrRule[0]);
                system.debug('objTask : ' + objTask);
                if (objTask != null)
                insert objTask;
            }
        } catch(Exception ex) { System.debug('Exception Thrown:' + ex.getMessage()); logger.logException('execute', ex); logger.saveLogs(); }

    }

    public NES_AddStudentCaseQueueable(User objCaretaker, Id enrollmentId, Contact objContact) {
        this.newStudentEnrollment = enrollmentId;
        this.caretaker = objCaretaker;
        this.newStudent = objContact;
    }

}