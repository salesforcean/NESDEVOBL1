public class SyntaxTree
{
    public SyntaxTree(){}
    
    public SyntaxTree(List<String> diagnostics, ExpressionSyntax root, SyntaxToken endOfFileToken)
    {
        this.Diagnostics = diagnostics;
        this.Root = root;
        this.EndOfFileToken = endOfFileToken;
    }

    public List<String> Diagnostics { get; private set;}
    public ExpressionSyntax Root { get; private set;}
    public SyntaxToken EndOfFileToken { get; private set;}

    public static SyntaxTree Parse(String text)
    {   
            ParserBoolean parser = new ParserBoolean(text);
            return parser.Parse();
    }

    // public static SyntaxTree Parse(String text, String Type)
    // {
    //     if (Type.equalsIgnoreCase('Binary')) {
    //         return Parse(text);
    //     } else if (Type.equalsIgnoreCase('Bool')) {
    //         ParserBoolean parser = new ParserBoolean(text);
    //         return parser.Parse();
    //     } else {
    //         return null;
    //     }
        
    // }
}