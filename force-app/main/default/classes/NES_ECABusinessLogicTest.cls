/*
* Created Test Class for the task #158615 for NES_ECABusinessLogic
*/
@IsTest
public class NES_ECABusinessLogicTest {
    @TestSetup
    static void setup(){
        List<Enrollment_Component__c> enrollIDslist = new list<Enrollment_Component__c>();
        list<hed__Program_Enrollment__c> progIds = new list< hed__Program_Enrollment__c>();
        list<Enrollment_Component_Affiliation__c> ecaListIDs = new list<Enrollment_Component_Affiliation__c>();
        
        Id educationalInstitutionRecType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Account parentAccount = new Account(name = Peak_TestConstants.ACCOUNT_NAME,
                                            recordTypeId = educationalInstitutionRecType,Too_Young_Cutoff__c = System.today() //Added By Anand 1/5/2018
                                           );
        insert parentAccount;
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest1', System.today());
        
        Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account academicAccount = new Account(name = Peak_TestConstants.ACCOUNT_NAME,
                                              recordTypeId = programEnrollmentRecordTypeId,
                                              ParentId = parentAccount.Id,
                                              School_Year__c = schlYear.Id,
                                              Registration_Start_Date__c = system.Today(),
                                              Registration_End_Date__c = system.Today(),
                                              Too_Young_Cutoff__c = System.today(), //Added By Anand 1/5/2018
                                              Confirmation_End_Date__c=Datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                              Second_Semester_Confirmation_Date__c=Datetime.newInstance(2014, 9, 15, 12, 30, 0),
                                              AutomatedPlacementMaxCutoff__c = 90,
                                              School_Id__c = parentaccount.id);// check
        insert academicAccount ;// account;
        
        Contact TestContact = new Contact(firstName = Peak_TestConstants.FIRSTNAME, lastName = Peak_TestConstants.LASTNAME, email = Peak_TestConstants.STANDARD_EMAIL);
        TestContact.accountId = parentAccount.id;
        insert TestContact;      
        
        hed__Program_Enrollment__c ProgramEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, TestContact.Id, schlYear.Id, false);
        ProgramEnrollmentTest.Final_Grade_Level__c = '1';
        ProgramEnrollmentTest.SIF_SummerSchoolCourses__c='Yes';
        ProgramEnrollmentTest.SIFStudentRetained__c='yes';
        ProgramEnrollmentTest.Stress_Factors__c = 'No';
        List<String> strList=new List<String>{'Math','Science','Social Studies'};
            String opt=String.join(strList, ';');
        ProgramEnrollmentTest .SIF_AcademicSupportNeeds__c = opt;
        insert ProgramEnrollmentTest;
        
        
        hed__Program_Enrollment__c progEnrollmentTest4 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,schlYear.Id, false);
        insert progEnrollmentTest4;        
        
        //Start-added logic for the bug 119931 on 11/19/2019
        Grade_Level__c   gradeLevel = Peak_TestUtils.createGradeLevel('1', True);
        Program_Grade_Level__c  progGrades = Peak_TestUtils.createProgramGradeLevel ('Test1',academicAccount.Id ,gradeLevel.Id, System.today(), false);
        progGrades.ActivateWaitlist__c = TRUE;
        progGrades.StartWaitlist__c = System.now();
        progGrades.EndWaitlist__c = System.now().addHours(4);
        insert progGrades;
        
        
        hed__Program_Enrollment__c progEnrollmentTest2 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest2.Household_Program_Enrollment__c= progEnrollmentTest4.id;
        progEnrollmentTest2.Program_Grade_Level__c = progGrades.id;
        progEnrollmentTest2.hed__Account__c = academicAccount.id;
        progIds.add(progEnrollmentTest2);
        
        //Create Program Enrollment
        hed__Program_Enrollment__c progEnrollmentTest3 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest3.Household_Program_Enrollment__c = progEnrollmentTest4.id;
        progEnrollmentTest3.Program_Grade_Level__c = progGrades.id;
        progIds.add(progEnrollmentTest3);
        
        hed__Program_Enrollment__c progEnrollmentTest5 = Peak_TestUtils.createProgramEnrollment(academicAccount.Id,TestContact.Id,schlYear.Id, false);
        progEnrollmentTest5.Household_Program_Enrollment__c = progEnrollmentTest4.id;
        progEnrollmentTest5.Program_Grade_Level__c = progGrades.id;
        progIds.add(progEnrollmentTest5);
        
        insert  progIds;
        
        
        system.debug('progIds'+progIds);
        //Create Enrollment Component for section
        Enrollment_Component__c section1=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Section',False);
        section1.Name = 'Section1';
        section1.Component_Type__c = 'Household';
        enrollIDslist.add( section1);
        
        //Create Enrollment Component for Form
        Enrollment_Component__c Form1=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Form',False);
        Form1.Name = 'Form';
        Form1.Component_Type__c = 'Household';
        enrollIDslist.add( Form1);
        //Create Enrollment Component for Stage
        Enrollment_Component__c stage1 =Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Stage',False);
        stage1.Name = 'Stage1';
        enrollIDslist.add( stage1);
        //Create Enrollment Component for Stage
        Enrollment_Component__c stage2=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Stage',False);
        stage2.Name = 'Stage2';
        enrollIDslist.add( stage2);
        //Create Enrollment Component for Stage        
        Enrollment_Component__c stage3=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Stage',False);
        stage3.Name = 'Stage3';
        enrollIDslist.add( stage3);
        //Create Enrollment Component for process
        Enrollment_Component__c Process1=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Process',False);
        Process1.Name = 'Process1';
        //Added - April 8th
        Process1.Waitlist__c = True;
        enrollIDslist.add(Process1);
        
        Enrollment_Component__c section2=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Section',False);
        section2.Name = 'Section2';
        section2.Component_Type__c = 'Household';
        enrollIDslist.add( section2);
        
        //Create Enrollment Component for Form
        Enrollment_Component__c Form2=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Form',False);
        Form2.Name = 'Form2';
        Form2.Component_Type__c = 'Household';
        enrollIDslist.add( Form2);
        Enrollment_Component__c text=Peak_TestUtils.createEnrollmentComponent(academicAccount.Id,'Text',False);
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
        list<Enrollment_Component_Relationship__c> enrollmentComponentRelationship= new list<Enrollment_Component_Relationship__c>();
        for(integer i=0;i<=8;i++){
            Enrollment_Component_Relationship__c compRelationship = new Enrollment_Component_Relationship__c();
            compRelationship.Child_Enrollment_Component__c = enrollIDslist[i].id;
            if(i!=8) compRelationship.Parent_Enrollment_Component__c = enrollIDslist[i+1].id;
            else  compRelationship.Parent_Enrollment_Component__c = enrollIDslist[i].id;
            compRelationship.Order__c = 1;
            enrollmentComponentRelationship.add(compRelationship);
        }
       // if(enrollmentComponentRelationship.size()>0); // insert enrollmentComponentRelationship;    
        Enrollment_Document__c enrollmentDocument1 = new Enrollment_Document__c(Program_Enrollment__c = ProgramEnrollmentTest.id);
        enrollmentDocument1.Type__c = 'Immunization Records';
        enrollmentDocument1.Status_Reason__c = 'Deferred-Incomplete-Allow';
        enrollmentDocument1.Enrollment_Component_Affiliation__c = ecaListIDs[0].Id;
        insert enrollmentDocument1;
        
    }
    
    @isTest
    static void updateALLECAsTests1(){
        
        //Create Program Enrollment for House hold Program Enrollment
        List<Enrollment_Component__c> enrollIDslist = new list<Enrollment_Component__c>();
        list<hed__Program_Enrollment__c> progIds = new list< hed__Program_Enrollment__c>();
        list<Enrollment_Component_Affiliation__c> ecaListIDs = new list<Enrollment_Component_Affiliation__c>();
        
        boolean updateFlag = true;
        
        
        map<id,id> ecaMap = new map<id,id>();
        list<Enrollment_Component_Affiliation__c> ecaList = new list<Enrollment_Component_Affiliation__c>();
        //Fetch ECA's related EC component
        for( Enrollment_Component_Affiliation__c  ecaAffiliation : [select id,Status__c,Program_Enrollment__c,Enrollment_Component__c from Enrollment_Component_Affiliation__c 
                                                                    Where Status__c='Complete' or status__C ='Not Started']){                                                                       
                                                                        ecaAffiliation.Status__c = 'In Progress';
                                                                        ecaList.add(ecaAffiliation);
                                                                        ecaMap.put(ecaAffiliation.Enrollment_Component__c, ecaAffiliation.Program_Enrollment__c);  
                                                                    }
        test.starttest();
        
        update ecaList;
       
        Test.StopTest(); 
        
    }  
    
}