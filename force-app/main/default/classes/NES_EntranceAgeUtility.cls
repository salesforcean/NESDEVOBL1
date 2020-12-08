/**
 * Created by Ashish Sharma on 12/12/18
 * Class Name: NES_EntranceAgeUtility
 * Test Class Name: NES_EntranceAgeUtilityTest
 * Purpose : Utility class to calculate the entrance age eligibility
 * 12/12/18 - Removed old Age Eligibility Logic US114797 (Andrew Sim)
*/
public without sharing class  NES_EntranceAgeUtility {
    //Constants
    public static final String ENTRANCE_AGE_CUSTOM_SETTING_VALUE = 'Entrance Age Eligibility Calculation';
    static final String CONTACT_SOBJECT = 'Contact';
    static final String SPECIAL_EDUCATION_SOBJECT = 'Special_Education__c';
    static final String PROGRAM_ENROLLMENT_SOBJECT = 'hed__Program_Enrollment__c';
    static final String ANNUAL_STUDENT_INFORMATION_SOBJECT = 'Annual_Student_Information__c';
    public static final String RELEASED = 'Released';
    public static final String ELIGIBLE = 'Eligible';
    public static final String NOT_ELIGIBLE_NO_BIRTHDAY = 'NOT ELIGIBLE-No Birthdate';
    public static final String TOO_YOUNG = 'Too young';
    public static final String TOO_OLD = 'Too old';
    public static final String TOO_YOUNG_OTHER = 'Too young - other options';
    public static final String POSSIBLY_TOO_OLD = 'Possibly too old';
    public static final String TOO_OLD_OTHER = 'Too old - other options';
    public static final String PENDING_MORE_INFO = 'Pending - More Information Needed';

	
    static final String NA = 'NA';
    public static final String MORE_THAN_THREE_YEARS = 'More than three years ago';
    static final Set<String> LESS_THAN_THREE_YEARS_SET = new Set<String>{'Within the last year', 'Within the last two years',
                                                                         'Within the last three years'};

    //switch to enable entrance age eligibility calculation logic
    public static Boolean entranceAgeEligibilitySwitch = NES_TriggerUtility.businessLogicSwitch(ENTRANCE_AGE_CUSTOM_SETTING_VALUE);

    public static Boolean shouldCalculateAgeEligibility = true;

    /**
     * Created by Ashish Sharma on 12/12/18
     * Parameters: List<sObject>
     * Return Type: void
     * Purpose : Method to calculate Entrance Age Eligibility
    */
    public static void calculateEntranceAgeEligibility(List<sObject> records){
        /*
 * 12/12/18 - Removed old Age Eligibility Logic US114797 (Andrew Sim)
         */
		/* Mark Membrino 2/13/2020 Bug 137045  Some schools didn't like this opt out.
        if (!shouldCalculateAgeEligibility) {
            return;
        } else {
            shouldCalculateAgeEligibility = false;
        } */

        system.debug('in calculateEntranceAgeEligibility');
        try{
            if(records != null && records.size() > 0){
                //List of program enrollments needs to be updated if the trigger is running on Contact and Special Education objects
                List<hed__Program_Enrollment__c> programEnrollmentsToUpdate = new List<hed__Program_Enrollment__c>();

                //check the typ of object on which trigger is executing
                String sObjectType = String.valueOf(records[0].getSObjectType());

                //calculate entrance age eligibility if trigger is running in program enrollment object
                if(sObjectType == PROGRAM_ENROLLMENT_SOBJECT){
                    system.debug('entranceAgeEligibility: Program Enrollment Change Detected');

                    processProgramEnrollments(records);
                }else if(sObjectType == CONTACT_SOBJECT){//calculate entrance age eligibility if trigger is running on contact object
                    system.debug('entranceAgeEligibility: Contact Change Detected');

                    System.debug('In Contact Object loop++');
                    Set<Id> contactIds = new Set<Id>();

                    for(Contact contact : (List<Contact>)records){
                        contactIds.add(contact.Id);
                    }

                    if(contactIds.size() > 0){
                        List<hed__Program_Enrollment__c> tempEnrollments = new List<hed__Program_Enrollment__c>();

                        for(hed__Program_Enrollment__c programEnrollment : [SELECT Id, hed__Contact__c, Start_Year__c,
                                                                            hed__Account__c, Final_Grade_Level__c, EntranceAgeEligibilityOverride__c,
																			EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c
                                                                            FROM hed__Program_Enrollment__c
                                                                            WHERE hed__Contact__c IN: contactIds and Status__c = 'In Progress']){

                            tempEnrollments.add(programEnrollment);
                        }

                        programEnrollmentsToUpdate = processProgramEnrollments(tempEnrollments);
                    }
                }else if(sObjectType == SPECIAL_EDUCATION_SOBJECT){ //calculate entrance age eligibility if trigger is running on special education object
                    system.debug('entranceAgeEligibility: Special Education Change Detected');

                    Set<Id> tempEnrollmentIds = new Set<Id>();

                    for(Special_Education__c specialEducation : (List<Special_Education__c>)records){
                        tempEnrollmentIds.add(specialEducation.Program_Enrollment__c);
                    }

                    if(tempEnrollmentIds.size() > 0){
                        List<hed__Program_Enrollment__c> tempEnrollments = new List<hed__Program_Enrollment__c>();

                        for(hed__Program_Enrollment__c programEnrollment : [SELECT Id, hed__Contact__c, Start_Year__c,
                                                                            hed__Account__c, Final_Grade_Level__c, EntranceAgeEligibilityOverride__c,
                                                                            EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c
																			FROM hed__Program_Enrollment__c
                                                                            WHERE Id IN: tempEnrollmentIds and Status__c = 'In Progress']){

                            tempEnrollments.add(programEnrollment);
                        }

                        programEnrollmentsToUpdate = processProgramEnrollments(tempEnrollments);
                    }
                }else if(sObjectType == ANNUAL_STUDENT_INFORMATION_SOBJECT){ //calculate entrance age eligibility if trigger is running on ASI object
                    system.debug('entranceAgeEligibility: ASI Change Detected');

                    Set<Id> tempEnrollmentIds = new Set<Id>();

                    for(Annual_Student_Information__c asiRec : (List<Annual_Student_Information__c>)records){
                        tempEnrollmentIds.add(asiRec.Program_Enrollment__c);
                    }

                    if(tempEnrollmentIds.size() > 0){
                        List<hed__Program_Enrollment__c> tempEnrollments = new List<hed__Program_Enrollment__c>();

                        for(hed__Program_Enrollment__c programEnrollment : [SELECT Id, hed__Contact__c, Start_Year__c,
                                                                            hed__Account__c, Final_Grade_Level__c, EntranceAgeEligibilityOverride__c,
                                                                            EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c
																			FROM hed__Program_Enrollment__c
                                                                            WHERE Id IN: tempEnrollmentIds and Status__c = 'In Progress']){

                            tempEnrollments.add(programEnrollment);
                        }

                        programEnrollmentsToUpdate = processProgramEnrollments(tempEnrollments);
                    }
                }

                if(programEnrollmentsToUpdate.size() > 0 && (sObjectType == CONTACT_SOBJECT || sObjectType == SPECIAL_EDUCATION_SOBJECT || sObjectType == ANNUAL_STUDENT_INFORMATION_SOBJECT)){
                    System.debug('programEnrollmentsToUpdate+++'+programEnrollmentsToUpdate);
                    update programEnrollmentsToUpdate;
                }
            }
        }catch(Exception e){System.debug('ERROR in NES_EntranceAgeUtility >> ' + e.getMessage()); throw e;}
    }

    /**
     * Created by Ashish Sharma on 12/12/18
     * Parameters: List<hed__Program_Enrollment__c>
     * Return Type: List<hed__Program_Enrollment__c>
     * Purpose : Method to process the related program enrollments
    */
    public static List<hed__Program_Enrollment__c> processProgramEnrollments(List<hed__Program_Enrollment__c> records){
        System.debug('EntranceAgeEligibility: processProgramEnrollments+++'+records);
        Set<Id> contactIds = new Set<Id>();
        Set<Id> startYearIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> programEnrollmentIds = new Set<Id>();
        List<hed__Program_Enrollment__c> programEnrollmentsToUpdate = new List<hed__Program_Enrollment__c>();
/*
 * 12/12/18 - Removed old Age Eligibility Logic US114797 (Andrew Sim)
         */
//iterate the program enrollment records and populate the sets to get the related object records information
        for(hed__Program_Enrollment__c programEnrollment : records){
            if(programEnrollment.hed__Contact__c != null){
                System.debug('programEnrollment.hed__Contact__c::::'+programEnrollment.hed__Contact__c);
                contactIds.add(programEnrollment.hed__Contact__c);
            }

            if(programEnrollment.Start_Year__c != null){
                startYearIds.add(programEnrollment.Start_Year__c);
            }

            if(programEnrollment.hed__Account__c !=  null){
                accountIds.add(programEnrollment.hed__Account__c);
            }

            if(programEnrollment.Id <> null){//if trigger is on update
                programEnrollmentIds.add(programEnrollment.Id);
            }
        }

        System.debug(contactIds);
        //Retrieve and populate the related contact information in contactDetailMap
        Map<Id, Contact> contactDetailMap = new Map<Id, Contact>();

        List<Contact> currentContacts = [SELECT Id, Birthdate__c FROM Contact WHERE Id IN: contactIds];
        for(Contact contact1 : currentContacts ){
            contactDetailMap.put(contact1.Id, contact1);
        }

        //Retrieve and populate the current year Ids in currentYearIds
        Set<Id> currentYearIds = new Set<Id>();

        for(School_Year__c schoolYear : [SELECT Id FROM School_Year__c WHERE ID IN: startYearIds AND Current_Year__c = true]){
            currentYearIds.add(schoolYear.Id);
        }

        //Retrieve and populate the related Program_Grade_Level__c information in accGradeLevelMap
        Map<Id, Map<String, Program_Grade_Level__c>> accGradeLevelMap = new Map<Id, Map<String, Program_Grade_Level__c>>();

        for(Program_Grade_Level__c gradeLevel : [SELECT Id, Grade_Level__r.Name, Academic_Program__c, MinBirthdate__c,
                                                 TooYoung_OtherOptions_Start__c, TooYoung_OtherOptions_End__c
                                                 FROM Program_Grade_Level__c
                                                 WHERE Academic_Program__c IN: accountIds]){

            if(!accGradeLevelMap.containsKey(gradeLevel.Academic_Program__c)){
                accGradeLevelMap.put(gradeLevel.Academic_Program__c, new Map<String, Program_Grade_Level__c>());
            }

            accGradeLevelMap.get(gradeLevel.Academic_Program__c).put(gradeLevel.Grade_Level__r.Name, gradeLevel);
        }

        //Retrieve and populate the related program information in accountDetailMap
        Map<Id, Account> accountDetailMap = new Map<Id, Account>();

        //Start : Ritvik Updated account fields on 01/04/19.
        for(Account program : [SELECT Id, MaxBirthdate__c, MaxSpecialEdBirthdate__c, Possibly_Too_Old_End_Date__c,
                               Possibly_Too_Old_Start_Date__c, Possibly_Too_Old_Start_Date_SPED__c, Possibly_Too_Old_End_Date_SPED__c,
                               Too_Old_Other_Options_Start__c, Too_Old_Other_Options_End__c, Too_Old_Other_Options_Start_SPED__c,
                               Too_Old_Other_Options_End_SPED__c, Too_Young_Cutoff__c, OffersTransitionalK__c FROM Account WHERE Id IN: accountIds]){
            accountDetailMap.put(program.Id, program);
        }

        //Retrieve and populate the related Special_Education__c information in enrollmentSEMap
        Map<Id, Special_Education__c> enrollmentSEMap = new Map<Id, Special_Education__c>();
		Map<Id,Id> enrollmentStartYearMap = new Map<Id,Id> ();

        List<hed__Program_Enrollment__c> enrollments = [
                SELECT Id, Program_Grade_Level__c, Program_Grade_Level__r.Grade_Level__r.Name, hed__Contact__c, hed__Contact__r.Birthdate__c, hed__Account__c,
                        hed__Account__r.MaxBirthdate__c, hed__Account__r.MaxSpecialEdBirthdate__c, hed__Account__r.Possibly_Too_Old_End_Date__c, hed__Account__r.Possibly_Too_Old_End_Date_SPED__c,
                        hed__Account__r.Possibly_Too_Old_Start_Date__c, hed__Account__r.Possibly_Too_Old_Start_Date_SPED__c,
                        hed__Account__r.Too_Old_Cutoff_SPED__c, hed__Account__r.Too_Old_Other_Options_End__c, hed__Account__r.Too_Old_Other_Options_End_SPED__c,
                        hed__Account__r.Too_Old_Other_Options_Start__c, hed__Account__r.Too_Old_Other_Options_Start_SPED__c, hed__Account__r.Too_Young_Cutoff__c,
                        EntranceAgeEligibilityOverride__c, EntranceAgeEligibilitySystem__c, EntranceAgeEligibilityFinal__c, Start_Year__c,
                (SELECT IEPLastUpdated__c, IEPHistory__c FROM Special_Educations__r ORDER BY CreatedDate DESC LIMIT 1)
                FROM hed__Program_Enrollment__c WHERE Id IN: programEnrollmentIds
        ];
        for(hed__Program_Enrollment__c temp : enrollments){
			enrollmentStartYearMap.put(temp.Id, temp.Start_Year__c);
            if(temp.Special_Educations__r != null && temp.Special_Educations__r.size() > 0){
                enrollmentSEMap.put(temp.Id, temp.Special_Educations__r[0]);
            }
        }

		Map<Id, String> enrollmentTransKAckMap = new Map<Id,String> ();
		//Mark Membrino 11/15/2019 Added as part of Gap Analysis Story 118665
		//Iterate over all the ASIs for any of the enrollments we are working on and find the one
		//for this year and save the Transitional Kindergarden Acknowledgement to a map.
		for (Annual_Student_Information__c asi : [SELECT TransitionalKAcknowledgement__c, Program_Enrollment__c, School_Year__c FROM Annual_Student_Information__c WHERE  Program_Enrollment__c IN: programEnrollmentIds]) {
			id thisPEsStartYear = enrollmentStartYearMap.get(asi.Program_Enrollment__c);
			if (asi.School_Year__c == thisPEsStartYear && !enrollmentTransKAckMap.containsKey(asi.Program_Enrollment__c))
				enrollmentTransKAckMap.put(asi.Program_Enrollment__c, asi.TransitionalKAcknowledgement__c);
		}

        //iterate the program enrollment records and populate the EntranceAgeEligibility__c
        for(hed__Program_Enrollment__c programEnrollment : enrollments){
            Date birthdate;
            Program_Grade_Level__c gradeLevel;
            Date maxBirthDate;
            Date maxSpecialBirthdate;
            Date possiblyOldStartDate;
            Date possiblyOldEndDate;
            Date possiblySpecialOldStartDate;
            Date possiblySpecialOldEndDate;
            Date possiblyTooOldStartOther;
            Date possiblyTooOldEndOther;
            Date possiblyTooOldStartOtherSpecial;
            Date possiblyTooOldEndOtherSpecial;
			Date acedemicProgramTooYoungCutoff;
			Boolean acedemicProgramOffersTransK;
            String iepLastUpdated = '';
            String grade = programEnrollment.Program_Grade_Level__r.Grade_Level__r.Name;
			Boolean isThereASpecEdRec = false;

            System.debug(contactDetailMap);
            System.debug(contactDetailMap.containsKey(programEnrollment.hed__Contact__c));
            System.debug(contactDetailMap.get(programEnrollment.hed__Contact__c) != null);
            if(contactDetailMap.containsKey(programEnrollment.hed__Contact__c) && contactDetailMap.get(programEnrollment.hed__Contact__c) != null) {
                System.debug('In contactDetailMap.get(programEnrollment.hed__Contact__c).Birthdate__c::::'+contactDetailMap.get(programEnrollment.hed__Contact__c).Birthdate__c);
                birthdate = contactDetailMap.get(programEnrollment.hed__Contact__c).Birthdate__c;
            }

            if(accGradeLevelMap.containsKey(programEnrollment.hed__Account__c) &&
               accGradeLevelMap.get(programEnrollment.hed__Account__c) != null &&
               accGradeLevelMap.get(programEnrollment.hed__Account__c).containsKey(grade) &&
               accGradeLevelMap.get(programEnrollment.hed__Account__c).get(grade) != null){

                gradeLevel = accGradeLevelMap.get(programEnrollment.hed__Account__c).get(grade);
                system.debug('grade level: ' + gradeLevel);
            }

            if(accountDetailMap.containsKey(programEnrollment.hed__Account__c) &&
               accountDetailMap.get(programEnrollment.hed__Account__c) != null){
                maxBirthDate = accountDetailMap.get(programEnrollment.hed__Account__c).MaxBirthdate__c;
                maxSpecialBirthdate = accountDetailMap.get(programEnrollment.hed__Account__c).MaxSpecialEdBirthdate__c;
                possiblyOldStartDate = accountDetailMap.get(programEnrollment.hed__Account__c).Possibly_Too_Old_Start_Date__c;
                possiblyOldEndDate = accountDetailMap.get(programEnrollment.hed__Account__c).Possibly_Too_Old_End_Date__c;
                possiblySpecialOldStartDate = accountDetailMap.get(programEnrollment.hed__Account__c).Possibly_Too_Old_Start_Date_SPED__c;
                possiblySpecialOldEndDate = accountDetailMap.get(programEnrollment.hed__Account__c).Possibly_Too_Old_End_Date_SPED__c;
                possiblyTooOldStartOther = accountDetailMap.get(programEnrollment.hed__Account__c).Too_Old_Other_Options_Start__c;
                possiblyTooOldEndOther = accountDetailMap.get(programEnrollment.hed__Account__c).Too_Old_Other_Options_End__c;
                possiblyTooOldStartOtherSpecial = accountDetailMap.get(programEnrollment.hed__Account__c).Too_Old_Other_Options_Start_SPED__c;
                possiblyTooOldEndOtherSpecial = accountDetailMap.get(programEnrollment.hed__Account__c).Too_Old_Other_Options_End_SPED__c;
                acedemicProgramTooYoungCutoff = accountDetailMap.get(programEnrollment.hed__Account__c).Too_Young_Cutoff__c;
				acedemicProgramOffersTransK = accountDetailMap.get(programEnrollment.hed__Account__c).OffersTransitionalK__c;
            }
            //End
            if(enrollmentSEMap.containsKey(programEnrollment.Id)){
                iepLastUpdated = enrollmentSEMap.get(programEnrollment.Id).IEPLastUpdated__c;
				isThereASpecEdRec = true;
            }
            System.debug('==iepLastUpdated==='+iepLastUpdated);
            System.debug('==birthdate==='+birthdate);
            if( (!isThereASpecEdRec) ||
				(isThereASpecEdRec && String.isBlank(enrollmentSEMap.get(programEnrollment.Id).IEPHistory__c)) ||
			    (isThereASpecEdRec && enrollmentSEMap.get(programEnrollment.Id).IEPHistory__c == 'Yes' && String.isBlank(iepLastUpdated) ) ){
                System.debug('In PENDING_MORE_INFO');
                programEnrollment.EntranceAgeEligibilitySystem__c = PENDING_MORE_INFO;
            }else if(birthdate == null){
                System.debug('birthdate+++'+birthdate);
                programEnrollment.EntranceAgeEligibilitySystem__c = NOT_ELIGIBLE_NO_BIRTHDAY;
            }else if(currentYearIds.contains(programEnrollment.Start_Year__c)){
                if(gradeLevel != null && (   (gradeLevel.MinBirthdate__c != null && birthdate > gradeLevel.MinBirthdate__c)
										  || (gradeLevel.MinBirthdate__c == null && birthdate > acedemicProgramTooYoungCutoff) ) ){
 
                    programEnrollment.EntranceAgeEligibilitySystem__c = TOO_YOUNG;
                }else if((maxBirthDate != null &&
                        (birthdate < maxBirthDate && (String.isBlank(iepLastUpdated) || (iepLastUpdated == MORE_THAN_THREE_YEARS)))) ||
                        (maxSpecialBirthdate != null &&
                         (birthdate < maxSpecialBirthdate && LESS_THAN_THREE_YEARS_SET.contains(iepLastUpdated)))){

                    programEnrollment.EntranceAgeEligibilitySystem__c = TOO_OLD;
                }else if(gradeLevel != null && gradeLevel.TooYoung_OtherOptions_Start__c != null &&
                         gradeLevel.TooYoung_OtherOptions_End__c != null &&
                         birthdate >= gradeLevel.TooYoung_OtherOptions_Start__c &&
                         birthdate <= gradeLevel.TooYoung_OtherOptions_End__c){
					if (!acedemicProgramOffersTransK)  //School does not offer trans K so put the in the too young bucket.
						programEnrollment.EntranceAgeEligibilitySystem__c = TOO_YOUNG_OTHER;
					else  //School does offer Trans K so find out if the family as agreed to accept it.
					{
						if (String.isBlank(enrollmentTransKAckMap.get(programEnrollment.Id)))
							programEnrollment.EntranceAgeEligibilitySystem__c = PENDING_MORE_INFO;
						else if (enrollmentTransKAckMap.get(programEnrollment.Id) == 'Yes')
							programEnrollment.EntranceAgeEligibilitySystem__c = ELIGIBLE;
						else
							programEnrollment.EntranceAgeEligibilitySystem__c = TOO_YOUNG;
					}
                }else if((possiblyOldStartDate != null && possiblyOldEndDate != null &&
                         birthdate >= possiblyOldStartDate && birthdate <= possiblyOldEndDate &&
                         (String.isBlank(iepLastUpdated) || (iepLastUpdated == MORE_THAN_THREE_YEARS))) ||
                         (possiblySpecialOldStartDate != null && possiblySpecialOldEndDate != null &&
                          birthdate >= possiblySpecialOldStartDate && birthdate <= possiblySpecialOldEndDate &&
                          LESS_THAN_THREE_YEARS_SET.contains(iepLastUpdated))){

                    programEnrollment.EntranceAgeEligibilitySystem__c = POSSIBLY_TOO_OLD;
                }else if((possiblyTooOldStartOther != null && possiblyTooOldEndOther != null &&
                         birthdate >= possiblyTooOldStartOther && birthdate <= possiblyTooOldEndOther &&
                         (String.isBlank(iepLastUpdated) || (iepLastUpdated == MORE_THAN_THREE_YEARS))) ||
                         (possiblyTooOldStartOtherSpecial != null && possiblyTooOldEndOtherSpecial != null &&
                          birthdate >= possiblyTooOldStartOtherSpecial && birthdate <= possiblyTooOldEndOtherSpecial &&
                          LESS_THAN_THREE_YEARS_SET.contains(iepLastUpdated))){

                    programEnrollment.EntranceAgeEligibilitySystem__c = TOO_OLD_OTHER;
                } else {
                    System.debug('In Else ELIGIBLE');
                    programEnrollment.EntranceAgeEligibilitySystem__c = ELIGIBLE;
                }
            }else{
                System.debug('In final ELIGIBLE');
                programEnrollment.EntranceAgeEligibilitySystem__c = ELIGIBLE;
            }

            programEnrollmentsToUpdate.add(programEnrollment);
        }

        return programEnrollmentsToUpdate;
    }
}