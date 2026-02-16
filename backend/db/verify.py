import psycopg2
import json
import boto3

DB_HOST = "localhost"
DB_PORT = "5433"
DB_NAME = "postgres"
REGION = "us-east-1"
SECRET_NAME = "saas-control-plane-db-credentials-dev"

# Get Creds
session = boto3.session.Session()
client = session.client(service_name='secretsmanager', region_name=REGION)
creds = json.loads(client.get_secret_value(SecretId=SECRET_NAME)['SecretString'])

# Connect
conn = psycopg2.connect(
    host=DB_HOST, port=DB_PORT, database=DB_NAME,
    user=creds['username'], password=creds['password']
)
cursor = conn.cursor()

# Query: List all Schemas
print("\n🔍 Existing Schemas:")
cursor.execute("SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT IN ('information_schema', 'pg_catalog', 'pg_toast');")
for row in cursor.fetchall():
    print(f" - {row[0]}")

# Query: List Tables in 'tenant_a'
print("\n📄 Tables in 'tenant_a':")
cursor.execute("SELECT table_name FROM information_schema.tables WHERE table_schema = 'tenant_a';")
for row in cursor.fetchall():
    print(f" - {row[0]}")

conn.close()
