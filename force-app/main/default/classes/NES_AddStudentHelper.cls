/**
 * Change Log:
 *   2018-12-26 Created (triciaigoe) 
 *   2019-08-09 Updated query to include Question_Read_Only__c for 101924 (Andrew Sim) 
  * Change Log:
 *         2019-10-03 #US102165 Additional fields for the Registration process (Mark Membrino) 
 *         2019-11-08 #US116612 Additional fields for the Add Student process (Anitha P) 
 */

public without sharing class NES_AddStudentHelper {
    private static Peak_ApexLog logger = new Peak_ApexLog('AddStudentHelper');

    /* Grab all the supplemental questions required by the entered school */
    public static List<NES_EvaluateUtil.Question> grabQuestionsBySchool(Id institutionId, Id yearId) {

        User caretaker = [SELECT Contact.AccountId, Contact.inputParameter__c, ContactId, Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.debug(institutionId + ' ' + yearId);
        if (institutionId == null || yearId == null) {
            return null;
        }

        Id programRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        List <Account> schools = [
                SELECT Id, Name
                FROM Account
                WHERE Registration_End_Date__c >= TODAY AND
                Registration_Start_Date__c <= TODAY AND RecordTypeId = :programRecordTypeId
                AND ParentId = :institutionId AND School_Year__c = :yearId
        ];
        System.debug(schools);
        Id schoolId = schools[0].Id;

        List<NES_EvaluateUtil.Question> returnObjList;

        // Grab all the record type Ids
        Id sectionEnrollmentRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get(NES_DashboardUtilities.SECTION_RT).getRecordTypeId();
        Id questionGroupRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get(NES_DashboardUtilities.QUESTIONGROUP_RT).getRecordTypeId();
        Id questionsEnrollmentRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get(NES_DashboardUtilities.QUESTION_RT).getRecordTypeId();

        //Get a List of Process type Enrollment Component records For Process Academic Program
        List<Enrollment_Component__c> processComponentList = [SELECT Id FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :schoolId AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT];

        //Find the Id of the First Stage by using the Order on the Enrollment Relationships object
        Id firstStageComponentId;
        List<Enrollment_Component_Relationship__c> processRelationships = [
                SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN :processComponentList
                AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
                ORDER BY Order__c ASC
        ];
        if (processRelationships.size() > 0) {
            firstStageComponentId = processRelationships[0].Child_Enrollment_Component__c;
        }

        List<Id> componentIdsForLater = new List<Id>();

        // Create map for storing the Enrollment Component Id, assignment logic
        Map<Id, String> assignmentLogicMap = new Map<Id, String>();

        //If first stage record exists find all the related Form Components
        Set<Id> formComponentIds = new Set<Id>();
        if (firstStageComponentId != null) {
            List <Enrollment_Component_Relationship__c> stageRelationships = [
                    SELECT Id, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c, Parent_Enrollment_Component__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c = :firstStageComponentId
                    AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
                    ORDER BY Order__c ASC
            ];

            for (Enrollment_Component_Relationship__c rel : stageRelationships) {
                formComponentIds.add(rel.Child_Enrollment_Component__c);
                if (String.isNotBlank(rel.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                    assignmentLogicMap.put(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Assignment_Logic__c);
                }
            }
            componentIdsForLater.addAll(formComponentIds);

            //Get all the Section Records using the form Ids
            Set<Id> sectionComponentIds = new Set<Id>();
            if (formComponentIds.size() > 0) {
                List<Enrollment_Component_Relationship__c> formRelationships = [
                        SELECT Id, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c,
                                Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name
                        FROM Enrollment_Component_Relationship__c
                        WHERE Parent_Enrollment_Component__c IN :formComponentIds
                        AND Child_Enrollment_Component__r.RecordTypeId = :sectionEnrollmentRecordTypeId
                        ORDER BY Order__c ASC
                ];

                for (Enrollment_Component_Relationship__c rel : formRelationships) {
                    sectionComponentIds.add(rel.Child_Enrollment_Component__c);
                    if (String.isNotBlank(rel.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                        assignmentLogicMap.put(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Assignment_Logic__c);
                    }
                }
                componentIdsForLater.addAll(sectionComponentIds);

                //Get all the Questions records using the section Ids
                Set<Id> questionComponentIds = new Set<Id>();
                if (sectionComponentIds.size() > 0) {
                    List<Enrollment_Component_Relationship__c> sectionRelationships = [
                            SELECT Id, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordTypeId,
                                    Child_Enrollment_Component__r.Assignment_Logic__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name
                            FROM Enrollment_Component_Relationship__c
                            WHERE Parent_Enrollment_Component__c IN :sectionComponentIds
                            AND (Child_Enrollment_Component__r.RecordTypeId = :questionsEnrollmentRecordTypeId OR
                            Child_Enrollment_Component__r.RecordTypeId = :questionGroupRecordTypeId)
                            ORDER BY Order__c ASC
                    ];
                    System.debug('sectionRelationships****' + sectionRelationships);
                    List<Id> groupComponentIds = new List<Id>();
                    Map<Id, Enrollment_Component_Relationship__c> childOfSectionMap = new Map<Id, Enrollment_Component_Relationship__c>();

                    for (Enrollment_Component_Relationship__c rel : sectionRelationships) {

                        if (String.isNotBlank(rel.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                            assignmentLogicMap.put(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Assignment_Logic__c);
                        }

                        if (rel.Child_Enrollment_Component__r.RecordTypeId == questionGroupRecordTypeId) {
                            groupComponentIds.add(rel.Child_Enrollment_Component__c);
                        } else {
                            questionComponentIds.add(rel.Child_Enrollment_Component__c);
                        }
                    }
                    componentIdsForLater.addAll(groupComponentIds);

                    List<Enrollment_Component_Relationship__c> groupRelationships = [
                            SELECT Id, Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name,
                                    Child_Enrollment_Component__r.Assignment_Logic__c
                            FROM Enrollment_Component_Relationship__c
                            WHERE Parent_Enrollment_Component__c IN :groupComponentIds
                            AND Child_Enrollment_Component__r.RecordTypeId = :questionsEnrollmentRecordTypeId
                            ORDER BY Order__c ASC
                    ];
                    List<Id> groupQuestionIds = new List<Id>();
                    for (Enrollment_Component_Relationship__c rel : groupRelationships) {
                        if (String.isNotBlank(rel.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                            assignmentLogicMap.put(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Assignment_Logic__c);
                        }
                        questionComponentIds.add(rel.Child_Enrollment_Component__c);
                        groupQuestionIds.add(rel.Child_Enrollment_Component__c);
                    }

                    componentIdsForLater.addAll(questionComponentIds);

                    //Instantiate variables needed
                    Map<Id, Option_Exclusion__c> optionExclusionMap = new Map<Id, Option_Exclusion__c>();
                    returnObjList = new List<NES_EvaluateUtil.Question>();

                    List<hed__Program_Enrollment__c> caretakerProgramEnrollments = [
                            SELECT Id
                            FROM hed__Program_Enrollment__c
                            WHERE hed__Contact__c = :caretaker.ContactId
                            AND hed__Account__c = :schoolId
                    ];
                    Id caretakerEnrollmentId;
                    if (caretakerProgramEnrollments.size() > 0) {
                        caretakerEnrollmentId = caretakerProgramEnrollments[0].Id;
                    }

                    // evaluate which components with assignment criteria are valid and add their Ids to a list
                    List<Enrollment_Component__c> componentsForAssignment = new List<Enrollment_Component__c>();
                    System.debug('Assignmentlogic: ' + assignmentLogicMap);
                    if (assignmentLogicMap.size() > 0) {
                        componentsForAssignment = NES_ECAEvaluation.evaluateEligibilityComponents(assignmentLogicMap.keySet(), null, caretaker.ContactId, caretaker.Contact.AccountId, null, caretakerEnrollmentId);
                    }
                    List<Id> returnedComponentIds = new List<Id>();

                    for (Enrollment_Component__c componentForAssignment : componentsForAssignment) {
                        returnedComponentIds.add(componentForAssignment.Id);
                    }
                    System.debug(returnedComponentIds);

                    // if there are any possible questions, continue evaluating
                    if (questionComponentIds.size() > 0 || returnedComponentIds.size() > 0) {

                        // Now go back through the relationships that we found before and add only those enrollment components without logic or assigned here
                        List<Id> newFormIds = new List<Id>();
                        Map<Id, Decimal> formOrderMap = new Map<Id, Decimal>();
                        for (Enrollment_Component_Relationship__c stageRelationship : stageRelationships) {
                            if (String.isBlank(stageRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                                newFormIds.add(stageRelationship.Child_Enrollment_Component__c);
                                formOrderMap.put(stageRelationship.Child_Enrollment_Component__c, stageRelationship.Order__c);
                            } else {
                                if (returnedComponentIds.contains(stageRelationship.Child_Enrollment_Component__c)) {
                                    newFormIds.add(stageRelationship.Child_Enrollment_Component__c);
                                    formOrderMap.put(stageRelationship.Child_Enrollment_Component__c, stageRelationship.Order__c);
                                }
                            }
                        }
                        System.debug('newFormIds++' + newFormIds);
                        // if there are any forms, continue down
                        if (newFormIds.size() > 0) {
                            List<Id> newSectionIds = new List<Id>();
                            Map<Id, Decimal> sectionOrderMap = new Map<Id, Decimal>();
                            Map<Id, List<Id>> formToSectionMap = new Map<Id, List<Id>>();
                            for (Enrollment_Component_Relationship__c formRelationship : formRelationships) {
                                System.debug(formRelationship);
                                if (newFormIds.contains(formRelationship.Parent_Enrollment_Component__c)) {
                                    if (String.isBlank(formRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                                        newSectionIds.add(formRelationship.Child_Enrollment_Component__c);
                                    } else {
                                        if (returnedComponentIds.contains(formRelationship.Child_Enrollment_Component__c)) {
                                            newSectionIds.add(formRelationship.Child_Enrollment_Component__c);
                                        }
                                    }
                                    sectionOrderMap.put(formRelationship.Child_Enrollment_Component__c, formRelationship.Order__c);
                                    formToSectionMap.put(formRelationship.Parent_Enrollment_Component__c, newSectionIds);
                                }
                            }
                            System.debug('newSectionIds++' + newSectionIds);
                            //if there are any sections, continue down
                            List<Id> newQuestionIds = new List<Id>();
                            List<Id> newGroupIds = new List<Id>();
                            Map<Id, Decimal> groupOrderMap = new Map<Id, Decimal>();
                            Map<Id, Decimal> questionOrderMap = new Map<Id, Decimal>();
                            Map<Id, List<Id>> sectionToGroupMap = new Map<Id, List<Id>>();
                            Map<Id, List<Id>> sectionToQuestionMap = new Map<Id, List<Id>>();
                            System.debug('sectionRelationships+++' + sectionRelationships);
                            for (Enrollment_Component_Relationship__c sectionRelationship : sectionRelationships) {
                                System.debug('sectionRelationship.Parent' + sectionRelationship.Parent_Enrollment_Component__c);
                                System.debug('sectionRelationship.Child' + sectionRelationship.Child_Enrollment_Component__c);
                                if (newSectionIds.contains(sectionRelationship.Parent_Enrollment_Component__c)) {
                                    System.debug('newSectionIds.contains(sectionRelationship.Parent_Enrollment_Component__c)++');
                                    if (String.isBlank(sectionRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                                        System.debug('********');
                                        if (sectionRelationship.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                                            newGroupIds.add(sectionRelationship.Child_Enrollment_Component__c);
                                            groupOrderMap.put(sectionRelationship.Child_Enrollment_Component__c, sectionRelationship.Order__c);
                                        } else if (sectionRelationship.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT) {
                                            newQuestionIds.add(sectionRelationship.Child_Enrollment_Component__c);
                                            questionOrderMap.put(sectionRelationship.Child_Enrollment_Component__c, sectionRelationship.Order__c);
                                        }
                                    } else {
                                        if (returnedComponentIds.contains(sectionRelationship.Child_Enrollment_Component__c)) {
                                            if (sectionRelationship.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                                                newGroupIds.add(sectionRelationship.Child_Enrollment_Component__c);
                                                groupOrderMap.put(sectionRelationship.Child_Enrollment_Component__c, sectionRelationship.Order__c);
                                            } else if (sectionRelationship.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTION_RT) {
                                                newQuestionIds.add(sectionRelationship.Child_Enrollment_Component__c);
                                                questionOrderMap.put(sectionRelationship.Child_Enrollment_Component__c, sectionRelationship.Order__c);
                                            }
                                        }
                                    }
                                    if (newGroupIds.size() > 0) {
                                        sectionToGroupMap.put(sectionRelationship.Parent_Enrollment_Component__c, newGroupIds);
                                    }
                                    if (newQuestionIds.size() > 0) {
                                        sectionToQuestionMap.put(sectionRelationship.Parent_Enrollment_Component__c, newQuestionIds);
                                    }

                                }
                            }

                            // Go through the question groups if there are any
                            Map<Id, List<Id>> groupQuestionMap = new Map<Id, List<Id>>();
                            if (newGroupIds.size() > 0) {
                                System.debug('newGroupIds>>>>>>>>>>' + newGroupIds);
                                for (Enrollment_Component_Relationship__c groupRelationship : groupRelationships) {
                                    System.debug('groupRelationship.Parent_Enrollment_Component__c>>>>>>>>>>>>>>' + groupRelationship.Parent_Enrollment_Component__c);
                                    if (newGroupIds.contains(groupRelationship.Parent_Enrollment_Component__c)) {
                                        if (String.isBlank(groupRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                                            newQuestionIds.add(groupRelationship.Child_Enrollment_Component__c);
                                        } else {
                                            if (returnedComponentIds.contains(groupRelationship.Child_Enrollment_Component__c)) {
                                                newQuestionIds.add(groupRelationship.Child_Enrollment_Component__c);
                                            }
                                        }
                                        questionOrderMap.put(groupRelationship.Child_Enrollment_Component__c, groupRelationship.Order__c);
                                        groupQuestionMap.put(groupRelationship.Parent_Enrollment_Component__c, newQuestionIds);
                                    }
                                }
                            }

                            //Create a map of Option_Exclusion__c record for the above account and Enrollment components records
                            List <Option_Exclusion__c> exclusions = [
                                    SELECT Id, Academic_Program__c, Option__c
                                    FROM Option_Exclusion__c
                                    WHERE Academic_Program__c = :schoolId AND Option__r.Enrollment_Component__c IN :newQuestionIds
                            ];
                            for (Option_Exclusion__c rec : exclusions) {

                                if (!optionExclusionMap.containsKey(rec.Option__c)) {
                                    optionExclusionMap.put(rec.Option__c, rec);
                                }
                            }

                            // Final list of questions
                            List <Enrollment_Component__c> questionComponents = [
                                    SELECT Answer_Target__c, Assignment_Logic__c, Completion_Logic__c, Component_Message__c, Component_Type__c,
                                            CreatedById, CreatedDate, Data_type_of_operation__c, Document_File_Formats__c, Document_Submission_End_Date__c,
                                            Document_Submission_Start_Date__c, End_Date__c, Enrollment_End_Date__c, Enrollment_Start_Date__c,
                                            External_Id__c, Filter_Logic__c, Final_Confirmation_Form_End_Date__c, Final_Confirmation_Form_Start_Date__c,
                                            First_Semester_End_Date__c, Help_Text__c, Id, Is_Required__c, IsDeleted, Label__c, LastModifiedById,
                                            LastModifiedDate, LastViewedDate, Name, Order__c, OwnerId, Process_Academic_Program__c,
                                            Program_Enrollment_Close_Date__c, Question_Prompt__c, Question_Read_Only__c, Question_School_Year__c, Question_Target__c,
                                            Question_Type__c, Question_Validation__c, Question_Validation_Message__c, RecordTypeId,
                                            School_End_Date__c, School_Start_Date__c, School_Student_Start_Date__c, Second_Semester_End_Date__c, API_Mapping__c, Default_Value__c,
                                            Second_Semester_Start_Date__c, Start_Date__c, Status__c,Tooltip_Text__c, RecordType.Name, (SELECT Id, Option_Label__c, Option_Value__c, Order__c FROM Enrollment_Component_Picklist_Options__r ORDER BY Order__c ASC), (SELECT Id, Criteria_Type__c FROM Enrollment_Component_Criteria__r)
                                    FROM Enrollment_Component__c
                                    WHERE Id IN:newQuestionIds
                            ];

                            //Grab List of target fields and create Map for query
                            Set<String> targetStrings = new Set<String>();
                            for (Enrollment_Component__c question : questionComponents) {

                                if(question.Question_Validation__c != null){
                                    question.Question_Validation__c = question.Question_Validation__c.replaceAll('<[^>]+>','');
                                }
                                
                                if (question.Component_Type__c == 'Household') {
                                    targetStrings.add(question.Answer_Target__c);
                                }
                            }

                            Map<String, List<String>> queryMapping = new Map<String, List<String>>();
                            Map<String, List<SObject>> dataMap = new Map<String, List<SObject>>();
                            System.debug('targetStrings: ' + targetStrings);
                            if (targetStrings.size() > 0) {
                                queryMapping = NES_EvaluateUtil.configureQueryMap(targetStrings);
                                dataMap = NES_EvaluateUtil.getObjectDataList(queryMapping, caretakerEnrollmentId, caretaker.Contact.AccountId, caretaker.ContactId);
                            }


                            Map<Id, Decimal> overallOrderMap = new Map<Id, Decimal>();
                            Decimal overallOrder = 1;
                            for (Id formId : formComponentIds) {

                                if (newFormIds.contains(formId)) {
                                    System.debug('formId: ' + formId);
                                    //Start of Modification by Ajith to check null condition and test class coverage
                                    List<Id> childSectionIds = new List<Id>();
                                    if (formToSectionMap.get(formId) != null)
                                        childSectionIds = formToSectionMap.get(formId);
                                    //End of Modification by Ajith to check null condition and test class coverage
                                    for (Id childSectionId : childSectionIds) {

                                        if (newSectionIds.contains(childSectionId)) {
                                            System.debug('sectionId: ' + childSectionId);
                                            List<Id> childQuestionIds = new List<Id>();
                                            List<Id> childGroupIds = new List<Id>();
                                            if (sectionToGroupMap.keySet().contains(childSectionId)) {
                                                childGroupIds = sectionToGroupMap.get(childSectionId);

                                                for (Id childGroupId : childGroupIds) {
                                                    if (newGroupIds.contains(childGroupId)) {
                                                        if (groupQuestionMap.keySet().contains(childGroupId)) {

                                                            childQuestionIds = groupQuestionMap.get(childGroupId);
                                                            for (Id childQuestionId : childQuestionIds) {

                                                                if (newQuestionIds.contains(childQuestionId)) {
                                                                    System.debug('questionOrder: ' + overallOrder);
                                                                    System.debug(childQuestionId);
                                                                    overallOrderMap.put(childQuestionId, overallOrder);
                                                                    overallOrder++;
                                                                }
                                                            }

                                                        }
                                                    }
                                                }
                                            } else if (sectionToQuestionMap.keySet().contains(childSectionId)) {
                                                childQuestionIds = sectionToQuestionMap.get(childSectionId);
                                                for (Id childQuestionId : childQuestionIds) {

                                                    if (newQuestionIds.contains(childQuestionId)) {
                                                        System.debug('questionOrder: ' + overallOrder);
                                                        System.debug(childQuestionId);
                                                        overallOrderMap.put(childQuestionId, overallOrder);
                                                        overallOrder++;
                                                    }
                                                }
                                            }

                                        }
                                    }
                                }
                            }
                            System.debug('here');
                            System.debug(overallOrderMap);
                            for (Enrollment_Component__c question : questionComponents) {
                                NES_EvaluateUtil.Question wrap = new NES_EvaluateUtil.Question();
                                Decimal ordering = overallOrderMap.get(question.Id);
                                System.debug('ordering: ' + ordering);
                                if (groupQuestionIds.contains(question.Id)) {
                                    wrap = NES_EvaluateUtil.configureQuestion(question, optionExclusionMap, dataMap, ordering, true, null, new Set<String>{});
                                } else {
                                    wrap = NES_EvaluateUtil.configureQuestion(question, optionExclusionMap, dataMap, ordering, false, null, new Set<String>{});
                                }
                                returnObjList.add(wrap);
                            }
                        }
                    }
                }
            }
        }
        return returnObjList;
    }

    /* Creates the student related to the caretaker*/
    public static Peak_Response insertingStudent(String studentJSON, String questionJSON) {
        Peak_Response peakResponse = new Peak_Response();
        User caretaker = [SELECT Id, AccountId, ContactId, Contact.RecordType.Name,Contact.Account.Family_Enrollment_Counselor__c, Contact.AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        List <Contact> CtList = [Select Id from Contact where AccountId =: caretaker.Contact.AccountId 
                                 and Recordtype.name != 'Students'];
        System.debug('NDEBUG: List of Contacts under this HH Acc:::'+CtList);
        System.debug('student data');
        System.debug(studentJSON);
        System.debug('questionJSON' + questionJSON);

        // Make sure that completion logic is not evaluated now through triggers
        NES_ECACompletion.shouldRunCompletion = false;
        NES_Constants.runAssignment = false;
        NES_LTSUtility.runLTSFlag = false;
        NES_ProgramEnrollmentHandler.runCBL = false;

        // if there is a student continue, else do nothing
        if (String.isNotBlank(studentJSON)) {

            try {

                // Deserialize the JSON
                List<NES_EvaluateUtil.Question> questionDataList = (List<NES_EvaluateUtil.Question>) JSON.deserialize(questionJSON, List<NES_EvaluateUtil.Question>.class);
                NES_EvaluateUtil.NewStudentData studentData = (NES_EvaluateUtil.NewStudentData) JSON.deserialize(studentJSON, NES_EvaluateUtil.NewStudentData.class);

                //Insert Contact for the student
                String firstName = String.isNotBlank(studentData.firstName) ? studentData.firstName : '';
                String middleName = String.isNotBlank(studentData.middleName) ? studentData.middleName : '';//added for US116612
                String lastName = String.isNotBlank(studentData.lastName) ? studentData.lastName : '';
                String suffix = String.isNotBlank(studentData.suffix) ? studentData.suffix : ''; //added for US116612
                String relation = String.isNotBlank(studentData.relationshipType) ? studentData.relationshipType : '';
                System.debug(caretaker.Contact.RecordType.Name);
                Id studentRecordType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
                Contact newStudent = NES_RegistrationUtils.createContact(caretaker.Contact.AccountId, studentRecordType, firstName, lastName, relation, caretaker.ContactId, '', middleName, suffix, null, null, true, null);//added middle and suffix for US116612

                //Insert relationship between the caretaker and the student
               /* hed__Relationship__c relationship = new hed__Relationship__c();
                relationship.hed__Contact__c = newStudent.Id;
                relationship.hed__Status__c = 'Current';
                relationship.hed__RelatedContact__c = caretaker.ContactId;
                relationship.Recalculate_Sharing__c = true;
                relationship.hed__Type__c = relation;
                relationship.OwnerId = System.Label.NES_Household_OwnerId;
                insert relationship; */
                
                //Naveen:: Insert relationship between all the caretakers under this HH and the new student
                List <hed__Relationship__c> relationshipList = new List <hed__Relationship__c> ();                
                for(Contact c: CtList){
                    hed__Relationship__c relationship = new hed__Relationship__c();
                    relationship.hed__Contact__c = newStudent.Id;
                    relationship.hed__Status__c = 'Current';
                    relationship.hed__RelatedContact__c = c.Id;
                    relationship.Recalculate_Sharing__c = true;
                    relationship.hed__Type__c = relation;
                    relationship.OwnerId = System.Label.NES_Household_OwnerId;
                    relationshipList.add(relationship);
                }
                System.debug('NDEBUG: List of Relationships:::'+relationshipList);
                insert relationshipList;


                //Get Program Enrollments and insert them.  Also retrieve the field that determines which version of the ECA 
                Id academicProgramRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
                Account academicProgram = [
                        SELECT Id, ParentId, RecordTypeId, School_Year__c, OwnerId, Confirmation_End_Date__c, Use_Updated_ECA_Process__c,

                               Too_Young_Cutoff__c, Too_Old_Cutoff__c,MaxSpecialEdBirthdate__c
                        FROM Account
                        WHERE ParentId = :studentData.SelectedSchoolId
                        AND RecordTypeId = :academicProgramRecordTypeId
                        AND School_Year__c = :studentData.SelectedSchoolYear
                        LIMIT 1
                ];

                List<hed__Program_Enrollment__c> caretakerEnrollment = [SELECT Id, hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c = :caretaker.ContactId AND hed__Account__c = :academicProgram.Id];

                //Check Whether Program Enrollment already exist or not for the caretaker if it is not present then insert it
                Id caretakerEnrollmentId;
                hed__Program_Enrollment__c newCareTakerEnrollment = new hed__Program_Enrollment__c();
                if (caretakerEnrollment.size() == 0) {
                    Id caretakerEnrollmentTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
                    newCareTakerEnrollment.hed__Contact__c = caretaker.ContactId;
                    newCareTakerEnrollment.RecordTypeId = caretakerEnrollmentTypeId;
                    newCareTakerEnrollment.OwnerId = academicProgram.OwnerId;
                    if (academicProgram != null) {
                        newCareTakerEnrollment.hed__Account__c = academicProgram.Id;
                    }
                    insert newCareTakerEnrollment;
                    caretakerEnrollmentId = newCareTakerEnrollment.Id;
                } else {
                    newCareTakerEnrollment = caretakerEnrollment[0];
                    caretakerEnrollmentId = caretakerEnrollment[0].Id;
                }

                //Program Enrollment for student
                hed__Program_Enrollment__c newStudentEnrollment = new hed__Program_Enrollment__c();
                Id studentEnrollmentTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
                newStudentEnrollment.hed__Contact__c = newStudent.Id;
                newStudentEnrollment.RecordTypeId = studentEnrollmentTypeId;
                newStudentEnrollment.Household_Program_Enrollment__c = caretakerEnrollmentId;
                newStudentEnrollment.hed__Account__c = academicProgram.Id;
                newStudentEnrollment.Start_Year__c = studentData.SelectedSchoolYear;
                newStudentEnrollment.OwnerId = academicProgram.OwnerId;
                newStudentEnrollment.Has_Open_Opportunity__c = true;
                insert newStudentEnrollment;

                //Now let's create an Opportunity based on that enrollmentId
                //Modified the ownerId as per the bug #77521 to match the Academic Program Owner
                Opportunity oppToInsert = new Opportunity(
                        Name = newStudent.FirstName + ' ' + newStudent.LastName + ' Opportunity',
                        OwnerId = academicProgram.OwnerId,
                        Caretaker_Id__c = caretaker.ContactId,
                        Student_Id__c = newStudent.Id,
                        AccountId = newStudent.AccountId,
                        Program_Enrollment__c = newStudentEnrollment.Id,
                        StageName = 'Open',
                        CloseDate = academicProgram.Confirmation_End_Date__c == null ? Date.today() : academicProgram.Confirmation_End_Date__c.date()
                );

                insert oppToInsert;

                // instantiate affiliations to insert, gather record type ids
                Set<Enrollment_Component_Affiliation__c> ecAffiliationsToInsert = new Set<Enrollment_Component_Affiliation__c>();

                List<Enrollment_Component__c> processComponent = [
                        SELECT Id, Assignment_Logic__c
                        FROM Enrollment_Component__c
                        WHERE Process_Academic_Program__c = :academicProgram.Id
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

                //Iterate over a list of Question Data to get Enrollment Components
                System.debug(questionDataList);
                Set<id> referencedSchoolYears = new Set<Id>();
                List<Id> questionIds = new List<Id>();
                for (NES_EvaluateUtil.Question data : questionDataList) {
                    questionIds.add(data.questionId);
                    referencedSchoolYears.add(data.schoolYear);
                }

                //build a map of school year ids to the 
                Map<Id, School_Year__c> schoolYearMap = new Map<Id, School_Year__c>();
                for ( School_Year__c s : [SELECT Id, External_Id__c FROM School_Year__c where id in :referencedSchoolYears] ) 
                    schoolYearMap.put(s.id, s);

                //Hang on to the birth date so we can use it in the hard stop logic at the end of the process.
                date birthdate;
                                            
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
                            if (careTakerEnrollment.size() > 0 && data.componentType == 'Household') {
                              
                                if (objectApiName == 'Account') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Account WHERE Id = \'' + caretaker.Contact.AccountId + '\' ';
                                } else if (objectApiName == 'Contact') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Contact WHERE Id = \'' + caretaker.Contact + '\' ';
                                } else if (objectApiName == 'hed__Program_Enrollment__c') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM hed__Program_Enrollment__c WHERE Id = \'' + careTakerEnrollment[0].Id + '\' ';
                                } else {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM ' + objectApiName + ' WHERE Program_Enrollment__c = \'' + careTakerEnrollment[0].Id + '\' ';
                                }
                                if (String.isNotBlank(data.schoolYear)) {
                                    query += ' AND School_Year__c = \'' + data.schoolYear + '\' ';
                                }
                                childRecords = Database.query(query);
                            } else {

                                if (objectApiName == 'Account') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Account WHERE Id = \'' + newStudent.AccountId + '\' ';
                                } else if (objectApiName == 'Contact') {
                                    query = 'SELECT Id, ' + fieldApiName + ' FROM Contact WHERE Id = \'' + newStudent.Id + '\' ';
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
                }

                // Add process affiliation
                Enrollment_Component_Affiliation__c affiliationRecord1 = new Enrollment_Component_Affiliation__c();
                affiliationRecord1.Enrollment_Component__c = processComponent[0].Id;
                affiliationRecord1.Program_Enrollment__c = newStudentEnrollment.Id;
                affiliationRecord1.Status__c = 'In Progress';
                ecAffiliationsToInsert.add(affiliationRecord1);

                // add stage 1 affiliation
                Enrollment_Component_Affiliation__c affiliationRecord2 = new Enrollment_Component_Affiliation__c();
                affiliationRecord2.Enrollment_Component__c = relationships[0].Child_Enrollment_Component__c;
                affiliationRecord2.Program_Enrollment__c = newStudentEnrollment.Id;
                affiliationRecord2.Status__c = 'Complete';
                affiliationRecord2.Order__c = relationships[0].Order__c;
                ecAffiliationsToInsert.add(affiliationRecord2);

                //Add the rest of the stages that have no assignment logic.
                for (Integer i = 1; i < relationships.size(); i++) {
                    if (String.isBlank(relationships[i].Child_Enrollment_Component__r.Assignment_Logic__c)) {                
                        Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                        affiliationRecord.Enrollment_Component__c = relationships[i].Child_Enrollment_Component__c;
                        affiliationRecord.Program_Enrollment__c = newStudentEnrollment.Id;
                        affiliationRecord.Order__c = relationships[i].Order__c;
                        //The second stage should be in progress all others not started.
                        if (i == 1)
                            affiliationRecord.Status__c = 'In Progress';
                        else
                            affiliationRecord.Status__c = 'Not Started';
                        ecAffiliationsToInsert.add(affiliationRecord);
                    }
                } 

                //add forms affiliation for the forms under stage 1 that have no assignment logic
                List<Enrollment_Component_Relationship__c> formRelationships = [
                        SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c
                        FROM Enrollment_Component_Relationship__c
                        WHERE Parent_Enrollment_Component__c = :relationships[0].Child_Enrollment_Component__c
                        AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
                        ORDER BY Order__c
                ];
                System.debug(formRelationships);
                List<Id> formRelationshipIds = new List<Id>();
                for (Enrollment_Component_Relationship__c formRelationship : formRelationships) {
                    if (String.isBlank(formRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                        Enrollment_Component_Affiliation__c affiliationRecord3 = new Enrollment_Component_Affiliation__c();
                        affiliationRecord3.Enrollment_Component__c = formRelationship.Child_Enrollment_Component__c;
                        affiliationRecord3.Program_Enrollment__c = newStudentEnrollment.Id;
                        affiliationRecord3.Status__c = 'Complete';
                        affiliationRecord3.Order__c = formRelationship.Order__c;
                        ecAffiliationsToInsert.add(affiliationRecord3);
                        formRelationshipIds.add(formRelationship.Child_Enrollment_Component__c);
                    }
                }

                //add section affiliations that have assignment criteria that were added in the previous section.
                List<Enrollment_Component_Relationship__c> sectionRelationships = [
                        SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c
                        FROM Enrollment_Component_Relationship__c
                        WHERE Parent_Enrollment_Component__c IN :formRelationshipIds
                        AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT
                ];
                System.debug(sectionRelationships);
                for (Enrollment_Component_Relationship__c sectionRelationship : sectionRelationships) {
                    if (String.isBlank(sectionRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                        Enrollment_Component_Affiliation__c affiliationRecord3 = new Enrollment_Component_Affiliation__c();
                        affiliationRecord3.Enrollment_Component__c = sectionRelationship.Child_Enrollment_Component__c;
                        affiliationRecord3.Program_Enrollment__c = newStudentEnrollment.Id;
                        affiliationRecord3.Status__c = 'Complete';
                        affiliationRecord3.Order__c = sectionRelationship.Order__c;
                        ecAffiliationsToInsert.add(affiliationRecord3);
                    }
                }

                List<Enrollment_Component_Affiliation__c> nonNullInsertingAffiliations = new List<Enrollment_Component_Affiliation__c>();
                for (Enrollment_Component_Affiliation__c eca : ecAffiliationsToInsert) {
                    if (eca <> null && eca.Enrollment_Component__c <> null && eca.Program_Enrollment__c <> null)
                        nonNullInsertingAffiliations.add(eca);
                }
				//Commented the below try catch and implemented retry logic to fix issue reported by Perf Team for BUG217916
                /*try {
                    insert nonNullInsertingAffiliations;
                } catch (Exception e) {
                    //Try again if it failed.
                    logger.logException('Retrying a timed out insert', e);
                    logger.saveLogs();
                    insert nonNullInsertingAffiliations;
                }*/
                 integer i=0;
                do{
                    try{
                       i++;
                       insert nonNullInsertingAffiliations;                
                       break;//Breaking the loop as the DML executed and no exceptions
                }
                    catch(Exception e){
                        logger.logException('Retrying a timed out insert', e);
                        logger.saveLogs();                        
                    }
                }while(i<5);
               //End: BUG217916

                //Determine which version of the ECA process we are using.
                if (academicProgram.Use_Updated_ECA_Process__c == false)
                {
                   //Call an @future that will create the rest of the ECAs
                   List<Id> relationIds = new List<Id>();
                   for (Enrollment_Component_Relationship__c r :relationships)
                        relationIds.add(r.id);

                   NES_ECAEvaluation.createRemainingAffiliations(caretaker.Contact.AccountId, newStudent.Id, caretaker.ContactId, newStudentEnrollment.Id, caretakerEnrollmentId, relationIds, processComponent[0].Id);
                } else  {  //Must be using the new ECA process
                    //Call the future method that will create the remaining ECAs and the PE Criteria.

                    EvaluationUtils.PerformAsyncNewStudentSteps(newStudentEnrollment.Id, processComponent[0].Id, caretakerEnrollmentId,''); 

                }

                //With the ECA rewrite, we changed the hard stop process to only look at dates from the Academic program.
                Boolean shouldHardStop = false;

				//Replaced with MaxSpecialEdBirthdate__c instead of Too_Old_Cutoff__c in below if condition for 335863
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
               System.enqueueJob(new NES_AddStudentCaseQueueable(caretaker,newStudentEnrollment.Id,newStudent));


                peakResponse.success = true;
            } catch (Exception e) {
                peakResponse.success = false;
                peakResponse.messages.add(e.getMessage());
                System.debug('Exception thrown: ' + e.getMessage());
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
                logger.logException('insertingStudent', e);
                logger.saveLogs();
            }

        }
        return peakResponse;
    }

    //Grabs all the school years based on the given school
    public static Peak_Response grabSchoolYears(Id institutionId) {
        System.debug(institutionId);
        Peak_Response peakResponse = new Peak_Response();
        Id processId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Process').getRecordTypeId();
        Id programId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();

        // Grab the process enrollment components to find valid programs with processes
        List<Enrollment_Component__c> processes = [
                SELECT Id, Process_Academic_Program__c
                FROM Enrollment_Component__c
                WHERE RecordTypeId = :processId
        ];

        System.debug(processes);

        List<Id> programIds = new List<Id>();

        //loop through processes to grab all Academic Program Ids
        for (Enrollment_Component__c process : processes) {
            programIds.add(process.Process_Academic_Program__c);
        }

        System.debug(programIds);

        List<Account> programs = [
                SELECT Id, School_Year__c
                FROM Account
                WHERE RecordTypeId = :programId AND ParentId = :institutionId AND
                Registration_End_Date__c >= TODAY AND Registration_Start_Date__c <= TODAY
        ];

        System.debug(programs);

        List<Id> schoolYearIds = new List<Id>();

        // loop through academic programs to get school year Ids
        for (Account program : programs) {
            schoolYearIds.add(program.School_Year__c);
        }

        List<School_Year__c> years = [SELECT Id, Name FROM School_Year__c WHERE Id = :schoolYearIds];

        peakResponse.results = years;
        return peakResponse;

    }

    //Grabs all the student data for the logged in caretaker
    public static NES_EvaluateUtil.NewStudentData grabStudents() {

        Id institutionRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        Id processId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Process').getRecordTypeId();

        // USXXX (Ali Khan)
        User caretaker = [SELECT Contact.inputParameter__c,contact.account.Family_Enrollment_Counselor__c,Contact.Account.ShippingState, Contact.Account.ShippingPostalCode  FROM User WHERE Id = :UserInfo.getUserId()];

        // Grab the process enrollment components to find valid schools
        List<Enrollment_Component__c> processes = [
                SELECT Id, Process_Academic_Program__c
                FROM Enrollment_Component__c
                WHERE RecordTypeId = :processId AND Process_Academic_Program__c != NULL
                AND Process_Academic_Program__r.School_Year__c != NULL
                AND Process_Academic_Program__r.Registration_Start_Date__c <= TODAY
                AND Process_Academic_Program__r.Registration_End_Date__c >= TODAY
        ];
        List<Id> programIds = new List<Id>();

        //grab all Ids of Academic Programs
        for (Enrollment_Component__c process : processes) {
            programIds.add(process.Process_Academic_Program__c);
        }
        System.debug('programIds: ' + programIds);

        // USXXX (Ali Khan)
        // Mark Membrino.  Added that we only want to show institutions that match on zip if that institution has any zips set up.

        Map<Id, set<String>> institutionToZipListMap = new Map<Id, set<String>> ();
        Set<Id> institutionsInState = new Set<Id>();

        List<Account> institutionTempAccounts = [
                SELECT Id, Name, (SELECT Id, Name FROM ChildAccounts)
                FROM Account
                WHERE RecordTypeId = :institutionRecordTypeId
                AND ShippingState = :caretaker.Contact.Account.ShippingState
        ];

        for (Account institution : institutionTempAccounts) {
            institutionsInState.add(institution.id);
        }

        for (Program_PostalCode__c ppc :  [SELECT Academic_Program__c,PostalCode__c FROM Program_PostalCode__c where Academic_Program__c in :programIds]) {
            set<string> thisAPZips;
            if (!institutionToZipListMap.containsKey(ppc.Academic_Program__c)) 
                thisAPZips = new set<String>();
            else
                thisAPZips = institutionToZipListMap.get(ppc.Academic_Program__c);

            thisAPZips.add(ppc.PostalCode__c);
            institutionToZipListMap.put(ppc.Academic_Program__c, thisAPZips);
        }

        System.debug('insti: ' + caretaker.Contact.Account.ShippingState);
        System.debug('insti: ' + institutionTempAccounts);
        Set<Account> institutionSet = new Set<Account>();

        //loop through institutions to grab all the ones with valid academic programs
        for (Account institution : institutionTempAccounts) {
            //if they have an academic program, we want to return to the school list
            if (institution.ChildAccounts.size() > 0 ) {
                for (Account child : institution.ChildAccounts) {
                    //This if this institution even has zips assigned.
                    boolean meetsZipCriteria = true;
                    if (institutionToZipListMap.containsKey(child.Id)) { //If this institution has no zips, they won't be in the map at all.
                        set<string> thisAPZips = institutionToZipListMap.get(child.Id);
                        if (!thisAPZips.contains(caretaker.Contact.Account.ShippingPostalCode.substring(0,5)))
                            meetsZipCriteria = false;
                    }
                    if (programIds.contains(child.Id) && meetsZipCriteria) {
                        institutionSet.add(institution);
                        System.debug('institutions: ' + institutionSet);
                    }
                }
            }
        }
        List<Account> institutions = new List<Account>();
        institutions.addAll(institutionSet);


        // Create empty lists for return to user
        List<School_Year__c> schoolYears = new List<School_Year__c>();
        List<Grade_Level__c> gradeLevels = [SELECT Id, Name FROM Grade_Level__c];

        Account defaultAcc = new Account();
        List<hed__Program_Enrollment__c> programEnrollmentsList = relatedProgramEnrollments(UserInfo.getUserId());
        Id accountId;

        // if there are program enrollments for this caretaker
        if (programEnrollmentsList.size() > 0) {
            accountId = programEnrollmentsList[0].hed__Account__r.ParentId;
        }

        if (String.isNotBlank(accountId)) {
            defaultAcc = [SELECT Id, Name FROM Account WHERE Id = :programEnrollmentsList[0].hed__Account__r.ParentId LIMIT 1];
        } else if (String.isNotBlank(caretaker.Contact.inputParameter__c)) {
            Account schoolAccount = [SELECT Id, Name FROM Account WHERE Id = :caretaker.Contact.inputParameter__c];
            defaultAcc = schoolAccount;
        }

        NES_EvaluateUtil.NewStudentData data = new NES_EvaluateUtil.NewStudentData('', '', '','', '', '', '', '', defaultAcc, schoolYears, institutions, gradeLevels);//added additional spaces for US116612

        return data;
    }

    // Finds all the students related to this caretaker and returns their program enrollments
    public static List<hed__Program_Enrollment__c> relatedProgramEnrollments(Id userId) {
        Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        User careTaker = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        System.debug('caretaker: ' + careTaker.ContactId);
        List<Id> studentIds = new List<Id>();

        //Grab all the student relationships for this caretaker
        List<hed__Relationship__c> relationships = [
                SELECT hed__RelatedContact__r.Id
                FROM hed__Relationship__c
                WHERE hed__Contact__c = :careTaker.ContactId
                AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId
        ];

        for (hed__Relationship__c relationship : relationships) {
            system.debug('student: ' + relationship.hed__RelatedContact__r.Id);
            studentIds.add(relationship.hed__RelatedContact__r.Id);
        }

        //Grab all the program enrollments for these students
        List<hed__Program_Enrollment__c> enrollments = [
                SELECT CreatedById, CreatedDate, hed__Account__c, hed__Admission_Date__c,
                        hed__Affiliation__c, hed__Application_Submitted_Date__c, hed__Class_Standing__c, hed__Account__r.ParentId,
                        hed__Contact__c, hed__Credits_Attempted__c, hed__Credits_Earned__c,
                        hed__Eligible_to_Enroll__c, hed__End_Date__c, Status__c,
                        hed__GPA__c, hed__Graduation_Year__c, hed__Program_Plan__c, hed__Start_Date__c,
                        Id, IsDeleted, LastModifiedById, LastModifiedDate, LastReferencedDate,
                        LastViewedDate, Name, OwnerId, SystemModstamp, Viewed_Final_Confirmation__c
                FROM hed__Program_Enrollment__c
                WHERE hed__Contact__c = :studentIds
                ORDER BY CreatedDate ASC
        ];
        return enrollments;

    }

}