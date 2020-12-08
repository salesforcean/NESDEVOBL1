/**
 * Created by Ritvik on 26-10-2018.
 */

trigger NES_EnrollmentCompCriteriaTrigger on Enrollment_Component_Criteria__c (before insert, before update, after insert, after update) {
    NES_EnrollmentCompCriteriaHandler handler = new NES_EnrollmentCompCriteriaHandler();

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
   /* else if ( Trigger.isUpdate )
    {
        if(Trigger.isBefore)
        {
            handler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
        }
        else
        {
            handler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
        }
    }*/
}