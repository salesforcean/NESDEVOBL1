/**
    Queue specifically created to handle Map of ecrNodes for ecrTree generation.
 */
global class ecrNodeQueue {
    
    /**
	* 	@ALIKM 20/apr/2020- commenting out changes

        private List<Map<Id, ecrNode>> nodes;
    
        public ecrNodeQueue() {
            nodes = new List<Map<Id, ecrNode>>();
        }
    
        public Map<Id, ecrNode> dequeue() {
            if (isEmpty()) {
                System.debug('Underflow, program terminated.');
            }
            System.debug('Removing::' + nodes.get(0));
            return nodes.remove(0);
        }
    
        public void enqueue(Map<Id, ecrNode> nds) {
            System.debug('Inserting::' + nds);
            nodes.add(nds);
        }
    
        public Map<Id, ecrNode> peek(){
            if (isEmpty()) {
                System.debug('Underflow, program terminated.');
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
	*/
}