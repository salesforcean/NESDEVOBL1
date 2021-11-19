/*
* Created by: Anitha P for User Story 108910 for the Task 109581
* Created date: 2019-09-13
* Purpose: Additional test class for NES_AnnualStudentInfoUtilities
*/

@isTest(SeeAllData=false isParallel=false)
private class NES_AnnualStudentInfoUtilities2Test {

    @TestSetup
    static void setup() {
       // Create account
        Account account = Peak_TestUtils.createTestAccount();
        //Create SchoolYear
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());
        schlYear.Start_Date__c = Date.parse('12/09/19');
        schlYear.End_Date__c = Date.parse('12/09/20');
        update schlYear;
       //Create Recordtype
        recordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];
        //Update account with Record type
        Account parentAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Account academicAccount = Peak_TestUtils.createAccountForNewStudentData(parentAccount.Id, schlYear.Id);
        academicAccount.recordtypeid = rtypes.id;
        academicAccount.Confirmation_End_Date__c=Datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.Second_Semester_Confirmation_Date__c=Datetime.newInstance(2014, 9, 15, 12, 30, 0);
        academicAccount.AutomatedPlacementMaxCutoff__c = 90;
        update academicAccount;

        List<Enrollment_Component__c> componentList = new List <Enrollment_Component__c>();
        Enrollment_Component__c processComponent = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        //processComponent.Assignment_Logic__c = '1';
        processComponent.Document_Type__c = 'Report Card';
        //processComponent.Required_to_Complete_for_Auto_Placement__c = true;
        Enrollment_Component__c processComponent2 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent2.Assignment_Logic__c = '1';
        processComponent2.Document_Type__c = 'Individualized Education Program';
        Enrollment_Component__c processComponent3 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent3.Assignment_Logic__c = '1';
        processComponent3.Document_Type__c = 'Evaluation';
        Enrollment_Component__c processComponent4 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent4.Assignment_Logic__c = '1';
        processComponent4.Document_Type__c = 'IEP Exit Documentation';
        Enrollment_Component__c processComponent5 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent5.Assignment_Logic__c = '1';
        processComponent5.Document_Type__c = 'Home School Prior Academic History';
        Enrollment_Component__c processComponent6 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent6.Assignment_Logic__c = '1';
        processComponent6.Document_Type__c = 'Unofficial Transcript';
        Enrollment_Component__c processComponent7 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent7.Assignment_Logic__c = '1';
        processComponent7.Document_Type__c = 'Gifted Documentation';
        Enrollment_Component__c processComponent8 = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Document', false);
        processComponent8.Assignment_Logic__c = '1';
        processComponent8.Document_Type__c = 'State Test Scores';
        Enrollment_Component__c stageComponent = Peak_TestUtils.createEnrollmentComponent(academicAccount.Id, 'Stage', false);
        stageComponent.Required_to_Complete_for_Auto_Placement__c = true;

        componentList.add(processComponent);
        componentList.add(processComponent2);
        componentList.add(processComponent3);
        componentList.add(processComponent4);
        componentList.add(processComponent5);
        componentList.add(processComponent6);
        componentList.add(processComponent7);
        componentList.add(processComponent8);
        componentList.add(stageComponent);
        insert componentList;

        //Create Contact
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018', date.parse('11/17/2017'));
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018')); 
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
        // Create Program Enrollment Record
        list<hed__Program_Enrollment__c> peList = new List<hed__Program_Enrollment__c>();
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c = previousSchoolYear.Id;
        progEnrollment1.MoreHighSchoolDocumentation__c =  null;
        progEnrollment1.CreditByExamScores__c = 'Verified';
        progEnrollment1.HomeSchoolEvaluatorReport__c = 'Verified';
        progEnrollment1.PlacementFlag__c  = 'Counselor Review';
        progEnrollment1.hed__Account__c  = academicAccount.Id;
        progEnrollment1.Status__c  = 'In Progress';
        progEnrollment1.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment1);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment2 = new hed__Program_Enrollment__c();
        progEnrollment2.Start_Year__c = currentSchoolYear.Id;
        progEnrollment2.PlacementFlag__c  = 'Pending Assessment';
        progEnrollment2.Status__c = 'In Progress';
        progEnrollment2.hed__Account__c  = academicAccount.Id;
        progEnrollment2.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment2);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment3 = new hed__Program_Enrollment__c();
        progEnrollment3.Start_Year__c = currentSchoolYear.Id;
        progEnrollment3.PlacementFlag__c  = 'Pending Assessment';
        progEnrollment3.CohortEligibility__c ='Ineligible' ;   
        progEnrollment3.hed__Account__c  = academicAccount.Id; 
        progEnrollment3.Status__c = 'In Progress';
        progEnrollment3.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment3);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment4 = new hed__Program_Enrollment__c();
        progEnrollment4.Start_Year__c = currentSchoolYear.Id;
        progEnrollment4.PlacementFlag__c  = 'Pending Assessment';
        progEnrollment4.CohortEligibility__c = 'Pending Review';    
        progEnrollment4.hed__Account__c  = academicAccount.Id;
        progEnrollment4.Status__c = 'In Progress';
        progEnrollment4.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment4);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment5 = new hed__Program_Enrollment__c();
        progEnrollment5.Start_Year__c = currentSchoolYear.Id;
        progEnrollment5.PlacementFlag__c  = 'Pending Assessment';
        progEnrollment5.CohortEligibility__c = 'Pending';    
        progEnrollment5.hed__Account__c  = academicAccount.Id;
        progEnrollment5.Status__c = 'In Progress';
        progEnrollment5.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment5);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment6 = new hed__Program_Enrollment__c();
        progEnrollment6.Start_Year__c = currentSchoolYear.Id;
        progEnrollment6.PlacementFlag__c  = 'Awaiting Communication- More Info';
        progEnrollment6.hed__Account__c  = academicAccount.Id;
        progEnrollment6.Status__c = 'In Progress';
        progEnrollment6.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment6);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment7 = new hed__Program_Enrollment__c();
        progEnrollment7.Start_Year__c = currentSchoolYear.Id;
        progEnrollment7.EnrollmentSpecialistContactReq__c = 'Pending Review';    
        progEnrollment7.hed__Account__c  = academicAccount.Id;
        progEnrollment7.Status__c = 'In Progress';
        progEnrollment7.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment7);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment8 = new hed__Program_Enrollment__c();
        progEnrollment8.Start_Year__c = currentSchoolYear.Id;
        progEnrollment8.PlacementFlag__c  = 'Awaiting Communication- School Counselor';
        progEnrollment8.hed__Account__c  = academicAccount.Id;
        progEnrollment8.Status__c = 'In Progress';
        progEnrollment8.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment8);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment9 = new hed__Program_Enrollment__c();
        progEnrollment9.Start_Year__c = currentSchoolYear.Id;
        progEnrollment9.HomelessRiskFlag__c = 'Potential Homeless';
        progEnrollment9.PlacementFlag__c  = 'Principal Review';
        progEnrollment9.hed__Account__c  = academicAccount.Id;
        progEnrollment9.Status__c = 'In Progress';
        progEnrollment9.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment9);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment10 = new hed__Program_Enrollment__c();
        progEnrollment10.Start_Year__c = currentSchoolYear.Id;
        progEnrollment10.PlacementFlag__c  = 'Pending Assessment';
        progEnrollment10.Status__c = 'In Progress';
        progEnrollment10.hed__Account__c = academicAccount.id ;
        progEnrollment10.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment10);
        //Create Program Enrollment Record



        hed__Program_Enrollment__c progEnrollment11 = new hed__Program_Enrollment__c();
        progEnrollment11.Start_Year__c = currentSchoolYear.Id;
        progEnrollment11.PlacementFlag__c  = 'Special Education Director';
        progEnrollment11.Status__c = 'In Progress';
        progEnrollment11.hed__Account__c  = academicAccount.Id;
        progEnrollment11.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment11);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment12 = new hed__Program_Enrollment__c();
        progEnrollment12.Start_Year__c = currentSchoolYear.Id;
        progEnrollment12.PlacementFlag__c  = 'RC/PAH Not Uploaded';
        progEnrollment12.hed__Account__c  = academicAccount.Id;
        progEnrollment12.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment12.Status__c  = 'In Progress';
        peList.add(progEnrollment12);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment13 = new hed__Program_Enrollment__c();
        progEnrollment13.Start_Year__c = currentSchoolYear.Id;
        progEnrollment13.hed__Account__c  = academicAccount.Id;
        progEnrollment13.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment13.Status__c  = 'In Progress';
        peList.add(progEnrollment13);
        //Create Program Enrollment Record
        hed__Program_Enrollment__c progEnrollment14 = new hed__Program_Enrollment__c();
        progEnrollment14.Start_Year__c = currentSchoolYear.Id;
        progEnrollment14.PlacementFlag__c = 'Academic Placement Advisor' ;
        progEnrollment14.MoreHighSchoolDocumentation__c = 'Documentation needed';
        progEnrollment14.HomeSchoolEvaluatorReport__c = 'Received';
        progEnrollment14.hed__Account__c  = academicAccount.Id;
        progEnrollment14.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        progEnrollment14.Status__c  = 'In Progress';
        peList.add(progEnrollment14);
        //Create program enrollment
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicAccount.Id, Contact.Id,schlYear.Id, false);
        progEnrollment.Start_Year__c =schlYear.Id;
        progEnrollment.GradeLevelEligibility__c = '';
        progEnrollment.PriorSchoolAttendanceElg__c = '';
        progEnrollment.HomeschoolMembershipElg__c = '';
        progEnrollment.AcademicPerformanceEligibility__c = '';
        progEnrollment.CohortEligibility__c = '';
        progEnrollment.WhyFlagged__c = '';
        progEnrollment.PlacementFlag__c = 'Principal Review';
        progEnrollment.EnrollmentSpecialistContactReq__c = '';
        progEnrollment.MoreHighSchoolDocumentation__c = '';
        progEnrollment.CreditByExamScores__c = '';
        progEnrollment.HomeSchoolEvaluatorReport__c = '';
        progEnrollment.hed__Account__c  = academicAccount.Id;
        progEnrollment.Status__c  = 'In Progress';
        progEnrollment.EntranceAgeEligibilitySystem__c = 'Eligible' ;
        peList.add(progEnrollment); 
        insert pelist;
     
        //Create Special education record   
        list<Special_Education__c> specialEducationslist = new list<Special_Education__c> ();
        Special_Education__c specialEducations = Peak_TestUtils.createSpecialEducation(progEnrollment2.Id,false);
        specialEducations.IEP__c = 'IEP-Withdrawn';
        specialEducationslist.add(specialEducations);
        Special_Education__c specialEducations1 = Peak_TestUtils.createSpecialEducation(progEnrollment11.Id,false);
        specialEducations1.IEP__c = 'Documenting';
        specialEducationslist.add(specialEducations1);
        Special_Education__c specialEducations2 = Peak_TestUtils.createSpecialEducation(progEnrollment1.Id,false);
        specialEducations2.IEP__c = 'IEP';
        specialEducationslist.add(specialEducations2);
        Special_Education__c specialEducations3 = Peak_TestUtils.createSpecialEducation(progEnrollment14.Id,false);
        specialEducations3.IEP__c = 'Documenting';
        specialEducationslist.add(specialEducations3);
        insert specialEducationslist;
        
       //Create Enrollment Document
       list<Enrollment_Document__c> enrollmntDocList = new list<Enrollment_Document__c> ();
        Enrollment_Document__c enrollmntDoc  = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment11.Id,'Gifted Documentation','Submitted',false);
        enrollmntDocList.add(enrollmntDoc);
        Enrollment_Document__c enrollmntDoc2 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment11.Id,'IEP Exit Documentation','Submitted',false); 
        enrollmntDocList.add(enrollmntDoc2); 
        Enrollment_Document__c enrollmntDoc3 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment11.Id,'Report Card','Submitted',false); 
        enrollmntDocList.add(enrollmntDoc3);
        Enrollment_Document__c enrollmntDoc5 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment11.Id,'Home School Prior Academic History','Submitted',false); 
        enrollmntDocList.add(enrollmntDoc5);
        Enrollment_Document__c enrollmntDoc6 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment11.Id,'Unofficial Transcript','Submitted',false); 
        enrollmntDocList.add(enrollmntDoc6);
        Enrollment_Document__c enrollmntDoc7 = Peak_TestUtils.createEnrollmentDocumentRecord(progEnrollment11.Id,'State Test Scores','Submitted',false); 
        enrollmntDocList.add(enrollmntDoc7);
        insert enrollmntDocList;
     
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI = new Annual_Student_Information__c();
        currentASI.Final_Grade_Level__c = '1';
        currentASI.Program_Enrollment__c = pelist[0].id;
        currentASI.name = 'Previous ASI1';
        currentASI.HowStudentPlacementCompleted__c = '';
        currentASI.AutomatedPlacementScore__c = null;
        currentASI.AutomatedPlacementExclude__c = false;
        currentASI.Academic_Documentation_Summary__c = '';
        currentASI.Science_Placement_Level__c = '';
        currentASI.LA_Placement_Level__c = '';
        currentASI.Math_Placement_Level__c = '';      
        currentASI.Grade_Level_Requested__c = '11';
        currentASI.CoursesFinalized__c = '';
        currentASI.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI.School_Year__c = previousSchoolYear.Id;
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        asiIdList.add(currentASI);  
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI1 = new Annual_Student_Information__c();
        currentASI1.Program_Enrollment__c = pelist[1].id;
        currentASI1.name = 'Previous ASI3';
        currentASI1.Grade_Level_Requested__c = '11';
        currentASI1.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI1.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI1);
        //Create Annual Student Information Record for previous school year
        Annual_Student_Information__c currentASI2 = new Annual_Student_Information__c();
        currentASI2.Program_Enrollment__c = pelist[1].id;
        currentASI2.name = 'Previous ASI2';
        currentASI2.Grade_Level_Completed__c = '11';
        currentASI2.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI2.School_Year__c = previousSchoolYear.Id;
        asiIdList.add(currentASI2);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI3 = new Annual_Student_Information__c();
        currentASI3.Program_Enrollment__c = pelist[2].id;
        currentASI3.name = 'Previous ASI4';
        currentASI3.Grade_Level_Completed__c = '11';
        currentASI3.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI3.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI3);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI4 = new Annual_Student_Information__c();
        currentASI4.Program_Enrollment__c = pelist[3].id;
        currentASI4.name = 'Previous ASI5';
        currentASI4.Grade_Level_Completed__c = '11';
        currentASI4.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI4.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI4);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI5 = new Annual_Student_Information__c();
        currentASI5.Program_Enrollment__c = pelist[4].id;
        currentASI5.name = 'Previous ASI6';
        currentASI5.Grade_Level_Completed__c = '11';
        currentASI5.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI5.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI5);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI6 = new Annual_Student_Information__c();
        currentASI6.Program_Enrollment__c = pelist[5].id;
        currentASI6.name = 'Previous ASI7';
        currentASI6.Grade_Level_Completed__c = '11';
        currentASI6.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI6.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI6);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI7 = new Annual_Student_Information__c();
        currentASI7.Program_Enrollment__c = pelist[6].id;
        currentASI7.name = 'Previous ASI8';
        currentASI7.Grade_Level_Completed__c = '11';
        currentASI7.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI7.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI7);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI8 = new Annual_Student_Information__c();
        currentASI8.Program_Enrollment__c = pelist[7].id;
        currentASI8.name = 'Previous ASI9';
        currentASI8.Grade_Level_Completed__c = '11';
        currentASI8.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI8.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI8);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI9 = new Annual_Student_Information__c();
        currentASI9.Program_Enrollment__c = pelist[8].id;
        currentASI9.name = 'Previous ASI10';
        currentASI9.Grade_Level_Completed__c = '11';
        currentASI9.Academic_Documentation_Summary__c = 'Not Applicable';
        currentASI9.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI9);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI10 = new Annual_Student_Information__c();
        currentASI10.Program_Enrollment__c = pelist[1].id;
        currentASI10.name = 'Previous ASI11';
        currentASI10.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        currentASI10.Final_Grade_Level__c = 'K';
        currentASI10.CoursesFinalized__c = 'Yes';
        currentASI10.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI10);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI12 = new Annual_Student_Information__c();
        currentASI12.Program_Enrollment__c = pelist[1].id;
        currentASI12.name = 'Previous ASI12';
        currentASI12.Final_Grade_Level__c = 'K';
        currentASI12.CoursesFinalized__c = 'Yes';
        currentASI12.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI12);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI13 = new Annual_Student_Information__c();
        currentASI13.Program_Enrollment__c = pelist[1].id;
        currentASI13.name = 'Previous ASI13';
        currentASI13.Final_Grade_Level__c = '12';
        currentASI13.CoursesFinalized__c = 'Yes';
        currentASI13.HowStudentPlacementCompleted__c = 'Modified Auto-Placement Process';
        currentASI13.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI13);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI14 = new Annual_Student_Information__c();
        currentASI14.Program_Enrollment__c = pelist[1].id;
        currentASI14.name = 'Previous ASI14';
        currentASI14.Final_Grade_Level__c = '12';
        currentASI14.CoursesFinalized__c = 'Yes';
        currentASI14.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI14);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI15 = new Annual_Student_Information__c();
        currentASI15.Program_Enrollment__c = pelist[9].id;
        currentASI15.name = 'Previous ASI15';
        currentASI15.AutomatedPlacementScore__c = 2;
        currentASI15.AutomatedPlacementExclude__c = false;
        currentASI15.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI15);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI16 = new Annual_Student_Information__c();
        currentASI16.Program_Enrollment__c = pelist[10].id;
        currentASI16.name = 'Previous ASI16';
        currentASI16.Grade_Level_Requested__c = '12' ;
        currentASI16.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI16);
        //Create Annual Student Information Record                                                                                     
        Annual_Student_Information__c currentASI17 = new Annual_Student_Information__c();
        currentASI17.Program_Enrollment__c = pelist[10].id;
        currentASI17.name = 'Previous ASI17';
        currentASI17.Grade_Level_Completed__c = 'None- entering kindergarten for the first time.';
        currentASI17.School_Year__c = previousSchoolYear.Id;
        asiIdList.add(currentASI17);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI18 = new Annual_Student_Information__c();
        currentASI18.Program_Enrollment__c = pelist[11].id;
        currentASI18.name = 'Previous ASI18';
        currentASI18.Grade_Level_Requested__c = 'K' ;
        currentASI18.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI18);
        //Create Annual Student Information Record
        Annual_Student_Information__c currentASI20 = new Annual_Student_Information__c();
        currentASI20.Program_Enrollment__c = pelist[13].id;
        currentASI20.name = 'Previous ASI20';
        currentASI20.Grade_Level_Requested__c = 'K' ;
        currentASI20.Final_Grade_Level__c = '12';
        currentASI20.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI20);
        //Create Annual Student Information Record                                                                                  
        Annual_Student_Information__c currentASI19 = new Annual_Student_Information__c();
        currentASI19.Program_Enrollment__c = pelist[12].id;
        currentASI19.name = 'Previous ASI19';
        currentASI19.School_Year__c = currentSchoolYear.Id;
        asiIdList.add(currentASI19);
        insert asiIdList;
        
    }
    
    //test method for PlacementBucket value Eligibility- Ineligible
    static testMethod void studentPlacementBucketEligibilityIneligibleTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
       //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI4'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI4'];
        Test.stopTest();
        system.assertEquals('Eligibility- Ineligible', asi.StudentPlacementBucket__c);
        
    }
     //test method for PlacementBucket value Eligibility- Pending Review
    static testMethod void studentPlacementBucketEligibilityPendingReviewTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI5'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI5'];
        Test.stopTest();
        system.assertEquals('Eligibility- Pending Review', asi.StudentPlacementBucket__c);
        }
    //test method for PlacementBucket value Eligibility- Pending
    static testMethod void studentPlacementBucketEligibilityPendingTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI6'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI6'];
        Test.stopTest();
        system.assertEquals('Eligibility- Pending', asi.StudentPlacementBucket__c);
        
    }
     //test method for PlacementBucket value Parent - Call APS
    static testMethod void studentPlacementBucketParentCallAPSTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI7'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI7'];
        Test.stopTest();
        system.assertEquals('Parent - Call APS', asi.StudentPlacementBucket__c);  
    }
     //test method for PlacementBucket value Parent - Enrollment Specialist
    static testMethod void studentPlacementBucketParentEnrollmentSpecialistTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI8'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI8'];
        Test.stopTest();
        system.assertEquals('Parent - Enrollment Specialist', asi.StudentPlacementBucket__c);
        
    }
    //test method for PlacementBucket value Parent - School Counselor
     static testMethod void studentPlacementBucketParentSchoolCounselorTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI9'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI9'];
        Test.stopTest();
        system.assertEquals('Parent - School Counselor', asi.StudentPlacementBucket__c);
        
    }
    //test method for PlacementBucket value Principal
    static testMethod void studentPlacementBucketParentPrincipalTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI10'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI10'];
        Test.stopTest();
        system.assertEquals('Principal', asi.StudentPlacementBucket__c);
    }
    //test method for PlacementBucket value Placed - Auto Placed K8
    static testMethod void studentPlacementBucketPlacedAutoPlacedK8Test() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI11'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI11'];
        Test.stopTest();
        system.assertEquals('Placed - Auto Placed K8', asi.StudentPlacementBucket__c);
    }
    
    //test method for PlacementBucket value Placed - K8
    static testMethod void studentPlacementBucketPlacedK8Test() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI12'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI12'];
        Test.stopTest();
        system.assertEquals('Placed - K8', asi.StudentPlacementBucket__c);  
    }
    //test method for PlacementBucket value Placed – Auto Placed High School
    //Mark Membrino - 10/12/2019  per Feature 101473, this is no long a bucket we are using.
   /* static testMethod void studentPlacementBucketPlacedAutoPlacedHighSchoolTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI13'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI13'];
        Test.stopTest();
        system.assertEquals('Placed – Auto Placed High School', asi.StudentPlacementBucket__c);
    } */
     //test method for PlacementBucket value Placed – High School
    static testMethod void studentPlacementBucketPlacedHighSchoolTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI14'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI14'];
        Test.stopTest();
        system.assertEquals('Placed – High School', asi.StudentPlacementBucket__c);
    }
     //test method for PlacementBucket value Placement - Auto-Placement in Progress
    static testMethod void studentPlacementBucketPlacementAutoPlacementinProgressTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI15'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI15'];
        Test.stopTest();
       system.assertEquals('Placement - Auto-Placement in Progress', asi.StudentPlacementBucket__c);  
    }
    //test method for Student placement buckent value 'Parent' 
    static testMethod void studentPlacementBucketParentTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        asiIdList.add(asirecord);   

        List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component__c enrollComp : [SELECT Id,Document_Type__c FROM Enrollment_Component__c ])
        { 
            Enrollment_Component_Affiliation__c eca = Peak_TestUtils.createEnrollmentComponentAffiliation(asirecord.Program_Enrollment__c, enrollComp.Id, false);
            ecaList.add(eca);
        }
        
        insert ecaList;

        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Test.stopTest();
        //Fetch Annual student information and compare values 
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        system.assertEquals('Parent', Asi.StudentPlacementBucket__c);
        
    }

    static testMethod void studentPlacementBucketParent2Test() {
        //Mark the report card as having been recieved, now it should to the next bucket.  Also confirm that updating the document
        //sends it back to the parent bucket.

        NES_LogicFeatureSwitch__c  logicSwitch = Peak_TestUtils.createNESBusinessLogicSwitch('EnrollmentDocTrigger', true);

        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        asiIdList.add(asirecord);   

        //Find the enrollment component for the Report Card.
        Enrollment_Component__c enrollComp = [SELECT Id FROM Enrollment_Component__c WHERE Document_Type__c = 'Report Card']; 
        enrollComp.Required_to_Complete_for_Auto_Placement__c = true;
        update enrollComp;

        //Tie this Program enrollement to the report card enrollment component.
        Enrollment_Component_Affiliation__c eca1 = Peak_TestUtils.createEnrollmentComponentAffiliation(asirecord.Program_Enrollment__c, enrollComp.Id, false);
        insert eca1;

        //Find the Report Card Enrollment Document and tie it to the ECA we just created and mark it as recieved.
        Enrollment_Document__c enrollmntDoc = [select ID from Enrollment_Document__c where type__c = 'Report Card'];
        enrollmntDoc.Status_Reason__c = 'Received';
        enrollmntDoc.Enrollment_Component_Affiliation__c = eca1.Id;
        update enrollmntDoc;

        //Force the bucket calculation and confirm that is NOT be set to the parent because the report card is required
        //but has been Recieved.
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        system.assertEquals('Special Education Director', Asi.StudentPlacementBucket__c);

        Test.startTest();

        //If the enrollment doc is updated, it should go back to the parent.
        enrollmntDoc.Status_Reason__c = 'Submitted';
        update enrollmntDoc;
        eca1.Status__c = 'Complete';
        update eca1;

        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);

        Test.stopTest();

        //Fetch Annual student information and compare values 
        Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        system.assertEquals('Parent', Asi.StudentPlacementBucket__c);
        
    }

    static testMethod void studentPlacementBucketParent3Test() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        asiIdList.add(asirecord);   

        //Add a bunch of enrollment component affiliations
        List<Enrollment_Component_Affiliation__c> ecaList = new List<Enrollment_Component_Affiliation__c>();

        for (Enrollment_Component__c enrollComp : [SELECT Id,Document_Type__c FROM Enrollment_Component__c where recordtype.name = 'Document'])
        { 
            Enrollment_Component_Affiliation__c eca = Peak_TestUtils.createEnrollmentComponentAffiliation(asirecord.Program_Enrollment__c, enrollComp.Id, false);
            ecaList.add(eca);
        }
        insert ecaList;

        //For each of the enrollment component affiliations, give them a document that is recieved.
        for (Enrollment_Component_Affiliation__c eca : [select Id, Enrollment_Component__r.Document_Type__c from Enrollment_Component_Affiliation__c where Enrollment_Component__r.recordtype.name = 'Document'])
        {
            list<Enrollment_Document__c> enrollmntDoc = [select ID from Enrollment_Document__c where  type__c = :eca.Enrollment_Component__r.Document_Type__c];
            if (enrollmntDoc.size() > 0) {
                enrollmntDoc[0].Status_Reason__c = 'Verified';
                enrollmntDoc[0].Enrollment_Component_Affiliation__c = eca.Id;
                update enrollmntDoc[0];
            }
        }

        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Test.stopTest();
        //Fetch Annual student information and compare values 
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        system.assertEquals('Parent', Asi.StudentPlacementBucket__c);
        
    }
    //test method for Student placement buckent value 'Special Education Director' 
    static testMethod void studentPlacementBucketSpecialEducationDirectorTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        asiIdList.add(asirecord);   
        //Enrollment_Document__c enrollmntDoc = [select ID from Enrollment_Document__c where type__c = 'Individualized Education Program'];
        //enrollmntDoc.Status_Reason__c = 'Received-No Documentation Available';
        //update enrollmntDoc;
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Test.stopTest();
        //Fetch Annual student information and compare values 
        Annual_Student_Information__c Asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI16'];
        system.assertEquals('Special Education Director', Asi.StudentPlacementBucket__c);
    }
     //test method for Student placement buckent value 'School Counselor'    
    static testMethod void studentPlacementBucketSchoolCounselorTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI1'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI1'];
        Test.stopTest();
        system.assertEquals('School Counselor', asi.StudentPlacementBucket__c);
        
    }
     //test method for Student placement buckent value 'Enrollment - RC/PAH Not Uploaded' 
     //Mark Membrino - 10/12/2019  per Feature 101473, this is no long a bucket we are using.
     /*
     static testMethod void studentPlacementBucketRCPAHNotUploadedTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI18'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI18'];
        Test.stopTest();
        system.assertEquals('Enrollment - RC/PAH Not Uploaded', asi.StudentPlacementBucket__c);
        
    } */
    //test method for Student placement buckent value Placement
       static testMethod void studentPlacementBucketPlacementTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI20'];
        asiIdList.add(asirecord);   
        // Enrollment_Document__c enrollmntDoc = [select ID from Enrollment_Document__c where type__c = 'IEP Exit Documentation'];
        //enrollmntDoc.Status_Reason__c = 'Reviewed-Incomplete';
        //update enrollmntDoc;
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI20'];
        Test.stopTest();
        system.assertEquals('Placement', asi.StudentPlacementBucket__c);
        
    }
     //test method for Student placement buckent value BROKEN
        static testMethod void studentPlacementBucketBROKENTest() {
        List<Annual_Student_Information__c> asiIdList = new List<Annual_Student_Information__c>();
        //Calling method to calculate Placement Bucket Field
        Test.startTest();
        Annual_Student_Information__c asirecord = [SELECT Id,Program_Enrollment__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI19'];
        asiIdList.add(asirecord);   
        NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(asiIdList, true);
        Annual_Student_Information__c asi = [SELECT Id,StudentPlacementBucket__c FROM Annual_Student_Information__c WHERE Name = 'Previous ASI19'];
        Test.stopTest();
        system.assertEquals('BROKEN', asi.StudentPlacementBucket__c);
        
    }
     //test method for calculateAutomatedPlacementExclude logic
     static testMethod void calculateAutomatedPlacementExclude1(){
         Set<Id> peIdsSet = new Set<Id>();
        School_Year__c currentYear = [SELECT Id FROM School_Year__c WHERE Name = 'SchoolTest'];
        hed__Program_Enrollment__c currentProgramEnrollment = [SELECT Id,EntranceAgeEligibilityFinal__c,Final_Grade_Level__c, hed__Account__r.AutomatedPlacementExclude__c, hed__Account__c, Start_Year__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Start_Year__c =: currentYear.Id];
        //Update Account
        Account acc = [SELECT Id, Name FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__r.ParentId];
        acc.Name = 'NMCA';
        update acc;

        Account eduAcc = [SELECT Id FROM Account where Id =:currentProgramEnrollment.hed__Account__c];
        eduAcc.AutomatedPlacementExclude__c = true;
        update eduAcc;
        //Create Special education for PE
        List<Special_Education__c> educationList = new List<Special_Education__c>();
        Special_Education__c education1 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education1.IEP__c = 'Documenting';
        educationList.add(education1);
         //Create Special education for PE
        Special_Education__c education2 = Peak_TestUtils.createSpecialEducation(currentProgramEnrollment.Id,false);
        education2.IEP__c = 'Documenting';
        educationList.add(education2);
        insert educationList;
         //Create Enrollment Document for PE
        Enrollment_Document__c enrollmentDocument = Peak_TestUtils.createEnrollmentDocumentRecord(currentProgramEnrollment.Id,'Individualized Education Program','Verified',false);
        enrollmentDocument.Type__c = 'IEP Exit Documentation';
        enrollmentDocument.Status_Reason__c = 'Requested';
        insert enrollmentDocument;
         //Create grade level for PE
        Grade_Level__c gradeLevel = Peak_TestUtils.createGradeLevel('3', true);
        Account academicProgramAccount = [SELECT Id FROM Account WHERE Id =: currentProgramEnrollment.hed__Account__c];
        List<Program_Grade_Level__c> programGradeLevels = new List<Program_Grade_Level__c>();
        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('3', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevels.add(programGradeLevel);
        //Create grade level for PE
        Program_Grade_Level__c programGradeLevelOne = Peak_TestUtils.createProgramGradeLevel('10', academicProgramAccount.Id, gradeLevel.Id, System.today(), false);
        programGradeLevel.AutoPlacement_PublicExclude__c = true;
        programGradeLevel.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel.AutoPlacement_HomeExclude__c = true;
        programGradeLevel.AutoPlacement_NoneExclude__c = true;
        programGradeLevels.add(programGradeLevelOne);
        insert programGradeLevels;
        //Create Annaul student info record for PE
        List<Id> ASId = new List<Id>();
        Annual_Student_Information__c currentASI1 = Peak_TestUtils.createAnnualStudentInformation('Current ASI1', currentProgramEnrollment.Id, currentProgramEnrollment.Start_Year__c, false);
        currentASI1.Final_Grade_Level__c = '3';
        currentASI1.LA_Placement_Level__c = '3';
        currentASI1.Math_Placement_Level__c = 'Gifted Math 4 (Math 5)';
        currentASI1.Grade_Level_Requested__c = '9';
        currentASI1.GiftedProgramRequest_LA_M_S__c = null;
        insert currentASI1;
        ASId.add(currentASI1.Id);
        //Update Prior school list 
        List<Prior_School__c> priorSchoolsList = new List<Prior_School__c>();
        Prior_School__c priorSchool_Homeschool = Peak_TestUtils.createPriorSchool(currentProgramEnrollment.Id, 'HomeSchool', false);
        priorSchool_Homeschool.School_Year__c = currentProgramEnrollment.Start_Year__c;
        priorSchoolsList.add(priorSchool_Homeschool);
        insert priorSchoolsList;
        //Create Placement and Elective record
        Placement_and_Elective__c placementAndElective = Peak_TestUtils.createPlacementAndElective(currentProgramEnrollment.Id, false);
        placementAndElective.Level_Requested__c = 'Standard';
        placementAndElective.Course_Requested__c = 'Social Studies';
        insert placementAndElective;

        //Update PE   
        currentProgramEnrollment.PlacementFlag__c = 'Released';
        currentProgramEnrollment.EntranceAgeEligibilityOverride__c = 'Eligible';
        currentProgramEnrollment.Credit_for_HS_Coursework__c = 'Yes';
        currentProgramEnrollment.Program_Grade_Level__c = programGradeLevels[0].id;
        update currentProgramEnrollment;
        peIdsSet.add(currentProgramEnrollment.id);
        PlacementUtilities.calculateAutomatedPlacementExclude(peIdsSet, true);
    }
    
    //test method for calculateAge logic
     static testMethod void calculateAgeTest(){
        Date birthDate = Date.Today();
        Test.startTest();
        NES_AnnualStudentInformationUtilities.calculateAge(birthDate);
        Test.stopTest();
    }
}