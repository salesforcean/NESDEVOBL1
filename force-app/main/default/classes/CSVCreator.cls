public without sharing class CSVCreator  {
    
    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');
        
        for(String result : results) {
            result = result.trim();
        }
        
        return results;
    }
    
    @AuraEnabled
    public static CSVObject getCSVObject(String csv_str) {
        List<String> lines_raw = csv_str.split('\n');
        List<String> headers_raw = separateCommas(lines_raw[0]);
        List<List<String>> lines = new List<List<String>>();
        List<CSVHeader> headers = new List<CSVHeader>();
        
        lines_raw.remove(0);
        
        //Handling fields with commas
        
        for(String line : lines_raw) {
            List<String> line_sep = separateCommas(line);
            List<String> fields = new List<String>();
            Boolean makeCompositeField = false;
            String compositeField;
            for(String field : line_sep) {
                if (field.startsWith('"') && field.endsWith('"')) {
                    fields.add(field.trim());
                } else if (field.startsWith('"')) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    fields.add(compositeField.trim());
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    fields.add(field.trim());
                }
            }
            lines.add(fields);
        }
        
        for(String header : headers_raw) {
            headers.add(new CSVHeader(header));
        }
        system.debug('lines-'+lines.size());
        return new CSVObject(headers, lines);
    }
    @AuraEnabled
    public static ResponseObj insertData(String strfromle,String section,List<Contact> contactList){
        ResponseObj returnresponse=new ResponseObj();
        List<Account> AccoutnListtoInsert = new List<Account>();
        List<CSVObject.CSVField> lstobj=new List<CSVObject.CSVField>();
        CSVObject.CSVField fieldObj;
        system.debug('strfromle = ' + contactList);
        List<Object> m =  (List<Object>)JSON.deserializeUntyped(strfromle);
        for(Object wrapper: m){
            if(wrapper instanceof map<string, object>) {
                Map<string, object> dataMap=(Map<string, object>)wrapper;
                for(String key:dataMap.keySet()){
                    system.debug('key = ' + key+'Value = '+dataMap.get(key));
                     fieldObj=new CSVObject.CSVField();
                     fieldObj.ConFirstName=(String)dataMap.get('Name');
                     fieldObj.ConLastName=(String)dataMap.get('Last Name');
                     fieldObj.Email=(String)dataMap.get('Email');   
                     fieldObj.username=(String)dataMap.get('Username');
                     fieldObj.password=(String)dataMap.get('Password');
                     fieldObj.state=(String)dataMap.get('State');
                     fieldObj.zip=(String)dataMap.get('Zip');
                     fieldObj.phone=(String)dataMap.get('Phone');
                     
                     fieldObj.phone=(String)dataMap.get('Phone');
                     fieldObj.programCode=(String)dataMap.get('Academic Program');
                     fieldObj.gradeCode=(String)dataMap.get('Grade');
                     fieldObj.yearCode=(String)dataMap.get('School Year');
                }
                    
                
                                     lstobj.add(fieldObj); 

            }
                   
        }
        
        //if(lstobj.size()>0)
        //createCommunityUsers(lstobj);
     //if(AccoutnListtoInsert.size() > 0)
     
            try {
                system.debug('section-'+section);
                if(section=='1')
                returnresponse=createCommunityUsers(lstobj);
                else if (section=='2')
                returnresponse=createStudent(fieldObj,contactList);
                else 
                returnresponse=createPERecord(fieldObj,contactList);    

               //returnresponse = 'SUCCESS';
            }
            catch(Exception ex){
                system.debug('exception-'+ex);
               returnresponse.errorMessage = ex.getMessage();
            }
        
        return returnresponse;
    }
    
    public class ResponseObj
    {   @AuraEnabled
       public String state;
        @AuraEnabled
        public List<Contact> contactList;
         @AuraEnabled
        public List<Contact> studentList;
         @AuraEnabled
       public String errorMessage;
        
        
    }
     private static ResponseObj createStudent(CSVObject.CSVField lstobj,List<Contact> contactList)
     {
              List<sObject> lstsObj = new List<sObject>();
            CSVObject.CSVField obj=lstobj;
         List<Contact> insertContactList=new List<Contact>();
            ResponseObj returnresponse=new ResponseObj();
           Id studentRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Students').getRecordTypeId();
           for(Contact cnct:contactList)
           {
           Contact con = new Contact(FirstName=obj.ConFirstName,Email = obj.Email, LastName=obj.ConLastName,accountid=cnct.accountId,Caretaker_Id__c=cnct.Id);
           con.recordtypeid=studentRecordTypeId; 	
           insertContactList.add(con);
           }    
               
         	try
            {
               
            insert insertContactList; 
            returnresponse.state='SUCCESS';
            returnresponse.studentList=insertContactList;
                }
            catch(Exception e)
            {             
                returnresponse.errorMessage=e.getMessage();
                returnresponse.state='Error';
 
            }
 		return returnresponse;
     }
     private static ResponseObj createPERecord(CSVObject.CSVField lstobj,List<Contact> studentList)
     {
            List<sObject> lstsObj = new List<sObject>();
            CSVObject.CSVField obj=lstobj;
            ResponseObj returnresponse=new ResponseObj();
            Id studentEnrollmentTypeId = Schema.SObjectType.hed__Program_Enrollment__c.getRecordTypeInfosByName().get('Student').getRecordTypeId();
            Account academicProgram=[select id,name from account where name =:obj.programCode limit 1]; 
            Program_Grade_Level__c grade=[select id,name from Program_Grade_Level__c where name =:obj.gradeCode limit 1]; 
            School_Year__c schoolYear=[select id,name from School_Year__c where name=:obj.yearCode limit 1];
            Enrollment_Component__c processComponent = [SELECT Id FROM Enrollment_Component__c WHERE Process_Academic_Program__c = :academicProgram.id AND RecordType.Name = :NES_DashboardUtilities.PROCESS_RT];
			List<hed__Relationship__c> relationList=new List<hed__Relationship__c>();
            List<Enrollment_Component_Affiliation__c> affiliationList= new List<Enrollment_Component_Affiliation__c> ();
            Map<Integer,hed__Program_Enrollment__c> programEnrollMap=new Map<Integer,hed__Program_Enrollment__c>();
           integer count=0;
                 for(Contact cont:studentList)
                 {
                hed__Relationship__c relationship = new hed__Relationship__c();
                relationship.hed__Contact__c = cont.id;
                relationship.hed__Status__c = 'Current';
                relationship.hed__RelatedContact__c = cont.Caretaker_Id__c;
                relationship.Recalculate_Sharing__c = true;
                relationship.hed__Type__c =  'Parent';
                relationship.OwnerId = System.Label.NES_Household_OwnerId;
                relationList.add(relationship);     
                hed__Program_Enrollment__c newStudentEnrollment = new hed__Program_Enrollment__c();
                newStudentEnrollment.hed__Contact__c = cont.id;
                newStudentEnrollment.RecordTypeId = studentEnrollmentTypeId;
                newStudentEnrollment.Program_Grade_Level__c=grade.id;
                newStudentEnrollment.hed__Account__c = academicProgram.Id;
                newStudentEnrollment.Start_Year__c = schoolYear.id;
                newStudentEnrollment.Has_Open_Opportunity__c = true;
                programEnrollMap.put(count,newStudentEnrollment);     
                     count++;
                 }
               
         	try
            {
            insert relationList; 
            insert programEnrollMap.values(); 
            for(hed__Program_Enrollment__c programEnroll:programEnrollMap.values() )
            {
             Enrollment_Component_Affiliation__c affiliationRecord = new Enrollment_Component_Affiliation__c();
             affiliationRecord.Enrollment_Component__c = processComponent.Id;
             affiliationRecord.Status__c = 'In Progress';    
             affiliationRecord.Program_Enrollment__c = programEnroll.Id;
             affiliationList.add(affiliationRecord);   
            }
            insert affiliationList; 
            returnresponse.state='SUCCESS';

                }
            catch(Exception e)
            {
                returnresponse.errorMessage=e.getMessage();
                returnresponse.state='Error';
 
            }
 		return returnresponse;
     }
    private static ResponseObj createCommunityUsers(List<CSVObject.CSVField> lstobj){
        List<sObject> lstsObj = new List<sObject>();
        List<Account> accountList=new List<Account>();
        List<User> userList=new  List<User> ();
            //CSVObject.CSVField obj=lstobj;
            ResponseObj returnresponse=new ResponseObj();
            Integer count=0;
            Map<Integer,Account> accountMap=new Map<Integer,Account>();
        	Map<Integer,Contact> contactMap=new Map<Integer,Contact>();
            Id cTRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Caretaker').getRecordTypeId();
        try
        {
        for(CSVObject.CSVField obj: lstobj)
                { 
            Account acct = new Account(Name=obj.ConFirstName,Phone=obj.Phone,ShippingState=obj.state,ShippingPostalCode=obj.zip);
            accountMap.put(count,acct);   
            count++;        
                }
       insert accountMap.values();
      
           count=0;
           for(CSVObject.CSVField obj: lstobj)
           {
            Contact con = new Contact(FirstName=obj.ConFirstName,Email = obj.Email, LastName=obj.ConLastName,MailingState=obj.state,MailingPostalCode=obj.zip);
            con.recordtypeid=cTRecordTypeId; 	
            contactMap.put(count,con);   
            count++;
                   
           }

          count=0;
           for(CSVObject.CSVField obj: lstobj)
           { 
                Contact con=contactMap.get(count);
                Account act=accountMap.get(count);
                if(con!=null&&act!=null)  
                {
                   con.accountid=act.id;
                    contactMap.put(count,con); 
                }                    
               count++;
           }
             insert  contactMap.values();          
                 system.debug('List Size--'+contactMap);
            Id profileId = [Select Id From Profile Where Name = 'Caretaker Community User' LIMIT 1].Id;         
          count=0;
         for(CSVObject.CSVField obj: lstobj)
         {        
            
            // Create community user
             String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
            Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
            String hexDigest = EncodingUtil.convertToHex(hash);  
            Contact con=contactMap.get(count); 
            if(con!=null)
            {
            User communityUser = new User(FirstName = obj.ConLastName, LastName = obj.ConFirstName,
                                          Email = obj.Email,
                                          contactid=con.id,
                                          ProfileId = profileId, UserName = obj.username,MobilePhone=obj.phone,PostalCode=obj.zip,state=obj.state,
                                          Alias =obj.ConLastName, CommunityNickName = hexDigest, TimeZoneSidKey = 'America/New_York',
                                          LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US'
                                         );
             
           userList.add(communityUser); 
            }
          
         //System.setPassword(communityUser.id,obj.password);
          // System.se
			count++;
                }
        if(userList.size()>0)
            {
         insert userList;  
                }
        returnresponse.contactList= contactMap.values();           
        returnresponse.state='SUCCESS';
        }
        catch(Exception e)
        {
               returnresponse.errorMessage=e.getMessage();
                returnresponse.state='Error'; 
        }
        return returnresponse;
      
    }
    
}