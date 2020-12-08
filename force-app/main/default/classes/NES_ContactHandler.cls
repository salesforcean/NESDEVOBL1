public class NES_ContactHandler {
    private static Peak_ApexLog logger = new Peak_ApexLog('ContactHandler');
    
    static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('ContactTrigger');
    static final Boolean likelihoodToTransitionScore = NES_TriggerUtility.BusinessLogicSwitch('Likelihood to Transition Score');
    
    
    //  public static void handleAfterUpdate(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
    public static void handleAfterUpdate(Map<Id, Contact> oldMap, Map<Id, Contact> newMap, Map<Id, Contact> actlstoldMap, Map<Id, Contact> actlstnewMap) { //Swapna:Changed method signature
        if (logicSwitch) {
            //   NES_ContactBusinessLogic.calculatePlacement(oldMap, newMap);
            NES_ContactBusinessLogic.calculatePlacement(actlstoldMap, actlstnewMap); //Swapna:Changed to active list
        }
        
        //Start: Task #60094 Ashish Sharma December 14, 2018
        if (NES_EntranceAgeUtility.entranceAgeEligibilitySwitch) {
            System.debug('In Entrance Age Eligibility Calculation Contact Update++++');
            List<sObject> validRecords = new List<SObject> ();
            
            //    for (Contact contact : newMap.values()) {
            for (Contact contact : actlstnewMap.values()) { //Swapna:Changed to active list
                System.debug('contact.Birthdate++' + contact.Birthdate__c);
                System.debug('oldMap.get(contact.Id).Birthdate' + oldMap.get(contact.Id).Birthdate__c);
                //    if (contact.Birthdate__c != oldMap.get(contact.Id).Birthdate__c) {
                if (contact.Birthdate__c != actlstoldMap.get(contact.Id).Birthdate__c) { //Swapna:Changed to active list
                    System.debug('contact.Birthdate != oldMap.get(contact.Id).Birthdate');
                    validRecords.add(contact);
                }
            }
            
            if (validRecords.size() > 0) {
                Boolean origAssignment = NES_Constants.runAssignment;
                NES_Constants.runAssignment = false;
                NES_BusinessLogicUtils.calculateEntranceAgeEligibility(validRecords);
                NES_Constants.runAssignment = origAssignment;
            }
        }
        List<Contact> runCriteriaContacts = new List<Contact> ();
        Id studentContactId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        //   for (Contact newContact : newMap.values()) {
        for (Contact newContact : actlstnewMap.values()) { //Swapna:Changed to active list
           // if (newContact.RecordTypeId == studentContactId) {  //MM 11/6/2020 Removed the need for a contact to be a student.
                runCriteriaContacts.add(newContact);
           // }
            }

        if (runCriteriaContacts.size() > 0){ 
            Contact contactObject = new Contact(); // This takes all available fields from the required object.
            Schema.SObjectType objType = contactObject.getSObjectType();
            Map<String, Schema.SObjectField> mapFields = Schema.SObjectType.Contact.fields.getMap();
            Map<Id, List<String>> changedFieldsMap = new Map<Id, List<String>> ();
            List<EvaluationUtils.fieldUpdate> fieldUpdateList = new List<EvaluationUtils.fieldUpdate> (); //How we track field changes in the new ECA model.
            
            //For the ECA rewrite we need to find which PEs are using the new model and which are using the old and direct those contacts
            //to the old ECA process or the new process.
            Map<Id, List<hed__Program_Enrollment__c>> contactIdToPEListMapNewECAProcess = new Map<Id, List<hed__Program_Enrollment__c>> ();
            Set<Id> contactsWithAtLeastOneOldECA = new Set<id> ();

            for (hed__Program_Enrollment__c pe : [SELECT Id, hed__Account__r.Use_Updated_ECA_Process__c, hed__Contact__c FROM hed__Program_Enrollment__c WHERE hed__Contact__c IN :runCriteriaContacts]) {
                if (pe.hed__Account__r.Use_Updated_ECA_Process__c == false)
                    contactsWithAtLeastOneOldECA.add(pe.hed__Contact__c);
                else {  //Must be an ECA in the new model.
                    List<hed__Program_Enrollment__c> thisContactsPEs;
                    if (contactIdToPEListMapNewECAProcess.containsKey(pe.hed__Contact__c) )
                        thisContactsPEs = contactIdToPEListMapNewECAProcess.get(pe.hed__Contact__c);
                    else
                        thisContactsPEs = new List<hed__Program_Enrollment__c> ();

                    thisContactsPEs.add(pe);
                    contactIdToPEListMapNewECAProcess.put(pe.hed__Contact__c, thisContactsPEs);
                }
            }
                
            for (Contact newContact : runCriteriaContacts) {
                // Contact oldContact = oldMap.get(newContact.Id);
                Contact oldContact = actlstoldMap.get(newContact.Id); //Swapna:Changed to active list
                List<String> changedFields = new List<String> ();
                List<hed__Program_Enrollment__c> thisContactsNewModelPEs = contactIdToPEListMapNewECAProcess.get(newContact.Id);
                for (String str : mapFields.keySet()) {
                    try {
                        if (newContact.get(str) != oldContact.get(str)) {
                            changedFields.add(str);

                            if(thisContactsNewModelPEs != null){
                                for (hed__Program_Enrollment__c PE : thisContactsNewModelPEs) {
                                    //These are for the new ECA processing model.  
                                    EvaluationUtils.fieldUpdate newFieldUpdate = new EvaluationUtils.fieldUpdate();
                                    newFieldUpdate.programEnrollmentId = PE.Id;
                                    newFieldUpdate.objectAndFieldName = 'Contact.' + str;
                                    newFieldUpdate.newValue = newContact.get(str);

                                    if (newContact.RecordTypeId == studentContactId)
                                        newFieldUpdate.studentOrHousehold = 'Student';
                                    else
                                        newFieldUpdate.studentOrHousehold = 'Household';
                                    fieldUpdateList.add(newFieldUpdate);
                                }
                            }
                        }
                    } catch(Exception e) { System.debug('Error: ' + e); logger.logException('handleAfterUpdate', e); logger.saveLogs(); }
                }

                if (contactsWithAtLeastOneOldECA.contains(newContact.Id))
                changedFieldsMap.put(newContact.Id, changedFields);
            }

            if (changedFieldsMap.size() > 0 && NES_Constants.runAssignment)  //These are the old ECA model.
            NES_ECACompletion.contactCompletion(changedFieldsMap);

            system.debug ('ContactTrigger  fieldUpdateList:' + fieldUpdateList);

            if (fieldUpdateList.size() > 0)  //Must be at least one PE in the NEW ECA model that has a changed field so call the new ECA stuff.
                EvaluationUtils.evaluateChangedFields  (fieldUpdateList);
        }
        
        
        if (likelihoodToTransitionScore)
            NES_ContactBusinessLogic.calculateLTS(actlstnewMap.values(), actlstoldMap); // Swapna:Changed to active list
        
        //Mark to recalculate Apex sharing
        NES_SharingUtility.markForRecalculation(newMap.values(), oldMap);
    }
    
    // public static void handleAfterInsert(Map<Id, Contact> newMap) {
    public static void handleAfterInsert(Map<Id, Contact> newMap, Map<Id, Contact> actlstnewMap) { //Swapna:Changed method signature
        //  if(!logicSwitch) return ;
        
        List<Contact> contacts = new List<Contact> ();
        // Set<Id> accountIds = new Set<Id>();
        //Added for US 197909 Student recordtype check by jagadeesh
        Set<Id> houseHoldIds = new Set<Id>();
        Id studentRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        for (Contact contact : newMap.values()) {
            contacts.add(contact);
            // accountIds.add(contact.accountId);
            if(Contact.recordTypeId == studentRTId){
                houseHoldIds.add(contact.AccountId);
            }
        }
        
        //added -- for the US 185603 by Jagadeesh
        // Excluded for bypassing batch/future/queuable execution  //added for US 203078 by Jagadeesh
        if (!houseHoldIds.isEmpty() && !System.isBatch() && !System.isFuture() && !System.isQueueable()){
            NES_ContactBusinessLogic.CountNoOfContacts(houseHoldIds);
        }
        //Ended -- for the US 185603 by Jagadeesh
        
        //Mark Membrino 3/19/2020 (1540590)  Removing all these calls because we do all these steps in NES_AddStudentCBLQueueable
        /*
//Start: Task #60094 Ashish Sharma December 14, 2018
if (NES_EntranceAgeUtility.entranceAgeEligibilitySwitch) {
List<sObject> validRecords = new List<SObject>();

//  for (Contact contact : newMap.values()) {
for (Contact contact : actlstnewMap.values()) { //Swapna:Changed to active list
if (contact.Birthdate__c != null) {
validRecords.add(contact);
}
contacts.add(contact);
}

if (validRecords.size() > 0) {
NES_BusinessLogicUtils.calculateEntranceAgeEligibility(validRecords);
}

}
//End Task #60094


if (likelihoodToTransitionScore)
NES_ContactBusinessLogic.calculateLTS(actlstnewMap.values(), null);
//   NES_ContactBusinessLogic.calculateLTS(newMap.values(), null); // Added by Anushka
*/
        // End Mark Membrino 3/19/2020 (1540590) 
        
        //Mark to recalculate Apex sharing
        NES_SharingUtility.markForRecalculation(newMap.values(), null);
    }
    
    public static void handleBeforeInsert(List<Contact> newMap) {
        for (Contact c : newMap) {
            if (Contact.Gender_Selector__c != null) {
                updateGender(c);
            }
        }
    }
    
    public static void handleBeforeUpdate(Map<Id, Contact> oldMap, Map<Id, Contact> newMap) {
        for (Contact c : newMap.values()) {
            Contact oldContact = oldMap.get(c.Id);
            if (c.Gender_Selector__c != oldContact.Gender_Selector__c) {
                updateGender(c);
            }
        }
    }
    
    private static void updateGender(Contact c) {
        c.Gender__c = c.Gender_Selector__c;
        c.Gender_Selector__c = 'Please select a value';
    }
    
    //added -- for the US 185603 by Jagadeesh
    public static void handleAfterDelete(List<Contact> oldList) {
        Set<Id> accountIds = new Set<Id>();
        //Added for US 197909 Student recordtype check by jagadeesh
        Id studentRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        for (Contact c : oldList) {
            if(c.recordTypeId == studentRTId){            
                accountIds.add(c.accountId);
            }
        }
        system.debug('after delete block');
        system.debug('accountIds-->'+accountIds);
         // Excluded for bypassing batch/future/queuable execution  //added for US 203078 by Jagadeesh
        if (!accountIds.isEmpty() && !System.isBatch() && !System.isFuture() && !System.isQueueable()){
            NES_ContactBusinessLogic.CountNoOfContacts(accountIds);   
        } 
    }
    public static void handleAfterUndelete(List<Contact> newList) {
        
        Set<Id> accountIds = new Set<Id>();
        //Added for US 197909 Student recordtype check by jagadeesh
        Id studentRTId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
        for (Contact c : newList) { if(c.recordTypeId == studentRTId){ accountIds.add(c.accountId);  }      }
        // Excluded for bypassing batch/future/queuable execution  //added for US 203078 by Jagadeesh
        if (!accountIds.isEmpty() && !System.isBatch() && !System.isFuture() && !System.isQueueable()){ NES_ContactBusinessLogic.CountNoOfContacts(accountIds);        } 
    }
    //Ended -- for the US 185603 by Jagadeesh
    
}