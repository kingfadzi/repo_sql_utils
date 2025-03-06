#!/usr/bin/env python3
import pandas as pd
import re
import yaml
import os
from sqlalchemy import create_engine

# Constants
CHUNK_SIZE = 50000  # Adjust based on memory availability
OUTPUT_FILE = "categorized_dependencies.csv"

# Database connection
engine = create_engine('postgresql://postgres:postgres@192.168.1.188:5422/gitlab-usage')

# Mapping package types to YAML rule files
RULES_MAPPING = {
    "pip": "rules_python.yaml",
    "maven": "rules_java.yaml",
    "gradle": "rules_java.yaml",
    "npm": "rules_javascript.yaml",
    "yarn": "rules_javascript.yaml",
    "go": "rules_go.yaml"
}

# Cache compiled regex rules
compiled_rules_cache = {}

def load_rules(rule_file):
    """Load YAML rules and compile regex patterns."""
    try:
        with open(rule_file, 'r') as f:
            rules = yaml.safe_load(f)
        return [
            (re.compile(pattern, re.IGNORECASE), cat['name'], sub.get('name', ""))
            for cat in rules.get('categories', [])
            for sub in cat.get('subcategories', [{"name": ""}])  # Handle categories without subcategories
            for pattern in sub.get('patterns', cat.get('patterns', []))
        ]
    except Exception as e:
        print(f"Error loading {rule_file}: {e}")
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
    """Categorize dependencies using vectorized regex matching."""
    df["category"], df["sub_category"] = "Other", ""
    
    for pkg_type in df["package_type"].unique():
        compiled_rules = get_compiled_rules(pkg_type)
        if not compiled_rules:
            continue
        
        for regex, top_cat, sub_cat in compiled_rules:
            matches = df["name"].str.contains(regex, na=False)
            df.loc[matches & (df["category"] == "Other"), ["category", "sub_category"]] = (top_cat, sub_cat)
    
    return df

def process_data():
    """Reads, categorizes, and processes data in chunks."""
    query = """
        SELECT d.repo_id, d.name, d.version, d.package_type, 
               b.tool, b.tool_version, b.runtime_version
        FROM dependencies d 
        LEFT JOIN build_tools b ON d.repo_id = b.repo_id
    """

    first_chunk = True
    with engine.connect() as conn:
        for chunk in pd.read_sql(query, con=conn, chunksize=CHUNK_SIZE):
            categorized_chunk = apply_categorization(chunk)
            categorized_chunk.to_csv(OUTPUT_FILE, mode='a', index=False, header=first_chunk)
            first_chunk = False

    print(f"Processing complete. Output written to {OUTPUT_FILE}")

if __name__ == '__main__':
    process_data()