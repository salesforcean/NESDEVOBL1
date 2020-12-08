/**
    * Created by Anushka on 14-12-2018.
    * Purpocomment : BusinessLogic class for HouseholdIncomeTrigger called by HouseholdIncomeHandler.
    * Added field to the query for US117580 (Jagadeesh) on 11/13/2019
**/


public class NES_HouseholdIncomeBusinessLogic {
    
    /**
    * Created by Anushka on 14-12-2018.
    * Purpose : This method filters the records which need .HHFosterChild calculation on insert/update.
    */
    public static void calculateHHIncomeFosterChild(List<Household_Income__c> newList, Map<Id, Household_Income__c> oldMap){
        system.debug('in calculateHHIncomeFosterChild');

        List<Household_Income__c> householdIncomeList= new List<Household_Income__c>();

        for(Household_Income__c income : newList){
            if(oldMap != null){
                if(income.HHFosterChild__c != oldMap.get(income.Id).HHFosterChild__c )
                    householdIncomeList.add(income);
            }else{
                if(income.HHFosterChild__c != null)
                    householdIncomeList.add(income);
            }
        }
        if(householdIncomeList.size() > 0)
          NES_BusinessLogicUtils.calculateHHIncomeFosterChild(householdIncomeList);
    }


    /**
     * Created By Raju on 17-12-2018.
     * purpose is to call the calculateFederalPovertyEligibility method in the NES_BusinessLogicUtils class after Update/Insert.
     */
    public static void federalPovertyEligibility(List<Household_Income__c> newList, Map<Id, Household_Income__c> oldMap){
        Set<Id> peIdSet = new Set<Id>();

        for(Household_Income__c income : newList){
            if(oldMap != null){
               if(oldMap.get(income.Id).HHFosterChild__c != income.HHFosterChild__c){
                 peIdSet.add(income.Program_Enrollment__c);
               }
            }else{
                if(income.HHFosterChild__c != null && income.Program_Enrollment__c != null){
                   peIdSet.add(income.Program_Enrollment__c);
                }
            }
        }

        if(peIdSet.size() > 0){
            List<Annual_Household_Information__c> ahiList =new List<Annual_Household_Information__c> ([SELECT Id,Total_Gross_HH_Income__c,
                    Number_HH_Children__c,
                    Number_HH_Adults__c,
                    HH_Has_Food_Stamp_Recipient__c,
                    Program_Enrollment__c,
                    HH_Has_Foster_Children__c, Income_Opt_Out_Options__c,
                    Program_Enrollment__r.Start_Year__r.id,
                    School_Year__c,
                    Program_Enrollment__r.hed__Account__r.Fed_Elig_Inc_Free_Meals_HH_Size_of_1__c,// added by jagadeesh - user story : 117580
                    Program_Enrollment__r.hed__Account__r.Fed_Poverty_Elig_Inc_Addl_Per_Person__c,// added by jagadeesh - user story : 117580
                    Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_HH_Size_of_1__c,// added by jagadeesh - user story : 117580
                    Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Free_Meals_Addl_Per_Person__c,// added by jagadeesh - user story : 117580
                    Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_HH_Size_of_1__c,// added by jagadeesh - user story : 117580
                    Program_Enrollment__r.hed__Account__r.FARM_Elig_Inc_Red_Meals_Addl_Per_Person__c// added by jagadeesh - user story : 117580
                                                                                                       
            FROM Annual_Household_Information__c
            WHERE Program_Enrollment__c IN: peIdSet]);
            NES_BusinessLogicUtils.calculateFederalPovertyEligibility(peIdSet,ahiList);
        }
    }

    /**
    * Created By Ajith on 19-12-2018.
    * purpose : This method is to filter the records that needs the TotalGrossHHIncome calculation
    * Params : newList, oldMap of HouseholdIncome records
    */
    public static void filterAndCalculateTotalGrossHHIncome(List<Household_Income__c> newList, Map<Id, Household_Income__c> oldMap){ 
        List<Household_Income__c> householdIncomesList = new List<Household_Income__c>();

        for(Household_Income__c income : newList){
            if(oldMap != null){
                if(oldMap.get(income.Id) != null && (oldMap.get(income.Id).HHAdultIncome_1__c != income.HHAdultIncome_1__c ||
                        oldMap.get(income.Id).HHAdultIncomeRecSup__c != income.HHAdultIncomeRecSup__c || oldMap.get(income.Id).HHAdultIncome_2__c != income.HHAdultIncome_2__c ||
                        oldMap.get(income.Id).HHAdultIncome_3__c != income.HHAdultIncome_3__c || oldMap.get(income.Id).Adult_Income_Other__c != income.Adult_Income_Other__c ||
                        oldMap.get(income.Id).HHAdultIncomeWork__c != income.HHAdultIncomeWork__c || oldMap.get(income.Id).HHChildIncome__c != income.HHChildIncome__c ||
                        oldMap.get(income.Id).Adult_Income_Sup__c != income.Adult_Income_Sup__c || oldMap.get(income.Id).Adult_Income_Received_1__c != income.Adult_Income_Received_1__c ||
                        oldMap.get(income.Id).Adult_Income_Received_2__c != income.Adult_Income_Received_2__c || oldMap.get(income.Id).Adult_Income_Received_3__c != income.Adult_Income_Received_3__c ||
                        oldMap.get(income.Id).Adult_Income_Rec_Other__c != income.Adult_Income_Rec_Other__c || oldMap.get(income.Id).HHAdultIncomeRecWork__c!= income.HHAdultIncomeRecWork__c ||
                        oldMap.get(income.Id).HHChildIncomeReceived__c != income.HHChildIncomeReceived__c)){

                    householdIncomesList.add(income);
                }
            //Changed below else if condition to accomodate all conditions and not just HHAdultIncome_1__c for Bug #202908 on 2020-06-24 (Krishna Peddanagammol) 
            }else if(income.HHAdultIncome_1__c != null || income.HHAdultIncomeRecSup__c != null || income.HHAdultIncome_2__c != null || income.HHAdultIncome_3__c != null || income.Adult_Income_Other__c  != null || 
                    income.HHAdultIncomeWork__c  != null || income.HHChildIncome__c  != null || income.Adult_Income_Sup__c  != null || income.Adult_Income_Received_1__c != null || income.Adult_Income_Received_2__c  != null || 
                    income.Adult_Income_Received_3__c != null || income.Adult_Income_Rec_Other__c != null || income.HHAdultIncomeRecWork__c != null ||  income.HHChildIncomeReceived__c != null) {
                        householdIncomesList.add(income);
            }
        }
        //Call the calculateTotalGrossHHIncome method
        if(householdIncomesList.size() > 0){
            NES_BusinessLogicUtils.calculateTotalGrossHHIncome(householdIncomesList);
        }
    }
}