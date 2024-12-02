#!/usr/bin/env node

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";
import pg from "pg";

const server = new Server(
  {
    name: "example-servers/postgres",
    version: "0.1.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
    },
  },
);

const args = process.argv.slice(2);
// if (args.length === 0) {
//   console.error("Please provide a database URL as a command-line argument");
//   process.exit(1);
// }

const controlPlaneUrl = "postgresql://postgres:postgres@localhost:5432/control_plane_fake";

const controlPlaneResourceBaseUrl = new URL(controlPlaneUrl);
controlPlaneResourceBaseUrl.protocol = "postgres:";
controlPlaneResourceBaseUrl.password = "";

const controlPlanePool = new pg.Pool({
  connectionString: controlPlaneUrl,
});

const supportTicketsUrl = "postgresql://postgres:postgres@localhost:5432/support_tickets_fake";

const supportTicketsResourceBaseUrl = new URL(supportTicketsUrl);
supportTicketsResourceBaseUrl.protocol = "postgres:";
supportTicketsResourceBaseUrl.password = "";

const supportTicketsPool = new pg.Pool({
  connectionString: supportTicketsUrl,
});

const SCHEMA_PATH = "schema";

async function getDatabaseSchema(pool: pg.Pool, customWhereClause: string): Promise<string> {
  const client = await pool.connect();
  const query = `
    SELECT 
      table_name,
      column_name,
      data_type
    FROM 
      information_schema.columns
    WHERE 
      table_schema = 'public' AND ${customWhereClause}
    ORDER BY 
      table_name, ordinal_position;
  `;

  const result = await client.query(query);
  
  const schema: { [key: string]: { columns: { name: string, type: string }[] } } = {};

  result.rows.forEach(row => {
    const tableName = row.table_name;
    const columnName = row.column_name;
    const columnType = row.data_type;

    if (!schema[tableName]) {
      schema[tableName] = { columns: [] };
    }

    schema[tableName].columns.push({ name: columnName, type: columnType });
  });

  let schemaString = '\n';
  for (const [table, { columns }] of Object.entries(schema)) {
    schemaString += `table ${table} columns (`;
    columns.forEach(col => {
      schemaString += ` ${col.name} ${col.type}, `;
    });
    schemaString += ')\n';
  }

  return schemaString.trim();
}

server.setRequestHandler(ListResourcesRequestSchema, async () => {
  // const client = await pool.connect();
  // try {
  //   const result = await client.query(
  //     "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'",
  //   );
  //   return {
  //     resources: result.rows.map((row) => ({
  //       uri: new URL(`${row.table_name}/${SCHEMA_PATH}`, resourceBaseUrl).href,
  //       mimeType: "application/json",
  //       name: `"${row.table_name}" database schema`,
  //     })),
  //   };
  // } finally {
  //   client.release();
  // }
  return {
    resources: []
  }
});

server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
  // const resourceUrl = new URL(request.params.uri);

  // const pathComponents = resourceUrl.pathname.split("/");
  // const schema = pathComponents.pop();
  // const tableName = pathComponents.pop();

  // if (schema !== SCHEMA_PATH) {
  //   throw new Error("Invalid resource URI");
  // }

  // const client = await pool.connect();
  // try {
  //   const result = await client.query(
  //     "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = $1",
  //     [tableName],
  //   );

  //   return {
  //     contents: [
  //       {
  //         uri: request.params.uri,
  //         mimeType: "application/json",
  //         text: JSON.stringify(result.rows, null, 2),
  //       },
  //     ],
  //   };
  // } finally {
  //   client.release();
  // }
  return {
    contents: []
  }
});

