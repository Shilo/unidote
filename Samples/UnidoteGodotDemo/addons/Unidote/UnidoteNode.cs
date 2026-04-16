using Godot;
using Unidote.Simulation;

namespace Unidote.Godot
{
    /// <summary>
    /// Godot Node adapter that bridges <c>_Process</c> into the
    /// engine-agnostic <see cref="SimulationTicker"/>. Add to any scene to
    /// print a greeting on <c>_Ready</c> and drive the Core each frame.
    /// </summary>
    public partial class UnidoteNode : Node
    {
        [Export] public string Subject { get; set; } = "Godot";

        [Export] public bool LogHeartbeat { get; set; }

        private readonly SimulationTicker ticker = new();

        public override void _Ready()
        {
            GD.Print(UnidoteCore.Greet(Subject));
        }

        public override void _Process(double delta)
        {
            ticker.Tick((float)delta);
            if (!LogHeartbeat)
            {
                return;
            }

            var s = ticker.State;
            GD.Print($"[Unidote] tick {s.Elapsed:F3}s heartbeat=({s.Heartbeat.X:F2},{s.Heartbeat.Y:F2},{s.Heartbeat.Z:F2})");
        }
    }
}
