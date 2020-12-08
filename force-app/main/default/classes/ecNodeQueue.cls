/**
    Queue specifically created to handle Map of ecNodes for ecrTree generation.
 */
global class ecNodeQueue {

    private List<Map<Id, ecNode>> nodes;

    public ecNodeQueue() {
        nodes = new List<Map<Id, ecNode>>();
    }

    public Map<Id, ecNode> dequeue() {
        if (isEmpty()) {
            // System.debug('Underflow, program terminated.');
        }
        // System.debug('Removing::' + nodes.get(0));
        return nodes.remove(0);
    }

    public void enqueue(Map<Id, ecNode> nds) {
        // System.debug('Inserting::' + nds);
        nodes.add(nds);
    }

    public Map<Id, ecNode> peek(){
        if (isEmpty()) {
            // System.debug('Underflow, program terminated.');
            return null;
        }
        return nodes.get(0);
    }

    public Integer size() {
        return nodes.size();
    }

    public Boolean isEmpty() {
        return (nodes.size()==0);
    }

}