public class NES_ECAStatusUpdate {
    
    public Static void InitReActivateReenrollment(List<Enrollment_Component_Affiliation__c> existEcas){
        
        List<Enrollment_Component_Affiliation__c> ecastoUpdate=new List<Enrollment_Component_Affiliation__c>();
        
            
            for(Enrollment_Component_Affiliation__c eca :existEcas){
                if(eca.Enrollment_Component__r.RecordType.Name !='Stage'){
                    if(eca.Enrollment_Component__r.RecordType.Name == 'Document' && eca.Enrollment_Component__r.Component_Type__c == 'Household' && eca.Status__c == 'Complete'){
                        eca.Status__c = 'Not Started';
                    }
                    else if((String.isBlank(eca.Enrollment_Component__r.Assignment_Logic__c))){
                        eca.Status__c = 'Not Started';
                        //ecastoUpdate.add(eca);
                    }
                    else{
                        eca.Status__c = 'Not Applicable';
                        //ecastoUpdate.add(eca);
                    }
                } 
                ecastoUpdate.add(eca);
                //existEcas.add(eca);
            }  
        
        if(ecastoUpdate.size() > 0)
            update ecastoUpdate;
       
        
    }

}