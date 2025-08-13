# How To Add the OPA ASP.NET Core SDK to an Existing ASP.NET Core Application

This guide explains how you can add the [OPA ASP.NET Core SDK](https://github.com/StyraInc/opa-aspnetcore) to an existing ASP.NET Core application in order to implement HTTP request authorization.

## Overview

The OPA ASP.NET Core SDK wraps the [OPA C# SDK](https://github.com/StyraInc/opa-csharp/) with the [`OpaAuthorizationMiddleware`](https://styrainc.github.io/opa-aspnetcore/api/Styra.Opa.AspNetCore.OpaAuthorizationMiddleware.html) class, which implements ASP.NET Core's [`Middleware`](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.http.imiddleware?view=aspnetcore-8.0) interface, allowing it to be used as part of the middleware pipeline for incoming requests. In this guide, you will learn:

- How to add the OPA ASP.NET Core SDK as a dependency for your application.
- How to add and configure the `OpaAuthorizationMiddleware` type for your application's middleware pipeline.
- How to inject application-specific information into your OPA requests using the [`IContextDataProvider`](https://styrainc.github.io/opa-aspnetcore/api/Styra.Opa.AspNetCore.IContextDataProvider.html) interface.

This guide is intended for developers who are already comfortable working in C# with ASP.NET Core. If you would like to learn more about ASP.NET Core, consider their [Getting Started](https://learn.microsoft.com/en-us/aspnet/core/getting-started/?view=aspnetcore-8.0) page.

## Adding the OPA ASP.NET Core SDK to your Project

Follow the instructions on the [Styra NuGet Repository page for the `Styra.Opa.AspNetCore`](https://www.nuget.org/packages/Styra.Opa.AspNetCore) to add the OPA ASP.NET Core SDK as a dependency.

## Adding and Configuring `OpaAuthorizationMiddleware` for the Middleware pipeline

The [`OpaAuthorizationMiddleware`](https://styrainc.github.io/opa-aspnetcore/api/Styra.Opa.AspNetCore.OpaAuthorizationMiddleware.html) class has a small surface area for configuration. The table below provides an overview.

| Description | Default Value | Why Change This? |
|-------------|---------------|------------------|
| [`OpaClient`](https://styrainc.github.io/opa-csharp/api/Styra.Opa.OpaClient.html) | `OpaClient(opa_url)`, where `opa_url` defaults to `http://localhost:8181`, or the value of the `OPA_URL` environment variable if it is set. | You need to customize the OPA URL, or modify the `OpaClient`'s settings directly. |
| OPA path | `null` (default decision) | You would like the OPA client to obtain decisions from a non-default rule. |
| [`IContextDataProvider`](https://styrainc.github.io/opa-aspnetcore/api/Styra.Opa.AspNetCore.IContextDataProvider.html) | `null` (no extra data injected) | You would like to include extra, application-specific data in the OPA policy's input at `input.context.data`. |

> [!TIP]
> A "default decision" corresponds to the `default_decision` OPA configuration key, see OPA's [Configuration doc](https://www.openpolicyagent.org/docs/configuration/) for more information.

Configuration is performed at the time that the authorization middleware is instantiated via the class constructor. The constructor is overloaded to allow any of these values to be omitted, though they are always ordered (from right to left): OPA client, OPA path, context data provider.

A minimal way to create an `OpaAuthorizationMiddleware` is:

```csharp
// ...
using Styra.Opa.AspNetCore;

var builder = new WebHostBuilder()
    .Configure(app =>
    {
        app.UseRouting();
        app.UseAuthentication();
        app.UseMiddleware<OpaAuthorizationMiddleware>();
        // ...
        // Your controller/routes added here.
    });
```

The authorization middleware will be instantiated with the default values discussed in the table above. This is suitable for use cases where:

- You can easily control the `OPA_URL` environment variable, or where the default `http://localhost:8181` URL is adequate.
- Your policy's entry point is configured as the default decision for your OPA instance.
- You don't need to inject any application specific data into policy input.

A maximal setup `OpaAuthorizationMiddleware`, setting all possible configuration values explicitly:

```csharp
// ...
using Styra.Opa;
using Styra.Opa.AspNetCore;

// ...

// Implement the default OPA client setup explicitly.
string opaURL = System.Environment.GetEnvironmentVariable("OPA_URL") ?? "http://localhost:8181";
OpaClient opa = new OpaClient(opaURL);

// This corresponds to the rule data.policy.main in the OPA policy bundle.
string policyEntrypoint = "policy/main";

// Assumes you have defined a suitable makeMyCustomProvider() elsewhere.
ContextDataProvider ctxProvider = makeMyCustomProvider();

var builder = new WebHostBuilder()
    .ConfigureServices(services =>
    {
        services.AddAuthentication( /* ... your authentication setup here ... */ );
        services.AddRouting();
        // ...
        // Ensure we inject a console logger, using Dependency Injection.
        services.AddLogging(builder => builder.SetMinimumLevel(LogLevel.Trace).AddConsole());
    }).Configure(app =>
    {
        app.UseRouting();
        app.UseAuthentication();
        app.UseMiddleware<OpaAuthorizationMiddleware>(opa, policyEndpoint, ctxProvider);
        // ...
        // Your controller/routes added here.
    });

var app = builder.Build();
app.Run();
```

Note that in both of the above examples, the `OpaAuthorizationMiddleware` will be applied to _all_ incoming requests, since it acts as a request delegate in the request handling pipeline. For more details on how the middleware and request delegate systems work, see the documentation [Overview of Middleware in ASP.NET Core](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/middleware/?view=aspnetcore-8.0).

## Injecting Application-Specific Data with an `IContextDataProvider`

The OPA ASP.NET Core SDK creates a rich input document with most of the information about each HTTP request included, following the AuthZEN format. You can find more details [here](../reference/input-output-schema). However, for some advanced use cases, it may be necessary to include additional data in the policy input. As an escape hatch, the [`OpaAuthorizationMiddleware`](https://styrainc.github.io/opa-aspnetcore/api/Styra.Opa.AspNetCore.OpaAuthorizationMiddleware.html) class, when instantiated with an object implementing [`IContextDataProvider`](https://styrainc.github.io/opa-aspnetcore/api/Styra.Opa.AspNetCore.IContextDataProvider.html), can include arbitrary structured data in the policy input at `input.context.data`.
