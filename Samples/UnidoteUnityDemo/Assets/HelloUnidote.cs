using UnityEngine;

namespace Unidote.Samples
{
    /// <summary>
    /// Minimal Unity MonoBehaviour verifying the Unidote package is linked via the local UPM reference.
    /// Attach to any GameObject in the scene and press Play — output appears in the Console.
    /// </summary>
    public sealed class HelloUnidote : MonoBehaviour
    {
        [SerializeField] private string subject = "Unity Demo";

        private void Start()
        {
            Debug.Log(UnidoteCore.Greet(subject), this);
        }
    }
}
