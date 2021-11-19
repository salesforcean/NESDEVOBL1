/**
    @class:         ECA_EvaluationTestData           
    @description:   Data Class, holds all the values needed for ECA re-write test classes.
    @author:        Mark Membrino
    @createdDate:   9/9/2020
    @classes used in: 
        => ECA_CriteriaEvaluatorTest
    @Note: 
        For usage see below test class/method: 
            ECA_CriteriaEvaluatorTest.ECACriteriaEvaluatoMoveStageForwardPositiveTest()
*/
public class ECA_EvaluationTestData 
{

    /**
     * 
     *  SETUP: DATA VARIABLES / METHODS...
     * 
     */
    
    public ECA_EvaluationTestData() 
    {
        mapECs = new Map<Id, Enrollment_Component__c>();
        mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();        
    }


    public void generateData()
    {
        // academic program | schoolYear | process / stage / forms & related ECRs | criteria & ECCs
        setupAcademicProgramData();
            
        // caretaker | student | PE / ECAs / PE Criteria | 
        setupStudentPEData();
    }

    public void setupStudentPEData() 
    {
        // * FETCH Data
        setAccounts(); // Query Academic Program & InstitutionAccount records
        schoolYear = querySchoolYear()[0];
        criterias = queryCriterias(); 
        // END...

        // * Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        // * Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // * Create a Contact with 'Students' record type  
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        // * Create PE
        studPE = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert studPE;

        // * Capture the studentPEId
        studPEId = studPE.Id;

        // * Create Program Enrollment Criteria records that will link the PE to the Criterias.
        List<Program_Enrollment_Criteria__c> pecs = new List<Program_Enrollment_Criteria__c>();
        for (Criteria__c c : criterias)

            pecs.add(createPEC(studPE.Id, c.id, true, schoolYear.Id, 'Student'));
        insert pecs;

        // * Create ECA records for the Program Enrollment
        List<Enrollment_Component_Affiliation__c> ecas = createECAsByAcademicProgram(false, academicProgram.Id, studPE.Id);
        insert ecas;
        
        // * Create Opportunity & Insert
        Opportunity studPEOppty = Peak_TestUtils.createOpportunity(studPE.Id);
    }

