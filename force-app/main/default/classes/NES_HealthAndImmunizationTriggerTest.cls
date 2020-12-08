/**
 * Created by Anushka Bansal on 12-12-2018.
 */

 @istest
 public class NES_HealthAndImmunizationTriggerTest {

     @TestSetup
     static void setup(){

         Peak_TestUtils.createNESBusinessLogicSwitch('Immunization Status Current', true);
         Account account = Peak_TestUtils.createTestAccount();
         School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));
         School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
         Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
         Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
         hed__Program_Enrollment__c programEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id, currentSchoolYear.Id, true);
         Health_and_Immunization__c hni = new Health_and_Immunization__c(Program_Enrollment__c = programEnrollment.Id, Immunization_Status_FollowUp__c = 'Verified', Immunization_Status__c = 'Verified');
         insert hni;
     }


     static testMethod void afterInsertTest() {

         hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
         Health_and_Immunization__c hni = new Health_and_Immunization__c(Program_Enrollment__c = programEnrollment.Id, Immunization_Status_FollowUp__c = 'Verified', Immunization_Status__c = 'Verified');
         insert hni;
     }

     static testMethod void afterUpdateTest() {

         hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
         Health_and_Immunization__c hni = new Health_and_Immunization__c(Program_Enrollment__c = programEnrollment.Id, Immunization_Status_FollowUp__c = 'Verified', Immunization_Status__c = 'Verified');
         insert hni;
         Health_and_Immunization__c hni2 = [SELECT Id FROM Health_and_Immunization__c LIMIT 1];
         List<Health_and_Immunization__c> listOfHealthAndImmunizations = new List<Health_and_Immunization__c>();
         listOfHealthAndImmunizations.add(hni);
         listOfHealthAndImmunizations.add(hni2);

         listOfHealthAndImmunizations[0].Immunization_Status__c = 'Missing';
         listOfHealthAndImmunizations[0].Immunization_Status_FollowUp__c = 'Verified';
         listOfHealthAndImmunizations[1].Immunization_Status__c = 'Verified';
         listOfHealthAndImmunizations[1].Immunization_Status_FollowUp__c = 'Missing';
         update hni;
     }
 }