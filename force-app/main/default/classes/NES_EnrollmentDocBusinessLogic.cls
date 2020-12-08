/**
* Created by Anushka on 22-11-2018.
* Purpose : BusinessLogic class for EnrollmentDocumentTrigger called by EnrollmentDocumentHandler.
*Change Log:
*         2019-08-14 initial for #101932 User Story (Chinnamanaidu Neerasa)
*         2019-08-30 for #101932 User Story (Chinnamanaidu Neerasa)
*         2019-09-05 for #101932 User Story (Chinnamanaidu Neerasa)
*         2019-09-06 for #101932 User Story (Chinnamanaidu Neerasa)
*         2019-09-10 for #101932/Bug 106310 User Story (Chinnamanaidu Neerasa)
*         2019-09-10 for #107180 User Story (Task 108660) on 2019-09-10(Anitha P)
*         2019-09-17 for #101932/Bug 108433 (Chinnamanaidu Neerasa)
*         2019-10-01 for #110763 User Story (Chinnamanaidu Neerasa)
*         2019-11-18 for #113765 User Story (Chinnamanaidu Neerasa)
*		  [2020-02-12 : ALI KM : US 135435] - Bug/Enhancement related changes made to reviewDocumentsBefore_Insert() method.
*		  [2020-02-23 : Krishna Peddanagammol : US 125320] - Enhancement related changes made to updateDocumentECAStatus() method.
**/

