# Plain .NET

Unidote's Core is a vanilla `netstandard2.1` class library. Reference it from any .NET 6+ project — servers, tools, tests, other engines.

## Why use Unidote's Core outside a game engine?

- **Integration tests** that exercise gameplay logic headlessly on CI.
- **Level generators** or asset pipelines that run as standalone .NET CLI tools.
- **Backends** that share type definitions with the game client.
- **Benchmarking** engine-agnostic code without launching an editor.

## Reference via `ProjectReference`

```xml title="YourProject.csproj"
<Project Sdk="Microsoft.NET.Sdk">
    <PropertyGroup>
        <TargetFramework>net8.0</TargetFramework>
    </PropertyGroup>

    <ItemGroup>
        <ProjectReference Include="../unidote/Core/Core.csproj" />
    </ItemGroup>
</Project>
```

## Reference via `<Compile Include>`

Useful when you want the Core sources compiled **into** your project's assembly rather than linked as a separate DLL (for example, when shipping a single-file tool).

```xml title="YourProject.csproj"
<ItemGroup>
    <Compile Include="../unidote/Core/*.cs" LinkBase="Unidote" />
</ItemGroup>
```

## Writing tests

Drop an xUnit test project next to the Core:

```sh
dotnet new xunit -n Unidote.Tests
cd Unidote.Tests
dotnet add reference ../Core/Core.csproj
```

```csharp title="Unidote.Tests/UnidoteCoreTests.cs"
using Unidote;
using Xunit;

public class UnidoteCoreTests
{
    [Fact]
    public void Greet_IncludesVersion()
    {
        var output = UnidoteCore.Greet("tests");
        Assert.Contains($"v{UnidoteCore.Version}", output);
    }
}
```

```sh
dotnet test
```

!!! tip "The Unidote template intentionally ships without a test project"
    This keeps the scaffold minimal. Add xUnit / NUnit / MSTest when you have logic worth testing.

## Consuming from F#

Because Unidote targets `netstandard2.1`, F# projects can consume it directly:

```fsharp
open Unidote

[<EntryPoint>]
let main _ =
    printfn "%s" (UnidoteCore.Greet "F#")
    0
```

## Shipping as a NuGet package

The template does not push to NuGet by default, but enabling it is one property:

```xml title="Core/Core.csproj"
<PropertyGroup>
    <IsPackable>true</IsPackable>
    <PackageId>Unidote.Core</PackageId>
    <Version>0.1.0</Version>
    <Authors>Shilo</Authors>
    <Description>Engine-agnostic C# core for cross-engine game libraries.</Description>
    <PackageLicenseExpression>MIT</PackageLicenseExpression>
</PropertyGroup>
```

Then:

```sh
dotnet pack Core/Core.csproj -c Release -o ./nupkgs
dotnet nuget push nupkgs/Unidote.Core.0.1.0.nupkg -k <API_KEY> -s https://api.nuget.org/v3/index.json
```

Downstream Unity and Godot consumers can ignore the NuGet feed and keep using the Git URL / folder drop-in install paths.
