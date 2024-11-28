# mcp-vs-promptql

What I've done so far:

## Split customer support DB into 2

- Go to `split_db` directory.
- Create two postgres DBs at localhost:5432 - `control_plane_fake` and `support_tickets_fake`.
- Run `control_plane.sql` in `control_plane_fake` and `support_tickets.sql` in `support_tickets_fake` to create schemas.
- Run `poetry install && poetry run python split_db.py`. This will copy all data from the single cloud DB and split it into the two local DBs.
  
## Customize Postgres MCP Server

Customizations done:
- Support multiple databases and hence multiple SQL tools. By default it's not possible since postgres MCP always names the tool "query".
- In the tool description add the DB schema so that Claude doesn't hallucinate / retry all the time.
  
Running:
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

## Example user journey

Prompt: who are my most pain in the butt customers relative to the value they add? So use the revenue they generate divided by the amount of support tickets they create

Claude thread: https://claude.ai/share/39f8c24c-7b48-4397-aca9-eac30346fc53

TLDR:
- gets some data. the top-5 list is not sorted correctly, makes me question the accuracy.
- Check against promptql, claude looks wrong.
- Ask claude to give a full list as markdown
- List contains missing users
- Ask claude if it is complete
- Claude gives a more complete list but still missing 1 user

Comparison Sheet: https://docs.google.com/spreadsheets/d/1yoLWc6RRbK0OsICe0LGotDuAJ6l-yPrZp_i-fZogdyM/edit?gid=0#gid=0
