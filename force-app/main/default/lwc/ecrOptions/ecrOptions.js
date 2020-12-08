import { LightningElement, api, track } from "lwc";
import getProcessOptions from "@salesforce/apex/ecrTreeViewerController.getProcessOptions";

export default class ComboboxRequired extends LightningElement {
  @api value;
  @api labelText;
  @api placeholderText;

  @track options;

  connectedCallback() {
    getProcessOptions({})
      .then((data) => {
        console.log("::data::", data);
        this.options = data;
      })
      .catch((error) => {
        this.displayError(error);
      });
  }

  handleChange(event) {
    event.preventDefault();
    const selectEvent = new CustomEvent("select", {
      detail: event.detail.value
    });
    this.dispatchEvent(selectEvent);
  }
}