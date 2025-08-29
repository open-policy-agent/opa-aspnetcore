# How To Troubleshoot the OPA ASP.NET Core SDK

## Enabling Logging

The OPA ASP.NET Core SDK uses the `ILogger<TCategoryName>` style of logging, which integrates nicely with dependency injection in ASP.NET Core applications. To get the most verbose logging from the OPA ASP.NET Core, try providing a logger with its minimum log level set to at least [trace](https://learn.microsoft.com/en-us/dotnet/api/microsoft.extensions.logging.loglevel?view=net-8.0#microsoft-extensions-logging-loglevel-trace).

In the `ConfigureServices` setup for an ASP.NET Core application, this might look like:

```csharp
builder.ConfigureServices(services =>
  {
    // ...
    services.AddLogging(builder => builder.SetMinimumLevel(LogLevel.Trace).AddConsole());
  });
```

:::note
Is there something you'd like to see the OPA ASP.NET Core SDK include in its logs? Feel free to open an issue [on the issue tracker](https://github.com/Open-policy-agent/opa-aspnetcore/issues).
:::

## OPA Connectivity Issues

If the dependent OPA C# SDK is not able to connect to an OPA you may see exceptions similar to the ones below:

```javastacktrace
System.Net.Sockets.SocketException (111): Connection refused
   at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.ThrowException(SocketError error, CancellationToken cancellationToken)
   at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.System.Threading.Tasks.Sources.IValueTaskSource.GetResult(Int16 token)
   at System.Net.Sockets.Socket.<ConnectAsync>g__WaitForConnectWithCancellation|277_0(AwaitableSocketAsyncEventArgs saea, ValueTask connectTask, CancellationToken cancellationToken)
   at System.Net.Http.HttpConnectionPool.ConnectToTcpHostAsync(String host, Int32 port, HttpRequestMessage initialRequest, Boolean async, CancellationToken cancellationToken)
```

```javastacktrace
fail: OpenPolicyAgent.Opa.OpaClient[688872823]
      executing policy 'this/rule/does/not/exist' failed with exception: Connection refused (localhost:8181)
Unhandled exception. OpaException: executing policy at 'this/rule/does/not/exist' with failed due to exception 'System.Net.Http.HttpRequestException: Connection refused (localhost:8181)
 ---> System.Net.Sockets.SocketException (111): Connection refused
   at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.ThrowException(SocketError error, CancellationToken cancellationToken)
   at System.Net.Sockets.Socket.AwaitableSocketAsyncEventArgs.System.Threading.Tasks.Sources.IValueTaskSource.GetResult(Int16 token)
   at System.Net.Sockets.Socket.<ConnectAsync>g__WaitForConnectWithCancellation|277_0(AwaitableSocketAsyncEventArgs saea, ValueTask connectTask, CancellationToken cancellationToken)
   at System.Net.Http.HttpConnectionPool.ConnectToTcpHostAsync(String host, Int32 port, HttpRequestMessage initialRequest, Boolean async, CancellationToken cancellationToken)
   --- End of inner exception stack trace ---
...
   at OpenPolicyAgent.Opa.OpaClient.queryMachinery[T](String path, Input input)
   at OpenPolicyAgent.Opa.OpaClient.evaluate[T](String path, Boolean input)
....
```

If you encounter these types of error, this typically indicates that the SDK was not able to reach OPA. This can have several causes:

- OPA is running, but the OPA URL the SDK is using is not correct. See [_Configuring `OpaAuthorizationMiddleware`_](./add-sdk#adding-and-configuring-opaauthorizationmiddleware-for-the-middleware-pipeline) for more information about how to configure the OPA URL.
- OPA is not running. You may have forgotten to start it, or it may have failed to start due to a bad configuration, syntax errors in your policy, etc.
- OPA is running and the OPA URL is configured correctly, but a network problem is preventing the SDK from communicating with OPA.

## Malformed Policy Outputs

If your OPA policy does not correctly follow the output schema described [here](../reference/input-output-schema), the SDK will not be able to interpret the policy decisions. This may result in errors similar to the ones below:

```javastacktrace
fail: OpenPolicyAgent.Opa.AspNetCore.OpaAuthorizationMiddleware[0]
      caught exception from OPA client: OpaException: Could not convert bool result to type OpenPolicyAgent.Opa.AspNetCore.OpaResponse
         at OpenPolicyAgent.Opa.OpaClient.convertResult[T](Result resultValue)
         at OpenPolicyAgent.Opa.OpaClient.queryMachinery[T](String path, Input input)
         at OpenPolicyAgent.Opa.OpaClient.evaluate[T](String path, Object input, JsonSerializerSettings jsonSerializerSettings)
         at OpenPolicyAgent.Opa.AspNetCore.OpaAuthorizationMiddleware.OpaRequest(HttpContext context) in /home/.../opa-aspnetcore/src/OpenPolicyAgent.Opa.AspNetCore/OpaAuthorizationMiddleware.cs:line 235
```

In the above sample, the SDK was configured to access a rule which evaluated to a boolean value. This isn't a `Newtonsoft.Json` serialization issue, but instead a failure to deserialize a boolean into an [`OpaResponse`](https://open-policy-agent.github.io/opa-aspnetcore/api/OpenPolicyAgent.Opa.AspNetCore.OpaResponse.html).

If you see these types of errors, then you should closely look at the output your policy is sending to the SDK. Your decision logs are a good place to start looking.

> [!TIP]
> An easy way to have OPA dump human-readable decision logs to the console is to add the `--log-format=text --log-level=error --set decision_logs.console=true` arguments to your `opa run -s` command.

> [!NOTE]
> If you have _extra_ fields that are not expected in the output schema, these will be ignored by the OPA ASP.NET Core SDK, and will not contribute to the `OpaResponse` objects it uses to make decisions.
