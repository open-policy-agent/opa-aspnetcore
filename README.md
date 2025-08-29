# OPA ASP.NET Core SDK

> [!IMPORTANT]
> The documentation for this SDK lives under [`docs/`](https://github.com/open-policy-agent/opa-aspnetcore/tree/main/docs), with reference documentation available at [https://open-policy-agent.io/opa-aspnetcore/](https://open-policy-agent.github.io/opa-aspnetcore/)

You can use the OPA C# ASP.NET Core SDK to connect [Open Policy Agent](https://www.openpolicyagent.org/) and [EOPA](https://github.com/open-policy-agent/eopa) deployments to your [ASP.NET Core](https://github.com/dotnet/aspnetcore) applications using the included [Middleware](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/?view=aspnetcore-8.0) implementation.

> [!IMPORTANT]
> Would you prefer a plain C# API instead of ASP.NET Core? Check out the [OPA C# SDK](https://github.com/open-policy-agent/opa-csharp).


## SDK Installation

This package is published on NuGet as [`OpenPolicyAgent.Opa.AspNetCore`](https://www.nuget.org/packages/OpenPolicyAgent.Opa.AspNetCore). The NuGet page includes up-to-date instructions on how to add it as a dependency to your C# project.

If you're using the dotnet CLI, this should look like:

```shell
dotnet add package OpenPolicyAgent.Opa.AspNetCore
```


## SDK Example Usage (high-level)

```csharp
using OpenPolicyAgent.Opa;
using OpenPolicyAgent.Opa.AspNetCore;

// ...

string opaUrl = System.Environment.GetEnvironmentVariable("OPA_URL") ?? "http://localhost:8181";
OpaClient opa = new OpaClient(opaUrl);

var builder = new WebHostBuilder()
    .ConfigureServices(services =>
    {
        services.AddAuthentication( /* ... your authentication setup here ... */ );
        services.AddRouting();
        // ...
    }).Configure(app =>
    {
        app.UseRouting();
        app.UseAuthentication();
        app.UseMiddleware<OpaAuthorizationMiddleware>(opa, "authz/exampleapp/routes/allow");
        // ...
        // Your controller/routes added here.
    });

var app = builder.Build();
app.Run();
```


## Policy Input/Output Schema

Documentation for the required input and output schema of policies used by the OPA ASP.NET Core SDK can be found [here](https://github.com/open-policy-agent/opa-aspnetcore/tree/main/docs/reference/input-output-schema.md)


## Build Instructions

**To build the SDK**, use `dotnet build`. The resulting library files will be in `src/OpenPolicyAgent.Opa.AspNetCore/bin/Debug/net8.0`.

**To build the documentation** site, run `docfx docs/docfx.json -o OUTPUT_DIR`. You should replace `OUTPUT_DIR` with a directory on your local system where you would like the generated docs to be placed (the default behavior without `-o` will place the generated HTML docs site under the `docs/_site` folder in this repo). You can also preview the documentation site using `docfx docs/docfx.json --serve`, which will serve the docs on `http://localhost:8080` until you use Ctrl+C to exit.

**To run the unit tests**, you can use `dotnet test`.


## Community

For questions, discussions, and announcements, please join the OPA community on [Slack](https://slack.openpolicyagent.org/)!


## Development

For development docs, see [DEVELOPMENT.md](./DEVELOPMENT.md).
