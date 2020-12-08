/**
 * Created by Anand on 3/19/2019.
 */
@isTest
private class NES_AnnouncementsControllerTest {

    @TestSetup
    static void testSetup() {
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        User portalUser = Peak_TestUtils.CreatePortalCaretTakerUser();
        Contact studentContact = Peak_TestUtils.createContact('Student Contact',academicAccount.Id,'Students',true);
        hed__Relationship__c relationship = Peak_TestUtils.createRelationship(portalUser.ContactId,studentContact.Id,true);
        hed__Program_Enrollment__c programEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,studentContact.Id,schlYear.Id,false);

        programEnrollment.Final_Grade_Level__c = '8';
        insert programEnrollment;

        Grade_Level__c gradeLevel1 = Peak_TestUtils.createGradeLevel('8',true);
        Grade_Level__c gradeLevel2 = Peak_TestUtils.createGradeLevel('10',true);

        Program_Grade_Level__c programGradeLevel1 = Peak_TestUtils.createProgramGradeLevel('Test PGL1', academicAccount.Id,gradeLevel1.Id,System.today().addDays(50),true);
        Program_Grade_Level__c programGradeLevel2 = Peak_TestUtils.createProgramGradeLevel('Test PGL2', academicAccount.Id,gradeLevel2.Id,System.today().addDays(50),true);

        Announcement__c announcement1 = Peak_TestUtils.createAnnouncement('Test Announcment1',false);
        announcement1.Alert_Type__c = 'Notification';
        announcement1.Body__c = 'Test data for body.';
        announcement1.Date_On__c = System.today().addDays(-20);
        announcement1.Date_Off__c = System.today().addDays(10);
        announcement1.Dismissable__c = false;
        announcement1.Order__c = 1;
        announcement1.Program_Grade_Level__c = programGradeLevel1.Id;
        announcement1.Account__c = null;
        insert announcement1;

        Announcement__c announcement2 = Peak_TestUtils.createAnnouncement('Test Announcment2',false);
        announcement2.Alert_Type__c = 'Notification';
        announcement2.Body__c = 'Test data for body.';
        announcement2.Date_On__c = System.today().addDays(-20);
        announcement2.Date_Off__c = System.today().addDays(10);
        announcement2.Dismissable__c = false;
        announcement2.Order__c = 2;
        announcement2.Program_Grade_Level__c = programGradeLevel1.Id;
        announcement2.Account__c = null;
        insert announcement2;

        Announcement__c announcement3 = Peak_TestUtils.createAnnouncement('Test Announcment3',false);
        announcement3.Alert_Type__c = 'Notification';
        announcement3.Body__c = 'Test data for body.';
        announcement3.Date_On__c = System.today().addDays(-20);
        announcement3.Date_Off__c = System.today().addDays(10);
        announcement3.Dismissable__c = false;
        announcement3.Order__c = 3;
        announcement3.Program_Grade_Level__c = programGradeLevel2.Id;
        announcement3.Account__c = null;
        insert announcement3;

        Contact_Announcement__c contactAnnouncement = Peak_TestUtils.createContactAnnouncement('Test Contact Announcment',portalUser.ContactId,announcement1.Id,false);
        contactAnnouncement.Date_Off__c = System.today().addDays(10);
        contactAnnouncement.Date_On__c = System.today().addDays(-20);
        contactAnnouncement.Dismissed__c = false;
        insert contactAnnouncement;
    }

    static testMethod void unitTestPositiveCases(){
        User portalUser = [SELECT Id FROM User WHERE Username = 'portalUser@gmail.com'];
        Contact_Announcement__c contactAnnouncement = [SELECT Id,Name FROM Contact_Announcement__c Limit 1];
        System.runAs(portalUser) {
            Test.startTest();
            Peak_Response getAnnouncementsResponse = NES_AnnouncementsController.retrieveAnnouncements();
            Peak_Response dismissAnnouncementResponse = NES_AnnouncementsController.dismissAnnouncement(contactAnnouncement.Id);
            System.assertNotEquals(getAnnouncementsResponse,Null);
            System.assert(dismissAnnouncementResponse.success);
            Test.stopTest();
        }
    }
    static testMethod void unitNegativeCases(){
        User stdUser = [SELECT Id FROM User WHERE Id=:userInfo.getUserId()];
        Contact_Announcement__c contactAnnouncement = [SELECT Id,Name FROM Contact_Announcement__c Limit 1];
        System.runAs(stdUser) {
            Test.startTest();
            Peak_Response getAnnouncementsResponse = NES_AnnouncementsController.retrieveAnnouncements();
            //Peak_Response dismissAnnouncementResponse = NES_AnnouncementsController.dismissAnnouncement(contactAnnouncement.Id);
            System.assert(!getAnnouncementsResponse.success);
          //  System.assert(dismissAnnouncementResponse.success);
            Test.stopTest();
        }
    }
}