    public void setupAdditionalStages(String ecaStatus)
    {
        ecaStatus=(ecaStatus!=null?ecaStatus:DEFAULT_STATUS);
        List<sObject> recsToInsert = new List<sObject>();
        // * Fetch RecordTypes

        Map<String, Id> ecRecTypes = EC_RECORD_TYPES;
        
        // * Create ECs
        // Stage-4 ECs
        Enrollment_Component__c stage4EC = createBaseEC(false, STAGE_FOUR, academicProgram.Id, ecRecTypes.get('Stage')); // Level 2 stages 
        Enrollment_Component__c stage4FormEC = createBaseEC(false, STAGE_FOUR+'Form', academicProgram.Id, ecRecTypes.get('Form')); // Level 3 forms
        Enrollment_Component__c stage4DocumentEC = createBaseEC(false, STAGE_FOUR+'Document', academicProgram.Id, ecRecTypes.get('Document')); // Level 4 sections/document
        // Stage-3 Waitlist ECs
        Enrollment_Component__c stageWaitlistEC = createBaseEC(false, STAGE_THREE, academicProgram.Id, ecRecTypes.get('Stage')); // Level 2 stages 
        Enrollment_Component__c stageWaitlistFormEC = createBaseEC(false, STAGE_THREE+'Form', academicProgram.Id, ecRecTypes.get('Form')); // Level 3 forms
        Enrollment_Component__c stageWaitlistSectionEC = createBaseEC(false, STAGE_THREE+'Section', academicProgram.Id, ecRecTypes.get('Section')); // Level 4 sections/document
        
        recsToInsert.add(stage4EC);
        recsToInsert.add(stage4FormEC);
        recsToInsert.add(stage4DocumentEC);
        recsToInsert.add(stageWaitlistEC);
        recsToInsert.add(stageWaitlistFormEC);
        recsToInsert.add(stageWaitlistSectionEC);
        insert recsToInsert;
        recsToInsert.clear();
        // * END

        // * tie the ECs (by ECRs)
        // Stage-4 ECRs
        Enrollment_Component_Relationship__c stage4ECR = createECR(false, processEC.Id, stage4EC.Id, 4); // level-1
        Enrollment_Component_Relationship__c stage4FormECR = createECR(false, stage4EC.Id, stage4FormEC.Id, 1); // level-2
        Enrollment_Component_Relationship__c stage4DocumentECR = createECR(false, stage4FormEC.Id, stage4DocumentEC.Id, 1); // level-3

        // Stage-3 Waitlist ECRs
        Enrollment_Component_Relationship__c stageWaitlistECR = createECR(false, processEC.Id, stageWaitlistEC.Id, 3); // level-1
        Enrollment_Component_Relationship__c stageWaitlistFormECR = createECR(false, stageWaitlistEC.Id, stageWaitlistFormEC.Id, 1); // level-2
        Enrollment_Component_Relationship__c stageWaitlistSectionECR = createECR(false, stageWaitlistFormEC.Id, stageWaitlistSectionEC.Id, 1); // level-3
        
        recsToInsert.add(stage4ECR);
        recsToInsert.add(stage4FormECR);
        recsToInsert.add(stage4DocumentECR);
        recsToInsert.add(stageWaitlistECR);
        recsToInsert.add(stageWaitlistFormECR);
        recsToInsert.add(stageWaitlistSectionECR);
        insert recsToInsert;
        recsToInsert.clear();
        // * END


        // * Create ECA records for Stage4 Program Enrollment
        List<Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c>();        
        ecas.add(createECAs(studPEId, stage4ECR.Order__c, stage4ECR.Child_Enrollment_Component__c, ecaStatus));
        ecas.add(createECAs(studPEId, stage4FormECR.Order__c, stage4FormECR.Child_Enrollment_Component__c, ecaStatus));
        ecas.add(createECAs(studPEId, stage4DocumentECR.Order__c, stage4DocumentECR.Child_Enrollment_Component__c, ecaStatus));

        // * Create ECA records for waitlistStage 
        ecas.add(createECAs(studPEId, stageWaitlistECR.Order__c, stageWaitlistECR.Child_Enrollment_Component__c, NA_STATUS));
        ecas.add(createECAs(studPEId, stageWaitlistFormECR.Order__c, stageWaitlistFormECR.Child_Enrollment_Component__c, NA_STATUS));
        ecas.add(createECAs(studPEId, stageWaitlistSectionECR.Order__c, stageWaitlistSectionECR.Child_Enrollment_Component__c, NA_STATUS));

        insert ecas;
        // * END
    }

