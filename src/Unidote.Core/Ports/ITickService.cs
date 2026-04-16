using System;

namespace Unidote.Ports
{
    /// <summary>
    /// Bridge surface the engine-agnostic Core exposes so any host
    /// (Unity, Godot, plain .NET tests) can drive the simulation
    /// from its native game loop.
    ///
    /// The Core never imports <c>UnityEngine</c> or <c>GodotSharp</c>;
    /// engine adapters wrap their native update pump and forward a
    /// <c>deltaTime</c> value into <see cref="Tick"/>.
    /// </summary>
    public interface ITickService
    {
        /// <summary>Raised after <see cref="Tick"/> advances the clock.</summary>
        event Action<Simulation.TickState> Ticked;

        /// <summary>Most recent snapshot produced by a <see cref="Tick"/> call.</summary>
        Simulation.TickState State { get; }

        /// <summary>
        /// Advance the simulation by <paramref name="deltaTime"/> seconds.
        /// Expected on the host's main thread.
        /// </summary>
        void Tick(float deltaTime);
    }
}
