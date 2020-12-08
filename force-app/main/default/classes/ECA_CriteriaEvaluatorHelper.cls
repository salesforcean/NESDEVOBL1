/**
    @class:         ECA_CriteriaEvaluatorHelper           
	@description:   Part of rewrite of the ECA assignment and completion logic, runs SOQL queries across relevant sObjects.
	@author: 		Mark Membrino
	@createdDate:   8/31/2020
*/
public class ECA_CriteriaEvaluatorHelper {

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
                                    Criteria__r.Criteria_Field__c
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
                        Program_Enrollment__c  
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

    // public static List<Enrollment_Component_Relationship__c> getAllECRsByIds(Set<Id> ecIDs) {
    //     return 
    //     [    
    //         SELECT  Id, 
    //                 Child_Enrollment_Component__c,
    //                 Child_Enrollment_Component__r.RecordType.Name,
    // 			 	Parent_Enrollment_Component__c,
    // 			 	Parent_Enrollment_Component__r.RecordType.Name,
    // 			 	Order__c
    //         FROM    Enrollment_Component_Relationship__c
    //         WHERE   Child_Enrollment_Component__c IN: ecIDs 
    //                 OR Parent_Enrollment_Component__c IN: ecIDs
    //     ];
    // }

    // public static List<Enrollment_Component_Affiliation__c> getECAsByPEIds(Set<Id> peIDs) {
    //     return 
    //     [    
    //         SELECT  Id, 
    //                 Order__c,
    //                 Program_Enrollment__c,
    //                 Program_Enrollment__r.hed__Account__c,
    //                 Enrollment_Component__c,
    //                 Enrollment_Component__r.Recordtype.Name,
    //                 Enrollment_Component__r.is_Required__c,
    //                 Status__c
    //         FROM Enrollment_Component_Affiliation__c 
    //         WHERE program_enrollment__c in : peIDs
    //     ];
    // }

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
                // ,
                // (
                //     SELECT      Id, StageName
                //     FROM        Opportunities__r
                //     WHERE       StageName = 'Open'
                //     ORDER BY    LastModifiedDate DESC
                //     LIMIT 1
                // )
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
}