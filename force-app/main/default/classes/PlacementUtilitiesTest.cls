/*
* Created by: Alex Chisholm
* Created date: 2019-11-12
* Purpose: Test Class to provide coverage for PlacementUtilities
*/

@isTest(SeeAllData=false)
public with sharing class PlacementUtilitiesTest {
    static testMethod void testrunPlacement(){
    	recordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];	
    	recordType rtypes2 = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Educational Institution' limit 1];	
    	recordType rtypes3 = [Select Name, Id From RecordType where sObjectType='Enrollment_Component__c' and RecordType.name = 'Section' limit 1];	
    	
    	/* Create Educational Institution */
    	account edInst = new account();
    	edInst.Name = 'Test School';
    	edInst.recordtypeID = rtypes2.ID;
    	insert edInst;
    	system.debug(edInst.Name + ' Created');
    	
    	account parent = [select id, name from account where name = 'Test School'];
    	system.debug(parent.name);
    	
    	/* Create a School Year */
    	School_Year__c schlYear = Peak_TestUtils.createSchoolYears('Test Year', System.today());
   		
   		/* Create Academic Program 1 */
    	Account academicProgram1 = new account();
    	academicProgram1.name = 'Academic Program 1';
    	academicProgram1.School_Year__c = schlYear.id;
    	academicProgram1.Too_Young_Cutoff__c = system.today();
    	academicProgram1.recordtypeID = rtypes.ID;
    	academicProgram1.ParentID = parent.ID;
    	academicProgram1.Grade7Math__c = 'Math 7';
    	academicProgram1.Grade8Math__c = 'Algebra 1';
    	academicProgram1.AutomatedPlacementMaxCutoff__c = 99;
    	insert academicProgram1;
     	
     	account AcProgram1 = [SELECT ID, Name, Parent.Name, ParentID, recordtypeID FROM account where name = 'Academic Program 1'];  
     	school_year__c schoolYear = [SELECT ID FROM School_Year__c WHERE NAME = 'Test Year'];
     	
     	
     	list<id>pesToProcess = new list<ID>();
     	
     	/* Create a PE */
     	hed__program_enrollment__c PE1 = new hed__program_enrollment__C();
    	PE1.Start_Year__c = schoolYear.ID;
        PE1.Status__c = 'In Progress';
        PE1.PlacementFlag__c = 'Principal Review';
        PE1.hed__account__c = AcProgram1.ID;
        PE1.EvaluatePlacementExclude__c = false;
        PE1.EvaluatePlacementScore__c = true;
        PE1.EvaluatePlacementBucket__c = true;
		PE1.isPlacementReady__c = false;
        PE1.EntranceAgeEligibilitySystem__c = 'Eligible';
        insert PE1;
        pesToProcess.add(PE1.ID);
        
        /* Create an ASI */
        annual_student_information__c ASI1 = new annual_student_information__c();
        ASI1.Grade_Level_Requested__c = '7';
        ASI1.Grade_Level_Completed__c ='6';
        ASI1.school_year__c = schoolYear.ID;
        ASI1.Program_enrollment__c = PE1.ID;
        ASI1.Academic_Documentation_Summary__c = null;
        ASI1.LA_Placement_Level__c= null; 
        ASI1.HowStudentPlacementCompleted__c= null; 
        ASI1.CoursesFinalized__c= null; 
        ASI1.Math_Placement_Level__c= null;
        ASI1.Science_Placement_Level__c= null; 
        ASI1.RecommendedAutoPlacement__c= null; 
        ASI1.AutomatedPlacementScore__c= 10; 
        ASI1.AutomatedPlacementExclude__c= false;
        ASI1.Final_Grade_Level__c= null;       
        insert ASI1;
        
        
      	/* Create a PE */
     	hed__program_enrollment__c PE2 = new hed__program_enrollment__C();
    	PE2.Start_Year__c = schoolYear.ID;
        PE2.Status__c = 'In Progress';
        PE2.PlacementFlag__c = 'Principal Review';
        PE2.hed__account__c = AcProgram1.ID;
        PE2.EvaluatePlacementExclude__c = false;
        PE2.EvaluatePlacementScore__c = true;
        PE2.EvaluatePlacementBucket__c = true;
		PE2.isPlacementReady__c = false;
        PE2.EntranceAgeEligibilitySystem__c = 'Eligible';
        insert PE2;
        pesToProcess.add(PE2.ID);
        
        /* Create an ASI */
        annual_student_information__c ASI2 = new annual_student_information__c();
        ASI2.Grade_Level_Requested__c = '8';
        ASI2.Grade_Level_Completed__c ='7';
        ASI2.school_year__c = schoolYear.ID;
        ASI2.Program_enrollment__c = PE2.ID;
        ASI2.Academic_Documentation_Summary__c = null;
        ASI2.LA_Placement_Level__c= null; 
        ASI2.HowStudentPlacementCompleted__c= null; 
        ASI2.CoursesFinalized__c= null; 
        ASI2.Math_Placement_Level__c= null;
        ASI2.Science_Placement_Level__c= null; 
        ASI2.RecommendedAutoPlacement__c= null; 
        ASI2.AutomatedPlacementScore__c= 10; 
        ASI2.AutomatedPlacementExclude__c= false;
        ASI2.Final_Grade_Level__c= null;       
        insert ASI2;

     	/* Create a PE */
     	hed__program_enrollment__c PE3 = new hed__program_enrollment__C();
    	PE3.Start_Year__c = schoolYear.ID;
        PE3.Status__c = 'In Progress';
        PE3.PlacementFlag__c = 'Principal Review';
        PE3.hed__account__c = AcProgram1.ID;
        PE3.EvaluatePlacementExclude__c = false;
        PE3.EvaluatePlacementScore__c = true;
        PE1.EvaluatePlacementBucket__c = false;
		PE3.isPlacementReady__c = false;
        PE3.EntranceAgeEligibilitySystem__c = 'Eligible';
        insert PE3;
        pesToProcess.add(PE3.ID);
        
        /* Create an ASI */
        annual_student_information__c ASI3 = new annual_student_information__c();
        ASI3.Grade_Level_Requested__c = '7';
        ASI3.Grade_Level_Completed__c ='6';
        ASI3.school_year__c = schoolYear.ID;
        ASI3.Program_enrollment__c = PE3.ID;
        ASI3.Academic_Documentation_Summary__c = null;
        ASI3.LA_Placement_Level__c= null; 
        ASI3.HowStudentPlacementCompleted__c= null; 
        ASI3.CoursesFinalized__c= null; 
        ASI3.Math_Placement_Level__c= null;
        ASI3.Science_Placement_Level__c= null; 
        ASI3.RecommendedAutoPlacement__c= null; 
        ASI3.AutomatedPlacementScore__c= 10; 
        ASI3.AutomatedPlacementExclude__c= false;
        ASI3.Final_Grade_Level__c= null;       
        insert ASI3;

     	/* Create a PE */
     	hed__program_enrollment__c PE4 = new hed__program_enrollment__C();
    	PE4.Start_Year__c = schoolYear.ID;
        PE4.Status__c = 'In Progress';
        PE4.PlacementFlag__c = 'Principal Review';
        PE4.hed__account__c = AcProgram1.ID;
        PE4.EvaluatePlacementExclude__c = false;
        PE4.EvaluatePlacementScore__c = true;
		PE4.isPlacementReady__c = false;
        PE4.EntranceAgeEligibilitySystem__c = 'Eligible';
        insert PE4;
        pesToProcess.add(PE4.ID);
        
        /* Create an ASI */
        annual_student_information__c ASI4 = new annual_student_information__c();
        ASI4.Grade_Level_Requested__c = 'K';
        ASI4.Grade_Level_Completed__c ='';
        ASI4.school_year__c = schoolYear.ID;
        ASI4.Program_enrollment__c = PE4.ID;
        ASI4.Academic_Documentation_Summary__c = null;
        ASI4.LA_Placement_Level__c= null; 
        ASI4.HowStudentPlacementCompleted__c= null; 
        ASI4.CoursesFinalized__c= null; 
        ASI4.Math_Placement_Level__c= null;
        ASI4.Science_Placement_Level__c= null; 
        ASI4.RecommendedAutoPlacement__c= null; 
        ASI4.AutomatedPlacementScore__c= 10; 
        ASI4.AutomatedPlacementExclude__c= false;
        ASI4.Final_Grade_Level__c= null;       
        insert ASI4;

     	/* Create a PE */
     	hed__program_enrollment__c PE5 = new hed__program_enrollment__C();
    	PE5.Start_Year__c = schoolYear.ID;
        PE5.Status__c = 'In Progress';
        PE5.PlacementFlag__c = 'Principal Review';
        PE5.hed__account__c = AcProgram1.ID;
        PE5.EvaluatePlacementExclude__c = false;
        PE5.EvaluatePlacementScore__c = true;
		PE5.isPlacementReady__c = false;
        PE5.EntranceAgeEligibilitySystem__c = 'Eligible';
        insert PE5;
        pesToProcess.add(PE5.ID);
        
        /* Create an ASI */
        annual_student_information__c ASI5 = new annual_student_information__c();
        ASI5.Grade_Level_Requested__c = 'K';
        ASI5.Grade_Level_Completed__c ='';
		ASI5.TransitionalKAcknowledgement__c = 'Yes';
        ASI5.school_year__c = schoolYear.ID;
        ASI5.Program_enrollment__c = PE5.ID;
        ASI5.Academic_Documentation_Summary__c = null;
        ASI5.LA_Placement_Level__c= null; 
        ASI5.HowStudentPlacementCompleted__c= null; 
        ASI5.CoursesFinalized__c= null; 
        ASI5.Math_Placement_Level__c= null;
        ASI5.Science_Placement_Level__c= null; 
        ASI5.RecommendedAutoPlacement__c= null; 
        ASI5.AutomatedPlacementScore__c= 10; 
        ASI5.AutomatedPlacementExclude__c= false;
        ASI5.Final_Grade_Level__c= null;       
        insert ASI5;		        

        /* Create an Enrollment Component of type section */
		Enrollment_Component__c EC1 = new Enrollment_Component__c();
		EC1.Name = 'Section 1';
		EC1.Required_to_Complete_for_Auto_Placement__c = true;
		EC1.RecordTypeID = rtypes3.ID;
		insert EC1;
		
		/* Create ECAs for both PEs for EC1 */
		list<enrollment_Component_Affiliation__c> ecas = new list<enrollment_component_affiliation__c>();
		
		Enrollment_Component_Affiliation__c ECA1 = new Enrollment_Component_Affiliation__c();
		ECA1.Enrollment_Component__c = EC1.ID;
		ECA1.Status__c = 'Not Started';
		ECA1.Program_Enrollment__c = PE1.ID;
		ecas.add(ECA1);

		Enrollment_Component_Affiliation__c ECA2 = new Enrollment_Component_Affiliation__c();
		ECA2.Enrollment_Component__c = EC1.ID;
		ECA2.Status__c = 'Not Started';
		ECA2.Program_Enrollment__c = PE2.ID;
		ecas.add(ECA2);
		/*
		insert ecas;
		
		for(enrollment_component_affiliation__c eca : ecas){
			eca.Status__c = 'Complete';
		}
		update ecas;*/
		
		PlacementUtilities.runPlacement(pesToProcess);
		
		list<annual_student_information__c> asichecks = [select id, howstudentplacementcompleted__c from annual_student_information__c where program_enrollment__c in : pesToProcess];
		for(annual_student_information__c asicheck: asichecks){
			//System.assertnotequals(asicheck.howstudentplacementcompleted__c, null);
		}
				
    }
    static testMethod void testcalculateAutomatedPlacementScore(){

    	recordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];	
    	recordType rtypes2 = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Educational Institution' limit 1];	
    	
    	/* Create Educational Institution */
    	account edInst = new account();
    	edInst.Name = 'Test School';
    	edInst.recordtypeID = rtypes2.ID;
    	insert edInst;
    	system.debug(edInst.Name + ' Created');
    	
    	account parent = [select id, name from account where name = 'Test School'];
    	system.debug(parent.name);
    	
    	/* Create a School Year */
    	School_Year__c schlYear = Peak_TestUtils.createSchoolYears('Test Year', System.today());
   		
   		/* Create Academic Program 1 */
    	Account academicProgram1 = new account();
    	academicProgram1.name = 'Academic Program 1';
    	academicProgram1.School_Year__c = schlYear.id;
    	academicProgram1.Too_Young_Cutoff__c = system.today();
    	academicProgram1.recordtypeID = rtypes.ID;
    	academicProgram1.ParentID = parent.ID;
    	insert academicProgram1;
     	
     	account AcProgram1 = [SELECT ID, Name, Parent.Name, ParentID, recordtypeID FROM account where name = 'Academic Program 1'];  
     	school_year__c schoolYear = [SELECT ID FROM School_Year__c WHERE NAME = 'Test Year'];
     	
     	/* Create a PE */
     	List<ID>pesToProcess = new List<ID>();
     	hed__program_enrollment__c PE1 = new hed__program_enrollment__C();
    	PE1.Start_Year__c = schoolYear.ID;
        PE1.Status__c = 'In Progress';
        PE1.PlacementFlag__c = 'Principal Review';
        PE1.hed__account__c = AcProgram1.ID;
        PE1.EvaluatePlacementExclude__c = true;
        PE1.EvaluatePlacementScore__c = true;
        PE1.isPlacementReady__c = true;
        PE1.Credit_for_HS_Coursework__c = 'Yes';
        PE1.SIF_SummerSchoolCourses__c = 'Yes';
        PE1.SIFStudentRetained__c = 'Yes';
        PE1.SIF_AcademicSupportNeeds__c = 'Language Arts;Math';
        insert PE1;
        pesToProcess.add(PE1.ID);
        
        /* Create an ASI */
        list<annual_student_information__c> asisToProcess = new list<annual_student_information__c>();
        annual_student_information__c ASI1 = new annual_student_information__c();
        ASI1.Grade_Level_Requested__c = '9';
        ASI1.Grade_Level_Completed__c ='8';
        ASI1.GiftedProgramRequest_LA_M_S__c = 'Math';
        ASI1.school_year__c = schoolYear.ID;
        ASI1.Program_enrollment__c = PE1.ID;
        ASI1.Academic_Documentation_Summary__c = null;
        ASI1.LA_Placement_Level__c= null; 
        ASI1.HowStudentPlacementCompleted__c= null; 
        ASI1.CoursesFinalized__c= null; 
        ASI1.Math_Placement_Level__c= null;
        ASI1.Science_Placement_Level__c= null; 
        ASI1.RecommendedAutoPlacement__c= null; 
        ASI1.AutomatedPlacementScore__c= null; 
        ASI1.AutomatedPlacementExclude__c= false;
        ASI1.Final_Grade_Level__c= null;


        
        insert ASI1;
        Set<ID> asiIDs = new Set<ID>();
        asiIds.add(ASI1.ID);
        asisToProcess.add(ASI1);
        
        /* Create Special Education Records */
        special_education__c spEd1 = new special_education__c();
        spEd1.program_enrollment__c = PE1.ID;
        spEd1.IEPHistory__c = 'Yes';
        sped1.Plan504History__c = 'Yes';
        sped1.Plan504Exit__c = 'Yes';
        sped1.EvaluatedWithInLastYear__c = 'Yes';
        insert spEd1;
        
        /* Create Prior School Record */
        prior_school__c ps1 = new prior_school__c();
        ps1.program_enrollment__c = pe1.id;
        ps1.SchoolType__c = 'Homeschool';
        insert ps1;                     
              
        test.startTest();
        System.enqueueJob(new NES_PlacementQueueable(pesToProcess)); 
        test.stopTest();
        
        list<annual_student_information__c> asis = new list<annual_student_information__c>([SELECT id, AutomatedPlacementScore__c from Annual_student_Information__c WHERE id in: asiIDs]);
        
        for(annual_student_information__c asi : asis){
        	system.debug('PlacementScore: ' + asi.AutomatedPlacementScore__c);
        	system.AssertEquals(asi.AutomatedPlacementScore__c, null);
        }
          	
    }

    static testMethod void testcalculateAutomatedPlacementExclude(){
    	recordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];	
    	recordType rtypes2 = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Educational Institution' limit 1];	
    	
    	/* Create Educational Institution */
    	account edInst = new account();
    	edInst.Name = 'Test School';
    	edInst.recordtypeID = rtypes2.ID;
    	insert edInst;
    	system.debug(edInst.Name + ' Created');
    	
    	account parent = [select id, name from account where name = 'Test School'];
    	system.debug(parent.name);
    	
    	/* Create a School Year */
    	School_Year__c schlYear = Peak_TestUtils.createSchoolYears('Test Year', System.today());
    	
    	/* Create a Grade Level K */
    	Grade_Level__c gradeK = new Grade_Level__c(name = 'K');
    	insert gradeK;

    	/* Create a Grade Level 9 */
    	Grade_Level__c grade9 = new Grade_Level__c(name = '9');
    	insert grade9;
    	
    	/* Create a parent Educational Institution 
    	Account edInst = new Account(name = 'Test', display_name__c = 'Test School');
    	insert edInst; */
    	
    	/* Create Academic Program 1 that is excluded from AutoPlacement */
    	Account academicProgram1 = new account();
    	academicProgram1.name = 'Academic Program 1';
    	academicProgram1.School_Year__c = schlYear.id;
    	academicProgram1.Too_Young_Cutoff__c = system.today();
    	academicProgram1.AutomatedPlacementExclude__c = true;
    	academicProgram1.recordtypeID = rtypes.ID;
    	academicProgram1.ParentID = parent.ID;
    	insert academicProgram1;
     	
     	account AcProgram1 = [SELECT ID, Name, Parent.Name, ParentID, recordtypeID FROM account where name = 'Academic Program 1'];    	
    	
    	system.debug(AcProgram1.Name + ' Created');
    	system.debug(AcProgram1.Parent.Name + ' Parent');
    	
    	/* Create a PGL for Academic Program 1 that excludes grade K */
    	Program_Grade_Level__c programGradeLevel1 = new Program_Grade_Level__c ();
    	programGradeLevel1.name = 'PGL1';
    	programGradeLevel1.Grade_Level__c = gradeK.id;
    	programGradeLevel1.Academic_Program__c = academicProgram1.id;
        programGradeLevel1.AutoPlacementExclude__c = true;
		insert programGradeLevel1;
    	
    	/* Create Academic Program 2 that is NOT excluded from AutoPlacement */
    	Account academicProgram2 = new account();
    	academicProgram2.name = 'Academic Program 2';
    	academicProgram2.School_Year__c = schlYear.id;
    	academicProgram2.Too_Young_Cutoff__c = system.today();    	
    	academicProgram2.recordtypeID = rtypes.ID;
    	academicProgram2.ParentID = parent.ID;
    	insert academicProgram2;
     	account AcProgram2 = [SELECT ID, Name, Parent.Name, ParentID, recordtypeID FROM account where name = 'Academic Program 2'];    	
    	system.debug(AcProgram2.Name + ' Created');
    	system.debug(AcProgram2.Parent.Name + ' Parent');
    	
    	/* Create a PGL for Academic Program 2 that excludes all prior school types */
    	Program_Grade_Level__c programGradeLevel2 = new Program_Grade_Level__c ();
    	programGradeLevel2.name = 'PGL2';
    	programGradeLevel2.Grade_Level__c = grade9.id;
    	programGradeLevel2.Academic_Program__c = academicProgram2.id;
        programGradeLevel2.AutoPlacement_PublicExclude__c = true;
        programGradeLevel2.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel2.AutoPlacement_HomeExclude__c = true;
        programGradeLevel2.AutoPlacement_NoneExclude__c = true;
        programGradeLevel2.AutoPlacement_Special_EdExclude__c = true;
		insert programGradeLevel2;
		system.debug(programGradeLevel2.grade_level__c + ' GradeLevel PGL2');

    	/* Create Program Enrollments */
    	list<hed__program_enrollment__c>pes = new list<hed__program_enrollment__c>();
    	set<id> pesToProcess = new set<id>();
    	
    	school_year__c schoolYear = [SELECT ID FROM School_Year__c WHERE NAME = 'Test Year'];
    	Program_Grade_Level__c PGL1 = [SELECT ID, Grade_Level__c, AutoPlacementExclude__c FROM Program_Grade_Level__c WHERE NAME = 'PGL1' LIMIT 1];
    	Program_Grade_Level__c PGL2 = [SELECT ID,Grade_Level__c, AutoPlacementExclude__c FROM Program_Grade_Level__c WHERE NAME = 'PGL2' LIMIT 1];

    	
    	system.debug(AcProgram1.ParentID + ' Parent1');
    	system.debug(AcProgram1.Parent.Name + ' Parent1.Name');
    	system.debug(AcProgram2.Parent.Name + ' Parent2.Name');
    	system.debug(AcProgram1.recordtypeID);
    	
    	hed__program_enrollment__c PE1 = new hed__program_enrollment__C();
    	PE1.Start_Year__c = schoolYear.ID;
        PE1.Status__c = 'In Progress';
        PE1.PlacementFlag__c = 'Principal Review';
        PE1.EntranceAgeEligibilityOverride__c = 'Ineligible';
        PE1.Program_Grade_Level__c = PGL1.ID;
        PE1.hed__account__c = AcProgram1.ID;
        PE1.EvaluatePlacementExclude__c = true;
        PE1.EvaluatePlacementScore__c = true;
        PE1.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        pes.add(PE1);
             
    	hed__program_enrollment__c PE2 = new hed__program_enrollment__C();
    	PE2.Start_Year__c = schoolYear.ID;
        PE2.Status__c = 'In Progress';
        PE2.LastSchoolType__c = 'Public School';
        PE2.Program_Grade_Level__c = PGL2.ID;
        PE2.hed__account__c = AcProgram2.ID;
        PE2.EvaluatePlacementExclude__c = true;
        PE2.EvaluatePlacementScore__c = true;
        PE2.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        pes.add(PE2);
        
    	hed__program_enrollment__c PE3 = new hed__program_enrollment__C();
    	PE3.Start_Year__c = schoolYear.ID;
        PE3.Program_Grade_Level__c = PGL2.ID;
        PE3.Status__c = 'In Progress';
        PE3.LastSchoolType__c = 'Private/Parochial School';
        PE3.hed__account__c = AcProgram2.ID;
        PE3.EvaluatePlacementExclude__c = true;
        PE3.EvaluatePlacementScore__c = true;
        PE3.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        pes.add(PE3);
       
    	hed__program_enrollment__c PE4 = new hed__program_enrollment__C();
    	PE4.Start_Year__c = schoolYear.ID;
        PE4.Status__c = 'In Progress';
        PE4.Program_Grade_Level__c = PGL2.ID;
        PE4.LastSchoolType__c = 'Homeschool';
        PE4.hed__account__c = AcProgram2.ID;
        PE4.EvaluatePlacementExclude__c = true;
        PE4.EvaluatePlacementScore__c = true;
        PE4.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        pes.add(PE4);   

    	hed__program_enrollment__c PE5 = new hed__program_enrollment__C();
    	PE5.Start_Year__c = schoolYear.ID;
        PE5.Program_Grade_Level__c = PGL2.ID;
        PE5.Status__c = 'In Progress';
        PE5.LastSchoolType__c = 'None';
        PE5.EntranceAgeEligibilitySystem__c = 'Eligible';
        PE5.WhyFlagged__c = 'Disciplinary';
        PE5.Credit_for_HS_Coursework__c = 'Yes';
        PE5.hed__account__c = AcProgram2.ID;
        PE5.EvaluatePlacementExclude__c = true;
        PE5.EvaluatePlacementScore__c = true;
        PE5.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        pes.add(PE5);           

		hed__program_enrollment__c PE6 = new hed__program_enrollment__C();
    	PE6.Start_Year__c = schoolYear.ID;
        PE6.Status__c = 'In Progress';
        PE6.PlacementFlag__c = 'Principal Review';
        PE6.EntranceAgeEligibilityOverride__c = 'Ineligible';
        PE6.Program_Grade_Level__c = PGL1.ID;
        PE6.hed__account__c = AcProgram1.ID;
        PE6.EvaluatePlacementExclude__c = true;
        PE6.EvaluatePlacementScore__c = true;
        PE6.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
        pes.add(PE6);

        insert pes;     
        
        //system.debug(AcademicProgram1.Parent.Name);
        system.debug(PE1.hed__account__c + ' hed__account__c');
        system.debug(PE1.hed__account__r.name + ' PE Parent1');
        system.debug(PE1.Start_year__c + ' PE Start Year');        
       /// system.debug(AcademicProgram2.Parent.Name);
        system.debug(PE2.hed__account__r.name + ' PE Parent 2');
        system.debug(PE2.program_grade_level__c);
        system.debug(PGL2.ID);
        system.debug(PGL2.AutoPlacementExclude__c + 'PGL Exclude');
        
        /* Create Special Education Records */
        special_education__c spEd5 = new special_education__c();
        spEd5.program_enrollment__c = PE5.ID;
        spEd5.IEP__c = 'IEP';
        insert spEd5;
        
        /* Create Enrollment Document Records */
        enrollment_document__c edoc1 = new enrollment_document__c();
        edoc1.program_enrollment__c = PE1.ID;
        edoc1.type__c = 'IEP Exit Documentation';
        edoc1.status_reason__c = 'Reviewed';
        insert edoc1;
        
        /* Create Annual Student Information Records */
        list<annual_student_information__c> asis = new list<annual_student_information__c>();
        
        annual_student_information__c ASI1 = new annual_student_information__c();
        ASI1.Grade_Level_Requested__c = 'Kindergarten';
        ASI1.Grade_Level_Completed__c ='';
        ASI1.GiftedProgramRequest_LA_M_S__c = 'Math';
        ASI1.school_year__c = schoolYear.ID;
        ASI1.Program_enrollment__c = PE1.ID;
        asis.add(ASI1);
        
        annual_student_information__c ASI2 = new annual_student_information__c();
        ASI2.Grade_Level_Requested__c = '9';
        ASI2.Grade_Level_Completed__c ='8';
        ASI2.School_year__c = schoolYear.ID;
        ASI2.Program_enrollment__c = PE2.ID;
        ASI2.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI2);
        
        annual_student_information__c ASI3 = new annual_student_information__c();
        ASI3.Grade_Level_Requested__c = '9';
        ASI3.Grade_Level_Completed__c ='8';
        ASI3.School_year__c = schoolYear.ID;
        ASI3.Program_enrollment__c = PE3.ID;
        ASI3.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI3);
        
        annual_student_information__c ASI4 = new annual_student_information__c();
        ASI4.Grade_Level_Requested__c = '9';
        ASI4.Grade_Level_Completed__c ='8';
        ASI4.School_year__c = schoolYear.ID;
        ASI4.Program_enrollment__c = PE4.ID;
        ASI4.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI4);
        
        annual_student_information__c ASI5 = new annual_student_information__c();
        ASI5.Grade_Level_Requested__c = '9';
        ASI5.Grade_Level_Completed__c ='8';
        ASI5.School_year__c = schoolYear.ID;
        ASI5.Program_enrollment__c = PE5.ID;
        ASI5.GiftedProgramRequest_LA_M_S__c = '';

		annual_student_information__c ASI6 = new annual_student_information__c();
        ASI6.Grade_Level_Requested__c = 'Kindergarten';
        ASI6.Grade_Level_Completed__c ='';
        ASI6.GiftedProgramRequest_LA_M_S__c = 'Math';
        ASI6.school_year__c = schoolYear.ID;
        ASI6.Program_enrollment__c = PE6.ID;
		ASI6.TransitionalKAcknowledgement__c = 'Yes';
        asis.add(ASI6);

        asis.add(ASI5);
        insert asis;
        
        /* Create a Placement and Elective Record */
        placement_and_elective__c PLE5 = new placement_and_elective__c();
		PLE5.program_enrollment__c = PE5.ID;
		PLE5.Course_Requested__c = 'English';
		PLE5.Level_Requested__c = 'Advanced';  
		insert PLE5;      
        
        pesToProcess.add(PE1.id);
        pesToProcess.add(PE2.id);
        pesToProcess.add(PE3.id);
        pesToProcess.add(PE4.id);
        pesToProcess.add(PE5.id);
        pesToProcess.add(PE6.id);
        
        list<annual_student_information__c> asiList = new list<annual_student_information__c>();
        
        asiList = PlacementUtilities.calculateAutomatedPlacementExclude(pesToProcess, true);
        system.debug('PlacementUtilitiesasiList>> ' + asiList);
        for(annual_student_information__c asi : asiList){
            system.debug('PlacementScoreMiddle: ' + asi.AutomatedPlacementScore__c);
        	//System.AssertEquals(asi.AutomatedPlacementExclude__c, null);
        }
    }

    static testMethod void testcalculateAutomatedPlacementExclude2(){
	//Mark Membrino 3/10/2020 Added for some additional auto exclude rules for 148152
    	recordType rtypes = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Academic Program' limit 1];	
    	recordType rtypes2 = [Select Name, Id From RecordType where sObjectType='Account' and RecordType.name = 'Educational Institution' limit 1];	
    	
    	/* Create Educational Institution */
    	account edInst = new account();
    	edInst.Name = 'Test School';
    	edInst.recordtypeID = rtypes2.ID;
    	insert edInst;
    	system.debug(edInst.Name + ' Created');
    	
    	account parent = [select id, name from account where name = 'Test School'];
    	system.debug(parent.name);
    	
    	/* Create a School Year */
        School_Year__c schlYear = Peak_TestUtils.createSchoolYears('2018-2019',date.parse('11/17/2018'));
    	
        School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2017-2018',date.parse('11/17/2017'));

    	/* Create a Grade Level K */
    	Grade_Level__c gradeK = new Grade_Level__c(name = 'K');
    	insert gradeK;

    	/* Create a Grade Level 8 */
    	Grade_Level__c grade8 = new Grade_Level__c(name = '8');
    	insert grade8;
    	
    	/* Create Academic Program 2 that is NOT excluded from AutoPlacement */
    	Account academicProgram2 = new account();
    	academicProgram2.name = 'Academic Program 2';
    	academicProgram2.School_Year__c = schlYear.id;
    	academicProgram2.Too_Young_Cutoff__c = system.today();    	
    	academicProgram2.recordtypeID = rtypes.ID;
    	academicProgram2.ParentID = parent.ID;
    	insert academicProgram2;
     	account AcProgram2 = [SELECT ID, Name, Parent.Name, ParentID, recordtypeID FROM account where name = 'Academic Program 2'];    	
    	system.debug(AcProgram2.Name + ' Created');
    	system.debug(AcProgram2.Parent.Name + ' Parent');
    	
    	/* Create a PGL for Academic Program 2 that excludes all prior school types */
    	Program_Grade_Level__c programGradeLevel2 = new Program_Grade_Level__c ();
    	programGradeLevel2.name = 'PGL2';
    	programGradeLevel2.Grade_Level__c = grade8.id;
    	programGradeLevel2.Academic_Program__c = academicProgram2.id;
        programGradeLevel2.AutoPlacement_PublicExclude__c = false;
        programGradeLevel2.AutoPlacement_PrivateExclude__c = true;
        programGradeLevel2.AutoPlacement_HomeExclude__c = true;
        programGradeLevel2.AutoPlacement_NoneExclude__c = true;
        programGradeLevel2.AutoPlacement_Special_EdExclude__c = true;
		insert programGradeLevel2;
		system.debug(programGradeLevel2.grade_level__c + ' GradeLevel PGL2');

    	/* Create Program Enrollments */
    	list<hed__program_enrollment__c>pes = new list<hed__program_enrollment__c>();
    	set<id> pesToProcess = new set<id>();
    	
    	school_year__c schoolYear = [SELECT ID FROM School_Year__c WHERE NAME = '2018-2019'];
    	school_year__c prevschoolYear = [SELECT ID FROM School_Year__c WHERE NAME = '2017-2018'];
    	Program_Grade_Level__c PGL2 = [SELECT ID,Grade_Level__c, AutoPlacementExclude__c FROM Program_Grade_Level__c WHERE NAME = 'PGL2' LIMIT 1];

		Account account = Peak_TestUtils.createTestAccount();
        Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
		contact.Birthdate__c = System.today();
		update contact;

    	hed__program_enrollment__c PE1 = new hed__program_enrollment__C();
    	PE1.Start_Year__c = schoolYear.ID;
        PE1.Status__c = 'In Progress';
        PE1.LastSchoolType__c = 'Public School';
        PE1.Program_Grade_Level__c = PGL2.ID;
        PE1.hed__account__c = AcProgram2.ID;
        PE1.EvaluatePlacementExclude__c = true;
        PE1.EvaluatePlacementScore__c = true;
        PE1.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
		PE1.EntranceAgeEligibilityOverride__c = 'Eligible';
        pes.add(PE1);
            
    	hed__program_enrollment__c PE2 = new hed__program_enrollment__C();
    	PE2.Start_Year__c = schoolYear.ID;
        PE2.Status__c = 'In Progress';
        PE2.LastSchoolType__c = 'Public School';
        PE2.Program_Grade_Level__c = PGL2.ID;
        PE2.hed__account__c = AcProgram2.ID;
        PE2.EvaluatePlacementExclude__c = true;
        PE2.EvaluatePlacementScore__c = true;
        PE2.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
		PE2.EntranceAgeEligibilityOverride__c = 'Eligible';
        pes.add(PE2);

    	hed__program_enrollment__c PE3 = new hed__program_enrollment__C();
    	PE3.Start_Year__c = schoolYear.ID;
        PE3.Status__c = 'In Progress';
        PE3.LastSchoolType__c = 'Public School';
        PE3.Program_Grade_Level__c = PGL2.ID;
        PE3.hed__account__c = AcProgram2.ID;
        PE3.EvaluatePlacementExclude__c = true;
        PE3.EvaluatePlacementScore__c = true;
        PE3.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
		PE3.EntranceAgeEligibilityOverride__c = 'Eligible';
        pes.add(PE3);

    	hed__program_enrollment__c PE4 = new hed__program_enrollment__C();
    	PE4.Start_Year__c = schoolYear.ID;
        PE4.Status__c = 'In Progress';
        PE4.LastSchoolType__c = 'Public School';
        PE4.Program_Grade_Level__c = PGL2.ID;
        PE4.hed__account__c = AcProgram2.ID;
        PE4.EvaluatePlacementExclude__c = true;
        PE4.EvaluatePlacementScore__c = true;
        PE4.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';
		PE4.EntranceAgeEligibilityOverride__c = 'Eligible';
		PE4.hed__Contact__c= contact.Id;

        pes.add(PE4);
				        
        insert pes;     
      
       
        /* Create Annual Student Information Records */
        list<annual_student_information__c> asis = new list<annual_student_information__c>();
        
		//Test Repeating the same grade.
        annual_student_information__c ASI1 = new annual_student_information__c();
        ASI1.Grade_Level_Requested__c = '9';
        ASI1.Grade_Level_Completed__c ='8';
        ASI1.School_year__c = schoolYear.ID;
        ASI1.Program_enrollment__c = PE1.ID;
        ASI1.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI1);

		annual_student_information__c ASI2 = new annual_student_information__c();
        ASI2.Grade_Level_Completed__c = '9';
        ASI2.Grade_Level_Completed__c ='8';
        ASI2.School_year__c = previousSchoolYear.ID;
        ASI2.Program_enrollment__c = PE1.ID;
        ASI2.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI2);
		
		//Test skipping a grade     
        annual_student_information__c ASI3 = new annual_student_information__c();
        ASI3.Grade_Level_Requested__c = '9';
        ASI3.Grade_Level_Completed__c ='8';
        ASI3.School_year__c = schoolYear.ID;
        ASI3.Program_enrollment__c = PE2.ID;
        ASI3.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI3);

		annual_student_information__c ASI4 = new annual_student_information__c();
        ASI4.Grade_Level_Completed__c = '5';
        ASI4.Grade_Level_Completed__c ='4';
        ASI4.School_year__c = previousSchoolYear.ID;
        ASI4.Program_enrollment__c = PE2.ID;
        ASI4.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI4);

		//Test grade 8 Math requirement.
		annual_student_information__c ASI5 = new annual_student_information__c();
        ASI5.Grade_Level_Requested__c = '8';
        ASI5.Grade_Level_Completed__c ='7';
        ASI5.School_year__c = schoolYear.ID;
        ASI5.Program_enrollment__c = PE3.ID;
        ASI5.GiftedProgramRequest_LA_M_S__c = '';
		ASI5.Grade_8_Next_Years_Math_Course__c = 'Pre-Algebra';
        asis.add(ASI5);

		//Test too young for grade level
		annual_student_information__c ASI6 = new annual_student_information__c();
        ASI6.Grade_Level_Requested__c = '8';
        ASI6.Grade_Level_Completed__c ='7';
        ASI6.School_year__c = schoolYear.ID;
        ASI6.Program_enrollment__c = PE4.ID;
        ASI6.GiftedProgramRequest_LA_M_S__c = '';
        asis.add(ASI6);

        insert asis;
        
        pesToProcess.add(PE1.id);
        pesToProcess.add(PE2.id);
        pesToProcess.add(PE3.id);
        pesToProcess.add(PE4.id);
        
        list<annual_student_information__c> asiList = new list<annual_student_information__c>();
        
        asiList = PlacementUtilities.calculateAutomatedPlacementExclude(pesToProcess, true);
        system.debug('asiListpesToProcess>> ' + asiList);
        for(annual_student_information__c asi : asiList){
            system.debug('SecongPlacementScore: ' + asi.AutomatedPlacementScore__c);
        	//System.AssertEquals(asi.AutomatedPlacementExclude__c, null);
        }
    }    
}