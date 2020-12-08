/**
* Created by Mark Membrino on 5/21/2020 as a quick batch job to set all the initial number of students on the account.
*/

global with sharing class NES_BatchSetInitialCountofStudents  implements DataBase.Batchable<SObject>, Schedulable {
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_BatchSetInitialCountofStudents');
    global NES_BatchSetInitialCountofStudents() {
        
    }
    
    // Find all the current in progress program enrollments
    global List<SObject> start(Database.BatchableContext BC){
        
        List<account> accounts = [SELECT Id FROM account];
        return accounts;
    }
    
    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        Set<Id> accountIdSet = new Set<Id>();
        for(account a : (List<account>) scope) {
            accountIdSet.add(a.Id);
        }
        NES_ContactBusinessLogic.CountNoOfContacts(accountIdSet);
    }
    
    global void finish(Database.BatchableContext BC) {
    }
    
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_BatchSetInitialCountofStudents(), 25);
    }
    
}