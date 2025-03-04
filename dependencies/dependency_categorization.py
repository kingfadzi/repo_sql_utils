#!/usr/bin/env python3
import pandas as pd
import re
import yaml
from sqlalchemy import create_engine

# Mapping of package type to YAML rule file.
rules_mapping = {
    "pip": "rules_python.yaml",
    "maven": "rules_java.yaml",
    "gradle": "rules_java.yaml",
    "npm": "rules_javascript.yaml",
    "yarn": "rules_javascript.yaml",
    "go": "rules_go.yaml"
}

# Cache for precompiled rules for each YAML file.
compiled_rules_cache = {}

def load_and_compile_rules(rule_file):
    """Load and compile regex rules from YAML file."""
    try:
        with open(rule_file, 'r') as f:
            rules = yaml.safe_load(f)
        # Flatten all categories into a list of tuples: (compiled_regex, category_name)
        return [
            (re.compile(pattern, re.IGNORECASE), cat['name'])
            for cat in rules.get('categories', [])
            for pattern in cat.get('patterns', [])
        ]
    except Exception as e:
        print(f"Error loading {rule_file}: {e}")
        return []

def get_compiled_rules(package_type):
    """Get compiled rules for package type with caching."""
    rule_file = rules_mapping.get(package_type.lower())
    if not rule_file:
        return []
    
    if rule_file not in compiled_rules_cache:
        compiled_rules_cache[rule_file] = load_and_compile_rules(rule_file)
    return compiled_rules_cache[rule_file]

def main():
    # Database setup: connect to the PostgreSQL database using the provided credentials.
    engine = create_engine('postgresql://postgres:postgres@192.168.1.188:5422/gitlab-usage')
    
    # Load the dependencies table into a DataFrame.
    # Expected columns: id, repo_id, name, version, package_type (all lower case)
    df = pd.read_sql_table('dependencies', con=engine)
    
    # Ensure package_type is lower case for consistent mapping.
    df['package_type_lower'] = df['package_type'].str.lower()
    df['technology_category'] = 'Other'  # Default category
    
    # Process each package type group separately.
    for pkg_type, group in df.groupby('package_type_lower', observed=True):
        compiled_rules = get_compiled_rules(pkg_type)
        if not compiled_rules:
            continue
        # Initialize a Series for the category assignment, defaulting to 'Other'
        categories = pd.Series('Other', index=group.index)
        
        # Iterate over each precompiled regex and assign the first matching category.
        for regex, category in compiled_rules:
            matches = group['name'].str.contains(regex, na=False)
            update_mask = matches & (categories == 'Other')
            categories.loc[update_mask] = category
        
        df.loc[group.index, 'technology_category'] = categories
    
    # Output the resulting DataFrame to STDOUT.
    print(df[['repo_id', 'name', 'version', 'package_type', 'technology_category']])

if __name__ == '__main__':
    main()