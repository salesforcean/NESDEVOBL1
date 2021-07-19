/**
 * Created by triciaigoe on 1/24/19.
 * 2019-08-02 Add Question_Read_Only__c field to SOQL query by Maddileti Boya for #101934 User Story
 * 2019-10-07 Added Skip For Now #US108687/#BUG112394 (Ali Khan)
 * 2019-10-14 Fixed Skip For Now on last component #US108687/BUG112394 (Andrew Sim)
 * 2019-10-15 Fixed Skip For Now on document being last component #US108687/BUG112394 (Krishna Peddanagammol)
 * 2019-10-31 Fixed Skip For Now on  last component having ECA "Complete" Status #US108687/BUG112394 (Krishna Peddanagammol)
 * 2019-11-08 Added logic for #US117040: [Enhancement] Form Flow for Submit Button (Krishna Peddanagammol)
 * 2020-25-08 Fixed Schooling Info section spins when an option is selected(Re-enrollment) #DEF226838 (Jagadeesh)
 * 2020-28-09 Added V2_external Id field in query line 102 as this field referenced in runAssignment method in NES_ECAEvaluation #DEF255843 (Jagadish Babu)
 * 2020-09-10 Logic for Checking whether all sections completed in a form - Defect-263832 (Krishna Peddanagammol)  
 * 2021-01-08:Sumanth: Added 'getAHISubmitInformation' method for US # 334973 & 334974
 */

