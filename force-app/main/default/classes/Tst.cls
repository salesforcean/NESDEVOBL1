public class Tst {
    
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_ITRUtilities');
    public static ReEnrResults reenrollingStudent(Id studentId, Id studentPEId){
        Peak_Response peakResponse = new Peak_Response();
        // The logic will be the same as adding a new student except the below:
        // Student will not be created
        // Caretaker will not be created
        // Opportunity will be created
        // 
        
        try{
            NES_ECACompletion.shouldRunCompletion = false;
            NES_Constants.runAssignment = false;
            NES_LTSUtility.runLTSFlag = false;
            NES_ProgramEnrollmentHandler.runCBL = false;
            
            // Get the Student Contact
            List<Contact> studentContact = [Select Id, FirstName,AccountId, LastName from contact where Id =: studentId];
            
            // Get the Student PE Record
            hed__Program_Enrollment__c studentPERecord = [Select Id,Start_Year__c,Program_Grade_Level__r.Grade_Level__r.Name,Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c,hed__Account__r.ParentId, hed__Account__c, OwnerId 
                                                          																from hed__Program_Enrollment__c where Id=:studentPEId limit 1];
            
            // Get Grade Level
            String peGradeLevel = studentPERecord?.Program_Grade_Level__r?.Grade_Level__r?.Name;
            
            Id caretakerEnrollmentId = studentPERecord.Household_Program_Enrollment__c;
            // Get the Academic Program
            List<Account> AcademicProgram  = [Select Id,OwnerId,ParentId,Confirmation_End_Date__c,School_Year__c,Registration_Start_Date__c,Registration_End_Date__c 
                                              					from Account where ParentId =:studentPERecord.hed__Account__r.ParentId 
                                              					and Id =:studentPERecord.hed__Account__c ] ;    

			// Get the Caretake PE Record            
            List<hed__Program_Enrollment__c> caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = : studentPERecord.Household_Program_Enrollment__r.hed__Contact__c AND hed__Account__c = :AcademicProgram[0].Id];
                
            // Create the Opportunity Record
            Opportunity oppToInsert = new Opportunity(
                        Name = studentContact[0].FirstName + ' ' + studentContact[0].LastName + ' Opportunity',
                        OwnerId = AcademicProgram[0].OwnerId,
                        Caretaker_Id__c = studentPERecord.Household_Program_Enrollment__r.hed__Contact__c,
                        Student_Id__c = studentId,
                        AccountId = studentContact[0].AccountId,
                        Program_Enrollment__c = studentPERecord.Id,
                        StageName = 'Open',
                        CloseDate = AcademicProgram[0].Confirmation_End_Date__c == null ? Date.today() : AcademicProgram[0].Confirmation_End_Date__c.date()
            );

            insert oppToInsert;  
            
            List<Enrollment_Component__c> processComponent = [
                        SELECT Id, Assignment_Logic__c
                        FROM Enrollment_Component__c
                        WHERE Process_Academic_Program__c = :AcademicProgram[0].Id
                        AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                        LIMIT 1
                ];

            //Get all the stages
            List<Enrollment_Component_Relationship__c> relationships = [
                SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c,
                Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN :processComponent
                AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
                ORDER BY Order__c ASC
            ];
            
            // Create a Map of EC and Relationship Record
            Map <String, Enrollment_Component_Relationship__c> ecTORelMap = new Map <String, Enrollment_Component_Relationship__c> ();
            for(Enrollment_Component_Relationship__c rel: relationships){
                ecTORelMap.put(rel.Child_Enrollment_Component__c, rel);                
            }
            
            // Get the list of ECAs under this PE
            List <Enrollment_Component_Affiliation__c> currEcaList = [Select Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Order__c from 
                                                                     Enrollment_Component_Affiliation__c where Program_Enrollment__c =: studentPERecord.Id];
            
            // Create a Map of EC and ECA records
            Map <String, Enrollment_Component_Affiliation__c> ecTOECAMap = new Map <String, Enrollment_Component_Affiliation__c> ();
            for(Enrollment_Component_Affiliation__c eca: currEcaList){
                ecTOECAMap.put(eca.Enrollment_Component__c, eca);                
            }
            
            List <Enrollment_Component_Affiliation__c> updEcaList = new List <Enrollment_Component_Affiliation__c> ();
            // Start updating the ECAs to reflect the Initial Enrollment
            for(Enrollment_Component_Affiliation__c eca: currEcaList){
                // Update process affiliation
                if(eca.Enrollment_Component__c == processComponent[0].Id){
                    eca.Status__c = 'In Progress'; 
                    updEcaList.add(eca);                    
                }
                //Update stage 1 affiliation
                if(eca.Enrollment_Component__c == relationships[0].Child_Enrollment_Component__c){
                    eca.Status__c = 'Complete'; 
                    updEcaList.add(eca);                    
                }
            }
            
            //Update the rest of the stages that have no assignment logic.
            for (Integer i = 1; i < relationships.size(); i++) {
                    if (String.isBlank(relationships[i].Child_Enrollment_Component__r.Assignment_Logic__c)) {                
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord = ecTOECAMap.get(relationships[i].Child_Enrollment_Component__c);
                        //The second stage should be in progress all others not started.
                        if (i == 1)
                            affiliationRecord.Status__c = 'In Progress';
                        else
                            affiliationRecord.Status__c = 'Not Started';
                        updEcaList.add(affiliationRecord);
                    }
                } 
            
            update updEcaList;   
            PerformAsyncReEnrStudentSteps(studentPEId,processComponent[0].Id,caretakerEnrollmentId, '' );
            ReEnrResults result = new ReEnrResults(studentPEId , processComponent[0].Id, peGradeLevel);
            return result;
        
    }
        catch(Exception e){
            peakResponse.success = false;
            peakResponse.messages.add('Could not create ReEnrollment process');
            system.debug('exception*************'+e.getMessage());
            logger.logException('There is some issue with the Re-Enrollment Process'+studentPEId, e);
            logger.saveLogs();
            return null;
        }

}
    
    
    
    @future 
    public static void PerformAsyncReEnrStudentSteps( Id programEnrollment,  Id processId, Id caretakerEnrollmentId, String EnrollmentType)

    {
        //This method is called from Add a student process. Runs as a future method.  Will create the remaining ECAs and all the PE Criteria Records.

        //Retrieve the ECR tree.
        NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
		NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(processId);
        //Retrieve all the ECRs for this process
        List<Enrollment_Component_Relationship__c> allECRs = new list <Enrollment_Component_Relationship__c> ();
        allECRs.addAll(thisProcessData.stageRelationships);
        allECRs.addAll(thisProcessData.formRelationships);
        allECRs.addAll(thisProcessData.sectionRelationships);
        allECRs.addAll(thisProcessData.questionGroupRelationships);
        allECRs.addAll(thisProcessData.questionRelationships);

        
        // Get the list of ECAs under this PE
        List <Enrollment_Component_Affiliation__c> currEcaList = [Select Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Order__c from 
                                                                  Enrollment_Component_Affiliation__c where Program_Enrollment__c =: programEnrollment];
        
        List <Enrollment_Component_Affiliation__c> updEcaList = new List <Enrollment_Component_Affiliation__c> ();
        
        // Create a Map of EC and ECA records
        Map <String, Enrollment_Component_Affiliation__c> ecTOECAMap = new Map <String, Enrollment_Component_Affiliation__c> ();
        for(Enrollment_Component_Affiliation__c eca: currEcaList){
            ecTOECAMap.put(eca.Enrollment_Component__c, eca);                
        }
        
        
        Set<id> allECs = new set <Id>();  // Holds all the Enrollment Components for this Academic Program

        Set<id> allQuestionECs = new set <Id>();  // Holds all the Enrollment Components that are questions so we can use that list later to set initial values.

        //Add all the ECAs that have not already been added.  The ones with assignment criteria should be 'Not Started' the ones
        //with assignment criteria should be 'Not Applicable' for now.  If their assignment criteria is met, it will get switched to not started.
        //We also don't want to create ECAs for Questions, Question Groups, Messages and Text.  The community will retrieve
        //what should appear within a section based on the ECRs instead of the ECAs.
        for (Enrollment_Component_Relationship__c ecr : allECRs) {
            //Determine if it is one of the excluded record types.
            boolean ECANotNeededForThisRecType = false;
            if ( ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.HIDDEN_INPUT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.TEXT_RT ||
                ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT )
                    ECANotNeededForThisRecType = true;

                if (!ECANotNeededForThisRecType) {
                    Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                    affiliationRecord = ecTOECAMap.get(ecr.Child_Enrollment_Component__c);
    
                    if (String.isBlank(ecr.Child_Enrollment_Component__r.Assignment_Logic__c) ) 
                        affiliationRecord.Status__c = 'Not Started';
                    else
                        affiliationRecord.Status__c = 'Not Applicable';
    
                    updEcaList.add(affiliationRecord);
                }

            //While we are looping over the ECRs, collect all the ECs for this process so we can retrieve all the required criteria.
            allECs.add(ecr.Child_Enrollment_Component__c);


            if (ecr.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT)
                allQuestionECs.add(ecr.Child_Enrollment_Component__c);
        }

        if (updEcaList.size() > 0)
            update updEcaList;


        //Mark the PE as In Progress and Ready to be shown to the caretaker in the community.
        hed__Program_Enrollment__c pe = new hed__Program_Enrollment__c (id = programEnrollment, Initial_ECA_Creation_Complete__c = true, status__c = 'In Progress');
        update pe;

		System.enqueueJob(new NES_AddStudentCBLQueueable(programEnrollment));       
    }
    
    public class ReEnrResults{
        @AuraEnabled public Id programEnrollmentId{get;set;}
        @AuraEnabled public Id processId{get;set;}
        @AuraEnabled public String gradeLevel{get;set;}
        public ReEnrResults(Id programEnrollmentId, Id processId, String gradeLevel){
            this.programEnrollmentId = programEnrollmentId;
            this.processId = processId;
            this.gradeLevel = gradeLevel;
        }
    }
    
}