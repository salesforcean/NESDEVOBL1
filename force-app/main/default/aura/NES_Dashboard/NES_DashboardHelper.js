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
           console.log(students); 
            var state = response.getState();
            if(state === "SUCCESS"){
                if(students !== null && students.length > 0) {
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

    }
    

});