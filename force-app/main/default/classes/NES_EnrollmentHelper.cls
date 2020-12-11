/**
* Created by triciaigoe on 12/26/18. 
* 2019-12-30 modified for #124409 Bug (Maddileti Boya) [from line no 267 to 270]
* Added code by viswa for #182050 User Story (When a student inactivates who was prev withdrawn, set them to withrawn) on 2020-05-15
*/

public without sharing class NES_EnrollmentHelper {
    
    private static Peak_ApexLog logger = new Peak_ApexLog('EnrollmentHelper');
    
    /**
* Created by Ashish Sharma on 12/05/18
* Parameters: ID
* Return Type: List<Enrollment_Component_Affiliation__c>
* Purpose : This method is used to retreive and return the enrollment components' information (Stage Record Type) of the related programEnrollmentId
Using Enrollment_Component_Affiliation__c object here as this is defining the relationship between Enrollment_Component__c
and Program_Enrollment__c objects
*/
    public static List<Enrollment_Component_Affiliation__c> getRelatedStages(Id programEnrollmentId){
        try{
            /*
Retreive and return the enrollment components' information (Stage Record Type) of the related programEnrollmentId
Using Enrollment_Component_Affiliation__c object here as this is defining the relationship between Enrollment_Component__c
and Program_Enrollment__c objects
*/
            if(programEnrollmentId != null){
                List<Enrollment_Component_Affiliation__c> enrollmentComponents = new List<Enrollment_Component_Affiliation__c>();
                for(Enrollment_Component_Affiliation__c eca : [SELECT Enrollment_Component__r.Name, Status__c, Order__c, Program_Enrollment__r.Final_Grade_Level__c
                                                               FROM Enrollment_Component_Affiliation__c
                                                               WHERE Program_Enrollment__c =: programEnrollmentId
                                                               AND Enrollment_Component__r.RecordType.Name =: NES_DashboardUtilities.STAGE_RT
                                                               AND status__c <> 'Not Applicable']){
                                                                   enrollmentComponents.add(eca);
                                                               }
                
                return enrollmentComponents;
            }
            
            return null;
        } catch(Exception e){logger.logException('getRelatedStages', e);logger.saveLogs();return null;
                            }
    }
    
    /**
* Created by Ashish Sharma on 12/05/18
* Parameters: ID
* Return Type: List<Enrollment_Component__c>
* Purpose : This method is used to retreive and return the enrollment components' information (Message Record Type) of the related enrollmentComponentId
Using Enrollment_Component_Relationship__c object here as this is defining the relationship between Parent_Enrollment_Component__c
and Parent_Enrollment_Component__c objects
*/
    public static List<Enrollment_Component__c> getRelatedMessages(Id enrollmentComponentId, Id programEnrollmentId){
        Id messageRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get(NES_DashboardUtilities.MESSAGE_RT).getRecordTypeId();
        List<Enrollment_Component__c> enrollmentComponentsList = new List<Enrollment_Component__c>();
        List<Id> messageIds = new List<Id>();
        List<Enrollment_Component_Affiliation__c> allAffiliations = [SELECT Id, Enrollment_Component__c, Status__c FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c = : programEnrollmentId];
        
        List<Id> affiliationIds = new List<Id>();
        for(Enrollment_Component_Affiliation__c affiliation : allAffiliations) {
            if(affiliation.Status__c == 'Not Started') {
                affiliationIds.add(affiliation.Enrollment_Component__c);
            }
        }
        List<Enrollment_Component_Relationship__c> messageRelationships = new List<Enrollment_Component_Relationship__c>();
         if(affiliationIds.size() > 0){
			messageRelationships = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c
                                                                           WHERE Parent_Enrollment_Component__c =: enrollmentComponentId
                                                                           AND Child_Enrollment_Component__r.RecordTypeId =: messageRecordTypeId
                                                                           AND Child_Enrollment_Component__c IN : affiliationIds
                                                                           ORDER BY Order__c];
		}
		else{
			messageRelationships = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c
                                                                           WHERE Parent_Enrollment_Component__c =: enrollmentComponentId
                                                                           AND Child_Enrollment_Component__r.RecordTypeId =: messageRecordTypeId
                                                                           ORDER BY Order__c];
			
		}
        for(Enrollment_Component_Relationship__c rel : messageRelationships){
            messageIds.add(rel.Child_Enrollment_Component__c);
        }
        
        if(messageIds.size() > 0){
            enrollmentComponentsList = [SELECT Id, Component_Message__c, Order__c FROM Enrollment_Component__c WHERE Id IN: messageIds ORDER BY Order__c];
        }
        
        return enrollmentComponentsList;
    }
    
    /**
* Created by Ashish Sharma on 12/05/18
* Parameters: ID
* Return Type: NES_DashboardUtilities.Process
* Purpose : This method is used to get the related Child enrollment component of STAGE_RT record type using processComponentId
and using those child components get the required information
*/
    public static NES_DashboardUtilities.Process getProcessInformation(Id processComponentId, Id programEnrollmentId){
        try{
            /*
Get the related Child enrollment component of STAGE_RT record type using processComponentId
and using those child components get the required information
*/
            if(processComponentId != null){
                Set<Id> enrollmentComponentIds = new Set<Id>();
                Enrollment_Component__c enrollment = new Enrollment_Component__c();
                
                //query for stages related to the process passed into function
                for(Enrollment_Component__c temp : [SELECT Id, Name, (SELECT Child_Enrollment_Component__c,
                                                                      Child_Enrollment_Component__r.Name,
                                                                      Child_Enrollment_Component__r.Order__c
                                                                      FROM Enrollment_Component_Relationships__r
                                                                      WHERE Child_Enrollment_Component__r.RecordType.Name =: NES_DashboardUtilities.STAGE_RT)
                                                    FROM Enrollment_Component__c WHERE Id =: processComponentId
                                                    AND RecordType.Name =: NES_DashboardUtilities.PROCESS_RT]) {
                                                        enrollment = temp;
                                                        //add process to list of ECs
                                                        enrollmentComponentIds.add(temp.Id);
                                                        
                                                        //if relationships exist, add stages to list of ECs
                                                        if(temp.Enrollment_Component_Relationships__r != null &&
                                                           temp.Enrollment_Component_Relationships__r.size() > 0){
                                                               
                                                               for(Enrollment_Component_Relationship__c ecr : temp.Enrollment_Component_Relationships__r){
                                                                   enrollmentComponentIds.add(ecr.Child_Enrollment_Component__c);
                                                               }
                                                           }
                                                    }
                
                Map<Id, String> ecaStatusMap = new Map<Id, String>();
                //get ECAs of all of the ECs
                for(Enrollment_Component_Affiliation__c temp : [SELECT Enrollment_Component__c, Status__c
                                                                FROM Enrollment_Component_Affiliation__c
                                                                WHERE Enrollment_Component__c IN: enrollmentComponentIds AND Program_Enrollment__c = : programEnrollmentId]){
                                                                    ecaStatusMap.put(temp.Enrollment_Component__c, temp.Status__c);
                                                                    
                                                                }
                
                hed__Program_Enrollment__c programEnrollment = [SELECT Id, Status__c FROM hed__Program_Enrollment__c WHERE Id = : programEnrollmentId];
                
                List<NES_DashboardUtilities.Stage> stages = new List<NES_DashboardUtilities.Stage>();
                
                if(enrollment.Enrollment_Component_Relationships__r != null &&
                   enrollment.Enrollment_Component_Relationships__r.size() > 0){
                       
                       for(Enrollment_Component_Relationship__c ecr : enrollment.Enrollment_Component_Relationships__r){
                           stages.add(new NES_DashboardUtilities.Stage(ecr.Child_Enrollment_Component__r.Name,
                                                                       (ecaStatusMap.containsKey(ecr.Child_Enrollment_Component__c) ?
                                                                        ecaStatusMap.get(ecr.Child_Enrollment_Component__c) : ''),
                                                                       Integer.valueOf(ecr.Child_Enrollment_Component__r.Order__c)));
                       }
                   }
                
                return new NES_DashboardUtilities.Process(enrollment.Name, programEnrollment.Status__c,
                                                          stages);
            }
            
            return null;
        }catch(Exception e){logger.logException('getProcessInformation', e); logger.saveLogs(); return null;
                           }
    }
    
    /**
* Created by Ashish Sharma on 12/05/18
* Parameters: ID
* Return Type: List<NES_DashboardUtilities.Form>
* Purpose : This method is used to get the related Child enrollment component of FORM_RT record type using stageComponentId
and using those child components get the required form information
*/
    public static List<NES_DashboardUtilities.Form> getRelatedForms(Id stageComponentId, Id programEnrollmentId){
        try{
            /*
Get the related Child enrollment component of FORM_RT record type using stageComponentId
and using those child components get the required form information
*/
            if(stageComponentId != null){
                Set<Id> formIds = NES_EvaluateUtil.getChildComponentIds(new Set<Id>{stageComponentId}, new Set<String>{NES_DashboardUtilities.STAGE_RT}, new Set<String>{NES_DashboardUtilities.FORM_RT});
                
                if(formIds.size() > 0){
                    List<NES_DashboardUtilities.Form> forms = new List<NES_DashboardUtilities.Form>();
                    
                    for(Enrollment_Component__c temp : [SELECT Id, Name, Component_Message__c,Document_Submission_Start_Date__c, Document_Submission_End_Date__c,
                                                        (SELECT Status__c, Deferral_Date__c, Order__c FROM Enrollment_Component_Affiliation__r
                                                         WHERE Program_Enrollment__c =: programEnrollmentId)
                                                        FROM Enrollment_Component__c
                                                        WHERE Id IN: formIds]){
                                                            
                                                            if(temp.Enrollment_Component_Affiliation__r != null && temp.Enrollment_Component_Affiliation__r.size() > 0){
                                                                
                                                                for(Enrollment_Component_Affiliation__c eca : temp.Enrollment_Component_Affiliation__r){
                                                                    //exempt the form if affiliation status is exempt and deferred, and if deferred then Deferral_Date__c is in past
                                                                    /*
* Updated by Krishna Reddy P on 08/07/2019 for User Story: 101933
* Purpose: Added additional condition in if statement to check for 'Not Applicable' Status. 
* 			A new constant is added at NES_DashboardUtilities.NOTAPPLICABLE_STATUS 				 
*/ 
                                                                    if(eca.Status__c != NES_DashboardUtilities.EXEMPT_STATUS && eca.Status__c != NES_DashboardUtilities.NOTAPPLICABLE_STATUS)
                                                                    {
                                                                        forms.add(new NES_DashboardUtilities.Form(temp.Name, eca.Status__c, temp.Component_Message__c, temp.Id, eca.Order__c));                                        
                                                                    }
                                                                }
                                                            }
                                                        }
                    
                    return forms;
                }
            }
            return null;
        }catch(Exception e){logger.logException('getRelatedForms', e);logger.saveLogs();return null;
                           }
    }
    
    /**
* Created by Ashish Sharma on 12/05/18
* Parameters: ID
* Return Type: List<NES_DashboardUtilities.RelatedFormContent>
* Purpose : This method is used to get the related Child enrollment component of SECTION_RT and DOCUMENT_RT record type using formComponentId
and using those child components get the required component information
*/
    public static List<NES_DashboardUtilities.RelatedFormContent> getRelatedFormContent(Id formComponentId, Id programEnrollmentId){
        try{
            if(formComponentId != null){
                /*
Get the related Child enrollment component of SECTION_RT and DOCUMENT_RT record type using formComponentId
and using those child components get the required component information
*/
                Set<Id> relatedComponentIds = NES_EvaluateUtil.getChildComponentIds(new Set<Id>{formComponentId}, new Set<String>{NES_DashboardUtilities.FORM_RT},
                                                                                    new Set<String>{NES_DashboardUtilities.SECTION_RT, NES_DashboardUtilities.DOCUMENT_RT});
                
                if(relatedComponentIds.size() > 0){
                    List<NES_DashboardUtilities.RelatedFormContent> relatedFormComponents = new List<NES_DashboardUtilities.RelatedFormContent>();
                    //US #227705 Date: 09/22/2020 Krishna Peddanagammol : Included Deferral_Date__c in the soql
                    List<Enrollment_Component_Affiliation__c> componentAffiliations = [SELECT Status__c, Deferral_Date__c, Enrollment_Component__r.Name, Enrollment_Component__r.Id, Enrollment_Component__r.Component_Message__c, Enrollment_Component__r.RecordType.Name,
                                                                                       Program_Enrollment__r.hed__Account__r.Document_Start_Date__c, Order__c, Program_Enrollment__r.Final_Grade_Level__c,
                                                                                       Program_Enrollment__r.hed__Account__r.Document_End_Date__c, Program_Enrollment__r.hed__Contact__r.Account.Document_Extension_Date__c,
                                                                                       Program_Enrollment__r.hed__Contact__r.Document_Extension_Date__c, Program_Enrollment__r.Program_Grade_Level__r.Grade_Level__r.Name,
                                                                                       (SELECT Id, Status_Reason__c FROM Enrollment_Documents__r)
                                                                                       FROM Enrollment_Component_Affiliation__c
                                                                                       WHERE Program_Enrollment__c =: programEnrollmentId
                                                                                       AND Enrollment_Component__c IN : relatedComponentIds];
                    
                    //Mark Membrino 10/1/2020  Commented out the following Code because none of it is needed.
                    //List<Id>programEnrollmentIds = new List<Id>();
                    //for(Enrollment_Component_Affiliation__c eca : componentAffiliations){
                    //    programEnrollmentIds.add(eca.Program_Enrollment__c);
                    //}
                    //List<Annual_Student_Information__c> asis = [SELECT Id, Grade_Level_Requested__c, Program_Enrollment__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN: programEnrollmentIds];
                    // Map<Id,String> asiMap = new Map<Id,String>();
                    //  for(Annual_Student_Information__c asi : asis) {
                    //       asiMap.put(asi.Program_Enrollment__c, asi.Grade_Level_Requested__c);
                    //   }
                    
                    //query for component information for documents and sections realted to the form passed in by parameter
                    for(Enrollment_Component_Affiliation__c eca : componentAffiliations){
                        
                        //If the final grade level isn't set, let's pass in the requested grade level to use
                        DateTime documentStartDate = NES_EnrollmentUtils.getDocumentStartDate(eca.Program_Enrollment__r.hed__Account__c, eca.Program_Enrollment__r.Program_Grade_Level__r.Grade_Level__r.Name);
                        DateTime documentEndDate = NES_EnrollmentUtils.getDocumentEndDate(eca.Program_Enrollment__r.hed__Account__c, eca.Program_Enrollment__r.Program_Grade_Level__r.Grade_Level__r.Name);
                        logger.logInfo('getRelatedFormContent', 'Dates for ECA: '+eca+', '+documentStartDate+', '+documentEndDate);
                        
                        String docStatus = '';
                        System.debug('eca.Status__c::'+eca.Status__c);
                        if(eca.Status__c == 'In Progress') { 
                            docStatus = 'Submitted';
                        }
                        // Added by Maddileti for #124409 bug  
                        else if(eca.Status__c == 'Complete') {
                            docStatus = 'Complete';
                        }
                        
                        // end by Maddileti for #124409 bug
                        else if(eca.Enrollment_Documents__r.size() > 0) { docStatus = 'Submitted';  }
                        
                        //Do not pass enrollment component to the form if it is exempt
                        /*
* Updated by Krishna Reddy P on 08/20/2019 for User Story: 101933 Fixd for Bug #106393
* Purpose: Added additional condition in if statement to check for 'Not Applicable' Status. 
* 			A new constant is added at NES_DashboardUtilities.NOTAPPLICABLE_STATUS 				 
*/
                        if(eca.Status__c != NES_DashboardUtilities.EXEMPT_STATUS && eca.Status__c != NES_DashboardUtilities.NOTAPPLICABLE_STATUS ) {                                 
                            //check document dates detailed by the academic program attached to the program enrollment
                            if(eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.DOCUMENT_RT && (System.today() >= documentStartDate && System.today() <= documentEndDate)) {
                                System.debug('adding a document within normal academic program dates: ' + eca.Enrollment_Component__r);
                                relatedFormComponents.add(new NES_DashboardUtilities.RelatedFormContent(eca.Enrollment_Component__r.Name, eca.Status__c, eca.Id, eca.Enrollment_Component__r.Component_Message__c,
                                                                                                        Integer.valueOf(eca.Order__c), eca.Enrollment_Component__r.Id, eca.Enrollment_Component__r.RecordType.Name, docStatus));
                                
                                //check for document extensions detailed on the household account of the contact & the contact record of the student
                            } else if(eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.DOCUMENT_RT && (System.today() <= eca.Program_Enrollment__r.hed__Contact__r.Account.Document_Extension_Date__c || System.today() <= eca.Program_Enrollment__r.hed__Contact__r.Document_Extension_Date__c)){
                                
                                relatedFormComponents.add(new NES_DashboardUtilities.RelatedFormContent(eca.Enrollment_Component__r.Name, eca.Status__c, eca.Id, eca.Enrollment_Component__r.Component_Message__c,
                                                                                                        Integer.valueOf(eca.Order__c), eca.Enrollment_Component__r.Id, eca.Enrollment_Component__r.RecordType.Name, docStatus));
                                //adding document if there is no document date range defined
                            } else if(eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.DOCUMENT_RT && (documentStartDate == null && documentEndDate == null)){
                                
                                relatedFormComponents.add(new NES_DashboardUtilities.RelatedFormContent(eca.Enrollment_Component__r.Name, eca.Status__c, eca.Id, eca.Enrollment_Component__r.Component_Message__c, Integer.valueOf(eca.Order__c), eca.Enrollment_Component__r.Id, eca.Enrollment_Component__r.RecordType.Name, docStatus));
                                
                                //add all non document form elements
                            } else if(eca.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.SECTION_RT) {
                                
                                relatedFormComponents.add(new NES_DashboardUtilities.RelatedFormContent(eca.Enrollment_Component__r.Name, eca.Status__c, eca.Id, eca.Enrollment_Component__r.Component_Message__c,
                                                                                                        Integer.valueOf(eca.Order__c), eca.Enrollment_Component__r.Id, eca.Enrollment_Component__r.RecordType.Name, docStatus));
                                
                            } else {
                                
                                //if all else fails for a document, debug
                                System.debug('acceptable date ranges: AP: ' + eca.Program_Enrollment__r.hed__Account__r + 'AP Doc Start|End: ' + documentStartDate + '|' + documentEndDate + ' Extension Date: ' + eca.Program_Enrollment__r.hed__Contact__r.Document_Extension_Date__c);
                            }
                        }
                    }
                    logger.saveLogs();
                    return relatedFormComponents;
                }
                
            }
            
            return null;
        }catch(Exception e){logger.logException('getRelatedFormContent', e);logger.saveLogs();return null;
                           }
    }
    
    // grab the caretakers associated with a student
    public static Peak_Response grabCaretakers(Id studentId) {
        Peak_Response peakResponse = new Peak_Response();
        List<hed__Relationship__c> relationships = [SELECT hed__RelatedContact__r.Name, hed__Relationship_Explanation__c FROM hed__Relationship__c WHERE hed__Contact__c = : studentId];
        peakResponse.results = relationships;
        return peakResponse;
    }
    
    /**
* Created by Raju on 11/30/18.
* Parameters: ID, String
* Return Type: Peak_Response
* Purpose : This method is used to Update the Opportunity stage,closedate, Application End Reason and Program Enrollment status.
*/
    public static Peak_Response terminateApplication(Id enrollmentId, String withdrawalReason){
        Peak_Response peakResponse = new Peak_Response();
        Opportunity opportunityToUpdate;
        for(Opportunity opp : [SELECT  Application_End_Reason__c, CloseDate, Id, Program_Enrollment__c, StageName FROM Opportunity
                               WHERE Program_Enrollment__c =: enrollmentId ORDER BY CreatedDate DESC LIMIT 1]){
                                   opportunityToUpdate = opp;
                               }
        
        hed__Program_Enrollment__c programEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Id =: enrollmentId];
        
        if(opportunityToUpdate != null ){
            opportunityToUpdate.StageName = 'Closed Lost';
            opportunityToUpdate.CloseDate = Date.today();
            opportunityToUpdate.Application_End_Reason__c = withdrawalReason;
            
            //programEnrollment.Status__c = 'Inactive';
            
            try{
                update opportunityToUpdate;
                //update programEnrollment;
                peakResponse.messages.add('Opportunity record successfully updated');
                
                hed__Program_Enrollment__c programEnrollmentRecord = [Select id,Status__c,Enrollment_Type__c from hed__Program_Enrollment__c where id=: opportunityToUpdate.Program_Enrollment__c];
                //programEnrollmentRecord.Id = opportunityToUpdate.Program_Enrollment__c;
                // Added - Start --for us: 182050 by viswa
                if(programEnrollmentRecord.Enrollment_Type__c == 'Re-enrolling student')
                    programEnrollmentRecord.Status__c = 'Withdrawn';
                // End --for us: 182050 by viswa
                else
                    programEnrollmentRecord.Status__c = 'Inactive';
                
                update programEnrollmentRecord;
                system.debug('programEnrollmentRecord+++++'+programEnrollmentRecord);
                
                peakResponse.messages.add('Program Enrollment record successfully updated');
                peakResponse.success = true;
                peakResponse.status = programEnrollmentRecord.Status__c;
                
            }catch (Exception ex){system.debug('Error: '+ex.getMessage());peakResponse.success = false; peakResponse.messages.add(ex.getMessage()); logger.logException('terminateApplication', ex);logger.saveLogs();
                                 }
        } else {
            peakResponse.success = false;
            peakResponse.messages.add('Could not find opportunity');
            logger.logError('terminateApplication', 'Could not find opportunity');
            logger.saveLogs();
        }
        
        return peakResponse;
    }
    
    /**
* Created by Raju on 11/30/18.
* Return Type: Peak_Response
* Purpose : This method is used to retrieve picklist values from Opportunity Application end reason
*/
    public static Peak_Response getTerminationReasons(){
        Peak_Response peakResponse = new Peak_Response();
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Opportunity.Application_End_Reason__c.getDescribe();
        List<Schema.PicklistEntry> pickListEntryList = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : pickListEntryList){
            pickListValuesList.add(pickListVal.getValue());
        }
        
        if(pickListValuesList.size()>0){
            peakResponse.messages.add('picklist values successfully retrieved');
            peakResponse.success = true;
            peakResponse.pickListValues = pickListValuesList;
        }
        return peakResponse;
    }
    
    
    /**
* Created By Anand on 12/19/2018
* purpose: To reactivate Student and create opportunity if any Opportunity StageName is Not closedLost related  to
* program Enrollments
* @param programEnrollmentId
*
* @return Peak_Response

**** **** ****
**** **** ****
* Updated By Ali KM on 11/27/2019 as part of [US 119348]
* Moved all pieces realted to Enrollment Reactivation to one class (NES_EnrollmentReactivation) & now just calling that class from here.
**** **** ****
**** **** ****

*/
    public static Peak_Response reactivateStudent(Id programEnrollmentId) {
        
        String reactivationType = 'FULL';
        return NES_EnrollmentReactivationHandler.reactivateStudent(programEnrollmentId, reactivationType);
        
    }
    
    
    /**
* Created by Chinnamanaidu on 26/11/2019.Task # 120988 for US#119347
* Parameters: ID, String
* Purpose : This method is used to display popup window when the  Program Enrollment's related
*           Opportunity Application End Reason (Internal) field starts with "Regulation" .
*/
    public static boolean displayPopupReg1(Id stdId){
        
        boolean res=false;
        
        for(Opportunity opp : [SELECT id,name,Student_Id__c,Application_End_Reason_internal__c FROM Opportunity WHERE Student_Id__c =: stdId]){
            if(opp.Application_End_Reason_internal__c != null){
                if(opp.Application_End_Reason_internal__c.startsWith('Regulation'))
                {
                    res = true;
                    return res;
                }
            }
        }
        
        return res;
    }
    // Created by Maddileti for US #335371 on 12/04/2020
    // Creating New PEs ,Opportunity & ECA's for New School Year
    public static Peak_Response nextYearEnrollment(Id studentId,String instituteNam,String schoolYear,String gradeLevels,String callType) {
        Peak_Response peakResponse = new Peak_Response();
        NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;
        NES_LTSUtility.runLTSFlag = false;
        NES_ProgramEnrollmentHandler.runCBL = false;
        
        if(studentId !=null){
            
            User caretaker = New User();
            if(callType=='community'){
               caretaker= NES_ReactivateStdUtils.getCTUser(UserInfo.getUserId());
            } else if(callType=='application'){
               caretaker= NES_ReactivateStdUtils.getCTUserFromStudentId(studentId);
            } else {
                System.debug('No callType');
               return peakResponse;
            }
            Id studentRecordType = NES_ReactivateStdUtils.getStudentRTId();
            contact reactivateStudent = NES_ReactivateStdUtils.getStudentContact(studentId,studentRecordType);
            School_Year__c schoolYears = NES_ReactivateStdUtils.getSchoolYears(schoolYear);
            Account instituteName = NES_ReactivateStdUtils.getInstitute(instituteNam);
            
            try{
               
                //List<NES_EvaluateUtil.Question> questionDataList = NES_AddStudentHelper.grabQuestionsBySchool(instituteName.id,schoolYears.id);
                //Get Program Enrollments and insert them.  Also retrieve the field that determines which version of the ECA 
                Id academicProgramRecordTypeId = NES_ReactivateStdUtils.getAcademicRTProgramId();
                Account academicProgram = [
                    SELECT Id, name,ParentId, RecordTypeId, School_Year__c, OwnerId, Confirmation_End_Date__c, Use_Updated_ECA_Process__c,
                    Too_Young_Cutoff__c, Too_Old_Cutoff__c,MaxSpecialEdBirthdate__c
                    FROM Account
                    WHERE parent.name =:instituteNam
                    AND RecordTypeId = :academicProgramRecordTypeId
                    AND School_Year__c= :schoolYears.id
                    LIMIT 1
                ];
                
                hed__Program_Enrollment__c caretakerEnrollmentId = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :caretaker.ContactId AND hed__Account__c = :academicProgram.Id limit 1];
               // Grade_Level__c grades=[SELECT id,Name FROM Grade_Level__c  where Name =:gradeLevels limit 1];
                
                Program_Grade_Level__c progGrades =[select id,Grade_Level__r.name from Program_Grade_Level__c where Academic_Program__r.name =:academicProgram.name AND Grade_Level__r.name =:gradeLevels limit 1];
                //Program Enrollment for student
                hed__Program_Enrollment__c newStudentEnrollment = new hed__Program_Enrollment__c();
                Id studentEnrollmentTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                newStudentEnrollment.hed__Contact__c = reactivateStudent.Id;     
                newStudentEnrollment.RecordTypeId = studentEnrollmentTypeId;
                newStudentEnrollment.Household_Program_Enrollment__c = caretakerEnrollmentId.id;
                newStudentEnrollment.hed__Account__c = academicProgram.Id;
                newStudentEnrollment.Start_Year__c = schoolYears.Id;
                newStudentEnrollment.OwnerId = academicProgram.OwnerId;
                newStudentEnrollment.Program_Grade_Level__c  = progGrades.id;
                newStudentEnrollment.Final_Grade_Level__c  = progGrades.Grade_Level__r.name;
                newStudentEnrollment.Has_Open_Opportunity__c = true;
             
                string str = Id.valueOf(reactivateStudent.id); 
                
                try{
                    
                    insert newStudentEnrollment;
                    }
                    catch(Exception e){
                        logger.logException('Program Enrollment insertion failed for Contact :'+str, e);
                        logger.saveLogs();                        
                    }
                
                //Now let's create an Opportunity based on that enrollmentId
                //Modified the ownerId as per the bug #77521 to match the Academic Program Owner
                
                Opportunity oppToInsert = new Opportunity(
                    Name = reactivateStudent.FirstName + ' ' + reactivateStudent.LastName + ' Opportunity',
                    OwnerId = academicProgram.OwnerId,
                    Caretaker_Id__c = caretaker.ContactId,
                    Student_Id__c = reactivateStudent.Id,
                    AccountId = reactivateStudent.AccountId,
                    Program_Enrollment__c = newStudentEnrollment.Id,
                    StageName = 'Open',
                    CloseDate = academicProgram.Confirmation_End_Date__c == null ? Date.today() : academicProgram.Confirmation_End_Date__c.date()
                );
                
                
                  string strs = Id.valueOf(reactivateStudent.id); 
                
                try{
                    
                    insert oppToInsert;
                    }
                    catch(Exception e){
                        logger.logException('Opportunity insertion failed for Contact :'+strs, e);
                        logger.saveLogs();                        
                    }
                
                // instantiate affiliations to insert, gather record type ids
                Set<Enrollment_Component_Affiliation__c> ecAffiliationsToInsert = new Set<Enrollment_Component_Affiliation__c>();
                List<Enrollment_Component__c> processComponent = NES_ReactivateStdUtils.getProcessEC(academicProgram.Id);
                List<Enrollment_Component_Relationship__c> relationships  = NES_ReactivateStdUtils.getAllStages(processComponent[0].Id);
                
                
                //Iterate over a list of Question Data to get Enrollment Components
               // System.debug(questionDataList);
                Set<id> referencedSchoolYears = new Set<Id>();
                List<Id> questionIds = new List<Id>();
              /* for (NES_EvaluateUtil.Question data : questionDataList) {
                    questionIds.add(data.questionId);
                    referencedSchoolYears.add(data.schoolYear);
                } */
                
                
                //build a map of school year ids to the 
               /* Map<Id, School_Year__c> schoolYearMap = new Map<Id, School_Year__c>();
                for ( School_Year__c s : [SELECT Id, External_Id__c FROM School_Year__c where id in :referencedSchoolYears] ) 
                    schoolYearMap.put(s.id, s);  */
                
                //Hang on to the birth date so we can use it in the hard stop logic at the end of the process.
                date birthdate;
             /*  
                for (NES_EvaluateUtil.Question data : questionDataList) {
                    System.debug(data);
                    
                    //Check for the Component Type
                    if (String.isNotBlank(data.componentType)) {
                        System.debug(data.questionTarget);
                        System.debug(data.targetField);
                        //Check whether EC record have the Target Field Value (ObjectAPIName.FieldAPIName) and also check whether user has put input or not
                        if (String.isNotBlank(data.targetField)) {
                            
                            //Split the Target field to get the Object and Field API Names
                            String fieldApiName = data.questionTarget.substring(data.questionTarget.indexOf('.') + 1, data.questionTarget.length());
                            String objectApiName = data.questionTarget.substring(0, data.questionTarget.indexOf('.'));
                            
                            //Build a query string and then query the records from the object obtained form the target field along with API name
                            // of the field where Program enrollment is same as the Care taker Program Enrollment Id
                            List<SObject> childRecords = new List<SObject>();
                            String query;
                            if (caretakerEnrollmentId.id !=null && data.componentType == 'Household') {
                                
                                if (objectApiName == 'Account') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Account WHERE Id = \'' + caretaker.Contact.AccountId + '\' ';
                                } else if (objectApiName == 'Contact') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Contact WHERE Id = \'' + caretaker.Contact + '\' ';
                                } else if (objectApiName == 'hed__Program_Enrollment__c') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM hed__Program_Enrollment__c WHERE Id = \'' + caretakerEnrollmentId.Id + '\' ';
                                } else {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM ' + objectApiName + ' WHERE Program_Enrollment__c = \'' + caretakerEnrollmentId.Id + '\' ';
                                }
                                if (String.isNotBlank(data.schoolYear)) {
                                    query += ' AND School_Year__c = \'' + data.schoolYear + '\' ';
                                }
                                childRecords = Database.query(query);
                            } else {
                                
                                if (objectApiName == 'Account') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Account WHERE Id = \'' + reactivateStudent.AccountId + '\' ';
                                } else if (objectApiName == 'Contact') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Contact WHERE Id = \'' + reactivateStudent.Id + '\' ';
                                } else if (objectApiName == 'hed__Program_Enrollment__c') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM hed__Program_Enrollment__c WHERE Id = \'' + newStudentEnrollment.Id + '\' ';
                                } else {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM ' + objectApiName + ' WHERE Program_Enrollment__c = \'' + newStudentEnrollment.Id + '\' ';
                                    if (String.isNotBlank(data.schoolYear)) {
                                        query += ' AND School_Year__c = \'' + data.schoolYear + '\' ';
                                    } 
                                }
                                System.debug(query);
                                childRecords = Database.query(query);
                                System.debug(childRecords);
                            }
                            
                            //If the record exists, update it with value of User Input, else insert a new one related the program enrollment Id
                            
                            if (childRecords.size() > 0) {
                                SObject sObj = NES_EvaluateUtil.updateDataVoid(data.questionType, data.targetField, fieldApiName, childRecords[0]);
                                update sObj;
                                //Capture the birtdate for later use in the hard stop logic.
                                if (fieldApiName == 'Birthdate__c')
                                    birthdate = ((contact) sObj).Birthdate__c;
                                
                            } else {
                                SObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
                                sObj = NES_EvaluateUtil.updateDataVoid(data.questionType, data.targetField, fieldApiName, sObj);
                                System.debug(data);
                                if (data.componentType == 'Household') {
                                    sObj.put('Program_Enrollment__c', caretakerEnrollmentId);
                                } else {
                                    sObj.put('Program_Enrollment__c', newStudentEnrollment.Id);
                                }
                                if (String.isNotBlank(data.schoolYear)) {
                                    sObj.put('School_Year__c', data.schoolYear);
                                }
                                insert sObj;
                            }
                            
                        }
                    }
                    
                    //In the new ECA model, we don't create questions for Question and Question Groups.
                    if (academicProgram.Use_Updated_ECA_Process__c == false)  {
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord.Enrollment_Component__c = data.questionId;
                        affiliationRecord.Program_Enrollment__c = newStudentEnrollment.Id;
                        affiliationRecord.Status__c = 'Complete';
                        ecAffiliationsToInsert.add(affiliationRecord);
                    }
                }*/
                List<Enrollment_Component_Affiliation__c> basicECAsforStage = NES_ReactivateStdUtils.insertAffiliations(processComponent[0].Id, newStudentEnrollment.Id,relationships);
                ecAffiliationsToInsert.addAll(basicECAsforStage);
                
                List<Enrollment_Component_Affiliation__c> allECAs =new List<Enrollment_Component_Affiliation__c>();
                allECAs.addAll(ecAffiliationsToInsert);
                
                integer i=0;
                do{
                    try{
                        i++;
                        insert allECAs;                
                        break;//Breaking the loop as the DML executed and no exceptions
                    }
                    catch(Exception e){
                        logger.logException('Retrying a timed out insert', e);
                        logger.saveLogs();                        
                    }
                }while(i<5);
                
                //Determine which version of the ECA process we are using.
                if (academicProgram.Use_Updated_ECA_Process__c == false)
                {
                    //Call an @future that will create the rest of the ECAs
                    List<Id> relationIds = new List<Id>();
                    for (Enrollment_Component_Relationship__c r :relationships)
                        relationIds.add(r.id);
                    
                    NES_ECAEvaluation.createRemainingAffiliations(caretaker.Contact.AccountId, reactivateStudent.Id, caretaker.ContactId, newStudentEnrollment.Id, caretakerEnrollmentId.id, relationIds, processComponent[0].Id);
                } else  {  //Must be using the new ECA process
                    //Call the future method that will create the remaining ECAs and the PE Criteria.
                    EvaluationUtils.PerformAsyncNewStudentSteps(newStudentEnrollment.Id, processComponent[0].Id, caretakerEnrollmentId.id);
                }
                
                //With the ECA rewrite, we changed the hard stop process to only look at dates from the Academic program.
                Boolean shouldHardStop = false;
                //Replaced with MaxSpecialEdBirthdate__c instead of Too_Old_Cutoff__c in below if condition for 335863
                
                birthdate = reactivateStudent.Birthdate__c;
                System.debug('birth date:'+birthdate);
                if (birthdate < academicProgram.MaxSpecialEdBirthdate__c || birthdate > academicProgram.Too_Young_Cutoff__c)
                    shouldHardStop = true;
                
                if (shouldHardStop) {
                    String message = label.NES_Add_Student_Hard_Stop_Message;
                    peakResponse.messages.add(message);
                    newStudentEnrollment.Status__c = 'Ineligible';
                    update newStudentEnrollment; 
                    
                    //added for the US 169322 - Jagadeesh Bokam
                    //If the student has been hard stopped, the opp should be closed lost.
                    oppToInsert.StageName = 'Closed Lost';
                    oppToInsert.CloseDate = Date.today();
                    update oppToInsert;
                    //Ended for the US 169322 - Jagadeesh Bokam
                } 
                
                //The case creation is now seperated out to a queable.
                System.enqueueJob(new NES_AddStudentCaseQueueable(caretaker,newStudentEnrollment.Id,reactivateStudent));
                
                
            }catch(exception e){
                
                peakResponse.success = false;
                peakResponse.messages.add(e.getMessage());
                System.debug('Exception thrown: ' + e.getMessage());
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                logger.logException('insertingpes', e);
                logger.saveLogs();
                
            }
        } 
        
        
        
        return peakResponse;
    }
    // End by Maddileti for US #335371 on 12/04/2020
    
}