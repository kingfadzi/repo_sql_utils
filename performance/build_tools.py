import psycopg2
import pandas as pd
from datetime import datetime

def generate_report(output_file='build_tools_report.md'):
    # Connect to your PostgreSQL database
    conn = psycopg2.connect(
        host='192.168.1.188',
        dbname='gitlab-usage',
        user='postgres',
        password='postgres'
    )
    
    # Initialize report content
    md_content = f"""# Build Tools Metrics Report
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Data Quality Notes
- Metrics account for missing version data (NULL values)
- Rates calculated as percentages of total relevant entries
- "Unknown" indicates missing version/runtime data

"""

    # --------------------------
    # 1. Data Completeness Metrics
    # --------------------------
    md_content += "## Data Completeness\n"
    
    # Overall completeness
    total_entries = pd.read_sql("SELECT COUNT(*) FROM build_tools", conn).iloc[0,0]
    complete_entries = pd.read_sql(
        """SELECT COUNT(*) FROM build_tools 
        WHERE tool_version IS NOT NULL 
        AND runtime_version IS NOT NULL""",
        conn
    ).iloc[0,0]
    
    md_content += f"- **Overall data completeness**: {complete_entries/total_entries:.1%}\n"
    
    # Most incomplete tools
    incomplete_tools = pd.read_sql("""
        SELECT tool, 
               (COUNT(*) FILTER (WHERE tool_version IS NULL) * 100.0 / COUNT(*) AS missing_tool_ver,
               (COUNT(*) FILTER (WHERE runtime_version IS NULL) * 100.0 / COUNT(*) AS missing_runtime_ver
        FROM build_tools
        GROUP BY tool
        ORDER BY (missing_tool_ver + missing_runtime_ver) DESC
        LIMIT 5
    """, conn)
    
    md_content += "\n### Tools with Most Missing Data\n"
    md_content += incomplete_tools.to_markdown(index=False) + "\n\n"

    # --------------------------
    # 2. Tool Usage Metrics
    # --------------------------
    md_content += "## Tool Usage Analysis\n"
    
    # Top tools (excluding NULL tools)
    top_tools = pd.read_sql("""
        SELECT tool, COUNT(DISTINCT repo_id) AS repo_count
        FROM build_tools
        WHERE tool IS NOT NULL
        GROUP BY tool
        ORDER BY repo_count DESC
        LIMIT 10
    """, conn)
    
    md_content += "\n### Most Used Tools (Across Repos)\n"
    md_content += top_tools.to_markdown(index=False) + "\n\n"

    # --------------------------
    # 3. Version Management
    # --------------------------
    md_content += "## Version Management\n"
    
    # Version fragmentation (excluding NULLs)
    version_frag = pd.read_sql("""
        SELECT tool, 
               COUNT(DISTINCT tool_version) AS tool_versions,
               COUNT(DISTINCT runtime_version) AS runtime_versions
        FROM build_tools
        WHERE tool_version IS NOT NULL
        GROUP BY tool
        HAVING COUNT(DISTINCT tool_version) > 1
        ORDER BY tool_versions DESC
    """, conn)
    
    md_content += "\n### Version Fragmentation\n"
    md_content += version_frag.to_markdown(index=False) + "\n\n"

    # --------------------------
    # 4. Repository Insights
    # --------------------------
    md_content += "## Repository-Level Insights\n"
    
    # Repos with incomplete data
    repo_incomplete = pd.read_sql("""
        SELECT repo_id, 
               (COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) * 100.0 / COUNT(*)) AS incomplete_pct
        FROM build_tools
        GROUP BY repo_id
        HAVING (COUNT(*) FILTER (WHERE tool_version IS NULL OR runtime_version IS NULL) * 100.0 / COUNT(*) > 20
        ORDER BY incomplete_pct DESC
        LIMIT 10
    """, conn)
    
    md_content += "\n### Repos with >20% Missing Data\n"
    md_content += repo_incomplete.to_markdown(index=False) + "\n\n"

    # Save report
    with open(output_file, 'w') as f:
        f.write(md_content)
    
    conn.close()
    print(f"Report generated: {output_file}")

if __name__ == '__main__':
    generate_report()