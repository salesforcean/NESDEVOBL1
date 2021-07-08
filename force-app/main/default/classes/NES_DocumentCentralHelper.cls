/**
* Created by ajith on 04/12/18.
- Change Log:
-         2019-09-09 modified for User Story #102169 (Maddileti Boya) 
- 03/13/2020 : US [149116] : Modified by ALI KM - in getDocumentsListByUser() changed how we are creating the 'ecaListStatus'
*/

public without sharing class NES_DocumentCentralHelper {
    private static Peak_ApexLog logger = new Peak_ApexLog('DocumentCentralHelper');
    
    /**
* Created by Anushka Bansal on 11/13/18.
* Purpose : This method segregates the Enrollment Documents into 3 categories - Accepted, Under Review, Needs Attention
* based on their Status.
* Input : The caretaker Id
* Output : Returns a wrapper class with No of documents in each category and a list of all documents.
* add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
* add by Maddileti for Bug #109789 (Maddileti Boya) on 2019-09-24
* add by Maddileti for Bug #111147 (Maddileti Boya) on 2019-10-01   
*/
    @AuraEnabled
    public static String getDocumentsListByUser(String caretakerId) {
        
        List<Enrollment_Document__c> documentsList = [
            SELECT id, Date_FollowedUp__c, Date_Reviewed__c, Document_Link__c,
            Document__c, Type__c, Notes__c, Official_Transcript__c, Program_Enrollment__c, Program_Enrollment__r.hed__Contact__r.Name,
            Review_Completed_Time__c, Reviewer__c, Submission_Time__c, Uploader__c, Uploader__r.Name, Enrollment_Component_Affiliation__c, Status_Reason__c,
            Program_Enrollment__r.hed__Account__r.Document_End_Date__c, Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_End_Date__c,
            Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_Start_Date__c, Program_Enrollment__r.Program_Grade_Level__r.Name
            FROM Enrollment_Document__c
            WHERE Uploader__c = :caretakerId
        ];
        System.debug('The ED records are:' + documentsList);
        //Start Lines as part of 241543 (Jagadish Babu)
        Set<Id> docECAs = new Set<Id>();
		for(Enrollment_Document__c doc : documentsList){			
			docECAs.add(doc.Enrollment_Component_Affiliation__c);
		}
		//End Lines as part of 241543 (Jagadish Babu)
		
        // [149116] ALI KM - NEW CODE START
        Date currentDate = System.today();
        Map<Id, List<Id>> validPEToStagesMap = new Map<Id, List<Id>> ();
        Map<Id, Enrollment_Component_Affiliation__c> ecaMap = new Map<Id, Enrollment_Component_Affiliation__c> ();
        Map<Id, hed__Program_Enrollment__c> validPEs = new Map<Id, hed__Program_Enrollment__c> ();
        Set<Id> peStages = new Set<Id> ();
        
        //Get the logged in User's contact Id (caretaker Id)
		List<User> careTakerUser = [SELECT Id, ContactId from User where Id =: caretakerId];
        
        // Query all qualifyingPEs & related Stage.ECAs with Stage=InProgress
        for (hed__Program_Enrollment__c pe :
             [SELECT Id, hed__Account__c, Status__c, hed__Contact__r.Name, hed__Account__r.Document_Start_Date__c, hed__Account__r.Document_End_Date__c, RecordTypeId, RecordType.Name,
              (SELECT Id, Name, Status__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Enrollment_component__r.RecordType.Name
               FROM Enrollment_Component_Affiliation__r
               WHERE Enrollment_component__r.RecordType.Name = : NES_DashboardUtilities.STAGE_RT
               AND Status__c IN('In Progress'))
              FROM hed__Program_Enrollment__c
              //WHERE hed__Contact__r.CreatedById = : caretakerId Commented to fix 255843 as the migrated student will have createdby id as PcxIntegration
			  WHERE Household_Program_Enrollment__r.hed__Contact__c =:careTakerUser[0].ContactId 
              // AND Id IN :peToEDsMap.keySet()
              AND Status__c = 'In Progress'
              AND hed__Account__r.Document_Start_Date__c != null AND hed__Account__r.Document_End_Date__c != null
              AND hed__Account__r.Document_Start_Date__c <= : currentDate AND hed__Account__r.Document_End_Date__c >= : currentDate])
        {
            
            if (pe.Enrollment_Component_Affiliation__r.size() > 0) {
                
                // collect PEs...
                validPEs.put(pe.Id, pe);
                
                Set<Id> stages = new Set<Id> ();
                System.debug('serialized ECAs::' + JSON.serialize(pe.Enrollment_Component_Affiliation__r));
                for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r)
                {
                    // collect stages...
                    stages.add(eca.Enrollment_component__r.Id);
                }
                
                // collect pe => stagesList
                validPEToStagesMap.put(pe.Id, new List<Id> (stages));
                peStages.addAll(stages);
                
            }
        }
        // System.debug(':::validPEs:::' + validPEs.size());
        // System.debug(JSON.serialize(validPEs));
        // System.debug(':::peStages:::' + peStages.size());
        // System.debug(JSON.serialize(peStages));
        // System.debug(':::validPEToStagesMap:::' + validPEToStagesMap.size());
        // System.debug(JSON.serialize(validPEToStagesMap));
        
        
        // Collect Stages.children from ECR
        Map<Id, Id> formsToStagesMap = new Map<Id, Id> ();
        Map<Id, List<Id>> stagesToDocsMap = new Map<Id, List<Id>> (); // final list we need.
        // Set<Id> allForms = new Set<Id>();
        for (Enrollment_Component_Relationship__c ecr :[
            SELECT Id, Child_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Id,
            Parent_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Order__c, Parent_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c IN :peStages])
        {
            formsToStagesMap.put(ecr.Child_Enrollment_Component__c, ecr.Parent_Enrollment_Component__c);
        }
        // System.debug(':::formsToStagesMap:::' + formsToStagesMap.size());
        // System.debug(JSON.serialize(formsToStagesMap));
        // System.debug(':::stagesToDocsMap:::' + stagesToDocsMap.size());
        // System.debug(JSON.serialize(stagesToDocsMap));
        
        
        // Collect Stages.Forms.children from ECR
        Map<Id, Id> childToParentMap = new Map<Id, Id> ();
        for (Enrollment_Component_Relationship__c ecr :[
            SELECT Id, Child_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Id,
            Parent_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Order__c, Parent_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c IN :formsToStagesMap.keySet()])
        {
            
            // collect documents...
            if (NES_DashboardUtilities.DOCUMENT_RT.equalsIgnoreCase(ecr.Child_Enrollment_Component__r.RecordType.Name))
            {
                Id stageId = formsToStagesMap.get(ecr.Parent_Enrollment_Component__c);
                List<Id> children = stagesToDocsMap.get(stageId);
                if (children == null) {
                    children = new List<Id> ();
                    stagesToDocsMap.put(stageId, children);
                }
                children.add(ecr.Child_Enrollment_Component__c);
            }
            childToParentMap.put(ecr.Child_Enrollment_Component__c, ecr.Parent_Enrollment_Component__c);
        }
        // System.debug(':::childToParentMap:::' + childToParentMap.size());
        // System.debug(JSON.serialize(childToParentMap));
        // System.debug(':::stagesToDocsMap 2:::' + stagesToDocsMap.size());
        // System.debug(':::stagesToDocsMap.values():::' + stagesToDocsMap.values());
        // System.debug(JSON.serialize(stagesToDocsMap));
        
        
        // collect all Doc.EC.IDs
        Set<Id> docECIds = new Set<Id> ();
        for (List<Id> docECs : stagesToDocsMap.values()) {
            docECIds.addAll(docECs);
        }
        // System.debug(':::docECIds:::' + docECIds.size());
        // System.debug(JSON.serialize(docECIds));
        
        
        list<Enrollment_Component_Affiliation__c> ecaListStatus = new list<Enrollment_Component_Affiliation__c> ();
        list<Enrollment_Component_Affiliation__c> ecaListNotStarted = new list<Enrollment_Component_Affiliation__c> ();//Swapna:For US181065
        for (Enrollment_Component_Affiliation__c eca :[
            SELECT Id, Name, status__c, Enrollment_component__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Program_Enrollment__c, Program_Enrollment__r.hed__Contact__r.Name
            FROM Enrollment_Component_Affiliation__c
            WHERE
            Program_Enrollment__c IN :validPEs.keySet()
            AND Enrollment_component__r.Id IN :docECIds
            AND Status__c IN('Not Started', 'Deferred')])/***** Modified 5/15/2020 by Vani User Story #171693*****/
        {
			
			// collect valid ecas...
            List<Id> tmpPEStages = validPEToStagesMap.get(eca.Program_Enrollment__c);
            for (Id stg : tmpPEStages) {
                List<Id> docList = stagesToDocsMap.get(stg);
                if (docList != null && docList.size() > 0 && docList.contains(eca.Enrollment_component__c)) {
                    ecaListStatus.add(eca);
                    //Swapna:5/21/2020:For US 181065
                    if(eca.Status__c == 'Not Started' && !docECAs.contains(eca.Id)) //Added contains condition as part of 241543 (Jagadish Babu)
                        ecaListNotStarted.add(eca);
                        continue;
                }
            }
        }
        System.debug(':::ecaListStatus:::' + ecaListStatus.size());
        System.debug(JSON.serialize(ecaListStatus));
        // [149116] ALI KM - NEW CODE END
        
        // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        // End by Maddileti for Bug #111147 (Maddileti Boya) on 2019-10-01
        
        List<Document_Central_Status_Mapping__mdt> DocumentStatusMappingList = [Select Status_Level__c, Status__c from Document_Central_Status_Mapping__mdt];
        Map<String, String> DocumentStatusMappingMap = new Map<String, String> ();
        
        // creating a mapping between Enrollment Document Status and bucketed Status.
        for (Document_Central_Status_Mapping__mdt dsm : DocumentStatusMappingList) {
            DocumentStatusMappingMap.put(dsm.Status__c, dsm.Status_Level__c);
        }
        
        System.assertEquals(true, DocumentStatusMappingMap.size() > 0);
        
        Map<String, List<Enrollment_Document__c>> mapOfEnrollmentDocuments = new Map<String, List<Enrollment_Document__c>> ();
        
        //Creating a map with key as Bucketed status and value as corresponding Enrollment Documents.
        for (Enrollment_Document__c doc : documentsList) {
            
            if (doc.Status_Reason__c != NULL && doc.Status_Reason__c != '') {
                
                Boolean validDoc = false;
                if (doc.Program_Enrollment__r.hed__Account__r.Document_End_Date__c > currentDate) {
                    validDoc = true;
                }
                
                if (doc.Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_End_Date__c != null) {
                    if (doc.Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_End_Date__c >= currentDate &&
                        doc.Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_Start_Date__c <= currentDate) {
                            validDoc = true;
                        } else {
                            validDoc = false;
                        }
                }
                
                if (validDoc) {
                   // String docStatus = doc.Status_Reason__c.contains('-') ? doc.Status_Reason__c.substringBefore('-') : doc.Status_Reason__c;
                   //Swapna:Changed part of US-181065 to consider 1:1 mapping
                    String docStatus = doc.Status_Reason__c;
                    if (DocumentStatusMappingMap.get(docStatus) != null) {
                        if (mapOfEnrollmentDocuments.get(DocumentStatusMappingMap.get(docStatus)) != null) {
                            mapOfEnrollmentDocuments.get(DocumentStatusMappingMap.get(docStatus)).add(doc);
                        } else {
                            List<Enrollment_Document__c> documents = new List<Enrollment_Document__c> ();
                            documents.add(doc);
                            mapOfEnrollmentDocuments.put(DocumentStatusMappingMap.get(docStatus), documents);
                        }
                    }
                }
                
            }
            
        }
        
        //Categorizing documents into 3 buckets based on their status
        NES_DocumentUtilities.DocumentWrapper docsWrapper = new NES_DocumentUtilities.DocumentWrapper();
        System.debug('The values docsWrapper are 11::' + docsWrapper);
        if (mapOfEnrollmentDocuments.get('Accepted') != null)
            docsWrapper.numberOfAcceptedDocs = mapOfEnrollmentDocuments.get('Accepted').size();
        if (mapOfEnrollmentDocuments.get('Under Review') != null)
            docsWrapper.numberOfUnderReviewDocs = mapOfEnrollmentDocuments.get('Under Review').size();
        if (mapOfEnrollmentDocuments.get('Needs Attention') != null)
            docsWrapper.numberOfNeedsReviewDocs = mapOfEnrollmentDocuments.get('Needs Attention').size();
        /***** Modified 5/15/2020 by Vani User Story #171693*****/
        if (mapOfEnrollmentDocuments.get('Deferred') != null)
            docsWrapper.numberOfDeferredDocs = mapOfEnrollmentDocuments.get('Deferred').size();
        // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        docsWrapper.numberOfNotSubmittedDocs = ecaListStatus.size();
        // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        
        docsWrapper.mapOfEnrollmentDocuments = mapOfEnrollmentDocuments;
        // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        docsWrapper.ecaListStatus = ecaListStatus;
        // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        // Swapna:US181065: Pass the ECA's with Not Started status
           docsWrapper.ecaListStatusNotStarted = ecaListNotStarted;
        return JSON.serialize(docsWrapper);
        
    }
    
    // /**
    //     * Created by Anushka Bansal on 11/13/18.
    //     * Purpose : This method segregates the Enrollment Documents into 3 categories - Accepted, Under Review, Needs Attention
    //     * based on their Status.
    //     * Input : The caretaker Id
    //     * Output : Returns a wrapper class with No of documents in each category and a list of all documents.
    //     * add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    //     * add by Maddileti for Bug #109789 (Maddileti Boya) on 2019-09-24
    //     * add by Maddileti for Bug #111147 (Maddileti Boya) on 2019-10-01
    // */
    // @AuraEnabled
    // public static String getDocumentsListByUser_OLD(String caretakerId) { 
    
    
    //     Date currentDate = Date.today();
    
    //     List<Enrollment_Document__c> documentsList = [
    //         Select id, Date_FollowedUp__c, Date_Reviewed__c, Document_Link__c,
    //         Document__c, Type__c, Notes__c, Official_Transcript__c, Program_Enrollment__c, Program_Enrollment__r.hed__Contact__r.Name,
    //         Review_Completed_Time__c, Reviewer__c, Submission_Time__c, Uploader__c,Uploader__r.Name, Enrollment_Component_Affiliation__c, Status_Reason__c,
    //         Program_Enrollment__r.hed__Account__r.Document_End_Date__c, Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_End_Date__c, Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_Start_Date__c, Program_Enrollment__r.Program_Grade_Level__r.Name
    //         from Enrollment_Document__c
    //         where Uploader__c = :caretakerId
    //     ];
    //     System.debug('The ED records are:'+documentsList);
    
    //     // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    //      // Start by Maddileti for Bug #111147 (Maddileti Boya) on 2019-10-01
    //     set<id> programIdslist = new set<id>();
    //     set<id> programIds = new set<id>();
    //     set<id> ecaIdsnot = new set<id>();
    //     set<id> ecaIds = new set<id>();
    //     System.debug(documentsList.size());
    //     If(documentsList.size()>0){
    //     for (Enrollment_Document__c enrolldoc :documentsList ){ 
    //         programIds.add(enrolldoc.Program_Enrollment__c); 
    //         ecaIdsnot.add(enrolldoc.Enrollment_Component_Affiliation__c);
    //     }  
    //         for(hed__Program_Enrollment__c enrollments:[select Id from hed__Program_Enrollment__c where hed__Contact__r.CreatedById = : caretakerId
    //                                                     and id in : programIds]){ 
    //             programIdslist.add(enrollments.Id); 
    
    
    //         } 
    //     }    
    //      System.debug(programIdslist);
    //      for(hed__Program_Enrollment__c enrollments:[select Id from hed__Program_Enrollment__c where hed__Contact__r.CreatedById = : caretakerId
    //                                                     and id not in : programIds]){ 
    //             programIdslist.add(enrollments.Id); 
    
    
    //         } 
    
    //        list<Enrollment_Component_Affiliation__c> ecaListStatus = new list<Enrollment_Component_Affiliation__c> ();   
    //   /* if (ecaIdsnot.size()>0){ 
    //        list<Enrollment_Component_Affiliation__c> ecaList = [ 
    //            SELECT Id,Name,status__c,Enrollment_component__r.Id,Enrollment_component__r.Name,Program_Enrollment__r.hed__Contact__r.Name
    //                                                                   FROM Enrollment_Component_Affiliation__c 
    //            WHERE ID not IN : ecaidsnot and Program_Enrollment__c IN: programIds and Enrollment_Component__r.recordtype.name = 'Document' and (Status__c ='Not started' or Status__c='Deferred')];
    //         if (ecaList.size()>0){
    //                 ecaListstatus = ecaList;
    //             }
    //     } */
    //        if (programIdslist.size()>0 ){
    //       list<Enrollment_Component_Affiliation__c> ecaList = [
    //            SELECT Id,Name,status__c,Enrollment_component__r.Id,Enrollment_component__r.Name,Program_Enrollment__r.hed__Contact__r.Name
    //                                                                   FROM Enrollment_Component_Affiliation__c 
    //            WHERE Program_Enrollment__c IN: programIdslist and Enrollment_Component__r.recordtype.name = 'Document' and (Status__c ='Not started' or Status__c='Deferred')];  
    //         if (ecaList.size()>0){
    //                 ecaListstatus = ecaList;
    //             } 
    
    //     } 
    
    //      // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    //      // End by Maddileti for Bug #111147 (Maddileti Boya) on 2019-10-01
    
    //         List<Document_Central_Status_Mapping__mdt> DocumentStatusMappingList = [Select Status_Level__c, Status__c from Document_Central_Status_Mapping__mdt];
    //     Map<String, String> DocumentStatusMappingMap = new Map<String, String>();
    
    //     // creating a mapping between Enrollment Document Status and bucketed Status.
    //     for (Document_Central_Status_Mapping__mdt dsm : DocumentStatusMappingList) {
    //         DocumentStatusMappingMap.put(dsm.Status__c, dsm.Status_Level__c);
    //     }
    //     Map<String, List<Enrollment_Document__c>> mapOfEnrollmentDocuments = new Map<String, List<Enrollment_Document__c>>();
    
    //     //Creating a map with key as Bucketed status and value as corresponding Enrollment Documents.
    //     for (Enrollment_Document__c doc : documentsList) {
    
    //         if (doc.Status_Reason__c != NULL && doc.Status_Reason__c != '') {
    
    //             Boolean withinAcceptedDates = false;
    
    //             if(doc.Program_Enrollment__r.hed__Account__r.Document_End_Date__c > currentDate){
    //                 withinAcceptedDates = true;
    //             }
    
    //             if(doc.Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_End_Date__c != null){
    //                 if(doc.Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_End_Date__c >= currentDate &&
    //                    doc.Program_Enrollment__r.Program_Grade_Level__r.Document_Submission_Start_Date__c <= currentDate) {
    //                        withinAcceptedDates = true;
    //                    } else {
    //                        withinAcceptedDates = false;
    //                    }
    //             }
    
    //             if(withinAcceptedDates) {
    //                 String docStatus = doc.Status_Reason__c.contains('-') ? doc.Status_Reason__c.substringBefore('-') : doc.Status_Reason__c;
    
    //                 if (DocumentStatusMappingMap.get(docStatus) != null) {
    //                     if (mapOfEnrollmentDocuments.get(DocumentStatusMappingMap.get(docStatus)) != null) {
    //                         mapOfEnrollmentDocuments.get(DocumentStatusMappingMap.get(docStatus)).add(doc);
    //                     } else {
    //                         List<Enrollment_Document__c> documents = new List<Enrollment_Document__c>();
    //                         documents.add(doc);
    //                         mapOfEnrollmentDocuments.put(DocumentStatusMappingMap.get(docStatus), documents);
    //                     }
    //                 }
    //             }
    
    //         }
    
    //     }
    
    //     //Categorizing documents into 3 buckets based on their status
    //     NES_DocumentUtilities.DocumentWrapper docsWrapper = new NES_DocumentUtilities.DocumentWrapper();
    //     System.debug('The values docsWrapper are 11::'+docsWrapper);
    //     if (mapOfEnrollmentDocuments.get('Accepted') != null)
    //         docsWrapper.numberOfAcceptedDocs = mapOfEnrollmentDocuments.get('Accepted').size();
    //     if (mapOfEnrollmentDocuments.get('Under Review') != null)
    //         docsWrapper.numberOfUnderReviewDocs = mapOfEnrollmentDocuments.get('Under Review').size();
    //     if (mapOfEnrollmentDocuments.get('Needs Attention') != null)
    //         docsWrapper.numberOfNeedsReviewDocs = mapOfEnrollmentDocuments.get('Needs Attention').size();
    //     // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    //        docsWrapper.numberOfNotSubmittedDocs =  ecaListStatus.size();
    //     // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    
    //     docsWrapper.mapOfEnrollmentDocuments = mapOfEnrollmentDocuments ;
    //      // Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    //        docsWrapper.ecaListStatus = ecaListStatus;
    //      // End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
    //       return JSON.serialize(docsWrapper);
    
    // } 
    
    
    /**
* Created by Raju on 19/11/18.
* Purpose : This method takes enrollment component affiliation id as a parameter and returns the related enrollment component of type document
*           and its related enrollment component of type message
*/
    
    @AuraEnabled
    public static String getDocumentInfo(Id enrollmentComponentAffiliationId, String enrollmentDocumentId) {
        
        //Query EnrollmentComponent records where recordtype is Document
        Id documentRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Document').getRecordTypeId();
        Enrollment_Component__c enrollmentComponent = new Enrollment_Component__c();
        
        List<Enrollment_Component__c> enrollmentComponentList = [
            SELECT Id, Status__c, Name, Component_Message__c, Question_Type__c, Document_Type__c
            FROM Enrollment_Component__c
            WHERE RecordTypeId = :documentRecordTypeId AND
            Id IN(
                SELECT Enrollment_Component__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Id = :enrollmentComponentAffiliationId
            )
            LIMIT 1
        ];
        enrollmentComponent = enrollmentComponentList[0];
        
        if (enrollmentComponent != null) {
            
            //Get message components that are children of the EC -- to display in Contextual Help
            Peak_Response getMessagesResponse = getRelatedEnrollmentComponents('Message', enrollmentComponent.Id);
            
            List<Enrollment_Component__c> messageComponentsList = new List<Enrollment_Component__c> ();
            if (!Peak_Utils.isNullOrEmpty(getMessagesResponse.results)) {
                messageComponentsList = getMessagesResponse.results;
            }
            
            //Get text components that are children of the EC -- to display in above uploader
            Peak_Response getTextResponse = getRelatedEnrollmentComponents('Text', enrollmentComponent.Id);
            
            List<Enrollment_Component__c> textComponentsList = new List<Enrollment_Component__c> ();
            if (!Peak_Utils.isNullOrEmpty(getTextResponse.results)) {
                textComponentsList = getTextResponse.results;
            }
            
            List<Enrollment_Component_Affiliation__c> enrollmentComponentAffiliations = [
                SELECT Id, Program_Enrollment__r.hed__Contact__r.Name
                FROM Enrollment_Component_Affiliation__c
                WHERE Id = :enrollmentComponentAffiliationId
            ];
            
            //Get the Student Name
            String studentName = '';
            if (!Peak_Utils.isNullOrEmpty(enrollmentComponentAffiliations)) {
                studentName = enrollmentComponentAffiliations[0].Program_Enrollment__r.hed__Contact__r.Name;
            }
            
            
            List<String> EDReasonMessages = new List<String> (); //List to hold Enrollment Document Reason Messages
            if (enrollmentDocumentId != NULL && enrollmentDocumentId != '') {
                
                List<Enrollment_Document__c> enrollmentDocuments = [SELECT Id, Status_Reason__c, Type__c FROM Enrollment_Document__c WHERE Id = :enrollmentDocumentId];
                
                //Get Status_Reason__c and get mapping from custom metadata records
                if (enrollmentDocuments[0].Status_Reason__c != NULL && enrollmentDocuments[0].Status_Reason__c != '') {
                    
                    
                    //Make a call to wrapper class passing in ED
                    List<NES_DocReasonMDTWrapper.NES_DocReasonMessage> enrollmentDocumentReasonMessages =
                        NES_DocReasonMDTWrapper.getDocReasonMDTS(enrollmentDocuments[0]);
                    
                    for (NES_DocReasonMDTWrapper.NES_DocReasonMessage theWrapper : enrollmentDocumentReasonMessages) {
                        EDReasonMessages.add(theWrapper.message);
                    }
                    
                }
            }
            
            
            NES_DocumentUtilities.DocumentData ecInfo = new NES_DocumentUtilities.DocumentData(enrollmentComponent.Id, enrollmentComponent.Status__c, enrollmentComponent.name,
                                                                                               enrollmentComponent.Component_Message__c,
                                                                                               enrollmentComponent.Document_Type__c, enrollmentComponent.Question_Type__c, studentName,
                                                                                               messageComponentsList, textComponentsList, EDReasonMessages);
            ecInfo.documentStatus = enrollmentComponent.Status__c;
            
            System.debug('ED INFO ===' + ecInfo);
            return JSON.serialize(ecInfo);
        }
        // This needs to be changes to Peak Response lets us discuss and make this change since we have developed this as per the task description
        return '';
        
    }
    
    /**
* Created by Raju on 21/11/18.
* Purpose : This method takes enrollment component affiliation id and document link as a parameter and if there is an existing enrollment document is there
*           update it, otherwise insert a new document
*/
    
    @AuraEnabled
    public static Peak_Response updateDocuments(Id enrollmentComponentAffiliationId, String documentLink) {
        System.debug('enrollmentComponentAffiliationId===>>>' + enrollmentComponentAffiliationId);
        Peak_Response peakResponse = new Peak_Response();
        //Query EnrollmentDocument
        Id documentRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get('Document').getRecordTypeId();
        Enrollment_Component_Affiliation__c eca = new Enrollment_Component_Affiliation__c();
        
        for (Enrollment_Component_Affiliation__c affiliation :[
            SELECT Id, Program_Enrollment__c
            FROM Enrollment_Component_Affiliation__c
            WHERE Id = :enrollmentComponentAffiliationId AND Enrollment_Component__r.RecordTypeId = :documentRecordTypeId
        ]) {
            
            eca = affiliation;
            System.debug('affiliation ::' + affiliation);
        }
        System.debug('eca ::' + eca);
        List<Enrollment_Document__c> enrollmentDocumentList = new List<Enrollment_Document__c> ([
            SELECT Id,
            Document_Link__c,
            Program_Enrollment__c,
            Type__c
            FROM Enrollment_Document__c
            WHERE Enrollment_Component_Affiliation__c = :eca.Id
        ]);
        System.debug('enrollmentDocumentList::' + enrollmentDocumentList);
        //Check if there are records existing already if yes update else insert new records
        if (enrollmentDocumentList.size() > 0) {
            for (Enrollment_Document__c ed : enrollmentDocumentList) {
                ed.Document_Link__c = documentLink;
            }
            
            try {
                Database.SaveResult[] srList = Database.update(enrollmentDocumentList, true);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        peakResponse.messages.add('successfully updated enrollment document records');
                        peakResponse.success = true;
                    } else {
                        // Operation failed, so get all errors
                        for (Database.Error err : sr.getErrors()) {
                            peakResponse.success = false;
                            peakResponse.messages.add('Error :' + err.getMessage());
                            
                        }
                    }
                }
            } catch(Exception ex) {
                peakResponse.success = false;
                peakResponse.messages.add('Error :' + ex.getMessage());
                logger.logException('updateDocuments', ex);
                logger.saveLogs();
            }
        } else {
            Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c();
            enrollmentDocument.Document_Link__c = documentLink;
            enrollmentDocument.Program_Enrollment__c = eca.Program_Enrollment__c;
            enrollmentDocument.Enrollment_Component_Affiliation__c = eca.Id;
            List<Enrollment_Document__c> newEnrollmentDocumentList = new List<Enrollment_Document__c> ();
            newEnrollmentDocumentList.add(enrollmentDocument);
            
            try {
                Database.SaveResult[] srList = Database.insert(newEnrollmentDocumentList, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        peakResponse.messages.add('successfully inserted EC record');
                        peakResponse.success = true;
                    } else {
                        // Operation failed, so get all errors
                        for (Database.Error err : sr.getErrors()) {
                            peakResponse.success = false;
                            peakResponse.messages.add('Error :' + err.getMessage());
                        }
                    }
                }
                
            } catch(Exception ex) {
                peakResponse.success = false;
                peakResponse.messages.add('Error :' + ex.getMessage());
                logger.logException('updateDocuments', ex);
                logger.saveLogs();
            }
        }
        System.debug('peakResponse' + peakResponse);
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
    public static Peak_Response insertDocuments(Map<String, String> files, Id affiliationId) {
        
        Peak_Response peakResponse = new Peak_Response();
        
        //Enrollment Document Insert Code Start
        Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c();
        //Check whether the Id is passed or not
        if (!String.isEmpty(affiliationId)) {
            //Query Enrollment Component Affiliation__c based on the method Parameter
            Enrollment_Component_Affiliation__c enrollCompAffiliation;
            for (Enrollment_Component_Affiliation__c rec :[
                SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Id = :affiliationId
                LIMIT 1
            ]) {
                enrollCompAffiliation = rec;
            }
            
            
            try {
                enrollmentDocument.Uploader__c = UserInfo.getUserId();
                enrollmentDocument.Submission_Time__c = system.now();
                enrollmentDocument.Program_Enrollment__c = enrollCompAffiliation.Program_Enrollment__c;
                enrollmentDocument.Type__c = enrollCompAffiliation.Enrollment_Component__r.Document_Type__c;
                enrollmentDocument.Enrollment_Component_Affiliation__c = affiliationId;
                insert enrollmentDocument;
                
                peakResponse.messages.add('Enrollment Document Inserted');
                peakResponse.success = true;
            } catch(Exception ex) {
                system.debug('ex++' + ex.getMessage());
                peakResponse.success = false;
                peakResponse.messages.add(ex.getMessage());
                logger.logException('insertDocuments', ex);
                logger.saveLogs();
            }
        }
        //Enrollment Document Insert Code End
        
        //Document File References Insertion code start
        //List to hold the references to Insert
        List<Document_File_References__c> docFileReferenceList = new List<Document_File_References__c> ();
        
        // Iterate over files map
        for (String filepath : files.keySet()) {
            // Create Document File References
            Document_File_References__c docFileReference = new Document_File_References__c();
            //docFileReference.Name = filepath;
            docFileReference.File_Path__c = files.get(filepath);
            docFileReference.Date_Uploaded__c = system.now();
            docFileReference.Enrollment_Document__c = enrollmentDocument.id;
            docFileReferenceList.add(docFileReference);
        }
        
        if (docFileReferenceList.size() > 0) {
            
            Database.SaveResult[] saveDocFileReferenceList = Database.insert(docFileReferenceList, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : saveDocFileReferenceList) {
                if (sr.isSuccess()) {
                    peakResponse.messages.add('Successfully inserted Document File References record');
                    peakResponse.success = true;
                } else {
                    // Operation failed, so get all errors
                    for (Database.Error ex : sr.getErrors()) {
                        peakResponse.success = false;
                        peakResponse.messages.add(ex.getMessage());
                    }
                }
            }
        }
        return peakResponse;
    }
    
    /* Method to get Enrollment Components of Record type 'Message' OR 'Text' related to the given Enrollment Component */
    public static Peak_Response getRelatedEnrollmentComponents(String recordType, String enrollmentComponentId) {
        
        Peak_Response peakResponse = new Peak_Response();
        
        //Get Enrollment Component record type
        Id messageRecordTypeId = Schema.SObjectType.Enrollment_Component__c.getRecordTypeInfosByName().get(recordType).getRecordTypeId();
        
        
        List<Enrollment_Component__c> enrollmentComponentsList = new List<Enrollment_Component__c> ();
        List<Id> messageIds = new List<Id> ();
        
        try {
            //Get list of child 'message' OR 'text' enrollment components
            List<Enrollment_Component_Relationship__c> ecRelationships = [
                SELECT Id, Child_Enrollment_Component__c, 
                       Child_Enrollment_Component__r.Id, Child_Enrollment_Component__r.Component_Message__c  ,Child_Enrollment_Component__r.Order__c
                FROM Enrollment_Component_Relationship__c
                WHERE Parent_Enrollment_Component__c = :enrollmentComponentId
                AND Child_Enrollment_Component__r.RecordTypeId = :messageRecordTypeId
                ORDER BY Order__c
            ];
            
            //Add all message Ids to a list
            for (Enrollment_Component_Relationship__c rel : ecRelationships) {
                messageIds.add(rel.Child_Enrollment_Component__c);
                enrollmentComponentsList.add(new Enrollment_Component__c(id = rel.Child_Enrollment_Component__r.Id, 
                                                                        Component_Message__c = rel.Child_Enrollment_Component__r.Component_Message__c,
                                                                        Order__c = rel.Child_Enrollment_Component__r.Order__c));

                peakResponse.results = enrollmentComponentsList;
            }
            
            //MM 12/9/2020 Moved this code into the for loop above so we could maintain the order from the ECR and not from the EC.
            //Query all the messages to return whole object
            /*if (!Peak_Utils.isNullOrEmpty(messageIds)) {
                enrollmentComponentsList = [
                    SELECT Id, Component_Message__c, Order__c
                    FROM Enrollment_Component__c
                    WHERE Id IN :messageIds
                ];
                peakResponse.results = enrollmentComponentsList;
            } */
            
        } catch(Exception e) {
            peakResponse.success = FALSE;
            peakResponse.messages.add(e.getMessage());
            logger.logException('getRelatedEnrollmentComponents', e);
            logger.saveLogs();
        }
        return peakResponse;
    }
    
    
    /*
This method will create or edit Enrollment Documents and  File References
*/
    
    @AuraEnabled
    public static Peak_Response upsertDocumentsAndFileReferences(String enrollmentComponentAffiliationId, String enrollmentDocumentId, List<String> documentLink) {
        Peak_Response peakResponse = new Peak_Response();
        
        
        System.debug('AFFILIATION ID ====' + enrollmentComponentAffiliationId);
        System.debug('ENROLLMENT DOC LIST ===' + enrollmentDocumentId);
        
        //Get Enrollment Component Affiliations
        List<Enrollment_Component_Affiliation__c> affiliationList = new List<Enrollment_Component_Affiliation__c> ();
        List<Enrollment_Document__c> enrollmentDocumentList = new List<Enrollment_Document__c> ();
        
        //If ECA is given
        if (enrollmentComponentAffiliationId != '' && enrollmentComponentAffiliationId != NULL) {
            
            //Get ECA record
            affiliationList = [
                SELECT Id, Program_Enrollment__c, Enrollment_Component__r.Document_Type__c, Enrollment_Component__r.Component_Type__c,
                Program_Enrollment__r.Household_Program_Enrollment__c, Enrollment_Component__r.Id, Program_Enrollment__r.hed__Account__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Id = :enrollmentComponentAffiliationId
            ];
            
            //If ED is also given, get related ED
            if (enrollmentDocumentId != '' && enrollmentDocumentId != NULL) {
                enrollmentDocumentList = [
                    SELECT Id, Document_Link__c, Program_Enrollment__c, Type__c
                    FROM Enrollment_Document__c
                    WHERE Enrollment_Component_Affiliation__c = :enrollmentComponentAffiliationId
                    AND Id = :enrollmentDocumentId
                ];
            }
            
        } else {
            //If no ECA is given,
            
            //Get Enrollment Documents
            if (enrollmentDocumentId != '' && enrollmentDocumentId != NULL) {
                
                enrollmentDocumentList = [
                    SELECT Id, Document_Link__c, Program_Enrollment__c, Type__c
                    FROM Enrollment_Document__c
                    WHERE Id = :enrollmentDocumentId
                ];
            }
        }
        System.debug('AFFILIATION LIST ====' + affiliationList);
        System.debug('ENROLLMENT DOC LIST ===' + enrollmentDocumentList);
        
        try {
            
            List<Enrollment_Document__c> enrollmentDocumentsToReturn = new List<Enrollment_Document__c> ();
            List<Document_File_References__c> fileReference = new List<Document_File_References__c> ();
            
            //If the ED exists update it
            if (!Peak_Utils.isNullOrEmpty(enrollmentDocumentList)) {
                
                //TODO: Check this -- what should be updated on Enrollment Document?
                for (Enrollment_Document__c theDoc : enrollmentDocumentList) {
                    theDoc.Status_Reason__c = 'Submitted';
                }
                
                update enrollmentDocumentList;
                enrollmentDocumentsToReturn.addAll(enrollmentDocumentList);
                
                fileReference = createFileReferences(documentLink, enrollmentDocumentList[0]);
                
                //Otherwise, create a new ED
            } else {
                
                String programEnrollmentId = '';
                System.debug('we are here ::programEnrollmentId::' + programEnrollmentId);
                
                //Get PE for new ED
                if (!Peak_Utils.isNullOrEmpty(affiliationList)) {
                    System.debug('we are in Get PE for new ED block');
                    //Now we need to get the ECR so we can get the parent EC
                    Enrollment_Component_Relationship__c relationship = [SELECT Parent_Enrollment_Component__c, Parent_Enrollment_Component__r.Process_Academic_Program__c
                                                                         FROM Enrollment_Component_Relationship__c
                                                                         WHERE Child_Enrollment_Component__c = :affiliationList[0].Enrollment_Component__r.Id];
                    
                    //AND Parent_Enrollment_Component__r.Process_Academic_Program__c =: affiliationList[0].Program_Enrollment__r.hed__Account__c
                    
                    System.debug('We are in relationship::' + relationship);
                    
                    //Ok using that parent id, let's get the status of that form
                    Enrollment_Component_Affiliation__c formEC = [SELECT Id, Status__c FROM Enrollment_Component_Affiliation__c WHERE
                                                                  Enrollment_Component__c = :relationship.Parent_Enrollment_Component__c AND
                                                                  Program_Enrollment__c = :affiliationList[0].Program_Enrollment__c];
                    
                    //If it the form has not been marked as In Progress already, let's do that now
                    if (formEC.Status__c == 'Not Started') {
                        formEC.Status__c = 'In Progress';
                        update formEC;
                    }
                    
                    //If the EC is a Household component type , we want a Household ED
                    if (affiliationList[0].Enrollment_Component__r.Component_Type__c == 'Household') {
                        programEnrollmentId = affiliationList[0].Program_Enrollment__r.Household_Program_Enrollment__c;
                        
                        //Otherwise ED goes on regular PE
                    } else {
                        programEnrollmentId = affiliationList[0].Program_Enrollment__c;
                    }
                }
                
                //Create the ED
                Enrollment_Document__c enrollmentDocument = new Enrollment_Document__c();
                enrollmentDocument.Program_Enrollment__c = programEnrollmentId;
                enrollmentDocument.Enrollment_Component_Affiliation__c = affiliationList[0].Id;
                enrollmentDocument.Status_Reason__c = 'Submitted';
                enrollmentDocument.Uploader__c = UserInfo.getUserId();
                enrollmentDocument.Submission_Time__c = system.now();
                enrollmentDocument.Type__c = affiliationList[0].Enrollment_Component__r.Document_Type__c;
                System.debug(enrollmentDocument);
                // Added code for the bug #147271 on 18/03/2020
                //insert enrollmentDocument;
                
                list<Enrollment_Document__c> eds = [select id,Status_Reason__c,Type__c, Program_Enrollment__c from Enrollment_Document__c where Uploader__c = :UserInfo.getUserId() AND Type__c = :affiliationList[0].Enrollment_Component__r.Document_Type__c AND Program_Enrollment__c = :programEnrollmentId];
                System.debug('the ed size:' + eds.size());
                // Added code for the bug #164337 on 07/05/2020
                //--Changes start here for Invalid-Reenrollment for the defect #246464 on 15/09/2020
                // Added code for the Defect #298246 on 7/10/2020
				if (eds.size() == 1 && ((eds[0].Type__c =='Report Card' && enrollmentDocument.Type__c=='Report Card') || (eds[0].Type__c =='Home School Prior Academic History' && enrollmentDocument.Type__c=='Home School Prior Academic History'))){
				   insert enrollmentDocument;
                   fileReference = createFileReferences(documentLink, enrollmentDocument); 
				}
                //End code for the Defect #298246 on 7/10/2020 
				else if (eds.size() == 1 && eds[0].Status_Reason__c == 'Invalid-Reenrollment'){
				   eds[0].Status_Reason__c = 'Submitted';
				   eds[0].Uploader__c = UserInfo.getUserId();
                   eds[0].Submission_Time__c = system.now();
				   update eds;
                   fileReference = createFileReferences(documentLink, eds[0]);
				}
				//--Changes end here Invalid-Reenrollment for the defect #246464 on 15/09/2020
		
                else if (eds.size() > 0) {
                    peakResponse.messages.add('Document is already uploaded for this section. Please click "Skip for now" to proceed to next section');
                    peakResponse.success = FALSE;
                }
                else {
                    System.debug('enrollmentDocument' + enrollmentDocument);
                    insert enrollmentDocument;
                    System.debug('enrollmentDocument' + enrollmentDocument);
                    fileReference = createFileReferences(documentLink, enrollmentDocument); 
                }
                //End code for the bug #147271 on 18/03/2020 
                enrollmentDocumentsToReturn.add(enrollmentDocument);
            }
            
            if(fileReference != null && !fileReference.isEmpty()){
                insert fileReference;
                
                peakResponse.success = TRUE;
                peakResponse.results = enrollmentDocumentsToReturn;
            }
        } catch(Exception e) {
            peakResponse.success = FALSE;
            peakResponse.messages.add(e.getMessage());
            logger.logException('upsertDocumentsAndFileReferences', e);
            logger.saveLogs();
        }
        System.debug('peakResponse' + peakResponse);
        return peakResponse;
    }
    
    /*
Helper method to create File References
*/
    
    public static List<Document_File_References__c> createFileReferences(List<String> documentLinkList, Enrollment_Document__c enrollmentDocument) {
        
        List<Document_File_References__c> existingFileReferences = [
            SELECT Id, Enrollment_Document__c
            FROM Document_File_References__c
            WHERE Enrollment_Document__c = :enrollmentDocument.Id
        ];
        
        List<Document_File_References__c> newFileReferences = new List<Document_File_References__c> ();
        
        for (String theDocumentLink : documentLinkList) {
            
            // Create Document File References
            Document_File_References__c docFileReference = new Document_File_References__c();
            //docFileReference.Name = theDocumentLink;
            docFileReference.File_Path__c = theDocumentLink;
            docFileReference.Date_Uploaded__c = system.now();
            docFileReference.Enrollment_Document__c = enrollmentDocument.Id;
            docFileReference.Version__c = existingFileReferences.size() + 1;
            newFileReferences.add(docFileReference);
        }
        
        return newFileReferences;
    }
    
}