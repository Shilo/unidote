using System;
using System.Numerics;
using Unidote.Ports;

namespace Unidote.Simulation
{
    /// <summary>
    /// Default <see cref="ITickService"/>. Advances a <see cref="TickState"/>
    /// every time <see cref="Tick"/> is called by an engine adapter.
    ///
    /// Declared <c>partial</c> so engine adapters can supply a
    /// <c>partial void OnPlatformTick(...)</c> implementation from their own
    /// file. Because the mirrored Core source is compiled *into* the engine
    /// assembly by the sync pipeline, the partial extension runs without any
    /// virtual-call overhead — the Unidote answer to hot-loop dispatch cost.
    /// </summary>
    public sealed partial class SimulationTicker : ITickService
    {
        /// <inheritdoc />
        public event Action<TickState>? Ticked;

        /// <inheritdoc />
        public TickState State { get; private set; } = new(Elapsed: 0d, DeltaTime: 0f, Heartbeat: Vector3.Zero);

        /// <inheritdoc />
        public void Tick(float deltaTime)
        {
            if (float.IsNaN(deltaTime) || float.IsInfinity(deltaTime))
            {
                throw new ArgumentException("deltaTime must be a finite number.", nameof(deltaTime));
            }

            var elapsed = State.Elapsed + deltaTime;
            var heartbeat = new Vector3(
                x: MathF.Sin((float)elapsed),
                y: MathF.Cos((float)elapsed),
                z: deltaTime);

            State = new TickState(elapsed, deltaTime, heartbeat);

            OnPlatformTick(State);
            Ticked?.Invoke(State);
        }

        /// <summary>
        /// Engine-specific hot-path extension point. Engine adapters may
        /// supply a body in their own file (e.g. <c>SimulationTicker.Unity.cs</c>)
        /// to add profiler samples, native ECS writes, or physics callbacks
        /// without introducing a virtual dispatch on every tick.
        /// </summary>
        partial void OnPlatformTick(TickState state);
    }
}
