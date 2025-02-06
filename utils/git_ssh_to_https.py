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

        project, repository = path.split("/", 1)

        return f"https://{host}/scm/{project}/{repository}.git"
    else:
        print(f"Invalid URL format: {ssh_url}")
        return ssh_url

def convert_csv(input_file, output_file):
    with open(input_file, mode='r') as infile, open(output_file, mode='w', newline='') as outfile:
        reader = csv.reader(infile)
        writer = csv.writer(outfile)

        header = next(reader)
        writer.writerow(header + ['https_clone_url'])

        for row in reader:
            ssh_url = row[0]
            https_url = convert_ssh_to_https(ssh_url)
            writer.writerow(row + [https_url])

if __name__ == "__main__":
    input_file = 'input.csv'
    output_file = 'output.csv'
    convert_csv(input_file, output_file)
    print("Conversion completed!")
