/**
 * Created by karolbrennan on 11/21/18.
 */
({
    getStudents: function(component, event, helper)
    {
        window.scrollTo(0, 0);
        var action = component.get("c.getAssociatedStudentsInfo");       
        action.setCallback(this, function(response){
            var students = response.getReturnValue();
           console.log("@@@###@@@@"+JSON.stringify(students)); 
            var state = response.getState();
            if(state === "SUCCESS"){
                if(students !== null && students.length > 0) {
                    console.log(JSON.stringify(students));
                    component.set("v.studentsInfo",students);
                }
            } else {
                var error = response.getError();
                console.log("Error: ", error);
            }
            //added for the defect 342198 Begin : Jagadeesh bokam
   				 component.set("v.loading", false);
            //added for the defect 342198 End : Jagadeesh bokam
            var appEvent = $A.get("e.c:NES_StudentsLoadedEvent");
            var numberOfStudents = students === null ? 0 : students.length;
            appEvent.setParams({
                numberOfStudents: numberOfStudents
            });
            appEvent.fire();
        });
        $A.enqueueAction(action); 
    },
        //This function is not required as part of UX update
    stepHover: function(component, event, helper)
    {
        var classes = event.currentTarget.getAttribute('class');
        var hoveringOverCurrentInProgress = classes.indexOf('slds-is-active') >= 0;
        var notAllCompleted =  document.getElementsByClassName('slds-is-active').length > 0;
        var completedItems = document.getElementsByClassName('slds-is-completed');
        var hoveringOverLastCompleted = event.currentTarget == completedItems[completedItems.length - 1];
        if((!hoveringOverCurrentInProgress && notAllCompleted) || (!notAllCompleted && !hoveringOverLastCompleted)) {
            $A.util.toggleClass(event.currentTarget, 'showItem');
            if(notAllCompleted) {
                $A.util.toggleClass(event.currentTarget.parentElement.getElementsByClassName('slds-is-active')[0], 'hideItem');
            } else {
                $A.util.toggleClass(completedItems[completedItems.length - 1], 'hideItem');
            }
        }
    },

    // Added for DEFECT 494868- DK
    helperRefreshOpenApp : function(component, event, helper, peId){
        var action = component.get("c.refreshOPenAppPortal"); 
        action.setParams({
            programEnrollmentId : peId
        });
        action.setCallback(this, function(a) {
           var state = a.getState();
            if (state === "SUCCESS") {

                var rfrsh = a.getReturnValue();
                component.set("v.refreshOpen", rfrsh);
                var openAppRefresh = component.get("v.refreshOpen");
                if(openAppRefresh == 'Refresh'){
                    setTimeout(function(){ $A.get('e.force:refreshView').fire(); }, 5000);  //Added for Open Application User story 451172 -->DK
                }
            }
        });
    $A.enqueueAction(action);
    },
		// End for DEFECT 494868- DK
		
		
		// Added for DEFECT 495363- DK 
    helperNonOpenApp : function(component, event, helper, peId){
        var action = component.get("c.nonOpenAppUpdate"); 
        action.setParams({
            peId : peId
        });
        action.setCallback(this, function(a) {
           var state = a.getState();
            if (state === "SUCCESS") {
               // alert('Updated successfully');
                console.log('ECA Open App updated successfully');
            }
        });
    $A.enqueueAction(action);
    }
    
    // End for DEFECT 495363- DK 
});