/**
 * Created by Ritvik on 27-12-2018.
 */

@IsTest
private class NES_EnrollmentCompTriggerTest {
   /* @TestSetup
    static void setup() {
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('CSY', System.today());
        // Create a contact with 'Students' record type
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        // Create a account with 'Academic Program' record type
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, true);
        Enrollment_Component__c questionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Question', false);
        questionComponent.Status__c = 'Complete';
        insert questionComponent;
        system.debug('question ' + questionComponent.Id);
        Enrollment_Component__c sectionComponent = Peak_TestUtils.createEnrollmentComponent(academicProgram.Id, 'Section', false);
        sectionComponent.Status__c = 'Inactive';
        insert sectionComponent;
        system.debug('sectionComponent ' + sectionComponent.Id);
        Enrollment_Component_Relationship__c enrollCompRelationship = Peak_TestUtils.createEnrollmentComponentRelationship(questionComponent.Id, sectionComponent.Id);

    }*/

    /**
    * Created by Anushka on 20/11/18.
    **/
    /*static testMethod void testValidateQuestionsInsert() {
        School_Year__c currentSchoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'CSY'];
        Account account = [SELECT Id, RecordType.DeveloperName FROM Account WHERE School_Year__c =: currentSchoolYear.Id limit 1];
        System.debug(account);
        Enrollment_Component__c component = Peak_TestUtils.createEnrollmentComponent(account.Id, 'Question', false);
        component.Type__c = 'Question';
        component.Question_Type__c = 'Radio';
        Test.startTest();
        insert component;
        Test.stopTest();
    }*/

   /* static testMethod void test_ECCompletionCheck(){
        Id enrollmentComponentRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Question').getRecordTypeId();
        Enrollment_Component__c ecRecord = [SELECT Id, Status__c, RecordType.DeveloperName  FROM Enrollment_Component__c WHERE RecordTypeId =: enrollmentComponentRecordTypeId];
        // Enrollment_Component_Relationship__c ecrRecord = [Select id from Enrollment_Component_Relationship__c limit 1];
        // ecrREcord.Status__c = '';
        ecRecord.Status__c = 'Not Complete';
        update ecRecord;
        system.debug('ecrecord '+ ecRecord );
    }*/
}