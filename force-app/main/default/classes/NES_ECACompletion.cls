/**
 * Created by triciaigoe on 1/12/19.
 * * Change Log: Added code by Anitha P for #108693 User Story (Task 109666) on 2019-09-20
 * * Change Log: 138707 : ALI KM : 02/24 : In grabIncompleteBoolean() method, changed logic to ignore all ECAs with is_required equals false.
 * * Change Log: 255842 : Jagadish Babu : 09/28/2020 : Added V2_External_Id field in queries line 112, 158 as the field refered in NES_ECAEValuation runAssignment Method
 */

public without sharing class NES_ECACompletion {
    private static Peak_ApexLog logger = new Peak_ApexLog('ECACompletion');

    // ALIKM: part of dataClass
    private static NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
    private static NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData;

    public static Boolean shouldRunCompletion = true;

    //Evaluate whether to run logic for Account change
    public static void accountCompletion(Map<Id, List<String>> changedFields) {

        if (shouldRunCompletion) {
            List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id, hed__Account__c, hed__Contact__c, hed__Contact__r.RecordType.Name, hed__Contact__r.AccountId , Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__r.AccountId IN :changedFields.keySet()];

            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            for (Id accountId : changedFields.keySet()) {

                for (hed__Program_Enrollment__c programEnrollment : programEnrollments) {

                    if (programEnrollment.hed__Contact__r.AccountId == accountId) {
                        List<String> fieldStrings = changedFields.get(accountId);
                        changedFieldsMap.put(programEnrollment.Id, fieldStrings);
                    }
                }
            }
            programEnrollmentCriteria(changedFieldsMap, 'Account', programEnrollments);
        }
    }

    //Evaluate whether to run logic for Contact change
    public static void contactCompletion(Map<Id, List<String>> changedFields) {

        if (shouldRunCompletion) {
            List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id, hed__Account__c, hed__Contact__c, hed__Contact__r.RecordType.Name, hed__Contact__r.AccountId, Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c IN :changedFields.keySet()];

            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            for (Id contactId : changedFields.keySet()) {

                for (hed__Program_Enrollment__c programEnrollment : programEnrollments) {

                    if (programEnrollment.hed__Contact__c == contactId) {
                        List<String> fieldStrings = changedFields.get(contactId);
                        changedFieldsMap.put(programEnrollment.Id, fieldStrings);
                    }
                }
            }
            programEnrollmentCriteria(changedFieldsMap, 'Contact', programEnrollments);
        }
    }

    //Evaluate whether to run logic for Contact change
	//This is the entry point when a record other that a PE was the changed record that may need reassignment
    public static void relatedCompletion(Map<Id, List<String>> changedFields, String objectName, Map<Id, List<Id>> peToObjectMap, List<EvaluationUtils.fieldUpdate> fieldUpdateList) {

        //MM 11/24/2020 Removing the check for should run completion as part of the ECA rewrite.  Added below to only care about this flag when it is the old ECA model
        //if (shouldRunCompletion) {
            List<hed__Program_Enrollment__c> programEnrollments = new List<hed__Program_Enrollment__c> ();
            Map<Id, hed__Program_Enrollment__c> newECAModelPEs = new Map<Id, hed__Program_Enrollment__c> ();
            Map<Id, hed__Program_Enrollment__c> oldECAModelPEs = new Map<Id, hed__Program_Enrollment__c> ();

            for (hed__Program_Enrollment__c pe : [SELECT Id, hed__Account__c, hed__Contact__c, hed__Contact__r.RecordType.Name, hed__Contact__r.AccountId, Household_Program_Enrollment__c,Household_Program_Enrollment__r.hed__Contact__c, hed__Account__r.Use_Updated_ECA_Process__c FROM hed__Program_Enrollment__c WHERE Id IN :peToObjectMap.keySet()] )
            {
                if (pe.hed__Account__r.Use_Updated_ECA_Process__c)
                    newECAModelPEs.put(pe.Id, pe);
                else
                    oldECAModelPEs.put(pe.Id, pe);
            }
                    
            //Decide if this is the new model for ECA processing or the old.  For PEs that use the new model direct to the new model for the
            //PEs that are still in the old model, send those to the existing completion Code.
            List<EvaluationUtils.fieldUpdate> fieldUpdateListNewModel = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            for (EvaluationUtils.fieldUpdate f : fieldUpdateList ) {
                if (newECAModelPEs.containsKey(f.programEnrollmentId))
                    fieldUpdateListNewModel.add(f);
            }

            // Got to make this a map of program enrollment to changed fields
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>>();
            for (Id programEnrollmentId : peToObjectMap.keySet()) {
                if (oldECAModelPEs.containsKey(programEnrollmentId)) {  //These changes are for PEs still in the old ECA processing model.
                    List<Id> relatedIds = peToObjectMap.get(programEnrollmentId);
                    List<String> fields = new List<String>();
                    for (Id relatedId : relatedIds) {
                        fields.addAll(changedFields.get(relatedId));
                    }
                    changedFieldsMap.put(programEnrollmentId, fields);
                    programEnrollments.add(oldECAModelPEs.get(programEnrollmentId));
                }
            }


            System.debug('changedFieldsMap.size()::'+changedFieldsMap.size());
            //If there are any PEs in the old model, hand them off.

            if (oldECAModelPEs.size() > 0 && NES_Constants.runAssignment && shouldRunCompletion) 
                programEnrollmentCriteria(changedFieldsMap, objectName, programEnrollments);
            
            if (fieldUpdateListNewModel.size() > 0)  //Must be at least one PE in the NEW ECA model that has a changed field so call the new ECA stuff.
                EvaluationUtils.evaluateChangedFields  (fieldUpdateListNewModel);

        //}
    }

    //Dispatch the program enrollment completion method
	//This is the entry point when a PE was the changed record that may need reassignment
    public static void programEnrollmentCompletion(Map<Id, List<String>> changedFieldsMap, String objectName) {
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id, hed__Account__c, hed__Contact__c, hed__Contact__r.RecordType.Name,
                            Household_Program_Enrollment__c, Household_Program_Enrollment__r.hed__Contact__c, V2_External_ID__c,hed__Contact__r.AccountId,Enrollment_Type__c,Attended_other_school_since_withdrawing__c,
                            hed__Account__r.Use_Updated_ECA_Process__c
						FROM hed__Program_Enrollment__c 
						WHERE Id IN :changedFieldsMap.keySet()];
                
        programEnrollmentCriteria(changedFieldsMap, objectName, programEnrollments);
    }

    //Evaluate whether we should run the criteria for a program enrollment
    public static void programEnrollmentCriteria(Map<Id, List<String>> changedFieldsMap, String objectName, List<hed__Program_Enrollment__c> programEnrollments) {

        // If completion could actually take place (not during initial eligibility)
        if (shouldRunCompletion) {

            shouldRunCompletion = false;
            List<hed__Program_Enrollment__c> caretakerEnrollments = new List<hed__Program_Enrollment__c>();
            List<hed__Program_Enrollment__c> studentEnrollments = new List<hed__Program_Enrollment__c>();
            map<Id,hed__Program_Enrollment__c> studentEnrollmentsMap = new map<Id,hed__Program_Enrollment__c>();
			Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap = new Map<Id,List<Enrollment_Component_Affiliation__c>> ();
			List<Id> allEnrollmentIds = new List<Id> ();
			Set<Id> acedemicProgramsReferenced = new Set<Id> ();

            // Find all the student and caretaker enrollments and split them
            for (hed__Program_Enrollment__c programEnrollment : programEnrollments) {

                if (programEnrollment.hed__Contact__r.RecordType.Name == 'Caretaker') {
                    caretakerEnrollments.add(programEnrollment);
                } else {
                    studentEnrollments.add(programEnrollment);
					studentEnrollmentsMap.put(programEnrollment.Id, programEnrollment);
                }
				allEnrollmentIds.add(programEnrollment.Id);
				acedemicProgramsReferenced.add(programEnrollment.hed__Account__c);
            }

            // if we have caretaker enrollments, we must analyze them
			map<Id,hed__Program_Enrollment__c> caretakerEnrollmentsMap = new map<Id,hed__Program_Enrollment__c>();
			List<hed__Program_Enrollment__c> relatedStudentEnrollments = new List<hed__Program_Enrollment__c>();
            if (caretakerEnrollments.size() > 0) {

                List<Id> caretakerEnrollmentIds = new List<Id>();
                for (hed__Program_Enrollment__c caretakerEnrollment : caretakerEnrollments) {
                    caretakerEnrollmentIds.add(caretakerEnrollment.Id);
                }
                relatedStudentEnrollments = [ 
						SELECT Id, hed__Account__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, 
								hed__Contact__r.AccountId,Enrollment_Type__c,V2_External_ID__c, Household_Program_Enrollment__c
                        FROM hed__Program_Enrollment__c
                        WHERE Household_Program_Enrollment__c IN :caretakerEnrollmentIds AND Status__c = 'In Progress'
                ];


				//add a reference to the appropriate fields for the eval to run
                for (hed__Program_Enrollment__c studentEnrollment : relatedStudentEnrollments) {
                    List<String> changedFields = changedFieldsMap.get(studentEnrollment.Household_Program_Enrollment__c);
                    changedFieldsMap.put(studentEnrollment.Id, changedFields);
					caretakerEnrollmentsMap.put(studentEnrollment.Id, studentEnrollment);
					allEnrollmentIds.add(studentEnrollment.Id);
					acedemicProgramsReferenced.add(studentEnrollment.hed__Account__c);
                }
            }

			for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
																		FROM Enrollment_Component_Affiliation__c
																		WHERE Program_Enrollment__c in :allEnrollmentIds]) {
				if (!progEnrollECAListMap.containsKey(affiliation.Program_Enrollment__c)){
					list <Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c> ();
					ecas.add(affiliation);
					progEnrollECAListMap.put(affiliation.Program_Enrollment__c, ecas);
				} else
					progEnrollECAListMap.get(affiliation.Program_Enrollment__c).add(affiliation);
			}

			//Build a map between Academic Programs and Process ids.
			map <Id, Id> academicProgramProcessIdMap = new Map<Id,Id>();
			for (Enrollment_Component__c e : [SELECT Id, Process_Academic_Program__c FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :acedemicProgramsReferenced])
			{
				academicProgramProcessIdMap.put(e.Process_Academic_Program__c, e.id);
			}

            // Only if there are related student program enrollments do we proceed
			if (caretakerEnrollmentsMap.size() > 0) {
                Map<Id, List<Id>> peImpactedComponentListAssignment = shouldRun(relatedStudentEnrollments, changedFieldsMap, 'Assignment', objectName, progEnrollECAListMap);
                fireAssignment(peImpactedComponentListAssignment, caretakerEnrollmentsMap, progEnrollECAListMap, academicProgramProcessIdMap);
                 
                Map<Id, List<Id>> peImpactedComponentListCompletion = shouldRun(relatedStudentEnrollments, changedFieldsMap, 'Completion', objectName, progEnrollECAListMap);
				fireCompletion(peImpactedComponentListCompletion, progEnrollECAListMap, caretakerEnrollmentsMap,academicProgramProcessIdMap);
            }

            if (studentEnrollments.size() > 0) {
                Map<Id, List<Id>> peImpactedComponentListAssignment = shouldRun(studentEnrollments, changedFieldsMap, 'Assignment', objectName, progEnrollECAListMap);
                fireAssignment(peImpactedComponentListAssignment, studentEnrollmentsMap, progEnrollECAListMap, academicProgramProcessIdMap);

                Map<Id, List<Id>> peImpactedComponentListCompletion = shouldRun(studentEnrollments, changedFieldsMap, 'Completion', objectName, progEnrollECAListMap);
				fireCompletion(peImpactedComponentListCompletion, progEnrollECAListMap, studentEnrollmentsMap,academicProgramProcessIdMap);
            }
        }
    }

    //fire off completion
    public static void fireCompletion(Map<Id, List<Id>> completionMap, Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap,  map<Id,hed__Program_Enrollment__c> EnrollmentsMap,map <Id, Id> academicProgramProcessIdMap) {
        List<Enrollment_Component_Affiliation__c> studentAffiliations = [
                SELECT Id, Enrollment_Component__c, Order__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.Assignment_Logic__c,
                        Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.Is_Required__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__c IN :completionMap.keySet()
        ];

        for (Id enrollmentId : completionMap.keySet()) {
			//If there were any impacted components, the size of the list will be > 0
			list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();
            if (completionMap.get(enrollmentId).size() > 0) {
				//singleAffiliationMap is a map between a Enrollment Component id and an ECA 
                Map<Id, Enrollment_Component_Affiliation__c> singleAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
                for (Enrollment_Component_Affiliation__c studentAffiliation : studentAffiliations) {
                    if (studentAffiliation.Program_Enrollment__c == enrollmentId) {
                        singleAffiliationMap.put(studentAffiliation.Enrollment_Component__c, studentAffiliation);
                        System.debug(studentAffiliation.Enrollment_Component__c + ' : ' + studentAffiliation.Status__c);
						thisStudentsECAs.add(studentAffiliation);
                    }
                }
				id processId = academicProgramProcessIdMap.get(EnrollmentsMap.get(enrollmentId).hed__Account__c);
                evaluateCompletion(enrollmentId, processId, null, singleAffiliationMap, thisStudentsECAs, EnrollmentsMap.get(enrollmentId) );
            }
        }
    }

    //fire off assignment
    public static void fireAssignment(Map<Id, List<Id>> completionMap, map<Id,hed__Program_Enrollment__c> EnrollmentsMap, Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap, map <Id, Id> academicProgramProcessIdMap) {

		/* Mark Membrino12/18/2019  Not used, not sure why it was ever calculated.
        List<Enrollment_Component_Affiliation__c> studentAffiliations = [
            SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.Assignment_Logic__c,
                    Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.Is_Required__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Program_Enrollment__c IN :completionMap.keySet()
        ]; */

        for (Id enrollmentId : completionMap.keySet()) {

            /* Mark Membrino12/18/2019  Not used, not sure why it was ever calculated.
			Map<Id, Enrollment_Component_Affiliation__c> singleAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
            for (Enrollment_Component_Affiliation__c studentAffiliation : studentAffiliations) {
                if (studentAffiliation.Program_Enrollment__c == enrollmentId) {
                    singleAffiliationMap.put(studentAffiliation.Enrollment_Component__c, studentAffiliation);
                }
            } */

            if (completionMap.get(enrollmentId).size() > 0) {
				hed__Program_Enrollment__c thisEnrollment = EnrollmentsMap.get(enrollmentId);
				id processId = academicProgramProcessIdMap.get(thisEnrollment.hed__Account__c);
                NES_ECAEvaluation.runAssignment(enrollmentId, completionMap.get(enrollmentId), thisEnrollment, progEnrollECAListMap.get(enrollmentId), processId );
            }
        }
    }

    //Grab map to figure out if we need to run completion
    public static Map<Id, List<Id>> shouldRun(List<hed__Program_Enrollment__c> relatedStudentEnrollments, Map<Id, List<String>> changedFieldsMap, String criteriaType, String objectName, Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap) {

        List<Id> studentEnrollmentIds = new List<Id>();
		List<Enrollment_Component_Affiliation__c> studentAffiliations = new  List<Enrollment_Component_Affiliation__c> ();

        for (hed__Program_Enrollment__c relatedStudentEnrollment : relatedStudentEnrollments) {
            studentEnrollmentIds.add(relatedStudentEnrollment.Id);

			if (progEnrollECAListMap.containsKey(relatedStudentEnrollment.Id))
			{
				List<Enrollment_Component_Affiliation__c> thisPEsListOfECAs = progEnrollECAListMap.get(relatedStudentEnrollment.Id);
				for (Enrollment_Component_Affiliation__c ECA : thisPEsListOfECAs) {
					if (ECA.Status__c != 'Complete')
						studentAffiliations.add(ECA);
				}
			}
        }

        // grab all the in progress student enrollment component affiliations
		/* Mark Membrino 12/20/2019 Removed the SOQL with the code above to reduce SOQL in for loops. 
        List<Enrollment_Component_Affiliation__c> studentAffiliations = [
                SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__c IN :studentEnrollmentIds AND Status__c != 'Complete'
        ]; */


        List<Id> enrollmentComponentIds = new List<Id>();
		//Program Enrollment to a list of components that are tied to that PE that are not complete
        Map<Id, List<Id>> peecMap = new Map<Id, List<Id>>();
        Set<Id> processId = new Set<Id>();

        // for every affiliation, add to the program enrollment enrollment component Ids map
        for (Enrollment_Component_Affiliation__c studentAffiliation : studentAffiliations) {

            if (studentAffiliation.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.PROCESS_RT) {
                processId.add(studentAffiliation.Enrollment_Component__c);
            }
            List<Id> componentIds = new List<Id>();
            enrollmentComponentIds.add(studentAffiliation.Enrollment_Component__c);
            if (peecMap.keySet().contains(studentAffiliation.Program_Enrollment__c)) {
                componentIds = peecMap.get(studentAffiliation.Program_Enrollment__c);
            }
            componentIds.add(studentAffiliation.Enrollment_Component__c);
            peecMap.put(studentAffiliation.Program_Enrollment__c, componentIds);
        }

        List<Id> newComponentIds = new List<Id>();
        if (criteriaType == 'Assignment') {

            // grab ALL the components of this process
            newComponentIds = grabProcessChildrenIds(processId); // @todo: Plug in the DataClass

            System.debug('newComponentIds: ' + newComponentIds);
            enrollmentComponentIds = newComponentIds;
        }

/*        List<Enrollment_Component__c> enrollmentComponents = [ // @todo: ALI : Plug in the DataClass
                SELECT Id, Completion_Logic__c, Assignment_Logic__c, (
                        SELECT Id, Criteria__c, Student_or_Household__c, Criteria_Number__c, Criteria__r.Criteria_Field__c,
                                Criteria__r.Comparison_Field__c
                        FROM Enrollment_Component_Criteria__r
                        WHERE Criteria_Type__c = :criteriaType
                ), (SELECT Id, Group_Number__c, Group_Logic__c FROM Criteria_Groups__r)
                FROM Enrollment_Component__c
                WHERE Id IN :enrollmentComponentIds
        ];  */

		//Go get all the Enrollment Components from the singleton class
		NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();

		List<Enrollment_Component__c> enrollmentComponents = new List<Enrollment_Component__c> (); 
		for (id EC : enrollmentComponentIds) {
			if ( allECData.enrollmentComponentMap.containsKey(EC) )
				enrollmentComponents.add(allECData.enrollmentComponentMap.get(EC));
		}


        // for each enrollment component, find all the criteria fields that may change completion/assignment
        Map<Id, List<String>> targetFieldMap = new Map<Id, List<String>>();
        system.debug ( enrollmentComponents);
        for (Enrollment_Component__c enrollmentComponent : enrollmentComponents) {
            String logicString;
            if (criteriaType == 'Assignment') {
                logicString = enrollmentComponent.Assignment_Logic__c;
            } else if (criteriaType == 'Completion') {
                logicString = enrollmentComponent.Completion_Logic__c;
            }
            // if there is no logic we are interested in, there may still be other logic
            if (String.isNotBlank(logicString)) {
                List<String> targetStrings = new List<String>();
                for (Enrollment_Component_Criteria__c enrollmentComponentCriterium : enrollmentComponent.Enrollment_Component_Criteria__r) {
                    System.debug('*************' + enrollmentComponentCriterium.Id + 'enrollmentComponentCriterium.Criteria__r+++' + enrollmentComponentCriterium.Criteria__r);
                    targetStrings.add(enrollmentComponentCriterium.Criteria__r.Criteria_Field__c.toLowerCase());
                    if (String.isNotBlank(enrollmentComponentCriterium.Criteria__r.Comparison_Field__c)) {
                        targetStrings.add(enrollmentComponentCriterium.Criteria__r.Comparison_Field__c.toLowerCase());
                    }
                }
                System.debug('targets: ' + targetStrings);
                System.debug('enrollmentComponent+++' + enrollmentComponent);
                if (targetStrings.size() > 0) {
                    targetFieldMap.put(enrollmentComponent.Id, targetStrings);
                }
            }
        }

		//For fun, let's build a list of the components that are impacted.
		//This data will go in a map that relates Prog Enrollment to a list of impacted components
        Map<Id, List<Id>> peImpactedComponentList = new Map<Id, List<Id>>();
        List<Id> componentIds = new List<Id>();
        
        // for each of the changed fields, evaluate whether there are target fields in that set
        Map<Id, Boolean> shouldRunCompletionMap = new Map<Id, Boolean>();
        for (hed__Program_Enrollment__c programEnrollment : relatedStudentEnrollments) {

            Boolean runCompletion = false;
			List<Id> impactedEnrollmentCompents = new List<Id> ();
            if (peecMap.keySet().contains(programEnrollment.Id)) {            
                if (criteriaType == 'Completion') {
                    componentIds = peecMap.get(programEnrollment.Id);
                } else {
                    componentIds = newComponentIds;
                }
                List<String> allTargetFields = new List<String>();
                System.debug(componentIds);
                for (Id componentId : componentIds) {

                    if (targetFieldMap.keySet().contains(componentId)) {

                        List<String> targetFields = targetFieldMap.get(componentId);
                        allTargetFields.addAll(targetFields);

                    }
                }
                System.debug(programEnrollment.Id);
                System.debug(changedFieldsMap);
                List<String> changedFields = changedFieldsMap.get(programEnrollment.Id);
                System.debug('changedFields.size()::'+changedFields.size());
                for (String changedField : changedFields) {

                    changedField = objectName.toLowerCase() + '.' + changedField.toLowerCase();

                    if (allTargetFields.contains(changedField)) {
                        runCompletion = true;
						//This changed field impacts at least one changed one criteria so lets find 
						//all the impacted Enrollment Components.
						for (Id componentId : componentIds) {
							if (targetFieldMap.keySet().contains(componentId)) {
		                        List<String> targetFields = targetFieldMap.get(componentId);
								if (targetFields.contains(changedField)) {
									impactedEnrollmentCompents.add(componentId);
								}
							}
						}
                    }
                }
            }
            shouldRunCompletionMap.put(programEnrollment.Id, runCompletion);
			if(criteriaType == 'Completion'){
				peImpactedComponentList.put(programEnrollment.Id, componentIds);
				}
			else{
				peImpactedComponentList.put(programEnrollment.Id, impactedEnrollmentCompents);
			}
        }
        System.debug(shouldRunCompletionMap);
		System.debug('peImpactedComponentList***'+peImpactedComponentList);

        return peImpactedComponentList;
    }

    //Grab process Id  
    public static Id grabProcessId(hed__Program_Enrollment__c studentEnrollment) {
        List<Enrollment_Component__c> processComponent = new List<Enrollment_Component__c> ( [SELECT Id FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :studentEnrollment.hed__Account__c LIMIT 1]);
        Id processId;
		if (processComponent.size() > 0)
			return processComponent[0].Id;
        return processId;
    }

    //evaluate completion at any time
    public static void evaluateCompletion(Id studentEnrollmentId, Id processId, Id sectionId, Map<Id, Enrollment_Component_Affiliation__c> studentAffiliationsMap, List<Enrollment_Component_Affiliation__c> thisStudentsECAs, hed__Program_Enrollment__c studentEnrollment) {

        // Grab records we need for criteria evaluation
        System.debug(studentEnrollmentId);
        Boolean origRunAssignment = NES_Constants.runAssignment;
        Boolean origRunCompletion = NES_ECACompletion.shouldRunCompletion;

        // ALIKM hed__Program_Enrollment__c studentEnrollment = stageRelationships

		/* Mark Membrino 12/23/2019  Passing this now to avoid a SOQL in a for loop.
        hed__Program_Enrollment__c studentEnrollment = [
                SELECT Id, hed__Contact__c, hed__Account__c, Household_Program_Enrollment__c, Household_Program_Enrollment__r.hed__Contact__c
                FROM hed__Program_Enrollment__c
                WHERE Id = :studentEnrollmentId
        ];  */

        if (String.isBlank(processId)) {
            processId = grabProcessId(studentEnrollment);
        }

        system.debug('processId'+processId);
        // Instantiate new variables for method
		//Mark Membrino 12/18/2019  Found this relationships variable is populated but never used.  Removing.
        //List<hed__Relationship__c> relationships = new List<hed__Relationship__c>();
        //MM 12/26/2019  Removing this need to get the student.
		//Contact student = new Contact();
        Map<Id, String> completionLogicMap = new Map<Id, String>();
        List<Id> allIds = new List<Id>();
        List<Enrollment_Component_Affiliation__c> affiliations = new List<Enrollment_Component_Affiliation__c>();
        
        //Ali KM 12/16/2019 This calculations was moved to the NES_EnrollmentCompentBuilder
        // public static NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        thisProcessData = allECData.getSpecificProcessECData(processId);
        List<Enrollment_Component_Relationship__c> processRelationships = thisProcessData.stageRelationships;

        // Grab all enrollment component relationships for this process
        // List<Enrollment_Component_Relationship__c> processRelationships = [
        //         SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name,
        //                 Parent_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Completion_Logic__c
        //         FROM Enrollment_Component_Relationship__c
        //         WHERE Parent_Enrollment_Component__c = :processId
        //         AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT ORDER BY Order__c
        // ];

        system.debug (processRelationships.size());     
        system.debug(processRelationships);
       
        List<Id> stageIds = new List<Id>();
        if (processRelationships.size() != 0 && String.isNotBlank(processRelationships[0].Parent_Enrollment_Component__r.Completion_Logic__c)) {
            completionLogicMap.put(processId, processRelationships[0].Parent_Enrollment_Component__r.Completion_Logic__c);
        }

        for (Enrollment_Component_Relationship__c processRelationship : processRelationships) {
            stageIds.add(processRelationship.Child_Enrollment_Component__c);
            if (String.isNotBlank(processRelationship.Child_Enrollment_Component__r.Completion_Logic__c)) {
                completionLogicMap.put(processRelationship.Child_Enrollment_Component__c, processRelationship.Child_Enrollment_Component__r.Completion_Logic__c);
            }
        }

        List<Enrollment_Component_Relationship__c> stageRelationships = thisProcessData.formRelationships;

        // List<Enrollment_Component_Relationship__c> stageRelationships = [
        //         SELECT Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.RecordType.Name,
        //                 Child_Enrollment_Component__r.Component_Type__c, Child_Enrollment_Component__r.Completion_Logic__c,
        //                 Parent_Enrollment_Component__c
        //         FROM Enrollment_Component_Relationship__c
        //         WHERE Parent_Enrollment_Component__c IN :stageIds
        //         AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
        //         OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FLAG_RT
        //         OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT)
        // ];
        Set<Id> formFlagIds = new Set<Id>();

        for (Enrollment_Component_Relationship__c stageRelationship : stageRelationships) {
            formFlagIds.add(stageRelationship.Child_Enrollment_Component__c);
            completionLogicMap.put(stageRelationship.Child_Enrollment_Component__c, stageRelationship.Child_Enrollment_Component__r.Completion_Logic__c);
        }
               
        allIds.add(processId);
        allIds.addAll(stageIds);
        allIds.addAll(formFlagIds);

        // Mark Membrino 12/26/2019  Removing this query and replacing it with the for loop below that iterates over the data class
		//   we built and only grabs the Enrollment Components that it previously collected.
        /*List<Enrollment_Component__c> enrollmentComponents = [
                SELECT Id, Completion_Logic__c, (
                        SELECT Id, Criteria__c, Student_or_Household__c, Criteria_Number__c, Criteria__r.Criteria_Field__c,
                                Criteria__r.Comparison_Field__c
                        FROM Enrollment_Component_Criteria__r
                ), (SELECT Id, Group_Number__c, Group_Logic__c FROM Criteria_Groups__r)
                FROM Enrollment_Component__c
                WHERE Id IN :allIds
        ]; */

		List<Enrollment_Component__c> enrollmentComponents = new List<Enrollment_Component__c> ();
		Set<Id> allIdsSet = new Set<Id>(allIds);
		for ( Enrollment_Component__c ecc: allECData.enrollmentComponentMap.values() ) {
			if ( allIdsSet.contains(ecc.id) )
				enrollmentComponents.add(ecc);
		}

        // Create a map of enrollment component Id to enrollment component for easy access of the data
        Map<Id, Enrollment_Component__c> enrollmentComponentMap = new Map<Id, Enrollment_Component__c>();

        for (Enrollment_Component__c enrollmentComponent : enrollmentComponents) {
            enrollmentComponentMap.put(enrollmentComponent.Id, enrollmentComponent);
        }

        List<Id> completedComponents = new List<Id>();
        system.debug(completionLogicMap.size());
        system.debug(enrollmentComponentMap.size());
        system.debug(enrollmentComponentMap);
        // if there are any completion logic to evaluate, evaluate it
        if (completionLogicMap.size() > 0) {
			//Mark Membrino 12/26/2019  Removing this SOQL passing the data instead.
            //student = [SELECT AccountId, Id FROM Contact WHERE Id = :studentEnrollment.hed__Contact__c];

			//MM  Never used, removing.
            //relationships = [SELECT hed__Contact__c, hed__RelatedContact__c FROM hed__Relationship__c WHERE hed__Contact__c = :studentEnrollment.hed__Contact__c];

			//Pass an empty list of impacted enrollments. This will force get more to look at all components.
			List<Id> impactedEnrollmentComponents = new List<Id> ();

            // Evaluating criteria, find all components whose completion criteria evaluates to true
            completedComponents = NES_ECAEvaluation.getMoreComponents(studentEnrollment.Id, studentEnrollment.Household_Program_Enrollment__c,
                    studentEnrollment.hed__Contact__c, studentEnrollment.Household_Program_Enrollment__r.hed__Contact__c, studentEnrollment.hed__Contact__r.AccountId, 'Completion', 
					enrollmentComponentMap, true, impactedEnrollmentComponents, thisStudentsECAs);
            System.debug(completedComponents.size()); 
        }

        // Mark Membrino 12/26/2019  Replacing the soql below with this in-memory process to remove a soql.
		List<Enrollment_Component_Relationship__c> formRelationships = new List<Enrollment_Component_Relationship__c> ();

		for (Enrollment_Component_Relationship__c r : thisProcessData.sectionRelationships) {
			if (r.Child_Enrollment_Component__r.RecordType.Name  == NES_DashboardUtilities.SECTION_RT ||
			          r.Child_Enrollment_Component__r.RecordType.Name  == NES_DashboardUtilities.DOCUMENT_RT)
				formRelationships.add(r);

		}

       /* List<Enrollment_Component_Relationship__c> formRelationships = [
                SELECT Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.RecordType.Name,
                        Child_Enrollment_Component__r.Component_Type__c, Child_Enrollment_Component__r.Completion_Logic__c,
                        Parent_Enrollment_Component__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c IN :formFlagIds
                AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT
                OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT)
        ]; */

        System.debug(sectionId);

        if (String.isNotBlank(sectionId)) {

            // evaluate completion within the frame of a specific section being completed
            evaluateCompletionSection(studentEnrollmentId, processId, sectionId, studentAffiliationsMap, formRelationships, completedComponents, stageRelationships, processRelationships);

        } else {

            System.debug('made it: ' + completedComponents);
            Map<Id, Enrollment_Component_Affiliation__c> affiliationsForUpdate = new Map<Id, Enrollment_Component_Affiliation__c>();
            List<Id> childSectionIds = new List<Id>();
            Boolean incompleteSection;

            for(Id completedId : completedComponents) {

                Enrollment_Component_Affiliation__c completedAffiliation = studentAffiliationsMap.get(completedId);
                if(completedAffiliation != null && completedAffiliation.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.FLAG_RT || completedAffiliation.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.MESSAGE_RT) {
                    if (completedAffiliation.Enrollment_Component__c == 'a0f0n0000003dhHAAQ')
                        System.debug(':: Ali KM :: Found Marking Status to Complete at: completedAffiliation:: ln 591 :: ' + JSON.serialize(	completedAffiliation ));
                    completedAffiliation.Status__c = 'Complete';
                    completedAffiliation.Date_Completed__c = System.now();
                    
                    affiliationsForUpdate.put(completedAffiliation.Id, completedAffiliation);
                    studentAffiliationsMap.put(completedAffiliation.Enrollment_Component__c, completedAffiliation);
                    System.debug(completedAffiliation);
                }

            }

            for (Enrollment_Component_Relationship__c formRelationship : formRelationships) {
                childSectionIds = grabSiblingIds(formRelationship.Parent_Enrollment_Component__c, formRelationships, sectionId);

                if (childSectionIds.size() == 0) {
                    incompleteSection = false;
                } else {
                    incompleteSection = grabIncompleteBoolean(childSectionIds, studentAffiliationsMap);
                }

                if (!incompleteSection) {

                    if (studentAffiliationsMap.keySet().contains(formRelationship.Parent_Enrollment_Component__c)) {
                        Enrollment_Component_Affiliation__c formAffiliation = studentAffiliationsMap.get(formRelationship.Parent_Enrollment_Component__c);
                        System.debug(formAffiliation.Id);
                        // if this form has no completion or the completion is true, complete it and move on; else, do nothing else 
                        if (formAffiliation.Status__c != 'Complete'  && (String.isBlank(formAffiliation.Enrollment_Component__r.Completion_Logic__c) || completedComponents.contains(formAffiliation.Enrollment_Component__c) || (completedComponents.indexOf(formAffiliation.Enrollment_Component__c) > -1))) {
                            if (formAffiliation.Enrollment_Component__c == 'a0f0n0000003dhHAAQ')
                                System.debug(':: Ali KM :: Found Marking Status to Complete at: formAffiliations :: ' + JSON.serialize(	formAffiliation ));
                            formAffiliation.Status__c = 'Complete';
                            formAffiliation.Date_Completed__c = System.today();
                         
                            affiliationsForUpdate.put(formAffiliation.Id, formAffiliation);
                            studentAffiliationsMap.put(formAffiliation.Enrollment_Component__c, formAffiliation);

                        }
                    }
                }

            }
             
            for (Enrollment_Component_Relationship__c stageRelationship : stageRelationships) {

                List<Id> childFormIds = grabSiblingIds(stageRelationship.Parent_Enrollment_Component__c, stageRelationships, null);
                System.debug(childFormIds);
                Boolean incompleteForm;
                 system.debug('childFormIds'+childFormIds);
                
                if (childFormIds.size() == 0) {
                    incompleteForm = false;
                } else {
                     system.debug('studentAffiliationsMap'+studentAffiliationsMap);
                    incompleteForm = grabIncompleteBoolean(childFormIds, studentAffiliationsMap);
                }
                  
                // if all required forms are complete
                if (!incompleteForm) {
                   
                      // if this stage is actually an affiliation
                    if (studentAffiliationsMap.keySet().contains(stageRelationship.Parent_Enrollment_Component__c)) {

                        Enrollment_Component_Affiliation__c stageAffiliation = studentAffiliationsMap.get(stageRelationship.Parent_Enrollment_Component__c);
                        // if there is no logic here or it has already evaluated to true, continue
                        if ((String.isBlank(stageAffiliation.Enrollment_Component__r.Completion_Logic__c)) || (completedComponents.contains(stageAffiliation.Enrollment_Component__c)) || (completedComponents.indexOf(stageAffiliation.Enrollment_Component__c) > -1)) {
                            // added 'Not Started' condition by anitha for #108693 User Story (Task 109666) 
                            if (stageAffiliation.Status__c != 'Complete' && stageAffiliation.Status__c != 'Not Started') {
                                if (stageAffiliation.Enrollment_Component__c == 'a0f0n0000003dhHAAQ')
                                    System.debug(':: Ali KM :: Found Marking Status to Complete at: stageAffiliation:: ln 591 :: '+ JSOn.serialize(stageAffiliation));
                                stageAffiliation.Status__c = 'Complete';
                                stageAffiliation.Date_Completed__c = System.today();
                                affiliationsForUpdate.put(stageAffiliation.Id, stageAffiliation);
                                studentAffiliationsMap.put(stageAffiliation.Enrollment_Component__c, stageAffiliation);
                                String newOrder = String.valueOf(stageAffiliation.Order__c + 1);
                            
                                for (Enrollment_Component_Relationship__c stageRelationship2 : stageRelationships) {

                                    if (studentAffiliationsMap.keySet().contains(stageRelationship2.Parent_Enrollment_Component__c)) {
                                        Enrollment_Component_Affiliation__c nextAffiliation = studentAffiliationsMap.get(stageRelationship2.Parent_Enrollment_Component__c);
                                        if (String.valueOf(nextAffiliation.Order__c) == newOrder) {
                                            nextAffiliation.Status__c = 'In Progress';
                                            affiliationsForUpdate.put(nextAffiliation.Id, nextAffiliation);
                                            studentAffiliationsMap.put(nextAffiliation.Enrollment_Component__c, nextAffiliation);
                                            break;
                                        }

                                    }

                                }
                            }

                        }
                    }

                }
            }

            List<Id> childStageIds = grabSiblingIds(processId, processRelationships, null);
            Boolean incompleteStage;
            if (childStageIds.size() == 0) {
                incompleteStage = false;
            } else {
                incompleteStage = grabIncompleteBoolean(childStageIds, studentAffiliationsMap);
            }

            NES_Constants.runAssignment = false;
            NES_ECACompletion.shouldRunCompletion = false;
            if (!incompleteStage && studentAffiliationsMap.get(processId) != null) {
                Enrollment_Component_Affiliation__c processAffiliation = studentAffiliationsMap.get(processId);
                processAffiliation.Status__c = 'Complete';
                processAffiliation.Date_Completed__c = System.today();
                affiliationsForUpdate.put(processAffiliation.Id, processAffiliation);
                studentEnrollment.Status__c = 'Complete';
                system.debug(processAffiliation);
                 system.debug(studentEnrollment);
                try {
                    update processAffiliation;
                    update studentEnrollment;
                } catch(Exception e) {
                    logger.logException('evaluateCompletion', e);
                    logger.saveLogs();
                    throw e;
                }

                Opportunity studentOpportunity;
                for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Program_Enrollment__c = :studentEnrollment.Id AND StageName = 'Open' LIMIT 1]) {
                    studentOpportunity = opp;
                }
                
                if (studentOpportunity != null) {
                     system.debug('im in this if part');
                    studentOpportunity.StageName = 'Closed Won';
                    try {
                        update studentOpportunity;
                    } catch(Exception e) {
                        logger.logException('evaluateCompletion', e);
                        logger.saveLogs();
                        throw e;
                    }
                }
            } else {
                      system.debug('im in this else part');
                for (Integer i = 1; i < processRelationships.size(); i++) {

                    if (studentAffiliationsMap.keySet().contains(processRelationships[i].Child_Enrollment_Component__c)) {
                        Enrollment_Component_Affiliation__c stageAffiliation = studentAffiliationsMap.get(processRelationships[i].Child_Enrollment_Component__c);

                        if(stageAffiliation.Status__c == 'Complete') {
                            continue;
                        } else {
                            stageAffiliation.Status__c = 'In Progress';
                            affiliationsForUpdate.put(stageAffiliation.Id, stageAffiliation);
                            studentAffiliationsMap.put(stageAffiliation.Enrollment_Component__c, stageAffiliation);
                            break;
                        }
                    }
                }
            }

            List<Enrollment_Component_Affiliation__c> componentAffiliations = new List<Enrollment_Component_Affiliation__c>();
            componentAffiliations.addAll(affiliationsForUpdate.values());
            System.debug('size: ' + componentAffiliations.size());
             System.debug('size: ' + componentAffiliations);
            try {
                update componentAffiliations;
            } catch(Exception e) {
                logger.logException('evaluateCompletion', e);
                logger.saveLogs();
                throw e;
            }
            NES_Constants.runAssignment = origRunAssignment;
            NES_ECACompletion.shouldRunCompletion = origRunCompletion;
        }
    }

    //Evaluate the completion logic for a process, when on a specific section
    public static void evaluateCompletionSection(Id programEnrollmentId, Id processId, Id sectionId, Map<Id, Enrollment_Component_Affiliation__c> studentAffiliationsMap, List<Enrollment_Component_Relationship__c> formRelationships,
            List<Id> completedComponents, List<Enrollment_Component_Relationship__c> stageRelationships, List<Enrollment_Component_Relationship__c> processRelationships) {

        Boolean origRunAssignment = NES_Constants.runAssignment;
        Boolean origRunCompletion = NES_ECACompletion.shouldRunCompletion;
        NES_Constants.runAssignment = false;
        NES_ECACompletion.shouldRunCompletion = false;
        List<Enrollment_Component_Affiliation__c> affiliations = new List<Enrollment_Component_Affiliation__c>();
        // Find the parent form to the section we have just completed, the siblings to this section and find if any are not complete
         System.debug(formRelationships);
        Id parentFormId = grabParentId(sectionId, formRelationships);
        List<Id> childSectionIds = grabSiblingIds(parentFormId, formRelationships, sectionId);
        System.debug(childSectionIds);
        Boolean incompleteSection;
        if (childSectionIds.size() == 0) {
            incompleteSection = false;
        } else {
            incompleteSection = grabIncompleteBoolean(childSectionIds, studentAffiliationsMap);
        }

        if (!incompleteSection) {
            Enrollment_Component_Affiliation__c formAffiliation = studentAffiliationsMap.get(parentFormId);
            system.debug('formAffiliation******'+formAffiliation);
            // if this form has no completion or the completion is true, complete it and move on; else, do nothing else
            if(formAffiliation != null)
            if (String.isBlank(formAffiliation.Enrollment_Component__r.Completion_Logic__c) || completedComponents.contains(parentFormId)) {

                if (formAffiliation.Enrollment_Component__c == 'a0f0n0000003dhHAAQ')
                    System.debug(':: Ali KM :: Found Marking Status to Complete at: formAffiliation:: ln 794: ' + JSON.serialize(	formAffiliation ));
                formAffiliation.Status__c = 'Complete';
                affiliations.add(formAffiliation);

                Id parentStageId = grabParentId(parentFormId, stageRelationships);
                List<Id> childFormIds = grabSiblingIds(parentStageId, stageRelationships, parentFormId);
                Boolean incompleteForm;
                if (childFormIds.size() == 0) {
                    incompleteForm = false;
                } else {
                    incompleteForm = grabIncompleteBoolean(childFormIds, studentAffiliationsMap);
                }

                if (!incompleteForm) {

                    Enrollment_Component_Affiliation__c stageAffiliation = studentAffiliationsMap.get(parentStageId);

                    if (String.isBlank(stageAffiliation.Enrollment_Component__r.Completion_Logic__c) || completedComponents.contains(parentStageId)) {
                        if (stageAffiliation.Enrollment_Component__c == 'a0f0n0000003dhHAAQ')
                            System.debug(':: Ali KM :: Found Marking Status to Complete at: stageAffiliation:: ln 813: ' + JSON.serialize(	stageAffiliation ));
                        stageAffiliation.Status__c = 'Complete';
                        affiliations.add(stageAffiliation);

                        List<Id> childStageIds = grabSiblingIds(processId, processRelationships, parentStageId);
                        Boolean incompleteStage;
                        if (childStageIds.size() == 0) {
                            incompleteStage = false;
                        } else {
                            incompleteStage = grabIncompleteBoolean(childStageIds, studentAffiliationsMap);
                        }

                        if (!incompleteStage) {
                            Enrollment_Component_Affiliation__c processAffiliation = studentAffiliationsMap.get(processId);
                            processAffiliation.Status__c = 'Complete';
                            affiliations.add(processAffiliation);
                            hed__Program_Enrollment__c studentEnrollment = [SELECT Id FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
                            studentEnrollment.Status__c = 'Complete';
                            update studentEnrollment;
                            List<Opportunity> opps = [SELECT Id FROM Opportunity WHERE Program_Enrollment__c = :studentEnrollment.Id AND StageName = 'Open' LIMIT 1];
                            for(Opportunity opp : opps) {
                                opp.StageName = 'Closed Won';
                                update opp;
                            }
                        } else {
                            Boolean updatedStatus = false;
                            for (Integer i=0; i<processRelationships.size();i++) {
                                System.debug(processRelationships[i]);
                                if (studentAffiliationsMap.keySet().contains(processRelationships[i].Child_Enrollment_Component__c) && updatedStatus == false) {
                                    Enrollment_Component_Affiliation__c nextStageAffiliation = studentAffiliationsMap.get(processRelationships[i].Child_Enrollment_Component__c);
                                    System.debug(nextStageAffiliation);
                                    if (nextStageAffiliation.Status__c != 'Complete') {
                                        nextStageAffiliation.Status__c = 'In Progress';
                                        affiliations.add(nextStageAffiliation);
                                        updatedStatus = true;
                                    }

                                }
                            }

                        }
                    }

                }


            }
        } else {
            Enrollment_Component_Affiliation__c formAffiliation = studentAffiliationsMap.get(parentFormId);            
            formAffiliation.Status__c = 'In Progress';
            affiliations.add(formAffiliation);
        }
        try {
            System.debug(affiliations);
            update affiliations;
        } catch(Exception e) {
            logger.logException('evaluateCompletionSection', e);
            logger.saveLogs();
            throw e;
        }
        NES_Constants.runAssignment = origRunAssignment;
        NES_ECACompletion.shouldRunCompletion = origRunCompletion;

    }
    // Get parent enrollment component
    public static Id grabParentId(Id childId, List<Enrollment_Component_Relationship__c> relationships) {

        // Find the parent form to the section we have just completed
        Id parentComponentId;
        for (Enrollment_Component_Relationship__c relationship : relationships) {
            if (relationship.Child_Enrollment_Component__c == childId) {
                parentComponentId = relationship.Parent_Enrollment_Component__c;
            }
        }
        return parentComponentId;
    }

    //Grab all siblings of a parent enrollment component to a certain child
    public static List<Id> grabSiblingIds(Id parentId, List<Enrollment_Component_Relationship__c> relationships, Id currentChildId) {

        List<Id> childIds = new List<Id>();
        for (Enrollment_Component_Relationship__c relationship : relationships) {
            if (relationship.Parent_Enrollment_Component__c == parentId && relationship.Child_Enrollment_Component__c != currentChildId && relationship.Child_Enrollment_Component__r.RecordType.Name != NES_DashboardUtilities.MESSAGE_RT) {
                childIds.add(relationship.Child_Enrollment_Component__c);
            }
        }
        return childIds;
    }

    //Find incomplete components
    // ALI KM : 1/20/2020 : [US 122106] Updated affiliation.Status check to handle 'Not Applicable' ECA records
    public static Boolean grabIncompleteBoolean(List<Id> childIds, Map<Id, Enrollment_Component_Affiliation__c> studentAffiliationMap) {
        Boolean incomplete = false;
        for (Id childId : childIds) {
            if (studentAffiliationMap.containsKey(childId) && studentAffiliationMap.get(childId) <> null && studentAffiliationMap.get(childId).Status__c <> null) {
                Enrollment_Component_Affiliation__c affiliation = new Enrollment_Component_Affiliation__c();
				affiliation = studentAffiliationMap.get(childId);
                if ( !(affiliation.Status__c.contains('Complete') || affiliation.Status__c.contains('Deferred') 
                        || affiliation.Status__c.contains('Not Applicable'))) {
                            System.debug(':: inside grabIncompleteBoolean > ECA=::' + JSON.serialize(affiliation)); // ALI KM
                            // [138707 : ALI KM : 02/24 : making changes to ignore all ECAs that are not required.]
                            // if (affiliation.Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.DOCUMENT_RT && affiliation.Enrollment_Component__r.Is_Required__c == false) {
                            if (affiliation.Enrollment_Component__r.Is_Required__c == false) {    
                            // [138707 : ALI KM : 02/24 : END]
                                incomplete = false;
                            } else {
                                incomplete = true;
                                break;
                            }
                }
            }
        }
        return incomplete;
    }

    //Grab all EC ids for a process
    public static List<Id> grabProcessChildrenIds(Set<Id> processId) {

        //Ali KM 12/16/2019 This calculations was moved to the NES_EnrollmentCompentBuilder
        // NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
		
		Set<Id> allIdsSet = new Set<Id>();
		for (id i: processId) {
			NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(i);
			allIdsSet.addall(thisProcessData.allIds);
		}
		list<Id> allids =  new List<Id> (allIdsSet);
        return allids;
        
        // List<Id> stageIds = new List<Id>();
        // List<Id> allIds = new List<Id>();
        // List<Enrollment_Component_Relationship__c> processChildren = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c = :processId];
        // for (Enrollment_Component_Relationship__c processChild : processChildren) {
        //     allIds.add(processChild.Child_Enrollment_Component__c);
        //     stageIds.add(processChild.Child_Enrollment_Component__c);
        // }
        // List<Id> flagFormIds = new List<Id>();
        // List<Enrollment_Component_Relationship__c> stageChildren = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :stageIds];
        // for (Enrollment_Component_Relationship__c stageChild : stageChildren) {
        //     allIds.add(stageChild.Child_Enrollment_Component__c);
        //     flagFormIds.add(stageChild.Child_Enrollment_Component__c);
        // }
        // List<Id> sectionDocIds = new List<Id>();
        // List<Enrollment_Component_Relationship__c> formChildren = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :flagFormIds];
        // for (Enrollment_Component_Relationship__c formChild : formChildren) {
        //     allIds.add(formChild.Child_Enrollment_Component__c);
        //     sectionDocIds.add(formChild.Child_Enrollment_Component__c);
        // }
        // List<Id> groupIds = new List<Id>();
        // List<Enrollment_Component_Relationship__c> groupRelationships = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :sectionDocIds AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTIONGROUP_RT];
        // for (Enrollment_Component_Relationship__c groupRelationship : groupRelationships) {
        //     groupIds.add(groupRelationship.Child_Enrollment_Component__c);
        //     allIds.add(groupRelationship.Child_Enrollment_Component__c);
        // }
        // List<Id> questionParentIds = new List<Id>();
        // questionParentIds.addAll(groupIds);
        // questionParentIds.addAll(sectionDocIds);
        // List<Enrollment_Component_Relationship__c> questionRelationships = [SELECT Child_Enrollment_Component__c FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :questionParentIds AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT];
        // for (Enrollment_Component_Relationship__c questionRelationship : questionRelationships) {
        //     allIds.add(questionRelationship.Child_Enrollment_Component__c);
        // }

        // return allIds;

        //Ali KM --- END ---    

    }
}