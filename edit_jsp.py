import os
import re


def edit_jsp_file(file_path):
    # Open the .jsp file and read its content using Windows-1251 encoding
    with open(file_path, "r", encoding="windows-1251") as file:
        content = file.readlines()

    # Regex pattern to match lines starting with 'static final int' containing 'SI(...)'
    pattern = re.compile(r"\s+static final int\s+\w+\s*=\s*SI\(([^)]+)\);")

    # List to store the modified content
    modified_content = []

    for line in content:
        match = pattern.match(line)
        print(f"match: {match}. Content : {line}")
        if match:
            # Extract the part inside SI(...)
            values = match.group(1)

            # Prompt the user to input the entire SI() content
            new_values = input(
                f'Enter new SI("rus", "uzb-krill", "uzb-latin", "english") values for {values}: '
            )

            # Construct the new line with the user-provided SI() content
            new_line = f"static final int si_credit_source_code = SI({new_values});\n"

            # Append the new line to the modified content
            modified_content.append(new_line)
            break
        else:
            # If the line doesn't match, keep it as is
            modified_content.append(line)

    # Write the modified content back to the file using Windows-1251 encoding
    with open(file_path, "w", encoding="windows-1251") as file:
        file.writelines(modified_content)

    print(f"File '{file_path}' has been updated.")


def process_files_in_directory(directory_path):
    # List all files in the directory
    for filename in os.listdir(directory_path):
        file_path = os.path.join(directory_path, filename)
        # Process only .jsp files
        if filename.endswith(".jsp") and os.path.isfile(file_path):
            print(f"Editing file: {filename}")
            edit_jsp_file(file_path)


if __name__ == "__main__":
    # Path to your directory containing .jsp files (Updated path for Windows)
    directory_path = r"D:/gitlab/rci/migration_tool"  # Correct path format for Windows

    # Process all .jsp files in the directory
    process_files_in_directory(directory_path)
