/** 

    @author: Ali KM (Ness Tech)
    * Created this test class on 10/28/2019 for US# 113910
    * This class covers test coverage for US# 113910, following bits are covered.
        - NES_BusinessLogicUtils.calculateAddressEligibility()
        - NES_ProgramEnrollmentHandler.handleBeforeInsert()
        - NES_AccountBusinessLogic.recalcAddrEligIfRequired()
        - NES_AccountHandler.handleAfterUpdate()
   * Added by Maddileti for the User story #121803
     * This class covers test coverage for US# 121803, following bits are covered.
         -NES_BusinessLogicUtils.getAHIRecord1()
        - NES_ProgramEnrollmentHandler.calculateHHIncomeFosterChild1()
        - NES_AccountBusinessLogic.getTotalGrossHHIncome1()
        - NES_AccountHandler.calculateAutomatedPlacementProcess()
        - NES_AccountBusinessLogic.placementWhyFlagged1()
        - NES_AccountHandler.calculateEntranceAgeEligibilityOverrideReview()
    * Added by Jagadeesh for the User story #121803
     * This class covers test coverage for US# 121803, following bits are covered.
         -NES_BusinessLogicUtils.calculateTotalGrossHHIncome()z
   *. Added for the User story #147622 on 11/03/2020
  *. modified for the task #159017 on 24/03/2020

*/


