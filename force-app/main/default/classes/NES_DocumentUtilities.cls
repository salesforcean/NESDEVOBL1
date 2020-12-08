public class NES_DocumentUtilities{

    public class DocumentData{
        @AuraEnabled public Id documentId {get;set;}
        @AuraEnabled public String documentStatus {get;set;}
        @AuraEnabled public String documentName {get;set;}
        @AuraEnabled public String documentMessage {get;set;}
        @AuraEnabled public String documentType{get;set;}
        @AuraEnabled public String type{get;set;}
        @AuraEnabled public String studentName{get;set;}
        @AuraEnabled public List<Enrollment_Component__c> messageEnrollmentComponents {get;set;}
        @AuraEnabled public List<Enrollment_Component__c> textEnrollmentComponents {get;set;}
        @AuraEnabled public List<String> enrollmentDocumentReasonMessages {get;set;}

        public DocumentData(Id documentId, String documentStatus, String documentName, String documentMessage, String documentType,
                            String type, String studentName, List<Enrollment_Component__c> messageEnrollmentComponents,
                List<Enrollment_Component__c> textEnrollmentComponents, List<String> enrollmentDocumentReasonMessages){

            this.documentId = documentId;
            this.documentStatus = documentStatus;
            this.documentName = documentName;
            this.documentMessage = documentMessage;
            this.documentType = documentType;
            this.type = type;
            this.studentName = studentName;
            this.messageEnrollmentComponents = messageEnrollmentComponents;
            this.textEnrollmentComponents = textEnrollmentComponents;
            this.enrollmentDocumentReasonMessages = enrollmentDocumentReasonMessages;
        }
    }

    /**Wrapper class for accessing Enrollment Document details on ligtning component.
     * - Change Log:
 -         2019-09-09 modified for User Story #102169 (Maddileti Boya) 
     */
    public class DocumentWrapper{
        @AuraEnabled public Integer numberOfAcceptedDocs;
        @AuraEnabled public Integer numberOfUnderReviewDocs;
        @AuraEnabled public Integer numberOfNeedsReviewDocs;
        @AuraEnabled public Integer numberOfDeferredDocs;/***** Modified 5/15/2020 by Vani User Story #171693*****/
         // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
         @AuraEnabled public Integer numberOfNotSubmittedDocs;
         @AuraEnabled public list<Enrollment_Component_Affiliation__c> ecaListStatus;
        // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        @AuraEnabled public Map<String, List<Enrollment_Document__c>> mapOfEnrollmentDocuments;
        @AuraEnabled public String studentName;
        @AuraEnabled public list<Enrollment_Component_Affiliation__c> ecaListStatusNotStarted;
    }

}