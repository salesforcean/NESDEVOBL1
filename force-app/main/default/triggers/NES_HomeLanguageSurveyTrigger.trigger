/**
 * Created By Anand 12/10/2018
 * 
 */
trigger NES_HomeLanguageSurveyTrigger on Home_Language_Survey__c (before insert,after insert,after update, before update) {

    if(trigger.isAfter){
        if(trigger.isInsert){
           // NES_HomeLanguageSurveyHandler.afterInsert(trigger.new);
           //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
           List<Home_Language_Survey__c> actlst = new List<Home_Language_Survey__c>();
           for(Home_Language_Survey__c hls:Trigger.new) {
               if(hls.Student_Act_Status__c == true)
               actlst.add(hls);   
           }  
            
           NES_HomeLanguageSurveyHandler.afterInsert(trigger.new,actlst);
        }
        if(trigger.isUpdate){
          //  NES_HomeLanguageSurveyHandler.afterUpdate(trigger.newMap,trigger.oldMap);
           //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
          
           Map<Id,Home_Language_Survey__c> actlstoldMap = new Map<Id,Home_Language_Survey__c>();
           Map<Id,Home_Language_Survey__c> actlstnewMap = new Map<Id,Home_Language_Survey__c>();
           for(Home_Language_Survey__c hls:Trigger.new) {
           if(hls.Student_Act_Status__c == true){
              
               actlstnewMap.put(hls.id,Trigger.newMap.get(hls.id));
               actlstoldMap.put(hls.id,Trigger.oldMap.get(hls.id));
           }
           }
            NES_HomeLanguageSurveyHandler.afterUpdate(trigger.newMap,trigger.oldMap,actlstnewMap,actlstoldMap);
        }
    }
    
      if ( Trigger.isUpdate ){
        if(Trigger.isBefore)
        {
          //  NES_HomeLanguageSurveyHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap);
           //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
          
           Map<Id,Home_Language_Survey__c> actlstoldMap = new Map<Id,Home_Language_Survey__c>();
           Map<Id,Home_Language_Survey__c> actlstnewMap = new Map<Id,Home_Language_Survey__c>();
           for(Home_Language_Survey__c hls:Trigger.new){
           if(hls.Student_Act_Status__c == true) {
              
               actlstnewMap.put(hls.id,Trigger.newMap.get(hls.id));
               actlstoldMap.put(hls.id,Trigger.oldMap.get(hls.id));
           }
           }
             NES_HomeLanguageSurveyHandler.handleBeforeUpdate(Trigger.newMap, Trigger.oldMap,actlstnewMap,actlstoldMap);
        }
       
    }
    
    if(Trigger.isInsert){
        if(Trigger.isBefore)
        {
           // NES_HomeLanguageSurveyHandler.handleBeforeInsert(Trigger.new);
             //Swapna:Changed the logic to ensure the business and assignment logic is executed for active students
           List<Home_Language_Survey__c> actlst = new List<Home_Language_Survey__c>();
           for(Home_Language_Survey__c hls:Trigger.new) {
               if(hls.Student_Act_Status__c == true)
               actlst.add(hls);   
           } 
          NES_HomeLanguageSurveyHandler.handleBeforeInsert(Trigger.new,actlst); 
        }
       
    }
}