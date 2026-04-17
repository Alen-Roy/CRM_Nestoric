import os
import re

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
    content = re.sub(r'dialogBackgroundColor:\s*(AppColors\.[A-Za-z0-9_]+),', r'dialogTheme: const DialogTheme(backgroundColor: \1),', content)

    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        return True
    return False

root_dir = r"c:\Study\flutter projects\crm\lib"
count = 0
for dirpath, _, filenames in os.walk(root_dir):
    for f in filenames:
        if f.endswith('.dart'):
            if process_file(os.path.join(dirpath, f)):
                count += 1
print(f"Updated {count}")
