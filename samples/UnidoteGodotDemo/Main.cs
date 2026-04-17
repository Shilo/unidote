using Godot;

namespace UnidoteGodotDemo;

public partial class Main : Label
{
    public override void _Ready()
    {
        Text = $"{nameof(Unidote)}: Hello World";
        GD.Print(Text);
    }
}
