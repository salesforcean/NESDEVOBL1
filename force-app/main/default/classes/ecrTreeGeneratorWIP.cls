/**
    @class:         Test CLASS WIP...           
	@description:   Test coverage for ECA_CriteriaEvaluator.
	@author: 		Mark Membrino
	@createdDate:   9/16/2020
*/
@isTest(SeeAllData=true)
public class ecrTreeGeneratorWIP 
{
    public static final String CT_USER_NAME = 'markmembrinotestca'; 
    public static final String INSTITUTIONAL_ACCOUNT_NAME = 'California Connections Academy North Bay';
    public static final String ACADEMIC_PROGRAM_NAME = 'CalCA North Bay 2020-2021';
    public static final String SCHOOL_YEAR = '2020-2021';

    /**
     *  bug-complete-status-on-forms
     */
    @IsTest
    static void createStudentPositive()
    {
        User careTaker = [SELECT Id, ContactId, UserName, CommunityNickname FROM User WHERE CommunityNickname = : CT_USER_NAME];	

        Account institutionalAccount = [SELECT Id, Name FROM Account WHERE 
            RecordType.Name = 'Educational Institution' AND Name = :INSTITUTIONAL_ACCOUNT_NAME LIMIT 1];

        Account academicProgram = [SELECT Id, ParentId, School_Year__c, School_Year__r.Name, Registration_End_Date__c, 
            Registration_Start_Date__c FROM Account WHERE RecordType.Name = 'Academic Program' AND Name = : ACADEMIC_PROGRAM_NAME LIMIT 1];   

        School_Year__c schoolYear = [SELECT Id FROM School_Year__c WHERE Name = :SCHOOL_YEAR LIMIT 1];

        System.assertNotEquals(null, careTaker);
        System.assertNotEquals(null, institutionalAccount);
        System.assertNotEquals(null, academicProgram);
        System.assertNotEquals(null, schoolYear);

        //Create a student enrollment for the CareTaker Contact
        hed__Program_Enrollment__c progEnrollment = Peak_TestUtils.createProgramEnrollment(academicProgram.Id, careTaker.ContactId, schoolYear.Id, true);
        System.assertNotEquals(null, progEnrollment);

         System.runAs(careTaker) {
            Test.startTest();
            NES_EvaluateUtil.NewStudentData data = NES_AddStudentController.getNewStudentData();
            Peak_Response response = NES_AddStudentController.getSchoolYears(institutionalAccount.Id);
            List<NES_EvaluateUtil.Question> questionsList = NES_AddStudentController.getComponentsByAcademicProgram(institutionalAccount.Id, schoolYear.Id);

            NES_EvaluateUtil.NewStudentData newStudentData = new NES_EvaluateUtil.NewStudentData('Royal','Middle', 'MaverickT','Sr.','Parent', institutionalAccount.Id, '', '',  null, null, null, null); //added for US116612 
            newStudentData.SelectedSchoolYear = academicProgram.School_Year__c;
            String studentJSON = JSON.serialize(newStudentData);
            System.debug('studentJSON++'+studentJSON);

            Enrollment_Component__c qComponent = [SELECT Id FROM Enrollment_Component__c WHERE Assignment_Logic__c != null AND RecordType.Name = 'Question' LIMIT 1];
            List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
            NES_EvaluateUtil.Question q1 = new NES_EvaluateUtil.Question();
            q1.order = 1;
            q1.componentType = 'Student';
            q1.questionGroup = false;
            q1.questionPrompt = 'What grade is the student going into?';
            q1.questionTarget = 'hed__Program_Enrollment__c.Final_Grade_Level__c';
            q1.questionType = 'Picklist';
            q1.required = true;
            q1.schoolYear = schoolYear.Id;
            q1.targetField = 'K';
            q1.componentType = 'false';
            q1.questionId = qComponent.Id;
            questionDataList.add(q1);
            String questionJSON = JSON.serialize(questionDataList);

            Peak_Response studentInsertResponse = NES_AddStudentController.createStudent(studentJSON, questionJSON);
            Test.stopTest();
        }

        // for (Enrollment_Component_Affiliation__c eca : [SELECT Id, Status__c, Order__c, Program_Enrollment__c, EC_Record_Type__c, Enrollment_Component__c, Enrollment_Component__r.Name
        //     FROM Enrollment_Component_Affiliation__c WHERE EC_Record_Type__c = 'Form' AND Program_Enrollment__c = : progEnrollment.Id AND 
        //         Enrollment_Component__c IN ('a293C000000JRzBQAW','a293C000000JRz8QAG','a293C000000JRz9QAG','a293C000000JRyiQAG','a293C000000JRz7QAG')])
        // {
        //     System.debug('eca>>' + JSON.serialize(eca));
        // }

        for (Enrollment_Component_Affiliation__c eca : [SELECT Id, Status__c, Order__c, Program_Enrollment__c, EC_Record_Type__c, Enrollment_Component__c, Enrollment_Component__r.Name
            FROM Enrollment_Component_Affiliation__c WHERE Program_Enrollment__c = : progEnrollment.Id])
        {
            System.debug('eca>>' + JSON.serialize(eca));
        }
        

        // List<Enrollment_Component_Affiliation__c> FormECAWithAssgnmentCriteria = new List<Enrollment_Component_Affiliation__c> 
        // ([select Id, status__c, Program_Enrollment__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Form' and Enrollment_Component__r.Assignment_Logic__c <> null ]);
        // System.assertEquals('Not Applicable', FormECAWithAssgnmentCriteria[0].status__c);

        // //Update a field that is part of a criteria on all the PEs that have been created.
        // List<hed__Program_Enrollment__c> allPEs = new List<hed__Program_Enrollment__c>([select id, SIF_Gifted_Initial_Interest__c from hed__Program_Enrollment__c]);
        // for (hed__Program_Enrollment__c pe : allPEs) {
        //    pe.SIF_Gifted_Initial_Interest__c = 'Yes';
        // }
        // update allPEs;

        // FormECAWithAssgnmentCriteria = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Form' and Enrollment_Component__r.Assignment_Logic__c <> null ]);
        // System.assertEquals('Not Started', FormECAWithAssgnmentCriteria[0].status__c);

        // List<Enrollment_Component_Affiliation__c> stageECAs = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Stage' ]);
        // System.assertEquals('In Progress', stageECAs[0].status__c);

        // //Now update the completion criteria
        // for (hed__Program_Enrollment__c pe : allPEs) {
        //    pe.DisciplinaryFlagOverride__c = 'Released';
        // }
        // update allPEs;

        // FormECAWithAssgnmentCriteria = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Form' and Enrollment_Component__r.Assignment_Logic__c <> null ]);
        // System.assertEquals('Not Started', FormECAWithAssgnmentCriteria[0].status__c);

        // stageECAs = new List<Enrollment_Component_Affiliation__c> ([select Id, status__c from Enrollment_Component_Affiliation__c where EC_Record_Type__c = 'Stage' ]);
        // System.assertEquals('In Progress', stageECAs[0].status__c);
                                          
    }
}