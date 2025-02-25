import psycopg2
import requests
import sys
from datetime import datetime
from dateutil.parser import parse

# Database configuration
DB_CONFIG = {
    "host": "192.168.1.188",
    "port": 5422,
    "dbname": "gitlab-usage",
    "user": "postgres",
    "password": "postgres"
}

API_BASE_URL = "https://endoflife.date/api"
BATCH_SIZE = 50  # Number of products to process between commits

def create_tables(conn):
    """Create tables with proper constraints and indexes"""
    create_table_sql = """
    DROP TABLE IF EXISTS product_versions;
    DROP TABLE IF EXISTS products;
    
    CREATE TABLE products (
        product_id SERIAL PRIMARY KEY,
        name VARCHAR(255) UNIQUE NOT NULL,
        product_type VARCHAR(50),
        vendor VARCHAR(100)
    );

    CREATE TABLE product_versions (
        version_id SERIAL PRIMARY KEY,
        product_id INTEGER NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
        cycle VARCHAR(20) NOT NULL,
        eol_date DATE,
        latest_version VARCHAR(50),
        release_date DATE,
        lts BOOLEAN DEFAULT false,
        UNIQUE(product_id, cycle)
    );

    CREATE INDEX idx_product_eol_date ON product_versions(eol_date);
    CREATE INDEX idx_product_release_date ON product_versions(release_date);
    """
    with conn.cursor() as cursor:
        cursor.execute(create_table_sql)
    conn.commit()

def get_or_create_product(conn, product_name):
    """Get existing product ID or insert new product"""
    with conn.cursor() as cursor:
        cursor.execute(
            "INSERT INTO products (name) VALUES (%s) ON CONFLICT (name) DO NOTHING RETURNING product_id",
            (product_name,)
        )
        result = cursor.fetchone()
        if result:
            return result[0]
        
        cursor.execute(
            "SELECT product_id FROM products WHERE name = %s",
            (product_name,)
        )
        return cursor.fetchone()[0]

def validate_date(date_value):
    """Convert various date formats to ISO date or return None"""
    if isinstance(date_value, bool):
        return None
    
    if not date_value:
        return None

    try:
        return parse(date_value).date().isoformat()
    except (ValueError, TypeError):
        return None

def process_product(conn, product_name):
    """Fetch and insert versions for a single product"""
    try:
        response = requests.get(f"{API_BASE_URL}/{product_name}.json", timeout=15)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"\nError fetching {product_name}: {str(e)}")
        return None

def insert_versions(conn, product_id, versions):
    """Bulk insert versions for a product with proper type validation"""
    insert_sql = """
    INSERT INTO product_versions (
        product_id, cycle, eol_date, latest_version, release_date, lts
    ) VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (product_id, cycle) DO UPDATE SET
        eol_date = EXCLUDED.eol_date,
        latest_version = EXCLUDED.latest_version,
        release_date = EXCLUDED.release_date,
        lts = EXCLUDED.lts
    """
    
    success = True
    with conn.cursor() as cursor:
        for version in versions:
            try:
                # Validate and convert dates
                eol_date = validate_date(version.get('eol'))
                release_date = validate_date(version.get('releaseDate'))
                
                cursor.execute(insert_sql, (
                    product_id,
                    str(version.get('cycle', '')),
                    eol_date,
                    version.get('latest'),
                    release_date,
                    bool(version.get('lts', False))
                ))
            except Exception as e:
                print(f"\nError inserting version {version.get('cycle')}: {str(e)}")
                print(f"Problematic data: {version}")
                success = False
                conn.rollback()
                continue
                
    return success

def main():
    start_time = datetime.now()
    print(f"Starting EOL data load at {start_time}")
    
    try:
        # Connect to database
        conn = psycopg2.connect(**DB_CONFIG)
        conn.autocommit = False
        
        # Initialize schema
        print("Creating tables...")
        create_tables(conn)
        
        # Get product list
        print("Fetching product list...")
        products = requests.get(f"{API_BASE_URL}/all.json").json()
        total_products = len(products)
        print(f"Found {total_products} products to process")
        
        # Process products in batches
        success_count = 0
        error_count = 0
        for idx, product_name in enumerate(products, 1):
            try:
                print(f"\rProcessing {idx}/{total_products}: {product_name.ljust(30)}", end="")
                
                # Get product data
                versions = process_product(conn, product_name)
                if not versions:
                    error_count += 1
                    continue
                
                # Get/Create product
                product_id = get_or_create_product(conn, product_name)
                
                # Insert versions
                if insert_versions(conn, product_id, versions):
                    success_count += 1
                
                # Commit in batches
                if idx % BATCH_SIZE == 0:
                    conn.commit()
                    
            except Exception as e:
                print(f"\nError processing {product_name}: {str(e)}")
                error_count += 1
                conn.rollback()
        
        # Final commit
        conn.commit()
        
    except psycopg2.OperationalError as e:
        print(f"\nFatal database error: {str(e)}")
        print("Check your connection parameters and database status")
        sys.exit(1)
    finally:
        if 'conn' in locals():
            conn.close()
    
    duration = datetime.now() - start_time
    print(f"\n\nCompleted in {duration.total_seconds():.2f} seconds")
    print(f"Successfully processed: {success_count}")
    print(f"Failed products: {error_count}")

if __name__ == "__main__":
    # Verify dependencies
    try:
        import psycopg2
        import requests
        from dateutil.parser import parse
    except ImportError as e:
        print(f"Missing dependencies: {str(e)}")
        print("Run: pip install psycopg2-binary requests python-dateutil")
        sys.exit(1)
    
    main()
