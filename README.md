# mcp-vs-promptql

What I've done so far:

## Split customer support DB into 2

- Go to `split_db` directory.
- Create two postgres DBs at localhost:5432 - `control_plane_fake` and `support_tickets_fake`.
- Run `control_plane.sql` in `control_plane_fake` and `support_tickets.sql` in `support_tickets_fake` to create schemas.
- Run `poetry install && poetry run python split_db.py`. This will copy all data from the single cloud DB and split it into the two local DBs.
  
## Customize Postgres MCP Server

- The `index.ts` file contains the modified server. It won't compile as-is, you have to:
- Clone the original repo: https://github.com/modelcontextprotocol/servers
- Replace the `src/postgres/index.ts` file in there with the `index.ts` file here.
- Then in that directory run:
    - `npx tsc`
    - Optional: Run `node dist/index.js` to verify the server starts up fine.

## Claude Desktop config

I put this in my `~/Library/Application Support/Claude/claude_desktop_config.json` on Mac:

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

