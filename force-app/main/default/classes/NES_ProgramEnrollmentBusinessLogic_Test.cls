/**
 * Created updateASIForCompletedPEsTest Method by Maddileti Boya for #194222 User Story on 2020-06-15 

 * Revision :
 * 09-04-2020 Added updateASIForCompletedPEsNegativeTest to cover negative scenarios(Jagadish Babu)
 */
@istest
Private class NES_ProgramEnrollmentBusinessLogic_Test
{
    @TestSetup
    static void setup() {
        // generate test-data
        Id Academic = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today());
        Account Objacc = Peak_TestUtils.createTestAccount();
        objacc.recordtypeid=Academic;
        Objacc.Alternative_Address_Request__c='Yes';
        Objacc.School_Year__c=currentSchoolYear.id;
        update Objacc;
        
        Contact contact = Peak_TestUtils.createTestContact('Students', Objacc.Id);
        hed__Program_Enrollment__c HousePE= Peak_TestUtils.createProgramEnrollment(objacc.id,contact.id,currentSchoolYear.id,true);
        hed__Program_Enrollment__c Hpe= Peak_TestUtils.createProgramEnrollment(objacc.id,contact.id,currentSchoolYear.id,true);
        Hpe.Household_Program_Enrollment__c=HousePE.id;
        update Hpe;
        Account account = Peak_TestUtils.createTestAccount();
        
        School_Year__c currentSchoolYear2 = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
        
        School_Year__c currentSchoolYearTest = Peak_TestUtils.createSchoolYears('2019-2020',date.parse('11/17/2020'));
        School_Year__c currentSchoolYear2020 = Peak_TestUtils.createSchoolYears('2021-2022',date.parse('11/17/2018'));
        
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));
        
        Contact contact2 = Peak_TestUtils.createTestContact('Students', account.Id);
        
        Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear2.Id);
        academicProgramAccount.AutomatedPlacementMaxCutoff__c = 90;
        update academicProgramAccount;
        hed__Program_Enrollment__c progEnrollment5 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact2.Id,currentSchoolYear2020.Id, false);
        insert progEnrollment5;
        Annual_Student_Information__c prevASI1 = Peak_TestUtils.createAnnualStudentInformation('Previous ASI1', progEnrollment5.Id, currentSchoolYear2020.Id, false);
        insert prevASI1;
        System.debug('the asi school year:'+prevASI1.School_Year__c);
        Special_Education__c specialEducations = Peak_TestUtils.createSpecialEducation(progEnrollment5.Id,false);
        specialEducations.IEPHistory__c ='Decline to Disclose';
        insert specialEducations;
        //
        
    }
    
    static testMethod void ProgramEnrollmentBusinessLogictest() 
    {
        Test.startTest();
        hed__Program_Enrollment__c Hpe= [ SELECT id,Status__c,Household_Program_Enrollment__c,OrderingHoldFlag__c,OrderingHoldDate__c,hed__Contact__c FROM hed__Program_Enrollment__c  where Household_Program_Enrollment__c != null limit 1 ];        
        HPe.Status__c = 'Complete';
        update Hpe;
        
        NES_ProgramEnrollmentBusinessLogic.updateHHPEOrderHold(new set<id>{Hpe.id});
        hed__Program_Enrollment__c Hpe1= [ SELECT id,Status__c,OrderingHoldFlag__c,OrderingHoldDate__c FROM hed__Program_Enrollment__c  where id =:Hpe.Household_Program_Enrollment__c limit 1 ];        
        List<case> objcase = new List<case>();
        objCase = [SELECT Id FROM Case WHERE Type='Fulfillment' AND Ticket_Sub_Type__c='Alternate Shipping' AND ContactId = :Hpe.hed__Contact__c AND Contact.account.Alternative_Address_Request__c = 'Yes'];
        
        test.stopTest();
        
        System.assertEquals('Alternate Shipping', Hpe1.OrderingHoldFlag__c);
        System.assertEquals(System.now().date(), Hpe1.OrderingHoldDate__c);
        System.assertNotEquals(objCase,null);
        
    } 
    static testMethod void updateASIForCompletedPEsTest() {
        
        Test.startTest();
        Set<Id> peIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2021-2022' LIMIT 1];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,Status__c,Start_Year__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        currentProgramEnrollment.Status__c='Complete';
        update currentProgramEnrollment;
        hed__Program_Enrollment__c currentProgramEnrollment1 = [SELECT Id,EntranceAgeEligibilityFinal__c,CohortEligibility__c FROM hed__Program_Enrollment__c WHERE Id=: currentProgramEnrollment.Id];
        Special_Education__c speid =[SELECT Id, Program_Enrollment__c FROM Special_Education__c WHERE Program_Enrollment__c = :currentProgramEnrollment1.Id];
        peIdList.add(currentProgramEnrollment.Id);
        NES_ProgramEnrollmentBusinessLogic.updateASIForCompletedPEs(peIdList);
        Annual_Student_Information__c Asi = [SELECT Id,Potential_Child_Find__c,Potential_Child_Find_Detailed_Log__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment1.Id];
        test.stopTest(); 
        System.assertEquals('Yes', Asi.Potential_Child_Find__c);
        System.assertEquals('Caretaker reports student has been evaluated in the last year, but did not indicate that the student has an IEP or Section 504 Plan or the caretaker declined to disclose.', Asi.Potential_Child_Find_Detailed_Log__c);
        
    } 
    

    //Created for US228767 (Jagadish Babu) to make sure to work if the special education and asi records are not exist
    static testMethod void updateASIForCompletedPEsNegativeTest() {        
        Test.startTest();
        Set<Id> peIdList = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = '2021-2022' LIMIT 1];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,Status__c,Start_Year__c FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        Annual_Student_Information__c Asi = [SELECT Id,Potential_Child_Find__c,Potential_Child_Find_Detailed_Log__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment.Id];
        Special_Education__c speid =[SELECT Id, Program_Enrollment__c FROM Special_Education__c WHERE Program_Enrollment__c = :currentProgramEnrollment.Id];
        delete Asi;
        delete speId;        
        hed__Program_Enrollment__c currentProgramEnrollment1 = [SELECT Id,EntranceAgeEligibilityFinal__c,CohortEligibility__c FROM hed__Program_Enrollment__c WHERE Id=: currentProgramEnrollment.Id];
        currentProgramEnrollment1.Status__c='Complete';
        System.assertEquals(0, [SELECT Id,Potential_Child_Find__c,Potential_Child_Find_Detailed_Log__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c = :currentProgramEnrollment1.Id].size());
        System.assertEquals(0, [SELECT Id, Program_Enrollment__c FROM Special_Education__c WHERE Program_Enrollment__c = :currentProgramEnrollment1.Id].size());
        update currentProgramEnrollment1;
        peIdList.add(currentProgramEnrollment1.Id);
        NES_ProgramEnrollmentBusinessLogic.updateASIForCompletedPEs(peIdList);        
        test.stopTest();               
    } 
    
}