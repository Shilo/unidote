using UnityEngine;

namespace Unidote.Unity
{
    /// <summary>
    /// Unity MonoBehaviour adapter that exercises the engine-agnostic <see cref="UnidoteCore"/>.
    /// Attach to any GameObject to log a greeting on Start.
    /// </summary>
    [AddComponentMenu("Unidote/Unidote Behaviour")]
    [DisallowMultipleComponent]
    public sealed class UnidoteBehaviour : MonoBehaviour
    {
        [SerializeField]
        [Tooltip("Passed to UnidoteCore.Greet. Leave blank for the generic greeting.")]
        private string subject = "Unity";

        private void Start()
        {
            Debug.Log(UnidoteCore.Greet(subject), this);
        }
    }
}
