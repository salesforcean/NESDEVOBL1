/**
 * Created by Anushka Bansal on 19-12-2018.
 */

@IsTest
public with sharing class NES_LTSUtilityTest {

    @TestSetup static void setup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account account = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018')); 

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
        hed__Program_Enrollment__c progEnrollmentHH = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true); 

        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollment.Stress_Factors__c = 'Yes';
        progEnrollment.DisciplinaryPastActions__c = 'Yes, expelled';
        progEnrollment.LastSchoolType__c = 'Private/Parochial School';
        insert progEnrollment;
        
        Enrollment_Component__c formComponent = Peak_TestUtils.createEnrollmentComponent(academicProgramAccount.Id, 'Form', false);
        formComponent.Household_Enrollment_Information__c = True;
        formComponent.Student_Enrollment_Information__c = True;
        insert formComponent;
        Enrollment_Component_Affiliation__c affiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollment.Id, formComponent.Id);
        affiliation.Status__c = 'In Progress';
        update affiliation;
        Annual_Household_Information__c ahi = Peak_TestUtils.createAnnualHouseholdInformation( progEnrollment.Id, currentSchoolYear.Id, false);
        ahi.Income_Opt_Out_Options__c ='Yes';
        ahi.Total_Gross_HH_Income__c=1;
        ahi.Number_HH_Children__c=10;
        ahi.Number_HH_Adults__c=10;
        insert ahi;

        Opportunity opp = Peak_TestUtils.createOpportunity('oldOpty',account.Id,System.Today(),'closed won',False);
        opp.Program_Enrollment__c = progEnrollment.Id;
        opp.SFDC_Informed__c = 'Uninformed';
        opp.SFDC_Engaged_Grassroots_User__c = 'True';
        Insert  opp;
       // Opportunity opportunity = Peak_TestUtils.createOpportunity(progEnrollment.Id);



    }
    /**
     * Created By Anushka 19/12/2018
     * Purpose : To test CalculateLTS method on Insert and update of Placement And Elective record
     */
    static testMethod void testCalculateLTSPlacementAndElective(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
        system.debug('pro test' + progEnrollment);

       // Enrollment_Component_Affiliation__c aff = [Select id,Program_Enrollment__c, Status__c, Enrollment_Component__c, Enrollment_Component__r.Student_Enrollment_Information__c, Enrollment_Component__r.RecordType.DeveloperNamefrom Enrollment_Component_Affiliation__c limit 1];
        Test.startTest();
        Placement_and_Elective__c pne = Peak_TestUtils.createPlacementAndElective(progEnrollment.Id,false);
        pne.Course_Requested__c = 'World History';
        pne.Level_Requested__c = 'Honors';
        
        insert pne;
        Contact con = [Select id, Why_Is_Your_Child_Attending_CA__c from Contact limit 1];
        con.Why_Is_Your_Child_Attending_CA__c = 'Student was struggling academically';
        update con;
        Test.stopTest();
    }

    /**
     * Created By Anushka 19/12/2018
     * Purpose : To test CalculateLTS method on Insert and update of Special Education record
     */
    static testMethod void testCalculateLTSSpecialEductaion(){
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
        Test.startTest();
        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(progEnrollment.Id, false);
        specialEducation.Gifted__c = 'Gifted IEP';
        insert specialEducation;
        specialEducation.Gifted__c = 'Gifted Allow';
        update  specialEducation;
        Test.stopTest();
    }
    
      /**
     * Created By Anushka 19/12/2018
     * Purpose : To test CalculateLTS method on Insert and update of Contact record
     */
    static testMethod void testCalculateLTSContact(){
        Account  account = [Select id from Account limit 1];
        hed__Program_Enrollment__c progEnrollment = [select Id from hed__Program_Enrollment__c limit 1];
        Test.startTest();
        Contact con = Peak_TestUtils.createContact('Test', account.Id,'Students',false);
        con.Why_Is_Your_Child_Attending_CA__c = 'Student has or had mental health concerns';
        insert con;

        account.LC_HighestLevelofEducation__c = 'College graduate (Bachelor\'s degree)';
        update account;
        
        con.Why_Is_Your_Child_Attending_CA__c = 'Student was struggling academically';
        update con;

        account.LC_HighestLevelofEducation__c = 'Not a high school graduate';
        account.Internet_Connection_Type__c = 'None';
        update account;

        con.Why_Is_Your_Child_Attending_CA__c = 'Student was ahead academically';
        update con;

        progEnrollment.LastSchoolType__c = 'Online (Virtual) Public School';
        update progEnrollment;

        account.LC_HighestLevelofEducation__c = 'High school graduate';
        account.Mktg_Customer_Loyalty__c = 'Customer Loyalty';
        account.Computer_in_Home__c = 'No';
        account.Internet_Connection_Type__c = 'Dial-up';
        update account;

        con.Why_Is_Your_Child_Attending_CA__c = 'Student was ahead academically';
        update con;

        Test.stopTest();
    }

}