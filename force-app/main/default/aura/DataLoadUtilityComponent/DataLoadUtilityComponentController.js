({
    handleUploadFinished : function(component, event, helper) {
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        var mdateFields=component.get('v.mandatoryFields');
        var columnNames=component.get('v.columnNames');

        if(file) {
            console.log("UPLOADED")
            var reader = new FileReader();
            reader.readAsText(file, 'UTF-8');
            reader.onload = function(evt) {
                var csv = evt.target.result;
                var result = helper.CSV2JSON(component,csv);
                component.set("v.jsonString",result);
                var jsonObj=JSON.parse(result);
                var isErrored=false;
                jsonObj.forEach((element) => {
    for (var key in element) {
      if (element.hasOwnProperty(key)) {
     if(!columnNames.includes(key))
        {
                    isErrored=true;
       }
       else
        {                             
                    if(mdateFields.includes(key)) 
                
                {                
                    if(element[key]!=undefined && element[key].length==0)
                    {isErrored=true;}
                                    
                }
       }
       // console.log(key + ':' + element[key].length);
      }
    }
          
                                
  });

               
                component.set("v.isError", isErrored);
                component.set("v.csvString", csv);
               
            }
        }
    },

    handleGetCSV : function(component, event, helper) {
        var csv = component.get("v.csvString");
        if(csv != null) {
            helper.createCSVObject(component, csv);
        }
        var header = component.get("v.header");
        console.log('header-'+header);
        if(header=='Import Care Taker Records')
        {
                      var isError =component.get("v.isError");
                if(isError)
               alert('Please correct Column Names / Mandatory Fields');
               else
               { 
               component.set("v.isError",false);    
                component.set("v.isImportDisabled",false);  
               }
         }
        else
        component.set("v.isImportDisabled",false);  
    
    },

    cleanData : function(component, event, helper) {
      helper.cleanDataObject(component, event, helper);
    },
gotoURL : function(component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
        "url":"/apex/ImportDataFromCSVPage"
    });
    urlEvent.fire(); },
        handleNext : function(component, event, helper) {
            /*
            var elements = document.getElementsByClassName("hidecard");
               elements[0].style.display = 'none';
                var flow = component.find("opportunityFlow");
             var inputVariables = [
            {
                name : "accountId",
                type : "String",
                value : component.get("v.accountId")
            },{
                name : "contactId",
                type : "String",
                value : component.get("v.contactId")
            }
        ];
                flow.startFlow("Data_Import_Flow",inputVariables);
            */

     },
        
  handleImportClick:function(component, event, helper) {
      var csv = component.get("v.jsonString");
      var header= component.get("v.header"); 
      component.set("v.loaded",false); 
      console.log('header-'+header);
      if(header=='Import Care Taker Records')
      {
      helper.createAccount(component,csv,helper); 

      }
      else if(header=='Import Student Records')
      {
      helper.createStudent(component,csv,helper);
      }   
      else
      {
      helper.createPE(component,csv);
  
      }    
      
        },
            
            openModel: function(component, event, helper) {
      // for Display Model,set the "isOpen" attribute to "true"
      component.set("v.isOpen", true);
   }
})