    public void setupAcademicProgramData() 
    {
        List<sObject> recsToInsert = new List<sObject>();

        // * Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        // * Create School Year
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears(SCHOOL_YEAR, System.today());

        schoolYear.External_Id__c = SCHOOL_YEAR;
        update schoolYear;

        // * Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        academicProgram.Use_Updated_ECA_Process__c = true; // this flag controls the triggering of new ECA Assignment / Completion code.
        update academicProgram;
        
        // * Fetch RecordTypes

        Map<String, Id> ecRecTypes = EC_RECORD_TYPES;

        // * Create ECs
        processEC = createBaseEC(false, 'process1', academicProgram.Id, ecRecTypes.get('Process')); // Level 1 process
        // Stage-2 ECs
        Enrollment_Component__c stage1EC = createBaseEC(false, STAGE_ONE, academicProgram.Id, ecRecTypes.get('Stage')); // Level 2 stages 
        Enrollment_Component__c stage1FormEC = createBaseEC(false, STAGE_ONE+'Form', academicProgram.Id, ecRecTypes.get('Form')); // Level 3 forms
        Enrollment_Component__c stage1SectionWithCriteriaEC = createBaseEC(false, STAGE_ONE+EC_WITH_CRITERIA_NAME_TXT, academicProgram.Id, ecRecTypes.get('Section')); // Level 4 sections
        // Stage-2 ECs
        Enrollment_Component__c stage2EC = createBaseEC(false, STAGE_TWO, academicProgram.Id, ecRecTypes.get('Stage')); // Level 2 stages 
        Enrollment_Component__c stage2FormEC = createBaseEC(false, STAGE_TWO+'Form', academicProgram.Id, ecRecTypes.get('Form')); // Level 3 forms
        Enrollment_Component__c stage2SectionEC = createBaseEC(false, STAGE_TWO+'Section', academicProgram.Id, ecRecTypes.get('Section')); // Level 4 sections
        
        recsToInsert.add(processEC);
        recsToInsert.add(stage1EC);
        recsToInsert.add(stage1FormEC);
        recsToInsert.add(stage1SectionWithCriteriaEC);
        recsToInsert.add(stage2EC);
        recsToInsert.add(stage2FormEC);
        recsToInsert.add(stage2SectionEC);  
        insert recsToInsert;
        recsToInsert.clear();
        // * END

        // * tie the ECs (by ECRs)
        // Stage-1 ECRs
        Enrollment_Component_Relationship__c stage1ECR = createECR(false, processEC.Id, stage1EC.Id, 1); // level-1
        Enrollment_Component_Relationship__c stage1FormECR = createECR(false, stage1EC.Id, stage1FormEC.Id, 1); // level-2
        Enrollment_Component_Relationship__c stage1SectionWithCriteriaECR = createECR(false, stage1FormEC.Id, stage1SectionWithCriteriaEC.Id, 1); // level-3

        // Stage-2 ECRs
        Enrollment_Component_Relationship__c stage2ECR = createECR(false, processEC.Id, stage2EC.Id, 2); // level-1
        Enrollment_Component_Relationship__c stage2FormECR = createECR(false, stage2EC.Id, stage2FormEC.Id, 1); // level-2
        Enrollment_Component_Relationship__c stage2SectionECR = createECR(false, stage2FormEC.Id, stage2SectionEC.Id, 1); // level-3
        
        recsToInsert.add(stage1ECR);
        recsToInsert.add(stage1FormECR);
        recsToInsert.add(stage1SectionWithCriteriaECR);
        recsToInsert.add(stage2ECR);
        recsToInsert.add(stage2FormECR);
        recsToInsert.add(stage2SectionECR);
        insert recsToInsert;
        recsToInsert.clear();
        // * END

        
        // * create Criteria
        Criteria__c criteria1 = creatCriteria(false, '5th grade assignment', 'Annual_Student_Information__c.Grade_Level_Requested__c', '=', 'Text', '5');
        Criteria__c criteria2 = creatCriteria(false, 'disciplinary history flag assignment', 'hed__program_enrollment__c.DisciplinaryFlagOverride__c', '=', 'Text', 'Pending Review');
        recsToInsert.add(criteria1);
        recsToInsert.add(criteria2);
        insert recsToInsert;
        recsToInsert.clear();

        // * create ECC for stage1SectionWithCriteriaEC
        Enrollment_Component_Criteria__c ecc1 = createECC(false, stage1SectionWithCriteriaEC.Id, 1, criteria1.Id);
        Enrollment_Component_Criteria__c ecc2 = createECC(false, stage1SectionWithCriteriaEC.Id, 2, criteria2.Id);

        ecc1.School_Year__c = SCHOOL_YEAR;
        ecc1.Student_or_Household__c = 'Student';
        ecc2.Student_or_Household__c = 'Student';
        ecc2.School_Year__c = SCHOOL_YEAR;
        recsToInsert.add(ecc1);
        recsToInsert.add(ecc2);
        insert recsToInsert;
        recsToInsert.clear();

        // * update Assignment / Completion Criteria on 'stage1SectionWithCriteriaEC'
        Enrollment_Component__c ecToUpdate 
            = new Enrollment_Component__c(
                Id = stage1SectionWithCriteriaEC.Id,
                Assignment_Logic__c = '1 AND 2',
                Completion_Logic__c = '1 OR 2'
            );
        update ecToUpdate;
    }

