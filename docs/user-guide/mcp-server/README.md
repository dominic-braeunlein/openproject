---
sidebar_navigation:
  title: MCP Server (AI)
  priority: 760
description: Use OpenProject with AI assistants through the Model Context Protocol (MCP).
keywords: mcp, ai, llm, assistant
---
# MCP Server (AI integration)

OpenProject can be connected to AI assistants and other tools that support the **Model Context Protocol** (MCP). This lets you query project data, create and update work packages, track time, and more — all through natural language in your preferred AI client.

> [!NOTE]
> The MCP Server is an **Enterprise add-on** and is currently in **beta**. Please [contact us](https://www.openproject.org/contact/) if you encounter any issues.

## What is MCP?

The Model Context Protocol (MCP) is an open standard that allows AI assistants (such as Claude, Copilot, or similar tools) to interact with external services. OpenProject acts as an MCP server, exposing your project data to compatible AI clients in a secure and controlled way.

With MCP, you can:

- **Search** work packages, projects, users, time entries, and more
- **Create** work packages, comments, relations, and time entries
- **Update** work packages, time entries, and relations
- **Delete** time entries and work package relations
- **Access** reference data like statuses, types, custom fields, versions, and the current user

All actions are performed using your OpenProject permissions, so AI clients can only see and do what you are allowed to.

## Getting started

### Prerequisites

- An OpenProject instance with the MCP Server feature enabled (contact your administrator if unsure)
- A compatible MCP client (e.g. Claude Desktop, Cursor, VS Code with GitHub Copilot, or any other tool that supports MCP)
- Either a personal API token or an OAuth2-based login, depending on your setup

### Configuring your MCP client

Your MCP client needs to know the OpenProject MCP endpoint. The endpoint is always available at `/mcp` on your OpenProject instance, for example:

```text
https://your-openproject.example.com/mcp
```

The exact configuration differs between MCP clients. Refer to your client's documentation for how to register an MCP server. You will typically need to provide:

1. The **MCP server URL** (the `/mcp` endpoint of your OpenProject instance)
2. **Authentication credentials** (see below)

### Authentication

There are two ways to authenticate with the OpenProject MCP server:

#### Option 1: Personal API token (for single-user clients)

This is the simplest method and works well for desktop-based MCP clients used by a single person.

1. In OpenProject, go to **My account → Access tokens** and create a new API token (or use an existing one).
2. In your MCP client configuration, provide the token as a Bearer token in the Authorization header.
3. Point your MCP client to your instance's `/mcp` endpoint.

> [!NOTE]
> API tokens must be enabled by an administrator under _Administration → API and webhooks_. See the [admin guide](../../system-admin-guide/integrations/mcp-server/) for details.

#### Option 2: OAuth2 (for shared or web-based clients)

When multiple users need to access the same MCP client (e.g. a web-based AI assistant), OAuth2 is the recommended approach. In this case, your administrator configures an OAuth application in OpenProject once, and each user authorizes the client through a standard OAuth login flow.

Users do not need to create API tokens themselves. After granting permission, the MCP client receives a token with the `mcp` scope and can interact with OpenProject on the user's behalf.

If your administrator has set up OAuth for MCP, simply start your MCP client and follow the login flow.

## Available tools

MCP tools allow your AI client to perform operations in OpenProject. Each tool maps to a specific action. Your administrator can enable, disable, or rename tools.

### Searching and reading data

| Tool | Description |
| --- | --- |
| `search_work_packages` | Search work packages by subject, project, assignee, status, type, and more. Returns a compact list by default. |
| `search_projects` | Search projects by name or identifier. |
| `search_users` | Search users by name or email. |
| `search_time_entries` | Search time entries by date range, user, or work package. |
| `search_versions` | Search versions by name. |
| `search_portfolios` | Search portfolios by name or identifier. |
| `search_programs` | Search programs by name or identifier. |
| `search_custom_fields` | Search custom fields by name or ID. |
| `search_custom_field_items` | List available values for hierarchy or weighted item list custom fields. |
| `list_statuses` | List all work package statuses. |
| `list_types` | List all work package types. |
| `list_work_package_comments` | List comments on a work package. |
| `list_work_package_relations` | List relations of a work package. |
| `current_user` | Get information about the currently authenticated user. |

### Creating and updating data

| Tool | Description |
| --- | --- |
| `create_work_package` | Create a new work package. |
| `update_work_package` | Update an existing work package (subject, description, dates, assignee, status, etc.). |
| `create_work_package_comment` | Add a comment to a work package. |
| `create_work_package_relation` | Create a relation (e.g. "blocks", "relates", "precedes") between two work packages. |
| `update_work_package_relation` | Update an existing relation. |
| `delete_work_package_relation` | Delete a relation between work packages. |
| `create_time_entry` | Log time on a work package. |
| `update_time_entry` | Update an existing time entry. |
| `delete_time_entry` | Delete a time entry. |

### Pagination

Search tools return a limited number of results per page (typically 40 for work packages and time entries, 100 for projects, users, etc.). If your search returns more results, your AI client can request the next page by passing a page number.

## Available resources

MCP resources provide structured access to OpenProject entities. Resources are read-only references that MCP clients can use to look up specific records.

| Resource | Description |
| --- | --- |
| `current_user` | The currently authenticated user. |
| `work_package` | Access work packages by ID. |
| `project` | Access projects by identifier. |
| `user` | Access users by ID. |
| `status` | Access work package statuses. |
| `status_list` | A list of all work package statuses. |
| `type` | Access work package types. |
| `type_list` | A list of all work package types. |
| `version` | Access work package versions. |
| `custom_field` | Access custom field definitions. |

## Common use cases

### Summarizing project status

Ask your AI assistant questions like:

> "Give me a summary of all open work packages assigned to me in the Website Redesign project."

The AI client will use the `search_work_packages` tool to find relevant work packages and summarize their status, dates, and progress.

### Creating work packages

You can ask your AI assistant to create new work packages:

> "Create a new task called 'Review homepage design' in the Website Redesign project, assigned to Jane Doe, due next Friday."

### Tracking time

You can log time through MCP:

> "Log 2 hours of work on work package #42 for today."

### Managing relations

You can ask your AI assistant to create relations:

> "Make work package #42 block work package #58."

## Permissions and security

All actions performed through MCP use your OpenProject user permissions. This means:

- You can only see projects and work packages that you have permission to view
- You can only create or modify work packages in projects where you have the appropriate role
- You can only log time on work packages where time tracking is enabled and you have permission

Your administrator can further restrict MCP access by:

- Enabling or disabling individual tools
- Limiting MCP access to specific users or groups
- Enabling MCP read access per project

## Troubleshooting

### My MCP client cannot connect

- Verify the MCP endpoint URL is correct (`https://your-openproject.example.com/mcp`)
- Check that the MCP Server is enabled in your OpenProject administration
- Ensure your API token or OAuth credentials are valid
- If using OAuth, make sure the `mcp` scope is included in your token

### The AI cannot find my work packages

- Check that you have the necessary project permissions
- Try searching with different parameters (e.g. project name instead of project ID)
- Remember that work package search returns a compact list by default; ask the AI to fetch full details if needed

### I get a permission error

- MCP uses the same permissions as your OpenProject user account
- Contact your administrator if you believe you should have access
- If your administrator has restricted MCP to certain users or groups, you may need to be added to the allowed list