trigger  NES_HealthAndImmunizationTrigger on Health_and_Immunization__c (before update, after update,after insert) {
    
    if ( Trigger.isUpdate ){
        if(Trigger.isBefore) {
            NES_HealthAndImmunizationHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        } else {
            NES_HealthAndImmunizationHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
        }
       
    }
    if ( Trigger.isInsert ){
        System.debug('isInsert++++');
        if(Trigger.isAfter) {
            System.debug('isAfter++++');
            NES_HealthAndImmunizationHandler.handleAfterInsert(Trigger.newMap);
        }
    }
}