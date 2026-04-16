using Unidote.Simulation;
using UnityEngine;

namespace Unidote.Unity
{
    /// <summary>
    /// Unity MonoBehaviour adapter that bridges the Unity game loop into the
    /// engine-agnostic <see cref="SimulationTicker"/>. Attach to any
    /// GameObject to log a greeting on Start and drive the Core each frame.
    /// </summary>
    [AddComponentMenu("Unidote/Unidote Behaviour")]
    [DisallowMultipleComponent]
    public sealed class UnidoteBehaviour : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("Passed to UnidoteCore.Greet. Leave blank for the generic greeting.")]
        private string subject = "Unity";

        [SerializeField]
        [Tooltip("When true, streams each tick's heartbeat vector to the Console.")]
        private bool logHeartbeat;

        private readonly SimulationTicker ticker = new();

        private void Start()
        {
            Debug.Log(UnidoteCore.Greet(subject), this);
        }

        private void Update()
        {
            ticker.Tick(Time.deltaTime);
            if (!logHeartbeat)
            {
                return;
            }

            var s = ticker.State;
            Debug.Log($"[Unidote] tick {s.Elapsed:F3}s heartbeat=({s.Heartbeat.X:F2},{s.Heartbeat.Y:F2},{s.Heartbeat.Z:F2})", this);
        }
    }
}
