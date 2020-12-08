/**
* Purpose : NES_DocumentReviewUtils for getting next document for review from a flow
* Change Log:
*         2019-10-01 initial #US109913 (Andrew Sim)
*/
global class NES_DocumentReviewUtils {
    
    @InvocableMethod
    global static List<DocumentReviewResponse> getNextDocumentReviews(List<DocumentReviewRequest> requests) {
        List<DocumentReviewResponse> results = new List<DocumentReviewResponse>();
        for (DocumentReviewRequest request : requests) {
            results.add(getNextDocumentReview(request));
        }
        return results;
    }
    
    public static DocumentReviewResponse getNextDocumentReview(DocumentReviewRequest request) {
        DocumentReviewResponse result = new DocumentReviewResponse();
        
        // retrieve academic programs matching on educational institution and school year 
        List<Account> accounts = new List<Account>();
        if (request.schoolYears<>'') {
            accounts = [SELECT Id FROM Account 
                        WHERE ParentId = :request.educationalInstitution 
                        AND School_Year__c in :request.schoolYears.split('; ')];
        } else {
            accounts = [SELECT Id FROM Account 
                        WHERE ParentId = :request.educationalInstitution];
        }        
        if (accounts.size()==0) {
            result.nextId = null;
            result.size = 0;
            result.statusReason = 'No matching Academic Programs.';
            return result;
        } else {
            result.statusReason = accounts.size() + ' matching Academic Program(s)';
            result.statusReason += ' / ' + accounts;
        }
        
        // retrieve program enrollment with grade level match
        List<Id> programEnrollments = new List<Id>();
        List<hed__Program_Enrollment__c> peList = new List<hed__Program_Enrollment__c>();
        if (request.gradeLevels<>'') {
            peList = [SELECT Id, Household_Program_Enrollment__c
                                                       FROM hed__Program_Enrollment__c
                                                       WHERE hed__Account__c in :accounts
                                                       AND Program_Grade_Level__r.Grade_Level__r.Id in :request.gradeLevels.split('; ')];
        } else {
            peList = [SELECT Id, Household_Program_Enrollment__c
                                                       FROM hed__Program_Enrollment__c 
                                                       WHERE hed__Account__c in :accounts];
        }
        for (hed__Program_Enrollment__c obj : peList) {
            if (!programEnrollments.contains(obj.Id)) {
                programEnrollments.add(obj.Id);
            }
            if (obj.Household_Program_Enrollment__c != null && !programEnrollments.contains(obj.Household_Program_Enrollment__c)) {
                programEnrollments.add(obj.Household_Program_Enrollment__c);
            }   
        }
        if (programEnrollments.size()==0) {
            result.nextId = null;
            result.size = 0;
            result.statusReason += ' / No matching Program Enrollments.';
            return result;
        } else {
            result.statusReason += ' / ' + programEnrollments.size() + ' matching Program Enrollment(s)';
            result.statusReason += ' / ' + programEnrollments;
        }
        
        // retrieve document reviews
        List<Enrollment_Document__c> enrollmentDocuments = [SELECT Type__c, Program_Enrollment__c, Status_Reason__c, Document_Review__r.CreatedDate, Document_Review__r.Id, Document_Review__r.Status__c, Document_Review__r.Queue_Type__c 
                                                            FROM Enrollment_Document__c 
                                                            WHERE Program_Enrollment__c in :programEnrollments 
                                                            AND Document_Review__c IN (SELECT Id from Document_Review__c where Status__c in ('In Progress') and OwnerId = :request.queue) 
                                                            ORDER BY Document_Review__r.Pending_Review_Date__c];
        List<Id> documentReviews = new List<Id>();
        for (Enrollment_Document__c obj : enrollmentDocuments) {
            if (!documentReviews.contains(obj.Document_Review__r.Id)) {
                documentReviews.add(obj.Document_Review__r.Id);
            }
        }
        if (documentReviews.size()==0) {
            result.nextId = null;
            result.size = 0;
            result.statusReason += ' / No matching Document Reviews.';
            return result;
        } else {
            result.nextId = documentReviews[0];
            result.size = documentReviews.size();
            result.statusReason += ' / ' + documentReviews.size() + ' matching Document Review(s)';
            return result;
        }
        
    }
    
    global class DocumentReviewResponse {
        // 
        @InvocableVariable
        global ID nextId;
        
        //
        @InvocableVariable
        global Integer size;
        
        // 
        @InvocableVariable
        global String statusReason;
    }
    
    global class DocumentReviewRequest {
        // account
        @InvocableVariable(required=true) 
        global Id queue;
        
        // account
        @InvocableVariable(required=true) 
        global ID educationalInstitution;
        
        // school_years__c
        @InvocableVariable(required=false)
        global String schoolYears;
        
        // grade_levels__c
        @InvocableVariable(required=false)
        global String gradeLevels;
    }
}