global class NES_EnrollmentCompentBuilderWIP  {
/**
 * 	* 	@ALIKM 20/apr/2020- commenting out changes
 *  @Usage: 
 * 
        WIP:
        NEW: 
            String processId ='a0f0n000001IAQ2AAO'; //  
            private static NES_EnrollmentCompentBuilderWIP.enrollmentComponentData thisProcessData = new NES_EnrollmentCompentBuilderWIP.enrollmentComponentData(processId);
            System.debug('componentOrderMap.size>>>' + thisProcessData.componentOrderMap.size());
            System.debug('questionParentIds.size>>>' + thisProcessData.questionParentIds.size());
            System.debug('stageRelationships.size>>>' + thisProcessData.stageRelationships.size());
            System.debug('formRelationships.size>>>' + thisProcessData.formRelationships.size());
            System.debug('sectionRelationships.size>>>' + thisProcessData.sectionRelationships.size());
            System.debug('questionGroupRelationships.size>>>' + thisProcessData.questionGroupRelationships.size());
            System.debug('questionRelationships.size>>>' + thisProcessData.questionRelationships.size());
        OLD: 
            String processId ='a0f0n000001IAQ2AAO'; //  
            private static NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = new NES_EnrollmentCompentBuilder.enrollmentComponentData(processId);
            System.debug('allIds.size>>>' + thisProcessData.allIds.size()); >>>467
            System.debug('componentOrderMap.size>>>' + thisProcessData.componentOrderMap.size()); >>>467
            System.debug('questionParentIds.size>>>' + thisProcessData.questionParentIds.size()); >>>86
            System.debug('stageRelationships.size>>>' + thisProcessData.stageRelationships.size()); >>>5
            System.debug('formRelationships.size>>>' + thisProcessData.formRelationships.size()); >>>23
            System.debug('sectionRelationships.size>>>' + thisProcessData.sectionRelationships.size()); >>>54
            System.debug('questionGroupRelationships.size>>>' + thisProcessData.questionGroupRelationships.size()); >>>33
            System.debug('questionRelationships.size>>>' + thisProcessData.questionRelationships.size()); >>>385
        WIP END: 

        private static NES_EnrollmentCompentBuilder allECData = NES_EnrollmentCompentBuilder.getInstance();
        private static NES_EnrollmentCompentBuilder.enrollmentComponentData thisProcessData = new enrollmentComponentData(processId);
        String ecParentID ='a0f0n000001IAQ2AAO'; // 
        thisProcessData = allECData.getSpecificProcessECData(processId);
        enrollmentComponentData newProcessData = new enrollmentComponentData(processId);

        Ex:
            List<Enrollment_Component_Relationship__c> processRelationships = thisProcessData.stageRelationships;
            List<Enrollment_Component_Relationship__c> stageRelationships = thisProcessData.formRelationships;
            List<Enrollment_Component_Relationship__c> sectionRelationships = thisProcessData.sectionRelationships;
            allIdsSet.addall(thisProcessData.allIds);
            thisProcessData.allIds

            List<Enrollment_Component_Relationship__c> questionGroupRelationships = thisProcessData.questionGroupRelationships;
            List<Enrollment_Component_Relationship__c> questionRelationships = thisProcessData.questionRelationships;
            
            componentOrderMap = thisProcessData.componentOrderMap;

            List<Enrollment_Component_Affiliation__c> affiliations = evalAssignment(studentEnrollment.hed__Contact__c, 
            studentEnrollment.Household_Program_Enrollment__r.hed__Contact__c, studentEnrollment.hed__Contact__r.AccountId, 
            studentEnrollment.Id, studentEnrollment.Household_Program_Enrollment__c, stageRelationships, formRelationships, 
            sectionRelationships, questionGroupRelationships, questionRelationships, thisProcessData, impactedEnrollmentComponents, progEnrollmentECAs);

            IMP: Query to get Academic Program: 
                SELECT Completion_Logic__c,Component_Type__c,Document_Type__c,Id,Name,Order__c,Parent_Enrollment_Component__c,
                Process_Academic_Program__c FROM Enrollment_Component__c where Process_Academic_Program__c!=null


        Need:
            ec.Completion_Logic__c
            ec.RecordType.Name

        enrollmentComponentMap.put(enrollmentComponent.Id, enrollmentComponent); 
        
        ecr 
            parentEC
            childEC
        TEST after building ecr & ec records: 
        #1:
            for (Enrollment_Component_Relationship__c r : thisProcessData.sectionRelationships) {
			if (r.Child_Enrollment_Component__r.RecordType.Name  == NES_DashboardUtilities.SECTION_RT ||
			          r.Child_Enrollment_Component__r.RecordType.Name  == NES_DashboardUtilities.DOCUMENT_RT)
                formRelationships.add(r);
            }
        
        #2:
            List<Id> stageIds = new List<Id>();
            if (processRelationships.size() != 0 && String.isNotBlank(processRelationships[0].Parent_Enrollment_Component__r.Completion_Logic__c)) {
                completionLogicMap.put(processId, processRelationships[0].Parent_Enrollment_Component__r.Completion_Logic__c);
            }



global class NES_EnrollmentCompentBuilderWIP  {

    private static NES_EnrollmentCompentBuilderWIP instance = null;
    private static Map<Id, enrollmentComponentData> allECData;
    //This will hold all the Enrollment Components for all process ids that have been passed in this
    //execution context.  No need to break the data out by process id.
    public Map<Id, Enrollment_Component__c> enrollmentComponentMap;

    private NES_EnrollmentCompentBuilderWIP() {
        //Only exists to defeat instantiation (Notice it is private)
        allECData = new map<id, enrollmentComponentData> ();
        enrollmentComponentMap = new Map<Id, Enrollment_Component__c>();
    }

    public static NES_EnrollmentCompentBuilderWIP getInstance() {
        if (instance == null)
            instance = new NES_EnrollmentCompentBuilderWIP();
        return instance;
    }

    public class enrollmentComponentData {

        public List<Enrollment_Component_Relationship__c> stageRelationships;
        public List<Enrollment_Component_Relationship__c> formRelationships;
        public List<Enrollment_Component_Relationship__c> sectionRelationships;
        public List<Enrollment_Component_Relationship__c> questionGroupRelationships;
        public List<Enrollment_Component_Relationship__c> questionRelationships;

        public Map<Id, Decimal> componentOrderMap = new Map<Id, Decimal>();
        public List<Id> allIds = new List<Id>();
        public Set<Id> questionParentIds;

        // WIP ALI KM 
        public Id ProcessId {get; private set;}
        public ecrConsumerFormat ecrTreeData {get; private set;}
        public Boolean isEnabledTreeConfig {get; private set;}

        // constructor
        public enrollmentComponentData (id ProcessId) {
            
            this.ProcessId = ProcessId;
            if (ecrTreeUtils.doesECRecordExist(ProcessId)) {// @TODO: need to identify & add toggle config. this.isEnabledTreeConfig || 
                this.generateDataUsingConfig();
            } else {
                this.generateDataUsingSOQL();
            }

        }

        private void generateDataUsingConfig() {
            
            // import the data
            this.ecrTreeData = ecrTreeImportExport.ImportTree(this.ProcessId);
            // System.debug('>>>>this.ecrTreeData>>>>>' + this.ecrTreeData);

            // run a query to get the ecr records.
            Map<Id, Enrollment_Component_Relationship__c> ecrMap = new Map<Id, Enrollment_Component_Relationship__c>();
            for (Enrollment_Component_Relationship__c ecr : ecrTreeUtils.queryECRById(ecrTreeData.ecrECMap.keySet())) {
                ecrMap.put(ecr.Id, ecr);
                this.componentOrderMap.put(ecr.Child_Enrollment_Component__c, ecr.Order__c);
                // this.allIds.add(ecr.Child_Enrollment_Component__c);
            }
            // Map<Id, Enrollment_Component_Relationship__c> ecrMap = new Map<Id, Enrollment_Component_Relationship__c>(ecrTreeUtils.queryECRById(ecrTreeData.ecrECMap.keySet()));

            // get all the IDs
            this.allIds.addAll(this.componentOrderMap.keySet());
            
            // ecrTreeData.sourceID = sourceID;
            // ecrTreeData.ecrNodesMap = ; (NOT NEEDED)
            // ecrTreeData.ecrECMap = ;
            // ecrTreeData.ecrIDsByLevel = ;

            // @todo: move this to config or setting
            Map<String, Integer> ecrTypeToLevelsMap = new Map<String, Integer> {
                'Process' => 0,
                'Stage' => 1 ,
                'Form' => 2,
                'Section' => 3,
                'QuestionGroup' => 4,
                'Question' => 5
            };

            // fill in the maps ( aka dataClass )
            this.stageRelationships = new List<Enrollment_Component_Relationship__c>();
            this.formRelationships = new List<Enrollment_Component_Relationship__c>();
            this.sectionRelationships = new List<Enrollment_Component_Relationship__c>();
            this.questionGroupRelationships = new List<Enrollment_Component_Relationship__c>();
            this.questionRelationships = new List<Enrollment_Component_Relationship__c>();
            this.questionParentIds = new Set<Id>();

            // List of stageRelationships;
            Integer level = ecrTypeToLevelsMap.get('Stage');
            for (Id ecrId : ecrTreeData.ecrIDsByLevel.get(level)) {
                // System.debug('inside stagge ecrId:' + ecrId);
                // System.debug('ecrMap.get(ecrId)?:' + ecrMap.get(ecrId));
                this.stageRelationships.add(ecrMap.get(ecrId));
            }

            
            // List of formRelationships;
            level = ecrTypeToLevelsMap.get('Form');
            for (Id ecrId : ecrTreeData.ecrIDsByLevel.get(level)) {
                this.formRelationships.add(ecrMap.get(ecrId));
            }

            
            // List of sectionRelationships;
            level = ecrTypeToLevelsMap.get('Section');
            for (Id ecrId : ecrTreeData.ecrIDsByLevel.get(level)) {
                this.sectionRelationships.add(ecrMap.get(ecrId));
                this.questionParentIds.add(ecrMap.get(ecrId).Child_Enrollment_Component__c);
            }


            // List of questionGroupRelationships;
            level = ecrTypeToLevelsMap.get('QuestionGroup');
            for (Id ecrId : ecrTreeData.ecrIDsByLevel.get(level)) {
                this.questionGroupRelationships.add(ecrMap.get(ecrId));
                this.questionParentIds.add(ecrMap.get(ecrId).Child_Enrollment_Component__c);
            }   


            // List of questionRelationships;
            level = ecrTypeToLevelsMap.get('Question');
            for (Id ecrId : ecrTreeData.ecrIDsByLevel.get(level)) {
                this.questionRelationships.add(ecrMap.get(ecrId));
            }
            
            // System.debug('allIds.size>>>' + this.allIds.size());
            // System.debug('componentOrderMap.size>>>' + this.componentOrderMap.size());
            // System.debug('questionParentIds.size>>>' + this.questionParentIds.size());
            // System.debug('stageRelationships.size>>>' + this.stageRelationships.size());
            // System.debug('formRelationships.size>>>' + this.formRelationships.size());
            // System.debug('sectionRelationships.size>>>' + this.sectionRelationships.size());
            // System.debug('questionGroupRelationships.size>>>' + this.questionGroupRelationships.size());
            // System.debug('questionRelationships.size>>>' + this.questionRelationships.size());
            

            //     switch on level { // @TODO: change level from Integer to enum of type {Process, Stage, ...}
            //         when 0 { // processID
            //             continue;
            //         }
            //         when 1 { // stages
            //             stageRelationships.add(ecrMap.get(ecrId));
            //         }
            //         when else {
            //                 throw new NES_EnrollmentReactivation.EnrollmentReactivation_Exception(
            //                     'EnrollmentReactivation error, reactivation type is invalid. Supported values are => FULL, SOFT.');
            //         }
            //     }

            // }

        }
        // ALI WIP END

        private void generateDataUsingSOQL() {
            System.debug('In the enrollmentComponentData constructor');

            //Do all the work of getting the EC data.
            stageRelationships = [
                SELECT Child_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Id, Order__c, Parent_Enrollment_Component__c,
                    Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Completion_Logic__c, Child_Enrollment_Component__r.Completion_Logic__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c = :processId
                AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT ORDER BY Order__c
            ];

            List<Id> stageIds = new List<Id>();

            for (Enrollment_Component_Relationship__c stageRelationship : stageRelationships) {
                stageIds.add(stageRelationship.Child_Enrollment_Component__c);
                componentOrderMap.put(stageRelationship.Child_Enrollment_Component__c, stageRelationship.Order__c);
            }

            formRelationships = [
                    SELECT Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.Assignment_Logic__c,
                            Child_Enrollment_Component__r.Component_Type__c, Parent_Enrollment_Component__c,
                            Child_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Completion_Logic__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :stageIds
                    AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FLAG_RT)
            ];

            List<Id> formIds = new List<Id>();
            for (Enrollment_Component_Relationship__c relationship : formRelationships) {
                formIds.add(relationship.Child_Enrollment_Component__c);
                componentOrderMap.put(relationship.Child_Enrollment_Component__c, relationship.Order__c);
            }

            sectionRelationships = [
                    SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, 
                    Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c,
                    Child_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Completion_Logic__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :formIds
                    AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT)
            ];

            List<Id> sectionIds = new List<Id>(); 
            for (Enrollment_Component_Relationship__c relationship : sectionRelationships) {
                sectionIds.add(relationship.Child_Enrollment_Component__c);
                componentOrderMap.put(relationship.Child_Enrollment_Component__c, relationship.Order__c);
            }

            questionGroupRelationships = [
                    SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE Parent_Enrollment_Component__c IN :sectionIds
                    AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTIONGROUP_RT
            ];

            List<Id> groupIds = new List<Id>(); 
            for (Enrollment_Component_Relationship__c relationship : questionGroupRelationships) {
                groupIds.add(relationship.Child_Enrollment_Component__c);
                componentOrderMap.put(relationship.Child_Enrollment_Component__c, relationship.Order__c);
            }

            questionRelationships = [
                    SELECT Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
                    FROM Enrollment_Component_Relationship__c
                    WHERE (Parent_Enrollment_Component__c IN :groupIds
                    OR Parent_Enrollment_Component__c IN :sectionIds)
                    AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.HIDDEN_INPUT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.TEXT_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FLAG_RT
                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.MESSAGE_RT)
            ];

            // Combine the question groups and the sections
            questionParentIds = new Set<Id>();
            questionParentIds.addAll(sectionIds);
            questionParentIds.addAll(groupIds);

            Set<Id> questionIds = new Set<Id>();

            for (Enrollment_Component_Relationship__c temp : questionRelationships) {
                questionIds.add(temp.Child_Enrollment_Component__c);
                componentOrderMap.put(temp.Child_Enrollment_Component__c, temp.Order__c);
            }

            allIds = new List<Id>();
            allIds.addAll(stageIds);
            allIds.addAll(formIds);
            allIds.addAll(questionParentIds);
            allIds.addAll(questionIds);
        }
    
    }

    public enrollmentComponentData getSpecificProcessECData (id processId)
    {
        //Check the map to see if I already have the data for this PE
        if (!allECData.containsKey(processId) ) {
            //Build the new data set, add it to the map and return it.
            enrollmentComponentData newProcessData = new enrollmentComponentData(processId);
            allECData.put(processId, newProcessData);

            //We have one map for all the enrollment components for all the processes we have in this execution context.
            if (newProcessData.allIds.size() > 0) { 

                List<Enrollment_Component__c> componentChildren = [
                        SELECT Id, RecordType.Name, Assignment_Logic__c, Completion_Logic__c,  (  
                                SELECT Id, Criteria_Type__c, Criteria_Number__c, Criteria__r.Criteria_Field__c,
                                        Criteria__c, Student_or_Household__c,
                                        Criteria__r.Comparison_Field__c, Criteria__r.Operator__c,
                                        Criteria__r.Comparison_Data_Type__c, Criteria__r.Comparison_Value__c,
                                        Enrollment_Component__c, Enrollment_Component__r.Completion_Logic__c,
                                        Enrollment_Component__r.Assignment_Logic__c
                                FROM Enrollment_Component_Criteria__r
                        ), (SELECT Id, Group_Logic__c, Group_Number__c FROM Criteria_Groups__r)
                        FROM Enrollment_Component__c
                        WHERE Id IN:newProcessData.allIds
                ];

                for (Enrollment_Component__c enrollmentComponent : componentChildren) {
                    enrollmentComponentMap.put(enrollmentComponent.Id, enrollmentComponent);
                }
            }
        }

        return allECData.get(ProcessId);
    }
*/
}