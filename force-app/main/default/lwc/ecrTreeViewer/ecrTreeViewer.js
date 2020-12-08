/**
 * 
 * PENDING Items as on: 18May2020: 
  1. PicklistChangeEvent, bubble it up (DONE)
  2. ExpandAll / CollapseAll button
  3. Hook it up to the EC page. (WIP)
  4. testClass (DONE)
  5. error/blank screen, show messages
  
 *
**/

import { LightningElement, track, api } from "lwc";
import getProcessECById from "@salesforce/apex/ecrTreeViewerController.getProcessECById";

export default class EcrTreeViewer extends LightningElement {
  @api recordId;
  @track ecId;
  @track ecProcessName;

  connectedCallback() {
    getProcessECById({
      ecId: this.recordId
    })
      .then((data) => {
        // if (data) {
        this.ecId = data.Id;
        this.ecProcessName = data.Process_Academic_Program__r.Name;
        // }
      })
      .catch((error) => {
        // this.displayError(error);
        console.log("error>>", error);
      });

    console.log("recordId>>>", this.recordId);
  }

  handleChange(event) {
    this.ecId = event.detail;
  }
}