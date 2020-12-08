public class EvaluatorBoolean {

    private ExpressionSyntax root;
    private Map<Object, Boolean> variableValueMap;
    
    public EvaluatorBoolean() {}

    public EvaluatorBoolean(ExpressionSyntax root, Map<Object, Boolean> variableValueMap) 
    {
    
        this.root = root;
        this.variableValueMap = variableValueMap;

    }

    public Boolean Evaluate() 
    {
        return EvaluateExpression(root);
    }

    private Boolean EvaluateExpression(ExpressionSyntax node) 
    {
     
        if (node instanceof NumberExpressionSyntax) 
        {
            NumberExpressionSyntax nes = (NumberExpressionSyntax) node;
            Boolean op = this.variableValueMap.get(nes.numberToken.value);

            if (op==null)
                throw new ecaEvaluationException(
                    String.format
                    (
                        'Data NOT FOUND for Number Token:{0} in ExpressionData: {1}', 
                        new List<Object>{nes.numberToken.value, this.variableValueMap}
                    )
                );      
                      
            return op;

        }

        if (node instanceof BooleanExpressionSyntax)
        {
            BooleanExpressionSyntax boolES = (BooleanExpressionSyntax) node;
            Boolean left = EvaluateExpression(boolES.Left);
            Boolean right = EvaluateExpression(boolES.Right);

            if (boolES.OperatorToken.Kind == SyntaxKind.OrToken)
                return left || right;
            else if (boolES.OperatorToken.Kind == SyntaxKind.AndToken)
                return left && right;
            else
                throw new ecaEvaluationException(String.format('Unexpected binary operator {0}', new List<Object>{boolES.OperatorToken.Kind}));
        } 
        
        if (node instanceof ParenthesizedExpressionSyntax) 
        {
            ParenthesizedExpressionSyntax p = (ParenthesizedExpressionSyntax) node;
            return EvaluateExpression(p.Expression);
        }

        throw new ecaEvaluationException(String.format('Unexpected node {0}', new List<Object>{node.Kind}));

    }

    // exception classes...
    public class ecaEvaluationException extends Exception {}

}