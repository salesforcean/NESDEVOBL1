({
    toggleChange : function(cmp, event, helper) {

        // x.classList.toggle("change");
        console.log('inside togggle change');
        console.log(JSON.stringify(event.currentTarget));
        console.log(JSON.stringify(event.currentTarget.classList));
        console.log(JSON.stringify(event.currentTarget.classList[0]));
        // event.currentTarget.classList.toggle("change");
        
        // $A.util.toggleClass(event.currentTarget.classList, 'change');
        // $A.util.toggleClass(event.currentTarget.classList[0], "change");

        var cmpTarget = cmp.find('changeIt');
        console.log(JSON.stringify(cmpTarget));
        //$A.util.removeClass(cmpTarget, 'changeMe');
        // $A.util.addClass(cmpTarget, "change");

        $A.util.addClass(event.currentTarget.classList[0], "change");

    }
})


// aura:id="changeIt"

// var cmpTarget = cmp.find('changeIt');
// $A.util.removeClass(cmpTarget, 'changeMe');
// $A.util.addClass(cmpTarget, 'changeMe');

// for(var cmp in arr) {
//     $A.util.toggleClass(arr[cmp], cssClass);
// }