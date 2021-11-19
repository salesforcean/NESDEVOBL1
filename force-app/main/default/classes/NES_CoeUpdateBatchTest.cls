@isTest
public class NES_CoeUpdateBatchTest {
    
    static testMethod void testmethod1() {
        // Create School Year
        School_Year__c schoolYear = new School_Year__c(Name = '2021-2022', 
                                                       End_Date__c = System.today()+20, 
                                                       Current_Year__c = true,
                                                       Start_Date__c = System.today());
        insert schoolYear;
        
        // Insert Caretaker Account and Contact
        Account account = Peak_TestUtils.createTestAccount();
        
        Contact TestContact = Peak_TestUtils.createTestContact('Students', account.Id);

        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,schoolYear.Id);
        system.debug('1 ' + academicProgramAccount);
        academicProgramAccount.Registration_Start_Date__c = Date.today().addMonths(-2);
        update academicProgramAccount;
        
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, TestContact.Id, schoolYear.Id, false);
        ProgramEnrollmentTest.Final_Grade_Level__c = '1';  
        Insert ProgramEnrollmentTest;
        
        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Op', ProgramEnrollmentTest.hed__Account__c, System.today().addDays(32), 'Closed Won', false);
        opportunity.Program_Enrollment__c = ProgramEnrollmentTest.Id;
        insert opportunity;
        
        hed__Program_Enrollment__c ProgramEnrollmentTest1 = new hed__Program_Enrollment__c (Id = ProgramEnrollmentTest.Id, Status__c = 'Complete');
        update ProgramEnrollmentTest1;
        
        //Enrollment__c enr = [Select Id from Enrollment__c where Program_Enrollment__c =: ProgramEnrollmentTest.Id];
        test.startTest();
        Id batchJobId = Database.executeBatch(new NES_CoeUpdateBatch(), 200);
        
        test.stopTest();
            
        
        
        
        
        
    } 

}