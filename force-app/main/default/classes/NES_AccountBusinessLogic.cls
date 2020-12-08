/**
 * Created by Ritvik on 25-10-2018.
 * Purpose : BusinessLogic class for AccountTrigger called by AccountHandler class.
 */


//Generating 20 characters unique Calculated Id on creating or updating a account & populating it into School Id if this field is blank.
public without sharing class NES_AccountBusinessLogic {
    private static Peak_ApexLog logger = new Peak_ApexLog('AccountBusinessLogic');

/**
 * Created by Ritvik on 25-10-2018.
 * Purpose : Generating 20 characters unique Calculated Id on creating or updating a account & populating it into School Id if this field is blank.
 * Parameter : List<Account> record to be inserted.
 */
    //Method depricated
   /* public static void createUniqueID(List<Account> newMap) {
        try {
            for (Account record : newMap) {
                //Logic to generate random Id
                Integer len = 20;
                String chars = '0123456789';
                String randomString = '';
                while (randomString.length() < len) {
                    Integer count = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
                    randomString += chars.substring(count, count + 1);
                }


                record.Calculated_ID__c = randomString;
                if (String.isBlank(record.School_Id__c)) {
                    record.School_Id__c = record.Calculated_ID__c;
                }
            }
        } catch (Exception e) {
            logger.logException('createUniqueId', e);
            logger.saveLogs();
            throw e ;
        }
    } */

    /**
 * Created by Ritvik on 25-10-2018.
 * Purpose : Generating 20 characters unique Calculated Id on creating or updating a account & populating it into School Id if this field is blank.
 * Parameter : @Map<Id, Account> -  Account record to updated with updated values.
 *             @Map<Id, Account> -  Account record to updated with values before updation i.e. old.
 */
  //Method depricated
  /*
    public static void populateSchoolID(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        try {

            for (Account record : newMap.values()) {
                if (String.isBlank(record.School_Id__c)) {
                    record.School_Id__c = record.Calculated_ID__c;
                }
            }
        } catch (Exception e) {
            logger.logException('populateSchoolID', e);
            logger.saveLogs();
            throw e ;
        }
    }
*/
    /**
    * Created by Raju on 12/13/18.
    * Purpose : Method is used to Set set Program_Enrollment__c.HomelessRiskFlag__c to “Potential Homeless”
    */
    public static void calculateHomelessRiskFlag(Map<Id, Account> newMap, Map<Id, Account> oldMap) {
        Id householdRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Household').getRecordTypeId();
        Set<Id> accountIdSet = new Set<Id>();
        for (Account account : (List<Account>) newMap.values() ) {
            if (account.RecordTypeId == householdRecordTypeId && String.isNotBlank(account.Type_of_Living_Accommodations__c)) {
                if (account.Type_of_Living_Accommodations__c.contains('With more than one family in a house or an apartment due to loss') ||
                                account.Type_of_Living_Accommodations__c.contains('In a shelter') ||
                                account.Type_of_Living_Accommodations__c.contains('In a temporary trailer') ||
                                account.Type_of_Living_Accommodations__c.contains('Awaiting') ||
                                account.Type_of_Living_Accommodations__c.contains('In a hotel or motel') ||
                                account.Type_of_Living_Accommodations__c.contains('A Primary Nighttime Residence')) {
                    accountIdSet.add(account.id);
                }
            }
        }

        if (accountIdSet.size() > 0) {
            NES_BusinessLogicUtils.calculateHomelessRiskFlag(accountIdSet);
        }
    }

    /**
     * Created By Anushka on 12/18/2018
     * purpose is to call the calculateLTS method in the NES_BusinessLogicUtils class after Update/Insert.
     */
    public static void calculateLTS(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Account account : newList) {
            if (oldMap != null && !oldMap.isEmpty()) {
                if (account.LC_HighestLevelofEducation__c != oldMap.get(account.Id).LC_HighestLevelofEducation__c
                        || account.Mktg_Customer_Loyalty__c != oldMap.get(account.Id).Mktg_Customer_Loyalty__c
                        || account.Computer_in_Home__c != oldMap.get(account.Id).Computer_in_Home__c
                        || account.Internet_Connection_Type__c != oldMap.get(account.Id).Internet_Connection_Type__c)
                    accountIds.add(account.Id);
            } else {
                if (!String.isBlank(account.LC_HighestLevelofEducation__c) || !String.isBlank(account.Mktg_Customer_Loyalty__c)
                        || account.Computer_in_Home__c != null || !String.isBlank(account.Internet_Connection_Type__c))

                    accountIds.add(account.Id);
            }
        }
        if (accountIds.size() > 0) {
            Map<Id, hed__Program_Enrollment__c> programEnrollmentMap = new Map<Id, hed__Program_Enrollment__c>([
                    Select id from hed__Program_Enrollment__c
                    where hed__Contact__r.AccountId IN :accountIds and status__c = 'In Progress'
            ]);
            List<hed__Program_Enrollment__c> programEnrollments = NES_LTSUtility.calculateLTS(programEnrollmentMap.keySet());
            try {
                update programEnrollments;
            } catch (Exception ex) {logger.logException('calculateLTS', ex);logger.saveLogs();}
        }
    }
    /**
     * Created By Mark Membrino on 10/24/2019  Story 113910
     * If an account postal or state is updated, we need to recalc the address eligibility.
     * // Added  shippingstreet code for the User Story #154114 on 06/04/2020
     * If an account postal or state or shippingstreet is updated, we need to recalc the address eligibility.
     */
    public static void recalcAddrEligIfRequired(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Account account : newList) {
            if (oldMap != null && !oldMap.isEmpty()) {
                if (account.shippingstate != oldMap.get(account.Id).shippingstate
                        || account.ShippingPostalCode != oldMap.get(account.Id).ShippingPostalCode || account.shippingstreet != oldMap.get(account.Id).shippingstreet)
                    accountIds.add(account.Id);
            }
        }

        if (accountIds.size() > 0) {
           list <hed__Program_Enrollment__c> PEsToCheck = new list <hed__Program_Enrollment__c>
             ([ Select id, hed__Account__c, hed__Contact__c
                from hed__Program_Enrollment__c
                where hed__Contact__r.AccountId IN :accountIds and status__c = 'In Progress']);

            if (PEsToCheck.size() > 0) {
                list <hed__Program_Enrollment__c> PEsToUpdate = NES_BusinessLogicUtils.calculateAddressEligibility(PEsToCheck);
                update PEsToUpdate;
            }
        }
    }


    /**
     * Created By Mark Membrino on 10/30/2019  Story 114150
     * If computer in home is updated, we need to recalc the technology flag for all related PEs.
     */
    public static void recalcTechnologyFlag(List<Account> newList, Map<Id, Account> oldMap) {
        Set<Id> accountIds = new Set<Id>();
        for (Account account : newList) {
            if (oldMap != null && !oldMap.isEmpty()) {
               if ( ( String.isBlank(oldMap.get(account.Id).Computer_in_Home__c) || oldMap.get(account.Id).Computer_in_Home__c =='Yes') && account.Computer_in_Home__c == 'No')
                     accountIds.add(account.Id);
            }
        }

        System.debug('recalcTechnologyFlag accountIds' + accountIds);
        if (accountIds.size() > 0) {
           /*list <hed__Program_Enrollment__c> PEsToCheck = new list <hed__Program_Enrollment__c>
             ([ Select id, hed__Account__c, hed__Contact__c
                from hed__Program_Enrollment__c
                where hed__Contact__r.AccountId IN :accountIds and status__c = 'In Progress']);*/
           //added for bug 121557
            list <hed__Program_Enrollment__c> PEsToCheck =[ Select id, hed__Account__c, hed__Contact__c
                from hed__Program_Enrollment__c
                where hed__Contact__r.AccountId IN :accountIds ]; //and status__c = 'In Progress'
          //added for bug 121557

                System.debug('recalcTechnologyFlag PEsToCheck' + PEsToCheck);

            if (PEsToCheck.size() > 0) {
                list <hed__Program_Enrollment__c> PEsToUpdate = NES_BusinessLogicUtils.flagTechnologyAction(PEsToCheck);
                update PEsToUpdate;
            }
        }
    }
}