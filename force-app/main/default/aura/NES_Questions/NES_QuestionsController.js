/**
 * Created by triciaigoe on 12/13/18.
 * 2019-10-07 Added Skip For Now #US108687 (Ali Khan)
 * 2019-11-12 updated for #115213 User Story (Maddileti Boya)
 */
({
    doInit: function(component, event, helper)
    {
        helper.initiateQuestions(component, event, helper);
    },

    
    handleSubmit: function (component, event, helper) {
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