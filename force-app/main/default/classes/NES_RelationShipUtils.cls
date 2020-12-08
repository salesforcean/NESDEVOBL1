/**
 * Created by ajith on 05/12/18.
 */

public with sharing class NES_RelationShipUtils {

    public static ECDataList getRelatedECInfo(List<Id> childEcIds, Id parentRecTypId){
        ECDataList wrapper = new ECDataList();
        wrapper.parentECIds = new List<Id>();
        wrapper.enrollmentComponentDataSet = new Set<EnrollmentComponentData>();

        Set<EnrollmentComponentData> tempDataSet = new Set<EnrollmentComponentData>();
        for(Enrollment_Component_Relationship__c rel : [SELECT Id, Parent_Enrollment_Component__c, Parent_Enrollment_Component__r.Name, Child_Enrollment_Component__c, Parent_Enrollment_Component__r.RecordTypeId
                                                               FROM Enrollment_Component_Relationship__c
                                                               WHERE Child_Enrollment_Component__c IN :childEcIds AND
                                                                     Parent_Enrollment_Component__r.RecordTypeId =:parentRecTypId]){
            wrapper.parentECIds.add(rel.Parent_Enrollment_Component__c);
            tempDataSet.add(new EnrollmentComponentData(rel.Parent_Enrollment_Component__c, rel.Parent_Enrollment_Component__r.Name));
        }
        if(tempDataSet.size() > 0) {
            wrapper.enrollmentComponentDataSet = tempDataSet;
        }

        return wrapper;
    }

    public static ECDataList getRelatedChildECInfo(List<Id> parentEcIds, Id childRecTypeId){
        ECDataList wrapper = new ECDataList();
        wrapper.childECIds = new List<Id>();
        wrapper.enrollmentComponentDataSet = new Set<EnrollmentComponentData>();

        Set<EnrollmentComponentData> tempDataSet = new Set<EnrollmentComponentData>();
        System.debug(parentEcIds);
        System.debug(childRecTypeId);
        List<Enrollment_Component_Relationship__c> relationships = [SELECT Id, Parent_Enrollment_Component__c, Parent_Enrollment_Component__r.Name, Child_Enrollment_Component__c, Child_Enrollment_Component__r.Name, Child_Enrollment_Component__r.RecordTypeId
                                                                    FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :parentEcIds AND Child_Enrollment_Component__r.RecordTypeId =:childRecTypeId];

        for(Enrollment_Component_Relationship__c rel : relationships ){
            wrapper.childECIds.add(rel.Child_Enrollment_Component__c);
            tempDataSet.add(new EnrollmentComponentData(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Name));
        }
        if(tempDataSet.size() > 0)
            wrapper.enrollmentComponentDataSet = tempDataSet;
        return wrapper;
    }

    public class ECDataList{
        @AuraEnabled public Set<EnrollmentComponentData> enrollmentComponentDataSet {get; set;}
        @AuraEnabled public List<Id> parentECIds {get; set;}
        @AuraEnabled public List<Id> childECIds {get; set;}
    }

    public class EnrollmentComponentData{
        @AuraEnabled public  Id     ecId {get; set;}
        @AuraEnabled public  String ecName {get; set;}

        public EnrollmentComponentData(Id ecId, String ecName){
            this.ecId = ecId;
            this.ecName = ecName;
        }
    }

}