public class NES_EnrollmentDocBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('EnrollmentDocBusinessLogic');
    
    /**
* Created by Anushka on 22-11-2018.
* Purpose : This method takes the Program Enrollment Ids of all the newly inserted/updated Enrollment Document records.
* The Program Enrollment Ids are then passed to NES_AnnualStudentInformationUtilities class to
* recalculate the Recommended Auto-Placement on the related current Annual student Information record.
*/
    public static void calculatePlacement(List < Enrollment_Document__c > newList, Map < Id, Enrollment_Document__c > oldMap) {
        System.debug('In Enrollment Document Business logic');
        Set<Id> programEnrollmentIds = new Set<Id>();
        if (oldMap != null) {
            for (Enrollment_Document__c ed : newList) {
                if (ed.Status_Reason__c != oldMap.get(ed.Id).Status_Reason__c) {
                    programEnrollmentIds.add(ed.Program_Enrollment__c);
                }
            }
        } else {
            for (Enrollment_Document__c ed : newList) {
                programEnrollmentIds.add(ed.Program_Enrollment__c);
            }
            
        }
        
        
        if (programEnrollmentIds.size() > 0) {
            List<Annual_Student_Information__c> asis = [SELECT Id, Program_Enrollment__c FROM Annual_Student_Information__c WHERE Program_Enrollment__c IN : programEnrollmentIds];
            NES_AnnualStudentInfoBusinessLogic.verifyAffiliationsComplete(asis);
        }
    }
    
    /**
* Created by Raju on 26-11-2018.
* Purpose : This method is used to create a Document Review record for Enrollment Document automatically,
*           If there is an existing Document Review record found it checks the  correct Status, Household, Academic Program and Queue 
*           to be existing otherwise create a Document Review record  
*/
    
    public static void reviewDocumentsBefore_Insert(List < Enrollment_Document__c > newList) {
        System.debug('Enrollment Document before insert');
        //Get the set of Program Enrollment ids related to Enrollment Document
        //Mark Membrino 5/21/2020  We don't want doc review records if these are being loaded from a data load.
        Set < Id > peIdset = new Set < Id > ();
        for (Enrollment_Document__c ecDocument : newList) {
            if (ecDocument.Program_Enrollment__c != null && String.isBlank(ecDocument.V2_External_Id__c)) {
                peIdset.add(ecDocument.Program_Enrollment__c);
            }
        }

        if (peIdset.size() == 0)
            return;

        //Query all Program Enrollment records related to Enrollment Documents
        Map < Id, hed__Program_Enrollment__c > programEnrollmentMap = new Map < Id, hed__Program_Enrollment__c > (
        		[SELECT Id, hed__Account__c, hed__Contact__r.AccountId FROM hed__Program_Enrollment__c WHERE Id IN:peIdset]);
        System.debug('programEnrollmentMap ::' + programEnrollmentMap);
        
        //Alex C - Added to limit query results to just relevant households
        list<Id> accountIDs = new list<Id>();
        for(hed__Program_Enrollment__c updatedPE : programEnrollmentMap.values()){
        	accountIDs.add(updatedPE.hed__Contact__r.AccountId);
        }
        
        //Query all Document Review records from Database.This can be used to get the First Occurance of the given combination of Document Review record with EnrollmentDocument record
        Map < Id, Document_Review__c > documentReviewMap = new Map < Id, Document_Review__c > 
        ([SELECT Id, Academic_Program__c, Household__c, Queue_Type__c, Status__c FROM Document_Review__c WHERE Household__c IN: accountIDs LIMIT 49999]);
        System.debug('documentReviewMap ::' + documentReviewMap);
        //Query All Metadata records to map Document Type to queue
        List < Map_DocumentType_Queue__mdt > documentTypeToQueueList = [SELECT Document_Type__c, Queue__c FROM Map_DocumentType_Queue__mdt];
        
        Map < String, String > documentTypeToQueueMap = new Map < String, String > ();
        
        Set<String> queueNames = new Set<String>();
        for (Map_DocumentType_Queue__mdt mdtRec : documentTypeToQueueList) {
            documentTypeToQueueMap.put(mdtRec.Document_Type__c, mdtRec.Queue__c);
            queueNames.add(mdtRec.Queue__c.replaceAll('-', '_'));
        }
        
        List<Group> documentOwnerQueues = [SELECT Id, Name,DeveloperName, Type FROM Group WHERE Type = 'Queue' AND DeveloperName = :queueNames];
        Map<String, Id> queueNameToIdMap = new Map<String, Id>();
        for (Group theQueue : documentOwnerQueues) {
            queueNameToIdMap.put(theQueue.DeveloperName, theQueue.Id);
        }
        
        //Iterate each enrollment document and find the any existing document review record found or not with the below combination defined as key.
        
        Map < Id, Document_Review__c > enrollDocumentToDocumentReviewMap = new Map < Id, Document_Review__c > ();
        
        List < Document_Review__c > createDocumentReviewList = new List < Document_Review__c > ();
        Set < Id > alreadystampedEDRecordsSet = new Set < Id > ();

        // [Ali KM : 2/12/2020 : Changes for Bug# 135435]
        String validEDStatus = 'In Progress, Complete';
        String defaultEDStatus = 'In Progress';
        List<Document_Review__c> toUpdateDocReviews = new List<Document_Review__c>();
        // [Ali KM : 2/12/2020 : Changes for Bug# 135435 : END]

        for (Enrollment_Document__c edRecord : newList) {
            hed__Program_Enrollment__c programEnrollmentRecord = programEnrollmentMap.get(edRecord.Program_Enrollment__c);
            String queue = documentTypeToQueueMap != null && documentTypeToQueueMap.containsKey(edRecord.Type__c) ? documentTypeToQueueMap.get(edRecord.Type__c) : '';
            
            // [Ali KM : 2/10/2020 : Changes for Bug# 135435]
            // String key = 'In Progress' + programEnrollmentRecord.hed__Account__c + programEnrollmentRecord.hed__Contact__r.AccountId + queue;
            String key = '' + programEnrollmentRecord.hed__Account__c + programEnrollmentRecord.hed__Contact__r.AccountId + queue;
            // [Ali KM : 2/10/2020 : Changes for Bug# 135435 : END]
            
            System.debug('key1:: ' + key);
            System.debug('key ap account:: ' + programEnrollmentRecord.hed__Account__c);
            System.debug('key hh:: ' + programEnrollmentRecord.hed__Contact__r.AccountId);
            System.debug('key queue:: ' + queue);
            //If document review record is not populated on Enrollment document get all document review records check with the key if any match found pick the record assign to this enrollment document.
            if (edRecord.Document_Review__c == null) {
                //do we need to check all existing records with the combination defined in the key. if we found any combination do need to use the first occurance. or do we need to create new document review.
                Id idForStamping;
                for (Document_Review__c drRecord : documentReviewMap.values()) {
                    String queuetype = drRecord.Queue_Type__c != null ? drRecord.Queue_Type__c : '';
                    
                    // [Ali KM : 2/10/2020 : Changes for Bug# 135435]
                    // String validatekey = drRecord.Status__c + drRecord.Academic_Program__c + drRecord.Household__c + queuetype; 
                    String validatekey = '' + drRecord.Academic_Program__c + drRecord.Household__c + queuetype; 
                    // [Ali KM : 2/10/2020 : Changes for Bug# 135435 : END]
                    
                    System.debug('validatekey1:: ' + validatekey);
                    System.debug('validatekey Status__c:: ' + drRecord.Status__c);
                    System.debug('validatekey Academic_Program__c:: ' + drRecord.Academic_Program__c);
                    System.debug('validatekey Household__c:: ' + drRecord.Household__c);
                    System.debug('validatekey Queue_Type__c:: ' + drRecord.Queue_Type__c);
                    
                    // [Ali KM : 2/10/2020 : Changes for Bug# 135435]
                    // if (key.equalsIgnoreCase(validatekey)) {
                    if(drRecord.Status__c != null){ //Alex C - Added to resolve null pointer exceptions related to null status values
                        if (validEDStatus.containsIgnoreCase(drRecord.Status__c) && key.equalsIgnoreCase(validatekey)) {
                            // [Ali KM : 2/10/2020 : Changes for Bug# 135435 : END]                        
                                idForStamping = drRecord.Id;
                                break;
                            }
                    }
                }
                if (idForStamping == null) {
                    //create instance for Document review records.
                    Document_Review__c drRecord = new Document_Review__c();
                    drRecord.Status__c = 'In Progress';
                    drRecord.Household__c = programEnrollmentRecord.hed__Contact__r.AccountId;
                    drRecord.Academic_Program__c = programEnrollmentRecord.hed__Account__c;
                    drRecord.Queue_Type__c = queue;
                    drRecord.OwnerId = queueNameToIdMap.get(queue.replaceAll('-', '_'));
                    System.debug('drRecord.Status__c :: ' + drRecord.Status__c);
                    System.debug('drRecord.Household__c::' + drRecord.Household__c);
                    System.debug('drRecord.Academic_Program__c::' + drRecord.Academic_Program__c);
                    System.debug('drRecord.Queue_Type__c :: ' + drRecord.Queue_Type__c);
                    createDocumentReviewList.add(drRecord);
                    
                } else {
                    System.debug('The id was null');
                    edRecord.Document_Review__c = idForStamping;
                    alreadystampedEDRecordsSet.add(edRecord.id);

                    // [Ali KM : 2/12/2020 : Changes for Bug# 135435 : END]
                    toUpdateDocReviews.add(new Document_Review__c(id=idForStamping, Status__c = defaultEDStatus));
                    // [Ali KM : 2/12/2020 : Changes for Bug# 135435]
                }
            } else {
                if (documentReviewMap != null && documentReviewMap.containsKey(edRecord.Document_Review__c) && documentReviewMap.get(edRecord.Document_Review__c) != null) {
                    Document_Review__c documentReviewRecord = documentReviewMap.get(edRecord.Document_Review__c);

                    // [Ali KM : 2/10/2020 : Changes for Bug# 135435]
                    // String validatekey = documentReviewRecord.Status__c + documentReviewRecord.Academic_Program__c + documentReviewRecord.Household__c + documentReviewRecord.Queue_Type__c;
                    String validatekey = '' + documentReviewRecord.Academic_Program__c + documentReviewRecord.Household__c + documentReviewRecord.Queue_Type__c;
                    Id idForStamping;
                    // if (key.equalsIgnoreCase(validatekey)) {
                    if (validEDStatus.containsIgnoreCase(documentReviewRecord.Status__c) && key.equalsIgnoreCase(validatekey)) {
                        idForStamping = documentReviewRecord.Id;
                    }
                    // [Ali KM : 2/10/2020 : Changes for Bug# 135435 : END]
                    
                    if (idForStamping == null) {
                        //create instance for Document review records.
                        Document_Review__c drRecord = new Document_Review__c();
                        drRecord.Status__c = 'In Progress';
                        drRecord.Household__c = programEnrollmentRecord.hed__Contact__r.AccountId;
                        drRecord.Academic_Program__c = programEnrollmentRecord.hed__Account__c;
                        drRecord.Queue_Type__c = queue;
                        createDocumentReviewList.add(drRecord);
                        System.debug('drRecord.Status__c :: ' + drRecord.Status__c);
                        System.debug('drRecord.Household__c::' + drRecord.Household__c);
                        System.debug('drRecord.Academic_Program__c::' + drRecord.Academic_Program__c);
                        System.debug('drRecord.Queue_Type__c :: ' + drRecord.Queue_Type__c);
                    } else {
                        edRecord.Document_Review__c = idForStamping;
                        alreadystampedEDRecordsSet.add(edRecord.id);

                        // [Ali KM : 2/12/2020 : Changes for Bug# 135435]
                        toUpdateDocReviews.add(new Document_Review__c(id=idForStamping, Status__c = defaultEDStatus));
                        // [Ali KM : 2/12/2020 : Changes for Bug# 135435 : END]
                    }
                }
            }
            
        }

        // [ALI KM]
        if (toUpdateDocReviews.size() > 0) {
            System.debug('::ALIKM::toUpdateDocReviews::' + JSON.serialize(toUpdateDocReviews));
            try {
                update toUpdateDocReviews;
            } catch (Exception ex) {System.debug('Error: ' + ex.getMessage());logger.logException('reviewDocumentsBefore_Insert', ex);logger.saveLogs(); }
        }
        // [ALI KM ]
        
        
        if (createDocumentReviewList.size() > 0) {
            Set < Id > insertedDocumentReviewRecordIdSet = new Set < Id > ();
            Database.SaveResult[] srList;
            try {
                srList = Database.insert(createDocumentReviewList, false);
            } catch (Exception e) {System.debug('EXCEPTION THROWN =======' + e.getMessage());logger.logException('reviewDocumentsBefore_Insert', e);logger.saveLogs();}
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was inserted
                    insertedDocumentReviewRecordIdSet.add(sr.getId());
                    system.debug('Record inserted' + insertedDocumentReviewRecordIdSet);
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error err : sr.getErrors()) {
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Document Review fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            //Get all document review records which are created in the above step.
            if (insertedDocumentReviewRecordIdSet.size() > 0) {
                Map < Id, Document_Review__c > insertedAndExistingdocumentReviewMap = new Map < Id, Document_Review__c > ([SELECT Id, Academic_Program__c, Household__c, Queue_Type__c, Status__c FROM Document_Review__c WHERE Id IN:insertedDocumentReviewRecordIdSet]);
                
                List < Enrollment_Document__c > finalEnrollmentDocumentsUpdateList = new List < Enrollment_Document__c > ();
                for (Enrollment_Document__c edRecord : newList) {
                    System.debug('edRecord ::' + edRecord);
                    if (alreadystampedEDRecordsSet.contains(edRecord.Id)) {
                        continue;
                    }
                    
                    hed__Program_Enrollment__c programEnrollmentRecord = programEnrollmentMap.get(edRecord.Program_Enrollment__c);
                    String queue = documentTypeToQueueMap != null && documentTypeToQueueMap.containsKey(edRecord.Type__c) ? documentTypeToQueueMap.get(edRecord.Type__c) : '';
                    
                    String key = 'In Progress' + programEnrollmentRecord.hed__Account__c + programEnrollmentRecord.hed__Contact__r.AccountId + queue;
                    system.debug('key:: ' + key);
                    system.debug('key ap account:: ' + programEnrollmentRecord.hed__Account__c);
                    system.debug('key hh:: ' + programEnrollmentRecord.hed__Contact__r.AccountId);
                    system.debug('key queue:: ' + queue);
                    
                    //do we need to check all existing records with the combination defined in the key. if we found any combination do need to use the first occurance. or do we need to create new document review.
                    for (Document_Review__c drRecord : insertedAndExistingdocumentReviewMap.values()) {
                        String queuetype = drRecord.Queue_Type__c != null ? drRecord.Queue_Type__c : '';
                        String validatekey = drRecord.Status__c + drRecord.Academic_Program__c + drRecord.Household__c + queuetype;
                        system.debug('validatekey:: ' + validatekey);
                        system.debug('validatekey Status__c:: ' + drRecord.Status__c);
                        system.debug('validatekey Academic_Program__c:: ' + drRecord.Academic_Program__c);
                        system.debug('validatekey Household__c:: ' + drRecord.Household__c);
                        system.debug('validatekey Queue_Type__c:: ' + drRecord.Queue_Type__c);
                        if (key.equalsIgnoreCase(validatekey)) {
                            System.debug('edRecord.Id' + edRecord.id + 'Document_Review__c###' + drRecord.Id);
                            // Enrollment_Document__c enrollmentDocumentRecord = new Enrollment_Document__c();
                            //enrollmentDocumentRecord.Id = edRecord.id;
                            edRecord.Document_Review__c = drRecord.Id;
                            finalEnrollmentDocumentsUpdateList.add(edRecord);
                            break;
                        }
                    }
                    
                }
                
                if (finalEnrollmentDocumentsUpdateList.size() > 0) {
                    try {
                        // update finalEnrollmentDocumentsUpdateList;
                    } catch (Exception ex) {system.debug('Error: ' + ex.getMessage());logger.logException('reviewDocumentsBefore_Insert', ex);logger.saveLogs();}
                }
                
            }
        }
        
    }
    /**
* Created By Anand on 12/6/2018
*purpose To Update DateReviewed Field  when Enrollment_Document.Status(new) != Enrollment_Document.Status (old) and
*Enrollment_Document.Status (old) = Submitted
* @param newMap
* @param oldMap
*/
    
    public static void updateDateReviewed(Map < Id, Enrollment_Document__c > newMap, Map < Id, Enrollment_Document__c > oldMap) {
        for (Id docId : oldMap.keySet()) {
            if ((oldMap.get(docId).Status_Reason__c != newMap.get(docId).Status_Reason__c) && oldMap.get(docId).Status_Reason__c == 'Submitted') {
                newMap.get(docId).Date_Reviewed__c = System.now();
            }
        }
        
    }
    /**
* Created By Anand on 12/6/2018
*purpose To Update Doc Status Field
* @param newMap
* @param oldMap
*/
    public static void updateDocumentStatus(List<Enrollment_Document__c> enrollmentDocList, Map < Id, Enrollment_Document__c > newMap, Map < Id, Enrollment_Document__c > oldMap) {
        System.debug('In Update Document Status++++++');
        Set <Id> documentIds = new Set <Id> ();
        if (enrollmentDocList <> null && !enrollmentDocList.isEmpty()) {
            for (Enrollment_Document__c enDoc : enrollmentDocList) {
                // if  HHORStatus is true and doc type is proof of residence
                if (enDoc.Type__c <> Null && NES_LogicFeatureSwitch__c.getValues('HHPORStatus') <> Null && !String.isBlank(enDoc.Type__c) && enDoc.Type__c == 'Proof of Residence' &&
                    NES_LogicFeatureSwitch__c.getValues('HHPORStatus').Active__c == True) {
                        
                        documentIds.add(enDoc.Id);
                    }
            }
        } else if (!newMap.isEmpty() && !oldMap.isEmpty() && newMap <> null && oldMap <> null) {
            for (Id docId : oldMap.keyset()) {
                // if  HHORStatus is true and old status not equals to new status and if odc type is proof of residence
                if ((newMap.get(docId).Type__c <> Null && NES_LogicFeatureSwitch__c.getValues('HHPORStatus') <> Null && !String.isBlank(newMap.get(docId).Type__c)) &&
                    newMap.get(docId).Type__c == 'Proof of Residence' && newMap.get(docId).Status_Reason__c != oldMap.get(docId).Status_Reason__c &&
                    NES_LogicFeatureSwitch__c.getValues('HHPORStatus').Active__c == True) {
                        documentIds.add(docId);
                    }
            }
        }
        if (!documentIds.isEmpty()) {
            System.debug('In documentIds+++');
            NES_BusinessLogicUtils.calculateHHPORStatus(documentIds);
        }
        
    }
    
    public static void insertDocECAStatus(List<Enrollment_Document__c> newDocs) {
        
        List<Id> affiliationIds = new List<Id>();
        List<Id> householdEnrollmentIds = new List<Id>();
        List<Id> componentIds = new List<Id>();
        
        for (Enrollment_Document__c newDoc : newDocs) {
            affiliationIds.add(newDoc.Enrollment_Component_Affiliation__c);
        }
        
        List<Enrollment_Component_Affiliation__c> docAffiliations = [
            SELECT Id, Status__c, Enrollment_Component__r.Component_Type__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c, Enrollment_Component__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Id IN :affiliationIds
            AND Status__c != 'Completed'];
        
        for(Enrollment_Component_Affiliation__c docAffiliation : docAffiliations) {
            if(docAffiliation.Enrollment_Component__r.Component_Type__c == 'Household') {
                householdEnrollmentIds.add(docAffiliation.Program_Enrollment__r.Household_Program_Enrollment__c);
            }
            componentIds.add(docAffiliation.Enrollment_Component__c);
        }
        if(householdEnrollmentIds.size() > 0) {
            List<Enrollment_Component_Affiliation__c> additionalDocAffiliations = [
                SELECT Id, Status__c, Enrollment_Component__r.Component_Type__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c, Enrollment_Component__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__r.Household_Program_Enrollment__c IN : householdEnrollmentIds
                AND Enrollment_Component__c IN : componentIds
                AND Status__c = 'Not Started'
            ];
            
            System.debug(additionalDocAffiliations);
            docAffiliations.addAll(additionalDocAffiliations);
        }
        
        //Create some variables to work with
        Set<Enrollment_Component_Affiliation__c> affiliationsForUpdate = new Set<Enrollment_Component_Affiliation__c>();
        List<Id> programEnrollmentIds = new List<Id>();
        
        // Mark all the document affiliations complete
        for (Enrollment_Component_Affiliation__c affiliation : docAffiliations) {
            affiliation.Status__c = 'In Progress';
            affiliationsForUpdate.add(affiliation);
            programEnrollmentIds.add(affiliation.Program_Enrollment__c);
        }
        
        
        //Grab all the document relationships and put the child, parent in a map
        List<Enrollment_Component_Relationship__c> docRelationships = [
            SELECT Id, Parent_Enrollment_Component__c, Child_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Child_Enrollment_Component__c IN :componentIds];
        Set<Id> parentFormIds = new Set<Id>();
        for (Enrollment_Component_Relationship__c docRelationship : docRelationships) {
            parentFormIds.add(docRelationship.Parent_Enrollment_Component__c);
        }
        
        List<hed__Program_Enrollment__c> programEnrollments = [
            SELECT Id, hed__Contact__c, hed__Contact__r.RecordType.Name
            FROM hed__Program_Enrollment__c
            WHERE Id IN :programEnrollmentIds OR Household_Program_Enrollment__c IN :programEnrollmentIds
        ];
        
        Map<Id, List<Enrollment_Component_Affiliation__c>> peECAMap = new Map<Id, List<Enrollment_Component_Affiliation__c>>();
        for (Enrollment_Component_Affiliation__c affiliation : docAffiliations) {
            
            List<Enrollment_Component_Affiliation__c> tempAffiliations = new List<Enrollment_Component_Affiliation__c>();
            if (peECAMap.keySet().contains(affiliation.Program_Enrollment__c)) {
                tempAffiliations = peECAMap.get(affiliation.Program_Enrollment__c);
            }
            tempAffiliations.add(affiliation);
            peECAMap.put(affiliation.Program_Enrollment__c, tempAffiliations);
        }
        
        Map<Id, Map<Id, Enrollment_Component_Affiliation__c>> peStudentAffiliationMap = new Map<Id, Map<Id, Enrollment_Component_Affiliation__c>>();
        for (Id peId : peECAMap.keySet()) {
            Map<Id, Enrollment_Component_Affiliation__c> studentAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
            List<Enrollment_Component_Affiliation__c> studentAffiliations = peECAMap.get(peId);
            for (Enrollment_Component_Affiliation__c studentAffiliation : studentAffiliations) {
                if(!studentAffiliationMap.containsKey(studentAffiliation.Enrollment_Component__c)){
                    studentAffiliationMap.put(studentAffiliation.Enrollment_Component__c, studentAffiliation);
                    
                }
                
            }
            peStudentAffiliationMap.put(peId, studentAffiliationMap);
            system.debug('studentAffiliationMap==>'+studentAffiliationMap);
            //put current parent forms in progress
            for (Id parentFormId : parentFormIds) {
                system.debug('parentFormId==>'+parentFormId);
                //
                if (studentAffiliationMap.containsKey(parentFormId)) {
                    system.debug('called the logic');
                    Enrollment_Component_Affiliation__c formAffiliation = studentAffiliationMap.get(parentFormId);
                    formAffiliation.Status__c = 'In Progress';
                    affiliationsForUpdate.add(formAffiliation);
                }
            }
        }
        try {
            List<Enrollment_Component_Affiliation__c> affiliationListToUpdate = new List<Enrollment_Component_Affiliation__c>();
            affiliationListToUpdate.addAll(affiliationsForUpdate);
            update affiliationListToUpdate;
        } catch (Exception e) {System.debug(e.getMessage());logger.logException('insertDocECAStatus', e);logger.saveLogs(); }
        
    }
    
    public static void updateDocECAStatus(Map <Id, Enrollment_Document__c> newMap) {
        
        System.debug('Updating ECA doc status');
        //Grab all the affiliations for these documents
        List<Id> affiliationIds = new List<Id>();
        
        // Bug number 108461- If the ED status reason is updated to "Deferred-Verified-In progress" or "Invalid-Incomplete Exemption" 
        // the corresponding ECA status should set 'In Progress".Earlier status is setting to 'Complete' status. 
        for (Enrollment_Document__c enrollmentDocument : newMap.values()) {
            if (!String.isEmpty(enrollmentDocument.Status_Reason__c) && !enrollmentDocument.Status_Reason__c.Contains('Invalid')&&!enrollmentDocument.Status_Reason__c.Contains('Deferred')&&
                (enrollmentDocument.Status_Reason__c.indexOf('Verified') > -1 ||
                 // Bug number 102882 - Removed the below two conditions. Chinnamananaidu Neerasa August 12,2019
                 //enrollmentDocument.Status_Reason__c.indexOf('Received') > -1 ||
                 //enrollmentDocument.Status_Reason__c.indexOf('Reviewed') > -1 ||
                 //Story # 101932 - When ED status set to 'Not Applicable' status, ECA status should set to 'Complete' 
                 enrollmentDocument.Status_Reason__c.indexOf('Not Applicable') > -1 ||
                   //Bug # 109615 - When ED status set to 'Deferred' status, ECA status should set to 'Complete' 
                 enrollmentDocument.Status_Reason__c.indexOf('Deferred') > -1 ||
                 enrollmentDocument.Status_Reason__c.indexOf('Exemption') > -1))  {
                     affiliationIds.add(enrollmentDocument.Enrollment_Component_Affiliation__c);
                 }
        }
        
        if (affiliationIds.size() > 0) {
            List<Enrollment_Component_Affiliation__c> docAffiliations = [
                SELECT Id, Status__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c,
                Enrollment_Component__c, Enrollment_Component__r.Component_Type__c
                FROM Enrollment_Component_Affiliation__c WHERE Id IN :affiliationIds AND Status__c != 'Complete'];
            
            List<Id> householdEnrollmentIds = new List<Id>();
            List<Id> componentIds = new List<Id>();
            
            for(Enrollment_Component_Affiliation__c docAffiliation : docAffiliations) {
                householdEnrollmentIds.add(docAffiliation.Program_Enrollment__r.Household_Program_Enrollment__c);
                if(docAffiliation.Enrollment_Component__r.Component_Type__c == 'Household') {
                    componentIds.add(docAffiliation.Enrollment_Component__c);
                }
            }
            List<Enrollment_Component_Affiliation__c> additionalDocAffiliations = [SELECT Id, Status__c, Program_Enrollment__c, Enrollment_Component__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__r.Household_Program_Enrollment__c IN : householdEnrollmentIds
                AND Enrollment_Component__c IN : componentIds AND Status__c != 'Complete'];
            docAffiliations.addAll(additionalDocAffiliations);
            
            //Create some variables to work with
            Map<Id, Enrollment_Component_Affiliation__c> affiliationsForUpdate = new Map<Id, Enrollment_Component_Affiliation__c>();
            List<Id> programEnrollmentIds = new List<Id>();
            List<Id> docComponentIds = new List<Id>();
            
            // Mark all the document affiliations complete
            for (Enrollment_Component_Affiliation__c affiliation : docAffiliations) {
                affiliation.Status__c = 'Complete';
                affiliationsForUpdate.put(affiliation.Id, affiliation);
                programEnrollmentIds.add(affiliation.Program_Enrollment__c);
                docComponentIds.add(affiliation.Enrollment_Component__c);
            }

            // Additional check to handle new ECA Model
            Map<Id, hed__Program_Enrollment__c> mapPEs = queriedPEs(programEnrollmentIds);
            hed__Program_Enrollment__c queriedPE;
            for (Enrollment_Component_Affiliation__c eca : affiliationsForUpdate.values())
            {
                queriedPE = mapPEs.get(eca.Program_Enrollment__c);
                if (queriedPE!=null && queriedPE.hed__Account__r.Use_Updated_ECA_Process__c)
                {
                    // trigger parentHierarchy Status update
                    eca.Is_Dirty__c = true;

                }
            }
            
            try {

                List<Enrollment_Component_Affiliation__c> affiliationListToUpdate = new List<Enrollment_Component_Affiliation__c>();
                affiliationListToUpdate.addAll(affiliationsForUpdate.values());
                update affiliationListToUpdate;
                
                for (Id peId : programEnrollmentIds) {
                    if (mapPEs.containsKey(peId) && mapPEs.get(peId).hed__Account__r.Use_Updated_ECA_Process__c==false)
                        System.enqueueJob(new NES_CompletionQueueable(peId, null));
                }
                
            } catch (Exception e) {
                System.debug(e.getMessage());
                logger.logException('updateDocECAStatus', e); 
                logger.saveLogs(); 
            }
        }
        
    }
    
