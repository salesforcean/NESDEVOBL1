@isTest
public class EvaluationUtilsTest  {
    @TestSetup 
    static void setup(){
    }

    static testMethod void testNumberComparisonsEquals(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Number';
        testItem.comparisonValueRight = '5';
        testItem.newValue = 5;
        testItem.operator = '=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 6;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testNumberComparisonsLessThan(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Number';
        testItem.comparisonValueRight = '6';
        testItem.newValue = 5;
        testItem.operator = '<';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 6;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
        
        testItem.newValue = 7;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testNumberComparisonsGreaterThan(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Number';
        testItem.comparisonValueRight = '4';
        testItem.newValue = 5;
        testItem.operator = '>';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        testItem.newValue = 4;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);

        testItem.newValue = 3;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testNumberComparisonsNotEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Number';
        testItem.comparisonValueRight = '6';
        testItem.newValue = 5;
        testItem.operator = '!=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 6;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testNumberComparisonsLessThanOrEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Number';
        testItem.comparisonValueRight = '6';
        testItem.newValue = 5;
        testItem.operator = '<=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 6;
        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        testItem.newValue = 7;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testNumberComparisonsGreaterThanOrEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Number';
        testItem.comparisonValueRight = '6';
        testItem.newValue = 7;
        testItem.operator = '>=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 6;
        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        testItem.newValue = 4;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }

