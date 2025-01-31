import csv
from urllib.parse import urlparse
import sys

INPUT_CSV = 'input.csv'
OUTPUT_CSV = 'output.csv'

def convert_bitbucket_browse_to_http_clone(browse_url: str) -> str:
    if not browse_url:
        return ""
    parsed = urlparse(browse_url)
    path_parts = parsed.path.strip("/").split("/")
    if len(path_parts) < 5 or path_parts[0] != "projects" or path_parts[2] != "repos":
        return browse_url
    project_key = path_parts[1]
    repo_slug = path_parts[3]
    clone_path = f"/scm/{project_key}/{repo_slug}.git"
    clone_url = f"{parsed.scheme}://{parsed.netloc}{clone_path}"
    return clone_url

def main():
    with open(INPUT_CSV, mode="r", encoding="utf-8", newline="") as infile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames
        if "HTTP Clone URL" not in fieldnames:
            fieldnames = fieldnames + ["HTTP Clone URL"]
        with open(OUTPUT_CSV, mode="w", encoding="utf-8", newline="") as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()
            for row in reader:
                original_url = row.get("Web URL", "")
                row["HTTP Clone URL"] = convert_bitbucket_browse_to_http_clone(original_url)
                writer.writerow(row)

if __name__ == "__main__":
    if len(sys.argv) >= 2:
        INPUT_CSV = sys.argv[1]
    if len(sys.argv) >= 3:
        OUTPUT_CSV = sys.argv[2]
    main()
