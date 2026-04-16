using Godot;

namespace Unidote.Godot
{
    /// <summary>
    /// Godot Node adapter that exercises the engine-agnostic <see cref="UnidoteCore"/>.
    /// Add to any scene to print a greeting on _Ready.
    /// </summary>
    public partial class UnidoteNode : Node
    {
        [Export] public string Subject { get; set; } = "Godot";

        public override void _Ready()
        {
            GD.Print(UnidoteCore.Greet(Subject));
        }
    }
}
