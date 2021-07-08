/**
 * Created by triciaigoe on 12/13/18.
 * 2019-10-07 Added Skip For Now #US108687 (Ali Khan)
 * 2019-11-12 updated for #115213 User Story (Maddileti Boya)
 */
({
    doInit: function(component, event, helper)
    {
        component.set("v.formError",false);
        helper.initiateQuestions(component, event, helper);
        
    },
    
    
    handleSubmit: function (component, event, helper) {
        //Added by Jagadeesh for the Task :341992
        var Sname = component.get('v.sectionName');
        var ahi = component.get('v.AHIIncomeSubmitDate');
      	  if(Sname == "Family Income Form" && ahi == null ){
            component.set("v.formError",true);
            component.set("v.formErrorMsg",'You cannot submit this page without completing the form.');  
            return false;   
        }
        else{
            component.set("v.formError",false);
           component.set("v.formErrorMsg","");  
        }   
        // Ended By Jagdeesh 
        
       
        console.log('i am here');
        
        helper.getformName(component, event, helper,'Submit');//Swapna:For GTM
        console.warn('In submit');
        component.set("v.spinner", true);
        var groupComponents = component.find("groupComp");
        var allValidated = true;
        if(groupComponents) {
            if(Array.isArray(groupComponents)) {
                for (var i = 0; i < groupComponents.length; i++) {
                    console.log('in array group');
                    var responseBoolean = groupComponents[i].validateFields(true);
                    console.log('responseBoolean=='+responseBoolean);
                    allValidated = allValidated && responseBoolean;
                }
            } else {
                console.log('in single group');
                var responseBoolean = groupComponents.validateFields(true);
                console.log('responseBoolean', responseBoolean);
                allValidated = allValidated && responseBoolean;
            }
        }
        if(allValidated) {
            console.log('handleSubmit');
            helper.fireAppEvent(component, event, helper);
            
        } else {
            component.set("v.spinner", false);
        }
        
    },
    //Added by Jagadeesh for the Task :341992
    fifRefresh: function(component, event, helper){
        helper.getAhiAckUpdate(component, event, helper);
    },
    //Ended by Jagadeesh for the Task :341992
    
    updateValidationMessages: function(component, event, helper){
        helper.resetNoRequiredValidationErrorIfNeeded(component, event, helper);
    },
    runAssignmentRegardlessOfCriteria: function(component, event, helper) {
        component.set("v.spinner", true);
        component.set("v.runCompletion", false);
        helper.assignmentEvaluation(component, event, helper);
    },  
    runAssignment: function(component, event, helper) {
        console.log($A.util.hasClass(event.getSource(), "hasCriteria"));
        if($A.util.hasClass(event.getSource(), "hasCriteria")) {
            component.set("v.spinner", true);
            component.set("v.runCompletion", false);
            //Added by Jagadeesh for the Task :341992
            var Sname = component.get('v.sectionName');
            if(Sname == "Family Income Form"){
                helper.getAHIIncomeFormSubmitDate(component, event, helper);
                var ahiSubmitDate = component.get('v.AHIIncomeSubmitDate');
                console.log('Ahi submit date' + ahiSubmitDate);
                if(ahiSubmitDate != null){
               		 $A.get('e.force:refreshView').fire();
               }
            }
            //Ended by Jagadeesh for the Task :341992
            helper.assignmentEvaluation(component, event, helper);
        }
    },
    
    goToOverview: function (component, event, helper) {
        helper.goBack(component, event, helper);
    },
    validateDate: function(component, event, helper) {
        console.log('We are here ready to remove the error');
        helper.validateDate(component, event, helper);
    },
    // #US108687 (Ali Khan)
    skipForNow: function(component, event, helper) {
        console.log('skipForNow');
        helper.skipForNow(component, event, helper);
    },
    // added by maddileti for #115213 User Story on 2019-11-12
    openModel: function(component, event, helper) {
        // Set isModalOpen attribute to true
        component.set("v.isModalOpen", true);
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
    
    submitDetails: function(component, event, helper) {
        // Set isModalOpen attribute to false
        component.set("v.isModalOpen", false);
    } 
})