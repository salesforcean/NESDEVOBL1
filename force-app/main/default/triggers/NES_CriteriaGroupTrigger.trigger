/**
 * Created by Ritvik on 25/10/18.
 * Purpose : Trigger on Criteria Group object.
 */

trigger NES_CriteriaGroupTrigger on Criteria_Group__c (before insert, before update, after insert, after update) {
    //Instantiating handler class object.
    NES_CriteriaGroupHandler handler = new NES_CriteriaGroupHandler();

    if( Trigger.isInsert )
    {
        if(Trigger.isBefore)
        {
            handler.handleBeforeInsert(Trigger.new);
        }
        else
        {
            handler.handleAfterInsert(Trigger.new);
        }
    }

}