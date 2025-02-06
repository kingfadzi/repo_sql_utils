import csv

def convert_ssh_to_https(ssh_url):
    prefix = "ssh://git@"
    suffix = ".git"

    if ssh_url.startswith(prefix) and ssh_url.endswith(suffix):
        url_without_prefix = ssh_url[len(prefix):]
        url_without_suffix = url_without_prefix[:-len(suffix)]

        host_and_path = url_without_suffix.split(":", 1)
        host = host_and_path[0]
        path = host_and_path[1]

        project, slug = path.split("/", 1)

        return f"https://{host}/scm/{project}/{slug}.git"
    else:
        print(f"Invalid URL format: {ssh_url}")
        return ssh_url

def convert_csv(input_file, output_file):
    with open(input_file, mode='r') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.DictReader(infile)
        fieldnames = reader.fieldnames + ['clone_url_https']
        writer = csv.DictWriter(outfile, fieldnames=fieldnames)

        writer.writeheader()

        for row in reader:
            ssh_url = row['clone_url_ssh']
            https_url = convert_ssh_to_https(ssh_url)
            row['clone_url_https'] = https_url
            writer.writerow(row)

if __name__ == "__main__":
    input_file = 'input.csv'  # Path to your input CSV file
    output_file = 'output.csv'  # Path to your output CSV file
    convert_csv(input_file, output_file)
    print("Conversion completed!")
