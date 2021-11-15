trigger NES_EnrollmentCompAffiliationTrigger on Enrollment_Component_Affiliation__c (before insert,after insert,before update,after update) {
    
   //added code for US119349 by anitha P
    if(trigger.isBefore){
        if(trigger.isInsert){
            NES_ECAHandler.handleBeforeInsert(Trigger.new);
        }
        if ( Trigger.isUpdate ){
            NES_ECAHandler.handleBeforeUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap);
        }
    }
    //added code for US119349 by anitha p
    if( Trigger.isInsert ){
        if(Trigger.isAfter)
        {
            NES_ECAHandler.handleAfterInsert(Trigger.new);
        
        }
    }
    else if ( Trigger.isUpdate ){
        if(Trigger.isAfter)
        {
          NES_ECAHandler.handleAfterUpdate(Trigger.new,Trigger.newMap,Trigger.oldMap);
       
        }
    }
}