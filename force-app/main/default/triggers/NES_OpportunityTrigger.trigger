/**
 * Created by Anand on 12/3/2018.
 */

trigger NES_OpportunityTrigger on Opportunity (before insert, before update,after update,after Insert) {
    if(trigger.isBefore){
        if(trigger.isInsert){
          // NES_OpportunityHandler.beforeInsert(trigger.new);
             //Swapna:Changed the logic to ensure the business and logic is executed for active students
           List<Opportunity> actlst = new List<Opportunity>();
           for(Opportunity pe:Trigger.new)
           {
               if(pe.Student_Act_Status__c  == true)
               actlst.add(pe);   
           }  
          NES_OpportunityHandler.beforeInsert(Trigger.new,actlst);
           
        }
        if(trigger.isUpdate){
          //  NES_OpportunityHandler.beforeUpdate(trigger.oldMap,trigger.new, trigger.NewMap);
           //Swapna:Changed the logic to ensure the business and logic is executed for active students
           List<Opportunity> actlst = new List<Opportunity>();
           Map<Id,Opportunity> actlstoldMap = new Map<Id,Opportunity>();
           Map<Id,Opportunity> actlstnewMap = new Map<Id,Opportunity>();
           for(Opportunity asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
               actlst.add(asi);
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));
           }
           }
           NES_OpportunityHandler.beforeUpdate(trigger.oldMap,trigger.new, trigger.NewMap,actlstoldMap,actlst,actlstnewMap);
        }
        /*if(trigger.isUpdate){
           //NES_OpportunityHandler.afterUpdate(trigger.oldMap,trigger.newMap);
        }*/
    }
   if(trigger.isAfter){
        if(trigger.isUpdate){
         // NES_OpportunityHandler.afterUpdate(trigger.oldMap,trigger.newMap);
          //Swapna:Changed the logic to ensure the business and logic is executed for active students
          
           Map<Id,Opportunity> actlstoldMap = new Map<Id,Opportunity>();
           Map<Id,Opportunity> actlstnewMap = new Map<Id,Opportunity>();
           for(Opportunity asi:Trigger.new){
           if(asi.Student_Act_Status__c == true){
               
               actlstnewMap.put(asi.id,Trigger.newMap.get(asi.id));
               actlstoldMap.put(asi.id,Trigger.oldMap.get(asi.id));
           }
           }
        NES_OpportunityHandler.afterUpdate(trigger.oldMap,trigger.newMap,actlstoldMap,actlstnewMap);
    }
       if(trigger.isInsert){
          // NES_OpportunityHandler.afterInsert(trigger.New);
           //Swapna:Changed the logic to ensure the business and logic is executed for active students
           List<Opportunity> actlst = new List<Opportunity>();
           for(Opportunity pe:Trigger.new)
           {
               if(pe.Student_Act_Status__c  == true)
               actlst.add(pe);   
           }  
           NES_OpportunityHandler.afterInsert(Trigger.new,actlst);
       }
    }
}