public class ParenthesizedExpressionSyntax extends ExpressionSyntax 
{
    public ParenthesizedExpressionSyntax(){}

    public ParenthesizedExpressionSyntax(SyntaxToken openParenthesisToken, ExpressionSyntax expression, SyntaxToken closeParenthesisToken)
    {
        this.OpenParenthesisToken = openParenthesisToken;
        this.Expression = expression;
        this.CloseParenthesisToken = closeParenthesisToken;
        this.Kind = SyntaxKind.ParenthesizedExpression;
    }

    public SyntaxToken OpenParenthesisToken { get; set; }
    public ExpressionSyntax Expression { get; set; }
    public SyntaxToken CloseParenthesisToken { get; set; }

    public override List<SyntaxNode> GetChildren()
    {
        return (new List<SyntaxNode>{ this.OpenParenthesisToken, this.Expression, this.CloseParenthesisToken});
    }
}