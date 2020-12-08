/**
* Created by Anand on 12/9/2018.
* Change Log: Added code by Anitha P for #107180 User Story (Task 108661) on 2019-09-06
* Added logic for Waitlist for the bug 119931 (Anitha P) on 12/09/19
*/
@IsTest
private class  NES_EnrollmentCompAffiliationTriggerTest {
    
    @TestSetup
    static void setup() {
        NES_ECUtilities.mock = new Peak_MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, new Peak_MockHttpResponseGenerator());
        HttpResponse response = NES_ECUtilities.createHttpRequestForPhoneData('POST', 'https://api.experianmarketingservices.com/sync/queryresult/PhoneValidate/1.0/','0fef8f0d-e5d7-4f6b-a74c-8c9ad6516750', '{"Number": 56988,  "DefaultCountryCode": "+1"}');
        Peak_TestUtils.createNESBusinessLogicSwitch('Automated Placement Process', true);
        
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        parentAccount.Phone = '9345678120';
        update parentAccount;
        
        Contact TestContact = Peak_TestUtils.createTestContact();
        TestContact.LastName='TestCon';
        TestContact.Phone='8143098909';
        TestContact.Birthdate__c=Date.newInstance(2000, 2, 17);
        TestContact.AccountId=parentAccount.Id;        
        update TestContact;
        
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        School_Year__c schlYearTest1 = Peak_TestUtils.createSchoolYears('SchoolTest1', System.today());
        
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        academicAccount.Confirmation_End_Date__c=Datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.Second_Semester_Confirmation_Date__c=Datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.AutomatedPlacementMaxCutoff__c = 90;
        update academicAccount;
        
