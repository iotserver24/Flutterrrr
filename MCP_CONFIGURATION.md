# MCP Configuration Guide

## What is MCP?

Model Context Protocol (MCP) is a protocol that allows AI models to access external tools and context. This app supports MCP servers to enhance the AI's capabilities.

## Configuration File

The app stores MCP server configurations in a JSON file at:
- **Location**: `<app_documents_directory>/mcp_config.json`

You can manage MCP servers in two ways:
1. **Through the App UI**: Navigate to Settings → MCP Servers
2. **Direct File Editing**: Edit the `mcp_config.json` file directly

## Configuration Format

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "your-api-key"
      }
    },
    "url-based-server": {
      "url": "https://mcp.example.com",
      "headers": {}
    }
  }
}
```

## Default Servers

The app comes pre-configured with several MCP servers:

### 1. Memory (Knowledge Graph)
- **Purpose**: Persistent memory and knowledge graph
- **Command**: `npx -y mcp-knowledge-graph --memory-path ./mcp-memory/`

### 2. Browser MCP
- **Purpose**: Web browsing capabilities
- **Command**: `npx @browsermcp/mcp@latest`

### 3. Rube (Composio)
- **Purpose**: Access to Composio tools
- **URL**: `https://rube.composio.dev/mcp?agent=cursor`

### 4. E2B
- **Purpose**: Code execution sandbox
- **URL**: `https://e2b.dev/mcp`

### 5. Expo MCP
- **Purpose**: React Native development tools
- **URL**: `https://mcp.expo.dev/mcp`

## Adding Custom Servers

### Command-Based Server

```json
{
  "my-custom-server": {
    "command": "node",
    "args": ["path/to/server.js"],
    "env": {
      "API_KEY": "your-key-here"
    }
  }
}
```

### URL-Based Server

```json
{
  "my-api-server": {
    "url": "https://api.example.com/mcp",
    "headers": {
      "Authorization": "Bearer your-token"
    }
  }
}
```

## Managing Through UI

1. Open the app
2. Tap the **"+"** button in the chat input
3. Select **"Manage MCP Servers"**
4. Use the interface to:
   - View all configured servers
   - Toggle servers on/off
   - Add new servers
   - Delete existing servers
   - Export/Import configuration
   - View configuration file location

## Enable/Disable Servers

Each server can be toggled on or off using the switch in the UI. This allows you to:
- Temporarily disable servers without removing them
- Control which servers are active
- Test different server combinations

## Import/Export Configuration

### Export
1. Go to MCP Servers screen
2. Tap the **"⋮"** (more) menu
3. Select **"Export Configuration"**
4. Configuration is copied to clipboard

### Import
1. Go to MCP Servers screen
2. Tap the **"⋮"** (more) menu
3. Select **"Import Configuration"**
4. Paste your JSON configuration
5. Tap **"Import"**

⚠️ **Warning**: Importing will replace your current configuration. Export first if you want to keep a backup.

## Server Types

### Command-Based Servers
- Run local commands or npm packages
- Require `command` and `args` fields
- Optional `env` for environment variables
- Examples: npx packages, local scripts

### URL-Based Servers
- Connect to remote MCP servers
- Require `url` field
- Optional `headers` for authentication
- Examples: cloud-hosted services, APIs

## Troubleshooting

### Server Not Working
1. Check if the server is enabled (toggle should be ON)
2. Verify the command/URL is correct
3. For command-based servers, ensure the package is installed
4. For URL-based servers, check network connectivity
5. Review environment variables and API keys

### Configuration Not Saving
1. Check app permissions for file storage
2. Verify JSON format is valid
3. Try exporting and re-importing configuration

### Can't Find Configuration File
1. Use the **"Show File Location"** option in the UI
2. The path will be displayed and can be copied

## Best Practices

1. **Keep API Keys Secure**: Don't share configuration files with API keys
2. **Test New Servers**: Enable one at a time to test functionality
3. **Backup Configuration**: Export your configuration regularly
4. **Use Descriptive Names**: Name servers clearly for easy identification
5. **Document Custom Servers**: Add comments in a separate file about custom server purposes

## Example Configurations

### Development Setup
```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "mcp-knowledge-graph", "--memory-path", "./dev-memory/"]
    },
    "browser": {
      "command": "npx",
      "args": ["@browsermcp/mcp@latest"]
    },
    "e2b": {
      "url": "https://e2b.dev/mcp",
      "headers": {}
    }
  }
}
```

### Production Setup with API Keys
```json
{
  "mcpServers": {
    "magic": {
      "command": "npx",
      "args": ["-y", "@21st-dev/magic@latest"],
      "env": {
        "API_KEY": "your-production-key"
      }
    },
    "supabase": {
      "command": "npx",
      "args": ["-y", "@supabase/mcp-server-supabase", "--read-only"],
      "env": {
        "SUPABASE_ACCESS_TOKEN": "your-token"
      }
    }
  }
}
```

## Support

For more information about MCP and available servers, visit:
- MCP Documentation: [Model Context Protocol](https://modelcontextprotocol.io/)
- Available MCP Servers: [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
