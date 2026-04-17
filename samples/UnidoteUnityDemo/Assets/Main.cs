using UnityEngine;

public class Main : MonoBehaviour
{
    void Start()
    {
        var text = $"{nameof(Unidote.Unidote)}: Hello World";
        Debug.Log(text);
    }
}