    public static final String EDU_INSTITUTE_TXT = 'Educational Institution';
    public static final String ACADEMIC_PROGRAM_TXT = 'Academic Program';
    public static final String SCHOOL_YEAR = '2020-2021';
    public static final String DEFAULT_STATUS = 'Not Started';
    public static final String COMPLETE_STATUS = 'Complete';
    public static final String IN_PROGRESS_STATUS = 'In Progress';
    public static final String DEFERRED_STATUS = 'Deferred';
    public static final String NA_STATUS = 'Not Applicable';
    public static final String STAGE_ONE = 'Stage1';
    public static final String STAGE_TWO = 'Stage2';
    public static final String STAGE_THREE = 'Stage3';
    public static final String STAGE_FOUR = 'Stage4';
    public static final String STUDENT_PE_RECORD_TYPE = 'Student';
    public static final String EC_WITH_CRITERIA_NAME_TXT = 'SectionWithCriteria';
    public static final String IN_COMPLETE_STATUS_STRING = 'In Progress, Not Started';
    public static final Map<String, Id> EC_RECORD_TYPES = getRecordTypeIdName('Enrollment_Component__c', new List<String>{'Process', 'Stage', 'Form', 'Section', 'Document'});

    public Account institutionAccount;
    public Account academicProgram;
    public School_Year__c schoolYear;
    public List<Criteria__c> criterias;
    public Map<Id, hed__Program_Enrollment__c> mapPEs;
    public Map<Id, Enrollment_Component__c> mapECs;
    public Enrollment_Component_Affiliation__c ecaSectionWithCriteria;
    public Map<Id, Program_Enrollment_Criteria__c> mapPECs;
    public Id studPEId;
    public hed__program_enrollment__c studPE;
    public Enrollment_Component__c processEC;
    
    /**
     * 
     * INSERT DATA...
     * 
     */

    public static List<Enrollment_Component_Affiliation__c> createECAsByAcademicProgram(Boolean isInsert, Id academicProgramId, Id studPEId)
    {
        List<Enrollment_Component_Affiliation__c> ecas = new List<Enrollment_Component_Affiliation__c>();
        Boolean addParentProcess = true;
        for (Enrollment_Component_Relationship__c ecr : [
            SELECT Id, Order__c, Parent_Enrollment_Component__c, Parent_Enrollment_Component__r.Name, 
                Parent_Enrollment_Component__r.RecordType.Name, Child_Enrollment_Component__c, 
                Child_Enrollment_Component__r.Name, Child_Enrollment_Component__r.RecordType.Name
            FROM Enrollment_Component_Relationship__c
            WHERE Child_Enrollment_Component__r.Process_Academic_Program__c = :academicProgramId
            OR Parent_Enrollment_Component__r.Process_Academic_Program__c = :academicProgramId
        ])
        {
            String ecaStatus = DEFAULT_STATUS;
            // hack to create ECA for processEC
            if (ecr.Parent_Enrollment_Component__r.RecordType.Name=='Process' && addParentProcess) 
            {
                Enrollment_Component_Affiliation__c processECA = createECAs(studPEId, ecr.Order__c, ecr.Parent_Enrollment_Component__c, DEFAULT_STATUS);
                processECA.Status__c = IN_PROGRESS_STATUS;
                ecas.add(processECA);
                addParentProcess=false;
            }
            if (ecr.Child_Enrollment_Component__r.RecordType.Name=='Stage' &&
                ecr.Child_Enrollment_Component__r.Name.containsIgnoreCase(STAGE_ONE))
            {
                ecaStatus = IN_PROGRESS_STATUS;
            }
            ecas.add(createECAs(studPEId, ecr.Order__c, ecr.Child_Enrollment_Component__c, ecaStatus));
        }
        
        if (isInsert)
            insert ecas;
        return ecas;
    }
    
