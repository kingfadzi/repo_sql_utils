#!/usr/bin/env python3
import pandas as pd
import re
import yaml
import os
import logging
import time
from sqlalchemy import create_engine

# 🔹 Set up logging
logging.basicConfig(
    filename="categorization.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)
console = logging.StreamHandler()
console.setLevel(logging.INFO)
logging.getLogger().addHandler(console)

# 🔹 Constants
CHUNK_SIZE = 50000
OUTPUT_FILE = "categorized_dependencies.parquet"

# 🔹 Database connection
engine = create_engine('postgresql://postgres:postgres@192.168.1.188:5422/gitlab-usage')

# 🔹 Mapping package types to YAML rule files
RULES_MAPPING = {
    "pip": "rules_python.yaml",
    "maven": "rules_java.yaml",
    "gradle": "rules_java.yaml",
    "npm": "rules_javascript.yaml",
    "yarn": "rules_javascript.yaml",
    "go": "rules_go.yaml"
}

# 🔹 Cache compiled rules
compiled_rules_cache = {}

def load_rules(rule_file):
    """Load YAML rules and compile regex patterns."""
    try:
        with open(rule_file, 'r') as f:
            rules = yaml.safe_load(f)
        compiled_list = [
            (re.compile(pattern, re.IGNORECASE), cat['name'], sub.get('name', ""))
            for cat in rules.get('categories', [])
            for sub in cat.get('subcategories', [{"name": ""}]) 
            for pattern in sub.get('patterns', cat.get('patterns', []))
        ]
        logging.info(f"Loaded {len(compiled_list)} rules from {rule_file}")
        return compiled_list
    except Exception as e:
        logging.error(f"Error loading {rule_file}: {e}")
        return []

def get_compiled_rules(package_type):
    """Retrieve compiled rules for a package type with caching."""
    rule_file = RULES_MAPPING.get(package_type.lower())
    if not rule_file:
        return []
    if rule_file not in compiled_rules_cache:
        compiled_rules_cache[rule_file] = load_rules(rule_file)
    return compiled_rules_cache[rule_file]

def apply_categorization(df):
    """Batch categorize dependencies using vectorized regex."""
    start_time = time.time()
    df["category"], df["sub_category"] = "Other", ""

    package_types = df["package_type"].unique()
    
    for pkg_type in package_types:
        compiled_rules = get_compiled_rules(pkg_type)
        if not compiled_rules:
            continue

        regex_patterns, categories, sub_categories = zip(*compiled_rules)
        full_regex = "|".join(f"({pattern.pattern})" for pattern in regex_patterns)
        matches = df["name"].str.extract(full_regex, expand=False)

        for i, col in enumerate(matches.columns):
            matched_rows = matches[col].notna()
            df.loc[matched_rows & (df["category"] == "Other"), ["category", "sub_category"]] = (
                categories[i], sub_categories[i]
            )

    duration = time.time() - start_time
    logging.info(f"Categorization completed for {len(df)} rows in {duration:.2f} seconds")
    return df

def process_data():
    """Reads, categorizes, and processes data in chunks."""
    logging.info("Starting data processing...")
    
    query = """
        SELECT d.repo_id, d.name, d.version, d.package_type, 
               b.tool, b.tool_version, b.runtime_version
        FROM dependencies d 
        LEFT JOIN build_tools b ON d.repo_id = b.repo_id
        WHERE d.package_type IS NOT NULL
    """

    first_chunk = True
    total_rows = 0
    start_time = time.time()

    with engine.connect() as conn:
        for chunk_idx, chunk in enumerate(pd.read_sql(query, con=conn, chunksize=CHUNK_SIZE)):
            chunk_start_time = time.time()
            logging.info(f"Processing chunk {chunk_idx + 1} (size: {len(chunk)})...")
            
            chunk = apply_categorization(chunk)

            # Write output (append mode)
            chunk.to_parquet(OUTPUT_FILE, engine="fastparquet", index=False, compression="snappy", append=not first_chunk)
            first_chunk = False
            total_rows += len(chunk)

            chunk_duration = time.time() - chunk_start_time
            logging.info(f"Chunk {chunk_idx + 1} processed in {chunk_duration:.2f} seconds")

    total_duration = time.time() - start_time
    logging.info(f"Processing complete: {total_rows} rows processed in {total_duration:.2f} seconds")
    print(f"Processing complete. Output written to {OUTPUT_FILE}")

if __name__ == '__main__':
    process_data()