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

            var appEvent = $A.get("e.c:NES_StudentsLoadedEvent");
            var numberOfStudents = students === null ? 0 : students.length;
            appEvent.setParams({
                numberOfStudents: numberOfStudents
            });
            appEvent.fire();
        });
        $A.enqueueAction(action);
    },
    //added for the US 335364 by Jagadish babu : Begin
    newMethod: function(component, event, helper){
        var action = component.get("c.getAssociatedStudentsInfo");  
         action.setCallback(this, function(response){
             var studentInfo = response.getReturnValue();
             component.set("v.studentsInfo", studentInfo);    
         }); 

    	$A.enqueueAction(action); 
    },
    //added for the US 335364 by Jagadish babu : End
//This below function is not required as part of UX update
    sortStudents: function(component, event, helper, students)
    {
        var sortedStudents = [];
        var eligible = [];
        var eligibleOther = [];
        var ineligible = [];
        students.forEach(student => {
            console.log(JSON.stringify(student) );
            if(student.hasOwnProperty('gradeLevel')){
                var studentGradeLevel = null;
                switch(student.gradeLevel){
                    case 'K':
                        studentGradeLevel = 'Kindergarten';
                        break;
                    case '1':
                        studentGradeLevel = '1st Grade';
                        break;
                    case '2':
                        studentGradeLevel = '2nd Grade';
                        break;
                    case '3':
                        studentGradeLevel = '3rd Grade';
                        break;
                    default:
                        studentGradeLevel = student.gradeLevel + 'th Grade';
                        break;
                }
                student.grade = studentGradeLevel;
            }
            if(student.hasOwnProperty('stages')) {
                student.totalStages = student.stages.length;
                student.completedStages = 0;
                if (student.totalStages > 0) {
                    var originalStages = student.stages;
                    var noOrderStages = [];
                    var index = 0;

                    student.stages = [];

                    originalStages.sort(function(a,b){
                        return a.Order__c - b.Order__c;
                    });

                    for(var i = 0; i < originalStages.length; i++) {
                        student.stages[i] = originalStages[i];
                    }


                    originalStages.forEach(stage => {
                        if(stage.Order__c != null) {
                        } else {
                            noOrderStages.push(originalStages[index])
                        }
                        index++;
                    })


                    if(noOrderStages.length > 0) {
                        noOrderStages.forEach(stage => {
                            student.stages.push(stage);
                        })
                    }

                    student.stages.forEach(stage => {
                        if (stage.Status__c === 'Complete') {
                            student.completedStages = student.completedStages + 1;
                        }
                    })
                }
                student.stageProgress = student.completedStages === 0 ? '0' : ((student.completedStages / student.totalStages) * 100);
                student.stageProgressPercent = student.stageProgress + '%';
            }
			//added for the US 335364 by Jagadish babu : Begin
           if (student.hasOwnProperty('peStatus')) {
                       if (student.peStatus == 'Withdrawn') {
                           student.PEbuttonVisible = 'Yes';
                           student.PEbuttonLabel = 'Continue';
                       } else {
                           student.PEbuttonVisible = 'No';
                           student.PEbuttonLabel = '';
                       }
              }
            //added for the US 335364 by Jagadish babu : End
            if (student.hasOwnProperty('ecaStatus')) {
                switch (student.ecaStatus) {
                    case 'In Progress':
                        student.buttonLabel = 'Continue';
                        student.buttonTarget = '/enrollment';
                        eligible.push(student);
                        break;
                    case 'Inactive':
                        student.buttonLabel = 'Reactivate';
                        student.buttonTarget = '/tickets';
                        eligibleOther.push(student);
                        break;
                    default:
                        student.buttonLabel = 'Contact Us';
                        student.buttonTarget = '/tickets';
                        ineligible.push(student);
                        break;
                }
            }
        });

        if(eligible.length > 0){
            eligible.forEach(student => {
                sortedStudents.push(student);
            })
        }
        if(eligibleOther.length > 0){
            eligibleOther.forEach(student => {
                sortedStudents.push(student);
            })
        }
        if(ineligible.length > 0){
            ineligible.forEach(student => {
                sortedStudents.push(student);
            })
        }
      //  console.log(sortedStudents);
        component.set("v.students", sortedStudents);
        component.set("v.loading", false);
                
        var firstAcc = sortedStudents[0].accountId;
        var schoolidValue;
        if(sortedStudents.length === 1) {
            schoolidValue = firstAcc;
        } else {
            for (var i = 0; i < sortedStudents.length-1; i++) {
                var currentSchool = sortedStudents[i].accountId;
                var nextSchool = sortedStudents[i+1].accountId;
                if (nextSchool !== currentSchool) {
                    schoolidValue =null;
                    break;
                } else {
                    schoolidValue = currentSchool;
                }
            }
        }
        var schoolAppEvent = $A.get("e.c:NES_schoolId");
        schoolAppEvent.setParams({
            "schoolids" : schoolidValue });
        schoolAppEvent.fire();
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