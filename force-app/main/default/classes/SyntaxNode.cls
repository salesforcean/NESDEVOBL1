public abstract class SyntaxNode
{
	public SyntaxKind Kind { get; set;}
	public abstract List<SyntaxNode> GetChildren();
}