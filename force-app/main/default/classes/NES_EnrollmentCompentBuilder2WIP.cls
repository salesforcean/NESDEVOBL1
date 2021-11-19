public with sharing class NES_EnrollmentCompentBuilder2WIP {
/**
 *  @ALIKM 20/apr/2020- commenting out changes
    private static NES_EnrollmentCompentBuilder2WIP instance = null;
    private static Map<Id, enrollmentComponentData> allECData;
    //This will hold all the Enrollment Components for all process ids that have been passed in this
    //execution context.  No need to break the data out by process id.
    public Map<Id, Enrollment_Component__c> enrollmentComponentMap;

    private NES_EnrollmentCompentBuilder2WIP() {
        //Only exists to defeat instantiation (Notice it is private)
        allECData = new map<id, enrollmentComponentData> ();
        enrollmentComponentMap = new Map<Id, Enrollment_Component__c>();
    }

    public static NES_EnrollmentCompentBuilder2WIP getInstance() {
        if (instance == null)
            instance = new NES_EnrollmentCompentBuilder2WIP();
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
        public Id ProcessId;
        // public ecrConsumerFormat ecrTreeData {get; private set;}
        // public Boolean isEnabledTreeConfig {get {return true;}; private set;}

        // new constructor
        public enrollmentComponentData() {
            this.stageRelationships          = new List<Enrollment_Component_Relationship__c>();
            this.formRelationships           = new List<Enrollment_Component_Relationship__c>();
            this.sectionRelationships        = new List<Enrollment_Component_Relationship__c>();
            this.questionGroupRelationships  = new List<Enrollment_Component_Relationship__c>();
            this.questionRelationships       = new List<Enrollment_Component_Relationship__c>();
            this.questionParentIds           = new Set<Id>();
        }

        // new constructor
        public enrollmentComponentData(enrollmentComponentData interim) {
            this.allIds                      = interim.allIds;
            this.componentOrderMap           = interim.componentOrderMap;
            this.stageRelationships          = interim.stageRelationships;
            this.formRelationships           = interim.formRelationships;
            this.sectionRelationships        = interim.sectionRelationships;
            this.questionGroupRelationships  = interim.questionGroupRelationships;
            this.questionRelationships       = interim.questionRelationships;
            this.questionParentIds           = interim.questionParentIds;
        }

        // constructor
        public enrollmentComponentData (id ProcessId) {

            this.ProcessId = ProcessId;
            enrollmentComponentData interim = NES_ECDataImportExport.ImportData(this.ProcessId);
            if (interim!=null) {
                this(interim);
            } else {
                this.generateData();
            }

        }

        private void importData() {

        }
        // ALI WIP END

        



        private void generateData() {
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