({
    createCSVObject : function(cmp, csv) {
        var action = cmp.get('c.getCSVObject');
        action.setParams({
            csv_str : csv
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
	    if(state == "SUCCESS") {
		cmp.set("v.csvObject", response.getReturnValue());
	    }
        });
        $A.enqueueAction(action);
    },
    CSV2JSON: function (component,csv) {
        //  console.log('Incoming csv = ' + csv);
        
        //var array = [];
        var arr = []; 
        
        arr =  csv.split('\n');
        //console.log('Array  = '+array);
        // console.log('arr = '+arr);
        arr.pop();
        var jsonObj = [];
        var headers = arr[0].split(',');
        for(var i = 1; i < arr.length; i++) {
            var data = arr[i].split(',');
            var obj = {};
            for(var j = 0; j < data.length; j++) {
                obj[headers[j].trim()] = data[j].trim();
                //console.log('obj headers = ' + obj[headers[j].trim()]);
            }
            jsonObj.push(obj);
        }
        var json = JSON.stringify(jsonObj);
        //console.log('json = '+ json);
        return json;
        
        
    },
    createAccount : function (component,jsonstr,helper){
        console.log('jsonstr' + jsonstr);
        var action = component.get('c.insertData');
        //  alert('Server Action' + action);    
        action.setParams({
            strfromle : jsonstr,section : '1'
        });
        action.setCallback(this, function(response) {
                component.set("v.loaded",true); 

            var state = response.getState();
            if (state === "SUCCESS") {             
                var result=response.getReturnValue();
                console.log('result--'+JSON.stringify(result));

                if(result.state=== "SUCCESS")
                {
                component.set("v.isImportDisabled",true);
                component.set("v.isNextDisabled",false);
                component.set("v.contactList",result.contactList);
                component.set("v.header",'Import Student Records');    
                alert("User Created Sucessfully!!");    
                helper.cleanDataObject(component, event, helper);
                var fileInput = component.find("file").getElement();
                fileInput =[];   
    
   
                }
                else
                {
                var result=response.getReturnValue();
                alert("Error Processing Request!! "+result.errorMessage);   
                }
                  //window.location.href = result;      
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                    //alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
        createStudent : function (component,jsonstr,helper){
        var action = component.get('c.insertData');
        var contactNameList=component.get("v.contactList");
            console.log('jsonstr-'+jsonstr+'contactNameList-'+JSON.stringify(contactNameList));
        action.setParams({
            strfromle : jsonstr,section:'2',contactList:contactNameList
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
             var res=response.getReturnValue();
            console.log('res-'+JSON.stringify(res));
            component.set("v.loaded",true); 
            if (state === "SUCCESS") {             
                var result=response.getReturnValue();
                console.log('result--'+JSON.stringify(result));

                if(result.state=== "SUCCESS")
                {
               
                component.set("v.header",'Import Program Enrollment Records');    
                alert("Student Created Sucessfully!!");  
                component.set("v.isImportDisabled",true);
                component.set("v.studentList",result.studentList);   
               helper.cleanDataObject(component, event, helper);

                }
                else
                {
               var result=response.getReturnValue();
                alert("Error Processing Request!! "+result.errorMessage);   
                }
                  //window.location.href = result;      
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                    //alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);    
        
    },
    createPE : function(component, jsonstr){
        var action = component.get('c.insertData');
       
        var studentList=component.get("v.studentList");

        action.setParams({
            strfromle : jsonstr,section:'3',contactList:studentList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            component.set("v.loaded",true); 
            if (state === "SUCCESS") {             
                var result=response.getReturnValue();
                console.log('result--'+JSON.stringify(result));

                if(result.state=== "SUCCESS")
                {
                
                alert("Program Enrollment Created Sucessfully!!");  
                component.set("v.isImportDisabled",true);

                }
                else
                {
                
               var result=response.getReturnValue();
                alert("Error Processing Request!! "+result.errorMessage);   
                }
                  //window.location.href = result;      
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        //console.log("Error message: " + errors[0].message);
                    }
                } else {
                    //console.log("Unknown error");
                    //alert('Unknown');
                }
            }
        }); 
        
        $A.enqueueAction(action);  

    },
     cleanDataObject : function(component, event, helper) {
        component.set("v.csvString", null);
        component.set("v.csvObject", null);
    }
})