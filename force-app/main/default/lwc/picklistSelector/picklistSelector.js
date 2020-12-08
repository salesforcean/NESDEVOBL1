import { LightningElement, api, track } from "lwc";
import getPickListValues from "@salesforce/apex/PicklistSelectorController.getAllProcessOptions";
// import getFieldLabel from "@salesforce/apex/PicklistSelectorController.getFieldLabel";

// below code from => https://salesforce.stackexchange.com/questions/277793/fetch-field-label-in-lightning-web-components/277803
// import OBJ_ENROLLMENT_COMPONENT from "@salesforce/schema/Enrollment_Component__c";
// import { getObjectInfo } from "lightning/uiObjectInfoApi";

export default class PicklistSelector extends LightningElement {
  @api ecId;
  @track options;
  @track selectedOption;
  @track isAttributeRequired = false;
  // @api fieldName;
  // @api objectName;
  @track fieldLabelName = "Academic Program";
  connectedCallback() {
    getPickListValues({
      // objApiName: this.objectName,
      // fieldName: this.fieldName
    })
      .then((data) => {
        console.log("::data::", data);
        console.log("testing");
        console.log("::this.ecId::", this.ecId);
        this.options = data;

        if (this.ecId) {
          let optionIsValid = this.options.some(function (item) {
            return item.value === this.ecId;
          }, this);

          console.log("optionIsValid>", optionIsValid);

          if (optionIsValid) {
            this.selectedOption = this.ecId;
          }
        }

        console.log("this.selectedOption>>>", this.selectedOption);
      })
      .catch((error) => {
        this.displayError(error);
      });
    // getFieldLabel({
    //   objName: this.objectName,
    //   fieldName: this.fieldName
    // })
    //   .then((data) => {
    //     this.fieldLabelName = data;
    //   })
    //   .catch((error) => {
    //     this.displayError(error);
    //   });
  }
  selectionChangeHandler(event) {
    this.dispatchEvent(
      new CustomEvent("selected", {
        detail: event.target.value
      })
    );
  }
  displayError(error) {
    this.error = "Unknown error";
    if (Array.isArray(error.body)) {
      this.error = error.body.map((e) => e.message).join(", ");
    } else if (typeof error.body.message === "string") {
      this.error = error.body.message;
    }
  }
  get isPicklistDisabled() {
    return this.options && this.contrFieldValue !== "Select" ? false : true;
  }
}