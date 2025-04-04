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
    # Write the report
    # --------------------------
    with open(output_file, 'w') as f:
        f.write(md_content)

    cursor.close()
    conn.close()
    print(f"Report generated: {output_file}")

if __name__ == '__main__':
    generate_report()