/**
* Created by Raju on 11/12/18.
* Purpose : Method is used to Set Program_Enrollment__c.DocumentUploadDate__c to Enrollment_Document__c.CreatedDate
*/
    public static void updateLastDocUploadDateOnInsert(List < Enrollment_Document__c > enrollmentDocList) {
        
        NES_LogicFeatureSwitch__c logicSwitch = NES_LogicFeatureSwitch__c.getInstance('Last Document Upload Date');
        if (logicSwitch <> Null && logicSwitch.Active__c) {
            NES_BusinessLogicUtils.updateLastDocUploadDate(enrollmentDocList);
        }
        
    }
    
    /**
* Task number 104355- Created by Chinnamanaidu Neerasa on 12/08/19.
* Purpose : Method is used to Set status to 'In Progress' in ECA, when the Enrollment Doc status changed from 'Verified' OR 'Exemption' to any other statuses.
*/
    
    public static void updateDocumentECAStatus(Map <Id, Enrollment_Document__c> newMap, Map<Id, Enrollment_Document__c> oldMap) {
        
        List<Id> affiliationIds = new List<Id>();
        // Optimized for US #125320 (Krishna Peddanagammol) on 2020-04-21
        if (newMap.size()> 0){
            for (Enrollment_Document__c enrollmentDocument : newMap.values()) {
                if (oldmap.size() > 0){
                    if (!String.isEmpty(newMap.get(enrollmentDocument.Id).Status_Reason__c) && !String.isEmpty(oldMap.get(enrollmentDocument.Id).Status_Reason__c)){
                        if (oldMap.get(enrollmentDocument.Id).Status_Reason__c != newMap.get(enrollmentDocument.Id).Status_Reason__c){
                            if (oldMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Verified' )  && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Exemption') && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Verified')
                            && (oldMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Verified') && newMap.get(enrollmentDocument.Id).Status_Reason__c !='Not Applicable' && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Verified'))
                            || ((oldMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Exemption') && newMap.get(enrollmentDocument.Id).Status_Reason__c !='Not Applicable' && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Exemption')) 
                                && (oldMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Exemption')   && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Verified') && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Exemption')))
                            || (oldMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Not Applicable') && !newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Verified') && !enrollmentDocument.Status_Reason__c.startsWith('Exemption')) 
                            || (oldMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Deferred') && newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Invalid')))
                            {
                                affiliationIds.add(enrollmentDocument.Enrollment_Component_Affiliation__c);                    
                            } 
                        }
                    }
                }
                // Implemented for US #125320 (Krishna Peddanagammol) on 2020-04-21
                // Added code for US #168067 on 2020-04-30
                if (!String.isEmpty(newMap.get(enrollmentDocument.Id).Status_Reason__c)) {
                    if(newMap.get(enrollmentDocument.Id).Status_Reason__c.startsWith('Pending') ){  //  MM Removed. || newMap.get(enrollmentDocument.Id).Status_Reason__c=='Invalid-Reenrollment'
                        affiliationIds.add(enrollmentDocument.Enrollment_Component_Affiliation__c); 
                    }
                }
            }              
            
            if (affiliationIds.size() > 0) {
                List<Enrollment_Component_Affiliation__c> docAffiliations = [
                    SELECT Id, Status__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c,
                    Enrollment_Component__c, Enrollment_Component__r.Component_Type__c
                    FROM Enrollment_Component_Affiliation__c WHERE Id IN :affiliationIds];
                
                List<Id> householdEnrollmentIds = new List<Id>();
                List<Id> componentIds = new List<Id>();
                
                for(Enrollment_Component_Affiliation__c docAffiliation : docAffiliations) {
                    householdEnrollmentIds.add(docAffiliation.Program_Enrollment__r.Household_Program_Enrollment__c);
                    if(docAffiliation.Enrollment_Component__r.Component_Type__c == 'Household') {
                        componentIds.add(docAffiliation.Enrollment_Component__c);
                    }
                }
                               
                // checking ECA status is not 'In Progress'.
                List<Enrollment_Component_Affiliation__c> additionalDocAffiliations = [SELECT Id, Status__c, Program_Enrollment__c, Enrollment_Component__c
                                                                                       FROM Enrollment_Component_Affiliation__c
                                                                                       WHERE Program_Enrollment__r.Household_Program_Enrollment__c IN : householdEnrollmentIds
                                                                                       AND Enrollment_Component__c IN : componentIds AND Status__c != 'In Progress'];
                docAffiliations.addAll(additionalDocAffiliations);
                
                //Create variables to work with
                Map<Id, Enrollment_Component_Affiliation__c> affiliationsForUpdate = new Map<Id, Enrollment_Component_Affiliation__c>();
                List<Id> programEnrollmentIds = new List<Id>();
                List<Id> docComponentIds = new List<Id>();
                               
                // Mark all the ECA document affiliations to 'In Progress' status.
                for (Enrollment_Component_Affiliation__c affiliation : docAffiliations) {
                    affiliation.Status__c = 'In Progress';
                                       
                    affiliationsForUpdate.put(affiliation.Id, affiliation);
                    programEnrollmentIds.add(affiliation.Program_Enrollment__c);
                    docComponentIds.add(affiliation.Enrollment_Component__c);
                }

                // Additional check to handle new ECA Model
                Map<Id, hed__Program_Enrollment__c> mapPEs = queriedPEs(programEnrollmentIds);
                hed__Program_Enrollment__c queriedPE;
                for (Enrollment_Component_Affiliation__c eca : affiliationsForUpdate.values())
                {
                    queriedPE = mapPEs.get(eca.Program_Enrollment__c);
                    if (queriedPE!=null && queriedPE.hed__Account__r.Use_Updated_ECA_Process__c)
                    {
                        // trigger parentHierarchy Status update
                        eca.Is_Dirty__c = true;

                    }
                }
                
                try {
                    List<Enrollment_Component_Affiliation__c> affiliationListToUpdate = new List<Enrollment_Component_Affiliation__c>();
                    affiliationListToUpdate.addAll(affiliationsForUpdate.values());
                    update affiliationListToUpdate;
                    
                    for (Id peId : programEnrollmentIds) {
                        if (mapPEs.containsKey(peId) && mapPEs.get(peId).hed__Account__r.Use_Updated_ECA_Process__c==false)
                            System.enqueueJob(new NES_CompletionQueueable(peId, null));
                    }
                    
                } catch (Exception e) {System.debug(e.getMessage());logger.logException('updateDocumentECAStatus', e);logger.saveLogs(); }
            }
        }
    }
