/**
 * Created by Ritvik on 16-12-2018.
 */

@IsTest
private class NES_HomeLanguageSurveyTriggerTest {
    @TestSetup
    static void testSetup() {
        Peak_TestUtils.createNESBusinessLogicSwitch('HLS Language Spoken By Adults', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('HomeLanguageSurveyTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('HLS Student Flag', true);

        Account account = Peak_TestUtils.createTestAccount();

        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('SchoolTest',System.today());

        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);

        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);

        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, true);

        hed__Program_Enrollment__c progEnrollment1 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollment1.ELLFlag__c ='Potential EL';
        Insert progEnrollment1;

        Opportunity opportunity = Peak_TestUtils.createOpportunity('Test Opp',academicProgramAccount.Id,System.today().addDays(20),'Proposal',false);
        //Commented by Ritvik on 01/16/2019 as Reactivation_Date__c is removed from org.
        opportunity.Reactivation__c = false;
        opportunity.Program_Enrollment__c = progEnrollment1.Id;
        insert opportunity;

    }

    static testMethod void test_calculateHLSLanguageSpokenByAdults_afterInsert(){
          //School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
          hed__Program_Enrollment__c programEnrollment = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential EL'];
          Home_Language_Survey__c homeLanguageSurvey = Peak_TestUtils.createHomeLanguageSurveyRecord('Test HLS',programEnrollment.Id,false);
          homeLanguageSurvey.HLS2_Spoken_To_Child__c = 'Arabic';
            homeLanguageSurvey.Language_spoken__c = 'Chinese';
            homeLanguageSurvey.HLS2_Home_Language__c = 'French';
            homeLanguageSurvey.HLS_Student_At_Home__c = 'Hindi';
            homeLanguageSurvey.HLS_Home_Often_Spoken__c = 'Arabic';
            homeLanguageSurvey.HLS2_Home_Language_Many__c = 'Albanian';
            homeLanguageSurvey.HLS2_Home_Language_NE__c = 'Bengali';
            homeLanguageSurvey.HLS_Speak_Understand_NE_YN__c = false;
          Test.startTest();
          insert homeLanguageSurvey;
          Home_Language_Survey__c hlsRecord = [SELECT HLS_Language_Spoken_By_Adults__c FROM Home_Language_Survey__c WHERE Name ='Test HLS'];
          System.assertEquals('Arabic',hlsRecord.HLS_Language_Spoken_By_Adults__c);
          Test.stopTest();
      }

      static testMethod void test_calculateHLSLanguageSpokenByAdults_afterUpdate(){
          //School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
          hed__Program_Enrollment__c programEnrollment = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential EL'];
          Home_Language_Survey__c homeLanguageSurvey = Peak_TestUtils.createHomeLanguageSurveyRecord('Test HLS',programEnrollment.Id,true);
          homeLanguageSurvey.Language_spoken__c = 'Chinese';
          homeLanguageSurvey.HLS2_Home_Language__c = 'French';
          homeLanguageSurvey.HLS_Student_At_Home__c = 'Hindi';
          homeLanguageSurvey.HLS_Home_Often_Spoken__c = 'Arabic';
          homeLanguageSurvey.HLS2_Home_Language_Many__c = 'Albanian';
          homeLanguageSurvey.HLS2_Home_Language_NE__c = 'Bengali';
          homeLanguageSurvey.HLS_Speak_Understand_NE_YN__c = false;
          Test.startTest();
          update homeLanguageSurvey;
          Home_Language_Survey__c hlsRecord = [SELECT HLS_Language_Spoken_By_Adults__c FROM Home_Language_Survey__c WHERE Name ='Test HLS'];
          System.assertEquals('Chinese,French,Hindi,Arabic,Albanian,Bengali,English',hlsRecord.HLS_Language_Spoken_By_Adults__c);
          Test.stopTest();
      }

    // Created by Anand
    Static testMethod void CalculateELLFlagTest(){
        hed__Program_Enrollment__c progEnrollment1 = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential EL'];
        Home_Language_Survey__c   homeLangSurveyTest=Peak_TestUtils.createHomeLanguageSurveyRecord('Test1',progEnrollment1.Id,False);
        homeLangSurveyTest.HLS_Date_Completed__c = NULL;
        Insert homeLangSurveyTest;
        Home_Language_Survey__c hmeLangSurvey=[Select Id,HLS_Date_Completed__c,Program_Enrollment__r.ELLFlag__c FROM Home_Language_Survey__c WHERE Name='Test1' ];
        System.assertEquals(hmeLangSurvey.Program_Enrollment__r.ELLFlag__c,NUll);
        hmeLangSurvey.HLS_Date_Completed__c =System.Today();
        Update hmeLangSurvey;
        Home_Language_Survey__c hmeLangSurvey1=[Select Id,HLS_Date_Completed__c,Program_Enrollment__r.ELLFlag__c FROM Home_Language_Survey__c WHERE Id=:hmeLangSurvey.Id];
        System.assertEquals(hmeLangSurvey1.Program_Enrollment__r.ELLFlag__c,NUll);
    }

    /**
     * Created by: Anushka
     * Purpose : To test the calculateHLSStudentFlag method on Update
     */
    Static testMethod void testUpdatecalculateHLSStudentFlag(){
        hed__Program_Enrollment__c programEnrollment = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential EL'];
        Home_Language_Survey__c homeLanguageSurvey = Peak_TestUtils.createHomeLanguageSurveyRecord('Test HLS',programEnrollment.Id,false);
        homeLanguageSurvey.HLS2_FirstLanguage__c  = 'Hindi';
        insert homeLanguageSurvey;
        Test.startTest();
        homeLanguageSurvey.HLS2_FirstLanguage__c = 'English';
        update homeLanguageSurvey;
        System.assertEquals(false, [SELECT HLSStudentFlag__c FROM hed__Program_Enrollment__c WHERE id =: programEnrollment .Id][0].HLSStudentFlag__c );
        Test.stopTest();
    }

    /**
     * Created by: Anushka
     * Purpose : To test the calculateHLSStudentFlag method on Insert
     */
    Static testMethod void testInsertcalculateHLSStudentFlag(){
        hed__Program_Enrollment__c programEnrollment = [SELECT ID FROM hed__Program_Enrollment__c WHERE ELLFLAG__c='Potential EL'];
        Home_Language_Survey__c homeLanguageSurvey = Peak_TestUtils.createHomeLanguageSurveyRecord('Test HLS',programEnrollment.Id,false);
        homeLanguageSurvey.HLS2_FirstLanguage__c  = 'Hindi';

        Test.startTest();
        insert homeLanguageSurvey;
        System.assertEquals(True, [SELECT HLSStudentFlag__c FROM hed__Program_Enrollment__c WHERE id =: programEnrollment .Id][0].HLSStudentFlag__c );
        Test.stopTest();
    }
}