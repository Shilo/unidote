using UnityEngine;

namespace Unidote.Samples
{
    /// <summary>
    /// Minimal sample verifying the Unidote core is wired through the Unity adapter.
    /// Drop on an empty GameObject and press Play — output appears in the Console.
    /// </summary>
    [AddComponentMenu("Unidote/Samples/Hello Unidote")]
    public sealed class HelloUnidote : MonoBehaviour
    {
        [SerializeField] private string subject = "Unity Sample";

        private void Start()
        {
            Debug.Log(UnidoteCore.Greet(subject), this);
        }
    }
}
