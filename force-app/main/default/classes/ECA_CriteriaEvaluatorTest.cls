/**
    @class:         ECA_CriteriaEvaluatorTest           
	@description:   Test coverage for ECA_CriteriaEvaluator.
	@author: 		Mark Membrino
	@createdDate:   9/9/2020
    @classes-covered with coverage snapshot: 	
        => ECA_CriteriaEvaluator (94% coverage)
        => ECA_CriteriaEvaluatorHelper (100% coverage)
        => ECA_HierarchyStatusUpdate (91% coverage)
*/
@isTest(SeeAllData=false isParallel=true)
public class ECA_CriteriaEvaluatorTest
{

    /**
     * 
     * CriteriaEvaluatorHelper tests
     * 
     */
    @IsTest
    static void helperMethodsTest()
    {
        Map<String, Set<String>> objFieldsMap = ECA_CriteriaEvaluatorHelper.objectFieldsMap;
        System.assert(objFieldsMap.size()>0);

        Set<String> extIds = new Set<String>{'NES-QG-01', 'NES-QG-02'};
        ECA_CriteriaEvaluatorHelper.getECsByExternalId(extIds);
    }
    
    @IsTest
    static void recreatingPETest()
    {
        hed__Program_Enrollment__c progEnrollment = [SELECT Id,hed__Account__c, Status__c,Enrollment_Type__c,RecordType.Name FROM hed__Program_Enrollment__c  LIMIT 1];
        Criteria__c c = new Criteria__c(Name='Test Criteria',Criteria_Field__c='test',Comparison_Data_Type__c='Text',Operator__c='CONTAINS');
        insert c;
        Enrollment_Component__c ecComponent=[SELECT Id,Component_Type__c FROM Enrollment_Component__c LIMIT 1];
        Enrollment_Component_Criteria__c ecc = new Enrollment_Component_Criteria__c(Enrollment_Component__c=ecComponent.Id,Criteria__c=c.Id,Criteria_Type__c='Assignment');
        insert ecc;
       Test.startTest();
        Program_Enrollment_Criteria__c pec = ECA_CriteriaEvaluator.recreatingPE(progEnrollment.Id, c.Id);
       Test.stopTest();
    }