    public static Enrollment_Component_Affiliation__c createECAs(Id peId, Decimal order, Id ecId, String status)
    {
        return (new Enrollment_Component_Affiliation__c(
            Program_Enrollment__c = peId,
            Order__c = order,
            Enrollment_Component__c = ecId,
            Status__c = status
        ));
    } 

    public static Enrollment_Component_Relationship__c createECR(Boolean isInsert, Id parentECId, Id childECId, Integer order)
    {
        Enrollment_Component_Relationship__c ecr = new Enrollment_Component_Relationship__c(
            Parent_Enrollment_Component__c = parentECId,
            Child_Enrollment_Component__c = childECId,
            Order__c = order
        );
        if (isInsert)
            insert ecr;
        return ecr;
    }
    
    public static Enrollment_Component__c createBaseEC(Boolean isInsert, String name, Id academicProgramId, Id recTypeId)
    {   
        Enrollment_Component__c ec = new Enrollment_Component__c();
        ec.Name = name;
        ec.recordTypeId = recTypeId;
        if (academicProgramId!=null)
            ec.Process_Academic_Program__c = academicProgramId;
        if(isInsert)
            insert ec;
        return ec;
    }
    
    public static Criteria__c creatCriteria(Boolean isInsert, String name, String field, String operator, String dataType, String comparisionValue)
    {
        Criteria__c criteria 
            = new Criteria__c(
                Name=name, 
                Criteria_Field__c = field, 
                Operator__c = operator,
                Comparison_Data_Type__c = dataType,
                Comparison_Value__c = comparisionValue
            );
        if (isInsert)
            insert criteria;
        return criteria;
    }
        
    public static Enrollment_Component_Criteria__c createECC(boolean isInsert, Id ecId, Integer criteriaNumber, Id criteriaId)
    {
        Enrollment_Component_Criteria__c enrollCompCriteria
            = new Enrollment_Component_Criteria__c(
                Enrollment_Component__c = ecId,
                Criteria_Number__c = (Decimal) criteriaNumber,
                Criteria__c = criteriaId
                );
        if (isInsert) {
            insert enrollCompCriteria;
        }
        return enrollCompCriteria;
    }


    public static Program_Enrollment_Criteria__c createPEC(Id peId, Id criteriaId, Boolean result, String schoolYear, String peType) 
    {
        return (
            new Program_Enrollment_Criteria__c
            (
                Program_Enrollment__c = peId,
                Criteria__c = criteriaId,
                Result__c = result,

                School_Year__c = schoolYear,
                Student_or_Household__c = peType
            )
        );
    }

    /**
     * 
     * REFRESH DATA...
     * 
     */

    public static List<Enrollment_Component_Affiliation__c> refreshECAsByPEId(Id studPE) {
        return (
            [
                SELECT  Id, Name, Status__c, Order__c, Date_Completed__c, Program_Enrollment__c, Enrollment_Component__c, 
                        Enrollment_Component__r.Name, Enrollment_Component__r.RecordType.Name, Enrollment_Component__r.RecordTypeId
                FROM    Enrollment_Component_Affiliation__c
                WHERE   Program_Enrollment__c = :studPE
            ]
        );
    }
        
    public static Map<String, Id> getRecordTypeIdName(String srcObjectName, List<String> srcObjToRecTypeNamesMap) 
    {
        Map<String, Id> recTypeNameToIdsMap = new Map<String, Id>();
        for (RecordType recType : [ 
            SELECT Id, Name from RecordType 
            WHERE 
                sObjectType = :srcObjectName
                AND developerName IN : srcObjToRecTypeNamesMap
        ]) 
        {
            recTypeNameToIdsMap.put(recType.Name, recType.Id);
        }
        return recTypeNameToIdsMap;
    }

    public static List<Account> queryAccounts(List<String> recTypes) 
    {
        return [ 
            SELECT Id, Name, RecordType.Name
            FROM Account
            WHERE RecordType.Name IN :recTypes
        ];
    }

