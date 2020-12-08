/**
 * Created by melindagrad on 1/19/19.
 *
 * Custom wrapper for Document_Reason_Message__mdt which queries MDT and returns as a wrapper--
 * this so we can create wrapper for testing because we cannot DML test MDTs
 */

public with sharing class NES_DocReasonMDTWrapper {
    private static Peak_ApexLog logger = new Peak_ApexLog('DocReasonMDTWrapper');

    //Get Enrollment Document Reason MDTs for with the given Enrollment Document Reason
    public static List<NES_DocReasonMDTWrapper.NES_DocReasonMessage> getDocReasonMDTS(Enrollment_Document__c theDocument) {

        List<NES_DocReasonMDTWrapper.NES_DocReasonMessage> enrollmentDocumentReasonMessages = new List<NES_DocReasonMDTWrapper.NES_DocReasonMessage>();

        try {

            //Query the Document_Reason_Message__mdt with the Enrollment_Document_Reason__c to get mapping
            List<Document_Reason_Message__mdt> documentReasonMessages = [
                    SELECT Id, Enrollment_Document_Reason__c, Message__c
                    FROM Document_Reason_Message__mdt
                    WHERE Enrollment_Document_Reason__c = :theDocument.Status_Reason__c
                    AND Document_Type__c = :theDocument.Type__c
            ];


            //If MDTs exist, create wrappers
            if (!Peak_Utils.isNullOrEmpty(documentReasonMessages)) {

                for (Document_Reason_Message__mdt theReasonMDT : documentReasonMessages) {

                    NES_DocReasonMessage theDocReasonWrapper = formatDocReasonMDTWrapper(theReasonMDT);
                    enrollmentDocumentReasonMessages.add(theDocReasonWrapper);
                }
            }

        } catch (Exception e) {
            logger.logException('getDocReasonMDTS', e);
            logger.saveLogs();
            System.debug('Caught Exception ' + e.getMessage());
        }

        //Return list of all MDTs as wrappers
        return enrollmentDocumentReasonMessages;
    }

    //Format the queried MDTs as wrappers
    public static NES_DocReasonMessage formatDocReasonMDTWrapper(Document_Reason_Message__mdt theReasonMDT) {

        NES_DocReasonMessage theDocReasonWrapper = new NES_DocReasonMessage();
        theDocReasonWrapper.message = theReasonMDT.Message__c;
        theDocReasonWrapper.enrollmentDocReason = theReasonMDT.Enrollment_Document_Reason__c;

        return theDocReasonWrapper;

    }

    //Inner class to wrap Document_Reason_Message__mdt
    public class NES_DocReasonMessage {

        @AuraEnabled public String enrollmentDocReason { get; set; }
        @AuraEnabled public String message { get; set; }

    }
}