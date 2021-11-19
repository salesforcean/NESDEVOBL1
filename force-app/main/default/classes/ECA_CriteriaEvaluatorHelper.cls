/**
    @class:         ECA_CriteriaEvaluatorHelper           
    @description:   Part of rewrite of the ECA assignment and completion logic, runs SOQL queries across relevant sObjects.
    @author:        Mark Membrino
    @createdDate:   8/31/2020
*/
public class ECA_CriteriaEvaluatorHelper {


    public static final String[] DEFAULT_OBJECT_TYPES = new String[]{'Contact', 'Account', 'hed__program_enrollment__c', 
        'Emergency_Contact__c', 'Annual_Student_Information__c', 'Enrollment_Component_Affiliation__c', 'Prior_School__c', 'Special_Education__c'};

    public static Map<Id, Enrollment_Component__c> getECsById(List<Id> ecList) 
    {
        return new Map<Id, Enrollment_Component__c>
        (
            [
                SELECT  Id, 
                        RecordType.Name, 
                        Component_Type__c,
                        Assignment_Logic__c, 
                        Completion_Logic__c,  
                        (  
                            SELECT  Id, 
                                    Criteria_Type__c, 
                                    Criteria_Number__c, 
                                    Criteria__c,
                                    Criteria__r.Name, 

                                    Criteria__r.Criteria_Field__c,
                                    Student_or_Household__c,
                                    School_Year__c,
                                    Question_Group__c 
                            FROM    Enrollment_Component_Criteria__r
                            ORDER BY Criteria_Number__c ASC
                        )
                FROM Enrollment_Component__c
                WHERE Id IN: ecList
            ]
        );
    }

    public static List<Program_Enrollment_Criteria__c> getPECriteriaResultsByPEIds(List<Id> peIds) 
    {
        return new List<Program_Enrollment_Criteria__c>
        (
            [
                SELECT  Id, 
                        Criteria__c, 
                        Result__c, 
                        Criteria__r.Name, 
                        Criteria__r.Comparison_Field__c, 

                        Program_Enrollment__c,
                        Student_or_Household__c,
                        School_Year__c,
                        Question_Group__c  
                FROM    Program_Enrollment_Criteria__c
                WHERE   Program_Enrollment__c IN : peIds
            ]
        );
    }

    public static List<ECA_Evaluation_Setting__mdt> getAllECAEvaluationSettings() {
        
        return 
        [
            SELECT  Id,
                    Label,
                    DeveloperName,
                    QualifiedApiName,
                    Type__c,
                    Status__c,
                    NewStatus__c,
                    AssignmentLogic__c,
                    CompletionLogic__c,
                    DebugMode__c,
                    Feature_Toggle__c
            FROM    ECA_Evaluation_Setting__mdt
            ORDER BY Type__c DESC
        ];
    }


    public static List<hed__Program_Enrollment__c> getPEsWithECAs(Set<Id> peIDs) {
        return 
        [   
            SELECT Id, hed__Account__c, Status__c,
                (
                    SELECT  Id, 
                        Order__c,
                        Program_Enrollment__c,
                        Program_Enrollment__r.hed__Account__c,
                        Enrollment_Component__c,
                        Enrollment_Component__r.Recordtype.Name,
                        Enrollment_Component__r.is_Required__c,
                        Status__c
                    FROM Enrollment_Component_Affiliation__r
                )

            FROM hed__Program_Enrollment__c
            WHERE Id in : peIDs
        ];
    }

    public static List<Opportunity> getOpptyByStudPEIds(Set<Id> studPEIds) {
        return [
            SELECT      Id, Program_Enrollment__c
            FROM        Opportunity 
            WHERE       Program_Enrollment__c IN :studPEIds 
                        AND StageName = 'Open'
            ORDER BY    LastModifiedDate DESC
        ];
    }

    // query Process ECs based on AcademicProgramID
    public static List<Enrollment_Component__c> getECsByAcademicPrograms(List<Id> academicProgramIds) {
        return [
            SELECT  Id, 
                    Name, 
                    Assignment_Logic__c,
                    Process_Academic_Program__c,
                    RecordTypeId, 
                    RecordType.Name, 
                    Completion_Logic__c,
                    Is_Required__c,
                    External_Id__c
            FROM    Enrollment_Component__c 
            WHERE   Process_Academic_Program__c IN :academicProgramIds
            AND Recordtype.Name = 'Process'
        ];
    }


    public static Map<String, School_Year__c> getSchoolYearsByExternalId(Set<String> extIds)
    {
        // collect SchoolYears
        Map<String, School_Year__c> schoolYears = new Map<String, School_Year__c>();
        for (School_Year__c schYear : [ 
            SELECT  Id, External_Id__c, Name 
            FROM    School_Year__c WHERE External_Id__c IN : extIds]) {
                schoolYears.put(schYear.External_Id__c, schYear);
        }
        return schoolYears;
    }

    public static Map<String, Enrollment_Component__c> getECsByExternalId(Set<String> extIds)
    {
        // collect QuestionGroups        
        Map<String, Enrollment_Component__c> qgECs = new Map<String, Enrollment_Component__c>();
        for (Enrollment_Component__c questionGroupEC : [ 
            SELECT  Id, External_Id__c, Name 
            FROM    Enrollment_Component__c WHERE External_Id__c IN : extIds]) 
        {
            qgECs.put(questionGroupEC.External_Id__c, questionGroupEC);
        }
        return qgECs;
    }
                
    public static Map<String, Set<String>> objectFieldsMap 
    {
        get {
            if (objectFieldsMap==null) {
                objectFieldsMap = new Map<String, Set<String>>();
                Schema.DescribeSobjectResult[] results = Schema.describeSObjects(DEFAULT_OBJECT_TYPES);
                // For each returned result, get some info
                for(Schema.DescribeSobjectResult res : results) {
                    if (objectFieldsMap.get(res.getName())==null) {
                        objectFieldsMap.put(res.getName().toLowerCase(), res.fields.getMap().keySet());
                    }
                }
            }
            System.debug('>>>objectFieldsMap>>>DEFAULT>>>' + JSON.serialize(objectFieldsMap));
            return objectFieldsMap;
        }
        set;
    }
}