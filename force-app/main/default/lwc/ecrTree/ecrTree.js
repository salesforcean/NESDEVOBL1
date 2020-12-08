import { LightningElement, track, api, wire } from "lwc";
import getProcessTree from "@salesforce/apex/ecrTreeImportExport.getProcessTree";
import { NavigationMixin } from "lightning/navigation";
import { KEYFIELD, ECR_TREE_COLUMNS_DEFINITION } from "./ecrTreeData";

export default class EcrTree extends NavigationMixin(LightningElement) {
  @api rootId;

  keyField = KEYFIELD;
  gridColumns = ECR_TREE_COLUMNS_DEFINITION;

  @track processData;
  @track currentExpandedRows;
  @track isLoading = false;
  @track error;
  gridExpandedRows;

  @wire(getProcessTree, { rootId: "$rootId" })
  wireProcessData({ error, data }) {
    if (data) {
      let tempjson = JSON.parse(
        JSON.stringify(data).split("children").join("_children")
      );
      this.processData = new Array(tempjson);
      this.recurse(this.processData);
      this.gridExpandedRows = new Array(this.processData[0]["nodeId"]);
    } else if (error) {
      this.error = error;
    }
  }

  // build links dynamically
  recurse(obj) {
    for (let k in obj) {
      if (obj[k])
        if (typeof obj[k] == "object") {
          if (obj[k].length == 0) {
            delete obj[k];
          } else {
            this.recurse(obj[k]);
          }
        } else {
          if (obj[k]) {
            switch (k) {
              case "ecId":
                obj["ecNameLink"] = "/" + obj[k];
                break;
              case "ecrId":
                obj["ecrIdLink"] = "/" + obj[k];
                break;
              default:
                break;
            }
          }
        }
    }
  }

  // retrieve the list of rows currently marked as expanded
  getCurrentExpandedRows() {
    const treegrid = this.template.querySelector(".lgc-example-treegrid");
    this.currentExpandedRows = treegrid.getCurrentExpandedRows().toString();
  }
}