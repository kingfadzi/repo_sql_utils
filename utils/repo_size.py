#!/usr/bin/env python3
import os
import argparse

def get_directory_size(path, exclude_dirs=None):
    """Calculate directory size while excluding specified subdirectories."""
    total_size = 0
    exclude = set(exclude_dirs) if exclude_dirs else set()

    for root, dirs, files in os.walk(path):
        dirs[:] = [d for d in dirs if d not in exclude]  # Skip excluded directories
        for file in files:
            file_path = os.path.join(root, file)
            if os.path.exists(file_path):  # Handle broken symlinks
                try:
                    total_size += os.path.getsize(file_path)
                except PermissionError:
                    pass  # Skip files without access permissions
    return total_size

def format_size(bytes_size):
    """Convert bytes to human-readable format."""
    for unit in ['B', 'KB', 'MB', 'GB']:
        if bytes_size < 1024:
            return f"{bytes_size:.2f} {unit}"
        bytes_size /= 1024
    return f"{bytes_size:.2f} TB"

def main():
    parser = argparse.ArgumentParser(description='Calculate local Git repository size')
    parser.add_argument('path', help='Path to local repository directory')
    args = parser.parse_args()

    repo_path = os.path.expanduser(args.path)  # Handle ~ in paths

    if not os.path.isdir(repo_path):
        print(f"Error: {repo_path} is not a valid directory")
        return

    if not os.path.exists(os.path.join(repo_path, '.git')):
        print(f"Error: {repo_path} is not a Git repository")
        return

    total_size = get_directory_size(repo_path)
    code_size = get_directory_size(repo_path, exclude_dirs=['.git'])
    git_size = total_size - code_size

    print(f"\nRepository: {repo_path}")
    print(f"Total size (with Git history): {format_size(total_size)}")
    print(f"Working directory size (code/files): {format_size(code_size)}")
    print(f".git directory size: {format_size(git_size)}")

if __name__ == "__main__":
    main()
