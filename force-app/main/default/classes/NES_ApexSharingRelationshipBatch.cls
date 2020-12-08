/**
 * Created by melindagrad on 3/3/19.
 */

global class NES_ApexSharingRelationshipBatch implements Database.Batchable<SObject>, Schedulable {

    global NES_ApexSharingRelationshipBatch(){

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('In Batch Start++');

        List<hed__Relationship__c> relationships = new List<hed__Relationship__c>([
                SELECT Id, Recalculate_Sharing__c
                FROM hed__Relationship__c
                WHERE Recalculate_Sharing__c = TRUE]);

        System.debug('In Batch '+relationships.size());

        return Database.getQueryLocator([
                SELECT Id, Recalculate_Sharing__c
                FROM hed__Relationship__c
                WHERE Recalculate_Sharing__c = TRUE
        ]);
    }

    global void execute(Database.BatchableContext BC, List<hed__Relationship__c> scope){
        System.debug('scope++'+scope);
        NES_SharingUtility.calculateRelationshipShares(scope);

    }

    global void finish(Database.BatchableContext BC) {

    }

    global void execute(SchedulableContext sc) {
        Database.executeBatch(new NES_ApexSharingRelationshipBatch(), 200);
    }

}