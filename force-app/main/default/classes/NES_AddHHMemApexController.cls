public without sharing class NES_AddHHMemApexController {
    
    private static Peak_ApexLog logger = new Peak_ApexLog('NES_AddHHMemApexController');
    
    @AuraEnabled
    public static boolean STExistsforCT(){
        
        Boolean StPEExist = false;     
        //Student Record Type Id
        Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();                
        User cUsr = [Select Id, ContactId, Contact.AccountId from User where Id =: UserInfo.getUserId() limit 1];
        
                    
        List <hed__Relationship__c>  relRecList = [SELECT Id, hed__RelatedContact__c FROM hed__Relationship__c
                                                    WHERE hed__RelatedContact__c = : cUsr.ContactId 
                                                    AND hed__Contact__r.RecordTypeId = :studentRecordTypeId];
        
        if(relRecList != null && relRecList.size() >0){
            StPEExist = true;
        }
        return StPEExist;        
    }
    
    @AuraEnabled
    public static Map<String,String> chkExistCnts(String houseHoldMemberData){
      
        Map<String,String> respMap=new  Map<String,String>();
        AdditionalHouseHoldMembers member=(AdditionalHouseHoldMembers) JSON.deserialize(houseHoldMemberData, AdditionalHouseHoldMembers.class);
        String cntctExists = '';        
        
        User cUsr = [Select Id, ContactId, Contact.AccountId from User where Id =: UserInfo.getUserId() limit 1];        
        List <Contact> cntcList = [Select Id, RecordType.Name from Contact where Id !=: cUsr.ContactId and accountId =: cUsr.Contact.AccountId and Firstname =: member.fName and LastName =: member.lName and Email =: member.email];
        
        if(cntcList != null && cntcList.size() >0){
            respMap.put('status', 'ExistingContact');
            respMap.put('recordType', cntcList[0].RecordType.Name);
            cntctExists =  cntcList[0].RecordType.Name;
        }  
        else{           
            cntctExists = createAddlHHMemContact(houseHoldMemberData);
            respMap.put('status', cntctExists);            
        }
        
        return respMap;        
    }

    @AuraEnabled
    public static String createAddlHHMemContact(String houseHoldMemberData){
        
        String response=null;
        try{
            //Get LoggedIn User Contact ID
            User usrContact = [select contactId, contact.Email, contact.AccountId, contact.OwnerID from User where id =:UserInfo.getUserId() limit 1];
                 if(usrContact != null && !String.isBlank(usrContact.ContactId)){
                    AdditionalHouseHoldMembers member=(AdditionalHouseHoldMembers) JSON.deserialize(houseHoldMemberData, AdditionalHouseHoldMembers.class);
                    String memberRTDeveloperName;
                    String v2Role;
                    //get RT_ID using DeveloperName based on Selection from FE
                     if(member.memberRTDeveloperName!=null){
                          String hhTypeVal =member.memberRTDeveloperName.split(':')[0];
                         if(hhTypeVal == 'Learning_Coach'){
                             memberRTDeveloperName =  'Learning_Coach';
                             v2Role = 'Learning Coach';
                         }
                         else if (hhTypeVal == 'Caretaker_Parent'){
                             memberRTDeveloperName =  'Caretaker';
                             v2Role = 'Parent or Legal Guardian';
                         }
                         else if (hhTypeVal == 'Caretaker_Designated'){
                             memberRTDeveloperName =  'Caretaker';
                             v2Role = 'Designated Caretaker';
                         }
                     }
                   
                    Id memberRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(memberRTDeveloperName).getRecordTypeId();
                    
                     //Create a new Household Member
                    Contact careTaker=new Contact();
                    careTaker.FirstName=member.fName;
                    careTaker.MiddleName=member.mName;
                    careTaker.lastName=member.lName;
                    careTaker.Suffix=member.suffix;
                    careTaker.Email=member.email;
                    careTaker.ownerId= usrContact.contact.OwnerId;
                    careTaker.hed__PreferredPhone__c=member.phoneType;
                    careTaker.V2_Role__c = v2Role;
                    //careTaker.Owner_CT_Email__c = usrContact.Contact.Email;
                    //careTaker.hed__AlternateEmail__c = 'Alternate';
                     
                     if(member.phoneType=='Mobile'){
                         careTaker.Phone =member.phoneNumber;
                     }else if(member.phoneType=='Home'){
                         careTaker.HomePhone =member.phoneNumber;
                     }else if(member.phoneType=='Work'){
                         careTaker.hed__WorkPhone__c =member.phoneNumber;
                     }else if(member.phoneType=='Other'){
                         careTaker.OtherPhone =member.phoneNumber;
                     }
                    
                    careTaker.RecordTypeId=memberRecordTypeId;
                    careTaker.AccountId=usrContact.contact.accountId;
                    careTaker.Unverified__c = true;
               
                    // Naveen
                    Database.SaveResult sr = Database.insert(careTaker, false);
                   
                    
                    // Create the Case/Ticket and Send the Email only if the above Insert is Successful
                    // Being done using a flow..
                    if(sr.isSuccess())
                    {
                        // Create the relationship records to associate the Existing students to new CT                        
                        Boolean relRecsCreated = createdRelRecords(usrContact.ContactId, sr.getId());
                        if(relRecsCreated){
                           
                           response='New Contact Created'; 
                        }
                        else{
                            System.debug('NDEBUG:::: Relationship records Creation Failed');
                            response = 'FAILURE';
                        } 
                          
                    }
                     else{
                         System.debug('NDEBUG:::: Contact Creation Failed');
                         
                     }
            }else{
                 
                 response = 'FAILURE';
            }                   
        }catch(Exception ex){
            system.debug('===>'+ex);
            logger.logException('Addl HH Member Contact Creation Failed', ex);
            logger.saveLogs();
            return null;
        }
        return response;
    }
    
    
    public class AdditionalHouseHoldMembers{
        public String fName;
        public String mName;
        public String lName;
        public string email;
        public string suffix;
        public string phoneType;
        public string phoneNumber;
        public String memberRTDeveloperName;
        public String accountId;
    }
        
    // Create new hed__Relationship__c records for this new CT contact and existing students
    public static Boolean createdRelRecords(Id oldCtContactId, Id newCtContactId){
        Boolean saveResult = true;
        
        //Student Record Type Id
        Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();
        List <hed__Relationship__c> existingSts = [SELECT Id, hed__RelatedContact__c, hed__Contact__c  FROM hed__Relationship__c 
                                                   WHERE hed__Contact__c = : oldCtContactId AND hed__RelatedContact__r.RecordTypeId = :studentRecordTypeId];
        
        List <hed__Relationship__c> relationshipList = new List <hed__Relationship__c> (); 
        for(hed__Relationship__c rel: existingSts){
                    hed__Relationship__c relationship = new hed__Relationship__c();
                    relationship.hed__Contact__c = newCtContactId;
                    relationship.hed__Status__c = 'Current';
                    relationship.hed__RelatedContact__c =  rel.hed__RelatedContact__c;
                    relationship.Recalculate_Sharing__c = true;
                   // TODO:: relationship.hed__Type__c = relation;
                    relationship.OwnerId = System.Label.NES_Household_OwnerId;
                    relationshipList.add(relationship);
                }
        Database.SaveResult[] srList = Database.insert(relationshipList, false);
        for(Database.SaveResult sr : srList){
            if(!sr.isSuccess()){
                saveResult = false;
            }
        }
        
        // Fetch the Primary CT HH PE and clone it for new CT
        List<hed__Program_Enrollment__c> caretakerEnrollmentList = [SELECT Id, ownerId, RecordTypeId, hed__Contact__c, hed__Account__c FROM hed__Program_Enrollment__c  
                                                                WHERE hed__Contact__c = : oldCtContactId ];
        
        List<hed__Program_Enrollment__c> newcaretakerEnrollmentList = new List<hed__Program_Enrollment__c> ();
        if(caretakerEnrollmentList != null && caretakerEnrollmentList.size() >0){
            for(hed__Program_Enrollment__c hhPe: caretakerEnrollmentList){
                hed__Program_Enrollment__c newCareTakerEnrollment = new hed__Program_Enrollment__c();
                newCareTakerEnrollment.hed__Contact__c = newCtContactId;
                newCareTakerEnrollment.RecordTypeId = hhPe.RecordTypeId;
                newCareTakerEnrollment.OwnerId = hhPe.OwnerId;
                if (hhPe.hed__Account__c != null) {
                    newCareTakerEnrollment.hed__Account__c = hhPe.hed__Account__c;
                }
                newcaretakerEnrollmentList.add(newCareTakerEnrollment);
            }
        }
        Insert newcaretakerEnrollmentList;
        
        return saveResult;
        
        
        
    }
    
    
    public class EmailParameters{
        @InvocableVariable(required=true)
        public string v2Role;
        @InvocableVariable(required=true)
        public contact addlHHMember;
    }
    
    @InvocableMethod(label='Send Agreement Email')
    public static void sendEmail(EmailParameters [] emailParams){
        
               
        Map <String, String> v2RoleToEmailTempl = new Map <String, String> ();
        v2RoleToEmailTempl.put('Parent or Legal Guardian', 'Parent_Legal_Guardian_Caretaker_Acknowledgement');
        v2RoleToEmailTempl.put('Designated Caretaker', 'Caretaker_Designee_Agreement');
        v2RoleToEmailTempl.put('Learning Coach', 'Designated_Learning_Coach_Agreement');
        String emailTempl = v2RoleToEmailTempl.get(emailParams[0].v2Role);
        
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName =: emailTempl];
        
        User  ctContactUser = [Select Id, contactId, contact.Email, contact.hed__AlternateEmail__c from user where Id =: emailParams[0].addlHHMember.CreatedById limit 1];
        
        String email;
        if(Test.isRunningTest()) {
            email = 'test@test.com';
        }else{
            email = ctContactUser.contact.hed__AlternateEmail__c;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(lstEmailTemplates[0].Id);
        mail.setSaveAsActivity(false);
        mail.setTargetObjectId(ctContactUser.Id);// Any contact or User id of your record
        mail.setToAddresses(new list<string>{email});
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });             
       
    }

}