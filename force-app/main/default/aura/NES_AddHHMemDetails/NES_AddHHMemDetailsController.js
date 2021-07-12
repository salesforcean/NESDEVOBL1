({
    
    doInit : function(component, event, helper) {
        component.set("v.screen", 0);
        let formData={};
        component.set("v.formData", formData);
        let suffixOptions=[
            {value:'', label:'--None--'},
            {value:'I', label:'I'},
            {value:'II', label:'II'},
            {value:'III', label:'III'},
            {value:'IV', label:'IV'},
            {value:'Jr.', label:'Jr.'},
            {value:'Sr.', label:'Sr.'},
            {value:'V', label:'V'},
            {value:'VI', label:'VI'},
            {value:'VII', label:'VII'}
                        
        ];
        component.set("v.suffixOptions", suffixOptions);
        let phoneTypeOptions=[
            {value:'', label:'--None--'},
            {value:'Home', label:'Home'},
            {value:'Work', label:'Work'},
            {value:'Mobile', label:'Mobile'},
            {value:'Other', label:'Other'}
        ];
        component.set("v.phoneTypeOptions", phoneTypeOptions);
     
    },
    
    handleInput: function(component, event, helper) {
        var ev = event.getSource().get("v.name");
        },
  
    navigatetoNext: function(component, event, helper) {


        if(event.getSource().getLocalId() == "Next"){
            var scr = component.get("v.screen");
            //alert(component.find("fId").get("v.value"));
            if(component.find("fId").get("v.value") && component.find("lid").get("v.value") && component.find("eid").get("v.value")){
                scr++;
                component.set("v.screen", scr);
            }
        }else if(event.getSource().getLocalId() == "Prev"){
                var scr = component.get("v.screen");
                scr--;
                component.set("v.screen", scr);
        }else if(event.getSource().getLocalId() == "Next1"){
            // Do a Call to Apex Controller to Check if an existing Contact present with same details
            // If Yes re-direct to Screen 3 else re-direct to Screen2
            var scr = component.get("v.screen");
            var myAction = component.get("c.chkExistCnts");
            component.set('v.showSpinner', true);
            myAction.setParams({houseHoldMemberData : JSON.stringify(component.get("v.formData"))});
            myAction.setCallback(this, function(response) {
                 component.set('v.showSpinner', false);
            if(response.getState() === "SUCCESS") {
               
                var resp = response.getReturnValue();
                
                if(resp.status == 'ExistingContact'){
                       scr++; 
                    
                    component.set("v.screen", scr);
                    component.set('v.existingRecordType',resp.recordType);
                }
                else if(resp.status == 'New Contact Created'){
                   scr++;
                   scr++;
                  
                   component.set("v.screen", scr); 
                }
            }
            else{
                    console.log('In Failure ->'+ response.getState());
                }
            }); 
            $A.enqueueAction(myAction);
        }else if(event.getSource().getLocalId() == "Next2"){
            var scr = component.get("v.screen");
            var myAction = component.get("c.createAddlHHMemContact");
              component.set('v.showSpinner', true);
            myAction.setParams({ houseHoldMemberData : JSON.stringify(component.get("v.formData"))});
            myAction.setCallback(this, function(response) {
            if(response.getState() === "SUCCESS") { 
                  component.set('v.showSpinner', false);          
                var resp = response.getReturnValue();
              
                if(resp == 'New Contact Created'){
                   scr++; 
                
                   component.set("v.screen", scr);
                }
            }
            else{
                    console.log('In Failure ->'+ response.getState());
                }
            }); 
            $A.enqueueAction(myAction); 
        }
        
    },
    
    

    closeModal:function(component,event,helper){    
        $A.get("e.force:closeQuickAction").fire();
    },
    
})