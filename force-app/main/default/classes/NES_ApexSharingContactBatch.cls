/**
 * Created by Melinda Grad on 2/19/19.
 */

global class NES_ApexSharingContactBatch implements Database.Batchable<SObject>, Schedulable{

    global NES_ApexSharingContactBatch(){

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {

        return Database.getQueryLocator([
                SELECT Id, Recalculate_Sharing__c
                FROM Contact
                WHERE Recalculate_Sharing__c = TRUE
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Contact> scope){

        //Calling method to create share re
        NES_SharingUtility.calculateSharing(scope);

    }

    global void finish(Database.BatchableContext BC) {

    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_ApexSharingContactBatch(), 200);
    }
}