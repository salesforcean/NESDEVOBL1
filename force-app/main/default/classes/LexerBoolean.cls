public class LexerBoolean {

    public String expressionText  {get; private set;}
    private Integer position=0;
    private List<String> diagnostics = new List<string>();

    public LexerBoolean(String expression) {
        expressionText = expression;
    }

    public List<String> Diagnostics() {
        return diagnostics;
    }

    private String Current {
        get{
            if( position >= expressionText.length() ) 
                return null; // '\0' not valid in Apex
           
            return String.fromCharArray( new List<integer> { expressionText.charAt(position) } );
        }
    }

    private void Next(){
        position++;
    }

    public SyntaxToken NextToken(){
        // numbers
        // + - * / 
        // AND OR ( )
        // <whitespace>

        if (position >= expressionText.length())
        {
            return new SyntaxToken(SyntaxKind.EndOfFileToken, position, null, null);
        }

        if(Current!=null && Current.isNumeric()) {
            
            Integer start = position;
                
            while(Current!=null && Current.isNumeric())
                Next();

            Integer length = position - start;
            String text = expressionText.substring(start, start+length);
            Integer value = null;
            try {
                value = Integer.valueOf(text);
            }
            catch (Exception ex) {
                diagnostics.add(String.format('The number {0} isn\'t valid Int32.', new List<Object>{expressionText}));
            }
            return new SyntaxToken(SyntaxKind.NumberToken, start, text, value);
        }

        if (Current!=null && Current.isWhitespace()) {

            Integer start = position;
            
            while(Current!=null && Current.isWhitespace())
                Next();

            System.debug('start>>' + start);
            System.debug('position>>' + position);

            Integer length = position - start;
            String text = expressionText.substring(start, start+length);
            // Integer value = Integer.valueOf(text);
            return new SyntaxToken(SyntaxKind.WhitespaceToken, start, text, null);
        }

        // * FOR Boolean Expression
        if (Current!=null && Current.isAlpha()) {

            Integer start = position;
            
            while(Current!=null && Current.isAlpha())
                Next();

            Integer length = position - start;
            String text = expressionText.substring(start, start+length);
            // Integer value = Integer.valueOf(text);

            // System.debug('isAlpha, text=' + text);
            if (text.equalsIgnoreCase('AND'))
                return new SyntaxToken(SyntaxKind.AndToken, start, 'AND', null);
            else if (text.equalsIgnoreCase('OR'))
                return new SyntaxToken(SyntaxKind.OrToken, start, 'OR', null);        }
        // * END

        if (Current == '(')
            return new SyntaxToken(SyntaxKind.OpenParenthesisToken, position++, '(', null);
        else if (Current == ')') 
            return new SyntaxToken(SyntaxKind.CloseParenthesisToken, position++, ')', null);

        diagnostics.add(String.format('ERROR: bad character input: {0}', new List<Object>{Current}));
        return new SyntaxToken(SyntaxKind.BadToken, position++, expressionText.substring(position-1, position), null);
    }

     // exception classes...
    public class ecrEvaluationException extends Exception {}
}