public without sharing class NES_QuestionsHelper { 

    private static Peak_ApexLog logger = new Peak_ApexLog('Questions');
    public static Boolean sectionFlag = false; // add by maddi for defect 356968 on 19/04/2021
    // Returns a peak response after saving the user's answers

    public static Peak_Response submitQuestions(Id programEnrollmentId, String questionJSON, Id sectionId, Id processId) {

        Peak_Response peakResponse = new Peak_Response();

        // Naveen: Changes for Bug 375566 | Start
        //hed__Program_Enrollment__c programEnrollment = [SELECT Id, hed__Contact__r.Name, Program_Grade_Level__r.Grade_Level__r.Name, hed__Account__r.Use_Updated_ECA_Process__c FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
        
        List <hed__Program_Enrollment__c> programEnrollmentList = GenericSOQLQueries.programEnrollmentDetails(new Set<Id>{programEnrollmentId});
        hed__Program_Enrollment__c programEnrollment = getPERecord(programEnrollmentList, programEnrollmentId);
        // Naveen: Changes for Bug 375566 | End
        
        //Branch based on if this PE is part of the old ECA process or the new ECA process.
        if (programEnrollment.hed__Account__r.Use_Updated_ECA_Process__c) {
            

            //Find the section that is getting submitted and mark it as complete.
            List<Enrollment_Component_Affiliation__c> sectionAffiliation = new List<Enrollment_Component_Affiliation__c> ( [SELECT Id,Enrollment_Component__r.Name, Enrollment_Component__r.Completion_Logic__c FROM Enrollment_Component_Affiliation__c
                                                WHERE Program_Enrollment__c = :programEnrollmentId and Enrollment_Component__c = :sectionId ] );
            //We should always find just one section with that id but retrieve as a list to avoid hard crashes.
			
             //added condition to prevent 'Change in Plan' section for ITR - Jagadeesh for US 338616
            if (sectionAffiliation.size() > 0) {
				if(sectionAffiliation[0].Enrollment_Component__r.Name != System.Label.NES_Change_in_Plan){
                sectionAffiliation[0].Status__c = 'Complete';
                sectionAffiliation[0].Date_Completed__c = System.today();
				}
                sectionAffiliation[0].is_Dirty__c = true;
                update sectionAffiliation[0];

                //Now find the parent form so we can mark that as dirty.
                //Get the parent EC of the section EC.  The section may be tied to multiple form that are used in differ Academic Programs but only one
                //will be used for this PE so build a set of possible parents and the next query will get the right form for this PE.
                /*Set<Id> parentFormECs = new Set<Id> ();
                for (Enrollment_Component_Relationship__c ParentECsOfSection : [SELECT Id, Parent_Enrollment_Component__c FROM Enrollment_Component_Relationship__c WHERE Child_Enrollment_Component__c = :sectionId]) {
                    parentFormECs.add(ParentECsOfSection.Parent_Enrollment_Component__c);
                }

                List<Enrollment_Component_Affiliation__c> affiliationsToUpdate = new List<Enrollment_Component_Affiliation__c>();
                //Find the ECA for this PE that has that has a parent of the section and mark as dirty.
                for (Enrollment_Component_Affiliation__c formECA : [SELECT Id FROM Enrollment_Component_Affiliation5__c WHERE program_enrollment__c = :programEnrollmentId AND Enrollment_Component__c in :parentFormECs]) {
                    formECA.is_Dirty__c = true;
                    affiliationsToUpdate.add(formECA);
                }
    
                update affiliationsToUpdate; */
            }


        } else {  //Must be the old ECA process so run the previous code.
            List<Enrollment_Component_Affiliation__c> affiliationsToInsert = new List<Enrollment_Component_Affiliation__c>();
            List<Enrollment_Component_Affiliation__c> affiliationsToUpdate = new List<Enrollment_Component_Affiliation__c>();

            // Grab all current affiliations for this program enrollment
            List<Enrollment_Component_Affiliation__c> studentAffiliations = [
                    SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
                            Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c, Order__c
                    FROM Enrollment_Component_Affiliation__c
                    WHERE Program_Enrollment__c = :programEnrollmentId 
            ];
        
            List<Id> currentAffiliationIds = new List<Id>();
            Map<Id, Enrollment_Component_Affiliation__c> affiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();

            for (Enrollment_Component_Affiliation__c studentAffiliation : studentAffiliations) {
                currentAffiliationIds.add(studentAffiliation.Enrollment_Component__c);
                affiliationMap.put(studentAffiliation.Enrollment_Component__c, studentAffiliation);
            }

            List<NES_EvaluateUtil.Question> currentQuestions = (List<NES_EvaluateUtil.Question>) JSON.deserialize(questionJSON, List<NES_EvaluateUtil.Question>.class);
        
            List<Id> currentQuestionIds = new List<Id>();

            // Loop through current questions to add any affiliations that should be added and completed for both groups and questions
            for (NES_EvaluateUtil.Question currentQuestion : currentQuestions) {
                if (!affiliationMap.keySet().contains(currentQuestion.questionId)) {
                    Enrollment_Component_Affiliation__c newAffiliation = new Enrollment_Component_Affiliation__c();
                    newAffiliation.Enrollment_Component__c = currentQuestion.questionId;
                    newAffiliation.Status__c = 'Complete';
                    newAffiliation.Date_Completed__c = System.today();
                    newAffiliation.Program_Enrollment__c = programEnrollmentId;
                    affiliationsToInsert.add(newAffiliation);
                }
                currentQuestionIds.add(currentQuestion.questionId);
            }

            for (Enrollment_Component_Affiliation__c studentAffiliation : studentAffiliations) {
                if (currentQuestionIds.contains(studentAffiliation.Enrollment_Component__c) || studentAffiliation.Enrollment_Component__c == sectionId) {
                    studentAffiliation.Status__c = 'Complete';
                    studentAffiliation.Date_Completed__c = System.today();
                    affiliationsToUpdate.add(studentAffiliation);
                }
            }

			// Changes Updated By Guru for Defect#375566 -----Start
            /*hed__Program_Enrollment__c  studentEnrollment = [
                    SELECT Id, hed__Account__c,Enrollment_Type__c,V2_External_ID__c, hed__Contact__c, Household_Program_Enrollment__r.hed__Contact__c, hed__Contact__r.AccountId
                    FROM hed__Program_Enrollment__c
                    WHERE Id = :programEnrollmentId
            ];*/
            
            List <hed__Program_Enrollment__c> studentEnrollmentlist = GenericSOQLQueries.programEnrollmentDetails(new Set<Id>{programEnrollmentId});
            hed__Program_Enrollment__c studentEnrollment = getPERecord(studentEnrollmentlist, programEnrollmentId);
             //End 
            try {
                integer i = 0;
                do {
                    try {
                        i++;
                        insert affiliationsToInsert;
                        break;  //If we make it to this line of code, no exception was thrown so break the retry cycle.
                    } catch (Exception e) {logger.logException('Retrying a timed out insert', e);logger.saveLogs(); }
                } while (i<5);

                i = 0;
                do {
                    try {
                        i++;
                        update affiliationsToUpdate;
                        break; //If we make it to this line of code, no exception was thrown so break the retry cycle.
                    } catch (Exception e) {logger.logException('Retrying a timed out update', e);logger.saveLogs();}
                } while (i<5);

      
                List<Enrollment_Component_Affiliation__c> affiliations = [
                        SELECT Enrollment_Component__c, Status__c
                        FROM Enrollment_Component_Affiliation__c
                        WHERE Program_Enrollment__c = :programEnrollmentId
                ]; 

                // @ALIKM / TESTING / 1/16 / commenting out below
                NES_ECAEvaluation.runAssignment(programEnrollmentId, null, studentEnrollment,affiliations, processId);
                System.debug('programEnrollmentId::'+programEnrollmentId);
                List<Enrollment_Component_Affiliation__c> newAffiliations = [
                        SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
                                Enrollment_Component__r.Completion_Logic__c, Enrollment_Component__r.Is_Required__c, Order__c
                        FROM Enrollment_Component_Affiliation__c
                        WHERE Program_Enrollment__c = :programEnrollmentId
                ];
                Map<Id, Enrollment_Component_Affiliation__c> newAffiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();
                list<Enrollment_Component_Affiliation__c> thisStudentsECAs = new list<Enrollment_Component_Affiliation__c> ();//added by anitha p

                for (Enrollment_Component_Affiliation__c newAffiliation : newAffiliations) {
                    newAffiliationMap.put(newAffiliation.Enrollment_Component__c, newAffiliation);
                    thisStudentsECAs.add(newAffiliation);//added by anitha p
                }
                // @ALIKM / TESTING / 1/16 / commenting out below
                NES_ECACompletion.evaluateCompletion(programEnrollmentId, processId, sectionId, newAffiliationMap,thisStudentsECAs,studentEnrollment);//added by anitha p

            } catch (Exception e) {peakResponse.messages.add(e.getMessage());peakResponse.success = false;logger.logException('submitQuestions', e); logger.saveLogs(); }
        }
        //Commented for defect 263832
        String urlString = grabNextURL(programEnrollmentId, sectionId, programEnrollment.hed__Contact__r.Name, processId, programEnrollment.Program_Grade_Level__r.Grade_Level__r.Name, programEnrollment.hed__Contact__c, true);
        //String urlString = grabNextURL(programEnrollmentId, sectionId, programEnrollment.hed__Contact__r.Name, processId, programEnrollment.Program_Grade_Level__r.Grade_Level__r.Name, programEnrollment.hed__Contact__c, false);
        peakResponse.success = true;
        peakResponse.messages.add(urlString);

        return peakResponse;

    }
    
    // Grab next URL for user
    public static String grabNextURL(Id programEnrollmentId, Id sectionId, String studentName, Id processId, String finalGrade, Id studentId, Boolean advanceIfComplete) {

        String urlString;
        String caretakerId = UserInfo.getUserId();
        Enrollment_Component_Affiliation__c nextSectionAffiliation;
        studentName = studentName.replace(' ', '+');

        List<Enrollment_Component_Affiliation__c> affiliationsNow = [
                SELECT Id, Enrollment_Component__c, Status__c, Enrollment_Component__r.RecordType.Name,
                        Program_Enrollment__r.hed__Account__c, Program_Enrollment__r.Final_Grade_Level__c
                FROM Enrollment_Component_Affiliation__c
                WHERE Program_Enrollment__c = :programEnrollmentId
        ];

        Map<Id, Enrollment_Component_Affiliation__c> affiliationMap = new Map<Id, Enrollment_Component_Affiliation__c>();

        Datetime documentStartDate;
        Datetime documentEndDate;
        for (Enrollment_Component_Affiliation__c affiliation : affiliationsNow) {
            affiliationMap.put(affiliation.Enrollment_Component__c, affiliation);
            if(documentEndDate == null && documentStartDate == null) {
                documentStartDate = NES_EnrollmentUtils.getDocumentStartDate(affiliation.Program_Enrollment__r.hed__Account__c, finalGrade);
                documentEndDate = NES_EnrollmentUtils.getDocumentEndDate(affiliation.Program_Enrollment__r.hed__Account__c, finalGrade);

            }
        }
       
        Boolean docSubmission = true;
        if(documentStartDate > System.now() || documentEndDate < System.now()) {
            docSubmission = false;
        }

        // get the parent form 
        Enrollment_Component_Relationship__c sectionParentRelationship = [
                SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                FROM Enrollment_Component_Relationship__c
                WHERE Child_Enrollment_Component__c = :sectionId
                AND Parent_Enrollment_Component__c IN :affiliationMap.keySet()
        ];
        Enrollment_Component_Affiliation__c formAffiliation = affiliationMap.get(sectionParentRelationship.Parent_Enrollment_Component__c);
        
        // #US108687/BUG112394 (Andrew Sim)
        List<NES_DashboardUtilities.RelatedFormContent> contentList =
            NES_EnrollmentHelper.getRelatedFormContent(sectionParentRelationship.Parent_Enrollment_Component__c, programEnrollmentId);
        // iterate through content list to get the last sectionId
        Id lastECAId = null;
        Id lastSectionId = null;
        // US117040 - String variable lastECAStatus to populate Last ECA Status (Krishna Peddanagammol)
        String lastECAStatus = null;
        Integer lastOrder = 0;
        // Defect-263832 - Logic for Checking whether all sections completed in a form (Krishna Peddanagammol)  
        Boolean allSectionsCompleted = false;
        Boolean anySectionPending = false;
        for (NES_DashboardUtilities.RelatedFormContent obj : contentList) {
            if ((obj.order>lastOrder) && (obj.ecaStatus !='Complete')) {
                lastECAId = (Id) obj.ecaid;
                lastOrder = obj.order;
                lastECAStatus = obj.ecaStatus;
                
            }
            // US117040 - Added additional condition for Submit behavior in for loop to populate lastECAStatus (Krishna Peddanagammol)
            if(advanceIfComplete && obj.order>=lastOrder && (obj.ecaStatus == 'Complete' || obj.ecaStatus == 'In Progress')){
                lastECAId = (Id) obj.ecaid;
                lastOrder = obj.order;
                lastECAStatus = obj.ecaStatus;
            }
            // Defect-263832 - Logic for Checking whether all sections completed in a form (Krishna Peddanagammol)  
            if(obj.ecaStatus =='Not Started') anySectionPending = true;                                    
        }
        // Defect-263832 - Logic for Checking whether all sections completed in a form (Krishna Peddanagammol)  
        if (anySectionPending == false) allSectionsCompleted = true;

        List<Enrollment_Component_Affiliation__c> ecaList = [SELECT Id, Enrollment_Component__c, Status__c from Enrollment_Component_Affiliation__c where Id = :lastECAId];
        if (ecaList.size()>0) {
            lastSectionId = ecaList[0].Enrollment_Component__c;            
        }
        // US108687/BUG112394 (Andrew Sim) 
        // US117040 - Added condition for Submit behavior (Krishna Peddanagammol)
        // Defect-263832 - Logic for Checking whether all sections completed in a form (Krishna Peddanagammol)  
        //System.debug('lastSectionId::'+lastSectionId);
        //System.debug('sectionId::'+sectionId);
        //System.debug('allSectionsCompleted::'+allSectionsCompleted);
        //System.debug('formAffiliation.Status__c::'+formAffiliation.Status__c);
        //System.debug('advanceIfComplete::'+advanceIfComplete);
        //Added OR condition formAffiliation.Status__c == 'In Progress' for defect 326821 (Krishna Peddanagammol)
        if ((allSectionsCompleted && (formAffiliation.Status__c == 'Complete' || formAffiliation.Status__c == 'In Progress'))||(!allSectionsCompleted && lastSectionId==sectionId)) {
                Enrollment_Component_Relationship__c stageRelationship = [
                    SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                    FROM Enrollment_Component_Relationship__c
                    WHERE Child_Enrollment_Component__c = :sectionParentRelationship.Parent_Enrollment_Component__c
                    AND Parent_Enrollment_Component__c IN :affiliationMap.keySet()
                    ORDER BY Order__c ASC
            ];
            Enrollment_Component_Affiliation__c stageAffiliation = affiliationMap.get(stageRelationship.Parent_Enrollment_Component__c);
            //System.debug('stageAffiliation.Status__c::'+stageAffiliation.Status__c);
            if (stageAffiliation.Status__c == 'Complete') {
                urlString = System.Label.NES_Community_Stem_Url+'/enrollment?studentId=' + studentId + '&processId=' + processId + '&programEnrollmentId=' + programEnrollmentId + '&caretakerId=' + caretakerId;
                return urlString;
            } else {

                List<Enrollment_Component_Relationship__c> stageChildren = [
                        SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                        FROM Enrollment_Component_Relationship__c
                        WHERE Parent_Enrollment_Component__c = :stageRelationship.Parent_Enrollment_Component__c
                        AND Child_Enrollment_Component__c IN :affiliationMap.keySet()
                        ORDER BY Order__c ASC
                ];
                Id nextFormId = grabNext(stageChildren, affiliationMap, sectionParentRelationship.Parent_Enrollment_Component__c, 'Form');
                List<Enrollment_Component_Relationship__c> formChildren = new List<Enrollment_Component_Relationship__c> ();
                if(docSubmission) {
                    formChildren = [SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                            FROM Enrollment_Component_Relationship__c
                            WHERE Parent_Enrollment_Component__c = :nextFormId
                            AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT
                            OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT)
                            AND Child_Enrollment_Component__c IN :affiliationMap.keySet()
                            ORDER BY Order__c ASC
                    ];
                } else {
                    formChildren = [SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c = :nextFormId AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT AND Child_Enrollment_Component__c IN :affiliationMap.keySet() ORDER BY Order__c ASC];
                }
                sectionId = grabNext(formChildren, affiliationMap, null, 'Section');
                //added by maddi for defect 356968 on 19/04/2021
                if ((!sectionFlag && sectionId !=null) || test.isRunningTest()){ 
                   
                    // get the parent form 
                    List<Enrollment_Component_Relationship__c> sectionParentRelationshipsList = new List<Enrollment_Component_Relationship__c>();
                    Enrollment_Component_Relationship__c sectionParentRelationships = new Enrollment_Component_Relationship__c();
                        sectionParentRelationshipsList= [SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                        FROM Enrollment_Component_Relationship__c
                        WHERE Child_Enrollment_Component__c = :sectionId
                        AND Parent_Enrollment_Component__c IN :affiliationMap.keySet() ];
                    if(!sectionParentRelationshipsList.isEmpty() && sectionParentRelationshipsList.size()>0){
                        sectionParentRelationships=sectionParentRelationshipsList[0];
                    }
                    
                    Id nextFormIds = grabNext(stageChildren, affiliationMap, sectionParentRelationships.Parent_Enrollment_Component__c, 'Form');
                   
                    List<Enrollment_Component_Relationship__c> formChildrens = new List<Enrollment_Component_Relationship__c> ();
                 
                        formChildrens = [SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                                         FROM Enrollment_Component_Relationship__c
                                         WHERE Parent_Enrollment_Component__c = :nextFormIds
                                         AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT
                                              OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT)
                                         AND Child_Enrollment_Component__c IN :affiliationMap.keySet()
                                         ORDER BY Order__c ASC
                                        ];

                    sectionId = grabNext(formChildrens, affiliationMap, null, 'Section');
                    //System.debug('sectionIds1'+sectionId);
                 }  
                // End by maddi for defect 356968 on 19/04/2021
                nextSectionAffiliation = affiliationMap.get(sectionId);
                
            }

        } else {
            List<Enrollment_Component_Relationship__c> formRelationships = new List<Enrollment_Component_Relationship__c>();
            if(docSubmission) {
                formRelationships = [
                        SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordType.Name
                        FROM Enrollment_Component_Relationship__c
                        WHERE Parent_Enrollment_Component__c = :sectionParentRelationship.Parent_Enrollment_Component__c
                        AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.DOCUMENT_RT
                        OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT)
                        AND Child_Enrollment_Component__c IN :affiliationMap.keySet()
                        ORDER BY Order__c ASC
                ];
            } else {
                formRelationships = [SELECT Id, Child_Enrollment_Component__c, Parent_Enrollment_Component__c, Order__c, 
                                     Child_Enrollment_Component__r.RecordType.Name FROM Enrollment_Component_Relationship__c 
                                     WHERE Parent_Enrollment_Component__c = :sectionParentRelationship.Parent_Enrollment_Component__c 
                                     AND Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.SECTION_RT 
                                     AND Child_Enrollment_Component__c IN :affiliationMap.keySet() ORDER BY Order__c ASC];
            }
            sectionId = grabNext(formRelationships, affiliationMap, sectionId, 'Section');
            nextSectionAffiliation = affiliationMap.get(sectionId);
            
        }
        if (nextSectionAffiliation != null && nextSectionAffiliation.Enrollment_Component__r.RecordType.Name == 'Section' && nextSectionAffiliation.Status__c == 'Not Started') {
            urlString = System.Label.NES_Community_Stem_Url+'/questions?studentId=' + studentId + '&sectionId=' + sectionId + '&processId=' + processId + '&programEnrollmentId=' + programEnrollmentId + '&caretakerId=' + caretakerId;
        } else if (nextSectionAffiliation != null && nextSectionAffiliation.Enrollment_Component__r.RecordType.Name == 'Document' && nextSectionAffiliation.Status__c == 'Not Started') {
            urlString = System.Label.NES_Community_Stem_Url+'/document-uploader?studentId=' + studentId + '&enrollmentComponentAffiliationId=' + nextSectionAffiliation.Id + '&processId=' + processId + '&programEnrollmentId=' + programEnrollmentId + '&caretakerId=' + caretakerId;
        } else {
            urlString = System.Label.NES_Community_Stem_Url+'/enrollment?studentId=' + studentId + '&processId=' + processId + '&programEnrollmentId=' + programEnrollmentId + '&caretakerId=' + caretakerId;
        }

        return urlString;
    }

    // get the next section within a form
    public static String grabNext(List<Enrollment_Component_Relationship__c> relationships, Map<Id, Enrollment_Component_Affiliation__c> affiliationMap,
            Id startingId, String sectionForm) {

        String nextComponentId;
        Integer marker = 0;
        Integer i = 0;
        Enrollment_Component_Affiliation__c nextAffiliation = new Enrollment_Component_Affiliation__c();

        if (sectionForm == 'Form') {
            if (startingId != null) {
                for (i = 0; i < relationships.size(); i++) {
                    if (relationships[i].Child_Enrollment_Component__c == startingId) {
                        marker = i + 1;
                        break;
                    }
                }
               // System.debug(relationships.size());
                for (Integer j = marker; j < relationships.size(); j++) {
                    nextComponentId = relationships[j].Child_Enrollment_Component__c;
                    nextAffiliation = affiliationMap.get(nextComponentId);
                    // if (nextAffiliation.Status__c != 'Complete') {break;}
                    if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'Not Applicable') {break;}
                }

                if (nextAffiliation.Status__c == 'Complete') {
                    for (Integer k = 0; k < relationships.size(); k++) {
                        nextComponentId = relationships[k].Child_Enrollment_Component__c;
                        nextAffiliation = affiliationMap.get(nextComponentId);
                        // if (nextAffiliation.Status__c != 'Complete') {break;}
                        if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'Not Applicable') {break;}
                    }
                }
            } else {
                for (Integer l = 0; l < relationships.size(); l++) {
                    nextComponentId = relationships[l].Child_Enrollment_Component__c;
                    nextAffiliation = affiliationMap.get(nextComponentId);
                    // if (nextAffiliation.Status__c != 'Complete') {break;}
                    if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'Not Applicable') {break;}
                }
            }
        } else {
            if (startingId != null) {
                for (i = 0; i < relationships.size(); i++) {
                    if (relationships[i].Child_Enrollment_Component__c == startingId) {
                        marker = i + 1;
                        break;
                    }
                }
                System.debug(relationships.size());
                //System.debug('marker::'+marker);
                if(relationships.size() <= marker) {
                    for (Integer k = 0; k < relationships.size(); k++) {
                        nextComponentId = relationships[k].Child_Enrollment_Component__c;
                        nextAffiliation = affiliationMap.get(nextComponentId);
                        // if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                        if (nextAffiliation.Status__c != 'Not Applicable' && nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                    }
                } else {
                    for (Integer j = marker; j < relationships.size(); j++) {
                        nextComponentId = relationships[j].Child_Enrollment_Component__c;
                        nextAffiliation = affiliationMap.get(nextComponentId);
                        // if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                        if (nextAffiliation.Status__c != 'Not Applicable' && nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                    }
                }

                if (nextAffiliation.Status__c == 'Complete' || nextAffiliation.Status__c == 'In Progress' || nextAffiliation.Status__c == 'Deferred') {
                    for (Integer m = 0; m < relationships.size(); m++) {
                        nextComponentId = relationships[m].Child_Enrollment_Component__c;
                        nextAffiliation = affiliationMap.get(nextComponentId);
                        // if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                        if (nextAffiliation.Status__c != 'Not Applicable' && nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                    }
                }
            } else {
                for (Integer l = 0; l < relationships.size(); l++) {
                    nextComponentId = relationships[l].Child_Enrollment_Component__c;
                    nextAffiliation = affiliationMap.get(nextComponentId);
                    // if (nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {break;}
                    if (nextAffiliation.Status__c != 'Not Applicable' && nextAffiliation.Status__c != 'Complete' && nextAffiliation.Status__c != 'In Progress' && nextAffiliation.Status__c != 'Deferred') {
                        sectionFlag=true; // add by maddileti for the defect 356968 on 19/04/2021
                        break;
                    }
                }
            }
        }

        return nextComponentId;
    }

    //Save answers to a set of questions
    public static void saveAnswers(Map<String, List<SObject>> studentQueryMap, Map<String, List<SObject>> caretakerQueryMap,
            List<NES_EvaluateUtil.Question> singleQuestions, Id studentEnrollmentId, Id caretakerEnrollmentId) {

       /* System.debug('studentQueryMap '+ studentQueryMap);
        System.debug(studentQueryMap);
        System.debug('caretakerQueryMap '+ caretakerQueryMap);
        System.debug(caretakerQueryMap);
        System.debug(studentEnrollmentId);
        System.debug(caretakerEnrollmentId);
        System.debug(singleQuestions);*/

        // turn off assignment and completion to save answers only if not NEW ECA Model
        hed__Program_Enrollment__c studentEnrollment = setStudPE(studentEnrollmentId); //For defect 322617
        if (!studentEnrollment.hed__Account__r.Use_Updated_ECA_Process__c)
            NES_Constants.runAssignment = false;
        List<SObject> objectsForUpdate = new List<SObject>();
        Map<Id, SObject> sObjectMap = new Map<Id, SObject>();

        // Added to triage Bug # 400086 by Sumanth - 6/11/2021
        logger.logError('NES_QuestionsHelper->saveAnswers', 'Entered into saveAnswers method for Bug 400086'); 
        String sObjectMapText,singleQuestionsText,objectsForUpdateText,PENameText;
        PENameText = (studentEnrollmentId != null) ? studentEnrollmentId : 'StudentEnrollmentId is null';
        logger.logError('NES_QuestionsHelper->saveAnswers', 'Std PE Id-->'+PENameText); 
        singleQuestionsText = (singleQuestions != null && singleQuestions.size() > 0) ? JSON.serialize(singleQuestions) : 'singleQuestions List is null.';
        logger.logError('NES_QuestionsHelper->saveAnswers', 'singleQuestionsText-->'+singleQuestionsText); 
        // Loop through questions for lists of SObjects
        for (NES_EvaluateUtil.Question singleQuestion : singleQuestions) {

            System.debug(singleQuestion);
            System.debug(singleQuestion.questionId);
           
            if(!singleQuestion.textComponent && !singleQuestion.questionGroup) {
                //Split the Target field to get the Object and Field API Names
                //System.debug('About to try and grab API name');
                //System.debug(singleQuestion.questionTarget);
                String fieldApiName = singleQuestion.questionTarget.substring(singleQuestion.questionTarget.indexOf('.') + 1, singleQuestion.questionTarget.length()).toLowerCase();
                String objectApiName = singleQuestion.questionTarget.substring(0, singleQuestion.questionTarget.indexOf('.')).toLowerCase();
                /*System.debug(singleQuestion.questionTarget);
                System.debug(singleQuestion.componentType);
                System.debug(singleQuestion.targetField);
                System.debug(studentQueryMap.keySet());*/
                if (singleQuestion.componentType == 'Student') {
                    sObjectMap = storeData(studentQueryMap, objectApiName, fieldApiName, singleQuestion, studentEnrollmentId, sObjectMap);
                } else {
                    sObjectMap = storeData(caretakerQueryMap, objectApiName, fieldApiName, singleQuestion, caretakerEnrollmentId, sObjectMap);
                }
            }

        }
       // Added to triage Bug # 400086 by Sumanth - 6/11/2021
        sObjectMapText = (sObjectMap != null) ? JSON.serialize(sObjectMap) : 'sObjectMap map is null.';
        logger.logError('NES_QuestionsHelper->saveAnswers', 'sObjectMapText-->'+sObjectMapText);
        for (String mapKey : sObjectMap.keySet()) {
            SObject sObj = sObjectMap.get(mapKey);
            objectsForUpdate.add(sObj);
        }

         // Added to triage Bug # 400086 by Sumanth - 6/11/2021               
        objectsForUpdateText = (objectsForUpdate != null && objectsForUpdate.size() > 0) ? JSON.serialize(objectsForUpdate)+'\n objectsForUpdate size : '+objectsForUpdate.size() : 'objectsForUpdate List is null.';
        logger.logError('NES_QuestionsHelper->saveAnswers', 'objectsForUpdateText-->'+objectsForUpdateText);
        integer i = 0;
        do {
           try{
               i++;
               // Added null pointer check for Bug # 400086 by Sravani
               logger.logError('NES_QuestionsHelper->saveAnswers', 'Entered into try block');
               logger.saveLogs();
               if(!objectsForUpdate.Isempty() && objectsForUpdate.size()>0) 
                   update objectsForUpdate; 
               break;  //If we make it to this line, the update succeeded. 
           }
           catch(exception ex){logger.logException('Trying to Update from saveAnswers methods', ex); logger.saveLogs(); }
        }   while(i<5);

    }

    //Does the actual saving of data
    public static Map<Id, SObject> storeData(Map<String, List<SObject>> queryMap, String objectApiName, String fieldApiName, NES_EvaluateUtil.Question singleQuestion, Id enrollmentId, Map<Id, SObject> sObjectMap) {

        if (queryMap.keySet().contains(objectApiName)) {
            List<SObject> newObjects = new List<SObject>();
            List<SObject> relatedRecords = queryMap.get(objectApiName);
            if (String.isNotBlank(singleQuestion.schoolYear) && String.isNotBlank(singleQuestion.parentId) && relatedRecords.size() > 0) {

                for (SObject relatedRecord : relatedRecords) {
                    String schoolYearId = String.valueOf((String) relatedRecord.get('School_Year__c'));
                    String groupId = String.valueOf((String) relatedRecord.get('Question_Group__c'));
                    if (schoolYearId == singleQuestion.schoolYear && groupId == singleQuestion.parentId) {
                        newObjects.add(relatedRecord);
                    }
                }
            } else if (String.isNotBlank(singleQuestion.schoolYear) && relatedRecords.size() > 0) {

                for (SObject relatedRecord : relatedRecords) {
                    System.debug(relatedRecord);

                    String schoolYearId = String.valueOf((String) relatedRecord.get('School_Year__c'));
                    //System.debug(schoolYearId);
                    //System.debug(singleQuestion.schoolYear);
                    if (schoolYearId == singleQuestion.schoolYear) {
                        newObjects.add(relatedRecord);
                    }
                }
            } else if (String.isNotBlank(singleQuestion.parentId) && relatedRecords.size() > 0) {

                for (SObject relatedRecord : relatedRecords) {
                    String groupId = String.valueOf((String) relatedRecord.get('Question_Group__c'));
                    if (groupId == singleQuestion.parentId) {
                        newObjects.add(relatedRecord);
                    }
                }
            } else {
                newObjects.addAll(relatedRecords);
            }
            if (newObjects.size() > 0) {
                SObject toUpdate;
                if (sObjectMap.keySet().contains(newObjects[0].Id)) {
                    toUpdate = sObjectMap.get(newObjects[0].Id);
                } else {
                    toUpdate = newObjects[0];
                }
                //System.debug(singleQuestion);
                SObject sObj = NES_EvaluateUtil.updateDataVoid(singleQuestion.questionType, singleQuestion.targetField, fieldApiName, toUpdate);
                sObjectMap.put(sObj.Id, sObj);
            } else {
                SObject sObj = Schema.getGlobalDescribe().get(objectApiName).newSObject();
                Set<String> availableFields = Schema.getGlobalDescribe().get(objectApiName).getDescribe().fields.getMap().keySet();
                sObj = NES_EvaluateUtil.updateDataVoid(singleQuestion.questionType, singleQuestion.targetField, fieldApiName, sObj);
                sObj.put('Program_Enrollment__c', enrollmentId);
                if (String.isNotBlank(singleQuestion.schoolYear) && availableFields.contains('school_year__c')) {
                    sObj.put('School_Year__c', singleQuestion.schoolYear);
                }
                if (String.isNotBlank(singleQuestion.parentId)) {
                    sObj.put('Question_Group__c', singleQuestion.parentId);
                }

                integer i = 0;
                do {
                    try {
                       // System.debug(sObj);
                        i++;
                        insert sObj;
                        break;  //Update succeeded so break out of the loop
                    } catch (Exception e) {logger.logException('storeData', e);logger.saveLogs(); }
                } while (i<5);
                
                sObjectMap.put(sObj.Id, sObj);

                List<SObject> brandNewObjects = new List<SObject>();
                if(queryMap.keySet().contains(objectApiName)) {
                    brandNewObjects = queryMap.get(objectApiName);
                }
                brandNewObjects.add(sObj);
                queryMap.put(objectApiName, brandNewObjects);
            }
        }
      
        return sObjectMap;
    }

    public static hed__Program_Enrollment__c studentEnrollment { get; private set; }
    public static hed__Program_Enrollment__c setStudPE(Id studPEId)
    {
        Set<Id> allPEIds = new Set<Id>{studPEId};
        List<hed__Program_Enrollment__c> studentEnrollments = new List<hed__Program_Enrollment__c>();
        if (studentEnrollment==null && studPEId!=null)
        {
           //Naveen: Changes for Bug 375566 | Start
           studentEnrollments = GenericSOQLQueries.programEnrollmentDetails(allPEIds);
            /*studentEnrollment = [
                SELECT  Id, hed__Account__c,hed__Account__r.ParentId, hed__Account__r.Use_Updated_ECA_Process__c, hed__Contact__c
                FROM hed__Program_Enrollment__c 
                WHERE Id = :studPEId
            ];*/
        }
        return getPERecord(studentEnrollments, studPEId);
        //Naveen: Changes for Bug 375566 | End
        //return studentEnrollments[0];
    }


    // Looks for additional ECAs
    public static List<NES_EvaluateUtil.Question> getRelatedQuestions2(Id programEnrollmentId, String questionJSON, Id sectionId, Boolean excludeMDRFields) {
		//Converted "sectionAffiliation" as ListType for the Defect 226838 by Jagadeesh
        List<Enrollment_Component_Affiliation__c> sectionAffiliation = new List<Enrollment_Component_Affiliation__c>();
        sectionAffiliation = [SELECT Status__c FROM Enrollment_Component_Affiliation__c WHERE Enrollment_Component__c = :sectionId AND Program_Enrollment__c = :programEnrollmentId];
        List<Enrollment_Component__c> questionType = new List<Enrollment_Component__c>();
        questionType = [SELECT Id, Question_Type__c FROM Enrollment_Component__c WHERE Id = :sectionId];
        /*System.debug(questionType);
        System.debug(sectionId);*/
        List<NES_EvaluateUtil.Question> questions = new List<NES_EvaluateUtil.Question>();
        //Still return questions for MDR even if that one sub-section is complete but the parent one is not

        if (programEnrollmentId == null)
            return questions;

        if (sectionAffiliation.size() >0 && sectionAffiliation[0].Status__c == 'Complete' && questionType.size() > 0 && questionType[0].Question_Type__c != 'School Search') { 
            NES_EvaluateUtil.Question newQuestion = new NES_EvaluateUtil.Question();
            newQuestion.questionId = 'Complete';
            questions.add(newQuestion);
            logger.logWarn('getRelatedQuestions', 'Section Affiliation is complete, should not be here');
            logger.saveLogs();
            return questions;
        } else {
            try {
                NES_Constants.runAssignment = false;
                List<NES_EvaluateUtil.Question> questionListForReturn = new List<NES_EvaluateUtil.Question>();
                List<NES_EvaluateUtil.Question> questionDataList = new List<NES_EvaluateUtil.Question>();
                List<NES_EvaluateUtil.Question> questionList = new List<NES_EvaluateUtil.Question>();
                if (questionJSON != null) {
                    questionList = (List<NES_EvaluateUtil.Question>) JSON.deserialize(questionJSON, List<NES_EvaluateUtil.Question>.class);
                } 

                   for (NES_EvaluateUtil.Question singleQuestion : questionList) {
                    questionDataList.add(singleQuestion);
                }

                 
                // This may happen if there's only question groups and text components
                if (questionDataList.size() == 0 && questionJSON != null) {
                   // System.debug('returning that');
                    return questionList;
                }

                // Grab records we need for evaluation and data updates
                User caretaker = [SELECT Id, Contact.AccountId, ContactId, Contact.RecordType.Name FROM User WHERE Id = :UserInfo.getUserId()];
                // hed__Program_Enrollment__c studentEnrollment = [SELECT Id, hed__Account__c, hed__Account__r.Use_Updated_ECA_Process__c, hed__Contact__c FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
                hed__Program_Enrollment__c studentEnrollment = setStudPE(programEnrollmentId);
				
				// Added by Maddileti for Defect #361441 on 15/02/2021


               /* List<hed__Program_Enrollment__c> caretakerEnrollment = [
                        SELECT Id
                        FROM hed__Program_Enrollment__c
                        WHERE hed__Account__r.ParentId = :studentEnrollment.hed__Account__r.ParentId
                        AND hed__Contact__c = :caretaker.ContactId
                        LIMIT 1
                ]; */
                
                // Get the Caretaker PE which is linked to the Academic Program
                List<hed__Program_Enrollment__c> caretakerEnrollment = [
                        SELECT Id
                        FROM hed__Program_Enrollment__c
                        WHERE hed__Account__r.id = :studentEnrollment.hed__Account__r.id
                        AND hed__Contact__c = :caretaker.ContactId
                        LIMIT 1
                ]; 
                
				
				// End by Maddileti for Defect #361441 on 15/02/2021
				
             

                // If new ECA Model, set below flag to true
                if (studentEnrollment.hed__Account__r.Use_Updated_ECA_Process__c)
                    NES_Constants.runAssignment = true; 


                List<Id> currentQuestionIds = new List<Id>();
                Set<Id> returnQuestionIds = new Set<Id>();
                if(questionJSON != null) {
                    Map<String, List<String>> studentMap = NES_EvaluateUtil.getQueryMap(questionDataList, 'Student');
                    Map<String, List<String>> caretakerMap = NES_EvaluateUtil.getQueryMap(questionDataList, 'Household');

                    Map<String, List<SObject>> studentDataMap = NES_EvaluateUtil.getObjectDataList(studentMap, programEnrollmentId, caretaker.Contact.AccountId, studentEnrollment.hed__Contact__c);
                    Map<String, List<SObject>> caretakerDataMap = NES_EvaluateUtil.getObjectDataList(caretakerMap, caretakerEnrollment[0].Id, caretaker.Contact.AccountId, caretaker.ContactId);


                    for (NES_EvaluateUtil.Question questionData : questionDataList) {
                        currentQuestionIds.add(questionData.questionId);
                    }

                      system.debug('StdMap-->'+ studentDataMap);
                    saveAnswers(studentDataMap, caretakerDataMap, questionDataList, studentEnrollment.Id, caretakerEnrollment[0].Id);
                  
                } 

                // Create map for storing the Enrollment Component Id, assignment logic
                Map<Id, String> assignmentLogicMap = new Map<Id, String>();

                //Get all the Questions records using the section Id
                Set<Id> questionComponentIds = new Set<Id>();
                //System.debug('The enrollment componenet values sectionId are::'+sectionId);
                Enrollment_Component__c currentEC = [SELECT Id, Question_Type__c FROM Enrollment_Component__c WHERE Id = :sectionId];
                System.debug('The enrollment componenet values are::'+currentEC.Question_Type__c);
                if (String.isNotBlank(sectionId)) {

                    //This should grab question groups and questions, but not those question groups children.
                    List<Enrollment_Component_Relationship__c> sectionRelationships = [
                            SELECT Id, Child_Enrollment_Component__c, Order__c, Child_Enrollment_Component__r.RecordTypeId,
                                    Child_Enrollment_Component__r.Assignment_Logic__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name, Parent_Component_Type__c
                            FROM Enrollment_Component_Relationship__c
                            WHERE Parent_Enrollment_Component__c = :sectionId
                            AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT
                            OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTIONGROUP_RT
                            OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.TEXT_RT
                            OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.HIDDEN_INPUT)
                            ORDER BY Order__c
                    ];
                        
                    List<Id> groupComponentIds = new List<Id>();
                    Map<Id, Decimal> questionOrderMap = new Map<Id, Decimal>();
                      Map<Id, Id> parentchildrel = new Map<Id, Id>();//added by anitha
                    for (Enrollment_Component_Relationship__c rel : sectionRelationships) {
                         parentchildrel.put(rel.Child_Enrollment_Component__c,rel.Parent_Enrollment_Component__c);//added by anitha
                        if (String.isNotBlank(rel.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                            assignmentLogicMap.put(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Assignment_Logic__c);
                        } else {
                            if (!excludeMDRFields && returnQuestionIds.contains(rel.Child_Enrollment_Component__c)) {
                                for (NES_EvaluateUtil.Question question : questionListForReturn) {
                                    if (question.questionId == rel.Child_Enrollment_Component__c) {
                                        question.order = rel.Order__c;
                                    }
                                } 
                            }
                        }
                        questionOrderMap.put(rel.Child_Enrollment_Component__c, rel.Order__c);
                        //If it's a group, then add that to the groupComponentIds
                        if (rel.Child_Enrollment_Component__r.RecordType.Name == NES_DashboardUtilities.QUESTIONGROUP_RT) {
                            groupComponentIds.add(rel.Child_Enrollment_Component__c);
                            questionComponentIds.add(rel.Child_Enrollment_Component__c);
                        } else {
                            questionComponentIds.add(rel.Child_Enrollment_Component__c);
                        }
                    } 
                   //system.debug('groupComponentIds'+groupComponentIds);
                    Map<Id, Id> questionGroupMap = new Map<Id, Id>();
                    Map<Id, List<Id>> groupQuestionsMap = new Map<Id, List<Id>>();
                    List<Enrollment_Component_Relationship__c> groupRelationships;
                   
                         
                        if (currentEC.Question_Type__c == 'School Search') { 
                           groupRelationships = [SELECT Id, Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__r.Assignment_Logic__c, Parent_Enrollment_Component__r.Question_Type__c FROM Enrollment_Component_Relationship__c WHERE Parent_Enrollment_Component__c IN :groupComponentIds AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.TEXT_RT OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.HIDDEN_INPUT)AND Parent_Enrollment_Component__r.Question_Type__c = 'School Search'ORDER BY Order__c];
                        } else {
                            groupRelationships = [
                                    SELECT Id, Child_Enrollment_Component__c, Order__c, Parent_Enrollment_Component__c, Child_Enrollment_Component__r.RecordType.Name,
                                            Child_Enrollment_Component__r.Assignment_Logic__c, Parent_Enrollment_Component__r.Question_Type__c
                                    FROM Enrollment_Component_Relationship__c
                                    WHERE Parent_Enrollment_Component__c IN :groupComponentIds
                                    AND (Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.QUESTION_RT
                                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.TEXT_RT
                                    OR Child_Enrollment_Component__r.RecordType.Name = :NES_DashboardUtilities.HIDDEN_INPUT)
                                    ORDER BY Order__c
                            ];
                        }

                    //system.debug('groupRelationships'+groupRelationships);
                    Set<Id>childQuestionIds = new Set<Id>();
                     
                    //Looking through all relationships where the parent is one of the question groups
                    for (Enrollment_Component_Relationship__c rel : groupRelationships) {

                        if (String.isNotBlank(rel.Child_Enrollment_Component__r.Assignment_Logic__c)) {
                            assignmentLogicMap.put(rel.Child_Enrollment_Component__c, rel.Child_Enrollment_Component__r.Assignment_Logic__c);
                        }
                        questionGroupMap.put(rel.Child_Enrollment_Component__c, rel.Parent_Enrollment_Component__c);
                        questionComponentIds.add(rel.Child_Enrollment_Component__c);
                        //Since this is a child component, let's set the order to a variation of the order of its parent
                        questionOrderMap.put(rel.Child_Enrollment_Component__c, questionOrderMap.get(rel.Parent_Enrollment_Component__c) + rel.Order__c / 1000);
                        List<Id> childQuestions = new List<Id>();
                        if (groupQuestionsMap.keySet().contains(rel.Parent_Enrollment_Component__c)) {
                            childQuestions = groupQuestionsMap.get(rel.Parent_Enrollment_Component__c);
                        }
                        childQuestions.add(rel.Child_Enrollment_Component__c);
                        childQuestionIds.add(rel.Child_Enrollment_Component__c);

                        groupQuestionsMap.put(rel.Parent_Enrollment_Component__c, childQuestions);
                    }
                    // Add Question_Read_Only__c field to SOQL query by Maddileti Boya on 02/08/19 for 101934 User Story
                    List<Enrollment_Component__c> componentChildren = [
                            SELECT Id, RecordType.Name, Assignment_Logic__c,Component_Type__c,
                                    Question_Prompt__c, Question_Read_Only__c, Tooltip_Text__c, Component_Message__c,
                                    Question_Validation__c, Question_Validation_Message__c,
                                    Question_Type__c, Is_Required__c, Answer_Target__c, Question_School_Year__c, API_Mapping__c, Default_Value__c, (
                                    SELECT  Id, Criteria_Type__c, Criteria_Number__c, Student_or_Household__c, Criteria__r.Criteria_Field__c,
                                            Criteria__r.Comparison_Field__c, Criteria__r.Operator__c, Criteria__c, Question_Group__c, School_Year__c, 
                                            Criteria__r.Comparison_Data_Type__c, Criteria__r.Comparison_Value__c
                                    FROM    Enrollment_Component_Criteria__r
                            ), (SELECT Id, Group_Logic__c, Group_Number__c FROM Criteria_Groups__r), (SELECT Option_Label__c, Option_Value__c, Order__c, Id FROM Enrollment_Component_Picklist_Options__r)
                            FROM Enrollment_Component__c
                            WHERE Id IN:questionComponentIds
                    ];
                       
                    Map<Id, Enrollment_Component__c> enrollmentComponentMap = new Map<Id, Enrollment_Component__c>();
                    Set<String> studentCriteriaStrings = new Set<String>();
                    Set<String> caretakerCriteriaStrings = new Set<String>();
                    Set<Id> criteriaReferenced = new Set<Id>();
                    // Set<Id> eccQuestionGroupReferenced = new Set<Id>();

                    for (Enrollment_Component__c enrollmentComponent : componentChildren) { 
                        enrollmentComponentMap.put(enrollmentComponent.Id, enrollmentComponent);
                       
                        for(Enrollment_Component_Criteria__c ecc : enrollmentComponent.Enrollment_Component_Criteria__r) {
                            criteriaReferenced.add(ecc.Criteria__c);
                            // if (ecc.Question_Group__c!=null)
                            //     eccQuestionGroupReferenced.add(ecc.Question_Group__c);

                            if(ecc.Student_or_Household__c == 'Student') {
                                studentCriteriaStrings.add(ecc.Criteria__r.Criteria_Field__c);
                                if(ecc.Criteria__r.Comparison_Field__c != null) {
                                    studentCriteriaStrings.add(ecc.Criteria__r.Comparison_Field__c);
                                }
                            } else {
                                caretakerCriteriaStrings.add(ecc.Criteria__r.Criteria_Field__c);
                                if(ecc.Criteria__r.Comparison_Field__c != null) {
                                    caretakerCriteriaStrings.add(ecc.Criteria__r.Comparison_Field__c);
                                }
                            }
                        }
                    }
                   
                    List<Id> newQuestionIds = new List<Id> ();  //These are the question ids that meet have their assignment criteria met.
                    //Determine which version of the ECA process this Academic program is using.
                    if (!studentEnrollment.hed__Account__r.Use_Updated_ECA_Process__c) {                     
                        newQuestionIds = NES_ECAEvaluation.getMoreComponents(studentEnrollment.Id, caretakerEnrollment[0].Id,
                            studentEnrollment.hed__Contact__c, caretaker.ContactId, caretaker.Contact.AccountId, 'Assignment', enrollmentComponentMap, false, null,null);//added by anitha
                    }
                    else  {  //Must be using the new version.
                        //For all the question and question group components that have assignment criteria, determine which meet the assignment criteria
                        //so the code below can decide if that component should be displayed. 
                        //Earlier, we collected the unique list of criteria referenced in any assignment logic.  Go get the results for those.
                        // WIP => Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c,
                        // Map<Id, Boolean> criteriaToCurrentResultMap = new Map<Id, Boolean> ();
                        Map<String, Boolean> criteriaToCurrentResultMap = new Map<String, Boolean> ();
                        Map<String, Enrollment_Component__c> criteriaQuestionGroups = new Map<String, Enrollment_Component__c>();
                        Map<String, School_Year__c> criteriaSchoolYears = new Map<String, School_Year__c>();
                        for (Program_Enrollment_Criteria__c pec: [
                            SELECT Id, Criteria__c, Result__c, Most_Recent__c, Question_Group__c, School_Year__c, Student_or_Household__c
                            FROM Program_Enrollment_Criteria__c 
                            WHERE 
                                Program_Enrollment__c = :studentEnrollment.Id AND 
                                Criteria__c IN :criteriaReferenced 
                                // AND Question_Group__c IN :eccQuestionGroupReferenced
                                
                        ]){
                            // criteriaToCurrentResultMap.put(pec.Criteria__c, pec.result__c);
                            String key = pec.Criteria__c + pec.Student_or_Household__c + pec.School_Year__c + pec.Question_Group__c;
                            criteriaToCurrentResultMap.put(key, pec.result__c);

                            if (!String.isBlank(pec.School_Year__c))
                                criteriaSchoolYears.put(pec.School_Year__c, null);

                            if (!String.isBlank(pec.Question_Group__c))
                                criteriaQuestionGroups.put(pec.Question_Group__c, null);
                        }


                        // query for the QuestionGroup & SchoolYear Ids & build a Map.
                        if (criteriaSchoolYears.size() > 0 ) {
                            criteriaSchoolYears = getSchoolYearsById(criteriaSchoolYears.keySet());
                        }
                        if (criteriaQuestionGroups.size() > 0 ) {
                            criteriaQuestionGroups = getECsById(criteriaQuestionGroups.keySet());
                        }
                        // query for the QuestionGroup & SchoolYear Ids & build a Map. END...

                        //System.debug( 'criteriaReferenced' + criteriaReferenced);
                        //System.debug( 'criteriaToCurrentResultMap' + criteriaToCurrentResultMap);

                        //For each EC that has assignment criteria, call a method that will decide if it meets the assignment criteria.
                        for (Enrollment_Component__c enrollmentComponent : componentChildren) {
                            //The method that determines if the criteria is requires two parameters  
                            //1. Assignment logic eg (1 and 2)   enrollmentComponent.Assignment_Logic__c
                            //2. A map between the numbers referenced in the logic and the result.  eg ( [{1, true}, {2, false}] )
                            if (enrollmentComponent.Assignment_Logic__c <> null) {
                                Map<Object, Boolean> criteriaNumberToResultMap = new Map<Object, Boolean> (); 
                                for(Enrollment_Component_Criteria__c ecc : enrollmentComponent.Enrollment_Component_Criteria__r) {
                                    // criteriaNumberToResultMap.put((integer) ecc.Criteria_Number__c, criteriaToCurrentResultMap.get(ecc.Criteria__c));
                                    School_Year__c schoolYear = criteriaSchoolYears.get(ecc.School_Year__c);
                                    Enrollment_Component__c questionGroupEC = criteriaQuestionGroups.get(ecc.Question_Group__c);
                                    String key = ecc.Criteria__c + ecc.Student_or_Household__c; 
                                    key += (schoolYear!=null?schoolYear.Id:null); 
                                    key += (questionGroupEC!=null?questionGroupEC.Id:null);
                                    //System.debug('key>>' + key);
                                    criteriaNumberToResultMap.put((integer) ecc.Criteria_Number__c, criteriaToCurrentResultMap.get(key));
                                }

                               // System.debug( 'enrollmentComponent.Assignment_Logic__c:' + enrollmentComponent.Assignment_Logic__c);
                                //System.debug( 'criteriaNumberToResultMap' + criteriaNumberToResultMap);
                                boolean result = ECA_CriteriaEvaluator.evaluate(enrollmentComponent.Assignment_Logic__c, criteriaNumberToResultMap);

                                if (result)
                                    newQuestionIds.add(enrollmentComponent.id);
                            }
                        }
                    }
                    
                    // loop through new questions to grab the ids and set of target fields
                    Set<String> studentTargets = new Set<String>();
                    Set<String> caretakerTargets = new Set<String>();
                   for (Enrollment_Component__c componentChild : componentChildren) {

                        if (groupQuestionsMap.keySet().contains(componentChild.Id)) {
                            List<Id> addedQuestionIds = groupQuestionsMap.get(componentChild.Id);
                           
                            for (Id addedQuestionId : addedQuestionIds) {
                                Enrollment_Component__c newComponent = enrollmentComponentMap.get(addedQuestionId);
                                 if (String.isBlank(newComponent.Assignment_Logic__c)) {
                                    if (newComponent.Component_Type__c == 'Student') {
                                        if (newComponent.Answer_Target__c != null) {
                                            studentTargets.add(newComponent.Answer_Target__c);
                                        }
                                    } else {
                                        if (newComponent.Answer_Target__c != null) {
                                            caretakerTargets.add(newComponent.Answer_Target__c);
                                        }
                                    }
                                }
                            }
                        }

                        if (componentChild.Component_Type__c == 'Student') {
                            if (componentChild.Answer_Target__c != null) {
                                studentTargets.add(componentChild.Answer_Target__c);
                            }

                        } else {
                            if (componentChild.Answer_Target__c != null) {
                                caretakerTargets.add(componentChild.Answer_Target__c);
                            }
                        }

                    }

                    Map<String, List<String>> studentQueryMap = new Map<String, List<String>>();
                    Map<String, List<SObject>> studentDataMap2 = new Map<String, List<SObject>>();
                    Map<String, List<String>> caretakerQueryMap = new Map<String, List<String>>();
                    Map<String, List<SObject>> caretakerDataMap2 = new Map<String, List<SObject>>();

                    if (studentTargets.size() > 0) {
                        studentQueryMap = NES_EvaluateUtil.configureQueryMap(studentTargets);
                        studentDataMap2 = NES_EvaluateUtil.getObjectDataList(studentQueryMap, studentEnrollment.Id, caretaker.Contact.AccountId, studentEnrollment.hed__Contact__c);
                    }
                    if (caretakerTargets.size() > 0) {
                        caretakerQueryMap = NES_EvaluateUtil.configureQueryMap(caretakerTargets);
                        caretakerDataMap2 = NES_EvaluateUtil.getObjectDataList(caretakerQueryMap, caretakerEnrollment[0].Id, caretaker.Contact.AccountId, caretaker.ContactId);
                    }

                    //Create a map of Option_Exclusion__c record for the above account and Enrollment components records
                    List <Option_Exclusion__c> exclusions = [
                            SELECT Id, Academic_Program__c, Option__c
                            FROM Option_Exclusion__c
                            WHERE Academic_Program__c = :studentEnrollment.hed__Account__c
                            AND Option__r.Enrollment_Component__c IN :newQuestionIds
                    ];

                    Map<Id, Option_Exclusion__c> optionExclusionMap = new Map<Id, Option_Exclusion__c>();
                    for (Option_Exclusion__c rec : exclusions) {
                        if (!optionExclusionMap.containsKey(rec.Option__c)) {
                            optionExclusionMap.put(rec.Option__c, rec);
                        }
                    }

                    for (Enrollment_Component__c componentChild : componentChildren) {

                        Enrollment_Component__c newComponent = enrollmentComponentMap.get(componentChild.Id);
                        /*System.debug(newComponent.Id);
                        System.debug(String.isBlank(componentChild.Assignment_Logic__c));
                        System.debug(componentChild.Id);
                        System.debug(newQuestionIds.contains(componentChild.Id));*/
                        Decimal orderDecimal = questionOrderMap.get(componentChild.Id);
                        
                        if(String.isBlank(componentChild.Assignment_Logic__c) || newQuestionIds.contains(componentChild.Id)) {
                            //This means it is a question group.
                            //System.debug(groupQuestionsMap.keySet().contains(componentChild.Id));
                            if (groupQuestionsMap.keySet().contains(componentChild.Id)) {
                                // if it a special address or school search QG it is configured differently
                                //System.debug(newComponent.Question_Type__c);
                                if (newComponent.Question_Type__c == 'Address' || newComponent.Question_Type__c == 'School Search') {

                                    NES_EvaluateUtil.Question singleQuestion = new NES_EvaluateUtil.Question();
                                    if(newComponent.Component_Type__c == 'Student') {
                                        singleQuestion = NES_EvaluateUtil.configureQuestion(newComponent, optionExclusionMap, null, orderDecimal, true, componentChild.Id, studentCriteriaStrings);
                                    } else {
                                        singleQuestion = NES_EvaluateUtil.configureQuestion(newComponent, optionExclusionMap, null, orderDecimal, true, componentChild.Id, caretakerCriteriaStrings);
                                    }
                                     
                                    questionListForReturn.add(singleQuestion);

                                } else {
                                    List<Id> addedQuestionIds = groupQuestionsMap.get(componentChild.Id);
                                    //System.debug(addedQuestionIds);
                                    for (Id addedQuestionId : addedQuestionIds) {
                                        if (!returnQuestionIds.contains(addedQuestionId)) {
                                            NES_EvaluateUtil.Question singleQuestion = new NES_EvaluateUtil.Question();
                                            Enrollment_Component__c childComponent = enrollmentComponentMap.get(addedQuestionId);
                                            if(childComponent.Assignment_Logic__c == null || newQuestionIDs.contains(addedQuestionID)){
                                                if (childComponent.Component_Type__c == 'Student') {
                                                    orderDecimal = orderDecimal + questionOrderMap.get(addedQuestionId) / 1000;
                                                    singleQuestion = NES_EvaluateUtil.configureQuestion(childComponent, optionExclusionMap, studentDataMap2, orderDecimal, false, componentChild.Id, studentCriteriaStrings);
   
                                                } else {
                                                    orderDecimal = orderDecimal + questionOrderMap.get(addedQuestionId) / 1000;
                                                    singleQuestion = NES_EvaluateUtil.configureQuestion(childComponent, optionExclusionMap, caretakerDataMap2, orderDecimal, false, componentChild.Id, caretakerCriteriaStrings);
                                                }
                                              
                                                questionListForReturn.add(singleQuestion);
                                            }
                                        }
                                    }
                                }
                            } else { 
                                    
                                //System.debug(returnQuestionIds);
                                if (!returnQuestionIds.contains(componentChild.Id) && !childQuestionIds.contains(componentChild.Id)) {  
                                    NES_EvaluateUtil.Question singleQuestion = new NES_EvaluateUtil.Question();
                                    if (newComponent.Component_Type__c == 'Student') {
                                        //System.debug(studentDataMap2);
                                        if (questionType[0].Question_Type__c == 'School Search')  //MM 9/10/2020  Added to support a bug with School Search not finding the correct Prior School record.
                                            singleQuestion = NES_EvaluateUtil.configureQuestion(newComponent, optionExclusionMap, studentDataMap2, orderDecimal, false, sectionId, studentCriteriaStrings);
                                        else
                                            singleQuestion = NES_EvaluateUtil.configureQuestion(newComponent, optionExclusionMap, studentDataMap2, orderDecimal, false, null, studentCriteriaStrings);

                                    } else {
                                        singleQuestion = NES_EvaluateUtil.configureQuestion(newComponent, optionExclusionMap, caretakerDataMap2, orderDecimal, false, null, caretakerCriteriaStrings);
                                    }
                                   
                                    questionListForReturn.add(singleQuestion);
                                }
                            }
                        }

                    }
                }
                //System.debug('This is the question list we are returning');
                //System.debug(questionListForReturn);

                return questionListForReturn;
            } catch (Exception e) { logger.logException('getRelatedQuestions', e);  logger.saveLogs(); System.debug(e.getMessage()); System.debug(e.getStackTraceString()); return null;   }
        }
    }

    /**
     * Created by Ashish Sharma on 12/05/18
     * Parameters: ID
     * Return Type: List<Enrollment_Component_Picklist_Option__c>
     * Purpose : This method is used to retrieve and return all the Enrollment_Component_Picklist_Option__c records related to questionComponentId
    */
    public static List<Enrollment_Component_Picklist_Option__c> getRelatedPicklistOptions(Id questionComponentId) {
        try {
            /*
                Retrieve and return all the Enrollment_Component_Picklist_Option__c records related to questionComponentId
            */
            if (questionComponentId != null) {
                //check for option exclusion
                Set<Id> optionExclusionSet = new Set<Id>();

                for (Option_Exclusion__c rec : [
                        SELECT Option__c
                        FROM Option_Exclusion__c
                        WHERE Option__r.Enrollment_Component__c = :questionComponentId
                ]) {

                    optionExclusionSet.add(rec.Option__c);
                }

                List<Enrollment_Component_Picklist_Option__c> picklistOptions = new List<Enrollment_Component_Picklist_Option__c>();

                for (Enrollment_Component_Picklist_Option__c temp : [
                        SELECT Id, Option_Label__c, Option_Value__c, Order__c
                        FROM Enrollment_Component_Picklist_Option__c
                        WHERE Enrollment_Component__c = :questionComponentId
                ]) {
                    if (!optionExclusionSet.contains(temp.Id)) {
                        picklistOptions.add(temp);
                    }
                }

                return picklistOptions;
            }

            return null;
        } catch (Exception e) { logger.logException('getRelatedPicklistOptions', e);  logger.saveLogs();   return null;  }
    }
    /*grab the picklist values for a set of questions and return a map*/
    public static Map<Id, List<Enrollment_Component_Picklist_Option__c> > getAllPicklistOptions(List<String> questionIds) {
        try {
            /*
                Retrieve and return all the Enrollment_Component_Picklist_Option__c records related to questionComponentId
            */
            if (questionIds.size() > 0) {
                System.debug(questionIds);
                //check for option exclusion
                Set<Id> optionExclusionSet = new Set<Id>();

                List<Option_Exclusion__c> allExclusions = [SELECT Option__c, Option__r.Enrollment_Component__c FROM Option_Exclusion__c WHERE Option__r.Enrollment_Component__c = :questionIds];

                Map<Id, List<Option_Exclusion__c> > exclusionMap = new Map<Id, List<Option_Exclusion__c> >();
                List<Option_Exclusion__c> optionExclusions = new List<Option_Exclusion__c>();
                for (Option_Exclusion__c exclusion : allExclusions) {
                    if (exclusionMap.keySet().contains(exclusion.Option__r.Enrollment_Component__c)) {
                        optionExclusions = exclusionMap.get(exclusion.Option__r.Enrollment_Component__c);
                        optionExclusions.add(exclusion);
                        exclusionMap.put(exclusion.Option__r.Enrollment_Component__c, optionExclusions);
                    } else {
                        optionExclusions.clear();
                        optionExclusions.add(exclusion);
                        exclusionMap.put(exclusion.Option__r.Enrollment_Component__c, optionExclusions);
                    }

                }


                Map<Id, List<Enrollment_Component_Picklist_Option__c> > optionsMap = new Map<Id, List<Enrollment_Component_Picklist_Option__c> >();

                List<Enrollment_Component_Picklist_Option__c> componentPicklistOptions = [
                        SELECT Id, Option_Label__c, Option_Value__c, Order__c,
                                Enrollment_Component__c
                        FROM Enrollment_Component_Picklist_Option__c
                        WHERE Enrollment_Component__c IN :questionIds
                        ORDER BY Order__c ASC
                ];

                for (Enrollment_Component_Picklist_Option__c temp : componentPicklistOptions) {
                    List<Enrollment_Component_Picklist_Option__c> picklistOptions = new List<Enrollment_Component_Picklist_Option__c>();
                    if (optionsMap.keySet().contains(temp.Enrollment_Component__c)) {
                        picklistOptions = optionsMap.get(temp.Enrollment_Component__c);
                        picklistOptions.add(temp);
                        optionsMap.put(temp.Enrollment_Component__c, picklistOptions);
                    } else {
                        picklistOptions.add(temp);
                        optionsMap.put(temp.Enrollment_Component__c, picklistOptions);
                    }

                }

                return optionsMap;
            }
            return null;
        } catch (Exception e) { logger.logException('getAllPicklistOptions', e); logger.saveLogs(); return null; }
    }

    public static Id grabSchoolId(Id programEnrollmentId) {

        hed__Program_Enrollment__c studentEnrollment = [SELECT hed__Account__c, hed__Account__r.ParentId FROM hed__Program_Enrollment__c WHERE Id = :programEnrollmentId];
        return studentEnrollment.hed__Account__r.ParentId;
    }

    public static String getSectionName(Id sectionId){
        Enrollment_Component__c currentSection = [SELECT Name FROM Enrollment_Component__c WHERE Id =: sectionId];
        return currentSection.Name;
    }
    
    //Added by Sumanth for US # 334973 & 334974
    public static Date getAHISubmitInformation(Id programEnrollmentId){
        List<Annual_Household_Information__c> AHISubmitInfo = new List<Annual_Household_Information__c>();
        AHISubmitInfo = [select Income_Form_Submission_Date__c,Income_Form_Submitter__c  from Annual_Household_Information__c where Program_Enrollment__c in (select Household_Program_Enrollment__c from hed__Program_Enrollment__c where id =: programEnrollmentId)];
        if(AHISubmitInfo.size() > 0)  
       		return AHISubmitInfo.get(0).Income_Form_Submission_Date__c;
        else
           return null;
    }
    //end by Sumanth 
    //Swapna:For GTM
    public static String getformName(Id sectionId){
        //Conveterd to List as a Fix for issue -  List has more than 1 row for assignment to SObject
        //Encountered while testing  for defect 326821 (Krishna Peddanagammol)
        List<Enrollment_Component__c> currentForm = [select Name from Enrollment_Component__c where Id IN (select Parent_Enrollment_Component__c from Enrollment_Component_Relationship__c where Child_Enrollment_Component__c =: sectionId)];
        //System.debug('currentForm::'+currentForm);
        return currentForm[0].Name;
    }

    // Mark Membrino | 12/14/2020 | START...
    public static Map<String, School_Year__c> getSchoolYearsById(Set<String> ids)
    {
        // collect SchoolYears
        Map<String, School_Year__c> schoolYears = new Map<String, School_Year__c>();
        for (School_Year__c schYear : [ 
            SELECT  Id, External_Id__c, Name 
            FROM    School_Year__c WHERE Id IN : ids]) {
                schoolYears.put(schYear.External_Id__c, schYear);
        }
        return schoolYears;
    }

    public static Map<String, Enrollment_Component__c> getECsById(Set<String> ids)
    {
        // collect QuestionGroups        
        Map<String, Enrollment_Component__c> qgECs = new Map<String, Enrollment_Component__c>();
        for (Enrollment_Component__c questionGroupEC : [ 
            SELECT  Id, External_Id__c, Name 
            FROM    Enrollment_Component__c WHERE   Id IN : ids]) 
        {
            qgECs.put(questionGroupEC.External_Id__c, questionGroupEC);
        }
        return qgECs;
    }
    // Mark Membrino | 12/14/2020 | END...
    
    //Naveen : Changes for Bug 375566 | Start
    public static hed__Program_Enrollment__c getPERecord(List<hed__Program_Enrollment__c> peRecList, Id peRecId){
        for(hed__Program_Enrollment__c pe: peRecList){
            if(pe.Id == peRecId){
                return pe;
            }
        }
        return null;
    }
    //Naveen : Changes for Bug 375566 | End
    

}