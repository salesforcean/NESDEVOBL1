/**
 * Created by Raju on 19-12-2018.
 * Purpose : Test class for AnnualHouseholdInfoBusinessLogic apex class.
 * Added testing logic for new fields and corresponding logic for HHFedPovertyEligibility & HHFARMEligCalculate US117580 (Jagadeesh) on 11/13/2019
 */
@isTest
public class NES_AnnualHouseholdInfoBusinessLogicTest {
    @TestSetup
    static void setup(){

        Peak_TestUtils.createNESBusinessLogicSwitch('Federal Poverty Eligibility', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today()); 
        system.debug('current sy ' + currentSchoolYear.Name);

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        academicProgramAccount.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c = 3000;//added by jagadeesh - user story : 117580 
        academicProgramAccount.Fed_Poverty_Elig_Inc_Addl_Per_Person__c = 3000;//added by jagadeesh - user story : 117580 
        academicProgramAccount.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c = 1000;//added by jagadeesh - user story : 117580 
        academicProgramAccount.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c = 2000;//added by jagadeesh - user story : 117580 
        academicProgramAccount.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c = 3000;//added by jagadeesh - user story : 117580 
        academicProgramAccount.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c = 4000;//added by jagadeesh - user story : 117580 
        update academicProgramAccount;//added by jagadeesh - user story : 117580 
        
        system.debug('1 ' + academicProgramAccount);

        hed__Program_Enrollment__c progEnrollmentWithoutStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
       // progEnrollmentWithoutStatus.Status__c = 'Time Expired';
         progEnrollmentWithoutStatus.Status__c = 'In Progress';//added by anitha
        insert progEnrollmentWithoutStatus;
        system.debug('1 ' + progEnrollmentWithoutStatus);

        hed__Program_Enrollment__c progEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentTest.ELLFlag__c='Potential';
        Insert progEnrollmentTest;
       
        hed__Program_Enrollment__c programEnrollmentTest1 = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];//added by anitha
        School_Year__c currentSchoolYear1 = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
        Annual_Household_Information__c currentAHI11 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollmentTest1.Id, currentSchoolYear1.Id, false);
        
               
        hed__Program_Enrollment__c progEnrollmentTest2 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentTest2.Household_Program_Enrollment__c= programEnrollmentTest1.Id;
        progEnrollmentTest2.Status__c = 'In Progress';
        Insert progEnrollmentTest2;


    }//Added by Raju
    static testMethod void AfterInsertTestScenario1(){
        


        hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];//added by anitha
        School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
        Annual_Household_Information__c currentAHI = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI.Income_Opt_Out_Options__c ='Yes';
        
        Annual_Household_Information__c currentAHI1 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI1.Income_Opt_Out_Options__c ='Yes';
        currentAHI1.Total_Gross_HH_Income__c=1;
        currentAHI1.Number_HH_Children__c=10;
        currentAHI1.Number_HH_Adults__c=10;
       
        Annual_Household_Information__c currentAHI2 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI2.Income_Opt_Out_Options__c ='Yes';
        currentAHI2.Total_Gross_HH_Income__c=122500;
        currentAHI2.Number_HH_Children__c=10;
        currentAHI2.Number_HH_Adults__c=10;
        
        Annual_Household_Information__c currentAHI3 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI3.Income_Opt_Out_Options__c ='Yes';
        currentAHI3.Total_Gross_HH_Income__c=174310;
        currentAHI3.Number_HH_Children__c=10;
        currentAHI3.Number_HH_Adults__c=10;
        
        Annual_Household_Information__c currentAHI4 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI4.Income_Opt_Out_Options__c ='I certify that our household does not qualify';
        
        Annual_Household_Information__c currentAHI5 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI5.Income_Opt_Out_Options__c = system.label.NES_AHI_IncomeOptOut_Value; 
        
        Annual_Household_Information__c currentAHI6 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI6.Income_Opt_Out_Options__c = null;
        
        Annual_Household_Information__c currentAHI7 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI7.HH_Has_Food_Stamp_Recipient__c ='Yes';
       
        Household_Income__c currentHI = Peak_TestUtils.createHouseholdIncome(programEnrollment.Id, currentSchoolYear.Id, false);
        currentHI.HHFosterChild__c = 'Yes';
        
        List<Annual_Household_Information__c> ahiList = new List<Annual_Household_Information__c>();
        ahiList.add(currentAHI);
        ahiList.add(currentAHI1);
        ahiList.add(currentAHI2);
        ahiList.add(currentAHI3);
		ahiList.add(currentAHI4); 
        ahiList.add(currentAHI5); 
        ahiList.add(currentAHI6);
        ahiList.add(currentAHI7);
        
        Test.startTest();
        insert ahiList;
        insert currentHI;
        currentAHI.Total_Gross_HH_Income__c =10;
        NES_ECACompletion.shouldRunCompletion = true; 
        NES_Constants.runAssignment = true;
		update currentAHI;
        currentAHI.Income_Opt_Out_Options__c = system.label.NES_AHI_Income_Opt;//added by jagadeesh - user story : 117580 
        update currentAHI;//added by jagadeesh - user story : 117580 
        
        for(Annual_Household_Information__c ahi : [SELECT Federal_Poverty_Eligibility__c FROM Annual_Household_Information__c]){
            System.assertNotEquals(null, ahi.Federal_Poverty_Eligibility__c);
        }

        Test.stopTest();
    }

}