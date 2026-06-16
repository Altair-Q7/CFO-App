import re
import glob

files = glob.glob('screens/**/*.dart', recursive=True)
for f in files:
    with open(f, 'r') as fh:
        content = fh.read()
    
    original = content
    
    # Remove 'const' from TextStyle declarations that contain AppTheme.onSurfaceText*
    # Match: const TextStyle(...AppTheme.onSurfaceText...)
    # Use a simple approach: find lines with const TextStyle and AppTheme.onSurface
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if 'const TextStyle' in line and 'AppTheme.onSurface' in line:
            line = line.replace('const TextStyle', 'TextStyle', 1)
        new_lines.append(line)
    
    content = '\n'.join(new_lines)
    
    if content != original:
        with open(f, 'w') as fh:
            fh.write(content)
        print(f'Fixed: {f}')