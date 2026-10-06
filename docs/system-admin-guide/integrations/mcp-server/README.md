---
sidebar_navigation:
  title: MCP Server
  priority: 500
description: Integrate AI agents with your OpenProject instance through MCP.
keywords: ai llm mcp
---
# MCP Server

[feature: mcp_server ]

> [!NOTE]
> The MCP Server is an **Enterprise add-on** and is currently in **beta**. Configuration options and available tools may change in future releases.

OpenProject allows AI agents and similar tools to integrate through an API called **Model Context Protocol** (MCP). This allows agents to access information from your OpenProject instance and perform actions.

For the user-facing semanas perspective on configuring an MCP client and using the available tools, please see the [MCP Server user guide](../../../user-guide/mcp-server/).

## Configuration

### MCP endpoint

In your MCP client, you have to configure the endpoint of the OpenProject MCP server, which is available under `/mcp`, so for example:

```text
https://your-openproject.example.com/mcp
```

### Enabling the MCP server

The MCP server can be enabled or disabled globally under _Administration → Artificial Intelligence (AI) → Model Context Protocol (MCP)_.

![Model context protocol (MCP) settings under OpenProject administration](openproject_system_guide_new_mcp.png)

When the MCP server is disabled, all requests to the `/mcp` endpoint will be rejected. Enable the checkbox to activate the server and expose the available tools and resources to MCP clients.

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

> [!NOTE]
> The API token is sent as a Bearer token in the `Authorization` header of each MCP request.

#### Shared access via OAuth

If multiple users shall be able to use information from the same OpenProject instance and when using web-based MCP clients, the typical
configuration will involve an admin setting up the MCP client and OpenProject once, so that regular users can then utilize the
preconfigured connection, granting the MCP client the necessary permissions through an OAuth flow.

The MCP endpoints require access with a token that includes the `mcp` scope. These tokens can be obtained in all ways usually supported
by OpenProject already, namely:

- [Tokens issued from OpenProject](../../authentication/oauth-applications/)
- Tokens issued from a compliant OpenID Connect provider

In case OpenProject is used as the authentication provider, the configuration for the client has to be prepared by the administrator.
Go to _Administration → Authentication → OAuth applications_ and create an application with the `mcp` scope, entering
the "Redirect URI" according to the instructions of your MCP client.

> [!IMPORTANT]
>
> Make sure that the application is marked as confidential.

![Create new OAuth application for an MCP server in OpenProject administration](openproject_system_guide_new_oauth_mcp.png)

##### OAuth redirect URI

The **Redirect URI** (also called callback URL) tells OpenProject where to send the user's browser after they have authorized (or denied) the MCP client's access request. The exact value depends on your MCP client:

| MCP client type | Typical redirect URI |
| --- | --- |
| Web-based AI assistant | `https://your-mcp-client.example.com/callback` |
| Desktop client (loopback) | `http://localhost:PORT/callback` (e.g. `http://localhost:3000/callback`) |
| Custom application | The endpoint your application exposes to receive the authorization code |

To find the correct redirect URI:

1. Check your MCP client's documentation or configuration screen for a field labeled **Redirect URI**, **Callback URL**, or similar.
2. Copy the value exactly as provided, including the scheme (`http` or `https`), host, port (if non-default), and path.
3. Paste it into the **Redirect URI** field in the OpenProject OAuth application configuration.
4. If your client supports multiple redirect URIs (e.g. one for development and one for production), enter each on a separate line.

> [!TIP]
> If you are unsure of the redirect URI, configure the MCP client first and look for the callback URL it expects. Many MCP clients display the expected redirect URI during their setup wizard.

#### Session cookie authentication

[feature: mcp_session_cookie ]

In addition to API tokens and OAuth, OpenProject also supports authentication to the MCP endpoint via the user's **session cookie**. This is particularly useful for browser-based or embedded MCP clients that already have an active OpenProject session.

When a user is logged in to OpenProject in their browser, MCP clients running in the same browser context can use the existing session cookie to authenticate with the `/mcp` endpoint. No additional token or OAuth flow is required.

To enable session cookie authentication:

1. Navigate to _Administration → Artificial Intelligence (AI) → Model Context Protocol (MCP)_.
2. Enable the **Allow session cookie authentication** option.
3. Save your changes.

> [!IMPORTANT]
> Session cookie authentication only works when the MCP client runs in the same browser context as the OpenProject session. It does not apply to standalone desktop clients or server-to-server integrations.

### Per-project access control

[feature: mcp_project_access ]

Administrators can control which projects are accessible through MCP on a per-project basis. This allows you to limit the exposure of project data to AI clients.

To enable read access for MCP per project:

1. Navigate to the project settings of the project you want to configure.
2. In the project settings, look for the **MCP** or **AI** section.
3. Enable or disable MCP access for that project.

When MCP access is disabled for a project, MCP clients will not be able to search, read, or create work packages in that project, even if the authenticated user has project permissions.

