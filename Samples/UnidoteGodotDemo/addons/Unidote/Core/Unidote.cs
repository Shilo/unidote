// AUTO-GENERATED. DO NOT EDIT. Edit source in /Core instead.
namespace Unidote;

/// <summary>
/// Engine-agnostic entry point for the Unidote library.
/// Reference from any engine adapter (Unity, Godot, or standalone .NET).
/// </summary>
public static class UnidoteCore
{
    /// <summary>
    /// Library semantic version.
    /// Keep aligned with Unity <c>package.json</c> and Godot <c>plugin.cfg</c>.
    /// </summary>
    public const string Version = "0.1.0";

    /// <summary>
    /// Produces a greeting used by the sample adapters to verify the Core is wired up.
    /// </summary>
    /// <param name="subject">Name of the caller (e.g. "Unity", "Godot"). May be null or whitespace.</param>
    public static string Greet(string? subject) =>
        string.IsNullOrWhiteSpace(subject)
            ? $"Hello from Unidote v{Version}."
            : $"Hello, {subject}! â€” Unidote v{Version}";
}
