/**
* Created by triciaigoe on 12/26/18.
*/ 

public without sharing class NES_EnrollmentController {
    
    /**
* Created by Ashish Sharma on 11/14/18.
* Parameters: ID
* Return Type: List<Enrollment_Component_Affiliation__c>
* Purpose : This method is used to retreive and return the enrollment components' information (Stage Record Type) of the related programEnrollmentId
Using Enrollment_Component_Affiliation__c object here as this is defining the relationship between Enrollment_Component__c
and Program_Enrollment__c objects 
*/
    @AuraEnabled
    public static List<Enrollment_Component_Affiliation__c> getRelatedStages(Id programEnrollmentId){
        return NES_EnrollmentHelper.getRelatedStages(programEnrollmentId);
    }
    
    /**
* Created by Ashish Sharma on 11/14/18.
* Parameters: ID
* Return Type: List<Enrollment_Component__c>
* Purpose : This method is used to retreive and return the enrollment components' information (Message Record Type) of the related enrollmentComponentId
Using Enrollment_Component_Relationship__c object here as this is defining the relationship between Parent_Enrollment_Component__c
and Parent_Enrollment_Component__c objects
*/
    @AuraEnabled
    public static List<Enrollment_Component__c> getRelatedMessages(Id enrollmentComponentId, Id programEnrollmentId){
        return NES_EnrollmentHelper.getRelatedMessages(enrollmentComponentId, programEnrollmentId);
    }
    
    /**
* Created by Ashish Sharma on 11/14/18.
* Parameters: ID
* Return Type: NES_DashboardUtilities.Process
* Purpose : This method is used to get the related Child enrollment component of STAGE_RT record type using processComponentId
and using those child components get the required information
*/
    @AuraEnabled
    public static NES_DashboardUtilities.Process getProcessInformation(Id processComponentId, Id programEnrollmentId){
        return NES_EnrollmentHelper.getProcessInformation(processComponentId, programEnrollmentId);
    }
    
    /**
* Created by Ashish Sharma on 11/14/18.
* Parameters: ID
* Return Type: List<NES_DashboardUtilities.Form>
* Purpose : This method is used to get the related Child enrollment component of FORM_RT record type using stageComponentId
and using those child components get the required form information
*/
    @AuraEnabled
    public static List<NES_DashboardUtilities.Form> getRelatedForms(Id stageComponentId, Id enrollmentId){
        return NES_EnrollmentHelper.getRelatedForms(stageComponentId, enrollmentId);
    }
    
    /**
* Created by Ashish Sharma on 11/14/18.
* Parameters: ID
* Return Type: List<NES_DashboardUtilities.RelatedFormContent>
* Purpose : This method is used to get the related Child enrollment component of SECTION_RT and DOCUMENT_RT record type using formComponentId
and using those child components get the required component information
*/
    @AuraEnabled
    public static List<NES_DashboardUtilities.RelatedFormContent> getRelatedFormContent(Id formComponentId, Id enrollmentId){
        return NES_EnrollmentHelper.getRelatedFormContent(formComponentId, enrollmentId);
    }
    
    //grab the caretakers for a student
    @AuraEnabled
    public static Peak_Response getCaretakers(Id studentIdString) {
        return NES_EnrollmentHelper.grabCaretakers(studentIdString);
    }
    
    /**
* Created by Raju on 11/30/18.
* Parameters: ID, String
* Return Type: Peak_Response
* Purpose : This method is used to Update the Opportunity stage,closedate, Application End Reason and Program Enrollment status.
*/
    @AuraEnabled
    public static Peak_Response terminateApplication(Id opportunityId, String withdrawalReason){
        return NES_EnrollmentHelper.terminateApplication(opportunityId, withdrawalReason);
    }
    
    /**
* Created by Raju on 11/30/18.
* Return Type: Peak_Response
* Purpose : This method is used to retrieve picklist values from Opportunity Application end reason
*/
    @AuraEnabled
    public static Peak_Response getTerminationReasons(){
        return NES_EnrollmentHelper.getTerminationReasons();
    }
    
    /**
* Created By Anand on 12/19/2018
* purpose: To reactivate Student and create opportunity if any Opportunity StageName is not closedLost related  to
* program Enrollments
* @param programEnrollmentId
* @return Peak_Response
*/
    
    // Updated by Krishna Peddanagammol  for US#119618 on 11/28/2019 Included new parameters reactivationType, whoReactivated
    // @AuraEnabled
    // public static Peak_Response reactivateStudent(Id programEnrollmentId, String reactivationType, String whoReactivated) {
    //     return NES_EnrollmentHelper.reactivateStudent(programEnrollmentId,reactivationType,whoReactivated);
    // }
    
    @AuraEnabled
    public static Peak_Response reactivateStudent(Id programEnrollmentId) {
        return NES_EnrollmentHelper.reactivateStudent(programEnrollmentId);
    }
    
    @AuraEnabled
    public static Id getSchoolId(Id enrollmentId) {
        return NES_QuestionsHelper.grabSchoolId(enrollmentId);
    }
    
    @AuraEnabled
    public static String grabNameOfStudent(Id studentId, Id programEnrollmentId) {
        return NES_EnrollmentUtils.getStudentName(studentId, programEnrollmentId);
    }
    
    /**
* Created By Chinnamanaidu on 26/11/2019- task # 120987 for US#119347
* purpose: Used to display popup window when the  Program Enrollment's related Opportunity Application End Reason (Internal) field
* starts with the "Regulation".
* @param programEnrollmentId
*/
    @AuraEnabled
    public static boolean displayPopupReg(Id studentId) {
        return NES_EnrollmentHelper.displayPopupReg1(studentId);
    }
    
    @AuraEnabled (cacheable=false)
    public static boolean getIsEnrollmentReady(Id enrollmentId) {
        List<hed__Program_Enrollment__c> peS = new list<hed__Program_Enrollment__c> ([select Initial_ECA_Creation_Complete__c from hed__Program_Enrollment__c where id = :enrollmentId]);
        
        if (peS[0].Initial_ECA_Creation_Complete__c == true)
            return true;
        else   
            return false;
    }

    @AuraEnabled
    public static List<Grade_Level__c> getGradeLevels(String instituteName,String year) {
        
        Date todayDate  = date.today();
        
     Account acc=[select id,name,Registration_End_Date__c,Registration_Start_Date__c from Account where RecordType.Name = 'Academic Program' and Parent.Name =:instituteName and School_Year__r.Name=:year limit 1];
        system.debug('acc nname:'+acc.Name);
    
        
        List<Grade_Level__c> gradeLevels =[SELECT Id, Name FROM Grade_Level__c where Id in (Select Grade_Level__c from Program_Grade_Level__c where Academic_Program__r.name=:acc.name 
                                                                                            AND ((Registration_Start_Date__c <= :todayDate AND Registration_End_Date__c >= :todayDate) OR 
                                                                                                (Academic_Program__r.Registration_Start_Date__c <= :todayDate AND Academic_Program__r.Registration_End_Date__c >= :todayDate AND Registration_Start_Date__c = null AND Registration_End_Date__c =null))) order by order__c];
	 
        
        System.debug('grades:'+gradeLevels);
	   return gradeLevels;
        
    } 
   
 // Add by Maddileti for US 335371 on 12/04/2020   
    @AuraEnabled
    public static List<School_Year__c> getSchoolYears(String instituteName) {
      
        new List<School_Year__c>();
        //hed__Program_Enrollment__c programEnrollment =[Select id,hed__Account__r.ParentId from hed__Program_Enrollment__c where id=:programEnrollmentId];
        List<School_year__c> schoolYears = new List<School_year__c>();
        Date todayDate  = date.today();
        Set<Id> schoolYrIds = new Set<Id>();

        system.debug('instituteName== '+instituteName);
        for(Account academicProgrm : [select Id,Parent.Name,Registration_End_Date__c,Registration_Start_Date__c,School_Year__c from account where recordtype.Name = 'Academic Program' AND Registration_Start_Date__c <= :todayDate AND Registration_End_Date__c >= :todayDate and parent.Name =:instituteName]){
            system.debug('academicProgrm== '+academicProgrm);
            schoolYrIds.add(academicProgrm.School_Year__c);
        }
        system.debug('schoolYrIds== '+schoolYrIds);
        

        schoolYears = [Select Id, Name from School_year__c where Id IN: schoolYrIds];
        
        return schoolYears;
    } 
    @AuraEnabled

    public static Peak_Response nextYearEnrollment(Id studentId,String instituteNam,String schoolYear,String gradeLevels, String callType, boolean enrollFlag, Id programEnrollmentId) {
        
        return NES_EnrollmentHelper.nextYearEnrollment(studentId,instituteNam,schoolYear,gradeLevels,callType,enrollFlag,programEnrollmentId); 
    }
    // End by Maddileti for US 335371 on 12/04/2020  
    
    
    @AuraEnabled
    public static Boolean getNextYearAvailability(String instituteName, String currentSchoolYear) {
        List<School_year__c> schoolYears = new List<School_year__c>();
        Date todayDate  = date.today();
        Set<Id> schoolYrIds = new Set<Id>();
        for(Account academicProgrm : [select Id,Parent.Name,Registration_End_Date__c,Registration_Start_Date__c,School_Year__c from account where recordtype.Name = 'Academic Program' AND Registration_Start_Date__c <= :todayDate AND Registration_End_Date__c >= :todayDate and parent.Name =:instituteName]){
            schoolYrIds.add(academicProgrm.School_Year__c);
        }        
        schoolYears = [Select Id,current_year__c, Name from School_year__c where Id IN: schoolYrIds order by Name DESC];
        Boolean availability = (currentSchoolYear != schoolYears[0].Name);
        return availability;
    } 
    
    
   @AuraEnabled
    public static NES_ReEnrUtilities.ReEnrResults doReEnrollment(Id studentContactId,Id studentPeId){
    	return	NES_ReEnrUtilities.reenrollingStudent(studentContactId,studentPeId);
       
    } 
	
    
    @AuraEnabled
    public static string getPEEnrStatus(Id peId){
        
        String result = '';
    	hed__Program_Enrollment__c peRecord = [Select Id,Status__c,hed__Contact__c,Enrollment_Type__c,
                                                (select id,Withdrawal_Category__c from Enrollments__r order by createddate desc)  
                                                from hed__Program_Enrollment__c where Id =: peId limit  1];	
      
												
        	if(peRecord.Status__c == 'Inactive' && peRecord.Enrollment_Type__c == 'Returning Student')
            {
            	result = 'ReActivation';
            }
            else            
            if((!peRecord.Enrollments__r.isEmpty()) && ((peRecord.Status__c == 'Withdrawn' && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'No Show') || (peRecord.Status__c == 'Complete' && peRecord.Enrollments__r[0].Withdrawal_Category__c == 'Not Returning')))
            {
                result = 'ReEnrollment';               
            }
        
         return result;
        
    }
}