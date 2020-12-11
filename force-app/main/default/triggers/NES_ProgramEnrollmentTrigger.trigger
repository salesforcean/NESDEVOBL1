/*
* Created by:  
* Created date:  
* Purpose:  
* Change Log:
          2020-04-09 Sumanth B Added CS handler to associate permission set to the 
                     Student & CareTaker for US # 162232 in isUpdate&isAfter section
          2020-04-30 Rakesh Ramaswamy Added CS handler to associate school permission set to the 
                     Learning Coach related to US # 164369 in isUpdate & isAfter section.
          2020-05-08 Sumanth B Commented out the CS_ProgramEnrollmentHandler as its moved to Batch Job as part of US # 176990 (Task # 177185)         
*/

trigger NES_ProgramEnrollmentTrigger on hed__Program_Enrollment__c (before update, after update, after Insert, before insert, before delete ) {
    if ( Trigger.isUpdate ){        
        if(Trigger.isBefore)
        {
        // NES_ProgramEnrollmentHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
        //Swapna:Changed the logic to ensure the business assignment logic is executed for active students
          
           Map<Id,hed__Program_Enrollment__c> actlstoldMap = new Map<Id,hed__Program_Enrollment__c>();
           Map<Id,hed__Program_Enrollment__c> actlstnewMap = new Map<Id,hed__Program_Enrollment__c>();                     
           
           for(hed__Program_Enrollment__c pe:Trigger.new)
           {
               if(pe.status__c == 'In Progress')
               {              
                   actlstnewMap.put(pe.id,Trigger.newMap.get(pe.id));
                   actlstoldMap.put(pe.id,Trigger.oldMap.get(pe.id));
               }               
           }                        
             
             NES_ProgramEnrollmentHandler.handleBeforeUpdate(Trigger.newMap,Trigger.oldMap,actlstnewMap,actlstoldMap);                               
        }
        else {
               
            //  NES_ProgramEnrollmentHandler.handleAfterUpdate(Trigger.newMap, Trigger.oldMap);
           //Swapna:Changed the logic to ensure the business assignment logic is executed for active students
           Map<Id,hed__Program_Enrollment__c> actlstoldMap = new Map<Id,hed__Program_Enrollment__c>();
           Map<Id,hed__Program_Enrollment__c> actlstnewMap = new Map<Id,hed__Program_Enrollment__c>();

          // List<id> stdStatComplLst = new List<Id>(); // Added by Sumanth B for the US # 162232
          // List<id> stdStatWDLst = new List<id>();    // Added by Sumanth B for the US # 162232
           
           for(hed__Program_Enrollment__c pe:Trigger.new)
           {               
               if(pe.status__c == 'In Progress')
               {
                   actlstnewMap.put(pe.id,Trigger.newMap.get(pe.id));
                   actlstoldMap.put(pe.id,Trigger.oldMap.get(pe.id));
               }

               //Sumanth B:Added CS_ProgramEnrollmentHandler for Associting/Removing permission sets 
               // to the Student and Caretaker for US # 162232 based on PE Status (Complete/Withdrawn)
               //Sumanth B: Commented out as its moved to Batch Job
               /*
               else
               if(pe.status__c == 'Complete' && pe.Contact_RecordType__c == 'Students')
               {
                   hed__Program_Enrollment__c peOldMap = Trigger.oldMap.get(pe.Id);                   
                   if(peOldMap.Status__c != 'Complete')
                   {
                       stdStatComplLst.add(pe.id);                                             
                   }
               }
               else
               if(pe.status__c == 'Withdrawn' && pe.Contact_RecordType__c == 'Students')
               {
                   hed__Program_Enrollment__c peOldMap = Trigger.oldMap.get(pe.Id);
                   system.debug('**** Withdrawn Status Check For Students Executing in Test Class Context *****');
                   if(peOldMap.Status__c != 'Withdrawn')
                   {
                       stdStatWDLst.add(pe.id);                       
                   }
               } */
           }
            NES_ProgramEnrollmentHandler.handleAfterUpdate(Trigger.newMap,Trigger.oldMap,actlstnewMap,actlstoldMap);
         //   if(stdStatComplLst.size() > 0 || stdStatWDLst.size() > 0)  
         //       CS_ProgramEnrollmentHandler.invokePermSets(stdStatComplLst,stdStatWDLst);                                                                    
        }
       
    }
    
    if(Trigger.isInsert){
        if(Trigger.isAfter){
           // NES_ProgramEnrollmentHandler.handleAfterInsert(Trigger.new);
               //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
           List<hed__Program_Enrollment__c> actlst = new List<hed__Program_Enrollment__c>();
           for(hed__Program_Enrollment__c pe:Trigger.new)
           {
               if(pe.status__c == 'In Progress')
               actlst.add(pe);   
           }  
           NES_ProgramEnrollmentHandler.handleAfterInsert(Trigger.new,actlst);
                                
        }
        else{
           // NES_ProgramEnrollmentHandler.handleBeforeInsert(Trigger.new);
              //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
           List<hed__Program_Enrollment__c> actlst = new List<hed__Program_Enrollment__c>();
           for(hed__Program_Enrollment__c pe:Trigger.new)
           {
               if(pe.status__c == 'In Progress')
               actlst.add(pe);   
           } 
           NES_ProgramEnrollmentHandler.handleBeforeInsert(Trigger.new,actlst); 
        }
    }

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            System.debug('PE TRIGGER');
            //NES_ProgramEnrollmentHandler.handleBeforedelete(Trigger.oldMap);
        }
    }
}