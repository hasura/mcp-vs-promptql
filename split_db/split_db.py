import psycopg2
import psycopg2.extras
from psycopg2 import sql

import subprocess

def get_table_definition(table_name, db_conn_str):
    """Retrieve the SQL statement to create a table using pg_dump."""
    result = subprocess.run(
        [
            "pg_dump",
            "--schema-only",
            "--table", table_name,
            db_conn_str
        ],
        capture_output=True,
        text=True
    )
    if result.returncode != 0:
        raise Exception(f"Error fetching table definition: {result.stderr}")
    return result.stdout

# Original database connection
original_db = "postgresql://postgres:RgkufIYlR61hxV9t@34.94.43.105:5432/postgres"

# Local databases
control_plane_db = "postgresql://postgres:postgres@localhost:5432/control_plane_fake"
support_tickets_db = "postgresql://postgres:postgres@localhost:5432/support_tickets_fake"

# Connect to the original database
original_conn = psycopg2.connect(original_db)
original_cursor = original_conn.cursor()

# Get all tables in the public schema
original_cursor.execute("""
    SELECT tablename 
    FROM pg_tables 
    WHERE schemaname = 'public'
""")
tables = [row[0] for row in original_cursor.fetchall()]

# Filter tables
# support_tables = [t for t in tables if t.startswith('support_')]
# other_tables = [t for t in tables if not t.startswith('support_')]

support_tables = ["support_user", "support_ticket", "support_ticket_comment"]
other_tables = ["users", "plans", "projects", "project_entitlement_catalog", "invoice", "error_rate_daily", "invoice_item", "plan_entitlement_access", "project_entitlement_access", "project_plan_changelogs", "requests_daily_count"]
print(f"support_tables = {support_tables}")
print(f"other_tables = {other_tables}")

def copy_table(source_conn_str, dest_conn_str, table_name):
    """Copies a table from the source database to the destination database."""
    print(f"copying table {table_name}")
    with psycopg2.connect(source_conn_str) as src_conn, psycopg2.connect(dest_conn_str) as dest_conn:
        with src_conn.cursor() as src_cursor, dest_conn.cursor() as dest_cursor:
            # # Fetch table creation SQL
            # table_def = get_table_definition(table_name, source_conn_str)

            # # Create table in the destination database
            # dest_cursor.execute(table_def)

            # Copy data
            src_cursor.execute(sql.SQL("SELECT * FROM {}").format(sql.Identifier(table_name)))
            rows = src_cursor.fetchall()
            if rows:
                insert_query = sql.SQL("INSERT INTO {} VALUES %s").format(sql.Identifier(table_name))
                psycopg2.extras.execute_values(dest_cursor, insert_query, rows)

            dest_conn.commit()

# Copy tables
for table in support_tables:
    copy_table(original_db, support_tickets_db, table)

for table in other_tables:
    copy_table(original_db, control_plane_db, table)

# Close connections
original_cursor.close()
original_conn.close()
