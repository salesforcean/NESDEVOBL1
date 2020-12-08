public class ParserBoolean
{
    private List<SyntaxToken> Tokens = new List<SyntaxToken>();
    private List<String> diagnostics = new List<String>();
    private Integer position=0;

    public ParserBoolean(string text) {

        List<SyntaxToken> tokens = new List<SyntaxToken>();

        LexerBoolean lexer = new LexerBoolean(text);
        SyntaxToken token;
        
        do
        {
            token = lexer.NextToken();

            if (token.Kind != SyntaxKind.WhitespaceToken &&
                token.Kind != SyntaxKind.BadToken)
            {
                tokens.Add(token);   
            }
        } while (token.Kind != SyntaxKind.EndOfFileToken);
        
        this.Tokens.addAll(tokens);

        diagnostics.AddAll(lexer.Diagnostics());

    }

    public List<String> Diagnostics() {

        return diagnostics;

    }

    private SyntaxToken Peek(Integer offset)
    {
        
        Integer index = position + offset;
        
        if (index >= this.Tokens.size())
            return this.Tokens[this.Tokens.size() - 1];

        return this.Tokens[index];

    }

    private SyntaxToken Current 
    {
        get 
        {
            return Peek(0);
        }

        set;
        
    }

    private SyntaxToken NextToken()
    {
        SyntaxToken current = this.Current;
        position++;
        return current;
    }

    private SyntaxToken Match(SyntaxKind kind)
    {
        if (this.Current.Kind == kind)
            return NextToken();
        
        diagnostics.add(String.format('ERROR: Unexpected token <{0}>, expected <{1}>', new List<Object>{this.Current.Kind, kind}));
        return new SyntaxToken(kind, this.Current.Position, null, null);
    }

    private ExpressionSyntax ParseExpression()
    {
        return ParseTerm();
    }

    public SyntaxTree Parse()
    {
        ExpressionSyntax expression = ParseTerm();
        SyntaxToken endOfFileToken = Match(SyntaxKind.EndOfFileToken);
        return new SyntaxTree(diagnostics, expression, endOfFileToken);
    }

    private ExpressionSyntax ParseTerm()
    {
        ExpressionSyntax left = ParseFactor();

        while (this.Current.Kind == SyntaxKind.OrToken ||
                this.Current.Kind == SyntaxKind.AndToken)
        {
            SyntaxToken operatorToken = NextToken();
            ExpressionSyntax right = ParseFactor();
            left = new BooleanExpressionSyntax(left, operatorToken, right);
        }

        return left;
    }

    private ExpressionSyntax ParseFactor()
    {
        ExpressionSyntax left = ParsePrimaryExpression();

        // while (this.Current.Kind == SyntaxKind.StarToken ||
        //         this.Current.Kind == SyntaxKind.SlashToken)
        // {
        //     SyntaxToken operatorToken = NextToken();
        //     ExpressionSyntax right = ParsePrimaryExpression();
        //     left = new BinaryExpressionSyntax(left, operatorToken, right);
        // }

        return left;
    }

    private ExpressionSyntax ParsePrimaryExpression()
    {
        if (this.Current.Kind == SyntaxKind.OpenParenthesisToken)
        {
            SyntaxToken left = NextToken();
            ExpressionSyntax expression = ParseExpression();
            SyntaxToken right = Match(SyntaxKind.CloseParenthesisToken);

            return new ParenthesizedExpressionSyntax(left, expression, right);
        }

        SyntaxToken numberToken = Match(SyntaxKind.NumberToken);
        return new NumberExpressionSyntax(numberToken);
    }
}