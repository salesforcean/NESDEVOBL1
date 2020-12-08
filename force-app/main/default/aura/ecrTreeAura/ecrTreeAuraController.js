({
  gotoURL: function (component, event, helper) {
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      url: "/lightning/n/ecr_tree_viewer"
    });
    urlEvent.fire();
  }
});