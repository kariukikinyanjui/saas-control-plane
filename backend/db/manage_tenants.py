import boto3
import psycopg2
import sys
import json
import os


# 1. Configuration (Tunnel settings)
DB_HOST = "localhost"
DB_PORT = "5433"
DB_NAME = "postgres"
REGION  = "us-east-1"
SECRET_NAME = "saas-control-plane-db-credentials-dev"

def get_db_credentials():
    """Retrieve password from AWS Secrets Manager"""
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=REGION)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=SECRET_NAME)
        secret = json.loads(get_secret_value_response['SecretString'])
        return secret
    except Exception as e:
        print(f"Error retrieving secrets: {e}")
        sys.exit(1)

def provision_tenant(tenant_id):
    """Creates a new schema and tables for a tenant"""
    print(f"Provisioning tenant: {tenant_id}...")

    creds = get_db_credentials()

    try:
        # Connect to the DB (via the Tunnel)
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=creds['username'],
            password=creds['password']
        )
        conn.autocommit = True
        cursor = conn.cursor()

        # 1. Create the Schema
        print(f"    Creating schema '{tenant_id}'...")
        cursor.execute(f"CREATE SCHEMA IF NOT EXISTS \"{tenant_id}\";")

        # 2. Read the Blueprint
        with open('schema.sql', 'r') as f:
            sql_template = f.read()

        # 3. Apply the Blueprint to the Schema
        # Replace {schema} with the actual tenant_id
        sql_script = sql_template.format(schema=f'"{tenant_id}"')

        print(f"    Creating tables in '{tenant_id}'...")
        cursor.execute(sql_script)

        print(f"✅ Tenant '{tenant_id}' provisioned successfully!")
    
    except Exception as e:
        print(f"❌ Database Error: {e}")
    finally:
        if conn:
            conn.close()

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python manage_tenants.py <tenant_id>")
        sys.exit(1)

    tenant_id = sys.argv[1]
    provision_tenant(tenant_id)
