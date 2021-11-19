/**
* Created by Ritvik on 25-10-2018.
* Purpose : Handler Class for AccountTrigger.
*/
public without sharing class NES_AccountHandler {
   
    static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('AccountTrigger');
    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.BusinessLogicSwitch('Likelihood to Transition Score');
    //Swapna:Functionality depricated
    /*  public static void handleBeforeUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
if (!logicSwitch) return;
NES_AccountBusinessLogic.populateSchoolID(oldMap, newMap);
}*/
   
    // public static void handleAfterUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) { //Swapna:Changed method signature
    public static void handleAfterUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap,Map<Id, Account> actlstoldMap, Map<Id, Account> actlstnewMap) {
        
        //Find the changed fields and pass to the program enrollments that are using the new ECA process.
        //Create a map between each changed account and a map of the changed fields with their new values.
        Map<Id, Map<String, object>> AcctsToChangedFieldNewValMap = new Map<Id, Map<String, Object>> ();
        List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
        Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.account.fields.getMap();
        Map<Id, Account> FECupdatedAccounts = new Map<Id, Account>(); // used to track FEC field updated Accounts;Added for US #247791

        for (account a : actlstnewMap.values()) {  //Iterate over all accounts
            account oldAcct = actlstoldMap.get(a.Id); 
            for (String str : mapFields.keySet()) {  //Iterate over all fields
                if (a.get(str) != oldAcct.get(str)) {  //Any field that has been updated should go in the map.
                    Map<String, object> thisAccountsChangedFields;
                    if (!AcctsToChangedFieldNewValMap.containsKey(a.id)) {  //instantiate the new inner map if we don't have this account yet.
                        thisAccountsChangedFields = new Map<String, object> ();
                        AcctsToChangedFieldNewValMap.put(a.Id, thisAccountsChangedFields);
                    }
                    else
                        thisAccountsChangedFields = AcctsToChangedFieldNewValMap.get(a.id);

                    thisAccountsChangedFields.put(str, a.get(str) );  //add the column and the new Value for later use.
                    
                    if(str == 'family_enrollment_counselor__c'){  // Checking if updated field is 'Family_Enrollment_Counselor__c'; Added for US #247791
                        FECupdatedAccounts.put(a.Id,a);             // adding account to the tracking map variable 'FECupdatedAccounts' ; Added for US #247791
                    }
                }
            }
        }

        System.debug ('AcctsToChangedFieldNewValMap:' + AcctsToChangedFieldNewValMap);
        System.debug ('AcctsToChangedFieldNewValMap.keySet():' + AcctsToChangedFieldNewValMap.keySet());

        System.debug ('FECupdatedAccounts:' + FECupdatedAccounts); // Added for US #247791
        
        //Find the Program Enrollments that are tied to any of the changed accounts that are using the new ECA process.
        if (AcctsToChangedFieldNewValMap.size() > 0) {
            list <hed__Program_Enrollment__c> PEsToCheck = new list <hed__Program_Enrollment__c>
                    ([ Select id, hed__Contact__r.AccountId from hed__Program_Enrollment__c  where hed__Contact__r.AccountId IN :AcctsToChangedFieldNewValMap.keySet() and hed__Account__r.Use_Updated_ECA_Process__c = true and status__c = 'In Progress']);
            for (hed__Program_Enrollment__c pe : PEsToCheck)  {
                //Get the changed fields for this account.
                Map<String, object> thisAccountsChangedFields = AcctsToChangedFieldNewValMap.get(pe.hed__Contact__r.AccountId);

                //Iterate over the changed fields for the account that is tied to this PE
                for (String fieldName : thisAccountsChangedFields.keySet()){
                    EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate ();
                    newFieldUpdate.programEnrollmentId = pe.Id;
                    newFieldUpdate.objectAndFieldName = 'account.' + fieldName;
                    newFieldUpdate.newValue = thisAccountsChangedFields.get(fieldName);
                    fieldUpdateList.add(newFieldUpdate);
                }
            }
            
            System.debug ('fieldUpdateList:' + fieldUpdateList);

            if (fieldUpdateList.size() > 0)  //Must be at least one PE in the NEW ECA model that has a changed field so call the new ECA stuff.
                EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        }


        
        // NES_AccountBusinessLogic.calculateHomelessRiskFlag(newMap, oldMap);
        NES_AccountBusinessLogic.calculateHomelessRiskFlag(actlstnewMap, actlstoldMap);//Swapna:Changed to active list
       
        if (likelihoodToTransitionScore) {
            //    NES_AccountBusinessLogic.calculateLTS(newMap.values(), oldMap);
            NES_AccountBusinessLogic.calculateLTS(actlstnewMap.values(), actlstoldMap);//Swapna:Changed to active list
           
        }
        /*NES_AccountBusinessLogic.recalcAddrEligIfRequired(newMap.values(), oldMap);
NES_AccountBusinessLogic.recalcTechnologyFlag(newMap.values(), oldMap); */
        //Swapna:Changed to active list
        NES_AccountBusinessLogic.recalcAddrEligIfRequired(actlstnewMap.values(), actlstoldMap);
        
        //Commented Deprecate Technology flag logic for US 476956
        //NES_AccountBusinessLogic.recalcTechnologyFlag(actlstnewMap.values(), actlstoldMap);
       
        //Added/changed by Chinna on 8 , 9th and 10 april 2020
        //Map<Id, Account> accountsMap = new Map<Id, Account>();
        //for(Account acc : newMap.values()){
        //    Account oldAcc = oldMap.get(acc.Id);
        //    if(acc.Alt_Shipping_City__c <> oldAcc.Alt_Shipping_City__c ||
        //       acc.Alt_Shipping_State__c <> oldAcc.Alt_Shipping_State__c ||
        //       acc.Alt_Shipping_Street_1__c <> oldAcc.Alt_Shipping_Street_1__c){
        //           accountsMap.put(acc.Id, acc);
        //       }
        //}
        //if(!accountsMap.isEmpty()){
        //    updatePEOrderingFlag(accountsMap);
        //}

    }
    //Swapna:Functionality depricated
    /*  public static void handleBeforeInsert(List<Account> newMap) {
if (!logicSwitch) return;
NES_AccountBusinessLogic.createUniqueID(newMap);
}*/
   
    // public static void handleAfterInsert(List<Account> newList, Map<Id, Account> oldMap) {
    //Swapna:Changed method signature
    public static void handleAfterInsert(List<Account> newList, Map<Id, Account> oldMap,List<Account> actList) {
        if (likelihoodToTransitionScore) {
            // NES_AccountBusinessLogic.calculateLTS(newList, null);
            NES_AccountBusinessLogic.calculateLTS(actList, null); //Swapna:CHanged to active list
        }
    }
   
    //Added by chinna on 8 april 2020
    //public static void updatePEOrderingFlag(Map<Id, Account> accountsMap){
    //    List<hed__Program_Enrollment__c> PEList = [Select Id, OrderingHoldDate__c, OrderingHoldFlag__c from hed__Program_Enrollment__c where hed__Account__c IN: accountsMap.keyset() AND RecordType.Name = 'Caretaker'AND Status__c = 'Complete' AND Old_Status__c = 'In Progress' limit 5];
    //    for(hed__Program_Enrollment__c PE : PEList){
    //        PE.OrderingHoldDate__c = System.Date.Today();
    //        PE.OrderingHoldFlag__c = 'Alternate Shipping';
    //    }
    //    update PEList;
    //}
}