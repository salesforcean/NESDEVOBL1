/**
 * Change Log:
 *   2019-01-25 Created (triciaigoe) 
 *   2019-08-09 Updated query to include Question_Read_Only__c for 101924 (Andrew Sim) 
 */

public without sharing class NES_IntegrationUtils {
    private static Peak_ApexLog logger = new Peak_ApexLog('IntegrationUtils');

    public static void savingAnswers(Id programEnrollmentId, Id groupId, Map<String, String> apiMap, Boolean apiValidated) {

        System.debug('apiValidated: ' + apiValidated);

        //Grab all question affiliations
        List<Enrollment_Component_Affiliation__c> affiliations = [
                SELECT Id, Enrollment_Component__c, Status__c, Name
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__c = :programEnrollmentId
                AND (Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT OR Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTIONGROUP_RT)
        ];
        List<Id> questionIds = new List<Id>();

        for (Enrollment_Component_Affiliation__c affiliation : affiliations) {
            questionIds.add(affiliation.Enrollment_Component__c);
        }

        //Grab all question components for this PE for this question group
        List<Enrollment_Component_Relationship__c> questions = [
                SELECT Id, Child_Enrollment_Component__r.Answer_Target__c, Child_Enrollment_Component__r.API_Mapping__c,
                        Child_Enrollment_Component__r.Question_Type__c, Child_Enrollment_Component__r.Component_Type__c,
                        Child_Enrollment_Component__r.Question_School_Year__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c = :groupId
                AND Child_Enrollment_Component__c IN :questionIds
        ];

        //Create list of NES_EvaluateUtil.Question for use in saving answers
        List<NES_EvaluateUtil.Question> newQuestions = new List<NES_EvaluateUtil.Question>();
        for (Enrollment_Component_Relationship__c question : questions) {

            String answer;
            if (apiMap.keySet().contains(question.Child_Enrollment_Component__r.API_Mapping__c)) {
                answer = apiMap.get(question.Child_Enrollment_Component__r.API_Mapping__c);
            }
            NES_EvaluateUtil.Question singleQuestion = new NES_EvaluateUtil.Question();
            singleQuestion.targetField = answer;
            singleQuestion.questionType = question.Child_Enrollment_Component__r.Question_Type__c;
            singleQuestion.questionTarget = question.Child_Enrollment_Component__r.Answer_Target__c;
            singleQuestion.questionGroup = false;
            singleQuestion.textComponent = false;
            singleQuestion.componentType = question.Child_Enrollment_Component__r.Component_Type__c;
            singleQuestion.schoolYear = question.Child_Enrollment_Component__r.Question_School_Year__c;
            singleQuestion.parentId = groupId;
            newQuestions.add(singleQuestion);
        }

        // Grab records we need for evaluation and data updates
        User caretaker = [SELECT Id, Contact.AccountId, ContactId, Contact.RecordType.Name FROM User WHERE Id = :UserInfo.getUserId()];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__c FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];

        //Grab map of object name to list of strings for querying
        Map<String, List<String>> studentMap = NES_EvaluateUtil.getQueryMap(newQuestions, 'Student');
        Map<String, List<String>> caretakerMap = NES_EvaluateUtil.getQueryMap(newQuestions, 'Household');

        // Grab maps of data that hold the related records for the object
        Map<String, List<SObject>> studentDataMap = NES_EvaluateUtil.getObjectDataList(studentMap, programEnrollmentId, caretaker.Contact.AccountId, studentEnrollment.hed__Contact__c);
        Map<String, List<SObject>> caretakerDataMap = NES_EvaluateUtil.getObjectDataList(caretakerMap, studentEnrollment.Household_Program_Enrollment__c, caretaker.Contact.AccountId, caretaker.ContactId);

        NES_QuestionsHelper.saveAnswers(studentDataMap, caretakerDataMap, newQuestions, studentEnrollment.Id, studentEnrollment.Household_Program_Enrollment__c);

        System.debug('About to save address');
        System.debug('The value of API validated is: ' + apiValidated);

        //create list to hold updates and loop through
        List<Enrollment_Component_Affiliation__c> affiliationsForUpdate = new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c affiliation : affiliations) {

            System.debug(affiliation.Name);
            System.debug(affiliation.Enrollment_Component__c);
            System.debug('Was it contained');
            // if this is one of OUR affiliations, we update to complete and mark API validated
            if (questionIds.contains(affiliation.Enrollment_Component__c)) {
                System.debug('Marking MDR SChool as validated');
                affiliation.Status__c = 'Complete';
                affiliation.API_Validated__c = apiValidated;
                affiliationsForUpdate.add(affiliation);
            }

        }

        try {
            update affiliationsForUpdate;
        } catch(Exception e) {
            logger.logException('savingAnswers', e);
            logger.saveLogs();
            throw e;
        }
    }

    public static void saveTheAnswers(Id programEnrollmentId, Id groupId, List<NES_EvaluateUtil.Question> questionData, Boolean apiValidated) {

        List<Id> questionIds = new List<Id>();
        for (NES_EvaluateUtil.Question singleQuestion : questionData) {
            questionIds.add(singleQuestion.questionId);
        }
        questionIds.add(groupId);

        //Grab all question affiliations
        List<Enrollment_Component_Affiliation__c> affiliations = [
                SELECT Id, Enrollment_Component__c, Status__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__c = :programEnrollmentId
                AND Enrollment_Component__c IN :questionIds
        ];


        // Grab records we need for evaluation and data updates
        User caretaker = [SELECT Id, Contact.AccountId, ContactId, Contact.RecordType.Name FROM User WHERE Id = :UserInfo.getUserId()];
        hed__Program_Enrollment__c studentEnrollment = [SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__c FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];

        //Grab map of object name to list of strings for querying
        Map<String, List<String>> studentMap = NES_EvaluateUtil.getQueryMap(questionData, 'Student');
        Map<String, List<String>> caretakerMap = NES_EvaluateUtil.getQueryMap(questionData, 'Household');

        // Grab maps of data that hold the related records for the object
        Map<String, List<SObject>> studentDataMap = NES_EvaluateUtil.getObjectDataList(studentMap, programEnrollmentId, caretaker.Contact.AccountId, studentEnrollment.hed__Contact__c);
        Map<String, List<SObject>> caretakerDataMap = NES_EvaluateUtil.getObjectDataList(caretakerMap, studentEnrollment.Household_Program_Enrollment__c, caretaker.Contact.AccountId, caretaker.ContactId);

        NES_QuestionsHelper.saveAnswers(studentDataMap, caretakerDataMap, questionData, studentEnrollment.Id, studentEnrollment.Household_Program_Enrollment__c);

        //create list to hold updates and loop through
        List<Enrollment_Component_Affiliation__c> affiliationsForUpdate = new List<Enrollment_Component_Affiliation__c>();
        for (Enrollment_Component_Affiliation__c affiliation : affiliations) {

            // if this is one of OUR affiliations, we update to complete and mark API validated
            if (questionIds.contains(affiliation.Enrollment_Component__c)) {
                affiliation.Status__c = 'Complete';
                affiliation.API_Validated__c = apiValidated;
                affiliationsForUpdate.add(affiliation);
            }

        }

        try {
            update affiliationsForUpdate;
        } catch(Exception e) {
            logger.logException('saveTheAnswers', e);
            logger.saveLogs();
            throw e;
        }
    }

    public static List<NES_EvaluateUtil.Question> grabQuestions(Id questionGroupId, Id programEnrollmentId) {

        System.debug('In grabbing questions');
        System.debug(questionGroupId);
        System.debug(programEnrollmentId);

        // For new ECA Model, need to fetch question a bit differently since we don't create ECAs for Question/QuestionGroups
        List<hed__Program_Enrollment__c> studentEnrollment = new List<hed__Program_Enrollment__c>(); 
        studentEnrollment = [SELECT  Id, hed__Account__c, hed__Account__r.Use_Updated_ECA_Process__c, hed__Contact__c
            FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];

        List<Enrollment_Component_Relationship__c> questionRelationships;
        if (studentEnrollment.size() >0 && !studentEnrollment[0].hed__Account__r.Use_Updated_ECA_Process__c)
        {
            List<Enrollment_Component_Affiliation__c> questionAffiliations = [
                    SELECT Enrollment_Component__c, Id, Name, Enrollment_Component__r.Name
                    FROM Enrollment_Component_Affiliation__c
                    WHERE Program_Enrollment__c = :programEnrollmentId
            ];

            List<Id> questionIds = new List<Id>();
            for (Enrollment_Component_Affiliation__c questionAffiliation : questionAffiliations) {
                System.debug('One of the items');
                System.debug(questionAffiliation.Id);
                System.debug(questionAffiliation.Name);
                System.debug(questionAffiliation.Enrollment_Component__r.Name);
                questionIds.add(questionAffiliation.Enrollment_Component__c);
            }

            System.debug('These are the questionIds');
            System.debug(questionIds);

            questionRelationships = [
                    SELECT Order__c, Child_Enrollment_Component__c, Child_Enrollment_Component__r.Question_Type__c,
                            Child_Enrollment_Component__r.Question_Prompt__c,Child_Enrollment_Component__r.Question_Read_Only__c,Child_Enrollment_Component__r.API_Mapping__c, Child_Enrollment_Component__r.Is_Required__c,
                            Child_Enrollment_Component__r.Question_Validation__c, Child_Enrollment_Component__r.Question_Validation_Message__c, Child_Enrollment_Component__r.Answer_Target__c,
                            Child_Enrollment_Component__r.Component_Type__c, Child_Enrollment_Component__r.Question_School_Year__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c = :questionGroupId  AND Child_Enrollment_Component__c IN :questionIds
                    order by External_Id__c
            ];
        } 
        else 
        {
            questionRelationships = [
                SELECT Order__c, Child_Enrollment_Component__c, Child_Enrollment_Component__r.Question_Type__c,
                        Child_Enrollment_Component__r.Question_Prompt__c,Child_Enrollment_Component__r.Question_Read_Only__c,Child_Enrollment_Component__r.API_Mapping__c, Child_Enrollment_Component__r.Is_Required__c,
                        Child_Enrollment_Component__r.Question_Validation__c, Child_Enrollment_Component__r.Question_Validation_Message__c, Child_Enrollment_Component__r.Answer_Target__c,
                        Child_Enrollment_Component__r.Component_Type__c, Child_Enrollment_Component__r.Question_School_Year__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c = :questionGroupId
                order by External_Id__c
            ];
        }

            System.debug('The question relationships');
            System.debug(questionRelationships);

        // hed__Program_Enrollment__c studentEnrollment = [SELECT hed__Account__c FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
        List<NES_EvaluateUtil.Question> questions = new List<NES_EvaluateUtil.Question>();
        List<Id> questionComponentIds = new List<Id>();

        for (Enrollment_Component_Relationship__c groupRelationship : questionRelationships) {

            System.debug(groupRelationship.Child_Enrollment_Component__r.Question_Type__c);
            NES_EvaluateUtil.Question newQuestion = new NES_EvaluateUtil.Question();
            newQuestion.questionType = groupRelationship.Child_Enrollment_Component__r.Question_Type__c;
            newQuestion.questionTarget = groupRelationship.Child_Enrollment_Component__r.Answer_Target__c;
            newQuestion.questionId = groupRelationship.Child_Enrollment_Component__c;
            newQuestion.questionPrompt = groupRelationship.Child_Enrollment_Component__r.Question_Prompt__c;
            newQuestion.questionReadOnly = groupRelationship.Child_Enrollment_Component__r.Question_Read_Only__c;
            newQuestion.questionGroup = false;
            newQuestion.textComponent = false;
            newQuestion.validation = groupRelationship.Child_Enrollment_Component__r.Question_Validation__c;
            newQuestion.validationMessage = groupRelationship.Child_Enrollment_Component__r.Question_Validation_Message__c;
            newQuestion.order = groupRelationship.Order__c;
            newQuestion.componentType = groupRelationship.Child_Enrollment_Component__r.Component_Type__c;
            newQuestion.schoolYear = groupRelationship.Child_Enrollment_Component__r.Question_School_Year__c;
            newQuestion.apiMapping = groupRelationship.Child_Enrollment_Component__r.API_Mapping__c;
            newQuestion.required = groupRelationship.Child_Enrollment_Component__r.Is_Required__c;
            newQuestion.targetField = groupRelationship.Child_Enrollment_Component__r.Answer_Target__c;
            questions.add(newQuestion);
            questionComponentIds.add(newQuestion.questionId);
        }

        System.debug('Should now have things to return');
        System.debug(questions);
        System.debug(questions.size());
        List <Option_Exclusion__c> exclusions = new List <Option_Exclusion__c>();
        if(studentEnrollment.size() > 0){
            
            //Create a map of Option_Exclusion__c record for the above account and Enrollment components records
            exclusions = [
                    SELECT Id, Academic_Program__c, Option__c
                    FROM Option_Exclusion__c
                    WHERE Academic_Program__c = :studentEnrollment[0].hed__Account__c
                    AND Option__r.Enrollment_Component__c IN :questionComponentIds
            ];
        }
        Map<Id, Option_Exclusion__c> optionExclusionMap = new Map<Id, Option_Exclusion__c>();
        for (Option_Exclusion__c rec : exclusions) {
            if (!optionExclusionMap.containsKey(rec.Option__c)) {
                optionExclusionMap.put(rec.Option__c, rec);
            }
        }

        Map<Id, List<Enrollment_Component_Picklist_Option__c> > optionMap = NES_QuestionsHelper.getAllPicklistOptions(questionComponentIds);
        System.debug('The option Map');
        System.debug(optionMap);
        for (NES_EvaluateUtil.Question question : questions) {
            if (question.questionType == 'Picklist' || question.questionType == 'Radio' || question.questionType == 'Checkbox Group') {
                System.debug('About to access group');
                List<Enrollment_Component_Picklist_Option__c> options = optionMap.get(question.questionId);
                List<NES_EvaluateUtil.PicklistOption> optionsForReturn = new List<NES_EvaluateUtil.PicklistOption>();
                if (options != null) {
                    if (options.size() > 0) {
                        for (Enrollment_Component_Picklist_Option__c option : options) {

                            if (!optionExclusionMap.keySet().contains(option.Id)) {
                                NES_EvaluateUtil.PicklistOption picklistOption = new NES_EvaluateUtil.PicklistOption();
                                picklistOption.order = option.Order__c;
                                picklistOption.label = option.Option_Label__c;
                                picklistOption.value = option.Option_Value__c;
                                optionsForReturn.add(picklistOption);
                            }
                        }
                        question.picklistValues = optionsForReturn;
                    }
                }
            }
        }

        return questions;
    }
}