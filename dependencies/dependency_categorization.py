#!/usr/bin/env python3
import pandas as pd
import re
import yaml
from sqlalchemy import create_engine
import psycopg2

# Mapping of package type to YAML rule file.
# For Java, we're using the hierarchical rule file.
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
    """
    Load and compile hierarchical regex rules from a YAML file.
    Returns a flat list of tuples: (compiled_regex, top_category, sub_category)
    If a top-level category doesn't define subcategories, sub_category is set to None.
    """
    try:
        with open(rule_file, 'r') as f:
            rules = yaml.safe_load(f)
        compiled_list = []
        for cat in rules.get('categories', []):
            top_category = cat.get('name', 'Other')
            if 'subcategories' in cat:
                for sub in cat.get('subcategories', []):
                    sub_category = sub.get('name', 'Other')
                    for pattern in sub.get('patterns', []):
                        compiled_list.append((re.compile(pattern, re.IGNORECASE), top_category, sub_category))
            else:
                # No subcategories: compile flat rules with sub_category set to None.
                for pattern in cat.get('patterns', []):
                    compiled_list.append((re.compile(pattern, re.IGNORECASE), top_category, None))
        return compiled_list
    except Exception as e:
        print(f"Error loading {rule_file}: {e}")
        return []

def get_compiled_rules(package_type):
    """
    Get compiled rules for the given package type using caching.
    Returns a flat list of tuples: (compiled_regex, top_category, sub_category)
    """
    rule_file = rules_mapping.get(package_type.lower())
    if not rule_file:
        return []
    if rule_file not in compiled_rules_cache:
        compiled_rules_cache[rule_file] = load_and_compile_rules(rule_file)
    return compiled_rules_cache[rule_file]

def categorize_dependency(dependency_name, compiled_rules):
    """
    Iterate through the flat list of compiled rules and return a tuple (category, sub_category).
    If no pattern matches, returns ("Other", "").
    """
    for regex, top_cat, sub_cat in compiled_rules:
        if regex.search(dependency_name):
            return top_cat, sub_cat if sub_cat is not None else ""
    return "Other", ""

def main():
    # Connect to PostgreSQL using the provided credentials.
    engine = create_engine('postgresql://postgres:postgres@192.168.1.188:5422/gitlab-usage')

    # Load the dependencies table into a DataFrame.
    # Expected columns: id, repo_id, name, version, package_type (all lower case)
    df = pd.read_sql_table('dependencies', con=engine)

    # Ensure package_type is lower case for consistent mapping.
    df['package_type_lower'] = df['package_type'].str.lower()
    df['category'] = "Other"      # Top-level category default
    df['sub_category'] = ""       # Sub-category default (empty if not applicable)

    # Process each package type group separately.
    for pkg_type, group in df.groupby('package_type_lower', observed=True):
        compiled_rules = get_compiled_rules(pkg_type)
        if not compiled_rules:
            continue
        # Initialize Series for category and sub_category with default values.
        top_categories = pd.Series("Other", index=group.index)
        sub_categories = pd.Series("", index=group.index)

        # Iterate over the precompiled regex rules.
        for regex, top_cat, sub_cat in compiled_rules:
            matches = group['name'].str.contains(regex, na=False)
            update_mask = matches & (top_categories == "Other")
            top_categories.loc[update_mask] = top_cat
            sub_categories.loc[update_mask] = sub_cat if sub_cat is not None else ""

        df.loc[group.index, 'category'] = top_categories
        df.loc[group.index, 'sub_category'] = sub_categories

    # Write the resulting DataFrame to a CSV file.
    output_file = "categorized_dependencies.csv"
    df[['repo_id', 'name', 'version', 'package_type', 'category', 'sub_category']].to_csv(output_file, index=False)
    print(f"Results written to {output_file}")

if __name__ == '__main__':
    main()
