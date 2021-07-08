public with sharing class deleteObjectRecordsController
{
    private ApexPages.StandardSetController standardController;

    public deleteObjectRecordsController(ApexPages.StandardSetController standardController)
    {
        this.standardController = standardController;
    }

    public PageReference deleteRecords()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        List<Data_Deletion__c> selectedRecords= (List<Data_Deletion__c>) standardController.getSelected();
        // Update records  
        set<string> objectValues= new set<String>(); 
        List< Data_Deletion__c > updateCheckBox= new list<Data_Deletion__c>();
        for(Data_Deletion__c cdt: [select id,objectName__c,OrderOfExecution__c,execute__c from Data_Deletion__c where id=:selectedRecords ]){
            cdt.execute__c= true;
            updateCheckBox.add(cdt );
        }
        if(updateCheckBox.size()>0){
            update updateCheckBox;
            }
           
        for(Data_Deletion__c selectedRecord : [select id,objectName__c,OrderOfExecution__c,execute__c from Data_Deletion__c where id=:selectedRecords and execute__c= true ORDER BY OrderOfExecution__c ASC LIMIT 1]){
            objectValues.add(selectedRecord.objectName__c);
        }       
            if(objectValues.size()>0){
                executeBatchToDeleteRecords.executeBatch(objectValues);
            }
        return null;        
    }
    
    public static void executeNextBatch(){
        set<string> objectValues= new set<String>(); 
         for(Data_Deletion__c selectedRecord : [select id,objectName__c,OrderOfExecution__c,execute__c from Data_Deletion__c where execute__c= true ORDER BY OrderOfExecution__c ASC LIMIT 1]){
            objectValues.add(selectedRecord.objectName__c);
        }       
            if(objectValues.size()>0){
                executeBatchToDeleteRecords.executeBatch(objectValues);
            }
    }
   }