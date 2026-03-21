import re
import os
import sys

version = os.environ['VERSION']
base = os.environ['BASE']

print(f"Fixing versions to: {version}")
print(f"Base path: {base}")

for root, dirs, files in os.walk(base):
    for fname in files:
        if not (fname.endswith('.pom') or fname == 'maven-metadata.xml'):
            continue
        
        fpath = os.path.join(root, fname)
        
        with open(fpath, 'r') as f:
            content = f.read()
        
        original = content
        
        if fname.endswith('.pom'):
            content = re.sub(
                r'(<artifactId>flutter_(?:debug|release)</artifactId>\s*\n\s*<version>)[^<]*(</version>)',
                r'\g<1>' + version + r'\g<2>',
                content
            )
            content = re.sub(
                r'flutter_(debug|release)-[\d.]+\.aar',
                lambda m: f'flutter_{m.group(1)}-{version}.aar',
                content
            )
        
        if fname == 'maven-metadata.xml':
            content = re.sub(r'<latest>[^<]*</latest>', f'<latest>{version}</latest>', content)
            content = re.sub(r'<release>[^<]*</release>', f'<release>{version}</release>', content)
            content = re.sub(r'<version>1\.0</version>', f'<version>{version}</version>', content)
        
        if content != original:
            with open(fpath, 'w') as f:
                f.write(content)
            print(f'Fixed: {fpath}')

print("Done!")