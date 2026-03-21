import re
import os

version = os.environ['VERSION']
base = os.environ['BASE']

print(f"Fixing versions to: {version}")

for root, dirs, files in os.walk(base):
    for fname in files:
        if not (fname.endswith('.pom') or fname.endswith('.module') or fname == 'maven-metadata.xml'):
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

        # Fix ALL file references in both .pom and .module files
        content = re.sub(
            r'flutter_(debug|release)-[\d.]+\.(aar|jar)',
            lambda m: f'flutter_{m.group(1)}-{version}.{m.group(2)}',
            content
        )

        if fname == 'maven-metadata.xml':
            content = re.sub(r'<latest>[^<]*</latest>', f'<latest>{version}</latest>', content)
            content = re.sub(r'<release>[^<]*</release>', f'<release>{version}</release>', content)
            content = re.sub(r'<version>1\.0</version>', f'<version>{version}</version>', content)

        if fname.endswith('.module'):
            content = re.sub(r'"version"\s*:\s*"[^"]*"', f'"version": "{version}"', content, count=1)

        if content != original:
            with open(fpath, 'w') as f:
                f.write(content)
            print(f'Fixed: {fpath}')

print("Done!")