/**
 * Created by Anushka Bansal on 19-12-2018.
 */

public with sharing class NES_LTSUtility {

     /**
    * Created by Anushka on 19/12/18.
    * Purpose : Method to calculate the value of Likelihood to Transition Score on Program Enrollment.
    * Params : List of Related student program enrollments of the record that fired the Trigger.
    */
    public static Boolean runLTSFlag = True;
    public static List<Hed__Program_Enrollment__c> calculateLTS(Set<Id> programEnrollmentList){
        Set<Id> progEnrollmentIds = new Set<Id>();
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();
        Map<Id, Placement_and_Elective__c> placementAndElectiveMap = new Map<Id, Placement_and_Elective__c>();
        Map<Id, Special_Education__c> specialEducationMap = new Map<Id, Special_Education__c>();
        Map<Id, Annual_Household_Information__c> annualHouseholdInfoMap = new Map<Id, Annual_Household_Information__c>();
        Set<Id> contactIds = new Set<Id>();
        List<Hed__Program_Enrollment__c> programEnrollmentsToUpdate = new List<Hed__Program_Enrollment__c>();
        if(runLTSFlag){
            progEnrollmentIds = NES_BusinessLogicUtils.getPEsWithRequisiteEcasComplete(programEnrollmentList, true, true, false);
            System.debug('prog enrollment Ids: '+progEnrollmentIds);

            for(hed__Program_Enrollment__c pe : [
                    Select hed__Contact__c
                    from hed__Program_Enrollment__c
                    where Id in :progEnrollmentIds]){
           // for(hed__Program_Enrollment__c pe : 
            //    GenericSOQLQueries.programEnrollmentDetails(progEnrollmentIds)){
                
                contactIds.add(pe.hed__Contact__c);
            }

            Map<Id,hed__Program_Enrollment__c> progEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>([Select id, LTS__c,LastSchoolType__c,LTSLastCalculation__c,
                    Start_Year__c , Household_Program_Enrollment__c, Stress_Factors__c, hed__Contact__c, DisciplinaryPastActions__c, Start_Year__r.Name, Start_Year__r.Current_Year__c
            from hed__Program_Enrollment__c where Id in:progEnrollmentIds ]);
            //Map<Id,hed__Program_Enrollment__c> progEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>(GenericSOQLQueries.programEnrollmentDetails(progEnrollmentIds));
            Map<Id, School_Year__c> parentPEtoSYMap = new Map<Id, School_Year__c>();
            for (hed__Program_Enrollment__c pe : progEnrollmentMap.values()) {
                parentPEtoSYMap.put(pe.Household_Program_Enrollment__c, pe.Start_Year__r);
            }
            System.debug('parentPEtoSYMap: '+parentPEtoSYMap);


            // for(Hed__Program_Enrollment__c progEnrollment : progEnrollmentIds)
            //   contactIds.add(progEnrollment.hed__Contact__c);


           // Added by CS Team Members - Rakesh & Sumanth to test the 101 SOQL Governer Limits work-around.
       
       /*   Map<Id, Contact> contactMap = new Map<Id, Contact>([Select id, Why_Is_Your_Child_Attending_CA__c, accountId, account.LC_HighestLevelofEducation__c,
                    account.Mktg_Customer_Loyalty__c, account.Internet_Connection_Type__c, account.Computer_in_Home__c
            from Contact where Id in: contactIds]); */
            
            List<Contact> contactList = GenericSOQLQueries.contactDetails(contactIds); 
            Map<Id, Contact> contactMap = new Map<Id,Contact>(contactList);
         // Ended by CS Team Members - Rakesh & Sumanth to test the 101 SOQL Governer Limits work-around.


            for(Opportunity opp : [Select id, Program_Enrollment__c, StageName, SFDC_Informed__c, SFDC_Engaged_Grassroots_User__c
            from Opportunity where Program_Enrollment__r.Household_Program_Enrollment__c in: progEnrollmentIds]){
                opportunityMap.put(opp.Program_Enrollment__c , opp);
            }

            for(Placement_and_Elective__c pne : [Select id,Level_Requested__c, Course_Requested__c,Program_Enrollment__c from Placement_and_Elective__c where
                    Program_Enrollment__c in: progEnrollmentIds]){
                placementAndElectiveMap.put(pne.Program_Enrollment__c, pne);

            }

            for(Special_Education__c se : [Select id,Program_Enrollment__c, Gifted__c from Special_Education__c
            where Program_Enrollment__c in: progEnrollmentIds ]){
                specialEducationMap.put(se.Program_Enrollment__c, se);
            }

            // AHI is based on household PE, but this operation executes on child PEs
            for(Annual_Household_Information__c ahi : [Select id,Program_Enrollment__c, Total_Gross_HH_Income__c, School_Year__c from Annual_Household_Information__c
            where Program_Enrollment__c in (select Household_Program_Enrollment__c from hed__Program_Enrollment__c where Id in :progEnrollmentIds) ]){
                //system.debug('pe - start year ' + progEnrollmentMap.get(ahi.Program_Enrollment__c).Start_Year__c);
                if(ahi.School_Year__c == parentPEtoSYMap.get(ahi.Program_Enrollment__c).Id)
                    annualHouseholdInfoMap.put(ahi.Program_Enrollment__c, ahi);

            }
            System.debug('AHIMap: '+annualHouseholdInfoMap);


            for(hed__Program_Enrollment__c pe : progEnrollmentMap.values()){
                pe.LTS__c = 0;
                Integer lts = 0;
                if((opportunityMap.get(pe.Id) != null && opportunityMap.get(pe.Id).stageName != 'Closed') ||
                        (pe.LTSLastCalculation__c == null && pe.LTS__c != null && annualHouseholdInfoMap.get(pe.Household_Program_Enrollment__c) != null &&
                                annualHouseholdInfoMap.get(pe.Household_Program_Enrollment__c).Total_Gross_HH_Income__c != null
                                && annualHouseholdInfoMap.get(pe.Household_Program_Enrollment__c).Total_Gross_HH_Income__c != 0)
                        ){
                    lts = 10;
                    //  system.debug('pe lts 3' + pe.LTS__c);
                }

                if(contactMap.get(pe.hed__Contact__c) != null){
                    Contact con = contactMap.get(pe.hed__Contact__c);
                    //system.debug('con ' +  con);


                    if(isMatch(con.Why_Is_Your_Child_Attending_CA__c, 'Student was ahead academically', false)){
                        //   system.debug('ahead ' + isMatch(con.Why_Is_Your_Child_Attending_CA__c, 'Student was ahead academically', false));
                        lts = lts + 2;
                    }

                    if(isMatch(con.Why_Is_Your_Child_Attending_CA__c, 'Student was suspended or expelled', false) ||
                            isMatch(con.Why_Is_Your_Child_Attending_CA__c, 'Student was struggling academically', false)){
                        lts = lts -3 ;
                    }


                    if(isMatch(con.Account.LC_HighestLevelofEducation__c, 'College graduate (Bachelor\'s degree)', false) ||
                            isMatch(con.Account.LC_HighestLevelofEducation__c, 'Graduate school / Post-graduate training', false))
                        lts = lts + 2;
                    else if(isMatch(con.Account.LC_HighestLevelofEducation__c, 'Not a high school graduate', false))
                        lts = lts - 3;
                    else if(isMatch(con.Account.LC_HighestLevelofEducation__c, 'High school graduate', false))
                        lts = lts - 1 ;

                    if(con.account.Mktg_Customer_Loyalty__c == 'Customer Loyalty')
                        lts = lts + 2;
                    if(con.Account.Computer_in_Home__c == 'No')
                        lts = lts - 2;
                    if(isMatch(con.Account.Internet_Connection_Type__c, 'Dial-up', false))
                        lts = lts - 1;
                    else if(isMatch(con.Account.Internet_Connection_Type__c, 'None', false))
                        lts = lts - 2;
                    system.debug('lts -- ' + lts);
                }

                if(opportunityMap.get(pe.Id) != null){
                    if(opportunityMap.get(pe.Id).SFDC_Informed__c == 'Uninformed')
                        lts = lts -1;
                    if(opportunityMap.get(pe.Id).SFDC_Engaged_Grassroots_User__c == 'True')
                        lts = lts +1;

                }

                if(placementAndElectiveMap.get(pe.Id) != null){
                    Placement_and_Elective__c placementAndElective = placementAndElectiveMap.get(pe.Id);
                    if(isMatch(placementAndElective.Level_Requested__c, 'Advanced', false)
                            || isMatch(placementAndElective.Level_Requested__c, 'Honors', true)){
                        if(placementAndElective.Course_Requested__c == 'Algebra 1' || placementAndElective.Course_Requested__c == 'Algebra 2' ||placementAndElective.Course_Requested__c == 'Calculus'
                                || placementAndElective.Course_Requested__c == 'Geometry' || placementAndElective.Course_Requested__c == 'Math I' || placementAndElective.Course_Requested__c == 'Math II'
                                || placementAndElective.Course_Requested__c == 'Math III' || placementAndElective.Course_Requested__c == 'Pre-Algebra' || placementAndElective.Course_Requested__c == 'Precalculus'
                                || placementAndElective.Course_Requested__c == 'Secondary Math 1' || placementAndElective.Course_Requested__c == 'Secondary Math 2' ||  placementAndElective.Course_Requested__c == 'Secondary Math 3'
                                || placementAndElective.Course_Requested__c == 'Statistics' || placementAndElective.Course_Requested__c == 'Biology' ||placementAndElective.Course_Requested__c == 'Chemistry'
                                || placementAndElective.Course_Requested__c == 'Physics' || placementAndElective.Course_Requested__c == 'Physical Science' ||placementAndElective.Course_Requested__c == 'Earth Science'
                                || placementAndElective.Course_Requested__c == 'American Government' || placementAndElective.Course_Requested__c == 'Economics' ||placementAndElective.Course_Requested__c == 'Geography'
                                || placementAndElective.Course_Requested__c == 'World History' || placementAndElective.Course_Requested__c == 'U.S. History' || placementAndElective.Course_Requested__c == 'English')
                            lts = lts + 1;
                    }
                }

                if(specialEducationMap.get(pe.Id) != null){
                    if(isMatch(specialEducationMap.get(pe.Id).Gifted__c, 'Gifted', false))
                        lts = lts + 2;
                }

                if(annualHouseholdInfoMap.get(pe.Household_Program_Enrollment__c) != null && pe.Start_Year__r.Current_Year__c == true)
                {
                    System.debug('Doing HH check');
                    Annual_Household_Information__c annualHouseholdInformation = annualHouseholdInfoMap.get(pe.Household_Program_Enrollment__c);
                    if(annualHouseholdInformation.Total_Gross_HH_Income__c >= 60000) {
                        System.debug('HH >= 60k');
                        lts = lts + 1;
                    } else if(annualHouseholdInformation.Total_Gross_HH_Income__c != null && annualHouseholdInformation.Total_Gross_HH_Income__c < 30000) {
                        System.debug('HH < 30k');
                        lts = lts - 2;
                    }
                }

                if(pe.Stress_Factors__c == 'Yes' || pe.Stress_Factors__c == 'Decline to Disclose')
                    lts =lts-2;
                if(isMatch(pe.DisciplinaryPastActions__c, 'Yes', false))
                    lts =lts-3;
                if(pe.LastSchoolType__c == 'Online (Virtual) Public School')
                    lts = lts + 1;
                else if(pe.LastSchoolType__c == 'Private/Parochial School')
                    lts = lts + 2;



                system.debug('lts ' + lts);
                pe.LTS__c =  lts;
				pe.LTSLastCalculation__c = System.today();  //MM Added during gap analysis 11/7/2019 
                programEnrollmentsToUpdate.add(pe);
            }
        }

                return programEnrollmentsToUpdate;
   
}

    /**
* Created by Anushka on 18/12/18.
* Purpose : Method to check if field contains or equals to a certain string.
* Params : @actualText - takes string field value.
*          @expectedText - takes string which we want to check against.
*          @isExactMatch - True for equals condition & False for contains condition.
*/
    private static boolean isMatch(String actualText, String expectedText, boolean isExactMatch) {
        if (String.isNotBlank(actualText)) {
            if ((isExactMatch && actualText.equals(expectedText)) ||
                    ((!isExactMatch) && actualText.contains(expectedText))) {
                return true;
            }
        }
        return false;

    }
}