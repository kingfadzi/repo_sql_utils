import csv
from urllib.parse import urlparse
import sys

INPUT_CSV = 'input.csv'
OUTPUT_CSV = 'output.csv'

def convert_bitbucket_browse_to_http_clone(browse_url: str) -> str:
    if not browse_url:
        print("No browse_url provided. Returning empty string.")
        return ""
    parsed = urlparse(browse_url)
    path_parts = parsed.path.strip("/").split("/")
    print(f"Parsed path_parts = {path_parts}")
    if len(path_parts) < 5 or path_parts[0] != "projects" or path_parts[2] != "repos":
        print("URL doesn't match the expected pattern. Returning original URL.")
        return browse_url
    project_key = path_parts[1]
    repo_slug = path_parts[3]
    clone_path = f"/scm/{project_key}/{repo_slug}.git"
    clone_url = f"{parsed.scheme}://{parsed.netloc}{clone_path}"
    print(f"Converted URL: {browse_url} -> {clone_url}")
    return clone_url

def main():
    with open(INPUT_CSV, "r", encoding="utf-8", newline="") as infile:
        reader = csv.DictReader(infile)
        if not reader.fieldnames:
            print("No columns found in CSV. Exiting.")
            return
        print(f"Columns found: {reader.fieldnames}")
        fieldnames = reader.fieldnames
        if "HTTP Clone URL" not in fieldnames:
            fieldnames = fieldnames + ["HTTP Clone URL"]
        with open(OUTPUT_CSV, "w", encoding="utf-8", newline="") as outfile:
            writer = csv.DictWriter(outfile, fieldnames=fieldnames)
            writer.writeheader()
            row_count = 0
            for row in reader:
                row_count += 1
                original_url = row.get("Web URL", "")
                print(f"Processing row {row_count}, Web URL = {original_url}")
                row["HTTP Clone URL"] = convert_bitbucket_browse_to_http_clone(original_url)
                writer.writerow(row)
    print(f"Processing completed. Output written to {OUTPUT_CSV}")

if __name__ == "__main__":
    if len(sys.argv) >= 2:
        INPUT_CSV = sys.argv[1]
    if len(sys.argv) >= 3:
        OUTPUT_CSV = sys.argv[2]
    main()
