using Godot;
using Unidote;

namespace UnidoteGodotDemo
{
    /// <summary>
    /// Minimal Godot scene script confirming the engine-agnostic Unidote core is wired up.
    /// Prints the greeting to the Output pane on scene start.
    /// </summary>
    public partial class Main : Node
    {
        public override void _Ready()
        {
            GD.Print(UnidoteCore.Greet("Godot Demo"));
        }
    }
}
