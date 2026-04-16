using System.Numerics;

namespace Unidote.Simulation
{
    /// <summary>
    /// Immutable snapshot of the simulation clock emitted by
    /// <see cref="SimulationTicker"/>.
    ///
    /// Math uses <see cref="Vector3"/> from <c>System.Numerics</c> so the
    /// type is shared across engines. Adapter layers are the only place
    /// that must convert to <c>UnityEngine.Vector3</c> or
    /// <c>Godot.Vector3</c> at the boundary — the "Vector3 Drift" tax
    /// flagged in the Unidote architecture spec.
    /// </summary>
    /// <param name="Elapsed">Total simulated seconds since the first tick.</param>
    /// <param name="DeltaTime">Seconds advanced by the most recent <see cref="SimulationTicker.Tick"/> call.</param>
    /// <param name="Heartbeat">Sample vector demonstrating SIMD-friendly Core math.</param>
    public readonly record struct TickState(double Elapsed, float DeltaTime, Vector3 Heartbeat);
}
