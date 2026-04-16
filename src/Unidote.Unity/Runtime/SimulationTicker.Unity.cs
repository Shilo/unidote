// Engine-specific partial that is compiled into Shilo.Unidote.dll alongside the
// mirrored Core. The Core's netstandard2.1 build sees only the empty partial
// declaration and compiles it away; only the Unity adapter assembly pays for
// the profiler sample.
using UnityEngine.Profiling;

namespace Unidote.Simulation
{
    public sealed partial class SimulationTicker
    {
        partial void OnPlatformTick(TickState state)
        {
            // Non-allocating profiler sample — zero cost when the Unity
            // Profiler is detached, measurable when it is attached.
            Profiler.BeginSample("Unidote.SimulationTicker.Tick");
            Profiler.EndSample();
        }
    }
}
