---
sidebar_navigation:
  title: MCP Server
  priority: 500
description: Integrate AI agents with your OpenProject instance through MCP.
keywords: ai llm mcp
---
# MCP Server

[feature: mcp_server ]

OpenProject allows AI agents and similar tools to integrate through an API called **Model Context Protocol** (MCP). This allows agents to access information from your OpenProject instance and perform actions.

## Configuration

In your MCP client, you have to configure the endpoint of the OpenProject MCP server, which is available under `/mcp`, so for example:

```text
https://your-openproject.example.com/mcp
```

### Authentication

Authentication with MCP can happen in the ways that authentication for regular API endpoints can happen as well. The two distinct
use cases for authentication are authentication for a single user via personal API tokens or authentication for different users
sharing the same (web) application through OAuth.

#### Personal access with API tokens

This way of authentication requires no further setup on the administration side of OpenProject.
The only requirement is that the ["Enable API tokens"](../../api-and-webhooks/) setting is enabled.

Afterwards users that want to make use of MCP on a personal basis, can create a personal API token and configure an MCP client with that
token. However, this only works properly with locally running MCP clients that are only used by a single user and it requires the user
to configure the MCP endpoint themselves.

#### Shared access via OAuth

If multiple users shall be able to use information from the same OpenProject instance and when using web-based MCP clients, the typical
configuration will involve an admin setting up the MCP client and OpenProject once, so that regular users can then utilize the
preconfigured connection, granting the MCP client the necessary permissions through an OAuth flow.

The MCP endpoints require access with a token that includes the `mcp` scope. These tokens can be obtained in all ways usually supported
by OpenProject already, namely:

- [Tokens issued from OpenProject](../../authentication/oauth-applications/)
- Tokens issued from a compliant OpenID Connect provider

In case OpenProject is used as the authentication provider, the configuration for the client has to be prepared by the administrator.

##### What is a redirect URI?

The **redirect URI** (also called "callback URL") is the address of the MCP client that receives the authorization response after a user
grants or denies access. It is defined by the MCP client vendor, not by OpenProject.

- **Web-based MCP clients** (e.g. Claude web app) use a fixed HTTPS URL, such as `https://example.com/callback`.
- **Local MCP clients** (CLI tools, desktop applications) often use a loopback address, such as `http://localhost:<port>/callback`,
  where the port may change per session.

You must enter the correct redirect URI in the OpenProject OAuth application so that OpenProject knows where to send the user after they
approve or deny the authorization request.

##### Setup steps

Follow these steps in order to configure an OAuth application for an MCP client:

1. **Create the OAuth application.**
   Go to _Administration → Authentication → OAuth applications_ and create a new application.

2. **Add the `mcp` scope.**
   Select the `mcp` scope so that tokens issued for this application can access the MCP endpoints.

3. **Enter the redirect URI.**
   Enter the redirect URI provided by your MCP client. See the [examples](#redirect-uri-examples) below for common values, or use the
   [fallback method](#finding-the-redirect-uri-from-the-authorization-url) if your client is not listed.

4. **Mark the application as confidential.**
   Ensure that the **Confidential** checkbox is selected. This is required so that the client can securely store and use its client secret.

   > [!IMPORTANT]
   >
   > Make sure that the application is marked as confidential.

   ![Create new OAuth application for an MCP server in OpenProject administration](openproject_system_guide_new_oauth_mcp.png)

5. **Copy the client ID and client secret.**
   After saving the OAuth application, copy the **client ID** and **client secret**. The client secret is shown only once — store it
   securely.

6. **Configure the MCP client.**
   In your MCP client, enter the OpenProject MCP endpoint URL:

   ```text
   https://your-openproject.example.com/mcp
   ```

   Enter the client ID and client secret from step 5. Your MCP client may also ask for the OAuth authorization endpoint and token
   endpoint URLs of your OpenProject instance:

   - Authorization endpoint: `https://your-openproject.example.com/oauth/authorize`
   - Token endpoint: `https://your-openproject.example.com/oauth/token`

##### Finding the redirect URI from the authorization URL

If your MCP client is not listed in the examples below, or you are unsure which redirect URI to use, you can find it from the OAuth
authorization URL:

1. Start the connection flow from your MCP client. You will be redirected to the OpenProject authorization page in your browser.
2. Look at the URL in your browser's address bar. It contains a `redirect_uri` query parameter, for example:

   ```text
   https://your-openproject.example.com/oauth/authorize?client_id=abc123&redirect_uri=https%3A%2F%2Fexample.com%2Fcallback&...
   ```

3. URL-decode the value of `redirect_uri`. In the example above, the decoded value is `https://example.com/callback`.
4. Enter this decoded value as the redirect URI in your OpenProject OAuth application.

##### Redirect URI examples

The values below are provided for convenience. Always verify with your MCP client vendor's documentation, as redirect URIs may change.

| Client | Platform | Redirect URI | Vendor documentation | Last verified |
| --- | --- | --- | --- | --- |
| Claude | Web, Desktop, Mobile | `https://claude.ai/api/mcp/auth_callback` | [Claude docs](https://claude.com/docs/connectors/building/authentication#callback-urls) | 2025-07-09 |
| Claude Code | CLI | `http://localhost:<port>/callback` | — | 2025-07-09 |

> [!NOTE]
>
> For Claude Code, the port number changes per session. You may need to enter `http://localhost:<port>/callback` as a wildcard or update
> the redirect URI each time you start a new session, depending on your OAuth client configuration.