/**
* Change Log: Added code by Anitha P for #107180 User Story (Task 108660) on 2019-09-10
* Purpose   : This method is used to Set status of PEs based on enrollment document statuses
**/
    //Start-added for #107180 User Story (Task 108660) on 2019-09-10  
   /* public static void updatePAHStatus(Map <Id, Enrollment_Document__c> newMap) {
        
        list<hed__Program_Enrollment__c> updatePesList =  new list<hed__Program_Enrollment__c>();
        hed__Program_Enrollment__c updatePes = new hed__Program_Enrollment__c();
        
        for (Enrollment_Document__c documentsList:newmap.values()){
            if (documentsList.Type__c == 'Home School Prior Academic History')
                if( documentsList.Status_Reason__c == 'Received') {
                    updatePes.id = documentsList.Program_Enrollment__c;
                    updatePes.PAHStatus__c = 'Received';       
                    updatePesList.add(updatePes);                                                    
                }else if (documentsList.Status_Reason__c == 'Received-No Documentation Available'){
                    updatePes.id = documentsList.Program_Enrollment__c;
                    updatePes.PAHStatus__c  = 'Received-No Documentation Available';       
                    updatePesList.add(updatePes);
                }else if (documentsList.Status_Reason__c == 'Verified'){
                    updatePes.id = documentsList.Program_Enrollment__c;
                    updatePes.PAHStatus__c = 'Verified';       
                    updatePesList.add(updatePes);              
                }else if (documentsList.Status_Reason__c == 'Verified-No Documentation Available'){
                    updatePes.id = documentsList.Program_Enrollment__c; 
                    updatePes.PAHStatus__c = 'Verified-No Documentation Available';       
                    updatePesList.add(updatePes);       
                }else if (documentsList.Status_Reason__c == 'Incomplete'){
                    updatePes.id = documentsList.Program_Enrollment__c;
                    updatePes.PAHStatus__c = 'Incomplete';       
                    updatePesList.add(updatePes);               
                }                                                 
        }
        //Update the Changed PE's statuses           
        if (updatePesList.size() > 0) {
            try {
                update updatePesList;               
            } catch (Exception ex) {
                System.debug('Exception Thrown : ' + ex.getMessage());
                logger.logException('updateSObjects', ex);
                logger.saveLogs();
            }
        }
        
    } */
    //End-added for #107180 User Story (Task 108660) on 2019-09-10      


