from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client
import asyncio

# Create server parameters for stdio connection
SERVER_PARAMS= StdioServerParameters(
    command="node",
    args=['/Users/hasura/projects/servers/src/postgres/dist/index.js'],  # Optional command line arguments
    env=None  # Optional environment variables
)


async def check():
    print('hello')
    try:
        async with stdio_client(SERVER_PARAMS) as (read, write):
            print('hello2')
            async with ClientSession(read, write) as session:
                
                print('hello3')
                # Initialize the connection
                await session.initialize()
                
                
                print('hello4')

                # List available resources
                resources = await session.list_resources()

                # List available prompts
                prompts = await session.list_prompts()

                # List available tools
                tools = await session.list_tools()
            
                print(tools)

                # # Read a resource
                # resource = await session.read_resource("file://some/path")

                # # Call a tool
                # result = await session.call_tool("tool-name", arguments={"arg1": "value"})

                # # Get a prompt
                # prompt = await session.get_prompt("prompt-name", arguments={"arg1": "value"})
    except Exception as e:
        print(e)


if __name__ == "__main__":
    asyncio.run(check())