> [!NOTE]
> Per-project access control is evaluated in addition to the user's regular project permissions. A user must have both the appropriate project role **and** MCP access must be enabled for the project.

### Restricting MCP to specific users or groups

[feature: mcp_user_restriction ]

Administrators can limit MCP usage to specific users or groups. This is useful when you want to pilot MCP with a small team before rolling it out organization-wide.

To restrict MCP access:

1. Navigate to _Administration → Artificial Intelligence (AI) → Model Context Protocol (MCP)_.
2. Under **Allowed users and groups**, select the users or groups that should be permitted to use MCP.
3. Save your changes.

If no users or groups are selected, MCP access is available to all authenticated users (subject to per-project settings). If at least one user or group is selected, only those users (and members of the selected groups) will be able to access the MCP endpoint.

### Customization

You can customize the MCP server further under _Administration → Artificial Intelligence (AI) → Model Context Protocol (MCP)_. 

Here you can enable or disable the entire MCP server and change the MCP server titles and descriptions indicated towards MCP clients. If you think that your MCP client is passing duplicated information to the language model, you can also change the response format, though for most purposes the default should work well.

The available response format options are:

- **Full**: The most compatible option. Tool responses will include both regular and  structured content, allowing MCP clients to choose which format they  want to read. This may increase the number of tokens that the language  model has to process, potentially increasing cost and decreasing  performance. 
- **Structured content only**: Choose this if you are certain that MCP clients connecting to this instance  support structured content. Tool responses will only include structured  content and leave out its text representation. 
- **Content only**: Choose this if MCP clients connecting to this instance do not support  structured content. Tool responses will only contain plain text content  and leave out the structured version. 

![Model context protocol (MCP) settings in OpenProject administration](openproject_system_guide_new_mcp.png)

Individual tools and resources can also be enabled or disabled. Their titles and descriptions can be customized. This can be useful if you want to introduce alternative terminology for certain entities or limit the functionality available through MCP.

For example, if work packages are called "work items" in your day-to-day language, you can rename **Search work packages** to **Search work
items**. This helps users understand what the tool does and gives the language model an additional cue that "work items" is an alias for work
packages.

The lists below show the tools and resources provided by OpenProject by default. Titles, descriptions and availability can differ if they have
been customized by an administrator.

![MCP tools section settings in OpenProject administration](openproject_system_guide_new_mcp_tools.png)

## Best practices

### Security

- **Use OAuth for shared clients**: When multiple users interact with the same MCP client (e.g. a web-based AI assistant), always use OAuth2 instead of personal API tokens. This ensures each user's actions are attributed correctly and access is scoped to their permissions.
- **Restrict MCP to trusted users**: During the beta phase, consider limiting MCP access to a small group of power users or administrators.
- **Disable unused tools**: If your organization does not use time tracking or relations, disable the corresponding MCP tools to reduce the attack surface and avoid confusing the AI assistant.
- **Review per-project settings**: Regularly audit which projects have MCP access enabled, especially after creating new projects.

### Performance

- **Choose the right response format**: If your MCP client supports structured content, switch from "Full" to "Structured content only" to reduce token usage and improve response times.
- **Disable unused tools**: Fewer tools means smaller tool descriptions sent to the AI model, which reduces token consumption and improves response quality.
- **Monitor usage**: Use OpenProject's activity logs to monitor MCP usage patterns and identify potential abuse or performance issues.

### Customization

- **Rename tools for your domain**: If your team uses different terminology (e.g. "tickets" instead of "work packages"), rename the MCP tools accordingly. This helps the AI model understand user requests better.
- **Curate tool descriptions**: Customize tool descriptions to include organization-specific context, such as naming conventions or required fields.

## Troubleshooting

### MCP clients cannot connect

- Verify that the MCP server is **enabled** under _Administration → Artificial Intelligence (AI) → Model Context Protocol (MCP)_.
- Check that the MCP endpoint URL is correct: `https://your-openproject.example.com/mcp`.
- If using API tokens, ensure **Enable API tokens** is checked under _Administration → API and webhooks_.
- If using OAuth, verify the OAuth application has the `mcp` scope and is marked as **confidential**.
- If using session cookies, ensure the **Allow session cookie authentication** option is enabled.

### Users get permission errors

- Check that the user is in the **allowed users or groups** list (if restriction is enabled).
- Verify the user has the appropriate **project role** in the projects they are trying to access.
- If per-project access control is enabled, make sure MCP access is enabled for the relevant project.

### OAuth redirect fails

- Double-check the **Redirect URI** in the OAuth application matches exactly what the MCP client expects (including scheme, host, port, and path).
- Ensure the OAuth application is marked as **confidential**.
- Verify that the `mcp` scope is included in the OAuth application configuration.

### AI responses are too large or slow

- Switch the response format to **Structured content only** or **Content only** instead of **Full**.
- Disable tools that are not needed by your users.
- Remind users that search results are paginated — the AI client should fetch additional pages only when needed.

## Tools

