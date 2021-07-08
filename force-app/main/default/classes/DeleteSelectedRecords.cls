global class DeleteSelectedRecords implements Database.Batchable<sObject>{//, Database.Stateful {

    private String strParameter;

    public DeleteSelectedRecords(String strParam) {
        strParameter = strParam;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
    if(strParameter =='user'){
        return Database.getQueryLocator('Select Id, IsActive, IsPortalEnabled from User where IsPortalEnabled= true and isactive=true');
    }else 
        return Database.getQueryLocator('Select Id From ' +strParameter + ' Where createddate <='+ label.deleteData );
     }

    global void execute(Database.BatchableContext BC, List<Sobject> scope) {
    system.debug('@@@scope'+scope);
    if(strParameter == 'user'){
    list<user> updateUser= new list<user>();
    for(User u : (List<user>) scope){
          if(u.IsActive || u.IsPortalEnabled ){
            u.IsActive = false;
            u.IsPortalEnabled = false;
            updateUser.add(u);
  }
  if(updateUser.size()>0){ 
      update updateuser;
       Database.emptyRecycleBin(scope);  
    } 
    }
    }    
    else {
    delete scope;
    Database.emptyRecycleBin(scope);  
     }
    Data_Deletion__c updateRecord= [select id,execute__c,ObjectName__c from Data_Deletion__c where ObjectName__c=:strParameter];
        updateRecord.execute__c= false;
        update updateRecord;
    }  
    
    global void finish(Database.BatchableContext BC) {
    }
}