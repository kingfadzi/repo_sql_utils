import psycopg2
import pandas as pd
from tabulate import tabulate
from datetime import timedelta

def analyze_pipeline(run_id):
    try:
        # Connect using provided credentials
        conn = psycopg2.connect(
            host='192.168.1.188',
            dbname='gitlab-usage',
            user='postgres',
            password='postgres'
        )
        
        # Get all pipeline data for this run
        query = f"""
            SELECT stage, repo_id, status, duration, execution_time, message 
            FROM analysis_execution_log 
            WHERE run_id = '{run_id}'
        """
        df = pd.read_sql(query, conn, parse_dates=['execution_time'])
        
        if df.empty:
            print(f"No data found for Run ID: {run_id}")
            return

        # Stage-wise statistics
        stage_stats = df.groupby('stage').agg(
            attempts=('stage', 'count'),
            success_rate=('status', lambda x: (x == 'SUCCESS').mean()),
            avg_duration=('duration', 'mean'),
            p95_duration=('duration', lambda x: x.quantile(0.95)),
            failures=('status', lambda x: (x == 'FAILURE').sum())
        ).reset_index()

        # Clone-specific analysis
        clone_data = df[df['stage'] == 'Clone Repository']
        clone_metrics = {
            'unique_clones': clone_data['repo_id'].nunique(),
            'duplicate_attempts': len(clone_data) - clone_data['repo_id'].nunique(),
            'max_concurrent': clone_data.groupby(pd.Grouper(key='execution_time', freq='1S')).size().max(),
            'longest_clone': clone_data['duration'].max()
        }

        # Temporal analysis for cloning
        clone_data = clone_data.sort_values('execution_time')
        time_deltas = clone_data['execution_time'].diff().dt.total_seconds()
        burst_analysis = {
            'max_1s_rate': clone_metrics['max_concurrent'],
            'max_10s_rate': clone_data.rolling('10S', on='execution_time').count()['repo_id'].max(),
            'median_interval': time_deltas.median()
        }

        # Generate reports
        print(f"\nPipeline Analysis for Run {run_id}")
        print("="*50)
        
        print("\nStage Performance:")
        print(tabulate(stage_stats, headers=['Stage', 'Attempts', 'Success Rate', 'Avg Duration', 'P95 Duration', 'Failures'],
                      tablefmt='psql', floatfmt=".2f"))

        print("\nClone Integrity Checks:")
        clone_integrity = pd.DataFrame({
            'Metric': ['Unique Repos Cloned', 'Duplicate Attempts', 
                      'Max Concurrent Clones', 'Longest Clone (s)'],
            'Value': [clone_metrics['unique_clones'], clone_metrics['duplicate_attempts'],
                     clone_metrics['max_concurrent'], clone_metrics['longest_clone']]
        })
        print(tabulate(clone_integrity, headers='keys', tablefmt='psql', showindex=False))

        print("\nClone Rate Analysis:")
        rate_stats = pd.DataFrame({
            'Window': ['Per Second', '10-second Window', 'Median Interval'],
            'Max Rate': [burst_analysis['max_1s_rate'], burst_analysis['max_10s_rate'], '-'],
            'Interval (s)': ['-', '-', burst_analysis['median_interval']]
        })
        print(tabulate(rate_stats, headers='keys', tablefmt='psql', showindex=False))

        # Failure analysis
        failures = df[df['status'] == 'FAILURE']
        if not failures.empty:
            print("\nFailure Patterns:")
            error_patterns = failures.groupby(['stage', 'message']).size().reset_index(name='count')
            print(tabulate(error_patterns, headers=['Stage', 'Error', 'Count'], 
                          tablefmt='psql', maxcolwidths=[None, 50]))

    except Exception as e:
        print(f"Analysis error: {str(e)}")
    finally:
        if 'conn' in locals(): conn.close()

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Analyze pipeline execution')
    parser.add_argument('run_id', help='Run ID to analyze')
    args = parser.parse_args()
    
    analyze_pipeline(args.run_id)
