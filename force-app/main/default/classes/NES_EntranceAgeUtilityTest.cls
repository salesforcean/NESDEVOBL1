/**
 * Created by Ashish Sharma on 12/14/18
 * Class Name: NES_EntranceAgeUtilityTest
 * Purpose : Test class for NES_EntranceAgeUtility and triggers where NES_EntranceAgeUtility is being used
 * 12/12/18 - Removed old Age Eligibility Logic US114797 (Andrew Sim)
*/
@isTest
public class NES_EntranceAgeUtilityTest {
    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Method to setup the test data
    */
    @TestSetup
    static void setup() {
        List<NES_LogicFeatureSwitch__c> logicSwitches = new List<NES_LogicFeatureSwitch__c>();
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch(NES_EntranceAgeUtility.ENTRANCE_AGE_CUSTOM_SETTING_VALUE, false));
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch('ProgramEnrollmentTrigger', false));
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch('ContactTrigger', false));
        logicSwitches.add(Peak_TestUtils.createNESBusinessLogicSwitch('SpecialEdTrigger', false));
        insert logicSwitches;

        Account account = Peak_TestUtils.createTestAccount(); 

        School_Year__c currentSchoolYear = Peak_TestUtils.createSchoolYears('2018-2019', date.parse('11/17/2018'));
        currentSchoolYear.Current_Year__c = true;
        update currentSchoolYear;

        Contact contact1 = new Contact(firstName = Peak_TestConstants.FIRSTNAME, lastName = 'LASTNAME', email = Peak_TestConstants.STANDARD_EMAIL);
        contact1.accountId = account.id;
        insert contact1;

        Contact contact = Peak_TestUtils.createTestContact('Caretaker', account.Id);
        contact.Birthdate__c = Date.today();
        update contact;

        Account academicProgram = Peak_TestUtils.createAccountForNewStudentData(account.Id, currentSchoolYear.Id);
        academicProgram.PushToSecondSemester__c = Datetime.now().addDays(5);
        update academicProgram;

        Grade_Level__c gradeLevel = new Grade_Level__c(Name = '2');
        insert gradeLevel;

        Program_Grade_Level__c programGradeLevel = new Program_Grade_Level__c(Grade_Level__c = gradeLevel.Id, Academic_Program__c = academicProgram.Id);
        insert programGradeLevel;
    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if EntranceAgeEligibilityOverride__c is released
    
 * 12/12/18 - Removed old Age Eligibility Logic US114797 (Andrew Sim)
     */
