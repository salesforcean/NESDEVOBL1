/**
 * Created by ajith on 03/12/18.
 * This is Apex Controller for the NES_DocumentCentral lightning Component
 */

public with sharing class NES_DocumentCentralController {

    /**
    * Created by Anushka Bansal on 11/13/18.
    * Purpose : This method segregates the Enrollment Documents into 3 categories - Accepted, Under Review, Needs Attention
    * based on their Status.
    * Input : The caretaker Id
    * Output : Returns a wrapper class with No of documents in each category and a list of all documents.
    */
    @AuraEnabled
    public static String getDocumentsList(String caretakerId){
        String returnJSONString = NES_DocumentCentralHelper.getDocumentsListByUser(caretakerId);
        // String returnJSONString = NES_DocumentCentralHelper.getDocumentsListByUser(caretakerId);
        return returnJSONString;
    }

    /**
    * Created by Raju on 19/11/18.
    * Purpose : This method takes enrollment component affiliation id as a parameter and returns the related enrollment component of type document
    *           and its related enrollment component of type message
    */

    @AuraEnabled
    public static String getUIContent(Id enrollmentComponentAffiliationId, Id enrollmentDocumentId){
        String documentJSONString = NES_DocumentCentralHelper.getDocumentInfo(enrollmentComponentAffiliationId, enrollmentDocumentId);
        return documentJSONString;
    }

    /***
    * Created by Raju on 21/11/18.
    * Purpose : This method takes enrollment component affiliation id and document link as a parameter and if there is an existing enrollment document is there
    *           update it, otherwise insert a new document
    **/

    @AuraEnabled
    public static Peak_Response setDocumentLink(Id enrollmentComponentAffiliationId, String documentLink){
        Peak_Response peakResponse = NES_DocumentCentralHelper.updateDocuments(enrollmentComponentAffiliationId, documentLink);
        return peakResponse;
    }

    /**
    * Created by ajith on 19/11/18.
    * Purpose : This method would insert record in Enrollment Document based on the afilitionId passed as parameter
    *           and This method also performs insertion of Document File References records based on the Enrollment Document created
    *           in the above step and using the files map parameter passed into the method.
    *           Return the Peak_Response with message and success properties
    * Params : Map of files with values and Enrollment Affiliation Record ID
    * Task : #60442
    */

    @AuraEnabled
    public static Peak_Response submitDocuments(Map<String, String> files, Id affiliationId){

        Peak_Response peakResponse = NES_DocumentCentralHelper.insertDocuments(files, affiliationId);
        return peakResponse;
    }

    @AuraEnabled
    public static Peak_Response upsertEnrollmentDocuments(String enrollmentComponentAffiliationId, String enrollmentDocumentId,  List<String> documentLink){
        Peak_Response peakResponse = NES_DocumentCentralHelper.upsertDocumentsAndFileReferences(enrollmentComponentAffiliationId,enrollmentDocumentId, documentLink);
        return peakResponse;
    }

    @AuraEnabled
    public static Id grabSchool(Id enrollmentId) {
        return NES_QuestionsHelper.grabSchoolId(enrollmentId);
    }

    @AuraEnabled
    public static String grabNameOfStudent(Id studentId, Id programEnrollmentId) {
        return NES_EnrollmentUtils.getStudentName(studentId, programEnrollmentId);
    }
}