import psycopg2
import pandas as pd
from datetime import datetime

def generate_report(output_file='build_tools_report.md'):
    # Connect using SQLAlchemy-style connection string to avoid pandas warning
    conn = psycopg2.connect(
        host='192.168.1.188',
        dbname='gitlab-usage',
        user='postgres',
        password='postgres'
    )
    
    md_content = f"""# Build Tools Metrics Report
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Data Quality Notes
- Metrics account for missing version data (NULL values)
- Rates calculated as percentages of total relevant entries

"""

    # --------------------------
    # 1. Data Completeness Metrics (FIXED ORDER BY)
    # --------------------------
    md_content += "## Data Completeness\n"
    
    # Most incomplete tools - Fixed SQL
    incomplete_tools = pd.read_sql("""
        SELECT tool, 
               (COUNT(*) FILTER (WHERE tool_version IS NULL) * 100.0 / COUNT(*) AS missing_tool_ver,
               (COUNT(*) FILTER (WHERE runtime_version IS NULL) * 100.0 / COUNT(*) AS missing_runtime_ver
        FROM build_tools
        GROUP BY tool
        ORDER BY (COUNT(*) FILTER (WHERE tool_version IS NULL) + 
                  COUNT(*) FILTER (WHERE runtime_version IS NULL)) DESC
        LIMIT 5
    """, conn)
    
    md_content += "\n### Tools with Most Missing Data\n"
    md_content += incomplete_tools.to_markdown(index=False) + "\n\n"

    # --------------------------
    # 2. Repository Insights (FIXED HAVING CLAUSE)
    # --------------------------
    md_content += "## Repository-Level Insights\n"
    
    # Repos with incomplete data - Fixed SQL
    repo_incomplete = pd.read_sql("""
        SELECT repo_id, 
               (COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) * 100.0 / COUNT(*)) AS incomplete_pct
        FROM build_tools
        GROUP BY repo_id
        HAVING (COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) * 100.0 / COUNT(*)) > 20
        ORDER BY incomplete_pct DESC
        LIMIT 10
    """, conn)
    
    md_content += "\n### Repos with >20% Missing Data\n"
    md_content += repo_incomplete.to_markdown(index=False) + "\n\n"

    # Rest of the script remains the same...
    # [Keep other sections unchanged]

    with open(output_file, 'w') as f:
        f.write(md_content)
    
    conn.close()
    print(f"Report generated: {output_file}")

if __name__ == '__main__':
    generate_report()