    public static List<School_Year__c> querySchoolYear()
    {
        return [SELECT Id FROM School_Year__c];
    }

    public static List<Criteria__c> queryCriterias()
    {
        return [SELECT Id, Name, Criteria_Field__c, Operator__c, Comparison_Data_Type__c,Comparison_Value__c FROM Criteria__c];
    }

    public static Map<Id, Enrollment_Component__c> getECsandChildrenByIds(List<Id> ecIds)
    {
        return ( 
            new Map<Id, Enrollment_Component__c>
            (
                [
                    SELECT  Id, Name, RecordType.Name, Assignment_Logic__c, Completion_Logic__c,
                        (
                            SELECT  Id, Name, Enrollment_Component__c, Criteria_Number__c, Criteria__c, 
                                    Criteria__r.Comparison_Data_Type__c, Criteria__r.Comparison_Value__c,
                                    Criteria__r.Criteria_Field__c, Criteria__r.Operator__c
                            FROM Enrollment_Component_Criteria__r
                        )
                    FROM    Enrollment_Component__c
                    WHERE   Id IN :ecIds
                ]
            )
        );
    }
    
    public Enrollment_Component_Affiliation__c getECAByECName(String ecName, String byRecTypeString)
    {   
        for (hed__Program_Enrollment__c pe : this.mapPEs.values())
        {       
         
            for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r)
            {
                if (!byRecTypeString.containsIgnoreCase(eca.Enrollment_Component__r.RecordType.Name))
                    continue;

                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(ecName))
                    return eca;
            }
        }
        
        return null;
    }
    
    public Map<Id, hed__Program_Enrollment__c> getPEAndChildren() 
    {
        return (
            new Map<Id, hed__Program_Enrollment__c>
            (
                [ // academicProgram: hed__Account__c
                    SELECT Id, Name, Status__c, hed__Account__c, hed__Account__r.Name, hed__Contact__c, hed__Contact__r.Name, RecordType.Name,
                        (
                            SELECT  Id, Name, Status__c, Order__c, Date_Completed__c, Program_Enrollment__c, Enrollment_Component__c, 
                                    Enrollment_Component__r.Name, Enrollment_Component__r.RecordType.Name
                            FROM    Enrollment_Component_Affiliation__r  
                        ), 
                        (
                            SELECT  Id, Name, Program_Enrollment__c, Criteria__c, Result__c, School_Year__c
                            FROM    Program_Enrollment_Criteria__r
                        )
                    FROM hed__Program_Enrollment__c WHERE RecordType.Name = :STUDENT_PE_RECORD_TYPE
                ]
            )
        );
    }

    public void setAccounts() 
    {
        for (Account acc: queryAccounts(new List<String>{ EDU_INSTITUTE_TXT, ACADEMIC_PROGRAM_TXT }))
        {
            if (acc.RecordType.Name==EDU_INSTITUTE_TXT)
                this.institutionAccount = acc;
            else if (acc.RecordType.Name==ACADEMIC_PROGRAM_TXT)
                this.academicProgram = acc;
        }
    }

    public void setECsAndPECs()
    {
        // mapECs = new Map<Id, Enrollment_Component__c>();
        // mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        for (hed__Program_Enrollment__c pe : mapPEs.values())
        {
            if (this.studPEId==null)
                studPEId = pe.Id;
                
            // gather all ECAs
            for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r)
            {
                this.mapECs.put(eca.Enrollment_Component__c, null);
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(EC_WITH_CRITERIA_NAME_TXT))
                    this.ecaSectionWithCriteria = eca;

                // Set Data.ProcessEC record.
                if (eca.Enrollment_Component__r.RecordTypeId == EC_RECORD_TYPES.get('Process'))
                    this.processEC = new Enrollment_Component__c(id=eca.Enrollment_Component__c);
            }

            // gather all PECriterias
            for (Program_Enrollment_Criteria__c pec : pe.Program_Enrollment_Criteria__r)
            {
                this.mapPECs.put(pec.Id, pec);
            }
        }
    }
}