server.setRequestHandler(ListToolsRequestSchema, async () => {
  const cp_schema = await getDatabaseSchema(controlPlanePool, "table_name NOT LIKE 'support%'")
  const support_schema = await getDatabaseSchema(supportTicketsPool, "table_name LIKE 'support%'")
  return {
    tools: [
      {
        name: "query_control_plane_data",
        description: `Run a read-only SQL query against the control plane database containing the following tables: ${cp_schema}`,
        inputSchema: {
          type: "object",
          properties: {
            sql: { type: "string" },
          },
        },
      },
      {
        name: "query_support_tickets",
        description: `Run a read-only SQL query against the support tickets database containing the following tables: ${support_schema}`,
        inputSchema: {
          type: "object",
          properties: {
            sql: { type: "string" },
          },
        },
      },
      {
        name: "execute_python_program",
        description: `Run a python program and also pass a data value argument that can be loaded in the program as the first command line argument`,
        inputSchema: {
          type: "object",
          properties: {
            pythonCode: { type: "string"},
            dataValues: { type: "string", description: "stringified json of data"}
          },
        },
      }
    ],
  };
});

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "query_control_plane_data" || request.params.name === "query_support_tickets") {
    const sql = request.params.arguments?.sql as string;

    let pool = controlPlanePool;
    if (request.params.name === "query_support_tickets") {
      pool = supportTicketsPool;
    }

    const client = await pool.connect();
    try {
      await client.query("BEGIN TRANSACTION READ ONLY");
      const result = await client.query(sql);
      return {
        content: [{ type: "text", text: JSON.stringify(result.rows, null, 2) }],
        isError: false,
      };
    } catch (error) {
      throw error;
    } finally {
      client
        .query("ROLLBACK")
        .catch((error) =>
          console.warn("Could not roll back transaction:", error),
        );

      client.release();
    }
  }

  if (request.params.name === "execute_python_program") {
    const pythonCode = request.params.arguments?.pythonCode as string;
    const dataVals = request.params.arguments?.dataValues as string;
    const resultStruct = await executePythonCode(pythonCode, dataVals);
    return {
        content: [{type: "text", text: resultStruct.stdout + '\n\n' + resultStruct.stderr}],
        isError: resultStruct.stderr != ''
      }
  }
  throw new Error(`Unknown tool: ${request.params.name}`);
});

async function runServer() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

const cp_schema = await getDatabaseSchema(controlPlanePool, "table_name NOT LIKE 'support%'")
const support_schema = await getDatabaseSchema(supportTicketsPool, "table_name LIKE 'support%'")

console.log(cp_schema)
console.log(support_schema)
runServer().catch(console.error);


// 

import { spawn } from 'child_process';
import { promises as fs } from 'fs';
import { join } from 'path';
import { tmpdir } from 'os';

interface PythonExecutionResult {
  stdout: string;
  stderr: string;
  exitCode: number;
}



export async function executePythonCode(pythonCode: string, dataValues: string): Promise<PythonExecutionResult> {
  // Create a temporary file to store the Python code
  const tempFile = join(tmpdir(), `temp_${Date.now()}.py`);
  
  try {
    // Write the Python code to the temporary file
    await fs.writeFile(tempFile, pythonCode, 'utf8');
    
    // Execute the Python script
    const result = await new Promise<PythonExecutionResult>((resolve, reject) => {
      const pythonProcess = spawn('python3', [tempFile, dataValues]);
      
      let stdout = '';
      let stderr = '';
      
      pythonProcess.stdout.on('data', (data) => {
        stdout += data.toString();
      });
      
      pythonProcess.stderr.on('data', (data) => {
        stderr += data.toString();
      });
      
      pythonProcess.on('close', (code) => {
        resolve({
          stdout,
          stderr,
          exitCode: code ?? -1
        });
      });
      
      pythonProcess.on('error', (err) => {
        reject(new Error(`Failed to execute Python code: ${err.message}`));
      });
    });
    
    return result;
    
  } finally {
    // Clean up: delete the temporary file
    try {
      await fs.unlink(tempFile);
    } catch (err) {
      console.error('Failed to delete temporary file:', err);
    }
  }
}

// Example usage
async function main() {
  const pythonCode = `
print("Hello from Python!")
x = 10 + 20
print(f"Result: {x}")
`;

  try {
    const result = await executePythonCode(pythonCode, "[]");
    
    if (result.exitCode === 0) {
      console.log('Execution successful!');
      console.log('Output:', result.stdout);
    } else {
      console.error('Execution failed!');
      console.error('Error:', result.stderr);
    }
  } catch (err) {
    console.error('Failed to execute Python code:', err);
  }
}

// Call main function if you want to run the example
// main().catch(console.error);