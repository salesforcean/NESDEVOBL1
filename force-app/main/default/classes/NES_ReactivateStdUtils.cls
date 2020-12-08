// Created By Maddileti for New SY Reactivation

public class NES_ReactivateStdUtils {
    
    public static user getCTUserFromStudentId(String studentId){
        User ctUser;
        Contact stdUser;
        if(studentId != null){
            stdUser= [SELECT Id, Caretaker_Id__c from Contact where Id=:studentId limit 1];
            ctUser = [SELECT Id, AccountId, ContactId, Contact.RecordType.Name,Contact.Account.Family_Enrollment_Counselor__c, Contact.AccountId FROM User WHERE ContactId = :stdUser.Caretaker_Id__c limit 1];
        }
        else
            ctUser = null;
        
        return ctUser; 
    }
    public static user getCTUser(String userId){
        
        User ctUser;
        if(userId != null){
            ctUser = [SELECT Id, AccountId, ContactId, Contact.RecordType.Name,Contact.Account.Family_Enrollment_Counselor__c, Contact.AccountId FROM User WHERE Id = :userId];
        }
        else
            ctUser = null;
        
        return ctUser; 
    }
    
    public static Id getStudentRTId(){		
        return Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
    }
    
    public static Contact getStudentContact(Id studentId, Id studentRTId){
        Contact student;
        if(studentId != null){
            student =[select id,AccountId,firstName,middleName,lastName,Birthdate__c from Contact WHERE id = :studentId  AND RecordTypeId = :studentRTId limit 1];
        }
        else
            student = null;
        return student;
    }
    
    
    public static School_year__c getSchoolYears(String schoolYearName){
        School_Year__c schoolYear;
        if(schoolYearName != null){
            schoolYear = [SELECT Current_Year__c,Id,name FROM School_Year__c where name =:schoolYearName limit 1];
        }
        else
            schoolYear = null;
        return schoolYear;
    }
    
    public static account getInstitute(String instituationName){
        
        return [SELECT Id, name FROM Account where name =:instituationName limit 1];
    }
    
    public static Id getAcademicRTProgramId(){
        
        return Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
    }
    
    
    
    public static List<Enrollment_Component__c> getProcessEC(Id academicProgramId){
        return [SELECT Id, Assignment_Logic__c
                FROM Enrollment_Component__c
                WHERE Process_Academic_Program__c = :academicProgramId
                AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT
                LIMIT 1
               ];
    }
    
    
    public Static List<Enrollment_Component_Relationship__c> getAllStages(Id processComponent){
        return [
            SELECT Child_Enrollment_Component__c, Id, Order__c, Parent_Enrollment_Component__c,
            Child_Enrollment_Component__r.Assignment_Logic__c, Child_Enrollment_Component__r.Component_Type__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c = :processComponent
            AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
            ORDER BY Order__c ASC
        ];
    }
    
    
    public static List<Enrollment_Component_Affiliation__c> insertAffiliations(Id processId, Id studentPEId, List<Enrollment_Component_Relationship__c> stageAffiliations){
        
        List<Enrollment_Component_Affiliation__c> ecAffiliationsToInsert = new List<Enrollment_Component_Affiliation__c>();
        // Add process affiliation
        Enrollment_Component_Affiliation__c affiliationRecord1 = new Enrollment_Component_Affiliation__c();
        affiliationRecord1.Enrollment_Component__c = processId;
        affiliationRecord1.Program_Enrollment__c = studentPEId;
        affiliationRecord1.Status__c = 'In Progress';
        ecAffiliationsToInsert.add(affiliationRecord1);
        
        // add stage 1 affiliation
        Enrollment_Component_Affiliation__c affiliationRecord2 = new Enrollment_Component_Affiliation__c();
        affiliationRecord2.Enrollment_Component__c = stageAffiliations[0].Child_Enrollment_Component__c;
        affiliationRecord2.Program_Enrollment__c = studentPEId;
        affiliationRecord2.Status__c = 'Complete';
        affiliationRecord2.Order__c = stageAffiliations[0].Order__c;
        ecAffiliationsToInsert.add(affiliationRecord2);
        
        //Add the rest of the stages that have no assignment logic.
        for (Integer i = 1; i < stageAffiliations.size(); i++) {
            if (String.isBlank(stageAffiliations[i].Child_Enrollment_Component__r.Assignment_Logic__c)) {                
                Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
                affiliationRecord.Enrollment_Component__c = stageAffiliations[i].Child_Enrollment_Component__c;
                affiliationRecord.Program_Enrollment__c = studentPEId;
                affiliationRecord.Order__c = stageAffiliations[i].Order__c;
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
            WHERE Parent_Enrollment_Component__c = :stageAffiliations[0].Child_Enrollment_Component__c
            AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.FORM_RT
            ORDER BY Order__c
        ];
        System.debug(formRelationships);
        List<Id> formRelationshipIds = new List<Id>();
        for (Enrollment_Component_Relationship__c formRelationship : formRelationships) {
            if (String.isBlank(formRelationship.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                Enrollment_Component_Affiliation__c affiliationRecord3 = new Enrollment_Component_Affiliation__c();
                affiliationRecord3.Enrollment_Component__c = formRelationship.Child_Enrollment_Component__c;
                affiliationRecord3.Program_Enrollment__c = studentPEId;
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
                affiliationRecord3.Program_Enrollment__c = studentPEId;
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
        
        return nonNullInsertingAffiliations;
    }
    
    
    
    
}