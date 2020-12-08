/*
* Created Test Class for the task #158615 for NES_ECABusinessLogic
*/
@IsTest
public class NES_ECABusinessLogicTest {
    @TestSetup
    static void setup(){
        
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
        // Test Setup for US#227705 by Krishna Peddanagammol on 2020-09-23 
        Enrollment_Component_Affiliation__c affiliation5 =Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id,enComp4.Id,false);
        affiliation5.Status__c = 'Deferred';
        afflist.add(affiliation5);
        Enrollment_Component_Affiliation__c phoneAffiliation = Peak_TestUtils.createEnrollmentComponentAffiliation(ProgramEnrollmentTest.Id, validatePhoneEnrollmentComponent.Id ,false);
        afflist.add(phoneAffiliation);
        insert afflist;
        
        Opportunity optyRecord=Peak_TestUtils.createOpportunity(ProgramEnrollmentTest.Id);
        optyRecord.WaitList_Added_Time__c=System.now();
        update optyRecord;
        
        Records_Request__c recordsRequest = Peak_TestUtils.createRecordsRequest('Test RR',ProgramEnrollmentTest.Id,true);
        Map<Id, Enrollment_Component_Affiliation__c> ecaAffiliationMap=new Map<Id,Enrollment_Component_Affiliation__c>([SELECT Id,Status__c,Program_Enrollment__c,Enrollment_Component__c FROM Enrollment_Component_Affiliation__c WHERE Status__c = 'Complete'  AND Enrollment_Component__r.RecordType.Name = 'Question']);
        NES_ECABusinessLogic.validatePhone(new List<Id>(ecaAffiliationMap.keySet()));
        
        Enrollment_Document__c enrollmentDocument1 = Peak_TestUtils.createEnrollmentDocumentRecord(ProgramEnrollmentTest.id);
        enrollmentDocument1.Type__c = 'Immunization Records';
        enrollmentDocument1.Status_Reason__c = 'Deferred-Non-compliant Allow';
        enrollmentDocument1.Enrollment_Component_Affiliation__c = affiliation5.Id;
        upsert enrollmentDocument1;
        
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
    }
    
    @isTest
    static void updateALLECAsTests1(){
        
        //Create Program Enrollment for House hold Program Enrollment
        List<Enrollment_Component__c> enrollIDslist = new list<Enrollment_Component__c>();
        list<hed__Program_Enrollment__c> progIds = new list< hed__Program_Enrollment__c>();
        list<Enrollment_Component_Affiliation__c> ecaListIDs = new list<Enrollment_Component_Affiliation__c>();
        
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
        
        Test.StartTest();
        
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
        //Added - April 8th
        Process1.Waitlist__c = True;
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
        
        if (progIds[2].id != null && enrollIDslist[6].name == 'Section2'){
            //Create ECA for section for PE2
            Enrollment_Component_Affiliation__c ECAsectionName=Peak_TestUtils.createEnrollmentComponentAffiliation(progIds[2].Id,enrollIDslist[6].id,False);
            ECAsectionName.Order__c = 1;
            ECAsectionName.Status__c = 'Not Started';
            insert ECAsectionName;
            
        }
        
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
        //Start test
        List<Enrollment_Component_Affiliation__c> updateStageList = new List<Enrollment_Component_Affiliation__c>();
        for(Enrollment_Component_Affiliation__c eca : [Select Id, Status__c from Enrollment_Component_Affiliation__c where Status__c = 'Not Started']){
            eca.Status__c = 'In Progress';
            updateStageList.add(eca);
        }
        update updateStageList;
        // End test
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
        
        //Start - US169322 by jagadeesh bokam
        //Fetch Enrollment Component for 'Stage1'
        Enrollment_Component__c  prEn1=[select id from Enrollment_Component__c Where NAME = 'Stage1' limit 1];
        System.debug('prEn1.id'+prEn1.id);
        map<id,id> ecaMap1 = new map<id,id>();
        list<Enrollment_Component_Affiliation__c> ecaList1 = new list<Enrollment_Component_Affiliation__c>();
        //Fetch ECA's related EC component
        for( Enrollment_Component_Affiliation__c  ecaAffiliation1 : [select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c 
                                                                     Where Status__c='Complete' and Enrollment_Component__c =:prEn.id]){
                                                                         ecaAffiliation1.Status__c='In Progress';
                                                                         ecaList1.add(ecaAffiliation1);
                                                                         
                                                                     }
        
        update ecaList1;
        
        //End - US169322 by jagadeesh bokam
        Test.StopTest(); 
        
    } 
    // Test method for US#227705 by Krishna Peddanagammol on 2020-09-23
    @isTest
    static void runECACompletionForNAStatusTest(){
        
        List<Enrollment_Component_Affiliation__c> updateSectionECAs = new List<Enrollment_Component_Affiliation__c>();
        List<Enrollment_Document__c> updateED = new List<Enrollment_Document__c>();
        List<hed__Program_Enrollment__c> progEnrollmentTest = new List<hed__Program_Enrollment__c>();
        progEnrollmentTest = [SELECT Id FROM hed__Program_Enrollment__c LIMIT 1];
        Test.startTest();
            updateED = [Select Id, Type__c, Status_Reason__c, Enrollment_Component_Affiliation__c FROM Enrollment_Document__c 
                        WHERE Program_Enrollment__c =: progEnrollmentTest[0].Id LIMIT 1];
            updateED[0].Status_Reason__c = 'Deferred-Incomplete-Allow';
            update updateED;
            
            updateSectionECAs= [Select Id, Status__c, Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c, Enrollment_Component__c 
                                from Enrollment_Component_Affiliation__c where Id =: updateED[0].Enrollment_Component_Affiliation__c LIMIT 1];
            updateSectionECAs[0].Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c = false;                                                           
            update updateSectionECAs;
            List<Enrollment_Component_Affiliation__c> updateSectionECA2 = new List<Enrollment_Component_Affiliation__c>();
        	updateSectionECA2 = [Select Id, Status__c, Program_Enrollment__r.hed__Account__r.Use_Updated_ECA_Process__c, Enrollment_Component__c 
                                 from Enrollment_Component_Affiliation__c where Id =: updateSectionECAs[0].Id LIMIT 1];
        	System.assertEquals('Deferred', updateSectionECA2[0].Status__c);            
        Test.stopTest();		      
    }    
}