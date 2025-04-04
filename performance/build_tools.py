import psycopg2
import pandas as pd
from datetime import datetime

def generate_report(output_file='build_tools_report.md'):
    conn = psycopg2.connect(
        host='192.168.1.188',
        dbname='gitlab-usage',
        user='postgres',
        password='postgres'
    )
    cursor = conn.cursor()

    md_content = f"""# Build Tools Metrics Report
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Data Quality Notes
- Metrics account for missing version data (NULL values)
- Rates calculated as percentages of total relevant entries

"""

    # --------------------------
    # 1. Data Completeness Metrics
    # --------------------------
    md_content += "## Data Completeness\n"

    incomplete_tools_query = """
        SELECT tool,
               COUNT(*) AS total_entries,
               COUNT(*) FILTER (WHERE tool_version IS NULL) AS missing_tool_ver_count,
               ROUND(COUNT(*) FILTER (WHERE tool_version IS NULL) * 100.0 / COUNT(*), 2) AS missing_tool_ver_pct,
               COUNT(*) FILTER (WHERE runtime_version IS NULL) AS missing_runtime_ver_count,
               ROUND(COUNT(*) FILTER (WHERE runtime_version IS NULL) * 100.0 / COUNT(*), 2) AS missing_runtime_ver_pct
        FROM build_tools
        GROUP BY tool
        ORDER BY (COUNT(*) FILTER (WHERE tool_version IS NULL) + 
                  COUNT(*) FILTER (WHERE runtime_version IS NULL)) DESC
        LIMIT 5
    """
    incomplete_tools = pd.read_sql(incomplete_tools_query, conn)
    
    md_content += "\n### Tools with Most Missing Data\n"
    md_content += incomplete_tools.to_markdown(index=False) + "\n\n"

    # --------------------------
    # 2. Repository-Level Insights
    # --------------------------
    md_content += "## Repository-Level Insights\n"

    repo_incomplete_query = """
        SELECT repo_id,
               COUNT(*) AS total_entries,
               COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) AS missing_entries_count,
               ROUND(COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) * 100.0 / COUNT(*), 2) AS incomplete_pct
        FROM build_tools
        GROUP BY repo_id
        HAVING (COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) * 100.0 / COUNT(*)) > 20
        ORDER BY incomplete_pct DESC
        LIMIT 10
    """
    cursor.execute(repo_incomplete_query)
    repo_incomplete_records = cursor.fetchall()
    repo_incomplete_cols = [desc[0] for desc in cursor.description]
    repo_incomplete_df = pd.DataFrame(repo_incomplete_records, columns=repo_incomplete_cols)
    
    md_content += "\n### Repos with >20% Missing Data\n"
    md_content += repo_incomplete_df.to_markdown(index=False) + "\n\n"

    # --------------------------
    # 3. Build Tool Identification Completeness
    # --------------------------
    md_content += "## Build Tool Identification Completeness\n"

    build_tool_completeness_query = """
    WITH build_tool_summary AS (
        SELECT
            repo_id,
            COUNT(*) AS tool_count,
            COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) AS incomplete_tool_count
        FROM build_tools
        GROUP BY repo_id
    )
    SELECT
        CASE
            WHEN bts.repo_id IS NULL THEN 'No Build Tool Detected'
            WHEN bts.incomplete_tool_count = 0 THEN 'Build Tool Detected, Complete Data'
            ELSE 'Build Tool Detected, Incomplete Data'
        END AS build_tool_status,
        COUNT(*) AS repo_count,
        ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM combined_repo_metrics), 2) AS percent_of_repos
    FROM combined_repo_metrics crm
    LEFT JOIN build_tool_summary bts ON crm.repo_id = bts.repo_id
    GROUP BY build_tool_status
    ORDER BY repo_count DESC
    """

    build_tool_completeness = pd.read_sql(build_tool_completeness_query, conn)

    md_content += "\n### Summary\n"
    md_content += build_tool_completeness.to_markdown(index=False) + "\n\n"

    # --------------------------
    # Write the report
    # --------------------------
    with open(output_file, 'w') as f:
        f.write(md_content)

    cursor.close()
    conn.close()
    print(f"Report generated: {output_file}")

if __name__ == '__main__':
    generate_report()