/**
 * Created by Ashish Sharma on 11/14/18.
 * Class Name: NES_DashboardUtilities
 * Test Class Name: NES_DashboardControllerTest
 * Purpose : This class is utilities class for NES_Dashboard controller
*/
public without sharing class NES_DashboardUtilities{
    //Constants to be used for record type names
    public static final String STUDENT_RT = 'Students';
    public static final String PROCESS_RT = 'Process';
    public static final String STAGE_RT = 'Stage';
    public static final String MESSAGE_RT = 'Message';
    public static final String FORM_RT = 'Form';
    public static final String FLAG_RT = 'Flag';
    public static final String SECTION_RT = 'Section';
    public static final String DOCUMENT_RT = 'Document';
    public static final String QUESTION_RT = 'Question';
    public static final String TEXT_RT = 'Text';
    public static final String QUESTIONGROUP_RT = 'Question Group';
    public static final String EXEMPT_STATUS = 'Exempt';
    public static final String DEFERRED_STATUS = 'Deferred';
    public static final String INSTITUATION_RT = 'Educational Institution';
    public static final String COMPLETE_STATUS = 'Complete';
    public static final String ITR_BTN_LABEL = 'TELL US ABOUT NEXT YEAR';
    public static final String INPROGRESS_STATUS = 'In Progress';
    public static final String INACTIVE_STATUS = 'Inactive';
    public static final String WITHDRAWN_STATUS = 'Withdrawn';
    public static final String REACTIVATE_BTN_LABEL = 'Reactivate';
    public static final String REENROLL_BTN_LABEL = 'Re-enroll';
    /*
     * Updated by Krishna Reddy P on 08/07/2019 for User Story: 101933, Task: 104433
     * Purpose: A new constant is added as NOTAPPLICABLE_STATUS for ECA's Status 'Not Applicable' 
    */
    public static final String NOTAPPLICABLE_STATUS = 'Not Applicable';
    public static final String HIDDEN_INPUT = 'Hidden Input';

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the Student type enrollment component information
    */
    public class StudentInformation{
        /*@AuraEnabled
        public Id programEnrollmentId{get;set;}
        @AuraEnabled
        public Id processId{get;set;}
        @AuraEnabled
        public Id contactId{get;set;}
        @AuraEnabled
       public String acadProgram{get;set;}
        @AuraEnabled
        public String ecaStatus{get;set;}
        @AuraEnabled
        public String peStatus{get;set;}
        @AuraEnabled
        public String schoolYear{get;set;}
        @AuraEnabled
        public String acadName{get;set;}
        @AuraEnabled
        public String contactName{get;set;}
        @AuraEnabled
        public Id accountId{get;set;}
        @AuraEnabled
        public String gradeLevel{get;set;}
        @AuraEnabled
        public Datetime regStart{get;set;}
        @AuraEnabled 
        public Datetime regEnd{get;set;}
        @AuraEnabled
        public List<Enrollment_Component_Affiliation__c> stages{get; set;}*/
		
        public StudentInformation(Id programEnrollmentId, String acadName, String schoolYear, String peStatus, String acadProgram, Id contactId, String ecaStatus, String contactName,String accountId,
                                  List<Enrollment_Component_Affiliation__c> stages, Id relatedProcessId, String grade, Datetime regBegin, Datetime regEnds){
            /*this.programEnrollmentId = programEnrollmentId;
            this.acadProgram = acadProgram;
            this.contactId = contactId;
            this.ecaStatus = ecaStatus;
            this.contactName = contactName;
            this.accountId = accountId;
            this.stages = stages;
            this.processId = relatedProcessId;
            this.gradeLevel = grade;
            this.acadName = acadName;
           this.schoolYear = schoolYear;
            this.regStart = regBegin;
            this.regEnd = regEnds;
            this.peStatus = peStatus;  */                        
        }
    }
    
    /**
     * Created by Jagadish Babu
     * Purpose : Wrapper class to store the Student type enrollment component information (US 338596)
     **/
    public class StudentsInformation {
         @AuraEnabled
		public String studentFName{get;set;}	//Student first Name 
		 @AuraEnabled
        public String studentLName{get;set;}	//Student Last Nam
		 @AuraEnabled
        public String studentId{get;set;}	//student record Id
		 @AuraEnabled
        public List<AcademicProgramsWrapper> academicPrograms{get;set;}//List of academic programs
	}
	public class AcademicProgramsWrapper {
         @AuraEnabled
		public String academicProgram{get;set;}	//Academic Program Name (ex:ACA2020-2021)
		 @AuraEnabled
        public Id programEnrollmentId{get;set;}	//Program enrollment record Id
		 @AuraEnabled
        public Id processId{get;set;}	//process eca Id
		 @AuraEnabled
        public String ecaStatus{get;set;}	//process ECA status
		 @AuraEnabled
        public String programEnrollmentStatus{get;set;}	//Program enrollment Status
		 @AuraEnabled
        public Id accountId{get;set;}	//Educational Institution account Id
		 @AuraEnabled
        public Id gradeLevelId{get;set;}	//Program grade Level record Id
		 @AuraEnabled
        public String programGradeLevel{get;set;}	//program grade Level Name (ex:2nd grade)
		 @AuraEnabled
        public DateTime regStart{get;set;}	//Registartion start date
		 @AuraEnabled
        public DateTime regEnd{get;set;}	//Registartion end date
		 @AuraEnabled
        public String instituationName{get;set;}	//Educational Institution account Name
		 @AuraEnabled
        public String schoolYear{get;set;}	//School year (ex:2020-2021)
		 @AuraEnabled
        public String buttonLabel{get;set;}
         @AuraEnabled
        public String buttonTarget{get;set;}
        
        public AcademicProgramsWrapper(String academicProgram,Id programEnrollmentId,Id processId,String ecaStatus,String programEnrollmentStatus,Id accountId,Id gradeLevelId,String programGradeLevel,DateTime regStart,DateTime regEnd,String instituationName,String schoolYear, String buttonLabel, String buttonTarget){
            this.academicProgram = academicProgram;
            this.programEnrollmentId = programEnrollmentId;
            this.processId = processId;
            this.ecaStatus = ecaStatus;
            this.programEnrollmentStatus = programEnrollmentStatus;
            this.accountId = accountId;
            this.gradeLevelId = gradeLevelId;
            this.programGradeLevel = programGradeLevel;
            this.regStart = regStart;
            this.regEnd = regEnd;
            this.instituationName = instituationName;
            this.schoolYear = schoolYear;            
			this.buttonLabel = buttonLabel;
            this.buttonTarget = buttonTarget;
        }
	}

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the Process type enrollment component information
    */
    public class Process{
        @AuraEnabled
        String processName{get;set;}
        @AuraEnabled
        String ecaStatus{get;set;}
        @AuraEnabled
        List<Stage> stages{get;set;}

        public Process(String name, String ecaStatus, List<Stage> stages){
            this.processName = name;
            this.ecaStatus = ecaStatus;
            this.stages = stages;
        }
    }

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the Stage type enrollment component information
    */
    public class Stage{
        @AuraEnabled
        String stageName{get;set;}
        @AuraEnabled
        String ecaStatus{get;set;}
        @AuraEnabled
        Integer order{get;set;}

        public Stage(String stageName, String ecaStatus, Integer order){
            this.stageName = stageName;
            this.ecaStatus = ecaStatus;
            this.order = order;
        }
    }

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the Form type enrollment component information
    */
    public class Form{
        @AuraEnabled
        String name{get;set;}
        @AuraEnabled
        String ecaStatus{get;set;}
        @AuraEnabled
        String componentMessage{get;set;}
        @AuraEnabled
        String formId {get;set;}
        @AuraEnabled
        Decimal orderNumber {get;set;}

        public Form(String name, String ecaStatus, String componentMessage, String formIdString, Decimal ordering){
            this.name = name;
            this.ecaStatus = ecaStatus;
            this.componentMessage = componentMessage;
            this.formId = formIdString;
            this.orderNumber = ordering;
        }
    }

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the RelatedFormContent information
    */
    public class RelatedFormContent{
        @AuraEnabled
        public String name{get;set;}
        @AuraEnabled
        public String ecaStatus{get;set;}
        @AuraEnabled
        public String docStatus{get;set;}
        @AuraEnabled
        public String ecaid{get;set;}
        @AuraEnabled
        public String componentMessage{get;set;}
        @AuraEnabled
        public Integer order{get;set;}
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String sectionType {get;set;}

        public RelatedFormContent(String name, String ecaStatus, String affiliationId,
                                  String componentMessage, Integer orderNumber, String idString, String sectionTypeString, String docStatusString){
            this.name = name;
            this.ecaStatus = ecaStatus;
            this.ecaid = affiliationId;
            this.componentMessage = componentMessage;
            this.order = orderNumber;
            this.Id = idString;
            this.sectionType = sectionTypeString;
            this.docStatus = docStatusString;
        }
    }

    /**
     * Created by Ashish Sharma on 11/14/18.
     * Purpose : Wrapper class to store the Question type enrollment component information
    */
    public class Question{
        @AuraEnabled
        public String questionPrompt{get;set;}
        @AuraEnabled
        public String tooltipText{get;set;}
        @AuraEnabled
        public String componentMessage{get;set;}
        @AuraEnabled
        public String questionType{get;set;}
        @AuraEnabled
        public String questionId{get;set;}
        @AuraEnabled
        public String answer{get;set;}
        @AuraEnabled
        public String targetField{get;set;}
        @AuraEnabled
        public List<Enrollment_Component_Picklist_Option__c> picklistValues{get;set;}

        public Question(String questionPrompt, String tooltipText,
                        String componentMessage, String questionType,
                        String questionIdString, String target,
                        List<Enrollment_Component_Picklist_Option__c> picklistStrings){
            this.questionPrompt = questionPrompt;
            this.tooltipText = tooltipText;
            this.componentMessage = componentMessage;
            this.questionType = questionType;
            this.questionId = questionIdString;
            this.targetField = target;
            this.picklistValues = picklistStrings;
        }
    }
}