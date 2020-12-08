/**
 * Created by Ashish Sharma on 12/04/18
 * Class Name: NES_Batch_SecondSemesterTest
 * Purpose : Test class for NES_Batch_SecondSemester
*/
@isTest
public class NES_Batch_SecondSemesterTest {
    //Constants
    static final String ACCOUNT_OBJECT = 'Account';
    static final String PROGRAM_GRADE_LEVEL_OBJECT = 'Program_Grade_Level__c';
    static final String FIRST_SEMESTER_INDICATOR = 'First';
    static final String SECOND_SEMESTER_INDICATOR = 'Second';
    static final String SCHEDULER_NAME = 'NES_Batch_SecondSemester';
    static final String HOURLY_SCHEDULE_CRON = '0 00 00 * * ?';

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Method to setup the test data
    */
    @TestSetup
    static void setup() {
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));
        Contact contact = Peak_TestUtils.createTestContact('Caretaker', account.Id);
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        academicProgram.PushToSecondSemester__c = Datetime.now().addDays(-5);
        update academicProgram;

        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, contact.Id, currentSchoolYear.Id, true);

        Opportunity opportunity = Peak_TestUtils.createOpportunity(UserInfo.getUserId(), null);
        opportunity.Program_Enrollment__c = progEnrollment.Id;
        opportunity.Semester_Indicator__c = FIRST_SEMESTER_INDICATOR;
        opportunity.Caretaker_Id__c = contact.Id;
        opportunity.StageName = 'Open';
        insert opportunity;

        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('Test Grade Level', true);
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('Test Program Grade Level', academicProgram.Id,
                                                                                          gradeLevel.Id, Datetime.now().addDays(-5), true);
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if batch is running for Account object
    */
    static testMethod void testAccountRelatedOpportunities() {
        //execute the NES_Batch_SecondSemester batch for Account object
        Test.startTest();
        Database.executeBatch(new NES_Batch_SecondSemester(ACCOUNT_OBJECT, Datetime.now()));
        Test.stopTest();

        //Assert test if Final_Semester_Indicator__c for related opportunity is set to Second Semester or not
        System.assertNotEquals(FIRST_SEMESTER_INDICATOR, [SELECT Final_Semester_Indicator__c FROM Opportunity][0].Final_Semester_Indicator__c);
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if batch is running for Program_Grade_Level__c object
    */
    static testMethod void testPGLRelatedOpportunities() {
        //execute the NES_Batch_SecondSemester batch for Program Grade Level object
        Test.startTest();
        Database.executeBatch(new NES_Batch_SecondSemester(PROGRAM_GRADE_LEVEL_OBJECT, Datetime.now()));
        Test.stopTest();

        //Assert test if Final_Semester_Indicator__c for related opportunity is set to Second Semester or not
        System.assertNotEquals(FIRST_SEMESTER_INDICATOR, [SELECT Final_Semester_Indicator__c FROM Opportunity][0].Final_Semester_Indicator__c);
    }

    /**
     * Created by Ashish Sharma on 12/03/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test scheduler for NES_Batch_SecondSemester
    */
    static testMethod void testSchedule() {
        //Assert test if scheduler is scheduled or not
        System.assertNotEquals(null, System.schedule(SCHEDULER_NAME, HOURLY_SCHEDULE_CRON, new NES_Batch_SecondSemester()));
    }
}