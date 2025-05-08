import re

# Example line from the JSP file
line = 'static final int si_form_title = SI("", "", "", "");'

# Regular expression pattern
pattern = re.compile(r"static final int\s+\w+\s*=\s*SI\((.*?)\);")

# Check for matches
match = pattern.match(line)

if match:
    print("Match found:", match.group(1))
else:
    print("No match")
