/**
 * @description       : Test coverage for EmergencyContactTriggerHandler class
 * @author            : Mark Membrino
 * @last modified on  : 10-03-2020
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   10-01-2020   Mark Membrino         Test coverage for EmergencyContactTriggerHandler class
                                            Coverate Snapshot
                                                => EmergencyContactTriggerHandler (97% coverage)
**/
@isTest(SeeAllData=false isParallel=true)
public with sharing class EmergencyContactTriggerHandlerTest
{
    @IsTest
    static void addingEmergencyContactPositive()
    {
        String newStatus = COMPLETE_STATUS;
        // * FETCH Data
            setAccounts(); // Query Academic Program & InstitutionAccount records
            schoolYear = querySchoolYear()[0]; 
            criterias = queryCriterias(); 
            mapPEs = getPEAndChildren();
            setECsAndPECs(); // gather ECs & PEs
            mapECs = getECsandChildrenByIds(new List<Id>(mapECs.keySet()));
            mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        // END...

        System.assertNotEquals(null, ecaSectionWithCriteria);
        System.assertNotEquals(null, studPEId);

        // create Emergency_Contact__c
        Emergency_Contact__c emergencyContact = new Emergency_Contact__c();
        emergencyContact.Program_Enrollment__c = studPEId;
        emergencyContact.Primary_Phone__c = '1231231233';
        emergencyContact.Secondary_Phone__c = '1231231234';
        emergencyContact.Add_Additional__c = 'Yes';
        insert emergencyContact;

        Test.startTest();
            emergencyContact.Add_Additional__c = 'No';
            update emergencyContact;
        Test.stopTest();

        Emergency_Contact__c ecRefreshed = [Select Id, Add_Additional__c from Emergency_Contact__c where Id = : emergencyContact.Id limit 1];
        System.assertEquals('No', ecRefreshed.Add_Additional__c);
    }

    /**
     * 
     *  SETUP: DATA VARIABLES / METHODS...
     * 
     */

    @TestSetup
    static void setup()
    {
        // academic program | schoolYear | process / stage / forms & related ECRs | criteria & ECCs
        setupAcademicProgramData();
            
        // caretaker | student | PE / ECAs / PE Criteria | 
        setupStudentPEData();
    }

    public static void setupStudentPEData() 
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
        hed__program_enrollment__c studPE = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert studPE;

        // * Capture the studentPEId
        studPEId = studPE.Id;

        // * Create Program Enrollment Criteria records that will link the PE to the Criterias.
        List<Program_Enrollment_Criteria__c> pecs = new List<Program_Enrollment_Criteria__c>();
        for (Criteria__c c : criterias)
            pecs.add(createPEC(studPE.Id, c.id, true, SCHOOL_YEAR));
        insert pecs;

        // * Create ECA records for the Program Enrollment
        List<Enrollment_Component_Affiliation__c> ecas = createECAsByAcademicProgram(false, academicProgram.Id, studPE.Id);
        insert ecas;
        
        // * Create Opportunity & Insert
        Opportunity studPEOppty = Peak_TestUtils.createOpportunity(studPE.Id);

    }

    public static void setupAcademicProgramData() 
    {
        List<sObject> recsToInsert = new List<sObject>();

        // * Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        
        // * Create School Year
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears(SCHOOL_YEAR, System.today());

        // * Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        academicProgram.Use_Updated_ECA_Process__c = true; // this flag controls the triggering of new ECA Assignment / Completion code.
        update academicProgram;
        
        // * Fetch RecordTypes
        Map<String, Id> ecRecTypes = getRecordTypeIdName('Enrollment_Component__c', new List<String>{'Process', 'Stage', 'Form', 'Section', 'Document'});
        
        // * Create ECs
        Enrollment_Component__c processEC = createBaseEC(false, 'process1', academicProgram.Id, ecRecTypes.get('Process')); // Level 1 process
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
    public static final String STAGE_ONE = 'Stage1';
    public static final String STAGE_TWO = 'Stage2';
    public static final String STUDENT_PE_RECORD_TYPE = 'Student';
    public static final String EC_WITH_CRITERIA_NAME_TXT = 'SectionWithCriteria';
    public static final String IN_COMPLETE_STATUS_STRING = 'In Progress, Not Started';

    public static Account institutionAccount;
    public static Account academicProgram;
    public static School_Year__c schoolYear;
    public static List<Criteria__c> criterias;
    public static Map<Id, hed__Program_Enrollment__c> mapPEs;
    public static Map<Id, Enrollment_Component__c> mapECs;
    public static Enrollment_Component_Affiliation__c ecaSectionWithCriteria;
    public static Map<Id, Program_Enrollment_Criteria__c> mapPECs;
    public static Id studPEId;
    
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

    public static Program_Enrollment_Criteria__c createPEC(Id peId, Id criteriaId, Boolean result, String schoolYear) 
    {
        return (
            new Program_Enrollment_Criteria__c
            (
                Program_Enrollment__c = peId,
                Criteria__c = criteriaId,
                Result__c = result,
                School_Year__c = schoolYear
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
                        Enrollment_Component__r.Name, Enrollment_Component__r.RecordType.Name
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

    public static void setAccounts() 
    {
        for (Account acc: queryAccounts(new List<String>{ EDU_INSTITUTE_TXT, ACADEMIC_PROGRAM_TXT }))
        {
            if (acc.RecordType.Name==EDU_INSTITUTE_TXT)
                institutionAccount = acc;
            else if (acc.RecordType.Name==ACADEMIC_PROGRAM_TXT)
                academicProgram = acc;
        }
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

    public static Map<Id, hed__Program_Enrollment__c> getPEAndChildren() 
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
    
    public static Enrollment_Component_Affiliation__c getECAByECName(String ecName, String byRecTypeString)
    {   
        for (hed__Program_Enrollment__c pe : mapPEs.values())
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

    public static void setECsAndPECs()
    {
        mapECs = new Map<Id, Enrollment_Component__c>();
        mapPECs = new Map<Id, Program_Enrollment_Criteria__c>();
        for (hed__Program_Enrollment__c pe : mapPEs.values())
        {
            if (studPEId==null)
                studPEId = pe.Id;
                
            // gather all ECAs
            for (Enrollment_Component_Affiliation__c eca : pe.Enrollment_Component_Affiliation__r)
            {
                mapECs.put(eca.Enrollment_Component__c, null);
                if (eca.Enrollment_Component__r.Name.containsIgnoreCase(EC_WITH_CRITERIA_NAME_TXT))
                    ecaSectionWithCriteria = eca;
            }

            // gather all PECriterias
            for (Program_Enrollment_Criteria__c pec : pe.Program_Enrollment_Criteria__r)
            {
                mapPECs.put(pec.Id, pec);
            }
        }
    }
}