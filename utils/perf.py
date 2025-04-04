import psycopg2
import pandas as pd
from datetime import datetime
from tabulate import tabulate

def generate_clone_report(run_id, output_file="clone_analysis.md"):
    """Generate Markdown report of clone metrics from PostgreSQL filtered by run ID."""
    try:
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host='192.168.1.188',
            dbname='gitlab-usage',
            user='postgres',
            password='postgres'
        )
        
        # Query clone operations filtered by run ID
        query = f"""
            SELECT repo_id, status, message, duration, execution_time 
            FROM analysis_execution_log 
            WHERE stage = 'Clone Repository' AND run_id = '{run_id}'
        """
        df = pd.read_sql(query, conn, parse_dates=['execution_time'])
        
        if df.empty:
            raise ValueError(f"No clone data found in database for run ID: {run_id}")
            
        # Core metrics
        total = len(df)
        success_rate = df[df['status'] == 'SUCCESS'].shape[0] / total
        duration_stats = df['duration'].describe(percentiles=[.25, .5, .75, .95])
        
        # Failure analysis
        failures = df[df['status'] == 'FAILURE']
        error_patterns = failures['message'].str.extract(r'ERROR: (.*?)\n', expand=False).value_counts()
        
        # Temporal analysis
        # Create columns for per-second and per-minute buckets
        df['second'] = df['execution_time'].dt.floor('S')
        df['minute'] = df['execution_time'].dt.floor('T')
        peak_sec = df.groupby('second').size().max()
        peak_min = df.groupby('minute').size().max()
        
        # Compute additional temporal metrics using sorted data
        df_sorted = df.sort_values('execution_time')
        max_10s_rate = df_sorted.rolling('10S', on='execution_time').count()['repo_id'].max()
        median_interval = df_sorted['execution_time'].diff().median().total_seconds()
        
        # Repository analysis (longest clones)
        repo_stats = df.groupby('repo_id').agg(
            max_duration=('duration', 'max'),
            avg_duration=('duration', 'mean')
        ).nlargest(10, 'max_duration')
        
        # Generate markdown content
        md_content = f"""# Clone Operation Analysis Report
**Run ID**: {run_id}  
**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}  
**Data Source**: `analysis_execution_log` table  

## Core Metrics
| Metric                | Value          |
|-----------------------|----------------|
| Total Attempts        | {total}        |
| Success Rate          | {success_rate:.1%} |
| Average Duration      | {duration_stats['mean']:.2f}s |
| Median Duration       | {duration_stats['50%']:.2f}s |
| 95th Percentile       | {duration_stats['95%']:.2f}s |
| Minimum Duration      | {duration_stats['min']:.2f}s |
| Maximum Duration      | {duration_stats['max']:.2f}s |

## Request Patterns
- **Peak clones/second**: {peak_sec}
- **Peak clones/10-second window**: {max_10s_rate}
- **Peak clones/minute**: {peak_min}
- **Median time between clones**: {median_interval:.2f}s

## Failure Analysis
"""
        if not error_patterns.empty:
            md_content += "\n| Error Pattern | Count |\n|---------------|-------|\n"
            for error, count in error_patterns.items():
                md_content += f"| `{error}` | {count} |\n"
                
        md_content += "\n## Longest Clones\n"
        md_content += tabulate(
            repo_stats.reset_index().rename(columns={
                'repo_id': 'Repository',
                'max_duration': 'Max Duration (s)',
                'avg_duration': 'Avg Duration (s)'
            }),
            headers='keys',
            tablefmt='pipe',
            showindex=False,
            floatfmt=".2f"
        )
        
        # Write the markdown report to file
        with open(output_file, 'w') as f:
            f.write(md_content)
            
        return output_file

    except Exception as e:
        print(f"Error generating report: {str(e)}")
        raise
    finally:
        if 'conn' in locals():
            conn.close()

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Generate clone report for a given run ID')
    parser.add_argument('run_id', help='Run ID to filter the clone report')
    parser.add_argument('--output_file', default="clone_analysis.md", help="Output markdown file")
    args = parser.parse_args()
    
    report_file = generate_clone_report(args.run_id, output_file=args.output_file)
    print(f"Report generated: {report_file}")