MCP tools allow connected clients to perform operations in OpenProject. Each tool can be enabled or disabled, and its title and description can be customized under the MCP administration settings.

| Name | Title | Description |
| --- | --- | --- |
| `create_time_entry` | Create time entry | Create a new time entry. |
| `create_work_package` | Create work package | Create a new work package. |
| `create_work_package_comment` | Create work package comment | Add a comment to a work package. |
| `create_work_package_relation` | Create work package relation | Create a new relation between two work packages. |
| `current_user` | Current user | Returns the currently authenticated user. Also available as an MCP resource. |
| `delete_time_entry` | Delete time entry | Delete an existing time entry. |
| `delete_work_package_relation` | Delete work package relation | Delete an existing relation between two work packages. |
| `list_statuses` | List statuses | Lists all work package statuses available on this OpenProject instance. Also available as an MCP resource. |
| `list_types` | List types | Lists all work package types available on this OpenProject instance. Also available as an MCP resource. |
| `list_work_package_comments` | List work package comments | List comments of the given work package. |
| `list_work_package_relations` | List work package relations | List relations of the given work package towards other work packages. |
| `search_custom_field_items` | Search custom field items | Access items available as values for the given custom field. Usable for hierarchy and weighted item list custom fields. |
| `search_custom_fields` | Search custom fields | Show details of the custom fields matching given criteria. |
| `search_portfolios` | Search portfolios | Search portfolios matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 100 portfolios. To get the rest of the results, call the tool again with a page number of 2 or higher. |
| `search_programs` | Search programs | Search programs matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 100 programs. To get the rest of the results, call the tool again with a page number of 2 or higher. |
| `search_projects` | Search projects | Search projects matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 100 projects. To get the rest of the results, call the tool again with a page number of 1 or higher. |
| `search_time_entries` | Search time entries | Search time entries matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 40 time entries. To get the rest of the results, call the tool again with a page number of 2 or higher. |
| `search_users` | Search users | Search users matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 100 users. To get the rest of the results, call the tool again with a page number of 2 or higher. |
| `search_versions` | Search versions | Search versions matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 100 versions. To get the rest of the results, call the tool again with a page number of 2 or higher. |
| `search_work_packages` | Search work packages | Search work packages matching all of the passed input parameters. Parameters not passed are ignored. Results are limited to a maximum of 40 work packages. To get the rest of the results, call the tool again with a page number of 2 or higher. Names of custom fields should be resolved through the corresponding tool before showing them to the user. They should not be rendered as 'customFieldN'. |
| `update_time_entry` | Update time entry | Update an existing time entry. |
| `update_work_package` | Update work package | Updates a work package in-place. |
| `update_work_package_relation` | Update work package relation | Update an existing relation between two work packages. |

Search tools support pagination. The tool description exposed to your MCP client contains the applicable result limit and pagination information.

## Resources

MCP resources allow connected clients to access OpenProject data. Each resource can be enabled or disabled, and its title and description can be customized under the MCP administration settings.

| Name | Title | Description |
| --- | --- | --- |
| `current_user` | Current user | Representation of the currently authenticated user. |
| `custom_field` | Custom field | Access custom fields of this OpenProject instance. |
| `project` | Project | Access projects of this OpenProject instance. |
| `status` | Work Package Status | Access work package statuses of this OpenProject instance. |
| `status_list` | Work Package Statuses List | A list of all work package statuses configured in this OpenProject instance. |
| `type` | Work Package Type | Access work package types of this OpenProject instance. |
| `type_list` | Work Package Types List | A list of all work package types configured in this OpenProject instance. |
| `user` | User | Access users of this OpenProject instance. |
| `version` | Work Package Version | Access work package versions of this OpenProject instance. |
| `work_package` | Work Package | Access work packages of this OpenProject instance. |

### Working with work packages

#### Work package IDs

MCP tools that accept a work package ID support both the numeric ID and the work package's semantic/display ID. This allows MCP clients to use
the identifiers shown to users in OpenProject instead of requiring the underlying numeric ID.

#### Work package search responses

The `search_work_packages` tool returns a compact representation of matching work packages by default. This reduces the amount of data transferred to the MCP client and helps avoid unnecessary context usage when processing search results.

The compact response includes:

-   ID
-   Subject
-   Type
-   Author
-   Status
-   Start date
-   Finish date
-   Assignee

The work package description and other additional attributes are not included in the compact response.

If the MCP client needs complete work package information, it can request the expanded response through the corresponding `search_work_packages` input parameter. The tool schema and description exposed to the MCP client provide the available parameter and its usage.

### Time tracking

OpenProject provides MCP tools for working with time entries. MCP clients can search time entries and, depending on the authenticated
user's permissions, create, update and delete time entries.

The relevant tools are:

-   `search_time_entries`
-   `create_time_entry`
-   `update_time_entry`
-   `delete_time_entry`

Actions performed through MCP use the permissions of the authenticated OpenProject user.