    static testMethod void testDateComparisonsEquals(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Date';
        testItem.comparisonValueRight = Datetime.now().format('MM/dd/YYYY');
        testItem.newValue = Date.today();
        testItem.operator = '=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        date futureDate = Date.today().addDays(5);
        testItem.newValue = futureDate;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testDateComparisonsLessThan(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Date';
        testItem.comparisonValueRight = Datetime.now().format('MM/dd/YYYY');
        date pastDate = Date.today().addDays(-5);
        testItem.newValue = pastDate;
        testItem.operator = '<';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        date futureDate = Date.today().addDays(5);
        testItem.newValue = futureDate;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testDateComparisonsGreaterThan(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Date';
        testItem.comparisonValueRight = Datetime.now().format('MM/dd/YYYY');
        date futureDate = Date.today().addDays(5);
        testItem.newValue = futureDate;
        testItem.operator = '>';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        futureDate = Date.today().addDays(-5);
        testItem.newValue = futureDate;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testDateComparisonsNotEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Date';
        testItem.comparisonValueRight = Datetime.now().format('MM/dd/YYYY');
        date futureDate = Date.today().addDays(5);
        testItem.newValue = futureDate;
        testItem.operator = '!=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = Date.today();
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testDateComparisonsLessThanOrEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Date';
        testItem.comparisonValueRight = Datetime.now().format('MM/dd/YYYY');
        date futureDate = Date.today().addDays(-5);
        testItem.newValue = futureDate;
        testItem.operator = '<=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = Date.today();
        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        futureDate = Date.today().addDays(5);
        testItem.newValue = futureDate;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testDateComparisonsGreaterThanOrEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Date';
        testItem.comparisonValueRight = Datetime.now().format('MM/dd/YYYY');
        date futureDate = Date.today().addDays(5);
        testItem.newValue = futureDate;
        testItem.operator = '>=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = Date.today();
        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        futureDate = Date.today().addDays(-5);
        testItem.newValue = futureDate;
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }

    static testMethod void testOtherComparisonsEquals(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.comparisonValueRight = 'dog';
        testItem.newValue = 'dog';
        testItem.operator = '=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 'cat';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testOtherComparisonsLessThan(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.comparisonValueRight = 'dog';
        testItem.newValue = 'cat';
        testItem.operator = '<';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 'mouse';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testOtherComparisonsGreaterThan(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.comparisonValueRight = 'dog';
        testItem.newValue = 'mouse';
        testItem.operator = '>';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 'cat';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testOtherComparisonsNotEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.comparisonValueRight = 'dog';
        testItem.newValue = 'cat';
        testItem.operator = '!=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 'dog';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testOtherComparisonsLessThanOrEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.comparisonValueRight = 'dog';
        testItem.newValue = 'dog';
        testItem.operator = '<=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 'cat';
        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        testItem.newValue = 'mouse';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testOtherComparisonsGreaterThanOrEqual(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.comparisonValueRight = 'dog';
        testItem.newValue = 'dog';
        testItem.operator = '>=';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.newValue = 'mouse';
        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);
        
        testItem.newValue = 'cat';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }

    static testMethod void testOtherComparisonsContains(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.newValue = 'catdoglike';
        testItem.comparisonValueRight = 'dog'; 
        testItem.operator = 'CONTAINS';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.comparisonValueRight = 'mouse';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }
    
    static testMethod void testOtherComparisonsDoesNotContain(){
        EvaluationUtils.criteriaItem testItem = new EvaluationUtils.criteriaItem();
        testItem.comparisonDataType = 'Text';
        testItem.newValue = 'catdoglike';
        testItem.comparisonValueRight = 'mouse';
        testItem.operator = 'DOES NOT CONTAIN';

        testItem.calculateNewResult();
        System.assertEquals(true, testItem.newResult);

        testItem.comparisonValueRight = 'cat';
        testItem.calculateNewResult();
        System.assertEquals(false, testItem.newResult);
    }

    static testMethod void testPassingFieldsUpdatesPECriteria(){
        Criteria__c criteria1 = Peak_TestUtils.createCriteriaRecord(null, 'Annual_Student_Information__c.Grade_Level_Requested__c', '=', false);
        criteria1.Comparison_Data_Type__c = 'Text';
        criteria1.Comparison_Value__c = '5';
        insert criteria1;

        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        hed__program_enrollment__c program_enrollment_1 = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert program_enrollment_1;

        //Insert a Program Enrollment Criteria record that will link the PE to the Criteria record created above.
        Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c (Program_Enrollment__c=program_enrollment_1.Id, Criteria__c = criteria1.id, Result__c = false);
        insert newPEC;

        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> ();
        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
        newFieldUpdate.programEnrollmentId = program_enrollment_1.Id;
        newFieldUpdate.objectAndFieldName = 'Annual_Student_Information__c.Grade_Level_Requested__c';
        newFieldUpdate.newValue = '5';
        fieldUpdateList.add(newFieldUpdate);

        Test.startTest();
        EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        Test.stopTest();

        List<Program_Enrollment_Criteria__c> afterEvaluate = new List<Program_Enrollment_Criteria__c> ([select Result__c from Program_Enrollment_Criteria__c]);

        System.assertEquals(true, afterEvaluate[0].Result__c);
    }


    static testMethod void testPassingFieldsUpdatesPECriteria2(){
        Criteria__c criteria1 = Peak_TestUtils.createCriteriaRecord(null, 'Annual_Student_Information__c.Grade_Level_Requested__c', '=', false);
        criteria1.Comparison_Data_Type__c = 'Text';
        criteria1.Comparison_Value__c = '5';
        insert criteria1;

        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        hed__program_enrollment__c program_enrollment_1 = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert program_enrollment_1;

        //Insert a Program Enrollment Criteria record that will link the PE to the Criteria record created above.
        Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c (Program_Enrollment__c=program_enrollment_1.Id, Criteria__c = criteria1.id, Result__c = false, School_Year__c = '2019-2020');
        insert newPEC;

        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> ();
        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
        newFieldUpdate.programEnrollmentId = program_enrollment_1.Id;
        newFieldUpdate.objectAndFieldName = 'Annual_Student_Information__c.Grade_Level_Requested__c';
        newFieldUpdate.schoolYear = '2019-2020';
        newFieldUpdate.newValue = '5';
        fieldUpdateList.add(newFieldUpdate);

        Test.startTest();
        EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        Test.stopTest();

        List<Program_Enrollment_Criteria__c> afterEvaluate = new List<Program_Enrollment_Criteria__c> ([select Result__c from Program_Enrollment_Criteria__c]);

        //This test confirms that when the the school year is used and they match, the criteria is updated.
        System.assertEquals(true, afterEvaluate[0].Result__c);
    }

    static testMethod void testPassingFieldsUpdatesPECriteria3(){
        Criteria__c criteria1 = Peak_TestUtils.createCriteriaRecord(null, 'Annual_Student_Information__c.Grade_Level_Requested__c', '=', false);
        criteria1.Comparison_Data_Type__c = 'Text';
        criteria1.Comparison_Value__c = '5';
        insert criteria1;

        //Create Educational Institutional Account i.e.., Parent Account
        Account institutionAccount = Peak_TestUtils.createEducationalInstitutionAccount();
        //Insert the School Year record
        School_Year__c schoolYear = Peak_TestUtils.createSchoolYears('Test School Year', System.today());

        //Create Academic Program Account i.e.., Child Account
        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(institutionAccount.Id, schoolYear.Id);
        academicProgram.Registration_Start_Date__c = System.today().addDays(-10);
        academicProgram.Registration_End_Date__c = System.today().addDays(10);
        update academicProgram;

        // Create a Contact with 'Caretaker' record type
        Contact careTakerContact = Peak_TestUtils.createTestContact('Caretaker', institutionAccount.Id);

        //Create a care taker user for community
        User careTaker = Peak_TestUtils.CreatePortalCaretTakerUser(careTakerContact.Id);

        // Create a Contact with 'Students' record type
        Contact student = Peak_TestUtils.createTestContact('Students', institutionAccount.Id);

        hed__program_enrollment__c program_enrollment_1 = Peak_TestUtils.createProgramEnrollment(String.valueOf(academicProgram.Id), String.valueOf(Student.Id), String.valueOf(schoolYear.Id), false);
        insert program_enrollment_1;

        //Insert a Program Enrollment Criteria record that will link the PE to the Criteria record created above.
        Program_Enrollment_Criteria__c newPEC = new Program_Enrollment_Criteria__c (Program_Enrollment__c=program_enrollment_1.Id, Criteria__c = criteria1.id, Result__c = false, School_Year__c = '2019-2020');
        insert newPEC;

        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> ();
        EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
        newFieldUpdate.programEnrollmentId = program_enrollment_1.Id;
        newFieldUpdate.objectAndFieldName = 'Annual_Student_Information__c.Grade_Level_Requested__c';
        newFieldUpdate.schoolYear = 'NOT2019-2020';  //Notice that the school doesn't match from the school year from the PE Criteria
        newFieldUpdate.newValue = '5';
        fieldUpdateList.add(newFieldUpdate);

        Test.startTest();
        EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        Test.stopTest();

        List<Program_Enrollment_Criteria__c> afterEvaluate = new List<Program_Enrollment_Criteria__c> ([select Result__c from Program_Enrollment_Criteria__c]);

        //This test confirms that when the the school year is used and they DON'T match, the criteria is NOT updated.
        System.assertEquals(false, afterEvaluate[0].Result__c);
    }
}