/*
    static testMethod void testReleasedOverride() {
        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment([SELECT Id FROM Account WHERE ParentId != null LIMIT 1][0].Id,
                                                                                       [SELECT Id FROM Contact LIMIT 1][0].Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, false);

        enrollment.Final_Grade_Level__c = '1';
        enrollment.EntranceAgeEligibilityOverride__c = NES_EntranceAgeUtility.RELEASED;
        insert enrollment;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibility__c is Eligible or not
        System.assertEquals(NES_EntranceAgeUtility.ELIGIBLE, [SELECT EntranceAgeEligibility__c FROM hed__Program_Enrollment__c WHERE Id =: enrollment.Id].EntranceAgeEligibility__c);
    }
*/
    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if Contact's birthday is null
     */
   
    static testMethod void testContactBirthdateNUll() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE Lastname = 'LASTNAME' LIMIT 1];
        System.debug('contact'+contact.Id);
        Account account = [SELECT Id FROM Account WHERE ParentId != null LIMIT 1];
        Id schoolYearId = [SELECT Id FROM School_Year__c LIMIT 1][0].Id;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id,
                                                                                       contact.Id,
                                                                                       schoolYearId, false);
        insert enrollment;

        hed__Program_Enrollment__c enroll = [SELECT Id, hed__Contact__c, hed__Contact__r.Birthdate__c FROM hed__Program_Enrollment__c WHERE Id =:enrollment.Id];
        System.debug('Contact++++'+enroll.hed__Contact__c);
        System.debug('Contact++++'+enroll.hed__Contact__r.Birthdate__c);

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

		Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
		insert specialEducation;

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibility__c is NOT_ELIGIBLE_NO_BIRTHDAY or not
        System.assertEquals(NES_EntranceAgeUtility.NOT_ELIGIBLE_NO_BIRTHDAY, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                              WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);

		//Now Call it passing the contact records.
		List<sObject> contacts = new List<sObject>();
		contact.Birthdate__c = System.today();
		update contact;
        contacts.add(contact);

		NES_EntranceAgeUtility.shouldCalculateAgeEligibility = true;
        NES_EntranceAgeUtility.calculateEntranceAgeEligibility(contacts);

        //Assert test should not longer be NOT_ELIGIBLE_NO_BIRTHDAY 
        System.assertNotEquals(NES_EntranceAgeUtility.NOT_ELIGIBLE_NO_BIRTHDAY, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                              WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);

    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if student is too young
        */

    static testMethod void testStudentTooYoung() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE ParentId != null LIMIT 1];

        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('1', account.Id, Peak_TestUtils.createGradeLevel('1', true).Id,
                                                                                          Datetime.now(), false);
        programGradeLevel.MinBirthdate__c = Date.today().addMonths(2);
        insert programGradeLevel;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, false);

        enrollment.Final_Grade_Level__c = '1';
        insert enrollment;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

		Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
		insert specialEducation;

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibilitySystem__c is TOO_YOUNG or not
        System.assertEquals(NES_EntranceAgeUtility.ELIGIBLE, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                               WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);
    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if student is too old
        */

    static testMethod void testStudentTooOld() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id, MaxBirthdate__c FROM Account WHERE ParentId != null LIMIT 1];
        account.MaxBirthdate__c = Date.today().addMonths(-2);
        update account;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = NES_EntranceAgeUtility.MORE_THAN_THREE_YEARS;
        insert specialEducation;

        account.MaxBirthdate__c = null;
        account.MaxSpecialEdBirthdate__c = Date.today().addMonths(-2);
        update account;

        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
        update specialEducation;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibility__c is TOO_OLD or not
        System.assertEquals(NES_EntranceAgeUtility.ELIGIBLE, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                             WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);
    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if student is too young other option
        */

    static testMethod void testStudentTooYoungOtherOption() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE ParentId != null LIMIT 1];

        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('1', account.Id, Peak_TestUtils.createGradeLevel('1', true).Id,
                                                                                          Datetime.now(), false);
        programGradeLevel.TooYoung_OtherOptions_Start__c = Date.today().addMonths(-2);
        programGradeLevel.TooYoung_OtherOptions_End__c = Date.today().addMonths(2);
        insert programGradeLevel;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, false);

        enrollment.Final_Grade_Level__c = '1';
        enrollment.Program_Grade_Level__c = programGradeLevel.Id;
        insert enrollment;

		Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
		insert specialEducation;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibilitySystem__c is TOO_YOUNG_OTHER or not
        System.assertEquals(NES_EntranceAgeUtility.TOO_YOUNG_OTHER, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                     WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);

		//Now Call it passing the special ed records.
		List<sObject> specEdRecs = new List<sObject>();
        specEdRecs.add(specialEducation);

		NES_EntranceAgeUtility.shouldCalculateAgeEligibility = true;
        NES_EntranceAgeUtility.calculateEntranceAgeEligibility(specEdRecs);

        System.assertEquals(NES_EntranceAgeUtility.TOO_YOUNG_OTHER, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                     WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);

    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if student is POSSIBLY_TOO_OLD
        */

    static testMethod void testStudentPossibleTooOld() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id, MaxBirthdate__c FROM Account WHERE ParentId != null LIMIT 1];
        //Start : Ritvik Updated account fields on 01/04/19.
        account.Possibly_Too_Old_Start_Date__c = Date.today().addMonths(-2);
        account.Possibly_Too_Old_End_Date__c = Date.today().addMonths(2);
        update account;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = NES_EntranceAgeUtility.MORE_THAN_THREE_YEARS;
        insert specialEducation;

        account.Possibly_Too_Old_Start_Date__c = null;
        account.Possibly_Too_Old_End_Date__c = null;
        account.Possibly_Too_Old_Start_Date_SPED__c = Date.today().addMonths(-2);
        account.Possibly_Too_Old_End_Date_SPED__c = Date.today().addMonths(2);
        //End
        update account;

        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
        update specialEducation;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibility__c is TOO_OLD or not
        System.assertEquals(NES_EntranceAgeUtility.POSSIBLY_TOO_OLD, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);
    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if student is TOO_OLD_OTHER
        */

    static testMethod void testStudentPossibleTooOldOther() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id, MaxBirthdate__c FROM Account WHERE ParentId != null LIMIT 1];
        //Start : Ritvik Updated account fields on 01/04/19.
        account.Too_Old_Other_Options_Start__c = Date.today().addMonths(-2);
        account.Too_Old_Other_Options_End__c = Date.today().addMonths(2);
        update account;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, true);

        Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = NES_EntranceAgeUtility.MORE_THAN_THREE_YEARS;
		specialEducation.IEPHistory__c = 'No';
        insert specialEducation;

        account.Too_Old_Other_Options_Start__c = null;
        account.Too_Old_Other_Options_End__c = null;
        account.Too_Old_Other_Options_Start_SPED__c = Date.today().addMonths(-2);
        account.Too_Old_Other_Options_End_SPED__c = Date.today().addMonths(2);
        //End
        update account;

        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
        update specialEducation;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibilitySystem__c is TOO_OLD or not
        System.assertEquals(NES_EntranceAgeUtility.TOO_OLD_OTHER, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                         WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);
    }

    /**
     * Created by Ashish Sharma on 12/14/18
     * Parameters: N/A
     * Return Type: void
     * Purpose : Test Method to test the functionality if student is in current year
        */



	static testMethod void testStudentTooYoungTransK() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE ParentId != null LIMIT 1];
		account.OffersTransitionalK__c = true;
        update account;

        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('1', account.Id, Peak_TestUtils.createGradeLevel('1', true).Id,
                                                                                          Datetime.now(), false);
        programGradeLevel.TooYoung_OtherOptions_Start__c = Date.today().addMonths(-2);
        programGradeLevel.TooYoung_OtherOptions_End__c = Date.today().addMonths(2);
        insert programGradeLevel;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,
                                                                                       [SELECT Id FROM School_Year__c LIMIT 1][0].Id, false);

        enrollment.Final_Grade_Level__c = '1';
        enrollment.Program_Grade_Level__c = programGradeLevel.Id;
        insert enrollment;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibilitySystem__c is PENDING_MORE_INFO or not
		//Since the school offers trans k but the asi record does not indicate they have either rejected or accepted it,
		//the status should be Pending more info.
        System.assertEquals(NES_EntranceAgeUtility.PENDING_MORE_INFO, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                     WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);
    }

	static testMethod void testStudentTooYoungTransKTooYoung() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        Account account = [SELECT Id FROM Account WHERE ParentId != null LIMIT 1];
		account.OffersTransitionalK__c = true;
        update account;

        Program_Grade_Level__c programGradeLevel = Peak_TestUtils.createProgramGradeLevel('1', account.Id, Peak_TestUtils.createGradeLevel('1', true).Id,
                                                                                          Datetime.now(), false);
        programGradeLevel.TooYoung_OtherOptions_Start__c = Date.today().addMonths(-2);
        programGradeLevel.TooYoung_OtherOptions_End__c = Date.today().addMonths(2);
        insert programGradeLevel;

        Id schoolYearId = [SELECT Id FROM School_Year__c LIMIT 1][0].Id;

        hed__Program_Enrollment__c enrollment = Peak_TestUtils.createProgramEnrollment(account.Id, contact.Id,schoolYearId, false);

        enrollment.Final_Grade_Level__c = '1';
        enrollment.Program_Grade_Level__c = programGradeLevel.Id;
        insert enrollment;

		Special_Education__c specialEducation = Peak_TestUtils.createSpecialEducation(enrollment.Id, false);
        specialEducation.IEPLastUpdated__c = 'Within the last year';
		specialEducation.IEPHistory__c = 'No';
		insert specialEducation;

        Annual_Student_Information__c asi = new Annual_Student_Information__c(School_Year__c = schoolYearId, Program_Enrollment__c = enrollment.Id, TransitionalKAcknowledgement__c = 'No', Final_Grade_Level__c = '2');
        insert asi;

        List<hed__Program_Enrollment__c> enrollments = new List<hed__Program_Enrollment__c>();
        enrollments.add(enrollment);

        enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        update enrollments;

        //Assert test if EntranceAgeEligibilitySystem__c is TOO_YOUNG or not
		//Since the school offers trans k and the asi record indicates they have rejected it,
		//the status should be too young.
        System.assertEquals(NES_EntranceAgeUtility.TOO_YOUNG, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                     WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);



		asi.TransitionalKAcknowledgement__c = 'Yes';
		update asi;

		//Now Call it passing the asi records.
		List<sObject> asis = new List<sObject>();
        asis.add(asi);

		NES_EntranceAgeUtility.shouldCalculateAgeEligibility = true;
        NES_EntranceAgeUtility.calculateEntranceAgeEligibility(asis);

		//enrollments = NES_EntranceAgeUtility.processProgramEnrollments(enrollments);
        //update enrollments;

        System.assertEquals(NES_EntranceAgeUtility.ELIGIBLE, [SELECT EntranceAgeEligibilitySystem__c FROM hed__Program_Enrollment__c
                                                                     WHERE Id =: enrollment.Id].EntranceAgeEligibilitySystem__c);


    }

    static testMethod void unitTest1() {
        Contact contact = [SELECT Id, Birthdate__c FROM Contact WHERE LastName != 'LASTNAME' LIMIT 1];
        contact.LastName = 'New Lastname';
        update contact; 

    }
}