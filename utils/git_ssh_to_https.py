import csv

def convert_ssh_to_https(ssh_url):
    prefix = "ssh://git@"
    suffix = ".git"
    if ssh_url.startswith(prefix) and ssh_url.endswith(suffix):
        url = ssh_url[len(prefix):-len(suffix)]
        try:
            host, remainder = url.split(":", 1)
            _, path = remainder.split("/", 1)
            project, slug = path.split("/", 1)
            return f"https://{host}/scm/{project}/{slug}.git"
        except Exception as e:
            print(f"Error parsing URL '{ssh_url}': {e}")
            return ssh_url
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
            ssh_url = row.get('clone_url_ssh', '')
            row['clone_url_https'] = convert_ssh_to_https(ssh_url)
            writer.writerow(row)

if __name__ == "__main__":
    input_file = 'input.csv'
    output_file = 'output.csv'
    convert_csv(input_file, output_file)
    print("Conversion completed!")