@isTest(SeeAllData=false isParallel=true)
public with sharing class NES_BusinessLogicUtilsTest {


    public static final String accName_HH = 'accName_HH';
    public static final String academicProgramParentAccName = Peak_TestConstants.ACCOUNT_NAME;
    public static final Id programEnrollmentRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
    public static final String currentSchoolYearName = '2018-2019';
    public static final String PENN_STATE_CODE = 'PA';
    public static final String PENN_POSTAL_CODE = '15203';
    public static final String MIT_STATE_CODE = 'MA';
    public static final String MIT_POSTAL_CODE = '02142-1122';

    // PE.AddressEligibilitySystem__c picklist values 
    public static final String ELIGIBLE = 'Eligible';
    public static final String INELIGIBLE = 'Ineligible';
    public static final String PE_STATUS_DEFAULT = 'In Progress';

    // data
    public static Account acc_APParent;
    public static Account acc_houseHold;
    public static School_Year__c currentSchoolYear;
    public static Contact cntct_student;
    public static Account acc_academicProgram;
    public static Program_PostalCode__c apPosCode;
    public static hed__Program_Enrollment__c PE;


    @testSetup
    static void testSetup() {

        // enableTriggers
        Peak_TestUtils.createNESBusinessLogicSwitch('AccountTrigger', true);

        // generate test-data
        acc_APParent = Peak_TestUtils.createTestAccount();
        acc_houseHold = Peak_TestUtils.createAccountRecord(accName_HH, 'Household');
        currentSchoolYear = Peak_TestUtils.createSchoolYears(currentSchoolYearName, date.parse('11/17/2018'));
        cntct_student = Peak_TestUtils.createTestContact('Students', acc_houseHold.Id);
        acc_academicProgram = Peak_TestUtils.createAccountForNewStudentData(acc_APParent.Id, currentSchoolYear.Id);
        
        
         Account account = Peak_TestUtils.createTestAccount();
Contact contact = Peak_TestUtils.createTestContact('Students', account.Id);
Account academicProgramAccount = Peak_TestUtils.createAccountForNewStudentData(account.Id,currentSchoolYear.Id);
School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today());
hed__Program_Enrollment__c progEnrollmentWithStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount.Id, contact.Id,currentSchoolYear.Id, false);
        progEnrollmentWithStatus.Status__c = 'In Progress';
        progEnrollmentWithStatus.ELLFlag__c='Potential EL';
        insert progEnrollmentWithStatus;
        School_Year__c SchoolYear =Peak_TestUtils.createSchoolYears('2018-2019', Date.newInstance(2018, 1, 1));
        SchoolYear.Name = '2018-2019';
        SchoolYear.Start_Date__c = Date.newInstance(2018, 1, 1);
        SchoolYear.End_Date__c = Date.newInstance(2019, 1, 1);
        update SchoolYear ;
        
        
        //added
        Peak_TestUtils.createNESBusinessLogicSwitch('Last School Type and State', true);

        Account account1 = Peak_TestUtils.createTestAccount();

        School_Year__c schoolYear1 = Peak_TestUtils.createSchoolYears('SchoolTest', System.today());

        Contact contact1 = Peak_TestUtils.createTestContact('Students', account1.Id);

        Account academicProgramAccount1 = Peak_TestUtils.createAccountForNewStudentData(account1.Id,schoolYear1.Id);

        hed__Program_Enrollment__c programEnrollmentRec = Peak_TestUtils.createProgramEnrollment(academicProgramAccount1.Id, contact1.Id, schoolYear1.Id, true);

        //added
        Peak_TestUtils.createNESBusinessLogicSwitch('AccountTrigger', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c schoolYear2 = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear2.Id);
        Id AccountHouseholdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Account householdAccount = new Account();
        householdAccount.Name = 'Household Account';
        householdAccount.RecordTypeId = AccountHouseholdRecordTypeId;
        householdAccount.LC_HighestLevelofEducation__c = 'High school graduate';
        insert householdAccount;
        //added
        //added on 03/03/2020
         Peak_TestUtils.createNESBusinessLogicSwitch('Federal Poverty Eligibility', true);
        Peak_TestUtils.createNESBusinessLogicSwitch('Likelihood to Transition Score', true);
        Account account3 = Peak_TestUtils.createTestAccount();
        School_Year__c currentSchoolYear3 = Peak_TestUtils.createSchoolYears('2018-2019',System.today()); 
        system.debug('current sy ' + currentSchoolYear3.Name);

        Contact contact3 = Peak_TestUtils.createTestContact('Students', account3.Id);

        Account academicProgramAccount3 = Peak_TestUtils.createAccountForNewStudentData(account3.Id,currentSchoolYear3.Id);
        academicProgramAccount3.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c = 3000;//added by jagadeesh - user story : 117580 
        academicProgramAccount3.Fed_Poverty_Elig_Inc_Addl_Per_Person__c = 3000;//added by jagadeesh - user story : 117580 
        academicProgramAccount3.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c = 1000;//added by jagadeesh - user story : 117580 
        academicProgramAccount3.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c = 2000;//added by jagadeesh - user story : 117580 
        academicProgramAccount3.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c = 3000;//added by jagadeesh - user story : 117580 
        academicProgramAccount3.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c = 4000;//added by jagadeesh - user story : 117580 
        update academicProgramAccount3;//added by jagadeesh - user story : 117580 
        
        system.debug('1 ' + academicProgramAccount);

        hed__Program_Enrollment__c progEnrollmentWithoutStatus = Peak_TestUtils.createProgramEnrollment(academicProgramAccount3.Id, contact3.Id,currentSchoolYear3.Id, false);
       // progEnrollmentWithoutStatus.Status__c = 'Time Expired';
         progEnrollmentWithoutStatus.Status__c = 'In Progress';//added by anitha
        insert progEnrollmentWithoutStatus;
        system.debug('1 ' + progEnrollmentWithoutStatus);

        hed__Program_Enrollment__c progEnrollmentTest = Peak_TestUtils.createProgramEnrollment(academicProgramAccount3.Id, contact3.Id,currentSchoolYear3.Id, false);
        progEnrollmentTest.ELLFlag__c='Potential';
        Insert progEnrollmentTest;
       
        hed__Program_Enrollment__c programEnrollmentTest1 = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];//added by anitha
        School_Year__c currentSchoolYear1 = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
        Annual_Household_Information__c currentAHI11 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollmentTest1.Id, currentSchoolYear3.Id, false);
        
               
        hed__Program_Enrollment__c progEnrollmentTest2 = Peak_TestUtils.createProgramEnrollment(academicProgramAccount3.Id, contact3.Id,currentSchoolYear3.Id, false);
        progEnrollmentTest2.Household_Program_Enrollment__c= programEnrollmentTest1.Id;
        progEnrollmentTest2.Status__c = 'In Progress';
        Insert progEnrollmentTest2;
        //added on 03/03/2020
        //
     
   }


    /** 

        Positive test:
            EntryPoint: Code is triggered when PE is created.
            Scenario: 
                When AcademicProgram > ProgramPostalCodeSet contains Contact.HouseHoldAccount.ShippingPostalCode
                Then set PE.AddressEligibilitySystem__c = Eligible
    */ 
    @isTest
    public static void PE_AddressEligibilitySystem_PostalCode_Eligible() {
        Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger', true);

        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];


        // create postCodes for Academic program
        apPosCode = createAcademicProgramPostalCodes(acc_academicProgram.id, PENN_POSTAL_CODE);


        // Set contact.Account.ShippingPostalCode = pennStatePostalCode;
        acc_houseHold.ShippingPostalCode = PENN_POSTAL_CODE;
        update acc_houseHold; 
        // acc_houseHold = [Select Id, Name, shippingstate, ShippingPostalCode from Account where Id =: acc_houseHold.Id];
        // System.assertEquals(acc_houseHold.ShippingPostalCode, PENN_POSTAL_CODE);


        Exception err;
        Test.startTest();
        try {
                // Now Insert the PE record
                PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);
                System.enqueueJob(new NES_AddStudentCBLQueueable(PE.Id));
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, AddressEligibilitySystem__c, Start_Year__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        contact cntctStudentAfter = [SELECT Id, CA_StartYear__c FROM Contact where id = :cntct_student.Id limit 1];

        // assert
        //System.assertEquals(PE.AddressEligibilitySystem__c, ELIGIBLE, 'PE.AddressEligibilitySystem__c does not match!');//
        system.assertEquals(null, err, 'exceptions!');
        
        System.assertEquals(cntctStudentAfter.CA_StartYear__c, currentSchoolYear.Id, 'Contact Start Year does not match.');
    }

    
    /** 
        
        Negative test:
            EntryPoint: Code is triggered when PE is created.
            Scenario: 
                When AcademicProgram > ProgramPostalCodeSet does NOT contains Contact.HouseHoldAccount.ShippingPostalCode
                Then set PE.AddressEligibilitySystem__c = Ineligible
            
    */ 
    @isTest 
    public static void PE_AddressEligibilitySystem_PostalCode_Ineligible() {
        

        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];


        // create postCodes for Academic program
        apPosCode = createAcademicProgramPostalCodes(acc_academicProgram.id, PENN_POSTAL_CODE);


        // Set contact.Account.ShippingPostalCode to different postalCode value.
        acc_houseHold.ShippingPostalCode = MIT_POSTAL_CODE;
        update acc_houseHold; 


        Exception err;
        Test.startTest();
        try {

                // Now Insert the PE record
                PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();


        // refresh PE
        PE = [SELECT Id, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

       
        // assert
       // System.assertEquals(PE.AddressEligibilitySystem__c, INELIGIBLE, 'PE.AddressEligibilitySystem__c does not match!');//
       system.assertEquals(null, err, 'exceptions!');
    

    }
    

    /** 

        Positive test:
            EntryPoint: Code is triggered when PE is created.
            Scenario: 
                When AcademicProgram > ProgramPostalCodeSet DOES NOT EXIST, 
                System checks if AcademicProgram.Parent.ShippingState ==  Contact.HouseHoldAccount.ShippingState, If it matches
                Then set PE.AddressEligibilitySystem__c = Eligible
            
    */ 
    @isTest 
    public static void PE_AddressEligibilitySystem_ShippingState_Eligible() {
        

        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name, ParentId, Parent.ShippingState 
            FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];


        // Set Contact.Account.ShippingState
        acc_houseHold.ShippingPostalCode = MIT_POSTAL_CODE;
        acc_houseHold.ShippingState = MIT_STATE_CODE;
        update acc_houseHold; 

        // Set AcademicProgram.ParentAccount.ShippingState to be same as Contact.Account.ShippingState
        acc_APParent = new Account(id=acc_academicProgram.ParentId, ShippingPostalCode=MIT_POSTAL_CODE, ShippingState=MIT_STATE_CODE);
        update acc_APParent; 


        Exception err;
        Test.startTest();
        try {

                // Now Insert the PE record
                PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();


        // refresh PE
        PE = [SELECT Id, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];


        // assert
        //System.assertEquals(PE.AddressEligibilitySystem__c, ELIGIBLE, 'PE.AddressEligibilitySystem__c does not match!');//
        system.assertEquals(null, err, 'exceptions!');
    

    }


    /** 

        Negative test:
            EntryPoint: Code is triggered when PE is created.
            Scenario: 
                When AcademicProgram > ProgramPostalCodeSet DOES NOT EXIST, 
                    System checks if AcademicProgram.Parent.ShippingState ==  Contact.HouseHoldAccount.ShippingState, If it DOES NOT match
                Then set PE.AddressEligibilitySystem__c = Ineligible
            
    */ 
    @isTest 
    public static void PE_AddressEligibilitySystem_ShippingState_Ineligible() {
    

        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name, ParentId, Parent.ShippingState 
            FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];


        // Set Contact.Account.ShippingState
        acc_houseHold.ShippingPostalCode = MIT_POSTAL_CODE;
        acc_houseHold.ShippingState = MIT_STATE_CODE;
        update acc_houseHold; 

        // Set AcademicProgram.ParentAccount.ShippingState to be DIFFERENT FROM Contact.Account.ShippingState
        acc_APParent = new Account(id=acc_academicProgram.ParentId, ShippingPostalCode=PENN_POSTAL_CODE, ShippingState=PENN_STATE_CODE);
        update acc_APParent; 


        Exception err;
        Test.startTest();
        try {

                // Now Insert the PE record
                PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();


        // refresh PE
        PE = [SELECT Id, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        
        // assert
       // System.assertEquals(PE.AddressEligibilitySystem__c, INELIGIBLE, 'PE.AddressEligibilitySystem__c does not match!');//
        system.assertEquals(null, err, 'exceptions!');
    

    }

    /** 

        Positive test:
            EntryPoint: Code is triggered when HouseHold_Account.ShippingPostalCode is updated.
            Scenario: 
                When HouseHold_Account.ShippingPostalCode is updated,
                    System kicks off the 'NES_BusinessLogicUtils.calculateAddressEligibility()' check.
                Then sets PE.AddressEligibilitySystem__c = Eligible for all PEs with PE.Status__c = 'In Progress'
            
    */ 
    @isTest 
    // test Acc_Household_PostalCodeChange_Eligible.
    public static void Acc_Household_PostalCodeChange_Eligible() {
   

        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name, ParentId, Parent.ShippingState 
            FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];


        // create postCodes for Academic program
        apPosCode = createAcademicProgramPostalCodes(acc_academicProgram.id, PENN_POSTAL_CODE);


        // Set contact.Account.ShippingPostalCode to different postalCode value.
        acc_houseHold.ShippingPostalCode = MIT_POSTAL_CODE;
        update acc_houseHold; 


        // Now Insert the PE record
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);
        // refresh PE
        PE = [SELECT Id, Status__c, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];
        System.assertEquals(PE.Status__c, PE_STATUS_DEFAULT);
        //System.assertEquals(PE.AddressEligibilitySystem__c, INELIGIBLE);//


        Exception err;
        Test.startTest();
        try {

                // Update Account ShippingPostalCode.
                acc_houseHold.ShippingPostalCode = PENN_POSTAL_CODE;
                update acc_houseHold; 

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();

        // refresh houseHold Acc
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Id =: acc_houseHold.Id];
        // refresh PE
        PE = [SELECT Id, status__c, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        
        // assert
        System.assertEquals(acc_houseHold.ShippingPostalCode, PENN_POSTAL_CODE);
        System.assertEquals(PE.AddressEligibilitySystem__c, ELIGIBLE, 'PE.AddressEligibilitySystem__c does not match!');
        system.assertEquals(null, err, 'exceptions!');
    

    }


    /** 

        Positive test:
            EntryPoint: Code is triggered when HouseHold_Account.ShippingState is updated.
            Scenario: 
                When HouseHold_Account.ShippingState is updated,
                    System kicks off the 'NES_BusinessLogicUtils.calculateAddressEligibility()' check.
                Then sets PE.AddressEligibilitySystem__c = 'Eligible' for all PEs with PE.Status__c = 'In Progress'
            
    */ 
    @isTest 
    // test ACC_Household_ShippingStateChange_Eligible.
    public static void ACC_Household_ShippingStateChange_Eligible() {
   

        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name, ParentId, Parent.ShippingState 
            FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];


        // Set Contact.Account.ShippingState
        acc_houseHold.ShippingPostalCode = MIT_POSTAL_CODE;
        acc_houseHold.ShippingState = MIT_STATE_CODE;
        update acc_houseHold; 

        // Set AcademicProgram.ParentAccount.ShippingState to be DIFFERENT FROM Contact.Account.ShippingState
        acc_APParent = new Account(id=acc_academicProgram.ParentId, ShippingPostalCode=PENN_POSTAL_CODE, ShippingState=PENN_STATE_CODE);
        update acc_APParent; 


        // Now Insert the PE record
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);
        // refresh PE
        PE = [SELECT Id, Status__c, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];
        System.assertEquals(PE.Status__c, PE_STATUS_DEFAULT);
        //System.assertEquals(PE.AddressEligibilitySystem__c, INELIGIBLE);//


        Exception err;
        Test.startTest();
        try {

                // Update Account Shipping details
                acc_houseHold.ShippingState = PENN_STATE_CODE;
                acc_houseHold.ShippingPostalCode = PENN_POSTAL_CODE;
                update acc_houseHold; 

        } catch (Exception e) {

            err = e;

        }
        Test.stopTest();

        // refresh houseHold Acc
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Id =: acc_houseHold.Id];
        // refresh PE
        PE = [SELECT Id, status__c, AddressEligibilitySystem__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        
        // assert
        System.assertEquals(acc_houseHold.ShippingState, PENN_STATE_CODE);
        System.assertEquals(PE.AddressEligibilitySystem__c, ELIGIBLE, 'PE.AddressEligibilitySystem__c does not match!');
        system.assertEquals(null, err, 'exceptions!');
    

    }


    // util method to create PostalCode records...
    public static Program_PostalCode__c createAcademicProgramPostalCodes(String academicProgramID, String postalCode)  {

        Program_PostalCode__c rec_postalCode = 
            new Program_PostalCode__c(Academic_Program__c = academicProgramID, Name = postalCode, PostalCode__c = postalCode);
                    
        insert rec_postalCode;
        return rec_postalCode;

    }

    /** 
        Positive test:
            EntryPoint: Code is triggered when PE.DisciplinaryPastActions__c is updated.
            Scenario: 
                When DisciplinaryPastActions__c is set to Yes, Suspended, and the Acedemic Program
                       has been set up with Disciplanary Actions to Pending Review
                Then set PE.DisciplinaryFlagOverride__c = Pending Review
           
    */ 
    @isTest
    public static void PE_Disciplinary_Action_Pending_Review() {
        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        acc_academicProgram.Disciplinary_Action_Currently_Expelled__c = 'Pending Review';
        acc_academicProgram.Disciplinary_Action_Currently_Suspended__c = 'Pending Review';
        acc_academicProgram.Disciplinary_Action_Ever_Expelled__c = 'Pending Review';
        acc_academicProgram.Disciplinary_Action_Ever_Suspended__c = 'Pending Review';
        update acc_academicProgram;

        Exception err;
        Test.startTest();
        try {

                // update the PE record and set the DisciplinaryPastActions__c
                PE.DisciplinaryPastActions__c = 'Yes, Suspended';
                Update PE;
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, DisciplinaryFlagOverride__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        // assert
        System.assertEquals(PE.DisciplinaryFlagOverride__c, 'Pending Review', 'PE.DisciplinaryFlagOverride__c does not match!');
        system.assertEquals(null, err, 'exceptions!');
    }    

    /** 

        Negative test:
            EntryPoint: Code is triggered when PE.DisciplinaryPastActions__c is updated.
            Scenario: 
                When DisciplinaryPastActions__c is set to Yes, Suspended, and the Acedemic Program
                       HAVE NOT BEEN SET been set up with Disciplanary Actions to Pending Review
                Then set PE.DisciplinaryFlagOverride__c = Pending Review
            
    */ 
    @isTest
    public static void PE_Disciplinary_Action_Not_Updated() {
        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        Exception err;
        Test.startTest();
        try {

                // update the PE record and set the DisciplinaryPastActions__c
                PE.DisciplinaryPastActions__c = 'Yes, Suspended';
                Update PE;
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, DisciplinaryFlagOverride__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        // assert
        System.assertEquals(PE.DisciplinaryFlagOverride__c, null, 'PE.DisciplinaryFlagOverride__c does not match!');
        system.assertEquals(null, err, 'exceptions!');
    }    

    /** 
        Positive test:
            EntryPoint: Code is triggered when PE.DisciplinaryPastActions__c is updated.
            Scenario: 
                When DisciplinaryPastActions__c is set to Yes, Expelled, and the Acedemic Program
                       has been set up with Disciplanary Actions to Withdraw
                Then set PE.DisciplinaryFlagOverride__c = Withdraw
            
    */ 
    @isTest
    public static void PE_Disciplinary_Action_Withdraw() {
        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        acc_academicProgram.Disciplinary_Action_Currently_Expelled__c = 'Withdraw';
        acc_academicProgram.Disciplinary_Action_Currently_Suspended__c = 'Withdraw';
        acc_academicProgram.Disciplinary_Action_Ever_Expelled__c = 'Withdraw';
        acc_academicProgram.Disciplinary_Action_Ever_Suspended__c = 'Withdraw';
        update acc_academicProgram;

        Exception err;
        Test.startTest();
        try {

                // update the PE record and set the DisciplinaryPastActions__c
                PE.DisciplinaryPastActions__c = 'Yes, Expelled';
                Update PE;
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, DisciplinaryFlagOverride__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        // assert
        System.assertEquals(PE.DisciplinaryFlagOverride__c, 'Withdraw', 'PE.DisciplinaryFlagOverride__c does not match!');
        system.assertEquals(null, err, 'exceptions!');
    }    
    
    /** 
        Positive test:
            EntryPoint: Code is triggered when PE.DisciplinaryPastActions__c is updated.
            Scenario: 
                When DisciplinaryPastActions__c is set to Yes, Expelled, and the Acedemic Program
                       has been set up with Disciplanary Actions to Withdraw but the first day of school 
                       is in the future and expulsion will have expired.
                Then set PE.DisciplinaryFlagOverride__c = Withdraw
            
    */ 
    @isTest
    public static void PE_Disciplinary_Action_Withdraw_With_Dates() {
        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        acc_academicProgram.Disciplinary_Action_Currently_Expelled__c = 'Withdraw';
        acc_academicProgram.Disciplinary_Action_Currently_Suspended__c = 'Withdraw';
        acc_academicProgram.School_Start_Date__c = Date.newInstance(2040, 12, 9);
        update acc_academicProgram;

        Exception err;
        Test.startTest();
        try {

                // update the PE record and set the DisciplinaryPastActions__c
                PE.DisciplinaryPastActions__c = 'Yes, Expelled';
                PE.End_Date_of_Disciplinary_Action__c = Date.newInstance(2020, 12, 9);
                PE.Status__c = 'In Progress';
                Update PE;
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, DisciplinaryFlagOverride__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        // assert
        System.assertEquals(PE.DisciplinaryFlagOverride__c, Null, 'PE.DisciplinaryFlagOverride__c does not match!');
        system.assertEquals(null, err, 'exceptions!');
    }    

    /** 
        Positive test:
            EntryPoint: Code is triggered when acc_houseHold.Computer_in_Home__c is updated.
            Scenario: 
                When acc_houseHold.Computer_in_Home__c is set to No and the Acedemic Program
                       has been set up with TechnologyFlagAction__c to Pending Review
                Then set PE.UserTechnologyFlag__c = Pending Review
            
    */ 
    @isTest
    public static void PE_Technolog_Flag_Pending_Review() {
        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);      
       
        acc_academicProgram.TechnologyFlagAction__c = 'Pending Review';
        update acc_academicProgram;
        PE.status__c = 'In Progress';
        update PE;
        
        Exception err;
        Test.startTest();
        try {
               //Pe1.status__c = 'In Progress';//added by anitha P  
               //update pe1;
        // Update the household to say there is no computer at home
                acc_houseHold.Computer_in_Home__c = 'No';
                Update acc_houseHold;
        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, UserTechnologyFlag__c from hed__Program_Enrollment__c WHERE Id =: PE.Id];

        // assert
        System.assertEquals('Pending Review', PE.UserTechnologyFlag__c,  'PE.UserTechnologyFlag__c does not match!');//commented
        system.assertEquals(null, err, 'exceptions!');
    }    

        /** 
        Positive test:
            EntryPoint: Code is triggered when a new PE is created.
            Scenario: 
                When acc_houseHold.Computer_in_Home__c is set to No and PE is added
                Then set PE.UserTechnologyFlag__c = Pending Review
            
    */ 
    @isTest
    public static void PE_Technolog_Flag_Pending_Review2() {
        // query test-data
        acc_houseHold = [SELECT Id, Name, shippingstate, ShippingPostalCode FROM Account WHERE Name =: accName_HH limit 1];
        acc_academicProgram = [SELECT Id, Name FROM Account WHERE Name =: academicProgramParentAccName  AND RecordTypeId =: programEnrollmentRecordTypeId limit 1];
        cntct_student = [SELECT Id, Name, AccountId, Account.Shippingstate, Account.ShippingPostalCode FROM Contact limit 1];
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        PE = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        acc_academicProgram.TechnologyFlagAction__c = 'Pending Review';
        update acc_academicProgram;
        PE.status__c = 'In Progress';
        update PE;
        // Update the household to say there is no computer at home
        acc_houseHold.Computer_in_Home__c = 'No';
        Update acc_houseHold;
        hed__Program_Enrollment__c PE2;

        Exception err;
        Test.startTest();
        try {
            //Create a new PE, it should have it's technology flag set.
            PE2 = Peak_TestUtils.createProgramEnrollment(acc_academicProgram.Id, cntct_student.Id, currentSchoolYear.Id, true);

        } catch (Exception e) {
            err = e;
        }
        Test.stopTest();

        // refresh PE
        PE = [SELECT Id, UserTechnologyFlag__c from hed__Program_Enrollment__c WHERE Id =: PE2.Id];

        // assert
        //System.assertEquals('Pending Review', PE.UserTechnologyFlag__c,  'PE.UserTechnologyFlag__c does not match!');//
        system.assertEquals(null, err, 'exceptions!');
    } 

    //Added by jagadeesh - User story : 117580
    @isTest 
    public static void HHFarmEligCalculated (){
        Id Academic = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
         Test.startTest();
        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today());
        Account accObj = Peak_TestUtils.createTestAccount();
        accObj.recordtypeid=Academic;
        accobj.Too_Young_Cutoff__c=system.today();
        accObj.Requires_Special_Education_Review__c=true;
        accObj.School_Year__c=currentSchoolYear.id;
        Update accObj;
        hed__Program_Enrollment__c obj = new hed__Program_Enrollment__c();
        obj.hed__Account__c = accObj.id;
        insert obj;
        
        Annual_Household_Information__c obj1 = new Annual_Household_Information__c();
        obj1.Program_Enrollment__c = obj.id;
        obj1.HH_Has_Food_Stamp_Recipient__c = 'Yes';
        obj1.HH_Has_Foster_Children__c='Yes';
        insert obj1;
        Household_Income__c hIObj = new Household_Income__c();
        hIObj.Program_Enrollment__c = obj.id;
        hIObj.School_Year__c = currentSchoolYear.id;
        insert hIObj;
          test.stopTest();
        map<id,List<Household_Income__c>> mapobj = new map<id,List<Household_Income__c>>();
        mapobj.put(hIObj.id,new list<Household_Income__c>{hIObj});
        NES_BusinessLogicUtils.HHFarmEligCalculated(mapobj,obj1);
        
    }

    
    @isTest
    public static void calculateFederalPovertyEligibility (){
          Account accObj = new Account();
        accObj.name = 'Test Name'; 
        hed__Program_Enrollment__c obj = new hed__Program_Enrollment__c();
        obj.hed__Account__c = accObj.id;
        insert obj;
        Annual_Household_Information__c obj1 = new Annual_Household_Information__c();
        obj1.Program_Enrollment__c = obj.id;
          obj1.Total_Gross_HH_Income__c = 0;
        insert obj1;
        System.debug('value------------->'+obj1.Number_HH_Children__c);
        Household_Income__c hIObj = new Household_Income__c();
        hIObj.Program_Enrollment__c = obj.id;
        currentSchoolYear = [SELECT Id, Name FROM School_Year__c WHERE Name =: currentSchoolYearName limit 1];
        hIObj.School_Year__c = currentSchoolYear.id;
        insert hIObj;
        map<id,List<Household_Income__c>> mapobj = new map<id,List<Household_Income__c>>();
        mapobj.put(hIObj.id,new list<Household_Income__c>{hIObj});
        NES_BusinessLogicUtils.calculateFederalPovertyEligibility(new set<id>{obj.id},new list<Annual_Household_Information__c>{obj1});
        
    }

    //Ended by jagadeesh - User story : 117580
    // Added by Maddileti for the User story #121803 
    @isTest
    public static void getAHIRecord1 (){
      Household_Income__c households=new Household_Income__c();
                          households.LastName__c='Testing';
                                             
        Test.startTest();
        Annual_Household_Information__c  val=NES_BusinessLogicUtils.getAHIRecord(households);
        
        Test.stopTest();
        
    } 
    @isTest
    public static void calculateHHIncomeFosterChild1 (){
        School_Year__c previousSchoolYear          = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2019'));
          hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c = previousSchoolYear.Id;
        insert progEnrollment1;
        List<Household_Income__c> hlas=new List<Household_Income__c>();
               for( integer i=0; i<5; i++){
      Household_Income__c households=new Household_Income__c();
                          households.LastName__c='Testing'+i;
                          households.Program_Enrollment__c=progEnrollment1.Id;
                          households.School_Year__c=previousSchoolYear.id;
                          hlas.add(households);
                           }
        insert hlas;
                          
       Annual_Household_Information__c ahiRecords=new Annual_Household_Information__c();
        ahiRecords.Program_Enrollment__c=progEnrollment1.Id;
        ahiRecords.School_Year__c=previousSchoolYear.Id;
        insert ahiRecords;
        Test.startTest();
         NES_BusinessLogicUtils.calculateHHIncomeFosterChild(hlas);
        
        Test.stopTest();
        
    }
     @isTest
    public static void getTotalGrossHHIncome1 (){
        Household_Income__c households=new Household_Income__c();
                          households.LastName__c='Testing';
                          households.HHAdultIncome_1__c=1;
                          households.HHAdultIncome_2__c=2;
                          households.HHAdultIncome_3__c=3;
                          households.Adult_Income_Received_1__c='2 times per month';
                          households.Adult_Income_Received_2__c='2 times per month';
                          households.Adult_Income_Received_3__c='2 times per month';
                          households.Adult_Income_Other__c=3;
                          households.Adult_Income_Sup__c=4;
                          households.HHAdultIncomeWork__c=4;
                          households.HHChildIncome__c=1;
                          households.Adult_Income_Rec_Other__c='2 times per month';
                          households.HHAdultIncomeRecSup__c='2 times per month';
                          households.HHAdultIncomeRecWork__c='2 times per month';
                          households.HHChildIncomeReceived__c='2 times per month';
                            
        Test.startTest();
         NES_BusinessLogicUtils.getTotalGrossHHIncome(households);
        
        Test.stopTest();
    }
       @isTest
    public static void calculateAutomatedPlacementProcess (){
        //School_Year__c previousSchoolYear= Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2019'));
        date mydate = date.parse('04/12/2019');
     	 School_Year__c previousSchoolYears=new School_Year__c();
        previousSchoolYears.Name='testing';
        previousSchoolYears.Start_Date__c=mydate;
        previousSchoolYears.End_Date__c=mydate;
        previousSchoolYears.Current_Year__c=True;
        insert previousSchoolYears;
        
        Id Academic = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        Account objacc = New Account();
        objacc.Name='test';
        objacc.recordtypeid=Academic;
        Objacc.Alternative_Address_Request__c='Yes';
        Objacc.School_Year__c=previousSchoolYears.id;
        Objacc.Requires_Special_Education_Review__c=true;
        objacc.Too_Young_Cutoff__c=system.today();
        Insert Objacc;
         //currentSchoolYear = Peak_TestUtils.createSchoolYears(currentSchoolYearName, date.parse('11/17/2018'));
        
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c=previousSchoolYears.Id;
        progEnrollment1.hed__Account__c = Objacc.id;
        insert progEnrollment1;
        Special_Education__c specialEds=new Special_Education__c();
        specialEds.Program_Enrollment__c=progEnrollment1.Id;
        specialEds.IEP__c='Documenting';
        specialEds.Plan504__c='504 Missing';
       	specialEds.FormallyExitedIEP__c='Yes';
       	insert specialEds;
        Set<id> setprogEnrollmentid = new set<id> ();
        setprogEnrollmentid.add(progEnrollment1.id);
        Annual_Student_Information__c asis = new Annual_Student_Information__c();
        asis.Program_Enrollment__c = progEnrollment1.id;
            asis.School_Year__c=previousSchoolYears.Id;
         
       // insert asis;
        List<Annual_Student_Information__c> asisRecords=new List<Annual_Student_Information__c>{asis};
            insert asisRecords;
        Records_Request__c recordsReq=new Records_Request__c();
        recordsReq.Program_Enrollment__c=progEnrollment1.id;
        insert recordsReq;
        map<id,List<Records_Request__c>> mapobj = new map<id,List<Records_Request__c>>();
        mapobj.put(recordsReq.id,new list<Records_Request__c>{recordsReq});
        set<Id> pids=new set<Id>{progEnrollment1.Id};
           Opportunity newOpportunity = new Opportunity(
            Program_Enrollment__c = progEnrollment1.Id,
            Name = 'Testing',
            StageName = 'Open',
            CloseDate = System.today(),
            Notes__c ='56988'
        );
        insert newOpportunity;
        System.debug(pids);
        Test.startTest();
        List<hed__Program_Enrollment__c> pewhyflg = NES_BusinessLogicUtils.calculateWhyFlagged(setprogEnrollmentid);
        system.assertEquals(True, pewhyflg[0].WhyFlagged__c.contains('{Special Education}'));
        
        objacc.Requires_Special_Education_Review__c=false;
        update Objacc;
        hed__Program_Enrollment__c progEnrollment2 = new hed__Program_Enrollment__c();
        progEnrollment2.Start_Year__c=previousSchoolYears.Id;
        progEnrollment2.hed__Account__c = Objacc.id;
        insert progEnrollment2;
        
        Set<id> setprogEnrollmentid2 = new set<id> ();
        setprogEnrollmentid2.add(progEnrollment2.id);
      	List<hed__Program_Enrollment__c> pewhyflg1 = NES_BusinessLogicUtils.calculateWhyFlagged(setprogEnrollmentid2);
       for(hed__Program_Enrollment__c hpc1 :pewhyflg1)
       
       	system.assertNotEquals(False, pewhyflg[0].WhyFlagged__c.contains('{Special Education}'));
       	List<Annual_Student_Information__c> valReturns=NES_BusinessLogicUtils.calculateAutomatedPlacementProcess(pids,asisRecords);
        Test.stopTest();
        
        
    }
    //2-feb-2020
     @isTest
    public static void calculateAutomatedPlacementProcess1 (){
        //School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019',System.today());
        School_Year__c currentSchoolYear = new School_Year__c(Name = 'name', End_Date__c = System.today().addDays(20), Start_Date__c = System.today());
        insert currentSchoolYear;
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c=currentSchoolYear.Id;
        insert progEnrollment1;
        
        
        
        // School_Year__c currentSchoolYear1 = Peak_TestUtils.createSchoolYears('2019-2020',System.today());
        School_Year__c currentSchoolYear1 = new School_Year__c(Name = 'name', End_Date__c =System.today().addDays(20), Start_Date__c = System.today());
        insert currentSchoolYear1;
        Annual_Student_Information__c asis = new Annual_Student_Information__c();
        asis.Program_Enrollment__c = progEnrollment1.id;
        asis.School_Year__c=currentSchoolYear1.Id;
         
        //insert asis;
        set<Id> pids=new set<Id>{progEnrollment1.Id};
        List<Annual_Student_Information__c> asisRecords=new List<Annual_Student_Information__c>{asis};
        insert asisRecords;
         Test.startTest();
        List<Annual_Student_Information__c> valReturns=NES_BusinessLogicUtils.calculateAutomatedPlacementProcess(pids,asisRecords);
        Test.stopTest();
        
    }
    //2-feb-2020
    
      @isTest
    public static void placementWhyFlagged1 (){
        //School_Year__c previousSchoolYear= Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2019'));
        date mydate = date.parse('04/12/2019');
        School_Year__c previousSchoolYears=new School_Year__c();
        previousSchoolYears.Name='testing';
        previousSchoolYears.Start_Date__c=mydate;
        previousSchoolYears.End_Date__c=mydate;
        insert previousSchoolYears;
        System.debug('syear:'+previousSchoolYears);
        //currentSchoolYear = Peak_TestUtils.createSchoolYears(currentSchoolYearName, date.parse('11/17/2018'));
        Grade_Level__c glsRecords=new Grade_Level__c();
        glsRecords.Name='testing';
        insert glsRecords;
        //School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, previousSchoolYears.Id);
        
        Program_Grade_Level__c pglRecords=new Program_Grade_Level__c();
        pglRecords.Academic_Program__c=academicProgram.Id;
        pglRecords.Grade_Level__c=glsRecords.Id;
        pglRecords.AutoPlacement_Special_EdExclude__c=FALSE;
        insert pglRecords;
        hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c=previousSchoolYears.Id;
        progEnrollment1.Program_Grade_Level__c=pglRecords.Id;
        progEnrollment1.PlacementFlag__c='Principal Review';
        progEnrollment1.CounselingFlag__c='Stop';
        progEnrollment1.EligibilityFlag__c='Pending';
        progEnrollment1.PriorWithdrawalFlag__c='Hold';
        progEnrollment1.WaitlistFlag__c='Active';
        //progEnrollment1.UserTechnologyFlag__c='Technology Flag';
        progEnrollment1.DisciplinaryFlagOverride__c='Withdraw';
        progEnrollment1.HomelessRiskFlag__c='Potential Homeless';
        progEnrollment1.PrincipalGeneralFlag__c='Released';
        progEnrollment1.GradeLevelEligibility__c='Need additional information';
        progEnrollment1.EntranceAgeEligibility__c='Too old';
        insert progEnrollment1;
        
         Enrollment_Document__c eds=new Enrollment_Document__c();
        eds.Program_Enrollment__c=progEnrollment1.Id;
        eds.Type__c='IEP Exit Documentation';
        eds.Status_Reason__c='Awaiting IEP';
        insert eds;
        Map<Id, List<Enrollment_Document__c>> enrollmentDocumentMap = new Map<Id, List<Enrollment_Document__c>>();
        enrollmentDocumentMap.put(eds.id,new list<Enrollment_Document__c>{eds});
          Opportunity newOpportunity = new Opportunity(
            Program_Enrollment__c = progEnrollment1.Id,
            Name = 'Testing',
            StageName = 'Closed Won',
            CloseDate = System.today(),
            Notes__c ='56988'
        );
        insert newOpportunity;
        
        Special_Education__c speciEds=new Special_Education__c();
        speciEds.Program_Enrollment__c=progEnrollment1.Id;
        speciEds.IEP__c='Documenting';
        speciEds.Plan504__c='504 Missing';
        //speciEds.IEPHistory__c='Yes';
        speciEds.FormallyExitedIEP__c='Yes';
        //speciEds.FormallyExitedIEP__c ='Yes';
        
        insert speciEds;
        Annual_Student_Information__c asRecords = new Annual_Student_Information__c();
        asRecords.Program_Enrollment__c = progEnrollment1.id;
        asRecords.School_Year__c=previousSchoolYears.Id;
        insert asRecords;
        List<Annual_Student_Information__c> asisRecords=new List<Annual_Student_Information__c>{asRecords};
        set<Id> pids=new set<Id>{progEnrollment1.Id};
        
        Test.startTest();
        List<Annual_Student_Information__c> val=NES_BusinessLogicUtils.placementWhyFlagged(pids,asisRecords);
        Test.stopTest();
    } 
      @isTest
    public static void calculateEntranceAgeEligibilityOverrideReview(){
          School_Year__c previousSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2019'));
          hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c = previousSchoolYear.Id;
        insert progEnrollment1;
        List<Hed__Program_Enrollment__c> progenrollments=new List<Hed__Program_Enrollment__c>{progEnrollment1};
        Test.startTest();
        List<Hed__Program_Enrollment__c> val=NES_BusinessLogicUtils.calculateEntranceAgeEligibilityOverrideReview(progenrollments);
        Test.stopTest();
        
    }
            
   // end by Maddileti for the User story #121803
    
    //  added by Jagadeesh for the User story #121803
     @isTest
    public static void calculateTotalGrossHHIncome1(){
        
          School_Year__c previousSchoolYear  = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/19/2019'));
          hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
          progEnrollment1.Start_Year__c = previousSchoolYear.Id;
          insert progEnrollment1;
        
       // Map<Id, List<Household_Income__c>> programEnrollmentToHIMap = new Map<Id, List<Household_Income__c>>();

     List<Household_Income__c> hlas=new List<Household_Income__c>();
      for( integer i=0; i<5; i++){
      Household_Income__c households=new Household_Income__c();
                          households.LastName__c='Testing'+i;
                          households.Program_Enrollment__c=progEnrollment1.Id;
                          households.School_Year__c=previousSchoolYear.id;
                          hlas.add(households);
                           }
        insert hlas;  
        Annual_Household_Information__c ahiInfo = new Annual_Household_Information__c();
        ahiInfo.Program_Enrollment__c = progEnrollment1.id;
        
        insert ahiInfo;
        
        //Test.startTest();
        //NES_BusinessLogicUtils.calculateTotalGrossHHIncome(hlas);
        //Test.stopTest();
        
        //2/20/20
        Annual_Household_Information__c ahiInfo1 = new Annual_Household_Information__c();
        School_Year__c previousSchoolYear1  = Peak_TestUtils.createSchoolYears('2019-2020', date.parse('11/19/2019'));
        ahiInfo1.Program_Enrollment__c = progEnrollment1.id;
        ahiInfo1.School_Year__c = previousSchoolYear1.id;
        insert ahiInfo1;
        Test.startTest();
        NES_BusinessLogicUtils.calculateTotalGrossHHIncome(hlas);
        Test.stopTest();
        //2/20/20
        
    }
    //2/20/20
     @isTest
    public static void calculateTotalGrossHHIncome2(){
        
           School_Year__c previousSchoolYear  = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/19/2019'));
          hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
          progEnrollment1.Start_Year__c = previousSchoolYear.Id;
          insert progEnrollment1;
        
       // Map<Id, List<Household_Income__c>> programEnrollmentToHIMap = new Map<Id, List<Household_Income__c>>();

     List<Household_Income__c> hlas=new List<Household_Income__c>();
      for( integer i=0; i<5; i++){
      Household_Income__c households=new Household_Income__c();
                          households.LastName__c='Testing'+i;
                          households.Program_Enrollment__c=progEnrollment1.Id;
                          households.School_Year__c=previousSchoolYear.id;
                          hlas.add(households);
                           }
        insert hlas;  
         Test.startTest();
        NES_BusinessLogicUtils.calculateTotalGrossHHIncome(hlas);
        Test.stopTest();
        
    }
    //2/20/20
   
      static testMethod void test_populatePEHighSchoolLTSGroup_AfterInsert2(){
      School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
          hed__Program_Enrollment__c pes=new hed__Program_Enrollment__c();
          pes.Start_Year__c=currentSchoolYear.id;
          pes.Status__c='In Progress';
          insert pes;
      hed__Program_Enrollment__c programEnrollment = [Select Id,hed__Account__c,hed__Contact__c from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' AND Start_Year__c =: currentSchoolYear.Id limit 1];
      Annual_Student_Information__c currentASI = Peak_TestUtils.createAnnualStudentInformation('Current ASI', programEnrollment.Id, currentSchoolYear.Id, false);
      currentASI.Grade_Level_Requested__c = '10';
      //currentASI.HS_LTS__c = '1';
          List<hed__Program_Enrollment__c> abcd=new List<hed__Program_Enrollment__c>{programEnrollment};
      Test.startTest();
      insert currentASI;
      Annual_Student_Information__c asiRecord = [SELECT Id,Program_Enrollment__r.HS_LTS_Group__c FROM Annual_Student_Information__c
      WHERE Id =: currentASI.Id];
          NES_BusinessLogicUtils.flagTechnologyAction(abcd);
      //System.assertEquals('Medium HS LTS',asiRecord.Program_Enrollment__r.HS_LTS_Group__c);
      Test.stopTest();
  }
   
     // end by Jagadeesh for the User story #121803
     static testMethod void unitTestPositiveCases(){
        Test.startTest();
        hed__Program_Enrollment__c programEnrollment = [SELECT Id, Start_Year__c FROM hed__Program_Enrollment__c LIMIT 1];
        School_Year__c schoolYear = [SELECT Id FROM School_Year__c LIMIT 1];

        Prior_School__c pSchool = Peak_TestUtils.createPriorSchool(programEnrollment.Id, schoolYear.Id, false);
        pSchool.State__c = 'AA';
        pSchool.SchoolType__c = 'Homeschool';

        insert pSchool;

        pSchool.SchoolType__c = 'Public School';
        update pSchool;

        hed__Program_Enrollment__c programEnrollment1 = [SELECT Id, Start_Year__c,LastSchoolState__c,LastSchoolType__c FROM hed__Program_Enrollment__c LIMIT 1];
        System.assertEquals(pSchool.State__c,programEnrollment1.LastSchoolState__c);
        System.assertEquals(pSchool.SchoolType__c,programEnrollment1.LastSchoolType__c);
        pSchool.State__c = 'AE';
        update pSchool;

        
        hed__Program_Enrollment__c programEnrollment2 = [SELECT Id, Start_Year__c,LastSchoolState__c,LastSchoolType__c FROM hed__Program_Enrollment__c LIMIT 1];
        System.assertEquals(pSchool.State__c,programEnrollment2.LastSchoolState__c);
        Test.stopTest();
    }
     //  Added for the User story #147622
        static testMethod void createUniqueIDTest(){
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
    }
    static testMethod void populateSchoolIDTest(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Educational Institution' limit 1];
        account1.Name = 'New name';
        account1.School_Id__c = '';
        update account1;
    }
    static testMethod void calculateHomelessRiskFlagTest(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Household' limit 1];
        account1.Name = 'New name';
        account1.School_Id__c = '';
        account1.Type_of_Living_Accommodations__c = 'A Primary Nighttime Residence Not Designed For Regular Sleeping Accommodations';
        update account1;
    }
    static testMethod void calculateLTSTest1(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Household' limit 1];
        account1.Name = 'New name';
        account1.School_Id__c = '';
        account1.Type_of_Living_Accommodations__c = 'A Primary Nighttime Residence Not Designed For Regular Sleeping Accommodations';
        account1.Internet_Connection_Type__c = 'DSL';
        update account1;
    }
    static testMethod void calculateLTSTest2(){
        Account account1 = [SELECT Id, Name, RecordType.Name FROM Account WHERE RecordType.Name = 'Household' limit 1];
        account1.Internet_Connection_Type__c = 'Cable';
        account1.LC_HighestLevelofEducation__c = 'High school graduate';
        account1.Mktg_Customer_Loyalty__c = 'Test Customer Loyalty';
        account1.Computer_in_Home__c = 'Yes';
        update account1;
    }
     
     static testMethod void AfterInsertTestScenario1(){
        


        hed__Program_Enrollment__c programEnrollment = [Select Id from hed__Program_Enrollment__c WHERE Status__c = 'In Progress' limit 1];//added by anitha
        School_Year__c currentSchoolYear = [Select Id from School_Year__c where Name = '2018-2019' limit 1];
        Annual_Household_Information__c currentAHI = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI.Income_Opt_Out_Options__c ='Yes';
        
        Annual_Household_Information__c currentAHI1 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI1.Income_Opt_Out_Options__c ='Yes';
        currentAHI1.Total_Gross_HH_Income__c=1;
        currentAHI1.Number_HH_Children__c=10;
        currentAHI1.Number_HH_Adults__c=10;
       
        Annual_Household_Information__c currentAHI2 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI2.Income_Opt_Out_Options__c ='Yes';
        currentAHI2.Total_Gross_HH_Income__c=122500;
        currentAHI2.Number_HH_Children__c=10;
        currentAHI2.Number_HH_Adults__c=10;
        
        Annual_Household_Information__c currentAHI3 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI3.Income_Opt_Out_Options__c ='Yes';
        currentAHI3.Total_Gross_HH_Income__c=174310;
        currentAHI3.Number_HH_Children__c=10;
        currentAHI3.Number_HH_Adults__c=10;
        
        Annual_Household_Information__c currentAHI4 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI4.Income_Opt_Out_Options__c ='I certify that our household does not qualify';
        
        Annual_Household_Information__c currentAHI5 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
            currentAHI5.Income_Opt_Out_Options__c = 'I choose not to provide my income information'; 
        
        Annual_Household_Information__c currentAHI6 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		//currentAHI6.Income_Opt_Out_Options__c = null;
        
        Annual_Household_Information__c currentAHI7 = Peak_TestUtils.createAnnualHouseholdInformation( programEnrollment.Id, currentSchoolYear.Id, false);
		currentAHI7.HH_Has_Food_Stamp_Recipient__c ='Yes';
       
        Household_Income__c currentHI = Peak_TestUtils.createHouseholdIncome(programEnrollment.Id, currentSchoolYear.Id, false);
        currentHI.HHFosterChild__c = 'Yes';
        
        List<Annual_Household_Information__c> ahiList = new List<Annual_Household_Information__c>();
       
        ahiList.add(currentAHI);
        ahiList.add(currentAHI1);
        ahiList.add(currentAHI2);
        ahiList.add(currentAHI3);
		ahiList.add(currentAHI4); 
        ahiList.add(currentAHI5); 
        ahiList.add(currentAHI6);
        ahiList.add(currentAHI7);
        Test.startTest();
        insert ahiList;
        insert currentHI;
        currentAHI.Total_Gross_HH_Income__c =10;
        NES_ECACompletion.shouldRunCompletion = true; 
        NES_Constants.runAssignment = true;
		update currentAHI;
        currentAHI.Income_Opt_Out_Options__c = system.label.NES_AHI_Income_Opt;//added by jagadeesh - user story : 117580 
        update currentAHI;//added by jagadeesh - user story : 117580 
        
        for(Annual_Household_Information__c ahi : [SELECT Federal_Poverty_Eligibility__c FROM Annual_Household_Information__c]){
            System.assertNotEquals(null, ahi.Federal_Poverty_Eligibility__c);
        }

        Test.stopTest();
    } 
     
    static testMethod void reActivationCasetest(){
        School_Year__c previousSchoolYear          = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2019'));
          hed__Program_Enrollment__c progEnrollment1 = new hed__Program_Enrollment__c();
        progEnrollment1.Start_Year__c = previousSchoolYear.Id;
        insert progEnrollment1;
        Set<id> peids=new Set<id>{progEnrollment1.id};
            Test.startTest();
                NES_BusinessLogicUtils.reActivationCase(peids);
            Test.stopTest();
        
    } 
   
}