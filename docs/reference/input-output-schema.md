# OPA ASP.NET Core SDK Policy Input/Output Schema

The OPA ASP.NET Core SDK makes calls to Enterprise OPA or Open Policy Agent to request an authorization decision.

The policy that processes these authorization decision requests must know the structure of the input given by OPA ASP.NET Core, and must return an appropriately structured output.

The following is a reference for these schemas:

## Endpoint Authorization

With endpoint authorization, the OPA ASP.NET Core SDK sends an authorization request on every call to an API endpoint.

### Input

| Parameter       | Type   | Value          | Description |
| --------------- | ------ | -------------- | ----------- |
| `input.resource.type`       | string | `endpoint` | A constant describing the type of resource being accessed. |
| `input.resource.id`         | string | Endpoint [request path](https://learn.microsoft.com/en-us/dotnet/api/microsoft.aspnetcore.http.httprequest.path?view=aspnetcore-8.0) |
| `input.action.name`         | string | `GET`, `POST`, `PUT`, `PATCH`, `HEAD`, `OPTIONS`, `TRACE`, or `DELETE` | HTTP request method |
| `input.action.protocol`     | string | HTTP protocol for request, e.g. `HTTP 1.1` | |
| `input.action.headers`      | Dictionary[string, object] | HTTP headers of request | Not guaranteed to be present. |
| `input.context.type`        | string | `http` | A constant describing the type of contextual information provided |
| `input.context.host`        | string | HTTP remote host of request | |
| `input.context.ip`          | string | HTTP remote IP of request | |
| `input.context.port`        | string | HTTP remote port for request | |
| `input.context.data`        | Dictionary[string, object] | | Optional supplemental data you can inject using a `ContextDataProvider` implementation |
| `input.subject.type`        | string | `aspnetcore_authentication` | A constant describing the kind of subject being provided. |
| `input.subject.id`          | string | ASP.NET Core authN [principal](https://learn.microsoft.com/en-us/dotnet/api/system.security.principal.iidentity.name?view=net-8.0#system-security-principal-iidentity-name) | ID representing the subject being authorized. |
| `input.subject.authorities` | string | ASP.NET Core authN [claims](https://learn.microsoft.com/en-us/dotnet/api/system.security.claims.claimsprincipal.claims?view=net-8.0) |

### Output

| Parameter       | Type   | Required | Description |
| --------------- | ------ | ---------| ----------- |
| `output.decision`             | boolean. `true` if and only if the request should be allowed to proceed, else `false` | Yes | The decision of the authorization request |
| `output.context.id`           | string | Yes | AuthZEN [Reason Object](https://openid.github.io/authzen/#name-reason-object) ID |
| `output.context.reason_admin` | Dictionary[string, string] | No |  AuthZEN [Reason Field Object](https://openid.github.io/authzen/#reason-field), for administrative use |
| `output.context.reason_user`  | Dictionary[string, string] | No | AuthZEN [Reason Field Object](https://openid.github.io/authzen/#reason-field), for user-facing error messages |
| `output.context.data`         | Dictionary[string, object] | No | Optional supplemental data provided by your OPA policy |
