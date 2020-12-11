@istest
private class NES_BusinessLogicUtilswhyflagTest
{
    @TestSetup
    static void setup() {
        // generate test-data
        
        Id Academic = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        School_Year__c previousSchoolYears = Peak_TestUtils.createSchoolYears('2018-2019',System.today());
        Account objacc = Peak_TestUtils.createEducationalInstitutionAccount();
        
        objacc.recordtypeid=Academic;
        Objacc.Alternative_Address_Request__c='Yes';
        Objacc.School_Year__c=previousSchoolYears.id;
        update Objacc;
        Contact contact = Peak_TestUtils.createTestContact('Students', Objacc.Id);
        hed__Program_Enrollment__c HousePE= Peak_TestUtils.createProgramEnrollment(objacc.id,contact.id,previousSchoolYears.id,true);
        hed__Program_Enrollment__c Hpe= Peak_TestUtils.createProgramEnrollment(objacc.id,contact.id,previousSchoolYears.id,true);
        Hpe.Household_Program_Enrollment__c=HousePE.id;
        update Hpe;
    }
    
    static testMethod void calculateWhyFlaggedtest (){
        
        date mydate = date.parse('04/12/2020');
        School_Year__c previousSchoolYears=new School_Year__c();
        previousSchoolYears.Name='testing';
        previousSchoolYears.Start_Date__c=mydate;
        previousSchoolYears.End_Date__c=mydate;
        insert previousSchoolYears;
        System.debug('syear:'+previousSchoolYears);
        
        Grade_Level__c glsRecords=new Grade_Level__c();
        glsRecords.Name='testing';
        insert glsRecords;
        
       	Account objacc = Peak_TestUtils.createEducationalInstitutionAccount(); 
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(objacc.Id, previousSchoolYears.Id);
        Program_Grade_Level__c pglRecords=new Program_Grade_Level__c();
        pglRecords.Academic_Program__c=academicProgram.Id;
        pglRecords.Grade_Level__c=glsRecords.Id;
        pglRecords.AutoPlacement_Special_EdExclude__c=FALSE;
        insert pglRecords;
        
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c=previousSchoolYears.Id;
        progEnrollment1.Program_Grade_Level__c=pglRecords.Id;
        progEnrollment1.PlacementFlag__c='Principal Review';
        progEnrollment1.CounselingFlag__c='Stop';
        progEnrollment1.EligibilityFlag__c='Pending';
        progEnrollment1.PriorWithdrawalFlag__c='Hold';
        progEnrollment1.WaitlistFlag__c='Active';
        //progEnrollment1.UserTechnologyFlag__c='Technology Flag';
        progEnrollment1.DisciplinaryFlagOverride__c='Withdraw';
        progEnrollment1.HomelessRiskFlag__c='Potential Homeless';
        progEnrollment1.PrincipalGeneralFlag__c='Released';
        progEnrollment1.GradeLevelEligibility__c='Need additional information';
        progEnrollment1.EntranceAgeEligibility__c='Too old';
        insert progEnrollment1;
        
        Enrollment_Document__c eds=new Enrollment_Document__c();
        eds.Program_Enrollment__c=progEnrollment1.Id;
        eds.Type__c='IEP Exit Documentation';
        eds.Status_Reason__c='Awaiting IEP';
        insert eds;
       
        
        Special_Education__c speciEds=new Special_Education__c();
        speciEds.Program_Enrollment__c=progEnrollment1.Id;
        speciEds.IEP__c='Documenting';
        speciEds.Plan504__c='504 Missing';
       	speciEds.FormallyExitedIEP__c='Yes';
        
        insert speciEds;
        Annual_Student_Information__c asRecords = new Annual_Student_Information__c();
        asRecords.Program_Enrollment__c = progEnrollment1.id;
        asRecords.School_Year__c=previousSchoolYears.Id;
        insert asRecords;
    }
}