# mcp-vs-promptql


## Prepare data

- Go to `data` directory.
- Create two postgres DBs at localhost:5432 - `control_plane` and `support_tickets`.
- Complete database dumps are given at `control_plane_dump.sql` and `support_tickets_dump.sql`. Load them into the DBs respectively
  
## Customize Postgres MCP Server

Customizations done:
- Support multiple databases and hence multiple SQL tools. By default it's not possible since postgres MCP always names the tool "query".
- In the tool description add the DB schema so that Claude doesn't hallucinate / retry all the time.
- Add python tool (needs `python3` in PATH)
  
Running:
- The `index.ts` file contains the modified server. It won't compile as-is, you have to:
- Clone the original repo: https://github.com/modelcontextprotocol/servers
- Replace the `src/postgres/index.ts` file in there with the `index.ts` file here.
- Then in that directory run:
    - `npx tsc`
    - Optional: Run `node dist/index.js` to verify the server starts up fine.

## Claude Desktop config

Use MCP instructions here: https://modelcontextprotocol.io/quickstart and modify the configuration like below:

Put this in `~/Library/Application Support/Claude/claude_desktop_config.json` on Mac:

```json
{
  "mcpServers": {
    "dbs": {
      "command": "node",
      "args": [
        "<path to cloned servers repo>/src/postgres/dist/index.js"
      ]
    }
  }
}
```

