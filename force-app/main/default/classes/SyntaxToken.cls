public class SyntaxToken extends SyntaxNode {

    public Integer Position {get; set;}
    public String text {get; set;}
    public Object value {get; set;}
        
    public SyntaxToken(){} 
    
    public SyntaxToken(SyntaxKind kind, Integer position, String text, Object value){
        this.Kind = kind;
        this.position = position; 
        this.text = text;
        this.value = value;
    }

    public override List<SyntaxNode> GetChildren() {
        return new List<SyntaxNode>();
    }
}