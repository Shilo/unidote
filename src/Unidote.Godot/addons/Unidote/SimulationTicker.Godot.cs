// Engine-specific partial compiled into the Godot addon assembly alongside the
// mirrored Core. Kept minimal: the scaffold proves the partial-class bridge
// pattern works in Godot; concrete hooks (custom physics, GPU probes) belong
// to the library author.
using Godot;

namespace Unidote.Simulation
{
    public sealed partial class SimulationTicker
    {
        partial void OnPlatformTick(TickState state)
        {
            // Left intentionally silent. Uncomment the line below to stream
            // tick telemetry to the Godot Output pane during development.
            // GD.Print($"[Unidote] tick {state.Elapsed:F3}s dt={state.DeltaTime:F4}");
            _ = state;
        }
    }
}
