public without sharing class ali_DocCentralHelper {
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
        
        // [149116] ALI KM - NEW CODE START
        Date currentDate = System.today();
        Map<Id, List<Id>> validPEToStagesMap = new Map<Id, List<Id>>();
        Map<Id, Enrollment_Component_Affiliation__c> ecaMap = new Map<Id, Enrollment_Component_Affiliation__c>();
        Map<Id, hed__Program_Enrollment__c> validPEs = new Map<Id, hed__Program_Enrollment__c>();
        Set<Id> peStages = new Set<Id>();

        // Query all qualifyingPEs & related Stage.ECAs with Stage=InProgress
        for(hed__Program_Enrollment__c pe : 
            [SELECT Id, hed__Account__c, Status__c, hed__Contact__r.Name, hed__Account__r.Document_Start_Date__c, hed__Account__r.Document_End_Date__c, RecordTypeId, RecordType.Name,
                (SELECT Id, Name, Status__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Enrollment_component__r.RecordType.Name
                FROM  Enrollment_Component_Affiliation__r
                WHERE Enrollment_component__r.RecordType.Name = :NES_DashboardUtilities.STAGE_RT
                    AND Status__c IN ('In Progress'))
            FROM hed__Program_Enrollment__c  
            WHERE hed__Contact__r.CreatedById = :caretakerId
                // AND Id IN :peToEDsMap.keySet()
                AND Status__c = 'In Progress'
                AND hed__Account__r.Document_Start_Date__c != null AND hed__Account__r.Document_End_Date__c != null
                AND hed__Account__r.Document_Start_Date__c <= :currentDate AND hed__Account__r.Document_End_Date__c >= :currentDate])
        {   

            if(pe.Enrollment_Component_Affiliation__r.size()>0) {

                // collect PEs...
                validPEs.put(pe.Id, pe);

                Set<Id> stages = new Set<Id>();
                System.debug('serialized ECAs::' + JSON.serialize(pe.Enrollment_Component_Affiliation__r));
                for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r) 
                {
                    // collect stages...
                    stages.add(eca.Enrollment_component__r.Id);
                }

                // collect pe => stagesList
                validPEToStagesMap.put(pe.Id, new List<Id>(stages));
                peStages.addAll(stages);

            }
        }
        System.debug(':::validPEs:::' + validPEs.size());
        System.debug(JSON.serialize(validPEs));
        System.debug(':::peStages:::' + peStages.size());
        System.debug(JSON.serialize(peStages));
        System.debug(':::validPEToStagesMap:::' + validPEToStagesMap.size());
        System.debug(JSON.serialize(validPEToStagesMap));
        

        // Collect Stages.children from ECR
        Map<Id, Id> formsToStagesMap = new Map<Id, Id>();
        Map<Id, List<Id>> stagesToDocsMap = new Map<Id, List<Id>>(); // final list we need.
        // Set<Id> allForms = new Set<Id>();
        for (Enrollment_Component_Relationship__c ecr : [
            SELECT Id, Child_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Id, 
                Parent_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Order__c, Parent_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c IN : peStages])
        {
            
            // // collect documents...
            // if (NES_DashboardUtilities.DOCUMENT_RT.equalsIgnoreCase(ecr.Child_Enrollment_Component__r.RecordType.Name)) 
            // {   
            //     List<Id> children = stagesToDocsMap.get(ecr.Parent_Enrollment_Component__c);
            //     if (children==null) {
            //         children = new List<Id>();
            //         stagesToDocsMap.put(ecr.Parent_Enrollment_Component__c, children);
            //     }
            //     children.add(ecr.Child_Enrollment_Component__c);
            // }
            formsToStagesMap.put(ecr.Child_Enrollment_Component__c, ecr.Parent_Enrollment_Component__c);
        }
        System.debug(':::formsToStagesMap:::' + formsToStagesMap.size());
        System.debug(JSON.serialize(formsToStagesMap));
        System.debug(':::stagesToDocsMap:::' + stagesToDocsMap.size());
        System.debug(JSON.serialize(stagesToDocsMap));
        

        // Collect Stages.Forms.children from ECR
        Map<Id, Id> childToParentMap = new Map<Id, Id>();
        for (Enrollment_Component_Relationship__c ecr : [
            SELECT Id, Child_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name, Parent_Enrollment_Component__r.Id, 
                Parent_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Order__c, Parent_Enrollment_Component__c
            FROM Enrollment_Component_Relationship__c
            WHERE Parent_Enrollment_Component__c IN : formsToStagesMap.keySet()])
        {
            
            // collect documents...
            if (NES_DashboardUtilities.DOCUMENT_RT.equalsIgnoreCase(ecr.Child_Enrollment_Component__r.RecordType.Name)) 
            {   
                Id stageId = formsToStagesMap.get(ecr.Parent_Enrollment_Component__c);
                List<Id> children = stagesToDocsMap.get(stageId);
                if (children==null) {
                    children = new List<Id>();
                    stagesToDocsMap.put(stageId , children);
                }
                children.add(ecr.Child_Enrollment_Component__c);
            }
            childToParentMap.put(ecr.Child_Enrollment_Component__c, ecr.Parent_Enrollment_Component__c);
        }
        System.debug(':::childToParentMap:::' + childToParentMap.size());
        System.debug(JSON.serialize(childToParentMap));
        System.debug(':::stagesToDocsMap 2:::' + stagesToDocsMap.size());
        System.debug(':::stagesToDocsMap.values():::' + stagesToDocsMap.values());
        System.debug(JSON.serialize(stagesToDocsMap));


        // collect all Doc.EC.IDs
        Set<Id> docECIds = new Set<Id>();
        for (List<Id> docECs : stagesToDocsMap.values()) {
            docECIds.addAll(docECs);
        }
        System.debug(':::docECIds:::' + docECIds.size());
        System.debug(JSON.serialize(docECIds));

        
        list<Enrollment_Component_Affiliation__c> ecaListStatus = new list<Enrollment_Component_Affiliation__c> ();
        for (Enrollment_Component_Affiliation__c eca : [
            SELECT Id, Name, status__c, Enrollment_component__c, Enrollment_component__r.Id, Enrollment_component__r.Name, Program_Enrollment__c, Program_Enrollment__r.hed__Contact__r.Name
            FROM Enrollment_Component_Affiliation__c
            WHERE 
                Program_Enrollment__c IN :validPEs.keySet() 
                AND Enrollment_component__r.Id IN :docECIds
                AND Status__c IN ('Not started', 'Deferred')])
        {
            // collect valid ecas...
            List<Id> tmpPEStages = validPEToStagesMap.get(eca.Program_Enrollment__c);
            for (Id stg : tmpPEStages) {
                List<Id> docList = stagesToDocsMap.get(stg);
                if (docList!=null && docList.size()>0 && docList.contains(eca.Enrollment_component__c)) {
                    ecaListStatus.add(eca);
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
        
        System.assertEquals(true, DocumentStatusMappingMap.size()>0);

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
					String docStatus = doc.Status_Reason__c.contains('-') ? doc.Status_Reason__c.substringBefore('-') : doc.Status_Reason__c;

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
		// Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
		docsWrapper.numberOfNotSubmittedDocs = ecaListStatus.size();
		// End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09

		docsWrapper.mapOfEnrollmentDocuments = mapOfEnrollmentDocuments;
		// Start add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
		docsWrapper.ecaListStatus = ecaListStatus;
		// End add by Maddileti for User Story #102169 (Maddileti Boya) on 2019-09-09
        return JSON.serialize(docsWrapper);

    }
}