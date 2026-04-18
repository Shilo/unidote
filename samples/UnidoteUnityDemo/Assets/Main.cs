using UnityEngine;

public class Main : MonoBehaviour
{
    private void Start()
    {
        var text = $"{nameof(Unidote)}: Hello World";
        this.GetComponent<UnityEngine.UI.Text>().text = text;
        Debug.Log(text);
    }
}
