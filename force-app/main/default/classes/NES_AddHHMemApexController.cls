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
        system.debug('StPEExist>>>'+StPEExist);
        return StPEExist;        
    }
    
    @AuraEnabled
    public static Map<String,String> chkExistCnts(String houseHoldMemberData){
        
        Map<String,String> respMap=new  Map<String,String>();
        AdditionalHouseHoldMembers member=(AdditionalHouseHoldMembers) JSON.deserialize(houseHoldMemberData, AdditionalHouseHoldMembers.class);
        String cntctExists = '';        
        
        User cUsr = [Select Id, ContactId, Contact.AccountId from User where Id =: UserInfo.getUserId() limit 1];        
        //List <Contact> cntcList = [Select Id, RecordType.Name from Contact where Id !=: cUsr.ContactId and accountId =: cUsr.Contact.AccountId and Firstname =: member.fName and LastName =: member.lName and Email =: member.email]; DEFECT 446508 - Commented and corrected below- DK  
        string finalFirstName = member.fname.trim();
        string finalLastName = member.lname.trim();
        
        string finalEmail = member.email.trim();
        finalEmail = finalEmail.toLowerCase();

        
        List <Contact> cntcList = [Select Id, RecordType.Name from Contact where accountId =: cUsr.Contact.AccountId and Firstname =: finalFirstName  and LastName =: finalLastName and Email =:finalEmail];
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
                        //v2Role = 'Parent or Legal Guardian';  DEFECT 446510 - Commented and corrected below- DK
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
                    response='New Contact Created'; 
                }
                else{
                    System.debug('NDEBUG:::: Contact Creation Failed');
                }
                
                
        Integer len = 3;
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, len);
                  
        Profile communityProfile = [SELECT Id, Name FROM Profile WHERE Name = 'Caretaker Community User'];
         
        User newUser = new User();
        newUser.FirstName = member.fName;
        newUser.LastName = member.lName;
        newUser.MiddleName = member.mName; 
        newUser.Username = member.email + '.' + Label.NES_Username_suffix+''+randomNumber;
        newUser.Alias = (member.fName.length() >2 ? member.fName.substring(0, 2) : member.fName) + (member.lName.length() > 2 ? member.lName.substring(0, 2) : member.lName);
        newUser.Email = member.email;
        //newUser.CommunityNickname = uName;
        newUser.ProfileId = communityProfile.Id;
        newUser.TimeZoneSidKey = 'America/New_York';
        newUser.LocaleSidKey = 'en_US';
        newUser.EmailEncodingKey = 'UTF-8';
        newUser.LanguageLocaleKey = 'en_US';
        //newUser.FederationIdentifier = uName;
        //newUser.PearsonUID__c = userId;
        newUser.ContactId = careTaker.Id;
        newUser.Document_Authorization__c = NES_Constants.DOCUMENT_AUTHORIZATION_CT;
        
        try {
            insert newUser;
            System.debug('The creation of user here:'+newUser);
        } catch(Exception e) { logger.logException('createRecords', e); logger.saveLogs();  throw e;  }
    
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
    public static Boolean createdRelRecords(FlowParams [] flowParams){
        Boolean saveResult = true;
        Id oldCtContactId = [Select Id, contactId from user where Id =: flowParams[0].addlHHMember.CreatedById limit 1].contactId;
        Id newCtContactId = flowParams[0].addlHHMember.Id;
        
        //Student Record Type Id
        Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(NES_DashboardUtilities.STUDENT_RT).getRecordTypeId();
        List <hed__Relationship__c> existingSts = [SELECT Id, hed__RelatedContact__c, hed__Contact__c  FROM hed__Relationship__c 
                                                   WHERE hed__RelatedContact__c = : oldCtContactId AND hed__Contact__r.RecordTypeId = :studentRecordTypeId];
        
        List <hed__Relationship__c> relationshipList = new List <hed__Relationship__c> (); 
        for(hed__Relationship__c rel: existingSts){
            hed__Relationship__c relationship = new hed__Relationship__c();
            //relationship.hed__Contact__c = newCtContactId;
            relationship.hed__Contact__c = rel.hed__Contact__c;
            relationship.hed__Status__c = 'Current';
            //relationship.hed__RelatedContact__c =  rel.hed__RelatedContact__c;
            relationship.hed__RelatedContact__c =  newCtContactId;
            relationship.Recalculate_Sharing__c = true;          
            relationship.hed__Type__c = flowParams[0].addlHHMember.V2_Role__c == 'Parent or Legal Guardian'? 'Parent' : ( flowParams[0].addlHHMember.V2_Role__c == 'Designated Caretaker'? 'Legal Guardian' : (flowParams[0].addlHHMember.V2_Role__c == 'Learning Coach' ? 'Learning Coach' :''));
            relationship.OwnerId = System.Label.NES_Household_OwnerId;
            relationshipList.add(relationship);
        }
        
        System.debug('NDEBUG:: Relationship records being inserted:::' +relationshipList);
        Database.SaveResult[] srList = Database.insert(relationshipList, false);
        for(Database.SaveResult sr : srList){
            if(!sr.isSuccess()){
                saveResult = false;
            }
        }
        
        // Fetch the Primary CT HH PE and clone it for new Non-Learning Coach CT 
        if(flowParams[0].addlHHMember.V2_Role__c != 'Learning Coach'){
            
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
        }
        return saveResult;
    }
    
    
    public class FlowParams{
        @InvocableVariable
        public String v2Role;
        @InvocableVariable
        public Contact addlHHMember;
        @InvocableVariable(required=true)
        public String action;
    }
    
    @InvocableMethod(label='Call Apex Methods')
    public static void callApexMethods(FlowParams [] flowParams){
        System.debug('NDEBUG Apex Method::::' + flowParams[0].action);
        if(flowParams[0].action == 'Send Agreement Email'){
            sendAgreementEmail(flowParams);
        }
        else if(flowParams[0].action == 'Create Related Records'){
            sendApprovalEmail(flowParams);
            createdRelRecords(flowParams);
        }
    }
    
    public static void sendApprovalEmail(FlowParams [] flowParams){
        
        
        Map <String, String> v2RoleToEmailTempl = new Map <String, String> ();
        String emailTempl = 'Additional_household_member_approved';
        
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName =: emailTempl];
        
        User  ctContactUser = [Select Id, contactId, contact.Email, contact.hed__AlternateEmail__c from user where Id =: flowParams[0].addlHHMember.CreatedById limit 1];
        
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
    
    public static void sendAgreementEmail(FlowParams [] flowParams){
        
        
        Map <String, String> v2RoleToEmailTempl = new Map <String, String> ();
        v2RoleToEmailTempl.put('Parent or Legal Guardian', 'Parent_Legal_Guardian_Caretaker_Acknowledgement');
        v2RoleToEmailTempl.put('Designated Caretaker', 'Caretaker_Designee_Agreement');
        v2RoleToEmailTempl.put('Learning Coach', 'Designated_Learning_Coach_Agreement');
        String emailTempl = v2RoleToEmailTempl.get(flowParams[0].v2Role);
        
        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate where DeveloperName =: emailTempl];
        
        User  ctContactUser = [Select Id, contactId, contact.Email, contact.hed__AlternateEmail__c from user where Id =: flowParams[0].addlHHMember.CreatedById limit 1];
        
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