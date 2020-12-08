public class NumberExpressionSyntax extends ExpressionSyntax 
{
    public NumberExpressionSyntax(){}
    
    public NumberExpressionSyntax(SyntaxToken numberToken)
    {
        this.NumberToken = numberToken;
        this.Kind = SyntaxKind.NumberExpression;
    }

    public SyntaxToken NumberToken { get; set; }

    public override List<SyntaxNode> GetChildren()
    {
        return (new List<SyntaxNode>{this.NumberToken});
    }
}