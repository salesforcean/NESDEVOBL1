/**
 * Created by Anushka Bansal on 21-12-2018.
 */

trigger NES_ProgramGradeLevelTrigger on Program_Grade_Level__c (after insert, after update) {

    if(Trigger.isAfter){
        if(Trigger.isInsert)
        {
            NES_ProgramGradeLevelHandler.handleAfterInsert(Trigger.new);
        }

        if(Trigger.isUpdate){
            /*set<id> peIds = new set<id>();
            for(Program_Grade_Level__c pg: trigger.new){
                peIds.add(pg.Id);
                system.debug('peIds'+peIds);
            }
            Map<Id,hed__Program_Enrollment__c> peList = new Map<Id,hed__Program_Enrollment__c>([select id,Program_Grade_Level__c,Open_Application__c from hed__Program_Enrollment__c where Program_Grade_Level__c IN:peIds AND Open_Application__c != null]);*/
        
            
            NES_ProgramGradeLevelHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.oldMap);
            //NES_BusinessLogicUtils.waitListCalculator(peList.keySet());
             //NES_BusinessLogicUtils.openApplicationflag(Trigger.new);
            
        }

    }
}