/**
 * Created by triciaigoe on 1/16/19.
 *  Revision History
 *  Added V2_External_ID__c in query line 66 as the runAssignment method needs V2_External_ID__c field in logic DEF255843(Jagadish Babu)
 */

global with sharing class NES_Batch_TimeCriteria implements DataBase.Batchable<SObject>, Schedulable {

    global NES_Batch_TimeCriteria() {

    }

    // Find all the current in progress program enrollments for evaluation
    // MM 9/23/2020  Added an additional check to the query to only retrieve PEs that have had all their ECAs created. (using Initial_ECA_Creation_Complete__c)
    global List<SObject> start(Database.BatchableContext BC){
        List<hed__Program_Enrollment__c> programEnrollments = [SELECT Id, hed__Account__r.Use_Updated_ECA_Process__c FROM hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND RecordType.Name = 'Student'  and Initial_ECA_Creation_Complete__c = true ];
        return programEnrollments;

        // List<hed__Program_Enrollment__c> programEnrollments = [
        //     SELECT Id, hed__Account__r.Use_Updated_ECA_Process__c 
        //     FROM    hed__Program_Enrollment__c 
        //     WHERE   Status__c = 'In Progress' AND 
        //             RecordType.Name = 'Student'  and Initial_ECA_Creation_Complete__c = true AND
        //             hed__Account__r.Use_Updated_ECA_Process__c = true
        // ];
        // return programEnrollments;
    }


    // Evaluate whether to run completion and then run it
    global void execute(Database.BatchableContext BC, List<SObject> scope) {

        Set<Id> programEnrollmentIds = new Set<Id>();  //Old ECA model PEs
        Set<Id> programEnrollmentIdsNewECAModel = new Set<Id>();  //New ECA model PEs
        for(SObject programEnrollment : scope) {
            if ( ((hed__Program_Enrollment__c) programEnrollment).hed__Account__r.Use_Updated_ECA_Process__c == true)
                programEnrollmentIdsNewECAModel.add(programEnrollment.Id);
            else 
                programEnrollmentIds.add(programEnrollment.Id);
        }
        
        if (programEnrollmentIdsNewECAModel.size() > 0) {
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> ();

            for (id peID: programEnrollmentIdsNewECAModel ) {
                //Add a record for to force the calculation of fields that are based on today's date.
                EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
                newFieldUpdate.programEnrollmentId = peID;
                newFieldUpdate.objectAndFieldName = 'hed__program_enrollment__c.date_today__c';
                newFieldUpdate.newValue = System.today();
                fieldUpdateList.add(newFieldUpdate);
            }

            EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        }

        if (programEnrollmentIds.size() > 0) {   //Must be some PEs in the batch using the old ECA model.

            //Collect the data you need.
            Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAListMap = new Map<Id,List<Enrollment_Component_Affiliation__c>> ();
            for ( Enrollment_Component_Affiliation__c affiliation : [SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Status__c, Enrollment_Component__r.RecordType.Name
                                                                        FROM Enrollment_Component_Affiliation__c
                                                                        WHERE Program_Enrollment__c in :programEnrollmentIds]) {
                if (!progEnrollECAListMap.containsKey(affiliation.Program_Enrollment__c)){
                    list <Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c> ();
                    ecas.add(affiliation);
                    progEnrollECAListMap.put(affiliation.Program_Enrollment__c, ecas);
                } else
                    progEnrollECAListMap.get(affiliation.Program_Enrollment__c).add(affiliation);
            }
        
            map<Id,hed__Program_Enrollment__c> EnrollmentsMap = new map<Id,hed__Program_Enrollment__c>();
            Set<Id> acedemicProgramsReferenced = new Set<Id> ();

            for (hed__Program_Enrollment__c pe : [SELECT Id, hed__Account__c, hed__Contact__c, hed__Contact__r.RecordType.Name, Enrollment_Type__c,
                            Household_Program_Enrollment__c,V2_External_ID__c,Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                            FROM hed__Program_Enrollment__c WHERE Id IN :programEnrollmentIds] ) {
                EnrollmentsMap.put(pe.Id, pe);
                acedemicProgramsReferenced.add(pe.hed__Account__c);
            }

            //Build a map between Academic Programs and Process ids.
            map <Id, Id> academicProgramProcessIdMap = new Map<Id,Id>();
            Set<Id> processIdSet = new Set<Id>();
            for (Enrollment_Component__c e : [SELECT Id, Process_Academic_Program__c FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :acedemicProgramsReferenced  AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT])
            {
                academicProgramProcessIdMap.put(e.Process_Academic_Program__c, e.id);
                processIdSet.add(e.id);
            }

            //Build a list of all the enrollment components that have time based criteria and pass
            //those to runAssignment as a list of all the ids of the possibly impacted components.
            map<Id, List<Id>> processIdTimeBasedComponentsMap = new Map<Id, List<Id>> ();
            NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();

            for (id pId : processIdSet) {
                NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = allECData.getSpecificProcessECData(pId);

            
                for (Enrollment_Component_Criteria__c ECC : [ SELECT Enrollment_Component__c, enrollment_component__r.name
                                                FROM Enrollment_Component_Criteria__c
                                                WHERE Enrollment_Component__c IN :thisProcessData.allIds
                                                AND Criteria_Type__c = 'Assignment'
                                                AND Criteria__r.criteria_field__c = 'hed__program_enrollment__c.date_today__c' ] ) {

                    List<Id> componentList;
                    if (processIdTimeBasedComponentsMap.containsKey(pid))
                        componentList = processIdTimeBasedComponentsMap.get(pid);
                    else 
                        componentList = new List<Id> ();

                    system.debug ('enrollment_component__r.name' + ECC.enrollment_component__r.name);
                                                
                    componentList.add(ECC.Enrollment_Component__c);
                    processIdTimeBasedComponentsMap.put(pId, componentList);
                    
                }
            }

        
            //for(SObject programEnrollment : scope) {
            for (id peID: programEnrollmentIds){
                hed__Program_Enrollment__c thisEnrollment = EnrollmentsMap.get(peID);
                id processId = academicProgramProcessIdMap.get(thisEnrollment.hed__Account__c);
                List<Id> thisProcessTimeBasedComponents = processIdTimeBasedComponentsMap.get(processId);
                system.debug ('thisProcessTimeBasedComponents' + thisProcessTimeBasedComponents);
                NES_ECAEvaluation.runAssignment(peID, thisProcessTimeBasedComponents, thisEnrollment, progEnrollECAListMap.get(peID), processId );
            }

            List<Enrollment_Component_Affiliation__c> affiliations = [
                    SELECT Id, Enrollment_Component__c, Program_Enrollment__c, Enrollment_Component__r.RecordType.Name, Status__c, Order__c,
                        Enrollment_Component__r.Assignment_Logic__c, Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c
                    FROM Enrollment_Component_Affiliation__c
                    WHERE Program_Enrollment__c IN : programEnrollmentIds];

            Map<Id,List<Enrollment_Component_Affiliation__c>> progEnrollECAAfterAssignmentListMap = new Map<Id,List<Enrollment_Component_Affiliation__c>> ();
            for ( Enrollment_Component_Affiliation__c affiliation : affiliations) {
                if (!progEnrollECAAfterAssignmentListMap.containsKey(affiliation.Program_Enrollment__c)){
                    list <Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c> ();
                    ecas.add(affiliation);
                    progEnrollECAAfterAssignmentListMap.put(affiliation.Program_Enrollment__c, ecas);
                } else
                    progEnrollECAAfterAssignmentListMap.get(affiliation.Program_Enrollment__c).add(affiliation);
            }

            Map<Id, Map<Id, Enrollment_Component_Affiliation__c>> enrollmentAffiliationMap = new Map<Id, Map<Id, Enrollment_Component_Affiliation__c>>();

            //Loop through affiliations and grab EC Ids and create map of PE Id to map of EC Id to Affiliation

            for(Id enrollmentId : programEnrollmentIds) {

                Map<Id, Enrollment_Component_Affiliation__c> tempAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();

                for(Enrollment_Component_Affiliation__c affiliation : affiliations) {

                    if(enrollmentId == affiliation.Program_Enrollment__c) {

                        if(enrollmentAffiliationMap.keySet().contains(enrollmentId)) {
                            tempAffiliationMap = enrollmentAffiliationMap.get(enrollmentId);
                        }

                        tempAffiliationMap.put(affiliation.Enrollment_Component__c, affiliation);
                        System.debug(tempAffiliationMap);
                    }

                }
                enrollmentAffiliationMap.put(enrollmentId, tempAffiliationMap);
            }

            for(Id enrollmentId : programEnrollmentIds) {

                Map<Id, Enrollment_Component_Affiliation__c> tempAffiliationMap = enrollmentAffiliationMap.get(enrollmentId);
                if(tempAffiliationMap.size() > 0) {
                    hed__Program_Enrollment__c thisEnrollment = EnrollmentsMap.get(enrollmentId);
                    id processId = academicProgramProcessIdMap.get(thisEnrollment.hed__Account__c);
                    List<Enrollment_Component_Affiliation__c> thisPEECAs = progEnrollECAAfterAssignmentListMap.get(enrollmentId);
                    if (thisPEECAs <> null && thisPEECAs.size() > 0)
                        NES_ECACompletion.evaluateCompletion(enrollmentId, processId, null, tempAffiliationMap, thisPEECAs, thisEnrollment);
                }

            }
        }
    }


    global void finish(Database.BatchableContext BC) {

    }


    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_Batch_TimeCriteria(), 2);
    }

}