        Account parentAcc = Peak_TestUtils.createAccount('TestAcc',True);
        Account programAccount = Peak_TestUtils.createAccountForNewStudentData(parentAcc.Id, schlYear.Id);
        programAccount.Confirmation_End_Date__c = System.Now().AddYears(2);
        programAccount.Confirmation_Start_Date__c = System.Now().AddYears(-2);
        update programAccount;
        
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, false);
        ProgramEnrollmentTest.Final_Grade_Level__c = '1';
        ProgramEnrollmentTest.SIF_SummerSchoolCourses__c='Yes';
        ProgramEnrollmentTest.SIFStudentRetained__c='yes';
        ProgramEnrollmentTest.Stress_Factors__c = 'No';
        List<String> strList=new List<String>{'Math','Science','Social Studies'};
            String opt=String.join(strList, ';');
        ProgramEnrollmentTest .SIF_AcademicSupportNeeds__c = opt;
        insert ProgramEnrollmentTest;
        List<Enrollment_Component__c> enCompList = new  List<Enrollment_Component__c>();
        Enrollment_Component__c enComp1=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Form',false);
        enComp1.Name='enComp1';
        enComp1.Status__c='Complete';
        enComp1.Student_Enrollment_Information__c = true;
        //insert enComp1;
        enCompList.add(enComp1);
        
        Enrollment_Component__c enComp2=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Form',false);
        enComp2.Name='enComp2';
        enComp2.Status__c='Not Complete';
        enComp2.Household_Enrollment_Information__c = true;
       // insert enComp2;
        enCompList.add(enComp2);
        
        Prior_School__c schl=Peak_TestUtils.createPriorSchool(ProgramEnrollmentTest.Id,schlYear.Id,false);
        schl.SchoolType__c='HomeSchool';
        insert schl;
        
        Enrollment_Component__c enComp3=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Stage',false);
        enComp3.Name='enComp3';
        enComp3.Required_to_Complete_for_Auto_Placement__c=true;
        enComp3.Waitlist__c = true;
        enComp3.Component_Message__c='TestMessage';
        //insert enComp3;
        enCompList.add(enComp3);
        
        Enrollment_Component__c enComp4=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Document',false);
        enComp4.Name='enComp4Doc';
        //insert enComp4;
        enCompList.add(enComp4);
        
        Enrollment_Component__c enComp5=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Question',false);
        enComp5.Name='enComp5Que';
        enComp5.Answer_Target__c='Account.Phone';
        //insert enComp5;
        enCompList.add(enComp5);
        
        Enrollment_Component__c enComp6=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Question',false);
        enComp6.Name='enComp5Question';
        enComp6.Answer_Target__c='Account.Phone';
        //insert enComp6;
        enCompList.add(enComp6);
        
        Enrollment_Component__c enComp7=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Question',false);
        enComp7.Name='enComp5Question';
        enComp7.Answer_Target__c='Contact.Phone';
        //insert enComp7;
        enCompList.add(enComp7);
        insert enCompList;
        
        Enrollment_Component__c validatePhoneEnrollmentComponent = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Question', false);
        validatePhoneEnrollmentComponent.Phone_Number_Validated_Field__c = 'Contact.Phone';
        validatePhoneEnrollmentComponent.Phone_Type_Field__c = 'Contact.Authorized_Contact__c';
        validatePhoneEnrollmentComponent.Question_Type__c = 'Phone';
        validatePhoneEnrollmentComponent.Answer_Target__c = 'Contact.Phone';
        insert validatePhoneEnrollmentComponent;
        
        Enrollment_Component_Relationship__c enCompRelation1=Peak_TestUtils.createEnrollmentComponentRelationship(enComp2.Id,enComp3.Id);
        Enrollment_Component_Relationship__c enCompRelation2=Peak_TestUtils.createEnrollmentComponentRelationship(enComp1.Id,enComp3.Id);
        Enrollment_Component_Relationship__c enCompRelation3=Peak_TestUtils.createEnrollmentComponentRelationship(enComp4.Id,enComp2.Id);
        
        Annual_Student_Information__c studInfo1=Peak_TestUtils.createAnnualStudentInformation('Test1',ProgramEnrollmentTest.Id,schlYear.Id,False);
        studInfo1.Grade_Level_Requested__c='7';
        insert studInfo1;
        
        Special_Education__c spEducation=Peak_TestUtils.createSpecialEducation(ProgramEnrollmentTest.Id,false);
        spEducation.EvaluatedWithInLastYear__c='yes';
        insert spEducation;
        
        List<Enrollment_Component_Affiliation__c> afflist = new list<Enrollment_Component_Affiliation__c>();
        Enrollment_Component_Affiliation__c ecaAffiliation=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp1.Id,false);
        System.debug('ecaAffiliation' +ecaAffiliation.Id );
        afflist.add(ecaAffiliation);
        Enrollment_Component_Affiliation__c ecaAffiliation1=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp5.Id,false);               
         afflist.add(ecaAffiliation1);
        Enrollment_Component_Affiliation__c affiliation=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp3.Id,false);
         afflist.add(affiliation);
        Enrollment_Component_Affiliation__c affiliation2=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp6.Id,false);
         afflist.add(affiliation2);
        Enrollment_Component_Affiliation__c affiliation3=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp7.Id,false);
         afflist.add(affiliation3);
        Enrollment_Component_Affiliation__c affiliation4 =Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp2.Id,false);
         afflist.add(affiliation4);
        Enrollment_Component_Affiliation__c phoneAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id, validatePhoneEnrollmentComponent.Id ,false);
         afflist.add(phoneAffiliation);
        insert afflist;
        
        
        Opportunity optyRecord=Peak_TestUtils.createOpportunity(ProgramEnrollmentTest.Id);
        optyRecord.WaitList_Added_Time__c=System.now();
        update optyRecord;
        
        Records_Request__c recordsRequest = Peak_TestUtils.createRecordsRequest('Test RR',ProgramEnrollmentTest.Id,true);
        Map<Id, Enrollment_Component_Affiliation__c> ecaAffiliationMap=new Map<Id,Enrollment_Component_Affiliation__c>([SELECT Id,Status__c,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c WHERE Status__c = 'Complete'  AND Enrollment_Component__r.RecordType.Name = 'Question']);
        NES_ECABusinessLogic.validatePhone(new List<Id>(ecaAffiliationMap.keySet()));
        
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,schlYear.Id, false);
        progEnrollment.Status__c = 'In Progress';
        progEnrollment.PORFlag__c ='Pending';
        progEnrollment.Start_Year__c = schlYear.Id;
        
        insert progEnrollment;
        Enrollment_Component_Affiliation__c ecaAffiliation5=Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp5.Id);
        ecaAffiliation5.Status__c = 'In Progress';
        update ecaAffiliation5;
        
        Enrollment_Component__c enrollmentComponent5=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Form',False);
        enrollmentComponent5.Name = 'Form';
        enrollmentComponent5.confirmation_form__c = True;
        insert enrollmentComponent5;
        
        Enrollment_Component__c enrollmentComponent6=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Form',False);
        enrollmentComponent6.Name = 'NegativeTest';
        insert enrollmentComponent6;
        
        hed__Program_Enrollment__c progEnrollmentTest1 = Peak_TestUtils.createProgramEnrollment(programAccount.Id,TestContact.Id,schlYear.Id, false);
        
        insert progEnrollmentTest1;
        
        Enrollment_Component_Affiliation__c ecaAffiliation6=Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollmentTest1.Id,enrollmentComponent5.Id);
        ecaAffiliation6.Status__c = 'In Progress';
        
        update ecaAffiliation6;
        
        Enrollment_Component_Affiliation__c ecaAffiliation7=Peak_TestUtils.createEnrollmentComponentAffiliation(progEnrollmentTest1.Id,enrollmentComponent6.Id);
        ecaAffiliation7.Status__c = 'In Progress';
        
        update ecaAffiliation7;
        
         
      /*  //Added for #101935 User Story ,Task 104311 by Anitha P 
        //Create Program Enrollment for House hold Program Enrollment
        List<Enrollment_Component__c> enrollIDslist = new list<Enrollment_Component__c>();
        list<hed__Program_Enrollment__c> progIds = new list< hed__Program_Enrollment__c>();
        list<Enrollment_Component_Affiliation__c> ecaListIDs = new list<Enrollment_Component_Affiliation__c>();
        
        hed__Program_Enrollment__c progEnrollmentTest4 = Peak_TestUtils.createProgramEnrollment(programAccount.Id,TestContact.Id,schlYear.Id, false);
        insert progEnrollmentTest4;
        
        //Fetch Record type 'Academic Program' form Account
        RecordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];
        //Update account with Record type
        account acc = new account();
        acc.recordtypeid = rtypes.id;
        acc.id = programAccount.Id;
        update acc;
        
        //Create Program Enrollment
        hed__Program_Enrollment__c progEnrollmentTest2 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest2.Household_Program_Enrollment__c= progEnrollmentTest4.id;
        progIds.add(progEnrollmentTest2);
        //Create Program Enrollment
        hed__Program_Enrollment__c progEnrollmentTest3 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest3.Household_Program_Enrollment__c = progEnrollmentTest4.id;
        progIds.add(progEnrollmentTest3);
        insert  progIds;
        
        system.debug('progIds'+progIds);
        //Create Enrollment Component for section
        Enrollment_Component__c section1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
        section1.Name = 'Section1';
        section1.Component_Type__c = 'Household';
        enrollIDslist.add( section1);
        //Create Enrollment Component for Form
        Enrollment_Component__c Form1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Form',False);
        Form1.Name = 'Form';
        Form1.Component_Type__c = 'Household';
        enrollIDslist.add( Form1);
        //Create Enrollment Component for Stage
        Enrollment_Component__c stage1 =Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
        stage1.Name = 'Stage1';
        enrollIDslist.add( stage1);
        //Create Enrollment Component for Stage
        Enrollment_Component__c stage2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
        stage2.Name = 'Stage2';
        enrollIDslist.add( stage2);
        //Create Enrollment Component for Stage        
        Enrollment_Component__c stage3=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
        stage3.Name = 'Stage3';
        enrollIDslist.add( stage3);
        //Create Enrollment Component for process
        Enrollment_Component__c Process1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Process',False);
        Process1.Name = 'Process1';
        enrollIDslist.add(Process1);
        //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
       /* Enrollment_Component__c section2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
        section2.Name = 'Homeschool Prior Academic History';
        section2.PAH__c = TRUE;
        enrollIDslist.add( section2);*/
        //End-added for #107180 User Story (Task 108661) on 2019-09-06 
        
      /*  insert enrollIDslist;
        
        for (Enrollment_Component__c enrollIds: enrollIDslist){
            if (progIds[0].id != null && enrollIds.name == 'Section1'){
                //Create ECA for section for PE2
                Enrollment_Component_Affiliation__c ECAsection1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ECAsection1.Order__c = 1;
                ecaListIDs.add(ECAsection1);
            }
            
            //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
           /* if (progIds[0].id != null && enrollIds.name == 'Homeschool Prior Academic History'){
                //Create ECA for section for PE2
                Enrollment_Component_Affiliation__c ECAsectionHome=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ECAsectionHome.Order__c = 1;
                ECAsectionHome.Status__c='In Progress';
                ecaListIDs.add(ECAsectionHome);
            }*/
            //End-added for #107180 User Story (Task 108661) on 2019-09-06  
        /*    if (progIds[1].id != null && enrollIds.name == 'Section1'){
                //Create ECA for section for PE3
                Enrollment_Component_Affiliation__c ecasection2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecasection2.Order__c = 1;
                ecaListIDs.add(ecasection2);
            }
            if (progIds[0].id != null && enrollIds.name == 'Form'){
                //Create ECA for Form for PE2
                Enrollment_Component_Affiliation__c ecaform1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecaform1.Order__c = 1;
                ecaListIDs.add(ecaform1);
            }
            
            if (progIds[1].id != null && enrollIds.name == 'Form'){
                //Create ECA for Form for PE3
                Enrollment_Component_Affiliation__c ecaform2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecaform2.Order__c = 1;
                ecaListIDs.add(ecaform2);
            }
            
            if (progIds[0].id != null && enrollIds.name == 'Stage1'){
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecastage1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecastage1.Order__c = 1;
                ecaListIDs.add(ecastage1);
                
            }
            
            if (progIds[1].id != null&& enrollIds.name == 'Stage1'){
                //Create ECA for Stage for PE3
                Enrollment_Component_Affiliation__c ecastage11=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecastage11.Order__c = 1;
                ecaListIDs.add(ecastage11);  
                
            }
            
            if (progIds[0].id != null && enrollIds.name == 'Stage2'){
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecastage2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecastage2.Status__c = 'In Progress';
                ecastage2.Order__c = 2;
                ecaListIDs.add(ecastage2);
                
            }
            
            if (progIds[1].id != null && enrollIds.name == 'Stage2'){
                
                //Create ECA for Stage for PE3
                Enrollment_Component_Affiliation__c ecastage22=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecastage22.Status__c = 'In Progress';
                ecastage22.Order__c = 2;
                ecaListIDs.add(ecastage22);
            }
            
            if (progIds[0].id != null && enrollIds.name == 'Stage3'){
                
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecastage3=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecastage3.Status__c = 'Not Started';
                ecastage3.Order__c = 3;
                ecaListIDs.add(ecastage3);
                
            }
            
            if (progIds[1].id != null && enrollIds.name == 'Stage3'){
                //Create ECA for Stage for PE3
                Enrollment_Component_Affiliation__c ecastage33=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecastage33.Status__c = 'Not Started';
                ecastage33.Order__c = 3;
                ecaListIDs.add(ecastage33);
                
            }
            if (progIds[0].id != null && enrollIds.name == 'Process1'){
                //Create ECA for process for PE2
                Enrollment_Component_Affiliation__c ecaProcess1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecaProcess1.Status__c = 'In Progress';
                ecaListIDs.add(ecaProcess1);
            }
            if (progIds[1].id != null && enrollIds.name == 'Process1'){
                
                //Create ECA for process for PE3
                Enrollment_Component_Affiliation__c ecaProcess11=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecaProcess11.Status__c = 'In Progress';
                ecaListIDs.add(ecaProcess11);
                
            }
        }
        
        insert ecaListIDs;
        system.debug('ecaListIDs'+ecaListIDs);
        //Create Relations within Form       
        Enrollment_Component_Relationship__c relation1=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[0].Id,enrollIDslist[1].Id);
        Enrollment_Component_Relationship__c relation2=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[1].Id,enrollIDslist[2].Id);
        Enrollment_Component_Relationship__c relation3=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[2].Id,enrollIDslist[5].Id);
        Enrollment_Component_Relationship__c relation4=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[3].Id,enrollIDslist[5].Id);
        Enrollment_Component_Relationship__c relation5=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[4].Id,enrollIDslist[5].Id);
        //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
       // Enrollment_Component_Relationship__c relation6=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[6].Id,enrollIDslist[1].Id);
        //End-added for #107180 User Story (Task 108661) on 2019-09-06 
        //Added for #101935 User Story ,Task 104311 by Anitha P */
    }
    @IsTest
    static void testQueries() {
        
        List<Enrollment_Component_Affiliation__c> affiliations = [SELECT Id, Program_Enrollment__r.hed__Contact__r.AccountId, Program_Enrollment__r.hed__Contact__c, Enrollment_Component__r.Answer_Target__c, Program_Enrollment__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__r.RecordType.Name = 'Question'];
        Map<Long, Enrollment_Component_Affiliation__c> affiliationMap = NES_ECUtilities.configureQuery(affiliations);
        NES_ECUtilities.GlobalPhoneInfo newInfo = new NES_ECUtilities.GlobalPhoneInfo(4271990, 'phoneType', 'certainty');
        System.assertEquals(affiliationMap.size(), 2);
    }
    
    @isTest
    static void autoPlacementLogicTest(){
        Test.startTest();
        Enrollment_Component_Affiliation__c ecaAffiliation=[select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c Where Status__c='Complete' LIMIT 1];
        ecaAffiliation.Status__c = 'Complete';
        update ecaAffiliation;
        Annual_Student_Information__c   studInfo=[select id,Grade_Level_Requested__c,AutomatedPlacementScore__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        studInfo.RecommendedAutoPlacement__c = 'Yes';
		studInfo.AutomatedPlacementExclude__c = false;
		update studInfo;

        Enrollment_Component__c  prEn=[select id from Enrollment_Component__c Where Status__c='Not Complete' ];
        ecaAffiliation.Enrollment_Component__c=prEn.Id;
        
        // Update program ENrollment values
        hed__Program_Enrollment__c   prEn1=[select id,Final_Grade_Level__c,SIF_SummerSchoolCourses__c,SIFStudentRetained__c,
                                            SIF_AcademicSupportNeeds__c FROM hed__Program_Enrollment__c Where Id=:ecaAffiliation.Program_Enrollment__c ];
        prEn1.Final_Grade_Level__c = '1';
        prEn1.SIF_SummerSchoolCourses__c='Unsure';
        prEn1.SIFStudentRetained__c='No';
        prEn1.Academic_Doc_Performance__c='No'; 
        List<String> strList=new List<string>{'Math','Science'};
            String opt=String.join(strList, ';');
        prEn1 .SIF_AcademicSupportNeeds__c=opt;
		prEn1.status__c = 'In Progress';
        update prEn1;
        // Update ASI Grade Request
        studInfo.Grade_Level_Requested__c='2';
        update studInfo;
        //Update Affliation  Status
        Enrollment_Component_Affiliation__c ecaAffiliation1=Peak_TestUtils.createEnrollmentComponentAffiliation(prEn1.Id,prEn.Id);
        ecaAffiliation.Status__c='In Progress';
        update ecaAffiliation;
        List<Id> asiIds = new List<Id>();
        asiIds.add(studInfo.Id);
        NES_AnnualStudentInfoBusinessLogic.runPlacement(asiIds);
        Test.stopTest();
    }
    
    @isTest
    static void autoPlacementLogicNegativeTest(){
        Test.StartTest();
        Enrollment_Component_Affiliation__c ecaAffiliation=[select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c Where Status__c='Complete' LIMIT 1];
        
        Annual_Student_Information__c   studInfo=[select id,Grade_Level_Requested__c,AutomatedPlacementScore__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        Enrollment_Component__c  prEn=[select id from Enrollment_Component__c Where Status__c='Complete' ];
        hed__Program_Enrollment__c   prEn1=[select id,Final_Grade_Level__c,SIF_SummerSchoolCourses__c,SIFStudentRetained__c,
                                            SIF_AcademicSupportNeeds__c FROM hed__Program_Enrollment__c Where Id=:ecaAffiliation.Program_Enrollment__c ];
        prEn1.Final_Grade_Level__c = '1';
        prEn1.SIF_SummerSchoolCourses__c='Unsure';
        prEn1.SIFStudentRetained__c='No';
        prEn1.Academic_Doc_Performance__c='No';
        String opt='';
        prEn1 .SIF_AcademicSupportNeeds__c=opt;
        update prEn1;
        //Update ASI Grade Request
        studInfo.Grade_Level_Requested__c='';
        update studInfo;
        Enrollment_Component_Affiliation__c ecaAffiliation1=Peak_TestUtils.createEnrollmentComponentAffiliation(prEn1.Id,prEn.Id);
        ecaAffiliation1.Status__c='In Progress';
        update ecaAffiliation1;
        List<Id> asiIds = new List<Id>();
        asiIds.add(studInfo.Id);
        NES_AnnualStudentInfoBusinessLogic.runPlacement(asiIds);
        Test.StopTest();
    }
    
    /**
* Change Log: 2019-08-13 modified for #101935 User Story ,Task 104311 by Anitha P 
* Purpose   : This method is used to Set status of Parent ECA and repective ECA stage, when the ECA status of child component 
*             changed from 'Completed' to 'In progress' or 'Not started'.
* Change Log: 2019-11-21 modified for #119349 User Story by Anitha
**/
    @isTest
    static void updateALLECAsTest(){
        //***************************************
       
         //Create Program Enrollment for House hold Program Enrollment
        List<Enrollment_Component__c> enrollIDslist = new list<Enrollment_Component__c>();
        list<hed__Program_Enrollment__c> progIds = new list< hed__Program_Enrollment__c>();
        list<Enrollment_Component_Affiliation__c> ecaListIDs = new list<Enrollment_Component_Affiliation__c>();
        
       Test.StartTest();
        // hed__Program_Enrollment__c progEnrollmentTest4 = [select ID from hed__Program_Enrollment__c where name = 'Program1' ];
        Account parentAcc = [select id from account where name = 'TestAcc'];


        account programAccount = [select ID from account where name = 'Test Account' and ParentId =: parentAcc.id  limit 1];
          Contact TestContact = [select id from contact where lastname = 'TestCon' limit 1 ];
           School_Year__c schlYear = [select id from School_Year__c where name = 'SchoolTest' limit 1];
        hed__Program_Enrollment__c progEnrollmentTest4 = Peak_TestUtils.createProgramEnrollment(programAccount.Id,TestContact.Id,schlYear.Id, false);
        insert progEnrollmentTest4;
        
        //Fetch Record type 'Academic Program' form Account
        RecordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];
        //Update account with Record type
        account acc = new account();
        acc.recordtypeid = rtypes.id;
        acc.id = programAccount.Id;
        update acc;
         //Start-added logic for the bug 119931 on 11/19/2019
        Grade_Level__c   gradeLevel = Peak_TestUtils.createGradeLevel('1', True);
        Program_Grade_Level__c  progGrades = Peak_TestUtils.createProgramGradeLevel ('Test1',programAccount.Id ,gradeLevel.Id, System.today(), false);
        progGrades.ActivateWaitlist__c = TRUE;
        progGrades.StartWaitlist__c = System.now();
        progGrades.EndWaitlist__c = System.now().addHours(4);
        insert progGrades;
        //End-added logic for the bug 119931 on 11/19/2019
        
        hed__Program_Enrollment__c progEnrollmentTest2 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest2.Household_Program_Enrollment__c= progEnrollmentTest4.id;
        progEnrollmentTest2.Program_Grade_Level__c = progGrades.id;
        progEnrollmentTest2.hed__Account__c = programAccount.id;
        progIds.add(progEnrollmentTest2);
        
        //Create Program Enrollment
        hed__Program_Enrollment__c progEnrollmentTest3 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest3.Household_Program_Enrollment__c = progEnrollmentTest4.id;
        progEnrollmentTest3.Program_Grade_Level__c = progGrades.id;
        progIds.add(progEnrollmentTest3);
        
        hed__Program_Enrollment__c progEnrollmentTest5 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest5.Household_Program_Enrollment__c = progEnrollmentTest4.id;
        progEnrollmentTest5.Program_Grade_Level__c = progGrades.id;
        progIds.add(progEnrollmentTest5);
        
        insert  progIds;
        
        Opportunity optyTest2 = Peak_TestUtils.createOpportunity(progEnrollmentTest2.id);
        Annual_Student_Information__c studInfo1=Peak_TestUtils.createAnnualStudentInformation('Test1',progEnrollmentTest2.Id,schlYear.Id,False);
        studInfo1.Grade_Level_Requested__c='7';
        studInfo1.Final_Grade_Level__c = '6';
        insert studInfo1;
        
        
        system.debug('progIds'+progIds);
        //Create Enrollment Component for section
        Enrollment_Component__c section1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
        section1.Name = 'Section1';
        section1.Component_Type__c = 'Household';
        enrollIDslist.add( section1);
       
        //Create Enrollment Component for Form
        Enrollment_Component__c Form1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Form',False);
        Form1.Name = 'Form';
        Form1.Component_Type__c = 'Household';
        enrollIDslist.add( Form1);
        //Create Enrollment Component for Stage
        Enrollment_Component__c stage1 =Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
        stage1.Name = 'Stage1';
        enrollIDslist.add( stage1);
        //Create Enrollment Component for Stage
        Enrollment_Component__c stage2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
        stage2.Name = 'Stage2';
        enrollIDslist.add( stage2);
        //Create Enrollment Component for Stage        
        Enrollment_Component__c stage3=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
        stage3.Name = 'Stage3';
        enrollIDslist.add( stage3);
        //Create Enrollment Component for process
        Enrollment_Component__c Process1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Process',False);
        Process1.Name = 'Process1';
        enrollIDslist.add(Process1);
        
        Enrollment_Component__c section2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
        section2.Name = 'Section2';
        section2.Component_Type__c = 'Household';
        enrollIDslist.add( section2);

        //Create Enrollment Component for Form
        Enrollment_Component__c Form2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Form',False);
        Form2.Name = 'Form2';
        Form2.Component_Type__c = 'Household';
        enrollIDslist.add( Form2);
        Enrollment_Component__c text=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Text',False);
        text.Name = 'text2';
        text.Component_Type__c = 'Household';
        enrollIDslist.add( text);
        //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
       /* Enrollment_Component__c section2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
        section2.Name = 'Homeschool Prior Academic History';
        section2.PAH__c = TRUE;
        enrollIDslist.add( section2);*/
        //End-added for #107180 User Story (Task 108661) on 2019-09-06 
        
       insert enrollIDslist;
        
        for (Enrollment_Component__c enrollIds: enrollIDslist){
            if (progIds[0].id != null && enrollIds.name == 'Section1'){
                //Create ECA for section for PE2
                Enrollment_Component_Affiliation__c ECAsection1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ECAsection1.Order__c = 1;
                //insert ECAsection1;
                ECAsection1.Status__c = 'Complete';
                ecaListIDs.add(ECAsection1);
            }
            
            //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
           /* if (progIds[0].id != null && enrollIds.name == 'Homeschool Prior Academic History'){
                //Create ECA for section for PE2
                Enrollment_Component_Affiliation__c ECAsectionHome=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ECAsectionHome.Order__c = 1;
                ECAsectionHome.Status__c='In Progress';
                ecaListIDs.add(ECAsectionHome);
            }*/
            //End-added for #107180 User Story (Task 108661) on 2019-09-06  
           if (progIds[1].id != null && enrollIds.name == 'Section1'){
                //Create ECA for section for PE3
                Enrollment_Component_Affiliation__c ecasection2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecasection2.Order__c = 1;
                ecasection2.Status__c = 'Complete';
                ecaListIDs.add(ecasection2);
            }
            if (progIds[0].id != null && enrollIds.name == 'Form'){
                //Create ECA for Form for PE2
                Enrollment_Component_Affiliation__c ecaform1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecaform1.Order__c = 1;
                ecaListIDs.add(ecaform1);
            }
            
            if (progIds[1].id != null && enrollIds.name == 'Form'){
                //Create ECA for Form for PE3
                Enrollment_Component_Affiliation__c ecaform2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecaform2.Order__c = 1;
                ecaListIDs.add(ecaform2);
            }
            
            if (progIds[0].id != null && enrollIds.name == 'Stage1'){
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecastage1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecastage1.Order__c = 1;
                ecaListIDs.add(ecastage1);
                
            }
            
            if (progIds[1].id != null&& enrollIds.name == 'Stage1'){
                //Create ECA for Stage for PE3
                Enrollment_Component_Affiliation__c ecastage11=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecastage11.Order__c = 1;
                ecaListIDs.add(ecastage11);  
                
            }
            
            if (progIds[0].id != null && enrollIds.name == 'Stage2'){
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecastage2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecastage2.Status__c = 'In Progress';
                ecastage2.Order__c = 2;
                ecaListIDs.add(ecastage2);
                
            }
            
            if (progIds[1].id != null && enrollIds.name == 'Stage2'){
                
                //Create ECA for Stage for PE3
                Enrollment_Component_Affiliation__c ecastage22=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecastage22.Status__c = 'In Progress';
                ecastage22.Order__c = 2;
                ecaListIDs.add(ecastage22);
            }
            
            if (progIds[0].id != null && enrollIds.name == 'Stage3'){
                
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecastage3=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecastage3.Status__c = 'Complete';
                ecastage3.Order__c = 3;
                ecaListIDs.add(ecastage3);
                
            }
          
             if (progIds[0].id != null && enrollIds.name == 'Section2'){
                
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecasection2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecasection2.Status__c = 'Complete';
                ecasection2.Order__c = 3;
                ecaListIDs.add(ecasection2);
                
            }
             if (progIds[0].id != null && enrollIds.name == 'Form2'){
                
                //Create ECA for Stage for PE2
                Enrollment_Component_Affiliation__c ecaform1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecaform1.Status__c = 'Complete';
                ecaform1.Order__c = 3;
                ecaListIDs.add(ecaform1);
                
            }
            
            
            if (progIds[1].id != null && enrollIds.name == 'Stage3'){
                //Create ECA for Stage for PE3
                Enrollment_Component_Affiliation__c ecastage33=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecastage33.Status__c = 'Not Started';
                ecastage33.Order__c = 3;
                ecaListIDs.add(ecastage33);
                
            }
            if (progIds[0].id != null && enrollIds.name == 'Process1'){
                //Create ECA for process for PE2
                Enrollment_Component_Affiliation__c ecaProcess1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
                ecaProcess1.Status__c = 'In Progress';
                ecaListIDs.add(ecaProcess1);
            }
            if (progIds[1].id != null && enrollIds.name == 'Process1'){
                
                //Create ECA for process for PE3
                Enrollment_Component_Affiliation__c ecaProcess11=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
                ecaProcess11.Status__c = 'In Progress';
                ecaListIDs.add(ecaProcess11);
                
            }
        }
        
        insert ecaListIDs;
        
        system.debug('ecaListIDs'+ecaListIDs);
        //Create Relations within Form       
        Enrollment_Component_Relationship__c relation1=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[0].Id,enrollIDslist[1].Id);
        Enrollment_Component_Relationship__c relation2=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[1].Id,enrollIDslist[2].Id);
        Enrollment_Component_Relationship__c relation3=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[2].Id,enrollIDslist[5].Id);
        Enrollment_Component_Relationship__c relation4=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[3].Id,enrollIDslist[5].Id);
        Enrollment_Component_Relationship__c relation5=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[4].Id,enrollIDslist[5].Id);
        Enrollment_Component_Relationship__c relation6=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[7].Id,enrollIDslist[4].Id);
        Enrollment_Component_Relationship__c relation7=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[6].Id,enrollIDslist[7].Id);
        Enrollment_Component_Relationship__c relation8=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[8].Id,enrollIDslist[6].Id);
        //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
       // Enrollment_Component_Relationship__c relation6=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[6].Id,enrollIDslist[1].Id);
        //End-added for #107180 User Story (Task 108661) on 2019-09-06 

       //added for US119349 
        if (progIds[2].id != null && enrollIDslist[6].name == 'Section2'){
                //Create ECA for section for PE2
                Enrollment_Component_Affiliation__c ECAsectionName=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[2].Id,enrollIDslist[6].id,False);
                ECAsectionName.Order__c = 1;
                ECAsectionName.Status__c = 'Not Started';
                insert ECAsectionName;
                
        }
        //added for US119349 
        boolean updateFlag = true;

        //Fetch Enrollment Component for 'Section1'
        Enrollment_Component__c  prEn=[select id from Enrollment_Component__c Where NAME = 'Section1' limit 1];
        System.debug('prEn.id'+prEn.id);
        map<id,id> ecaMap = new map<id,id>();
        list<Enrollment_Component_Affiliation__c> ecaList = new list<Enrollment_Component_Affiliation__c>();
        //Fetch ECA's related EC component
        for( Enrollment_Component_Affiliation__c  ecaAffiliation : [select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c 
                                                                    Where Status__c='Complete' and Enrollment_Component__c =:prEn.id]){
                                                                        ecaAffiliation.Status__c='In Progress';
                                                                        ecaList.add(ecaAffiliation);
                                                                        ecaMap.put(ecaAffiliation.Enrollment_Component__c, ecaAffiliation.Program_Enrollment__c);  
                                                                    }
      
        update ecaList;
        
        //Fetch Enrollment component relations     
        set<id> parentIDs = new set<id>();
        for( Enrollment_Component_Relationship__c ecaRelationship : [
            SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Child_Enrollment_Component__c IN : ecaMap.keyset()] ){
                parentIDs.add(ecaRelationship.Parent_Enrollment_Component__c);                
            }
        
        //Fetch ECAs of parent EC's
        Enrollment_Component_Affiliation__c affrecd = new Enrollment_Component_Affiliation__c();
        for( Enrollment_Component_Affiliation__c affiliationRecord : [
            SELECT Id,Enrollment_Component__c,
            Status__c, Order__c,Program_Enrollment__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Enrollment_Component__c IN :  parentIDs and
            Program_Enrollment__c IN :ecamap.values()]){
                if(affiliationRecord.Status__c == 'In Progress'){
                    UpdateFlag = False;
                    break;
                    affrecd = affiliationRecord;
                }
            }
        // Force completion of any async processing */
        Test.StopTest(); 
        //assert values 
       system.assertEquals(False, UpdateFlag);


    }

    //  @isTest
    // static void naECAsCompletionLogic_PositiveTest(){
    //     //***************************************
       
    //      //Create Program Enrollment for House hold Program Enrollment
    //     List<Enrollment_Component__c> enrollIDslist = new list<Enrollment_Component__c>();
    //     list<hed__Program_Enrollment__c> progIds = new list< hed__Program_Enrollment__c>();
    //     list<Enrollment_Component_Affiliation__c> ecaListIDs = new list<Enrollment_Component_Affiliation__c>();
        
    //    Test.StartTest();
    //     // hed__Program_Enrollment__c progEnrollmentTest4 = [select ID from hed__Program_Enrollment__c where name = 'Program1' ];
    //     Account parentAcc = [select id from account where name = 'TestAcc'];


    //     account programAccount = [select ID from account where name = 'Test Account' and ParentId =: parentAcc.id  limit 1];
    //       Contact TestContact = [select id from contact where lastname = 'TestCon' limit 1 ];
    //        School_Year__c schlYear = [select id from School_Year__c where name = 'SchoolTest' limit 1];
    //     hed__Program_Enrollment__c progEnrollmentTest4 = Peak_TestUtils.createProgramEnrollment(programAccount.Id,TestContact.Id,schlYear.Id, false);
    //     insert progEnrollmentTest4;
        
    //     //Fetch Record type 'Academic Program' form Account
    //     RecordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];
    //     //Update account with Record type
    //     account acc = new account();
    //     acc.recordtypeid = rtypes.id;
    //     acc.id = programAccount.Id;
    //     update acc;
    //      //Start-added logic for the bug 119931 on 11/19/2019
    //     Grade_Level__c   gradeLevel = Peak_TestUtils.createGradeLevel('1', True);
    //     Program_Grade_Level__c  progGrades = Peak_TestUtils.createProgramGradeLevel ('Test1',programAccount.Id ,gradeLevel.Id, System.today(), false);
    //     progGrades.ActivateWaitlist__c = TRUE;
    //     progGrades.StartWaitlist__c = System.now();
    //     progGrades.EndWaitlist__c = System.now().addHours(4);
    //     insert progGrades;
    //     //End-added logic for the bug 119931 on 11/19/2019
        
    //     hed__Program_Enrollment__c progEnrollmentTest2 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
    //     progEnrollmentTest2.Household_Program_Enrollment__c= progEnrollmentTest4.id;
    //     progEnrollmentTest2.Program_Grade_Level__c = progGrades.id;
    //     progEnrollmentTest2.hed__Account__c = programAccount.id;
    //     progIds.add(progEnrollmentTest2);
        
    //     //Create Program Enrollment
    //     hed__Program_Enrollment__c progEnrollmentTest3 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
    //     progEnrollmentTest3.Household_Program_Enrollment__c = progEnrollmentTest4.id;
    //     progEnrollmentTest3.Program_Grade_Level__c = progGrades.id;
    //     progIds.add(progEnrollmentTest3);
        
    //     hed__Program_Enrollment__c progEnrollmentTest5 = Peak_TestUtils.createProgramEnrollment(acc.Id,TestContact.Id,schlYear.Id, false);
    //     progEnrollmentTest5.Household_Program_Enrollment__c = progEnrollmentTest4.id;
    //     progEnrollmentTest5.Program_Grade_Level__c = progGrades.id;
    //     progIds.add(progEnrollmentTest5);
        
    //     insert  progIds;
        
    //     Opportunity optyTest2 = Peak_TestUtils.createOpportunity(progEnrollmentTest2.id);
    //     Annual_Student_Information__c studInfo1=Peak_TestUtils.createAnnualStudentInformation('Test1',progEnrollmentTest2.Id,schlYear.Id,False);
    //     studInfo1.Grade_Level_Requested__c='7';
    //     studInfo1.Final_Grade_Level__c = '6';
    //     insert studInfo1;
        
        
    //     system.debug('progIds'+progIds);
    //     //Create Enrollment Component for section
    //     Enrollment_Component__c section1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
    //     section1.Name = 'Section1';
    //     section1.Component_Type__c = 'Household';
    //     enrollIDslist.add( section1);
       
    //     //Create Enrollment Component for Form
    //     Enrollment_Component__c Form1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Form',False);
    //     Form1.Name = 'Form';
    //     Form1.Component_Type__c = 'Household';
    //     enrollIDslist.add( Form1);
    //     //Create Enrollment Component for Stage
    //     Enrollment_Component__c stage1 =Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
    //     stage1.Name = 'Stage1';
    //     enrollIDslist.add( stage1);
    //     //Create Enrollment Component for Stage
    //     Enrollment_Component__c stage2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
    //     stage2.Name = 'Stage2';
    //     enrollIDslist.add( stage2);
    //     //Create Enrollment Component for Stage        
    //     Enrollment_Component__c stage3=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Stage',False);
    //     stage3.Name = 'Stage3';
    //     enrollIDslist.add( stage3);
    //     //Create Enrollment Component for process
    //     Enrollment_Component__c Process1=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Process',False);
    //     Process1.Name = 'Process1';
    //     enrollIDslist.add(Process1);
        
    //     Enrollment_Component__c section2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
    //     section2.Name = 'Section2';
    //     section2.Component_Type__c = 'Household';
    //     enrollIDslist.add( section2);
        
    //     //Create Enrollment Component for Form
    //     Enrollment_Component__c Form2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Form',False);
    //     Form2.Name = 'Form2';
    //     Form2.Component_Type__c = 'Household';
    //     enrollIDslist.add( Form2);
    //     Enrollment_Component__c text=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Text',False);
    //     text.Name = 'text2';
    //     text.Component_Type__c = 'Household';
    //     enrollIDslist.add( text);
    //     //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
    //    /* Enrollment_Component__c section2=Peak_TestUtils.createEnrollmentComponent(acc.Id,'Section',False);
    //     section2.Name = 'Homeschool Prior Academic History';
    //     section2.PAH__c = TRUE;
    //     enrollIDslist.add( section2);*/
    //     //End-added for #107180 User Story (Task 108661) on 2019-09-06 
        
    //    insert enrollIDslist;
        
    //     for (Enrollment_Component__c enrollIds: enrollIDslist){
    //         if (progIds[0].id != null && enrollIds.name == 'Section1'){
    //             //Create ECA for section for PE2
    //             Enrollment_Component_Affiliation__c ECAsection1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ECAsection1.Order__c = 1;
    //             //insert ECAsection1;
    //             ECAsection1.Status__c = 'In Progress'; // @ALIKM: 1/21/2020 oldVal = 'Complete'
    //             ecaListIDs.add(ECAsection1);
    //         }
            
    //         //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
    //        /* if (progIds[0].id != null && enrollIds.name == 'Homeschool Prior Academic History'){
    //             //Create ECA for section for PE2
    //             Enrollment_Component_Affiliation__c ECAsectionHome=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ECAsectionHome.Order__c = 1;
    //             ECAsectionHome.Status__c='In Progress';
    //             ecaListIDs.add(ECAsectionHome);
    //         }*/
    //         //End-added for #107180 User Story (Task 108661) on 2019-09-06  
    //        if (progIds[1].id != null && enrollIds.name == 'Section1'){
    //             //Create ECA for section for PE3
    //             Enrollment_Component_Affiliation__c ecasection2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
    //             ecasection2.Order__c = 1;
    //             ecasection2.Status__c = 'In Progress'; // ALI KM oldVal = 'Complete'
    //             ecaListIDs.add(ecasection2);
    //         }
    //         if (progIds[0].id != null && enrollIds.name == 'Form'){
    //             //Create ECA for Form for PE2
    //             Enrollment_Component_Affiliation__c ecaform1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecaform1.Order__c = 1;
    //             ecaListIDs.add(ecaform1);
    //         }
            
    //         if (progIds[1].id != null && enrollIds.name == 'Form'){
    //             //Create ECA for Form for PE3
    //             Enrollment_Component_Affiliation__c ecaform2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
    //             ecaform2.Order__c = 1;
    //             ecaListIDs.add(ecaform2);
    //         }
            
    //         if (progIds[0].id != null && enrollIds.name == 'Stage1'){
    //             //Create ECA for Stage for PE2
    //             Enrollment_Component_Affiliation__c ecastage1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecastage1.Order__c = 1;
    //             ecaListIDs.add(ecastage1);
                
    //         }
            
    //         if (progIds[1].id != null&& enrollIds.name == 'Stage1'){
    //             //Create ECA for Stage for PE3
    //             Enrollment_Component_Affiliation__c ecastage11=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
    //             ecastage11.Order__c = 1;
    //             ecaListIDs.add(ecastage11);  
                
    //         }
            
    //         if (progIds[0].id != null && enrollIds.name == 'Stage2'){
    //             //Create ECA for Stage for PE2
    //             Enrollment_Component_Affiliation__c ecastage2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecastage2.Status__c = 'In Progress'; // ALI KM oldVal = 'Complete'
    //             ecastage2.Order__c = 2;
    //             ecaListIDs.add(ecastage2);
                
    //         }
            
    //         if (progIds[1].id != null && enrollIds.name == 'Stage2'){
                
    //             //Create ECA for Stage for PE3
    //             Enrollment_Component_Affiliation__c ecastage22=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
    //             ecastage22.Status__c = 'In Progress';
    //             ecastage22.Order__c = 2;
    //             ecaListIDs.add(ecastage22);
    //         }
            
    //         if (progIds[0].id != null && enrollIds.name == 'Stage3'){
                
    //             //Create ECA for Stage for PE2
    //             Enrollment_Component_Affiliation__c ecastage3=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecastage3.Status__c = 'In Progress'; // ALI KM oldVal = 'Complete'
    //             ecastage3.Order__c = 3;
    //             ecaListIDs.add(ecastage3);
                
    //         }
          
    //          if (progIds[0].id != null && enrollIds.name == 'Section2'){
                
    //             //Create ECA for Stage for PE2
    //             Enrollment_Component_Affiliation__c ecasection2=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecasection2.Status__c = 'In Progress'; // ALI KM oldVal = 'Complete'
    //             ecasection2.Order__c = 3;
    //             ecaListIDs.add(ecasection2);
                
    //         }
    //          if (progIds[0].id != null && enrollIds.name == 'Form2'){
                
    //             //Create ECA for Stage for PE2
    //             Enrollment_Component_Affiliation__c ecaform1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecaform1.Status__c = 'In Progress'; // ALI KM oldVal = 'Complete'
    //             ecaform1.Order__c = 3;
    //             ecaListIDs.add(ecaform1);
                
    //         }
            
            
    //         if (progIds[1].id != null && enrollIds.name == 'Stage3'){
    //             //Create ECA for Stage for PE3
    //             Enrollment_Component_Affiliation__c ecastage33=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
    //             ecastage33.Status__c = 'Not Started';
    //             ecastage33.Order__c = 3;
    //             ecaListIDs.add(ecastage33);
                
    //         }
    //         if (progIds[0].id != null && enrollIds.name == 'Process1'){
    //             //Create ECA for process for PE2
    //             Enrollment_Component_Affiliation__c ecaProcess1=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[0].Id,enrollIds.id,False);
    //             ecaProcess1.Status__c = 'In Progress';
    //             ecaListIDs.add(ecaProcess1);
    //         }
    //         if (progIds[1].id != null && enrollIds.name == 'Process1'){
                
    //             //Create ECA for process for PE3
    //             Enrollment_Component_Affiliation__c ecaProcess11=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[1].Id,enrollIds.id,False);
    //             ecaProcess11.Status__c = 'In Progress';
    //             ecaListIDs.add(ecaProcess11);
                
    //         }
    //     }
        
    //     insert ecaListIDs;
        
    //     system.debug('ecaListIDs'+ecaListIDs);
    //     //Create Relations within Form       
    //     Enrollment_Component_Relationship__c relation1=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[0].Id,enrollIDslist[1].Id);
    //     Enrollment_Component_Relationship__c relation2=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[1].Id,enrollIDslist[2].Id);
    //     Enrollment_Component_Relationship__c relation3=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[2].Id,enrollIDslist[5].Id);
    //     Enrollment_Component_Relationship__c relation4=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[3].Id,enrollIDslist[5].Id);
    //     Enrollment_Component_Relationship__c relation5=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[4].Id,enrollIDslist[5].Id);
    //     Enrollment_Component_Relationship__c relation6=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[7].Id,enrollIDslist[4].Id);
    //     Enrollment_Component_Relationship__c relation7=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[6].Id,enrollIDslist[7].Id);
    //     Enrollment_Component_Relationship__c relation8=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[8].Id,enrollIDslist[6].Id);
    //     //Start-added for #107180 User Story (Task 108661) on 2019-09-06 
    //    // Enrollment_Component_Relationship__c relation6=Peak_TestUtils.createEnrollmentComponentRelationship(enrollIDslist[6].Id,enrollIDslist[1].Id);
    //     //End-added for #107180 User Story (Task 108661) on 2019-09-06 

    //    //added for US119349 
    //     if (progIds[2].id != null && enrollIDslist[6].name == 'Section2'){
    //             //Create ECA for section for PE2
    //             Enrollment_Component_Affiliation__c ECAsectionName=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[2].Id,enrollIDslist[6].id,False);
    //             ECAsectionName.Order__c = 1;
    //             ECAsectionName.Status__c = 'Not Started';
    //             insert ECAsectionName;
                
    //     }
    //     //added for US119349 
    //     boolean updateFlag = true;

    //     //Fetch Enrollment Component for 'Section1'
    //     Enrollment_Component__c  prEn=[select id from Enrollment_Component__c Where NAME = 'Section1' limit 1];
    //     System.debug('prEn.id'+prEn.id);
    //     map<id,id> ecaMap = new map<id,id>();
    //     list<Enrollment_Component_Affiliation__c> ecaList = new list<Enrollment_Component_Affiliation__c>();
    //     //Fetch ECA's related EC component
    //     for( Enrollment_Component_Affiliation__c  ecaAffiliation : [select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c 
    //                                                                 Where Status__c='In Progress' and Enrollment_Component__c =:prEn.id]){
    //                                                                     ecaAffiliation.Status__c='Not Applicable';
    //                                                                     ecaList.add(ecaAffiliation);
    //                                                                     ecaMap.put(ecaAffiliation.Enrollment_Component__c, ecaAffiliation.Program_Enrollment__c);  
    //                                                                 }
      
    //     update ecaList;
        
    //     // ALIKM : Commented below : START
    //     // //Fetch Enrollment component relations     
    //     // set<id> parentIDs = new set<id>();
    //     // for( Enrollment_Component_Relationship__c ecaRelationship : [
    //     //     SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
    //     //     FROM Enrollment_Component_Relationship__c
    //     //     WHERE Child_Enrollment_Component__c IN : ecaMap.keyset()] ){
    //     //         parentIDs.add(ecaRelationship.Parent_Enrollment_Component__c);                
    //     //     }
        
    //     // //Fetch ECAs of parent EC's
    //     // Enrollment_Component_Affiliation__c affrecd = new Enrollment_Component_Affiliation__c();
    //     // for( Enrollment_Component_Affiliation__c affiliationRecord : [
    //     //     SELECT Id,Enrollment_Component__c,
    //     //     Status__c, Order__c,Program_Enrollment__c
    //     //     FROM Enrollment_Component_Affiliation__c
    //     //     WHERE Enrollment_Component__c IN :  parentIDs and
    //     //     Program_Enrollment__c IN :ecamap.values()]){
    //     //         if(affiliationRecord.Status__c == 'In Progress'){
    //     //             UpdateFlag = False;
    //     //             break;
    //     //             affrecd = affiliationRecord;
    //     //         }
    //     //     }
    //     // ALIKM : Commented below : END 

    //     // Force completion of any async processing */
    //     Test.StopTest(); 
        
    //     //assert values 
    // //    system.assertEquals(False, UpdateFlag);


    // }
    /**
* Change Log: Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-06
**/
    //Start-added for #107180 User Story (Task 108660) on 2019-09-06  
   /* @isTest
    static void updatePAHTest(){
        Test.StartTest();
        //Fetch Enrollment Component for 'Section1'
        Enrollment_Component__c prEn=[select id from Enrollment_Component__c Where NAME = 'Homeschool Prior Academic History' limit 1];
        set<id> peIDs = new set<Id>();
        list<Enrollment_Component_Affiliation__c> ecaList = new list<Enrollment_Component_Affiliation__c>();
        //Fetch ECA's related EC component
        for( Enrollment_Component_Affiliation__c  ecaAffiliation : [select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c 
                                                                    Where Enrollment_Component__c =:prEn.id]){
                                                                        peids.add( ecaAffiliation.Program_Enrollment__c);
                                                                        ecaAffiliation.Status__c='Complete';
                                                                        ecaList.add(ecaAffiliation);
        //Update ECA                                                            }
        update ecaList;
        hed__Program_Enrollment__c programIDs = [Select Id,PAHStatus__c from hed__Program_Enrollment__c where ID IN :peids limit 1] ;
        // Force completion of any async processing 
       Test.StopTest(); 
        //assert values 
        system.assertEquals('Received', programIDs.PAHStatus__c);
    }
    } */
    //End-added for #107180 User Story (Task 108660) on 2019-09-06
    
    @IsTest
    static void waitListAddedTimeTest(){
        Test.startTest();
        hed__Program_Enrollment__c progEnrollment=[SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        Enrollment_Component_Affiliation__c affiliation=[SELECT Id,Status__c,Program_Enrollment__c,Enrollment_Component__c,Enrollment_Component__r.Waitlist__c FROM Enrollment_Component_Affiliation__c WHERE Status__c='Complete' AND Enrollment_Component__r.Waitlist__c=TRUE LIMIT 1];
        affiliation.Status__c='In Progress';
        update affiliation;
        Test.stopTest();
        Opportunity opportunity = [SELECT Id,WaitList_Added_Time__c FROM Opportunity LIMIT 1];
        System.assertEquals(System.today(),opportunity.WaitList_Added_Time__c.date());
    }
    
    static testMethod void test_calculateAutomatedPlacementProcessOne(){
        Enrollment_Component__c  prEn=[select id,Required_to_Complete_for_Auto_Placement__c from Enrollment_Component__c Where Status__c='Complete' ];
        prEn.Required_to_Complete_for_Auto_Placement__c = true;
        update prEn;
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name ='SchoolTest'];
        schoolYear.Start_Date__c = Date.parse('12/09/19');
        schoolYear.End_Date__c = Date.parse('12/09/20');
        update schoolYear;
        hed__Program_Enrollment__c progEnrollment=[select id from hed__Program_Enrollment__c Limit 1];
        Enrollment_Component_Affiliation__c ecaAffiliation=[select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c Where Status__c='Complete' LIMIT 1];
        Annual_Student_Information__c   annualStudentInformation=[select id,Grade_Level_Requested__c,AutomatedPlacementScore__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        annualStudentInformation.RecommendedAutoPlacement__c = 'Yes';
        annualStudentInformation.AutomatedPlacementScore__c = 80;
        annualStudentInformation.AutomatedPlacementExclude__c = false;
        annualStudentInformation.LA_Placement_Level__c = null;
        annualStudentInformation.Science_Placement_Level__c = null;
        annualStudentInformation.Final_Grade_Level__c = null;
        annualStudentInformation.Math_Placement_Level__c = null;
        annualStudentInformation.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        annualStudentInformation.APS_PlacedTimeStamp__c = System.today();
        update annualStudentInformation;
        Enrollment_Component__c enrollmentComponent = [SELECT Id, Required_to_Complete_for_Auto_Placement__c FROM Enrollment_Component__c WHERE Name = 'enComp1' LIMIT 1];
        enrollmentComponent.Required_to_Complete_for_Auto_Placement__c = true;
        update enrollmentComponent;
        Enrollment_Component_Affiliation__c affiliation=[SELECT Id,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c
                                                         WHERE Status__c='Complete' AND Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = true
                                                         AND Program_Enrollment__c =: progEnrollment.Id  LIMIT 1];
        affiliation.Deferral_Date__c = System.today().addDays(5);
        update affiliation;
        List<Id> asiIds = new List<Id>();
        asiIds.add(annualStudentInformation.Id);
        NES_AnnualStudentInfoBusinessLogic.runPlacement(asiIds);
        
    }
    
    static testMethod void test_calculateAutomatedPlacementProcessTwo(){
        Enrollment_Component__c  prEn=[select id,Required_to_Complete_for_Auto_Placement__c from Enrollment_Component__c Where Status__c='Complete' ];
        prEn.Required_to_Complete_for_Auto_Placement__c = true;
        update prEn;
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name ='SchoolTest'];
        schoolYear.Start_Date__c = Date.parse('12/09/19');
        schoolYear.End_Date__c = Date.parse('12/09/20');
        update schoolYear;
        hed__Program_Enrollment__c progEnrollment=[SELECT Id from hed__Program_Enrollment__c WHERE Start_Year__c =: schoolYear.Id Limit 1];
        progEnrollment.WhyFlagged__c = null;
        progEnrollment.WaitlistFlag__c = 'Active';
        update progEnrollment;
        System.debug('progEnrollment.Id>>>>>>'+progEnrollment.Id);
        Enrollment_Component_Affiliation__c ecaAffiliation=[select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c Where Status__c='Complete' LIMIT 1];
        Annual_Student_Information__c   annualStudentInformation=[select id,Grade_Level_Requested__c,AutomatedPlacementScore__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        annualStudentInformation.RecommendedAutoPlacement__c = null;
        annualStudentInformation.AutomatedPlacementScore__c = 80;
        annualStudentInformation.AutomatedPlacementExclude__c = false;
        annualStudentInformation.LA_Placement_Level__c = null;
        annualStudentInformation.Science_Placement_Level__c = null;
        annualStudentInformation.Final_Grade_Level__c = null;
        annualStudentInformation.Math_Placement_Level__c = null;
        annualStudentInformation.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        annualStudentInformation.Grade_Level_Requested__c = '8';
        annualStudentInformation.APS_PlacedTimeStamp__c = null;
        update annualStudentInformation;
        Enrollment_Component__c enrollmentComponent = [SELECT Id, Required_to_Complete_for_Auto_Placement__c FROM Enrollment_Component__c WHERE Name = 'enComp1' LIMIT 1];
        enrollmentComponent.Required_to_Complete_for_Auto_Placement__c = true;
        update enrollmentComponent;
        Opportunity opportunity = [SELECT Id,Lottery_Selection_Date__c,Lottery_Selection__c FROM Opportunity WHERE Program_Enrollment__c =: progEnrollment.Id];
        opportunity.Lottery_Selection_Date__c = System.today().addDays(30);
        update opportunity;
        Enrollment_Component_Affiliation__c affiliation=[SELECT Id,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c
                                                         WHERE Status__c='Complete' AND Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = true
                                                         AND Program_Enrollment__c =: progEnrollment.Id  LIMIT 1];
        affiliation.Deferral_Date__c = System.today().addDays(5);
        Test.startTest();
        update affiliation;
        Test.stopTest();
    }
    
    static testMethod void test_calculateAutomatedPlacementProcessThree(){
        Enrollment_Component__c  prEn=[select id,Required_to_Complete_for_Auto_Placement__c from Enrollment_Component__c Where Status__c='Complete' ];
        prEn.Required_to_Complete_for_Auto_Placement__c = true;
        update prEn;
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name ='SchoolTest'];
        schoolYear.Start_Date__c = Date.parse('12/09/19');
        schoolYear.End_Date__c = Date.parse('12/09/20');
        update schoolYear;
        hed__Program_Enrollment__c progEnrollment=[SELECT Id from hed__Program_Enrollment__c WHERE Start_Year__c =: schoolYear.Id Limit 1];
        progEnrollment.WhyFlagged__c = 'Eligibility';
        progEnrollment.WaitlistFlag__c = 'Active';
        update progEnrollment;
        System.debug('progEnrollment.Id>>>>>>'+progEnrollment.Id);
        Enrollment_Component_Affiliation__c ecaAffiliation=[select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c Where Status__c='Complete' LIMIT 1];
        Annual_Student_Information__c   annualStudentInformation=[select id,Grade_Level_Requested__c,AutomatedPlacementScore__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        annualStudentInformation.RecommendedAutoPlacement__c = null;
        annualStudentInformation.AutomatedPlacementScore__c = 80;
        annualStudentInformation.AutomatedPlacementExclude__c = false;
        annualStudentInformation.LA_Placement_Level__c = null;
        annualStudentInformation.Science_Placement_Level__c = null;
        annualStudentInformation.Final_Grade_Level__c = null;
        annualStudentInformation.Math_Placement_Level__c = null;
        annualStudentInformation.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        annualStudentInformation.Grade_Level_Requested__c = 'K';
        annualStudentInformation.APS_PlacedTimeStamp__c = null;
        update annualStudentInformation;
        Enrollment_Component__c enrollmentComponent = [SELECT Id, Required_to_Complete_for_Auto_Placement__c FROM Enrollment_Component__c WHERE Name = 'enComp1' LIMIT 1];
        enrollmentComponent.Required_to_Complete_for_Auto_Placement__c = true;
        update enrollmentComponent;
        Opportunity opportunity = [SELECT Id,Lottery_Selection_Date__c,Lottery_Selection__c FROM Opportunity WHERE Program_Enrollment__c =: progEnrollment.Id];
        opportunity.Lottery_Selection_Date__c = System.today().addDays(30);
        update opportunity;
        Enrollment_Component_Affiliation__c affiliation=[SELECT Id,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c
                                                         WHERE Status__c='Complete' AND Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = true
                                                         AND Program_Enrollment__c =: progEnrollment.Id  LIMIT 1];
        affiliation.Deferral_Date__c = System.today().addDays(5);
        Test.startTest();
        update affiliation;
        Test.stopTest();
    }
    
    static testMethod void test_calculateAutomatedPlacementProcessFour(){
        Enrollment_Component__c  prEn=[select id,Required_to_Complete_for_Auto_Placement__c from Enrollment_Component__c Where Status__c='Complete' ];
        prEn.Required_to_Complete_for_Auto_Placement__c = true;
        update prEn;
        hed__Program_Enrollment__c progEnrollment=[select id from hed__Program_Enrollment__c Limit 1];
        Enrollment_Component_Affiliation__c ecaAffiliation=[select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c Where Status__c='Complete' LIMIT 1];
        Annual_Student_Information__c   annualStudentInformation=[select id,Grade_Level_Requested__c,AutomatedPlacementScore__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        annualStudentInformation.HowStudentPlacementCompleted__c = null;
        update annualStudentInformation;
        Enrollment_Component__c enrollmentComponent = [SELECT Id, Required_to_Complete_for_Auto_Placement__c FROM Enrollment_Component__c WHERE Name = 'enComp1' LIMIT 1];
        enrollmentComponent.Required_to_Complete_for_Auto_Placement__c = true;
        update enrollmentComponent;
        Enrollment_Component_Affiliation__c affiliation=[SELECT Id,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c
                                                         WHERE Status__c='Complete' AND Enrollment_Component__r.Required_to_Complete_for_Auto_Placement__c = true
                                                         AND Program_Enrollment__c =: progEnrollment.Id  LIMIT 1];
        affiliation.Deferral_Date__c = System.today().addDays(5);
        Test.startTest();
        update affiliation;
        Annual_Student_Information__c asiRecord = [SELECT HowStudentPlacementCompleted__c FROM Annual_Student_Information__c Where Program_Enrollment__c=:ecaAffiliation.Program_Enrollment__c];
        System.assertEquals(null,asiRecord.HowStudentPlacementCompleted__c);
        Test.stopTest();
    }
    //End
    
    static testMethod void unitTest_AutoPlacementLogic_One(){
        
        Enrollment_Component_Affiliation__c ecaAffiliation = [SELECT id,Status__c,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__r.RecordType.Name = 'Stage' LIMIT 1];
        
        Opportunity optyRecord=Peak_TestUtils.createOpportunity(ecaAffiliation.Program_Enrollment__c);
        optyRecord.StageName = 'Open';
        update optyRecord;
        
        ecaAffiliation.Status__c = 'In Progress';
        update ecaAffiliation;
        
    }
    
    static testMethod void unitTest_ValidatePhone_One(){
        NES_ECUtilities.mock = new Peak_MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, new Peak_MockHttpResponseGenerator());
        HttpResponse response = NES_ECUtilities.createHttpRequestForPhoneData('POST', 'https://api.experianmarketingservices.com/sync/queryresult/PhoneValidate/1.0/','0fef8f0d-e5d7-4f6b-a74c-8c9ad6516750', '{"Number": 5698881212,  "DefaultCountryCode": "+1"}');
        Enrollment_Component_Affiliation__c eca = [
            SELECT Id, Enrollment_Component__r.Phone_Type_Field__c, Enrollment_Component__r.Phone_Number_Validated_Field__c, Program_Enrollment__r.hed__Contact__r.AccountId,
            Program_Enrollment__r.hed__Contact__c, Program_Enrollment__c
            FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__r.Phone_Number_Validated_Field__c != null
            AND Enrollment_Component__r.Question_Type__c != null LIMIT 1];
        eca.Status__c = 'Complete';
        Test.startTest();
        update eca;
        Test.stopTest();
    }
    
    static testMethod void unitTest_ValidatePhone_Two(){
        NES_ECUtilities.mock = new Peak_MockHttpResponseGenerator();
        Test.setMock(HttpCalloutMock.class, new Peak_MockHttpResponseGenerator());
        HttpResponse response = NES_ECUtilities.createHttpRequestForPhoneData('POST', 'https://api.experianmarketingservices.com/sync/queryresult/PhoneValidate/1.0/','0fef8f0d-e5d7-4f6b-a74c-8c9ad6516750', '{"Number": 5698881212,  "DefaultCountryCode": "+1"}');
        Enrollment_Component_Affiliation__c eca = [
            SELECT Id, Enrollment_Component__r.Phone_Type_Field__c, Enrollment_Component__r.Phone_Number_Validated_Field__c, Program_Enrollment__r.hed__Contact__r.AccountId,
            Program_Enrollment__r.hed__Contact__c, Program_Enrollment__c
            FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__r.Phone_Number_Validated_Field__c != null
            AND Enrollment_Component__r.Question_Type__c != null LIMIT 1];
        eca.Status__c = 'Complete';
        update eca;
        NES_ECUtilities.GlobalPhoneInfo newInfo = new NES_ECUtilities.GlobalPhoneInfo(4271990, 'phoneType', 'certainty');
        Map<Enrollment_Component_Affiliation__c, NES_ECUtilities.GlobalPhoneInfo> newMap = new Map<Enrollment_Component_Affiliation__c, NES_ECUtilities.GlobalPhoneInfo>();
        newMap.put(eca, newInfo);
        NES_ECABusinessLogic.updateSObjects(newMap);
    }
}