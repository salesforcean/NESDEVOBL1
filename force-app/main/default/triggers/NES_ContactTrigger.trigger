trigger NES_ContactTrigger on Contact(after insert, after update, before insert, before update, after delete, after undelete) {

    if (Trigger.isAfter && Trigger.isUpdate) {
        //  NES_ContactHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
        //Swapna:Changed the logic to ensure the business and logic is executed for active students
        Set<ID> idsReferenced = Trigger.newMap.keySet();
        List<hed__Program_Enrollment__c> allRelatedInProgPEs = [select hed__Contact__c from hed__Program_Enrollment__c where Status__c = 'In Progress' and hed__Contact__c IN :idsReferenced];
        
        Set<Id> ContactsWithAnInProgPE = new Set<Id> ();
        if (allRelatedInProgPEs.size() > 0)  {
            for ( hed__Program_Enrollment__c  pe : allRelatedInProgPEs)
                ContactsWithAnInProgPE.add(pe.hed__Contact__c);
        }

        Map<Id, Contact> actlstoldMap = new Map<Id, Contact> ();
        Map<Id, Contact> actlstnewMap = new Map<Id, Contact> ();
        for (Contact con : Trigger.new) {
            if (ContactsWithAnInProgPE.contains(con.id)) {  //If it has an in prog pe, add it.
                actlstnewMap.put(con.id, Trigger.newMap.get(con.id));
                actlstoldMap.put(con.id, Trigger.oldMap.get(con.id));
            }
        }

        NES_ContactHandler.handleAfterUpdate(Trigger.oldMap, Trigger.newMap, actlstoldMap, actlstnewMap);   


        // 2020-May-15: Sumanth B: Removed call to CS code as per the Task # 177183
            
    }

    if (Trigger.isAfter && Trigger.isInsert) {
        // NES_ContactHandler.handleAfterInsert(Trigger.newMap); 
        //Swapna:Changed the logic to ensure the business and logic is executed for active students

        //Mark Membrino : Removing this active stuff because PEs are created after contacts so this will never find any 
        //                  records but it still adds to the query count.
        //                  I am going to leave the parameter because I don't want change the signature and break a bunch of stuff.
        //Set<ID> idsReferenced = Trigger.newMap.keySet();
        //List<hed__Program_Enrollment__c> allRelatedInProgPEs = [select hed__Contact__c from hed__Program_Enrollment__c where Status__c = 'In Progress' and hed__Contact__c IN :idsReferenced];



        //Set<Id> ContactsWithAnInProgPE = new Set<Id> ();
        //if (allRelatedInProgPEs.size() > 0)  {
        //  for ( hed__Program_Enrollment__c  pe : allRelatedInProgPEs)
        //      ContactsWithAnInProgPE.add(pe.hed__Contact__c);
        //}

        //Instantiate this map even though we are not using it.
        Map<Id, Contact> actlstnewMap = new Map<Id, Contact> ();
        //for (Contact con : Trigger.new) {
        //  if (ContactsWithAnInProgPE.contains(con.id)) {  //If it has an in prog pe, add it.
        //      actlstnewMap.put(con.id, Trigger.newMap.get(con.id));
        //  }
        //}


        NES_ContactHandler.handleAfterInsert(Trigger.newMap, actlstnewMap);
    }

    if (Trigger.isBefore && Trigger.isInsert) {
        NES_ContactHandler.handleBeforeInsert(Trigger.new);
    }

    if (Trigger.isBefore && Trigger.isUpdate) {
        NES_ContactHandler.handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
    }
        
    //added -- for the US 185603 by Jagadeesh
    if ((trigger.isAfter) && (trigger.isdelete)){
        NES_ContactHandler.handleAfterDelete(Trigger.old);
    }
     if ((trigger.isAfter) && (trigger.isUndelete)){
        NES_ContactHandler.handleAfterUndelete(Trigger.new);
    }
   //added -- for the US 185603 by Jagadeesh
    
}