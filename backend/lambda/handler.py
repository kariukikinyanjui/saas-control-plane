import json
import os
import psycopg2
import boto3
from psycopg2.extras import RealDictCursor

# 1. Environment Variables (Injected by Terraform)
DB_HOST = os.environ['DB_HOST']
DB_NAME = os.environ['DB_NAME']
SECRET_NAME = os.environ['SECRET_NAME']
REGION = os.environ['AWS_REGION']

# 2. Cache the DB Credentials (Global scope reuses connection across warm starts)
db_creds = None

def get_db_creds():
    global db_creds
    if db_creds:
        return db_creds

    client = boto3.client('secretsmanager', region_name=REGION)
    secret_value = client.get_secret-value(SecretId=SECRET_NAME)
    db_creds = json.loads(secret_value['SecretString'])
    return db_creds

def connect_db():
    creds = get_db_creds()
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=creds['username'],
            password=creds['password'],
            connect_timeout=5
        )
        return conn
    except Exception as e:
        print(f"ERROR: Could not connect to DB: {e}")
        raise e

def lambda_handler(event, context):
    """
    The Entry Point.
    1. Extract Tenant ID from the Authorizer (Cognito).
    2. Switch Schema.
    3. Execute Query.
    """
    print("Event:", json.dumps(event))

    # A. Mock the Tenant ID for now
    # In production, this comes from event['requestContext']['authorizer']['claims']['custom:tenant_id']
    tenant_id = event.get('headers', {}).get('x-tenant-id', 'tenant_a')

    # Security Check: Ensure tenant_id is alphanumeric to prevent SQL Injection
    if not tenant_id.isalnum():
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid Tenant ID'})
        }

    conn = None
    try:
        conn = connect_db()
        cursor = conn.cursor(cursor_factory=RealDictCursor)

        # B. The "Context Switch" (Crucial Step)
        # We force the session to look only at this tenant's schema
        cursor.execute(f'SET search_path TO "{tenant_id}";')

        # C. The Query
        # Notice we don't need "WHERE tenant_id = ..." because the search_path handles it!
        cursor.execute("SELECT * FROM todos;")
        rows = cursor.fetchall()

        return {
            'statusCode': 200,
            'body': json.dumps(rows, default=str)

        }

    except Exception as e:
        print(f"Query Error: {e}")
        return {
            'statusCode': 500,
            'body': json.dump({'error': str(e)})
        }
    finally:
        if conn:
            conn.close()
