/**
 * Created by Ritvik on 25/10/18.
 * Purpose : Handler class for Criteria Group trigger.
 */

public class NES_CriteriaGroupHandler {

    NES_CriteriaGroupBusinessLogic logicHandler = new NES_CriteriaGroupBusinessLogic();
     static final Boolean logicSwitch = NES_TriggerUtility.BusinessLogicSwitch('CriteriaGroupTrigger');

    public void handleBeforeInsert(List<Criteria_Group__c> newList){
    if(!logicSwitch) return ;
        logicHandler.GenerateNumber(newList);
    }

    public void handleAfterInsert(List<Criteria_Group__c> newList){
    if(!logicSwitch) return ;
    }

}