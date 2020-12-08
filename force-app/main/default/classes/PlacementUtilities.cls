/*******************************************************************
** Created by Alex Chisholm on 11/10/2019
** Purpose : Consolidate the revised AutoPlacement Business Logic
*******************************************************************/
public class PlacementUtilities {
    public static void runPlacement (List<ID>peIDs) {
		system.debug('Start runPlacement');
		
        /*Grab the PE records we need to work with*/
        List<hed__program_enrollment__c> pes = new list<hed__program_enrollment__c>([
            SELECT ID, HowStudentPlacementCompleted__c, isPlacementReady__c, EvaluatePlacementScore__c, EvaluatePlacementExclude__c, EvaluatePlacementBucket__c, start_year__c
            FROM hed__program_enrollment__c
            WHERE ID IN: peIDs]);
        
        /* Grab the ASI records we need to work with*/
        List<Annual_Student_Information__c> allasis = new list<annual_student_information__c>([
                SELECT Id, Program_Enrollment__c,Academic_Documentation_Summary__c,School_Year__r.Start_Date__c,
                        LA_Placement_Level__c, HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c,
                        Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c, AutomatedPlacementScore__c, 
                        AutomatedPlacementExclude__c,
                        Final_Grade_Level__c, GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c,
                        Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c,
                        School_Year__c, Program_Enrollment__r.Start_Year__r.Current_Year__c, APS_PlacedTimeStamp__c, 
                        Program_Enrollment__r.hed__account__r.Grade8Math__c,  Program_Enrollment__r.hed__account__r.Grade7Math__c,
						TransitionalKAcknowledgement__c
                        FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN: peIds
        ]);
        
        /* Create a map out of the PEs so that we can reference them easily*/
        Map<ID, hed__program_enrollment__c> peMap = new Map<ID, hed__program_enrollment__c>();
        for(hed__program_enrollment__c pe : pes){
            peMap.put(pe.ID, pe);
        }      
        
        
        
        /* Map the same year ASIs so that we can update them easily and build out the bucket list*/
        Map<ID, Annual_Student_Information__c> asiMap = new Map<ID, Annual_Student_Information__c>();
        list<annual_student_information__c> bucketASIs = new list<annual_student_information__c>();
        list<annual_student_information__c> asis = new list<annual_student_information__c>();
        for(annual_student_information__c asi : allasis){
            if (asi.school_year__c == peMap.get(asi.Program_Enrollment__c).start_Year__c){
            	asiMap.put(asi.ID, asi);
            	asis.add(asi);
            }
            /*Populate the list to call the bucket with */
            if(peMap.get(asi.Program_Enrollment__c).EvaluatePlacementBucket__c == true){
            	bucketASIs.add(asi);
            }
        
        }
        
        /* Create maps of just the ASIs and PEs we will eventually update */
        map<ID, Annual_Student_Information__c> asiUpdateMap = new map<ID, Annual_Student_Information__c>();
        
        /* Build a list of PEs that need Exclusion evaluation */
        Set<ID> evalExclude = new Set<ID> ();
        
        /*Build a list of PEs that need Score evaluation */
         Set<ID>  evalScore = new Set<ID>();
       
        /*Populate the score and exclusion lists and set their calculation flags to null. We will update these records later to commit the flag change*/
        for(hed__program_enrollment__c pe : peMap.Values()){
            if (pe.EvaluatePlacementExclude__c){
                pe.EvaluatePlacementExclude__c = false;
                evalExclude.add(pe.id);
            }
            if (pe.EvaluatePlacementScore__c){
                pe.EvaluatePlacementScore__c = false;
                evalScore.add(pe.id);
            }
            if(pe.EvaluatePlacementBucket__c){
            	pe.EvaluatePlacementBucket__c = false;
            }
        }
        
        
        /* Get the results of the exclusion evaluation*/
        list<Annual_Student_Information__c> asiExcludes = new list<Annual_Student_Information__c>();
        asiExcludes = calculateAutomatedPlacementExclude(evalExclude, true);
        System.debug('got Exclusions');
        
        /* Get the results of the score evaluation*/
        list<Annual_Student_Information__c> asiScores = new list<Annual_Student_Information__c>();
		asiScores = calculatePlacementScore(evalScore, asis);    
        System.debug('got Scores');
        
        /* Merge the outcomes of the score and exclusion evaluations into the mapped ASIs */
        for (annual_student_information__c asiEvalUpdate : asiExcludes){
        	asiMap.get(asiEvalUpdate.ID).AutomatedPlacementExclude__c = asiEvalUpdate.AutomatedPlacementExclude__c;
        	asiUpdateMap.put(asiEvalUpdate.ID, asiMap.get(asiEvalUpdate.ID));
        }

        for (annual_student_information__c asiScoreUpdate: asiScores){
        	asiMap.get(asiScoreUpdate.ID).AutomatedPlacementScore__c = asiScoreUpdate.AutomatedPlacementScore__c;
        	asiUpdateMap.put(asiScoreUpdate.ID, asiMap.get(asiScoreUpdate.ID));
        }

        /**** Start evaluation of the AutoPlacement Process *****/
        list<Annual_Student_Information__c> asiPlacements = new list<Annual_Student_Information__c>();
        list<Annual_Student_Information__c> asiPlacementUpdates = new list<Annual_Student_Information__c>();
        
        /**************************************************************  
        ** Only call AutoPlacement for applicable ASIs. 
        ** If any manual values have been provided or the student has request highschool, we bypass the process 
        ***************************************************************/ 
        for(Annual_Student_Information__c asi : asiUpdateMap.Values()) {
            if(asi.HowStudentPlacementCompleted__c == null && asi.AutomatedPlacementScore__c != null && asi.AutomatedPlacementExclude__c == false
                    && asi.LA_Placement_Level__c == null && asi.Science_Placement_Level__c == null
                    && asi.Final_Grade_Level__c == null && asi.Math_Placement_Level__c == null
                    && asi.Grade_Level_Requested__c != '9' && asi.Grade_Level_Requested__c != '10'
                    && asi.Grade_Level_Requested__c != '11' && asi.Grade_Level_Requested__c != '12') {
                asiPlacements.add(asi);
            }
        }
       	System.debug('calling PlacementProcess');
       	asiPlacementUpdates = calculateAutomatedPlacementProcess(peIds, asiPlacements);
       	System.debug('PlacementProcess done');
       	
       	/* Merge the placement updates into the mapped ASIS */
       	/***** NEED TO UPDATE PLACEMENT FLAGS FOR PLACED KIDS ****/
        for (annual_student_information__c asiPlacementUpdate: asiPlacementUpdates){
        	asiMap.get(asiPlacementUpdate.ID).Final_Grade_Level__c = asiPlacementUpdate.Final_Grade_Level__c;
        	asiMap.get(asiPlacementUpdate.ID).Math_Placement_Level__c = asiPlacementUpdate.Math_Placement_Level__c;
        	asiMap.get(asiPlacementUpdate.ID).Science_Placement_Level__c = asiPlacementUpdate.Science_Placement_Level__c;
        	asiMap.get(asiPlacementUpdate.ID).LA_Placement_Level__c = asiPlacementUpdate.LA_Placement_Level__c;
        	asiMap.get(asiPlacementUpdate.ID).CoursesFinalized__c = asiPlacementUpdate.CoursesFinalized__c;
        	asiMap.get(asiPlacementUpdate.ID).HowStudentPlacementCompleted__c = asiPlacementUpdate.HowStudentPlacementCompleted__c;
        	asiUpdateMap.put(asiPlacementUpdate.ID, asiMap.get(asiPlacementUpdate.ID));
        }
       	
		if(asiUpdateMap.size() > 0){
			/* Clear the placement flag for placed students */
			for (Annual_Student_Information__c updatedASI: asiUpdateMap.Values()){
				if(asiMap.get(updatedASI.ID).HowStudentPlacementCompleted__c != null){
					peMap.get(updatedASI.Program_Enrollment__c).HowStudentPlacementCompleted__c = asiMap.get(updatedASI.ID).HowStudentPlacementCompleted__c;
					peMap.get(updatedASI.Program_Enrollment__c).PlacementFlag__c = null;
					peMap.get(updatedASI.Program_Enrollment__c).Final_Grade_Level__c = asiMap.get(updatedASI.ID).Final_Grade_Level__c;
				}
			}
		}
		
		/* Update PEs */
		try {
			System.debug('Updating PEs');
			update peMap.Values();
		} 
		catch (Exception ex) {
			System.debug('Exception Thrown : ' + ex.getMessage());
			//logger.logException('updatePlacedPEs', ex);
			//logger.saveLogs();
		}
		
		if(asiUpdateMap.size() > 0){			
			/*Update ASI records */
			try {
				System.debug('Updating ASIs');
				update asiUpdateMap.Values();
			} 
			catch (Exception ex) {
				System.debug('Exception Thrown : ' + ex.getMessage());
				//logger.logException('updatePlacedASIs', ex);
				//logger.saveLogs();
			}		
		}
		/*Call the Placement Bucket now that all other operations have been processed*/
		NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(bucketASIs, false);
		/*
        if(newASIs.size() > 0) {
            NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(newASIs, true);
            populateProgramEnroll_FinalGradeLevel(newASIs);
        } else {
            NES_AnnualStudentInformationUtilities.recalculateStudentPlacementBucket(updatedASIs4, true);
            populateProgramEnroll_FinalGradeLevel(updatedASIs4);
        }*/

    }
    /**
	* Created by Ajith on 03/22/2019 in NES_AnnualStudentInformationUtilities
	* Updated by Alex Chisholm on 11/10/2019 and moved to PlacementUtilities
	* MethodName: automatedPlacementExclude
	* Description: Method of Excluding the Student from the auto placement
	* Params : @pesToProcess - Set of hed__program_enrollment__c Ids
	*/
    public static List<Annual_Student_Information__c> calculateAutomatedPlacementExclude(Set<Id> pesToProcess, Boolean isFiredFromASI) {
        System.debug('In calculateAutomatedPlacementExclude Method');
        system.debug(pesToProcess.size());
        
        //Create Some Variables to Work With
        List<Annual_Student_Information__c> asiListToBeUpdated = new List<Annual_Student_Information__c>();
        Map<Id, List<Program_Grade_Level__c>> programGradelevelMap = new Map<Id, List<Program_Grade_Level__c>> ();
        for(Program_Grade_Level__c gradeLevel : [
            SELECT Id, Grade_Level__c, Grade_Level__r.Name, Academic_Program__c, AutoplacementExclude__c, AutoPlacement_HomeExclude__c,
            AutoPlacement_Special_EdExclude__c, AutoPlacement_PublicExclude__c, AutoPlacement_PrivateExclude__c, AutoPlacement_NoneExclude__c 
            FROM Program_Grade_Level__c
            WHERE Academic_Program__c IN (SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id IN :pesToProcess) AND Grade_Level__c != null]){
                
                if (programGradelevelMap.containsKey(gradeLevel.Academic_Program__c)) {
                    programGradelevelMap.get(gradeLevel.Academic_Program__c).add(gradeLevel);
                } else {
                    programGradelevelMap.put(gradeLevel.Academic_Program__c, new List<Program_Grade_Level__c>{gradeLevel});
                }
            }
        system.debug(programGradeLevelMap.size());
        //Updated below query to include FormallyExitedIEP__c field for Special_Educations__r query. For Bug #195028 on 2020-08-06 (Krishna Peddanagammol)
        List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c>([
            SELECT Id, LastSchoolType__c, EntranceAgeEligibilityOverride__c, EntranceAgeEligibilitySystem__c, 
            EntranceAgeEligibilityFinal__c, placementflag__c, WhyFlagged__c, Final_Grade_Level__c,Credit_for_HS_Coursework__c,
            hed__Account__r.AutomatedPlacementExclude__c, Start_Year__r.Start_Date__c, 
            hed__Account__r.Parent.Name, Program_Grade_Level__c, hed__Account__c, hed__Contact__r.Birthdate__c,
            (SELECT Id, Program_Enrollment__c,Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c,Program_Enrollment__r.Start_Year__r.Current_Year__c,
             Academic_Documentation_Summary__c,School_Year__r.Start_Date__c, LA_Placement_Level__c, Program_Enrollment__r.WaitlistFlag__c, Program_Enrollment__r.WhyFlagged__c,
             HowStudentPlacementCompleted__c, CoursesFinalized__c, Math_Placement_Level__c, Science_Placement_Level__c, Grade_Level_Requested__c, RecommendedAutoPlacement__c,
             Final_Grade_Level__c, GiftedProgramRequest_LA_M_S__c, Program_Enrollment__r.Start_Year__r.Start_Date__c, School_Year__c, APS_PlacedTimeStamp__c,Grade_Level_Completed__c,
			 Grade_8_Next_Years_Math_Course__c
             FROM Annual_Student_Information__r),
            (SELECT Id, Status_Reason__c, Type__c, Program_Enrollment__c FROM Enrollment_Documents__r),
            (SELECT Id, Level_Requested__c, Course_Requested__c FROM Placement_and_Elective_Requests__r),
            (SELECT Id, Program_Enrollment__c, IEP__c, FormallyExitedIEP__c FROM Special_Educations__r)
            FROM hed__Program_Enrollment__c
            WHERE Id in :pesToProcess
        ]);
        //Some Variables/Collections to Work with
        Map<Id, Annual_Student_Information__c> progEnrollmentToAsiMap = new Map<Id, Annual_Student_Information__c>();
        Map<Id, Annual_Student_Information__c> previousASIMap = new Map<Id, Annual_Student_Information__c>();

        Map<Id, List<Enrollment_Document__c>> enrollmentDocumentMap = new Map<Id, List<Enrollment_Document__c>>();
        Map<Id, Special_Education__c> specialEducationMap = new Map<Id, Special_Education__c>();
        //Map<Id, Prior_School__c> priorSchoolMap = new Map<Id, Prior_School__c>();
        Map<Id, Placement_and_Elective__c> pleMap = new Map<Id,Placement_and_Elective__c>();
       
        for(hed__Program_Enrollment__c pe : programEnrollments) {
            if(pe.Annual_Student_Information__r != null){
                for(Annual_Student_Information__c asi : pe.Annual_Student_Information__r){
                    if(asi.School_Year__c != null && asi.Program_Enrollment__r.Start_Year__c != null && asi.School_Year__c == asi.Program_Enrollment__r.Start_Year__c){
                        progEnrollmentToAsiMap.put(asi.Program_Enrollment__c, asi);
                        System.debug('asi.FinalGrade Level'+asi.Final_Grade_Level__c);
                    } else if (asi.School_Year__r.Start_Date__c <> null && asi.Program_Enrollment__r.Start_Year__r.Start_Date__c <> null &&
							   asi.School_Year__r.Start_Date__c == asi.Program_Enrollment__r.Start_Year__r.Start_Date__c.addYears(-1))
					{
						previousASIMap.put(asi.Program_Enrollment__c, asi);
					}
				}
            }
            if(pe.Enrollment_Documents__r != null){
                for (Enrollment_Document__c document : pe.Enrollment_Documents__r) {
                    if (enrollmentDocumentMap.containsKey(document.Program_Enrollment__c)) {
                        enrollmentDocumentMap.get(document.Program_Enrollment__c).add(document);
                    } else {
                        enrollmentDocumentMap.put(document.Program_Enrollment__c, new List<Enrollment_Document__c>{document});
                    }
                }
            }
            if(pe.Special_Educations__r != null){
                for (Special_Education__c specialEducation : pe.Special_Educations__r) {
                    specialEducationMap.put(specialEducation.Program_Enrollment__c, specialEducation);
                }
            }
            
            /**Removed 11/12/2019 - Alex Chisholm. Don't need to pull prior schools, just reference the most recent on the PE */
            /*if(pe.Prior_Schools__r != null){
                for(Prior_School__c school : pe.Prior_Schools__r){
                    if(school.School_Year__c != null && school.School_Year__c == pe.Start_Year__c){
                        priorSchoolMap.put(pe.Id, school);
                    }
                }
            }*/
            if(pe.Placement_and_Elective_Requests__r != null){
                for(Placement_and_Elective__c ple : pe.Placement_and_Elective_Requests__r){
                    pleMap.put(pe.Id, ple);
                }
            }
        //}
        /*
        System.debug('progEnrollmentToAsiMap++' + progEnrollmentToAsiMap);
        System.debug('enrollmentDocumentMap+++' + enrollmentDocumentMap);
        System.debug('specialEducationMap++' + specialEducationMap);
        System.debug('programEnrollments++' + programEnrollments);
        */
        // Removing as we already loop this list right before this. We can just used the one loop
        //for(hed__Program_Enrollment__c pe : programEnrollments) {
            Annual_Student_Information__c asi = progEnrollmentToAsiMap.get(pe.Id);
            asi.AutomatedPlacementExclude__c = false;

			Annual_Student_Information__c prevASI = previousASIMap.get(pe.Id);
            
            //Account Conditions
            if(pe.hed__Account__r.AutomatedPlacementExclude__c){
                asi.AutomatedPlacementExclude__c = true;
            }
            if (pe.placementflag__c!= null){
				if( pe.placementflag__c.startsWith('Principal Review') || pe.placementflag__c.startsWith('Awaiting Communication')){ 
            		asi.AutomatedPlacementExclude__c = true;
				}
            }
            system.debug(pe.ID + ' PE ID');
            system.debug(pe.hed__Account__c + ' PE Account');
            system.debug(pe.program_grade_level__c + ' PE PGL');
            //Grade Level Conditions
			/* Updated 11/10/2019 to fix prior school handling - Alex Chisholm */           
            if(progEnrollmentToAsiMap.containsKey(pe.Id) && programGradelevelMap.containsKey(pe.hed__Account__c)){
                for(Program_Grade_Level__c gradeLevel : programGradelevelMap.get(pe.hed__Account__c)){
                    System.debug('progEnrollmentToAsiMap.get(pe.Id).Final_Grade_Level__c'+progEnrollmentToAsiMap.get(pe.Id).Final_Grade_Level__c);
                    System.debug('gradeLevel.Grade_Level__r.Name'+gradeLevel.Grade_Level__r.Name);
                    if(pe.Program_Grade_Level__c == gradeLevel.Id){
                        if(gradeLevel.AutoplacementExclude__c){
                            asi.AutomatedPlacementExclude__c = true;
                        }
                        else if(pe.LastSchoolType__c == 'Public School' && gradeLevel.AutoPlacement_PublicExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                        else if(pe.LastSchoolType__c == 'Private/Parochial School' && gradeLevel.AutoPlacement_PrivateExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                        else if(pe.LastSchoolType__c == 'Homeschool' && gradeLevel.AutoPlacement_HomeExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                        else if(pe.LastSchoolType__c == 'None' && gradeLevel.AutoPlacement_NoneExclude__c){
                                asi.AutomatedPlacementExclude__c = true;
                            }
                            
                        else if(pe.LastSchoolType__c == null && gradeLevel.AutoPlacement_NoneExclude__c){
                            asi.AutomatedPlacementExclude__c = true;
                        }
                        //MM 3/5/2020  148152 specialEducationMap.get(pe.Id).IEP__c != null should be or'd with formallyExited == Yes
                        if(gradeLevel.AutoPlacement_Special_EdExclude__c && specialEducationMap.containsKey(pe.Id) && ( specialEducationMap.get(pe.Id).IEP__c != null  || specialEducationMap.get(pe.Id).FormallyExitedIEP__c =='Yes' )){
                            asi.AutomatedPlacementExclude__c = true;
                        }
					}
            	}        
            }
            
            /* Handle Kindergarten */
            String gradeRequested = asi.Grade_Level_Requested__c;
            if(gradeRequested == 'K' || gradeRequested == 'Kindergarten') {
                gradeRequested = '0';
            }

			String gradeCompleted;
			if (prevASI <> null && prevASI.Grade_Level_Completed__c <> null) {
				if(prevASI.Grade_Level_Completed__c == 'K' || prevASI.Grade_Level_Completed__c == 'Kindergarten') {
					gradeCompleted = '0';
				} else if (prevASI.Grade_Level_Completed__c.isNumeric()) {
                    gradeCompleted = prevASI.Grade_Level_Completed__c;
                }
			}

            //Program Enrollment Conditions
            if(pe.EntranceAgeEligibilityFinal__c != null && pe.EntranceAgeEligibilityFinal__c != 'Eligible'){
                System.debug('Ineligible:' +pe.EntranceAgeEligibilityFinal__c);
                asi.AutomatedPlacementExclude__c = true;
            }else if(pe.WhyFlagged__c != null && pe.WhyFlagged__c.contains('Disciplinary')){
                System.debug('In why flagged'+pe.WhyFlagged__c);
                asi.AutomatedPlacementExclude__c = true;
            }
            
            //ASI Conditions
            system.debug(pe.hed__Account__r.Parent.Name);
            if(asi.GiftedProgramRequest_LA_M_S__c != null){
                if(pe.hed__Account__r.Parent.Name.contains('NMCA') && asi.GiftedProgramRequest_LA_M_S__c != 'Math'){
                    asi.AutomatedPlacementExclude__c = true;
                }else{
                    asi.AutomatedPlacementExclude__c = true;
                }
            }else if(asi.Grade_Level_Requested__c == null || (asi.Grade_Level_Requested__c != null && Integer.valueOf(gradeRequested) > 9)){
                asi.AutomatedPlacementExclude__c = true;
            }else if(asi.Grade_Level_Requested__c != null && Integer.valueOf(gradeRequested) == 9){
                if(pe.Credit_for_HS_Coursework__c == 'Yes'){
                    asi.AutomatedPlacementExclude__c = true;
                }
                if(pleMap.containsKey(pe.Id)){
                    Placement_and_Elective__c ple = pleMap.get(pe.Id);
                    if(ple.Level_Requested__c != null && ple.Course_Requested__c != null){
                        if(
                            ple.Level_Requested__c != 'Standard' && 
                            (ple.Course_Requested__c == 'English' ||ple.Course_Requested__c == 'Math' || ple.Course_Requested__c == 'Science' 
                            ||ple.Course_Requested__c == 'Social Studies' || ple.Course_Requested__c == 'Math I' 
                            || ple.Course_Requested__c == 'Algebra 1' || ple.Course_Requested__c == 'Secondary Math 1')
                        ){
                            asi.AutomatedPlacementExclude__c = true;
                        }
                    }
                }
            } 
            
			if (!String.isBlank(gradeRequested) && !String.isBlank(gradeCompleted)) {
				if ( Integer.valueOf(gradeCompleted) ==  Integer.valueOf(gradeRequested) )
					asi.AutomatedPlacementExclude__c = true;  //Grade isn't changing
				else if ( Integer.valueOf(gradeRequested) -  Integer.valueOf(gradeCompleted) > 1 )
					asi.AutomatedPlacementExclude__c = true;  //Skipping a grade
			}
            
			if ( !String.isBlank(gradeRequested) && pe.hed__Contact__r.Birthdate__c != null ) {
	            Integer age = NES_AnnualStudentInformationUtilities.calculateAge(pe.hed__Contact__r.Birthdate__c);
				Integer diffBetweenGradeAndAge = age - Integer.valueOf(gradeRequested);
				if (diffBetweenGradeAndAge <= 3 || diffBetweenGradeAndAge >= 7)
					asi.AutomatedPlacementExclude__c = true;  //too young or too old for the grade they want.
			}
			
			if ( asi.Grade_8_Next_Years_Math_Course__c != null && asi.Grade_8_Next_Years_Math_Course__c == 'Pre-Algebra' && asi.Grade_Level_Requested__c == '8' )
				asi.AutomatedPlacementExclude__c = true;

            //Enrollment Document Conditions
            if(!pe.Enrollment_Documents__r.isEmpty() ){
                for(Enrollment_Document__c doc : pe.Enrollment_Documents__r){
                    if(doc.Type__c != null && doc.Type__c == 'IEP Exit Documentation' && doc.Status_Reason__c != null) {
                        String statusReason = doc.Status_Reason__c;
                        if(statusReason.contains('Reviewed') || statusReason.contains('Invalid') || statusReason.contains('Received') || statusReason.contains('Illegible') ||
                           statusReason.contains('No Documentation Available') || statusReason.contains('Missing') || statusReason.contains('Awaiting IEP')) {
                               asi.AutomatedPlacementExclude__c = true;
                           }
                    }
                }
            }
            asiListToBeUpdated.add(asi);
        }
        return asiListToBeUpdated;
    }
    
    /**************************************************************************
    ** Moved from NES_ECABusinessLogic by Alex Chisholm on 11/10/2019
    ** Method to calculate the student's Automated Placement Score
    **
    ***************************************************************************/
    public static List<Annual_Student_Information__c> calculatePlacementScore(Set<Id> programEnrollmentIds, List<Annual_Student_Information__c> asis){
        
        // Get all AnnualStudentInformation,Academic Information form programEnrollment
        Map<Id, hed__Program_Enrollment__c> ProgramEnrollments = new Map<Id, hed__Program_Enrollment__c>([
            SELECT
            Start_Year__r.Start_Date__c,
            PlacementFlag__c,
            EntranceAgeEligibilitySystem__c,
            EntranceAgeEligibilityOverride__c,
            EntranceAgeEligibilityFinal__c,
            WhyFlagged__c,
            First_Yr_Complete_HS_Coursework__c,
            hed__Credits_Attempted__c,
            hed__Contact__c,
            hed__Contact__r.Birthdate__c,
            Credit_for_HS_Coursework__c,
            SIF_AcademicSupportNeeds__c,
            SIFStudentRetained__c,
            Academic_Doc_Performance__c,
            SIF_SummerSchoolCourses__c,
            hed__Account__r.AutomatedPlacementExclude__c,
            hed__Account__c, (
                SELECT
                Id,
                School_Year__c,
                SchoolType__c,
                Program_Enrollment__c
                FROM Prior_Schools__r
                ORDER BY CreatedDate DESC
            ), (
                SELECT
                Id,
                IEPHistory__c,
                Plan504Exit__c,
                Plan504History__c,
                EvaluatedWithInLastYear__c
                FROM Special_Educations__r
                ORDER BY CreatedDate DESC
                LIMIT 1
            )
            FROM hed__Program_Enrollment__c
            WHERE Id IN:programEnrollmentIds
        ]);
        
        /* if Annual Student Information school Start Date is equal to programEnrollment school Start Date then
		populate studentInformationMap with Enrollment Id and Student Information object */
        
        Map<Id, Annual_Student_Information__c> studentInformationMap = new Map<Id, Annual_Student_Information__c>();
        if (!ProgramEnrollments.isEmpty()) {
            
            for (hed__Program_Enrollment__c prEn : ProgramEnrollments.values()) {
                System.debug(prEn);
                System.debug(asis);
                if (asis != null && asis.size() > 0) {
                    for (Annual_Student_Information__c studInfo : asis) {
                        if (studInfo.School_Year__c == prEN.Start_Year__c && studInfo.Program_Enrollment__c == prEn.Id) {
                            studentInformationMap.put(prEn.Id, studInfo);
                            
                        }
                    }
                } else {
                    for (Annual_Student_Information__c studInfo : prEn.Annual_Student_Information__r) {
                        if (studInfo.School_Year__c == prEN.Start_Year__c) {
                            studentInformationMap.put(prEn.Id, studInfo);
                            
                        }
                    }
                }
            }
        }
        
        List<Annual_Student_Information__c> studentInfoList = new List<Annual_Student_Information__c>();
        System.debug('studentInformationMap###' + studentInformationMap);
        // AutoPlacement Conditional Check for Each EnrollmentId
        for (Id EnrollmentId : ProgramEnrollments.keySet()) {
            Integer returnValue = 0;
            
            Integer GradeLevelRequested = 0;
            List<String> academicSupportValues = new List<String>();
            if (ProgramEnrollments.get(EnrollmentId).SIF_AcademicSupportNeeds__c != null) {
                academicSupportValues.addAll(ProgramEnrollments.get(EnrollmentId).SIF_AcademicSupportNeeds__c.split(';'));
            }
            if (studentInformationMap.containsKey(EnrollmentId) && studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null) {
                if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c == 'K' || studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c == 'Kindergarten') {
                    GradeLevelRequested = 0;
                } else {
                    GradeLevelRequested = Integer.valueOf(studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c);
                }
                
            }
            
            if(ProgramEnrollments.get(EnrollmentId) != null && studentInformationMap.get(EnrollmentId) != null) {
                if (ProgramEnrollments.get(EnrollmentId).hed__Contact__r.Birthdate__c != null && !String.isBlank(studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c)) {
                    Integer age = NES_AnnualStudentInformationUtilities.calculateAge(ProgramEnrollments.get(EnrollmentId).hed__Contact__r.Birthdate__c);
                    if(age - GradeLevelRequested <= 4 || age - GradeLevelRequested >= 6){
                        returnValue += 4;
                    }
                }
            }
            
            if (!academicSupportValues.contains('None') && academicSupportValues.size() > 2 && academicSupportValues != null) {
                returnValue += 5;
            }
            if (!academicSupportValues.contains('None') && academicSupportValues.size() <= 2 && academicSupportValues.size() > 0 &&
                academicSupportValues != null) {
                    returnValue += 2;
                }
            if (ProgramEnrollments.get(EnrollmentId).SIF_SummerSchoolCourses__c != null &&
                (ProgramEnrollments.get(EnrollmentId).SIF_SummerSchoolCourses__c == 'Yes' || ProgramEnrollments.get(EnrollmentId).SIF_SummerSchoolCourses__c == 'Unsure')) {
                    returnValue += 1;
                }
            if (ProgramEnrollments.get(EnrollmentId).SIFStudentRetained__c == 'Yes') {
                returnValue += 3;
            }
            if (ProgramEnrollments.get(EnrollmentId).Academic_Doc_Performance__c == 'No') {
                returnValue += 1;
            }
            if (!ProgramEnrollments.get(EnrollmentId).Prior_Schools__r.isEmpty()) {
                
                for(Prior_School__c ps : ProgramEnrollments.get(EnrollmentId).Prior_Schools__r) {
                    if(ps.SchoolType__c == 'Homeschool') {
                        returnValue += 1;
                        break;
                    }
                }
            }
            if (!ProgramEnrollments.get(EnrollmentId).Special_Educations__r.isEmpty() &&
                (ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].IEPHistory__c == 'Yes' ||
                 ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].Plan504History__c == 'Yes' ||
                 ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].Plan504Exit__c == 'Yes' ||
                 ProgramEnrollments.get(EnrollmentId).Special_Educations__r[0].EvaluatedWithInLastYear__c == 'Yes')) {
                     returnValue += 2;
                 }
            if(studentInformationMap.containsKey(EnrollmentId)) {
                if ( (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c != '') &&
                    GradeLevelRequested == 7) {
                        returnValue += 2;
                    } else if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && (GradeLevelRequested == 8 || GradeLevelRequested == 9)) {
                        returnValue += 3;
                    } else if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && GradeLevelRequested > 2 && GradeLevelRequested < 7) {
                        returnValue += 1;
                    } else if (studentInformationMap.get(EnrollmentId).Grade_Level_Requested__c <> null && GradeLevelRequested < 3) {
                        returnValue -= 20;
                    }
                studentInformationMap.get(EnrollmentId).AutomatedPlacementScore__c = returnValue;
                System.debug('Final ASI' + studentInformationMap.get(EnrollmentId));
                studentInfoList.add(studentInformationMap.get(EnrollmentId));
            }
        }
        return studentInfoList;
    }
    
    
    /****************************************************************************
    ** Created By Ritvik on 21-12-2018.
    ** Updated and moved to PlacementUtilities by Alex Chisholm on 11/10/2019
    ** purpose :This logic will be required to support grade level determination
    ** Params :List of program enrollment Ids
    *****************************************************************************/
    public static List<Annual_Student_Information__c> calculateAutomatedPlacementProcess(list<Id> progEnrollIds, List<Annual_Student_Information__c> asis) {
        System.debug('in calculateAutomatedPlacementProcess');
        
        //Set to store Annual Student Information record Ids.
        Set<Id> asiIds = new Set<Id>();
        
        //List to store all object record which needs to be updated.
        List<SObject> allObjectsUpdateList = new List<SObject>();
       
        //List to Store Program Enrollment record that is to be updated.
        List<hed__Program_Enrollment__c> programEnrollUpdateList = new List<hed__Program_Enrollment__c>();
        
        //Map which have Id as program enrollment Ids & value as Opportunity related to it.
        Map<Id, Opportunity> progEnrollIdsOpportunity = new Map<Id, Opportunity>();
        
        //Map which have Id as program enrollment Id & value as List of Records_Request__c record related to it.
        Map<Id, Set<Records_Request__c>> progEnrollIdsRecordsRequest_Map = new Map<Id, Set<Records_Request__c>>();

        //Iterating over Records_Request__c record & populate progEnrollIdsRecordsRequest_Map map.
        for (Records_Request__c recordsRequest : [SELECT Id,Secondary_Academic_Doc_Request__c,Program_Enrollment__c FROM Records_Request__c WHERE Program_Enrollment__c IN :progEnrollIds]) {
            if (!progEnrollIdsRecordsRequest_Map.containsKey(recordsRequest.Program_Enrollment__c)) {
                progEnrollIdsRecordsRequest_Map.put(recordsRequest.Program_Enrollment__c, new Set<Records_Request__c>{
                        recordsRequest
                });
            }
            progEnrollIdsRecordsRequest_Map.get(recordsRequest.Program_Enrollment__c).add(recordsRequest);
        }

        for (Opportunity opportunityRecord : [SELECT Lottery_Selection__c,Lottery_Selection_Date__c,Program_Enrollment__c FROM Opportunity WHERE Program_Enrollment__c IN :progEnrollIds]) {
            progEnrollIdsOpportunity.put(opportunityRecord.Program_Enrollment__c, opportunityRecord);
        }

        //Iterating over the Annual student information record with program enrollment id as passes in this method's parameter.
        for (Annual_Student_Information__c asiRecord : asis ) {

            if (asiRecord.School_Year__c == asiRecord.Program_Enrollment__r.Start_Year__c) {
                hed__Program_Enrollment__c programEnrollment = new hed__Program_Enrollment__c(Id = asiRecord.Program_Enrollment__c);

                if (asiRecord.AutomatedPlacementExclude__c) {
                    continue;
                } else if (asiRecord.AutomatedPlacementScore__c != null && asiRecord.AutomatedPlacementExclude__c == false &&
                        asiRecord.AutomatedPlacementScore__c <= asiRecord.Program_Enrollment__r.hed__Account__r.AutomatedPlacementMaxCutoff__c && asiRecord.LA_Placement_Level__c == null &&
                        asiRecord.Science_Placement_Level__c == null && asiRecord.Final_Grade_Level__c == null && asiRecord.Math_Placement_Level__c == null &&
                        (asiRecord.Grade_Level_Requested__c == '8' || asiRecord.Grade_Level_Requested__c == '7' || asiRecord.Grade_Level_Requested__c == '6' ||
                                asiRecord.Grade_Level_Requested__c == '5' || asiRecord.Grade_Level_Requested__c == '4' || asiRecord.Grade_Level_Requested__c == '3' ||
                                asiRecord.Grade_Level_Requested__c == '2' || asiRecord.Grade_Level_Requested__c == '1' || asiRecord.Grade_Level_Requested__c == 'K' || asiRecord.Grade_Level_Requested__c == 'Kindergarten')) {
					
					System.debug('made it past first hed__Account__r reference');
					//Mark Membrino 11/19/2019 Made changes for Gap Analysis trans K changes. Story 117570                    
                    if (asiRecord.Grade_Level_Requested__c == 'K' || asiRecord.Grade_Level_Requested__c == 'Kindergarten') {
						if (asiRecord.TransitionalKAcknowledgement__c == 'Yes') {
							asiRecord.LA_Placement_Level__c = 'Transitional K';
							asiRecord.Final_Grade_Level__c = 'Transitional K';
							asiRecord.Math_Placement_Level__c = 'Transitional K';
							asiRecord.Science_Placement_Level__c = 'Transitional K';
						} else {
							asiRecord.LA_Placement_Level__c = 'K';
							asiRecord.Final_Grade_Level__c = 'K';
							asiRecord.Math_Placement_Level__c = 'K';
							asiRecord.Science_Placement_Level__c = 'K';
						}
                    } else if (asiRecord.Grade_Level_Requested__c == '8') {
                        asiRecord.Math_Placement_Level__c = asiRecord.Program_enrollment__r.hed__account__r.grade8math__c;
                        asiRecord.Final_Grade_Level__c = '8';
                        asiRecord.LA_Placement_Level__c = '8';
                        asiRecord.Science_Placement_Level__c = '8';
                    } else if (asiRecord.Grade_Level_Requested__c == '7') {
                        asiRecord.Math_Placement_Level__c = asiRecord.Program_enrollment__r.hed__account__r.grade7math__c;
                        asiRecord.Final_Grade_Level__c = '7';
                        asiRecord.LA_Placement_Level__c = '7';
                        asiRecord.Science_Placement_Level__c = '7';
                    } else {
                        asiRecord.LA_Placement_Level__c = asiRecord.Grade_Level_Requested__c;
                        asiRecord.Science_Placement_Level__c = asiRecord.Grade_Level_Requested__c;
                        asiRecord.Final_Grade_Level__c = asiRecord.Grade_Level_Requested__c;
                        asiRecord.Math_Placement_Level__c = asiRecord.Grade_Level_Requested__c;
                    }

                    programEnrollment = asiRecord.Program_Enrollment__r;
                    programEnrollment.PlacementFlag__c = null;

                    /* Records_Request__c - populating Secondary_Academic_Doc_Request__c field
                    ** Alex - Removing 11/10/2019. I don't think this is needed
                    if (!progEnrollIdsRecordsRequest_Map.isEmpty() && progEnrollIdsRecordsRequest_Map.containsKey(asiRecord.Program_Enrollment__c)) {
                        for (Records_Request__c recordsRequest : progEnrollIdsRecordsRequest_Map.get(asiRecord.Program_Enrollment__c)) {
                            recordsRequest.Secondary_Academic_Doc_Request__c = null;
                            allObjectsUpdateList.add(recordsRequest);
                        }
                    }*/

                    asiRecord.CoursesFinalized__c = 'Yes';
                    asiRecord.HowStudentPlacementCompleted__c = 'Standard Auto-Placement Process';

                    /*Calculate Program_Enrollment__c .StudentFlag__c - REMOVED 11/10/2019
                    if (!isMatch(asiRecord.Program_Enrollment__r.WaitlistFlag__c, 'Active', false) &&
                            !isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Eligibility', false) &&
                            !isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Disciplinary History', false) &&
                            !isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Special Education', false) &&
                            !isMatch(asiRecord.Program_Enrollment__r.WhyFlagged__c, 'Placement', false)) {
                        programEnrollment.StudentFlag__c = null;
                    } else if (asiRecord.Program_Enrollment__r.WhyFlagged__c == null) {
                        programEnrollment.StudentFlag__c = 'Released';
                    } else {
                        programEnrollment.StudentFlag__c = 'On-Hold';
                    }*/

                    /*Alex Removed 11/10/2019 - Why is this here? Nothing about placement is relevant to the determination of this data.
                    ** Calculate Opportunity.Lottery_Selection__c
                    if (!progEnrollIdsOpportunity.isEmpty() && progEnrollIdsOpportunity.containsKey(asiRecord.Program_Enrollment__c)) {
                        if (progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c).Lottery_Selection_Date__c != null) {
                            progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c).Lottery_Selection__c = 'Selected';
                        } else {
                            progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c).Lottery_Selection__c = 'Not Selected';
                        }
                    }*/

                    // Calculate Annual_Student_Information__c.APS_PlacedTimeStamp__c
                    if (asiRecord.Program_Enrollment__r.Start_Year__r.Current_Year__c == true &&
                            asiRecord.APS_PlacedTimeStamp__c == null && asiRecord.CoursesFinalized__c == 'Yes') {
                        asiRecord.APS_PlacedTimeStamp__c = System.now();
                    }

                    /*if (!programEnrollUpdateList.contains(programEnrollment)) {
                        allObjectsUpdateList.add(programEnrollment);
                    }*/

                    asiIds.add(asiRecord.Id);
                    //allObjectsUpdateList.add(progEnrollIdsOpportunity.get(asiRecord.Program_Enrollment__c));
                }
            }

        }
        /*Checking for sObject List that is to be updated is empty or not.
        if (!allObjectsUpdateList.isEmpty()) {
            try {
                update allObjectsUpdateList;
            } catch (Exception e) {
                System.debug('Exception :::' + e.getMessage());
                //logger.logException('calculateAutomatedPlacementProcess', e);
                //logger.saveLogs();
            }
        }*/
        return asis;
    }
}