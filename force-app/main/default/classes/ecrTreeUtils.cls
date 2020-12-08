/**
 * @Author: Ali KM (Ness Tech.)
 * @Purpose: 
 *      Utility methods for ecrTree generation & parsing.
 */
public class ecrTreeUtils {
    
    // @returns ecrTree record
    public static ecrTree__c createECRTreeRec(ecrProducerFormat config) {
        
        List<String> ecTypesList = new List<String>();
        ecTypesList.addAll(config.ecTypes); // converting ecTypes from set to list

        ecrTree__c newConfig = new ecrTree__c(
            ParentID__c = config.root.nodeId,
            isActive__c = true,
            Type__c = config.root.kind,
            ecTreeHeight__c = config.steps, 
            ecCount__c = config.countECs, 
            ecTypes__c = String.join(ecTypesList, ','),
            Payload__c = JSON.serialize(config.root),
            Version__c = config.version
        );

        return newConfig;

    }
    

    // query the ecProcess rec.
    public static List<Enrollment_Component__c> getECsByID(List<Id> ecIDs) {
        return [SELECT  Id, 
                        Name, 
                        Assignment_Logic__c, 
                        RecordTypeId, 
                        RecordType.Name, 
                        Completion_Logic__c,
                        Is_Required__c,
                        External_Id__c
                FROM    Enrollment_Component__c 
                WHERE   Id =: ecIDs];
    }
    

    // query ECR records by ParentIDs
    public static List<Enrollment_Component_Relationship__c> queryECRs(Set<Id> parentIDs) {       
        return [SELECT  Id, Order__c, External_Id__c,
                    Parent_Enrollment_Component__c,
                    Parent_Enrollment_Component__r.Id, 
                    Parent_Enrollment_Component__r.Name, 
                    Parent_Enrollment_Component__r.Completion_Logic__c, 
                    Child_Enrollment_Component__c, 
                    Child_Enrollment_Component__r.Id, 
                    Child_Enrollment_Component__r.Name, 
                    Child_Enrollment_Component__r.RecordTypeId,
                    Child_Enrollment_Component__r.RecordType.Name, 
                    Child_Enrollment_Component__r.Component_Type__c,
                    Child_Enrollment_Component__r.Completion_Logic__c,
                    Child_Enrollment_Component__r.Assignment_Logic__c,
                    Child_Enrollment_Component__r.Is_Required__c,
                    Child_Enrollment_Component__r.External_Id__c
            FROM    Enrollment_Component_Relationship__c
            WHERE   Parent_Enrollment_Component__c =: parentIDs
            //AND   Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT 
            ORDER BY Order__c ASC];
    }

    // query ECR records by IDs
    public static List<Enrollment_Component_Relationship__c> queryECRById(Set<Id> recIDs) {       
        return [SELECT  Id, Order__c, External_Id__c,
                    Parent_Enrollment_Component__c,
                    Parent_Enrollment_Component__r.Id, 
                    Parent_Enrollment_Component__r.Name, 
                    Parent_Enrollment_Component__r.Completion_Logic__c, 
                    Child_Enrollment_Component__c, 
                    Child_Enrollment_Component__r.Id, 
                    Child_Enrollment_Component__r.Name, 
                    Child_Enrollment_Component__r.RecordTypeId,
                    Child_Enrollment_Component__r.RecordType.Name, 
                    Child_Enrollment_Component__r.Component_Type__c,
                    Child_Enrollment_Component__r.Completion_Logic__c,
                    Child_Enrollment_Component__r.Assignment_Logic__c,
                    Child_Enrollment_Component__r.Is_Required__c,
                    Child_Enrollment_Component__r.External_Id__c
            FROM    Enrollment_Component_Relationship__c
            WHERE   Id =: recIDs
            //AND   Child_Enrollment_Component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT 
            ORDER BY Order__c ASC];
    }

    public static ecrTree__c getECRTreeByParentIDs(Id ecrTreeParentID) {
        return getECRTreeByParentIDs(new Set<Id>{ecrTreeParentID})[0];
    }


    /**
     * // ideally this should return just 1 Active record
     */
    public static List<ecrTree__c> getECRTreeByParentIDs(Set<Id> ecTreeParentIDs) {

        return [SELECT  Id, 
                        Name, 
                        ParentID__c, 
                        Version__c, 
                        isActive__c, 
                        Type__c,
                        Payload__c
                FROM    ecrTree__c
                WHERE   ParentID__c = : ecTreeParentIDs
                AND     isActive__c = true]; 
                // ORDER BY Version__c DESC]; 

    }

    public static Boolean doesECRecordExist(String ecId) {
        return doesECRecordExist(ecId, NES_DashboardUtilities.PROCESS_RT);
    }


    public static Boolean doesECRecordExist(String ecId, String ecType) {
        return (([SELECT count() FROM Enrollment_Component__c WHERE Id = :ecId AND RecordType.Name = :ecType])>0);
    }


    /**
     * Shallow clone the node to avoid recursive copy of all children.
     */
    public static ecNode ecrNodeClone(ecNode srcNode) {
        return new ecNode(srcNode);
    }

}