    /**
     *  Forward Test All Stages completion:  Stage 1 is Complete, Stage 2: Section is marked as 'Complete' from 'Not-Started', Section has only 1 Form, 
     *  so Stage=completed, PE=Completed, Opportunity.Stage=ClosedWon.
     */
    @IsTest
    static void ECACriteriaEvaluatorCompleteAllStagesPositiveTest()
    {
        testData = new ECA_EvaluationTestData();

		String newStatus = ECA_EvaluationTestData.COMPLETE_STATUS;
		List<sObject> recsForUpdate = new List<sObject>();

        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
		System.assertNotEquals(null, testData.studPEId);
		
		// * UPDATE TEST DATA
		// fetch Stage1 ECA, set Status=Complete
		Enrollment_Component_Affiliation__c Stage1StageECA = testData.getECAByECName(ECA_EvaluationTestData.STAGE_ONE, 'Stage');
		Stage1StageECA.Status__c = ECA_EvaluationTestData.COMPLETE_STATUS;
		Stage1StageECA.Date_Completed__c = System.today();
		recsForUpdate.add(Stage1StageECA);

		// fetch Stage2 ECA, set Status='In Progress'
		Enrollment_Component_Affiliation__c Stage2StageECA = testData.getECAByECName(ECA_EvaluationTestData.STAGE_TWO, 'Stage');
		Stage2StageECA.Status__c = ECA_EvaluationTestData.IN_PROGRESS_STATUS;
		recsForUpdate.add(Stage2StageECA);

		// fetch Stage2 SectionECA, set set Status=Complete
		Enrollment_Component_Affiliation__c Stage2SectionECA = testData.getECAByECName(ECA_EvaluationTestData.STAGE_TWO, 'Section');
		Stage2SectionECA.Status__c = ECA_EvaluationTestData.COMPLETE_STATUS;
        Stage2SectionECA.Date_Completed__c = System.today();
		recsForUpdate.add(Stage2SectionECA);		
		
		update recsForUpdate;
		// * END

        // Map<Id, Enrollment_Component_Affiliation__c> 
        //     editedECAs = new Map<Id, Enrollment_Component_Affiliation__c>{ Stage2SectionECA.Id => Stage2SectionECA };
        
        Test.startTest();
            // ECA_HierarchyStatusUpdate.run(editedECAs);
            Stage2SectionECA.Is_Dirty__c = true;
            update Stage2SectionECA;
		Test.stopTest();

        
		// * refresh data & verify/assert
		// verify that PE is COMPLETED	
		hed__Program_Enrollment__c studPE = [ SELECT Id, Status__c FROM hed__Program_Enrollment__c WHERE Id = :testData.studPEId ];
		System.assertEquals(newStatus, studPE.Status__c);

		// verify that Opportunity is CLOSED_WON
		Opportunity studPEOppty = [ SELECT Id, Program_Enrollment__c, StageName FROM Opportunity WHERE Program_Enrollment__c = :studPE.Id ];
		System.assertEquals('Closed Won', studPEOppty.StageName);

		// verify that ALL Stages are COMPLETED
        for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(studPE.Id))
        {
            if (eca.Enrollment_Component__r.RecordType.Name=='Stage') // validate All Stages are Complete
            {
                // Status == Complete
                if (eca.Status__c!=newStatus)
                    System.assertEquals(newStatus, JSON.serialize(eca));    
                System.assertEquals(newStatus, eca.Status__c);

                // CompleteDate == Date.Today()
                System.assertNotEquals(null, eca.Date_Completed__c);
            } 
		}
		// * END
    }

    /**
     *  Forward Test / In Progress:  Section is marked as 'Complete' from 'Not-Started', Section has only 1 Form, 
     *  so Stage=completed, next stage goes to 'In Progress'.
     */
    @IsTest
    static void ECACriteriaEvaluatoMoveStageForwardPositiveTest()
    {
		testData = new ECA_EvaluationTestData();

        String newStatus = ECA_EvaluationTestData.COMPLETE_STATUS;
        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
		System.assertNotEquals(null, testData.studPEId);

        // Set the new Status
        testData.ecaSectionWithCriteria.Status__c = newStatus;
        testData.ecaSectionWithCriteria.Date_Completed__c = System.today();
        update testData.ecaSectionWithCriteria;
        
        Test.startTest();
            testData.ecaSectionWithCriteria.Is_Dirty__c = true;
            update testData.ecaSectionWithCriteria;
		Test.stopTest();
        
        // refresh data & verify/assert
        for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
        {
            if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE)) // validate for STAGE_ONE ECAs
            {
                // Status == Complete
                if (eca.Status__c!=newStatus)
                    System.assertEquals(newStatus, JSON.serialize(eca));    
                System.assertEquals(newStatus, eca.Status__c);

                // CompleteDate == Date.Today()
                System.assertNotEquals(null, eca.Date_Completed__c);

            } 
            else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)) // validate for STAGE_TWO ECAs
            { 
                // ensure Status is either In-Progress OR Not-Started
                System.assert(ECA_EvaluationTestData.IN_COMPLETE_STATUS_STRING.containsIgnoreCase(eca.Status__c));

                // CompleteDate == null
                System.assertEquals(null, eca.Date_Completed__c);
            }
        }
    }
    
    /**
     *  Status QUO:  Form is marked as 'In Progress'
     */
    @IsTest
    static void ECACriteriaEvaluatoFormStatusQuoTest()
    {
		testData = new ECA_EvaluationTestData();

        String newStatus = ECA_EvaluationTestData.IN_PROGRESS_STATUS;
        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
        System.assertNotEquals(null, testData.studPEId);

        List<Enrollment_Component_Affiliation__c> peECAs
        = [
            SELECT  Id, Enrollment_Component__r.RecordType.Name 
            FROM    Enrollment_Component_Affiliation__c 
            // WHERE   Program_Enrollment__c = : testData.ecaSectionWithCriteria.Program_Enrollment__c
        ];

        Enrollment_Component_Affiliation__c formECA=null;
        for (Enrollment_Component_Affiliation__c eca : peECAs) {
            if (eca.Enrollment_Component__r.RecordType.Name.equalsIgnoreCase('Form'))
            {
                formECA = eca;
                break;
            }
        }

        System.assertNotEquals(0, peECAs.size());   
        System.assertNotEquals(null, formECA);   

        // Set the new Status
        formECA.Status__c = newStatus;
        // testData.ecaSectionWithCriteria.Date_Completed__c = System.today();
        update formECA;
        
        Test.startTest();
            formECA.Is_Dirty__c = true;
            update formECA;
        Test.stopTest();
        
        formECA = [Select Id, Status__c from Enrollment_Component_Affiliation__c where Id = :formECA.Id];
        System.assertEquals(newStatus, formECA.Status__c);
    }

    /**
     *  Deferred Document: Document is marked as 'Deferred', parent Form should go to 'In Progress'
     */
    @IsTest
    static void ECACriteriaEvaluatorDeferredDocumentPositive()
    {
		testData = new ECA_EvaluationTestData();

        String newStatus = ECA_EvaluationTestData.IN_PROGRESS_STATUS;
        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
        System.assertNotEquals(null, testData.studPEId);

        List<Enrollment_Component_Affiliation__c> peECAs
        = [
            SELECT  Id, Enrollment_Component__r.RecordType.Name 
            FROM    Enrollment_Component_Affiliation__c 
            // WHERE   Program_Enrollment__c = : testData.ecaSectionWithCriteria.Program_Enrollment__c
        ];

        Enrollment_Component_Affiliation__c formECA=null;
        for (Enrollment_Component_Affiliation__c eca : peECAs) {
            if (eca.Enrollment_Component__r.RecordType.Name.equalsIgnoreCase('Form'))
            {
                formECA = eca;
                break;
            }
        }

        System.assertNotEquals(0, peECAs.size());   
        System.assertNotEquals(null, formECA);   

        // now create new Document EC/ECA under the Form - START... 
            // * Fetch RecordTypes
            Map<String, Id> ecRecTypes = 
                ECA_EvaluationTestData.getRecordTypeIdName('Enrollment_Component__c', new List<String>{'Process', 'Stage', 'Form', 'Section', 'Document'});

            // Create Document EC
            Enrollment_Component__c stage1DocumentEC = 
                ECA_EvaluationTestData.createBaseEC(false, ECA_EvaluationTestData.STAGE_ONE+'Document', testData.academicProgram.Id, ecRecTypes.get('Document')); // Level 4 sections
            insert stage1DocumentEC;

            // ECR
            Enrollment_Component_Relationship__c stage1DocumentECR = 
                ECA_EvaluationTestData.createECR(false, formECA.Enrollment_Component__c, stage1DocumentEC.Id, 2); // level-3
            insert stage1DocumentECR;

            // ECA
            Enrollment_Component_Affiliation__c docECA = 
                ECA_EvaluationTestData.createECAs(testData.studPEId, stage1DocumentECR.Order__c, stage1DocumentECR.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS);
            insert docECA;
        // END... 

        
        Test.startTest();
            docECA.Status__c = ECA_EvaluationTestData.DEFERRED_STATUS; // Set the new Status
            docECA.Is_Dirty__c = true;
            update docECA;
        Test.stopTest();

        docECA = [Select Id, Status__c from Enrollment_Component_Affiliation__c where Id = :docECA.Id];
        System.assertEquals(ECA_EvaluationTestData.DEFERRED_STATUS, docECA.Status__c);
        
        formECA = [Select Id, Status__c from Enrollment_Component_Affiliation__c where Id = :formECA.Id];
        System.assertEquals(ECA_EvaluationTestData.IN_PROGRESS_STATUS, formECA.Status__c);
    }

    /**
    *   Stage Move Backwards usecase/bug:  
    *          a. Initial State: Four Stages, Stage 1 & 2 are complete. Stage-3/Waitlist is 'Not Applicable' AND Stage 4 is In-Progress. 
    *          b. Staff Member marks the document under Stage-2 as Invalid, this should move the stage backwards.
    *          c. Expected Outcome: 
    *               Stage-1 = complete, Stage-2 = In Progress, Stage-3/Waitlist = Not Applicable, Stage-4 = Not Started
    */
    @IsTest
    static void PreviousStageDocumentMoveTest()
    {
		testData = new ECA_EvaluationTestData();

        String newStatus = ECA_EvaluationTestData.IN_PROGRESS_STATUS;
        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
        System.assertNotEquals(null, testData.studPEId);

        List<Enrollment_Component_Affiliation__c> peECAs
        = [
            SELECT  Id, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.Name, Enrollment_Component__r.RecordTypeId
            FROM    Enrollment_Component_Affiliation__c 
            // WHERE   Program_Enrollment__c = : testData.ecaSectionWithCriteria.Program_Enrollment__c
        ];

        String stage2FormECName = ECA_EvaluationTestData.STAGE_TWO+'Form';
        Enrollment_Component_Affiliation__c stage2FormECA=null;
        for (Enrollment_Component_Affiliation__c eca : peECAs) {
            if (stage2FormECName.equalsIgnoreCase(eca.Enrollment_Component__r.Name))
            {
                stage2FormECA = eca;
                break;
            }
        }

        System.assertNotEquals(0, peECAs.size());   
        System.assertNotEquals(null, stage2FormECA);   

        // Add Doc to Stage2 - EC/ECA under the Form - START... 
            // * Fetch RecordTypes
            Map<String, Id> ecRecTypes = ECA_EvaluationTestData.EC_RECORD_TYPES;
            
            // Create Document EC
            Enrollment_Component__c stage2DocumentEC = ECA_EvaluationTestData.createBaseEC(
                    false, ECA_EvaluationTestData.STAGE_TWO+'Document', testData.academicProgram.Id, ecRecTypes.get('Document')
               ); // Level 4 sections
            insert stage2DocumentEC;

            // ECR
            Enrollment_Component_Relationship__c stage2DocumentECR = 
                ECA_EvaluationTestData.createECR(false, stage2FormECA.Enrollment_Component__c, stage2DocumentEC.Id, 2); // level-3
            insert stage2DocumentECR;

            // ECA
            Enrollment_Component_Affiliation__c stage2DocECA = 
                ECA_EvaluationTestData.createECAs(testData.studPEId, stage2DocumentECR.Order__c, stage2DocumentECR.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS);
            insert stage2DocECA;
        // END... 

        // CreateStage3
            testData.setupAdditionalStages(ECA_EvaluationTestData.IN_PROGRESS_STATUS);
        // END... 

        // Set the start-state for PE/ECAs before testing...
        // 1. Stage 1 & Stage 2 = Complete
        // 2. Stage 3 = In Progress
            List<Enrollment_Component_Affiliation__c> toUpdateECAs = new List<Enrollment_Component_Affiliation__c>();
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                )
                {   
                    toUpdateECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Status__c = ECA_EvaluationTestData.COMPLETE_STATUS));
                }
            }
            System.assert(toUpdateECAs.size()>0);
            update toUpdateECAs;
        // END... 

        // validate data setup.
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                ) // validate for STAGE_ONE ECAs
                {   
                    System.assert(eca.Status__c==ECA_EvaluationTestData.COMPLETE_STATUS);
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_THREE)) // validate for STAGE_THREE / Waitlist ECAs
                {
                    System.assert(eca.Status__c==ECA_EvaluationTestData.NA_STATUS);
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_FOUR)) // validate for STAGE_FOUR ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.IN_PROGRESS_STATUS);
                }
            }
        // END...
        
        Test.startTest();
            stage2DocECA.Status__c = ECA_EvaluationTestData.IN_PROGRESS_STATUS; // Set the new Status
            stage2DocECA.Is_Dirty__c = true;
            update stage2DocECA;
        Test.stopTest();

        // validate test 
            stage2DocECA = [Select Id, Status__c from Enrollment_Component_Affiliation__c where Id = :stage2DocECA.Id];
            System.assertEquals(ECA_EvaluationTestData.IN_PROGRESS_STATUS, stage2DocECA.Status__c);
            
            
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                // skip if not StageECA
                if (eca.Enrollment_Component__r.RecordTypeId != ECA_EvaluationTestData.EC_RECORD_TYPES.get('Stage'))
                    continue;

                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE))
                {   
                    System.assert(eca.Status__c==ECA_EvaluationTestData.COMPLETE_STATUS);
                } 
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)) // validate for STAGE_TWO ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.IN_PROGRESS_STATUS);
                } 
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_THREE)) // validate for STAGE_THREE/Waitlist ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.NA_STATUS);
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_FOUR)) // validate for STAGE_THREE ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.DEFAULT_STATUS);
                }
            }
        // END...
    }

    /**
    *   Release Waitlist usecase:
        Summary: Stage 3 (Waitlist) goes from 'In Progress' to 'Not Applicable' / Stage 4 (CoE) should move from 'Not Started' to 'In Progress'.  
        Steps: 
    *          a. Initial State: Four Stages, Stage 1 & 2 are complete. Stage-3/Waitlist is 'In Progress' AND Stage 4 is 'Not Started'. 
    *          b. Staff Member releases the Waitlist for the student. Implying, PE.WaitlistFlag__c goes from 'Active' to 'Released'
    *          c. Expected Outcome: 
    *               Stage-1, Stage-2 are complete, Stage-3/Waitlist = Not Applicable, Stage-4 = In Progress
    */
    @IsTest
    static void WaitlistedStudentReleasedTest()
    {
		testData = new ECA_EvaluationTestData();

        String newStatus = ECA_EvaluationTestData.IN_PROGRESS_STATUS;
        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
        System.assertNotEquals(null, testData.studPEId);

        List<Enrollment_Component_Affiliation__c> peECAs
            = [
                SELECT  Id, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.Name, Enrollment_Component__r.RecordTypeId
                FROM    Enrollment_Component_Affiliation__c 
                // WHERE   Program_Enrollment__c = : testData.ecaSectionWithCriteria.Program_Enrollment__c
            ];

        String stage2FormECName = ECA_EvaluationTestData.STAGE_TWO+'Form';
        Enrollment_Component_Affiliation__c stage2FormECA=null;
        for (Enrollment_Component_Affiliation__c eca : peECAs) {
            if (stage2FormECName.equalsIgnoreCase(eca.Enrollment_Component__r.Name))
            {
                stage2FormECA = eca;
                break;
            }
        }

        System.assertNotEquals(0, peECAs.size());   
        System.assertNotEquals(null, stage2FormECA);   

        // Add Doc to Stage2 - EC/ECA under the Form - START... 
            // * Fetch RecordTypes
            Map<String, Id> ecRecTypes = ECA_EvaluationTestData.EC_RECORD_TYPES;
            
            // Create Document EC
            Enrollment_Component__c stage2DocumentEC = ECA_EvaluationTestData.createBaseEC(
                    false, ECA_EvaluationTestData.STAGE_TWO+'Document', testData.academicProgram.Id, ecRecTypes.get('Document')
               ); // Level 4 sections
            insert stage2DocumentEC;

            // ECR
            Enrollment_Component_Relationship__c stage2DocumentECR = 
                ECA_EvaluationTestData.createECR(false, stage2FormECA.Enrollment_Component__c, stage2DocumentEC.Id, 2); // level-3
            insert stage2DocumentECR;

            // ECA
            Enrollment_Component_Affiliation__c stage2DocECA = 
                ECA_EvaluationTestData.createECAs(testData.studPEId, stage2DocumentECR.Order__c, stage2DocumentECR.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS);
            insert stage2DocECA;
        // END... 

        // CreateStage3/Waitlist & Stage4 
            testData.setupAdditionalStages(null);
        // END... 

        // Set the start-state for PE/ECAs before testing...
        // 1. Stage 1 & Stage 2 = Complete
        // 2. Stage 3 = In Progress
            List<Enrollment_Component_Affiliation__c> toUpdateECAs = new List<Enrollment_Component_Affiliation__c>();
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                )
                {   
                    toUpdateECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Status__c = ECA_EvaluationTestData.COMPLETE_STATUS));
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_THREE))
                {
                    toUpdateECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Status__c = ECA_EvaluationTestData.IN_PROGRESS_STATUS));
                }
            }
            System.assert(toUpdateECAs.size()>0);
            update toUpdateECAs;
        // END... 

        // gather Stage_3/Waitlisted ECAs
        List<Enrollment_Component_Affiliation__c> waitlistedECAs = new List<Enrollment_Component_Affiliation__c>();
        // validate data setup.
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                ) // validate for STAGE_ONE ECAs
                {   
                    System.assert(eca.Status__c==ECA_EvaluationTestData.COMPLETE_STATUS);
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_THREE)) // validate for STAGE_THREE / Waitlist ECAs
                {
                    System.assert(eca.Status__c==ECA_EvaluationTestData.IN_PROGRESS_STATUS);
                    if (eca.Enrollment_Component__r.RecordType.Name =='Stage')
                        waitlistedECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Is_Dirty__c=true, Status__c=ECA_EvaluationTestData.NA_STATUS));
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_FOUR)) // validate for STAGE_FOUR ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.DEFAULT_STATUS);
                }
            }
            System.assert(waitlistedECAs.size()>0);
        // END...
        
        Test.startTest();
            // for (Enrollment_Component_Affiliation__c pickedECA : waitlistedECAs)
            // {
            //     pickedECA.Status__c = ECA_EvaluationTestData.NA_STATUS; // Set the new Status
            //     pickedECA.Is_Dirty__c = true;
            // }
            update waitlistedECAs;
        Test.stopTest();

        // validate test 
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                // skip if not StageECA
                if (eca.Enrollment_Component__r.RecordTypeId != ECA_EvaluationTestData.EC_RECORD_TYPES.get('Stage'))
                    continue;

                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                )
                {   
                    System.assert(eca.Status__c==ECA_EvaluationTestData.COMPLETE_STATUS);
                } 
            }
        // END...
    }

    /**
    *   Waitlist a Student on Stage-4 (Confirmation Of Enrollment) usecase:
        Summary: Waitlist Actived on Student sitting on 'CoE'
        Steps: 
    *          a. Initial State: Four Stages, Stage 1 & 2 are complete. Stage-3/Waitlist is 'Not Applicable' AND Stage 4 is 'In Progress'. 
    *          b. Staff Member activates Waitlist for the student. Implying, PE.WaitlistFlag__c goes from null to 'Active'
    *          c. Expected Outcome: 
    *               Stage-1, Stage-2 are complete, Stage-3/Waitlist = In Progress, Stage-4 = Not Started
    */
    @IsTest
    static void FinalStageStudentWaitlistedTest()
    {
		testData = new ECA_EvaluationTestData();

        String newStatus = ECA_EvaluationTestData.IN_PROGRESS_STATUS;
        // * FETCH Data
            testData.setAccounts(); // Query Academic Program & InstitutionAccount records
            testData.schoolYear = ECA_EvaluationTestData.querySchoolYear()[0];
            testData.criterias = ECA_EvaluationTestData.queryCriterias(); 
            testData.mapPEs = testData.getPEAndChildren();
            testData.setECsAndPECs(); // gather ECs & PEs
            testData.mapECs = ECA_EvaluationTestData.getECsandChildrenByIds(new List<Id>(testData.mapECs.keySet()));
            testData.mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // * END...

        System.assertNotEquals(null, testData.ecaSectionWithCriteria);
        System.assertNotEquals(null, testData.studPEId);

        List<Enrollment_Component_Affiliation__c> peECAs
            = [
                SELECT  Id, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.Name, Enrollment_Component__r.RecordTypeId
                FROM    Enrollment_Component_Affiliation__c
            ];

        String stage2FormECName = ECA_EvaluationTestData.STAGE_TWO+'Form';
        Enrollment_Component_Affiliation__c stage2FormECA=null;
        for (Enrollment_Component_Affiliation__c eca : peECAs) {
            if (stage2FormECName.equalsIgnoreCase(eca.Enrollment_Component__r.Name))
            {
                stage2FormECA = eca;
                break;
            }
        }

        System.assertNotEquals(0, peECAs.size());   
        System.assertNotEquals(null, stage2FormECA);   

        // Add Doc to Stage2 - EC/ECA under the Form - START... 
            // * Fetch RecordTypes
            Map<String, Id> ecRecTypes = ECA_EvaluationTestData.EC_RECORD_TYPES;
            
            // Create Document EC
            Enrollment_Component__c stage2DocumentEC = ECA_EvaluationTestData.createBaseEC(
                    false, ECA_EvaluationTestData.STAGE_TWO+'Document', testData.academicProgram.Id, ecRecTypes.get('Document')
               ); // Level 4 sections
            insert stage2DocumentEC;

            // ECR
            Enrollment_Component_Relationship__c stage2DocumentECR = 
                ECA_EvaluationTestData.createECR(false, stage2FormECA.Enrollment_Component__c, stage2DocumentEC.Id, 2); // level-3
            insert stage2DocumentECR;

            // ECA
            Enrollment_Component_Affiliation__c stage2DocECA = 
                ECA_EvaluationTestData.createECAs(testData.studPEId, stage2DocumentECR.Order__c, stage2DocumentECR.Child_Enrollment_Component__c, ECA_EvaluationTestData.DEFAULT_STATUS);
            insert stage2DocECA;
        // END... 

        // CreateStage3/Waitlist & Stage4 
            testData.setupAdditionalStages(null);
        // END... 

        // Set the start-state for PE/ECAs before testing...
        // 1. Stage 1 & Stage 2 = Complete
        // 1. Stage 3 / Waitlist = Not Applicable
        // 2. Stage 4 = In Progress
            List<Enrollment_Component_Affiliation__c> toUpdateECAs = new List<Enrollment_Component_Affiliation__c>();
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                )
                {   
                    toUpdateECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Status__c = ECA_EvaluationTestData.COMPLETE_STATUS));
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_FOUR))
                {
                    toUpdateECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Status__c = ECA_EvaluationTestData.IN_PROGRESS_STATUS));
                }
            }
            System.assert(toUpdateECAs.size()>0);
            update toUpdateECAs;
        // END... 

        // gather Stage_3/Waitlisted ECAs
        List<Enrollment_Component_Affiliation__c> waitlistedECAs = new List<Enrollment_Component_Affiliation__c>();
        // validate data setup.
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                ) // validate for STAGE_ONE ECAs
                {   
                    System.assert(eca.Status__c==ECA_EvaluationTestData.COMPLETE_STATUS);
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_THREE)) // validate for STAGE_THREE / Waitlist ECAs
                {
                    System.assert(eca.Status__c==ECA_EvaluationTestData.NA_STATUS);
                    waitlistedECAs.add(new Enrollment_Component_Affiliation__c(Id=eca.Id, Is_Dirty__c=true, Status__c=ECA_EvaluationTestData.IN_PROGRESS_STATUS));
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_FOUR)) // validate for STAGE_FOUR ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.IN_PROGRESS_STATUS);
                }
            }
            System.assert(waitlistedECAs.size()>0);
        // END...
        
        Test.startTest();
            update waitlistedECAs;
        Test.stopTest();

        // validate test 
            for (Enrollment_Component_Affiliation__c eca: [Select Id, Status__c from Enrollment_Component_Affiliation__c where Id IN :waitlistedECAs])
            {
                System.assertEquals(ECA_EvaluationTestData.IN_PROGRESS_STATUS, eca.Status__c);
            }
            
            
            for (Enrollment_Component_Affiliation__c eca :ECA_EvaluationTestData.refreshECAsByPEId(testData.studPEId))
            {
                // skip if not StageECA
                if (eca.Enrollment_Component__r.RecordTypeId != ECA_EvaluationTestData.EC_RECORD_TYPES.get('Stage'))
                    continue;

                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_ONE) ||
                    eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)
                )
                {   
                    System.assert(eca.Status__c==ECA_EvaluationTestData.COMPLETE_STATUS);
                } 
                // else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_TWO)) // validate for STAGE_TWO ECAs
                // { 
                //     System.assert(eca.Status__c==ECA_EvaluationTestData.IN_PROGRESS_STATUS);
                // } 
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_THREE)) // validate for STAGE_THREE/Waitlist ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.IN_PROGRESS_STATUS);
                }
                else if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ECA_EvaluationTestData.STAGE_FOUR)) // validate for STAGE_THREE ECAs
                { 
                    System.assert(eca.Status__c==ECA_EvaluationTestData.DEFAULT_STATUS);
                }
            }
        // END...
    }


    /**
     * 
     *  TEST DATA SETUP
     * 
     */

    @TestSetup
    static void setup()
    {
        testData = new ECA_EvaluationTestData();
        testData.generateData();
    }

    public static ECA_EvaluationTestData testData;
    
}