/**
* Task number 111011- Created by Chinnamanaidu Neerasa on 30/09/2019.
* Purpose : Method is used to Set status to 'Deferred' in ECA, when the Enrollment Doc status changed from 'Verified' OR 'Exemption' to any other statuses.
*/
    
     public static void updateECAStatusToDeferred(Map<Id, Enrollment_Document__c> newMap, Map<Id, Enrollment_Document__c> oldMap) {
        
        List<Id> affiliationIds = new List<Id>();
        if (newMap.size()> 0 && oldmap.size() > 0){
            for (Enrollment_Document__c enrollmentDocument : newMap.values()) {
                Enrollment_Document__c enrollmentDocumentold = oldmap.get(enrollmentDocument.id);           
                    
                if (!String.isEmpty(enrollmentDocument.Status_Reason__c ) && !String.isEmpty(enrollmentDocumentold.Status_Reason__c )){
					if (enrollmentDocumentold.Status_Reason__c!= enrollmentDocument.Status_Reason__c && enrollmentDocument.Status_Reason__c.startsWith('Deferred') )
                       affiliationIds.add(enrollmentDocument.Enrollment_Component_Affiliation__c);
                }
             }  

            if (affiliationIds.size() > 0) {
                List<Enrollment_Component_Affiliation__c> docAffiliations = [
                    SELECT Id, Status__c, Program_Enrollment__c, Program_Enrollment__r.Household_Program_Enrollment__c,
                    Enrollment_Component__c, Enrollment_Component__r.Component_Type__c
                    FROM Enrollment_Component_Affiliation__c WHERE Id IN :affiliationIds];
                
                List<Id> householdEnrollmentIds = new List<Id>();
                List<Id> componentIds = new List<Id>();
                
                for(Enrollment_Component_Affiliation__c docAffiliation : docAffiliations) {
                    householdEnrollmentIds.add(docAffiliation.Program_Enrollment__r.Household_Program_Enrollment__c);
                    if(docAffiliation.Enrollment_Component__r.Component_Type__c == 'Household') {
                        componentIds.add(docAffiliation.Enrollment_Component__c);
                    }
                }
                              
                // checking ECA status is not 'Deferred'.
                List<Enrollment_Component_Affiliation__c> additionalDocAffiliations = [SELECT Id, Status__c, Program_Enrollment__c, Enrollment_Component__c
                                                                                       FROM Enrollment_Component_Affiliation__c
                                                                                       WHERE Program_Enrollment__r.Household_Program_Enrollment__c IN : householdEnrollmentIds
                                                                                       AND Enrollment_Component__c IN : componentIds AND Status__c != 'Deferred'];
                docAffiliations.addAll(additionalDocAffiliations);
                
                system.debug(docAffiliations);
                //Create variables to work with
                Map<Id, Enrollment_Component_Affiliation__c> affiliationsForUpdate = new Map<Id, Enrollment_Component_Affiliation__c>();
                List<Id> programEnrollmentIds = new List<Id>();                
                // Mark all the ECA document affiliations to 'Deferred' status.
                for (Enrollment_Component_Affiliation__c affiliation : docAffiliations) {
                    affiliation.Status__c = 'Deferred';
                    programEnrollmentIds.add(affiliation.Program_Enrollment__c);
                    affiliationsForUpdate.put(affiliation.Id, affiliation);
                }

                // Additional check to handle new ECA Model
                Map<Id, hed__Program_Enrollment__c> mapPEs = queriedPEs(programEnrollmentIds);
                hed__Program_Enrollment__c queriedPE;
                for (Enrollment_Component_Affiliation__c eca : affiliationsForUpdate.values())
                {
                    queriedPE = mapPEs.get(eca.Program_Enrollment__c);
                    if (queriedPE!=null && queriedPE.hed__Account__r.Use_Updated_ECA_Process__c)
                    {
                        // trigger parentHierarchy Status update
                        eca.Is_Dirty__c = true;

                    }
                }
 
                try {
                    List<Enrollment_Component_Affiliation__c> affiliationListToUpdate = new List<Enrollment_Component_Affiliation__c>();
                    affiliationListToUpdate.addAll(affiliationsForUpdate.values());
                    update affiliationListToUpdate;
                } catch (Exception e) {System.debug(e.getMessage());logger.logException('updateECAStatusToDeferred', e);logger.saveLogs();}
            }
        }
    }
    /**
* Task number 118391- Created by Chinnamanaidu Neerasa on 13/11/2019.
* Purpose : Method is used -when the ECA status has 'Deferred' its related ED should be in 'Submitted' status, and Set status to 'In Progress' in Document Review.
*/
    public static void updateDocumentRevStatus(Map<Id, Enrollment_Document__c> newMap, Map<Id, Enrollment_Document__c> oldMap){
            
        for(Enrollment_Document__c ed: newMap.values())
        {
           if(ed.Status_Reason__c == 'Submitted')
           {
               //Set the Document Review status to 'In Progress'.
              Document_Review__c parDocRev = new Document_Review__c();
               if (ed.Document_Review__c!= null){
                parDocRev = [SELECT id,Name FROM Document_Review__c WHERE id =:ed.Document_Review__c];
               parDocRev.Status__c = 'In Progress';
               //update parDocRev;
               }
               
               if (parDocRev.id!= null){
                try {
                    update parDocRev;
                } catch (Exception e) {System.debug(e.getMessage());logger.logException('updateDocumentReview', e); logger.saveLogs(); }
               }
           }
        }
        
    }

    /**
     * HELPER FUNCTIONS
    */

    public static Map<Id, hed__Program_Enrollment__c> queriedPEs(List<Id> peIds)
    {
        return new Map<Id, hed__Program_Enrollment__c>(
            [
                SELECT id, hed__Account__c, hed__Account__r.Use_Updated_ECA_Process__c, recordtype.name 
                FROM  hed__Program_Enrollment__c 
                WHERE Id in :peIds
            ]
        );
    }

}