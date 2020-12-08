public class BooleanExpressionSyntax extends ExpressionSyntax
{
    public BooleanExpressionSyntax() {}
    
    public BooleanExpressionSyntax(ExpressionSyntax left, SyntaxToken operatorToken, ExpressionSyntax right)
    {
        this.Left = left;
        this.OperatorToken = operatorToken;
        this.Right = right;
        this.Kind = SyntaxKind.BooleanExpression;
    }

    public ExpressionSyntax Left { get; set;}
    public SyntaxToken OperatorToken { get; set;}
    public ExpressionSyntax Right { get; set;}

    public override List<SyntaxNode> GetChildren()
    {
        return (new List<SyntaxNode>{ this.Left, this.OperatorToken, this.Right});
    }
}