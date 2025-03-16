import requests
import argparse
from urllib.parse import quote

def get_maven_artifacts(group_prefix, output_file, max_rows=200):
    base_url = "https://search.maven.org/solrsearch/select"
    encoded_query = quote(f'g:{group_prefix}*')

    start = 0
    total_processed = 0

    with open(output_file, 'w') as f:
        while True:
            url = (f"{base_url}?q={encoded_query}&wt=json"
                   f"&rows={max_rows}&start={start}")

            try:
                response = requests.get(url)
                response.raise_for_status()
                data = response.json()

                docs = data.get('response', {}).get('docs', [])
                if not docs:
                    break

                for doc in docs:
                    group = doc.get('g', '')
                    artifact = doc.get('a', '')
                    if group and artifact:
                        f.write(f"{group}:{artifact}\n")

                print(f"Processed {len(docs)} items (total: {total_processed + len(docs)})")
                total_processed += len(docs)
                start += max_rows

            except requests.exceptions.RequestException as e:
                print(f"Error making request: {e}")
                break
            except ValueError as e:
                print(f"Error parsing JSON: {e}")
                break

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Fetch Maven artifacts by group prefix')
    parser.add_argument('group_prefix', help='Group ID prefix (e.g., io.micronaut)')
    args = parser.parse_args()

    output_file = f"{args.group_prefix}.txt"
    print(f"Searching for group IDs starting with: {args.group_prefix}")
    print(f"Writing results to: {output_file}")

    get_maven_artifacts(args.group_prefix, output_file)
