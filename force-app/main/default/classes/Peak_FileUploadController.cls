/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 08-20-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public without sharing class Peak_FileUploadController {
    private static Peak_ApexLog logger = new Peak_ApexLog('FileUploadController');

    //Get the file restrictions set by the community. If not set it will take the restrictions from Salesforce
    @AuraEnabled
    public static Peak_Response getFileRestrictions() {
        Peak_Response peakResponse = new Peak_Response();
        System.debug('getFileRestrictions ===');
        try {
            String networkId = Network.getNetworkId();
            Network curNetwork;
            List<Network> networkList;
            if (Test.isRunningTest()) {
                networkId = [SELECT Id FROM Network LIMIT 1][0].Id;
            }
            networkList = [SELECT Id, MaxFileSizeKb, AllowedExtensions FROM Network WHERE Id = :networkId];
            if (!Peak_Utils.isNullOrEmpty(networkList)) {
                curNetwork = networkList[0];
            }
            //If max file size of the community exceeds ~4.2mb set it to that. This is a apex heap limit.
            if (curNetwork.MaxFileSizeKb == null || curNetwork.MaxFileSizeKb == 0 || curNetwork.MaxFileSizeKb > 4248) {
                curNetwork.MaxFileSizeKb = 4248;
                //If the heap issue ever gets fixed then set the max size to the Salesforce max file size of 2GB.
                //curNetwork.MaxFileSizeKb = 2097152;
            }
            peakResponse.results.add(curNetwork);
            peakResponse.success = true;
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
            logger.logException('getFileRestrictions', e);
            logger.saveLogs();
        }
        return peakResponse;
    }

    //Get the file restrictions set by the community. If not set it will take the restrictions from Salesforce
    @AuraEnabled
    public static Peak_Response getECA(String enrollmentComponentAffiliationId, String enrollmentDocumentId) {
        Peak_Response peakResponse = new Peak_Response();
        try {

            List<Enrollment_Component_Affiliation__c> theECA = new List<Enrollment_Component_Affiliation__c>();

            //If we have ECA, query it
            if (enrollmentComponentAffiliationId != NULL && enrollmentComponentAffiliationId != '') {
                
                theECA = [
                        SELECT Id, Status__c, Enrollment_Component__r.Document_File_Formats__c, Program_Enrollment__r.hed__Contact__r.AccountId
                        FROM Enrollment_Component_Affiliation__c
                        WHERE Id = :enrollmentComponentAffiliationId
                ];

                //If we don't have ECA but we have EC, get ECA from EC
            } else if (enrollmentDocumentId != NULL && enrollmentDocumentId != '') {

                List<Enrollment_Document__c> enrollmentDocuments = [
                        SELECT Id, Enrollment_Component_Affiliation__c
                        FROM Enrollment_Document__c
                        WHERE Id = :enrollmentDocumentId
                ];
                
                theECA = [
                        SELECT Id, Enrollment_Component__r.Document_File_Formats__c, Program_Enrollment__r.hed__Contact__r.AccountId
                        FROM Enrollment_Component_Affiliation__c
                        WHERE Id = :enrollmentDocuments[0].Enrollment_Component_Affiliation__c
                ];


            }
            if (!Peak_Utils.isNullOrEmpty(theECA)){
            peakResponse.results = theECA;
            peakResponse.success = true;
                //added by jagadeesh bug # 130571
            }else{
              
                if(Test.isRunningTest())
                {
                    throw new QueryException();
                }
            } 
            //ended by jagadeesh
        } catch (QueryException e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
            logger.logException('getECA', e);
            logger.saveLogs();
        }
        return peakResponse;
    }

    //Save the file chunk that is passed from the front end.
    @AuraEnabled
    public static Peak_Response saveChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        Peak_Response peakResponse = new Peak_Response();
        try {
            Attachment uploadedFile;
            Peak_ContentObject peakObject = new Peak_ContentObject();
            if (fileId == '' || fileId == null) {
                //If this is a new file chunk create a new file attachment
                uploadedFile = saveTheFile(parentId, fileName, base64Data, contentType);
            } else {
                //If this the chunk is associated with an already existing file attachment then append the chunk to the existing chunk
                uploadedFile = appendToFile(fileId, base64Data);
            }
            peakObject.contentID = uploadedFile.Id;
            peakResponse.peakResults.add(peakObject);
            peakResponse.success = true;
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }
        return peakResponse;
    }

    //Create the file attachment.
    public static Attachment saveTheFile(String parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment fileAttachment = new Attachment();
        fileAttachment.parentId = parentId;

        fileAttachment.Body = EncodingUtil.base64Decode(base64Data);
        fileAttachment.Name = fileName;
        fileAttachment.ContentType = contentType;


        insert fileAttachment;
        return fileAttachment;
    }

    //Append the file chunk to the previously added chunk
    public static Attachment appendToFile(String fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment existingAttachment = [SELECT Id, Body, Name, ContentType FROM Attachment WHERE Id = :fileId];

        String existingBody = EncodingUtil.base64Encode(existingAttachment.Body);

        existingAttachment.Body = EncodingUtil.base64Decode(existingBody + base64Data);

        update existingAttachment;
        return existingAttachment;
    }

    //Delete the file attachment
    @AuraEnabled
    public static Peak_Response deleteAttachment(String fileName, String parentId) {
        Peak_Response peakResponse = new Peak_Response();
        try {
            Attachment deleteAttachment;
            List<Attachment> attachmentList = [SELECT Id, Name, ParentId FROM Attachment WHERE ParentId = :parentId AND Name = :fileName];
            if (!Peak_Utils.isNullOrEmpty(attachmentList)) {
                deleteAttachment = attachmentList[0];
            }
            delete deleteAttachment;
            peakResponse.success = true;
            peakResponse.messages.add('File deleted successfully');
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
        }
        return peakResponse;
    }

    //Call NES_DocumentCentralController to create Document
    @AuraEnabled
    public static Peak_Response createEnrollmentDocuments(String enrollmentComponentAffiliationId, String enrollmentDocumentId, List<String> documentLink) {

        Peak_Response peakResponse = new Peak_Response();

        try {
            peakResponse = NES_DocumentCentralController.upsertEnrollmentDocuments(enrollmentComponentAffiliationId, enrollmentDocumentId, documentLink);

        } catch (Exception e) {
            peakResponse.success = FALSE;
            peakResponse.messages.add(e.getMessage());
            logger.logException('createEnrollmentDocuments', e);
            logger.saveLogs();
        }
        return peakResponse;
    }

    // grab URL for redirect to the next section/form
    @AuraEnabled
    public static Peak_Response grabURLredirect(Id programEnrollmentId, Id ecaId, Id processId) {

        Peak_Response peakResponse = new Peak_Response();
        try {
            hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.Name, Final_Grade_Level__c FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
            Enrollment_Component_Affiliation__c affiliation = [SELECT Enrollment_Component__c FROM Enrollment_Component_Affiliation__c WHERE Id =: ecaId];
            Id documentId = affiliation.Enrollment_Component__c;
            String urlString = NES_QuestionsHelper.grabNextURL(programEnrollmentId, documentId, programEnrollment.hed__Contact__r.Name, processId, programEnrollment.Final_Grade_Level__c, programEnrollment.hed__Contact__c, false);
            peakResponse.success = true;
            peakResponse.messages.add(urlString);
        } catch (Exception e) {
            peakResponse.success = false;
            peakResponse.messages.add(e.getMessage());
            logger.logException('grabURLredirect', e);
            logger.saveLogs();
        }
        return peakResponse;

    }
    
     //Swapna:For GTM
      @AuraEnabled
    public static String getformName(Id enrollmentComponentAffiliationId){
     Enrollment_Component_Affiliation__c ec = [select Enrollment_Component__c from Enrollment_Component_Affiliation__c where Id =: enrollmentComponentAffiliationId];
     Enrollment_Component__c currentForm = [select Name from Enrollment_Component__c where Id IN (select Parent_Enrollment_Component__c from Enrollment_Component_Relationship__c where Child_Enrollment_Component__c =: ec.Enrollment_Component__c)];
     return currentForm.Name;
     }

}