/**
 * Default tree-grid keyField
 */
export const KEYFIELD = "nodeId";

/**
 * Columns definition
 */
export const ECR_TREE_COLUMNS_DEFINITION = [
  {
    label: "EC Name",
    fieldName: "ecNameLink",
    type: "url",
    // initialWidth: 350,
    typeAttributes: { label: { fieldName: "name" }, target: "_blank" }
  },
  {
    label: "Type",
    fieldName: "kind",
    type: "text",
    initialWidth: 100,
    typeAttributes: {
      linkify: "true"
    }
  },
  {
    label: "Order",
    fieldName: "order",
    type: "number",
    initialWidth: 100
  },
  {
    label: "Process/ECR External ID",
    fieldName: "ecrIdLink",
    type: "url",
    initialWidth: 200,
    typeAttributes: {
      label: { fieldName: "ecrExtId" },
      target: "_blank"
    }
  },
  {
    label: "Assignment Logic",
    fieldName: "logicAssignment",
    type: "text",
    initialWidth: 200,
    typeAttributes: {
      linkify: "true"
    }
  },
  {
    label: "Completion Logic",
    fieldName: "logicCompletion",
    type: "text",
    initialWidth: 200,
    typeAttributes: {
      linkify: "true"
    }
  },
  {
    label: "Level",
    fieldName: "level",
    type: "number",
    initialWidth: 70
  }
];