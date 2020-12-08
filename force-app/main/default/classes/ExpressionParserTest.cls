/**
    @class:         ExpressionParserTest           
	@description:   Test coverage for expression evaluator, part of rewrite of the ECA assignment and completion logic.
	@author: 		Mark Membrino
	@createdDate:   8/31/2020
    @classes-covered with coverage snapshot: 
        => SyntaxKind (NaN% coverage) // enum class
        => SyntaxNode (100% coverage)
        => SyntaxToken (100% coverage)
        => SyntaxTree (91% coverage)
        => ExpressionSyntax (NaN% coverage) // abstract class
        => ParenthesizedExpressionSyntax (100% coverage)
        => BooleanExpressionSyntax (100% coverage)
        => NumberExpressionSyntax (100% coverage)
        => LexerBoolean (92% coverage)
        => ParserBoolean (91% coverage)
        => EvaluatorBoolean (90% coverage)
*/
@isTest(SeeAllData=false isParallel=true)
public class ExpressionParserTest
{
    
    @IsTest
    static void expressionEvaluator_Unary_Positive() 
    {
        String expression = '1';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => true};
        Boolean expectedOutput = true;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();            
    }

    @IsTest
    static void expressionEvaluator_Positive() 
    {
        String expression = '1 AND 2 AND 3';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => True, 2 => True, 3 => True};
        Boolean expectedOutput = true;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();            
    }
    
    @IsTest
    static void expressionEvaluator_Parenthesized_Positive() 
    {
        String expression = '1 AND 2 AND (3 OR 4)';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => True, 2 => True, 3 => False, 4 => True};
        Boolean expectedOutput = true;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();
    }

    @IsTest
    static void expressionEvaluator_Parenthesized_Positive2() 
    {
        String expression = '1 OR (2 AND (3 OR 4))';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => False, 2 => True, 3 => False, 4 => True};
        Boolean expectedOutput = true;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();
    }

    @IsTest
    static void expressionEvaluator_Parenthesized_Long_Expression_Positive()  // truthly: 3, 15, 30
    {
        String expression = '22 OR (((1 OR 2) OR (4 AND 5) OR (3)) AND ((6 OR 7 OR 8 OR 9 OR 10 OR 11 OR 12 OR 13) OR (31 OR 24 OR 25) OR (16 OR 26 OR 27 OR 28) OR (16 AND 24) OR ((14 AND 15) AND 30)))';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => False, 2 => False, 3 => True, 4 => False, 5 => False, 6 => False, 7 => False, 8 => False, 9 => False, 10 => False, 11 => False, 12 => False, 13 => False, 14 => False, 15 => True, 16 => False, 17 => False, 18 => False, 19 => False, 20 => False, 21 => False, 22 => False, 23 => False, 24 => False, 25 => False,  26 => False, 27 => True, 28 => False, 29 => False, 30 => True, 31 => False};
        Boolean expectedOutput = true;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();
    }

    @IsTest
    static void expressionEvaluator_Unary_Negative() 
    {
        String expression = '1';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => false};
        Boolean expectedOutput = false;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();
    }

    @IsTest
    static void expressionEvaluator_Parenthesized_Negative() 
    {
        String expression = '1 AND 2 AND (3 OR 4)';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{1 => True, 2 => True, 3 => False, 4 => False};
        Boolean expectedOutput = false;
        Test.startTest();
            System.assertEquals(expectedOutput, ECA_CriteriaEvaluator.evaluate(expression, expressionData));
        Test.stopTest();
    }

    @IsTest
    static void expressionEvaluator_Error_MissingData_Negative()
    {
        String expression = '1 AND 2 AND (3 OR 4)';
        Map<Object, Boolean> expressionData = new Map<Object, Boolean>{2 => True, 3 => False, 4 => False};

        Test.startTest();
        try {
            Boolean actualOutput = ECA_CriteriaEvaluator.evaluate(expression, expressionData);
        } catch (Exception e) {
            System.assert(e.getMessage().contains('Data NOT FOUND for Number Token:1'));
        }
        Test.stopTest();
    }

    @IsTest
    static void variousExpressionSyntax_Positive()
    {
        Test.startTest();

        BooleanExpressionSyntax boolExp = new BooleanExpressionSyntax();
        System.assertNotEquals(null, boolExp.GetChildren());

        ParenthesizedExpressionSyntax parenthesizedExp = new ParenthesizedExpressionSyntax();
        System.assertNotEquals(null, parenthesizedExp.GetChildren());

        NumberExpressionSyntax numberExp = new NumberExpressionSyntax();
        System.assertNotEquals(null, numberExp.GetChildren());

        SyntaxToken syntax = new SyntaxToken();
        System.assertNotEquals(null, syntax.GetChildren());

        Test.stopTest();

    }
}