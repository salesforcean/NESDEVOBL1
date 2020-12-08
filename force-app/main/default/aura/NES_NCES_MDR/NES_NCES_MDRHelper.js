/**
 * Created by triciaigoe on 1/24/19.
 * Change Log: 
 * 2019-04-10 #109932 User Story Bug # 113012(Anitha P)
 */
({

    verify: function(thingToVerify){
      var verified = true;
      var errorfocused = false;

      if(thingToVerify.constructor === Array) {
          verified = thingToVerify.reduce(
              function (validSoFar, inputCmp) {
                  inputCmp.showHelpMessageIfInvalid();
                 //Start-User Story Bug # 113012(Anitha P)
                    //Checking each filed valid or missing and then focus 
                    if ( !errorfocused && (!inputCmp.get('v.validity').valid || inputCmp.get('v.validity').valueMissing)){
                        inputCmp.focus();		
                        errorfocused = true;
                    }
                   //End-User Story Bug # 113012(Anitha P)   
                  return validSoFar && inputCmp.get('v.validity').valid && !inputCmp.get('v.validity').valueMissing;
              }, true);
      } else {
          verified = thingToVerify.get('v.validity').valid && !thingToVerify.get('v.validity').valueMissing
         
      }
               
      return verified;
    },

    verifyQuestion: function(component, event, helper){

        console.log('In verify');
        var isManual = component.get("v.isManualAddress");
        var errorfocused = false;
        var verified = true;

        var schoolSelectionNeeded = component.get("v.schoolSelectionNeeded");

        if(isManual || !schoolSelectionNeeded) {
            //Check to see if all manual fields have been created correctly.

            console.log('schoolSelection is not needed');

            if(schoolSelectionNeeded) {
                console.log('somehow in here');
                verified = helper.verify(component.find('formItem'));
            }
           
            console.log('here');
            console.log(component.find('fieldId'));

            verified = verified && helper.verify(component.find('fieldId'));
            console.log('Verified is: ' + verified);
        } else {
            var indexOfSelectedSchool = component.get("v.selectedSchool");
            console.log("This is the index of the school: ", indexOfSelectedSchool);
            if(indexOfSelectedSchool != null){
                console.log('A school was selected');
                verified = component.find('fieldId').reduce(
                    function (validSoFar, inputCmp) {
                        inputCmp.showHelpMessageIfInvalid();  
                    //Start-User Story Bug # 113012(Anitha P)
                    //Checking each filed valid or missing and then focus 
                    if ( !errorfocused && (!inputCmp.get('v.validity').valid || inputCmp.get('v.validity').valueMissing)){
                        inputCmp.focus();		
                        errorfocused = true;
                    }
                   //End-User Story Bug # 113012(Anitha P) 
                        return validSoFar && inputCmp.get('v.validity').valid && !inputCmp.get('v.validity').valueMissing;
                    });

            } else {
                //We need them to fill in the fields if they never selected a school to get the list to display:

                var completedSearch = component.get("v.completedSearch");

                if(completedSearch) {
                    //They haven't selected a school, so let's add error coloring to the text showing the list, and the text showing
                    //how to enter manually
                    $A.util.addClass(component.find("manualAddressLeadText"), "slds-text-color_error");
                    
                    //Check if the search returned results
                    var schools = component.get("v.schools");
                    if(schools.length > 0) {
                        $A.util.addClass(component.find("schoolListText"), "slds-text-color_error");
                        
                    }
                   
                    verified = false;

                } else {
                    //No fields were likely filled in, so mark the intro text with error coloring
                    $A.util.addClass(component.find("introText"), "slds-text-color_error");
                    verified = false;
                }
                 
               //Start-User Story Bug # 113012(Anitha P)
                
                var formElements = component.find("formItem");
               if (!verified){
                for(var i = 0; i < formElements.length; i++){
                    if($A.util.isEmpty(formElements[i].targetField)){
                       formElements[i].focus();
                        break;
                     }
                  }
            }
               //End-User Story Bug # 113012(Anitha P)
                
            }
              
        }

        console.log("The value of 'verified' is: ", verified);
       
        return verified;
    },

    connectSchoolEntryToFields: function(component, event, helper) {
        console.log('Connecting fields');
        console.log(selectedSchool);

        var questions = component.get("v.questions");

        var isManualAddress = component.get("v.isManualAddress");
        var schoolSelected = false;

        var selectedSchool = {};

        var manualSchoolAddress = {};

        if(isManualAddress) {
            manualSchoolAddress = {
                "streetAddress":component.get('v.schoolAddress'),
                "stateAbbr":component.get('v.schoolState'),
                "schoolName":component.get('v.schoolName'),
                "postalCode":component.get('v.schoolZip'),
                "districtName":component.get('v.schoolDistrict'),
                "countryAbbr":component.get('v.schoolCountry'),
                "city":component.get('v.schoolCity')};

            selectedSchool = manualSchoolAddress;
        } else {
            var selectedIndex = component.get("v.selectedSchool");
            if(selectedIndex != null) {
                selectedSchool = component.get("v.schools")[selectedIndex];
                schoolSelected = true;
            }
        }


        if(isManualAddress || schoolSelected) {
            Object.keys(selectedSchool).forEach(function(key, index){
                console.log(key);
                console.log('Grabbing key');
                var index = questions.findIndex(function(question){return question.apiMapping === key});
                //console.warn(index);
                if(index != -1) {
                    questions[index].targetField = selectedSchool[key];
                    console.log(selectedSchool[key]);
                    console.log(questions[index]);
                }

            });

            console.log(questions);
            component.set("v.questions", questions);
        }

    },

    connectAnswerTargetsToEntry: function(component, event, helper) {

        var apiMappings = ['schoolName','streetAddress','city','districtName','stateAbbr','postalCode','countryAbbr','faxNumber', 'phoneNumber'];
        var selectedSchool = {schoolName: '', streetAddress: '', city: '', districtName: '', stateAbbr: '', postalCode: '', faxNumber: ''};

        var questions = component.get("v.questions");

        var schoolIsRequired = questions.findIndex(function(question){return question.apiMapping != null});

        component.set("v.schoolSelectionNeeded", schoolIsRequired != -1);

        Object.keys(selectedSchool).forEach(function(key, index){
            //console.log(key);
            //console.log('Grabbing key');
            var index = questions.findIndex(function(question){return question.apiMapping === key});
            //console.warn(index);
            if(index != -1 && !$A.util.isEmpty(questions[index].targetField)) {
              selectedSchool[key] = questions[index].targetField;
                //console.log(selectedSchool[key]);
                //console.log(questions[index]);
            }

        });

        if(selectedSchool.schoolName != '') {
            component.set('v.schools', [selectedSchool]);
            component.set('v.selectedSchool', 0);
            component.set('v.schoolName', selectedSchool.schoolName);
            component.set('v.schoolCity', selectedSchool.city);
            component.set('v.schoolState', selectedSchool.stateAbbr);
        }
    },

    getStateData: function (component, event, helper) {

        var action = component.get('c.getStates');
        action.setCallback(this, function(response){
            console.log('NCES_MDRHelper::c.getStates callback');
            console.log(response);
            console.log(JSON.parse(JSON.stringify(response)));
            console.log(response.getReturnValue());
            console.log('AFter all that');
            component.set("v.states", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },

    runSearchForSchool: function(component, event, helper) {

        var action = component.get('c.searchSchool');

        action.setParams({
            'previousSchoolName': component.get('v.schoolName'),
            'previousSchoolCity': component.get('v.schoolCity'),
            'previousSchoolState': component.get('v.schoolState'),
        });

        console.log('About to fire search');

        action.setCallback(this, function(response){
            console.log('NCES_MDRHelper::c.searchSchool callback');
            var schools = JSON.parse(response.getReturnValue());
            console.log(schools);
            component.set("v.schools", schools);
        });
        $A.enqueueAction(action);
    },

    checkArrayForEquality: function(array1, array2) {
        var equal = true;

        if(array1.length != array2.length){
            console.error('not the same length');
            return false;
        }

        for(var i = 0; i < array1.length; i++){
            console.log(array1[i].questionId);
            console.log(array2[i].questionId);
            equal = equal && array1[i].questionId === array2[i].questionId;
            // for(var key in array1[i]){
            //     if(key !== 'picklistValues' && key !== 'targetField') {
            //         equal = equal && (array1[i][key] === array2[i][key]);
            //     }
            // }
        }

        return equal;

    },
    runAssignment: function(component, event, helper, questions, inInit){
        console.log('Run assignment');
        console.error('We are running assignment!');
        var action = component.get('c.evaluateQuestions');

        action.setParams({
            'enrollmentId': component.get('v.programEnrollmentId'),
            'questions':questions,
            'sectionComponentId':component.get('v.questionGroupId')
        });

        action.setCallback(this, function(response){
            console.log('NCES_MDRHelper::c.evaluateQuestions callback');
            console.log(response);
            console.log(response.getError());
            console.log(response.getReturnValue());
            
            var firstMDRFieldFound = false;
             
            
            var questions = response.getReturnValue();
            
            
            
            if(questions.length > 1){
                questions.sort(function(a, b){
                    return a.order - b.order
                });
            }

            questions.forEach(function(question){
                question.parentId = component.get('v.questionGroupId');
                question.mdrField = !$A.util.isEmpty(question.apiMapping);
                console.log('clearing targetfiled');
                if(inInit){
                    //Have a look here Added by Jagadeesh
                   //  questions.targetfield = "- select one -"; 						//Existing
                    questions.targetfield = "";            
                    //End
            }
                if(question.mdrField && !firstMDRFieldFound){
                    question.firstMDRField = true;
                    firstMDRFieldFound = true;
                }
                if(question.hasOwnProperty('picklistValues') && question.picklistValues.length > 1){
                    question.picklistValues.sort(function(a, b){
                        return a.order - b.order
                    });
                }
            });

            console.log(questions);
           
            var currentQuestions = component.get("v.questions");

            component.set("v.spinner", false);

            if(!inInit) {
                component.getEvent("tellParentItNeedsToRunAssignment").fire();
            }


            if(!helper.checkArrayForEquality(currentQuestions, questions)){
                console.warn('NCES_MDRHelper::set v.questions');
                component.set("v.questions", questions);
            } else {
                console.error('They were the same anyway');
            }




            helper.connectAnswerTargetsToEntry(component, event, helper);



        });

        component.set("v.spinner", true);

        $A.enqueueAction(action);
    }
})