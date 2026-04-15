#if TOOLS
using Godot;

namespace Unidote.Godot
{
    /// <summary>
    /// Minimal Godot EditorPlugin for Unidote. Activates the addon in the editor
    /// and logs the Core version to confirm the engine-agnostic library is linked.
    /// </summary>
    [Tool]
    public partial class UnidotePlugin : EditorPlugin
    {
        public override void _EnterTree()
        {
            GD.Print($"[Unidote] plugin enabled — Core v{UnidoteCore.Version}");
        }

        public override void _ExitTree()
        {
            // No editor resources registered — nothing to clean up.
        }
    }
}
#endif
