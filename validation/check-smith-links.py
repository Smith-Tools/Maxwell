#!/usr/bin/env python3
"""
Enhanced validation script for Maxwell v3 Smith-based knowledge system.
Validates routing.yaml references, markdown links, and Smith-specific patterns.
"""

import os
import yaml
import re
from pathlib import Path

def load_routing_config():
    """Load the routing.yaml configuration."""
    try:
        with open('routing.yaml', 'r') as f:
            return yaml.safe_load(f)
    except FileNotFoundError:
        print("❌ routing.yaml not found")
        return None
    except yaml.YAMLError as e:
        print(f"❌ Error parsing routing.yaml: {e}")
        return None

def check_file_exists(filepath):
    """Check if a file exists."""
    return Path(filepath).exists()

def validate_routing_references(routing_config):
    """Validate that all files referenced in routing.yaml exist."""
    if not routing_config:
        return []

    errors = []

    for task_name, task_config in routing_config.items():
        # Skip metadata keys
        if task_name.startswith('_') or task_name in ['global_settings', 'reading_budgets', 'red_flags', 'verification_requirements']:
            continue

        # Validate files
        if 'files' in task_config:
            for file_path in task_config['files']:
                if not check_file_exists(file_path):
                    errors.append(f"Task {task_name}: referenced file not found - {file_path}")

        # Validate case studies
        if 'case_studies' in task_config:
            for case_study in task_config['case_studies']:
                # Try different case study formats
                possible_paths = [
                    f"knowledge/case-studies/{case_study}.md",
                    f"knowledge-base/CaseStudies/{case_study}.md",
                    f"{case_study}.md"
                ]
                if not any(check_file_exists(path) for path in possible_paths):
                    errors.append(f"Task {task_name}: case study not found - {case_study}")

    return errors

def extract_markdown_links(file_path):
    """Extract all markdown links from a file."""
    try:
        with open(file_path, 'r') as f:
            content = f.read()

        # Match [text](link.md) and [text](../link.md) patterns
        pattern = r'\[([^\]]+)\]\(([^)]+\.md)\)'
        matches = re.findall(pattern, content)
        return [(match[0], match[1]) for match in matches]
    except FileNotFoundError:
        return []
    except Exception as e:
        print(f"⚠️  Error reading {file_path}: {e}")
        return []

def extract_section_references(file_path):
    """Extract section references like "Pattern 1:", "Tree 2:" etc."""
    try:
        with open(file_path, 'r') as f:
            content = f.read()

        # Match section headers and references
        section_patterns = [
            r'Pattern (\d+):',
            r'Tree (\d+):',
            r'### (.+)',
            r'## (.+)'
        ]

        sections = set()
        for pattern in section_patterns:
            matches = re.findall(pattern, content)
            sections.update(matches)

        return list(sections)
    except Exception as e:
        return []

def validate_markdown_links():
    """Validate all markdown links in knowledge files."""
    errors = []

    knowledge_dir = Path('knowledge')
    if not knowledge_dir.exists():
        errors.append("knowledge directory not found")
        return errors

    # Find all markdown files
    md_files = list(knowledge_dir.rglob('*.md'))

    for md_file in md_files:
        links = extract_markdown_links(md_file)

        for link_text, link_target in links:
            # Resolve relative paths
            if link_target.startswith('../'):
                target_path = (md_file.parent / link_target).resolve()
            elif link_target.startswith('./'):
                target_path = md_file.parent / link_target[2:]
            else:
                target_path = md_file.parent / link_target

            if not target_path.exists():
                errors.append(f"{md_file}: broken link to {link_target}")

    return errors

def validate_routing_sections():
    """Validate that referenced sections exist in files."""
    errors = []
    routing_config = load_routing_config()

    if not routing_config:
        return errors

    for task_name, task_config in routing_config.items():
        if 'sections' in task_config:
            for section in task_config['sections']:
                # Check if section exists in any of the files
                found = False
                for file_path in task_config.get('files', []):
                    if check_file_exists(file_path):
                        sections = extract_section_references(file_path)
                        if any(section.lower() in s.lower() for s in sections):
                            found = True
                            break

                if not found:
                    errors.append(f"Task {task_name}: section '{section}' not found in referenced files")

    return errors

def validate_smith_patterns():
    """Validate Smith-specific patterns and requirements."""
    errors = []

    # Check for essential Smith documents
    essential_docs = [
        'knowledge/patterns/AGENTS-TCA-PATTERNS.md',
        'knowledge/concepts/universal-principles.md',
        'knowledge/patterns/AGENTS-DECISION-TREES.md'
    ]

    for doc in essential_docs:
        if not check_file_exists(doc):
            errors.append(f"Essential Smith document missing: {doc}")

    # Check for case studies directory
    case_studies_dir = Path('knowledge/case-studies')
    if not case_studies_dir.exists():
        errors.append("Case studies directory not found")
    else:
        # Check for key case studies
        key_cases = [
            'DISCOVERY-14-NESTED-REDUCER-GOTCHAS.md',
            'DISCOVERY-5-ACCESS-CONTROL-CASCADE-FAILURE.md',
            'DISCOVERY-6-IFLET-CLOSURE-REQUIREMENT.md'
        ]

        for case in key_cases:
            if not (case_studies_dir / case).exists():
                errors.append(f"Key case study missing: {case}")

    return errors

def validate_scripts():
    """Validate that validation scripts exist and are executable."""
    errors = []

    scripts_dir = Path('knowledge/scripts')
    if not scripts_dir.exists():
        errors.append("Scripts directory not found")
        return errors

    # Check for key validation scripts
    key_scripts = [
        'check-compliance.sh',
        'validate-smith.sh',
        'compliance-report.sh'
    ]

    for script in key_scripts:
        script_path = scripts_dir / script
        if not script_path.exists():
            errors.append(f"Validation script missing: {script}")
        elif not os.access(script_path, os.X_OK):
            errors.append(f"Validation script not executable: {script}")

    return errors

def count_knowledge_files():
    """Count total knowledge files and provide statistics."""
    stats = {}

    knowledge_dir = Path('knowledge')
    if knowledge_dir.exists():
        stats['total_files'] = len(list(knowledge_dir.rglob('*.md')))
        stats['concepts'] = len(list((knowledge_dir / 'concepts').rglob('*.md'))) if (knowledge_dir / 'concepts').exists() else 0
        stats['patterns'] = len(list((knowledge_dir / 'patterns').rglob('*.md'))) if (knowledge_dir / 'patterns').exists() else 0
        stats['platforms'] = len(list((knowledge_dir / 'platforms').rglob('*.md'))) if (knowledge_dir / 'platforms').exists() else 0
        stats['case_studies'] = len(list((knowledge_dir / 'case-studies').rglob('*.md'))) if (knowledge_dir / 'case-studies').exists() else 0
        stats['testing'] = len(list((knowledge_dir / 'testing').rglob('*.md'))) if (knowledge_dir / 'testing').exists() else 0

    routing_config = load_routing_config()
    if routing_config:
        task_count = len([k for k in routing_config.keys() if not k.startswith('_') and k not in ['global_settings', 'reading_budgets', 'red_flags', 'verification_requirements']])
        stats['routing_tasks'] = task_count

    return stats

def main():
    """Main validation routine."""
    print("🔍 Maxwell v3 Smith Knowledge System Validation")
    print("=" * 60)

    all_errors = []

    # Validate routing.yaml references
    print("📋 Validating routing.yaml references...")
    routing_config = load_routing_config()
    if routing_config is None:
        return 1
    routing_errors = validate_routing_references(routing_config)
    all_errors.extend(routing_errors)

    if routing_errors:
        print(f"❌ {len(routing_errors)} routing errors found")
        for error in routing_errors:
            print(f"   - {error}")
    else:
        print("✅ All routing references valid")

    # Validate markdown links
    print("\n🔗 Validating markdown links...")
    link_errors = validate_markdown_links()
    all_errors.extend(link_errors)

    if link_errors:
        print(f"❌ {len(link_errors)} broken links found")
        for error in link_errors:
            print(f"   - {error}")
    else:
        print("✅ All markdown links valid")

    # Validate routing sections
    print("\n📚 Validating routing sections...")
    section_errors = validate_routing_sections()
    all_errors.extend(section_errors)

    if section_errors:
        print(f"❌ {len(section_errors)} section errors found")
        for error in section_errors:
            print(f"   - {error}")
    else:
        print("✅ All routing sections valid")

    # Validate Smith-specific patterns
    print("\n🏗️  Validating Smith patterns...")
    smith_errors = validate_smith_patterns()
    all_errors.extend(smith_errors)

    if smith_errors:
        print(f"❌ {len(smith_errors)} Smith pattern errors found")
        for error in smith_errors:
            print(f"   - {error}")
    else:
        print("✅ All Smith patterns valid")

    # Validate scripts
    print("\n⚙️  Validating validation scripts...")
    script_errors = validate_scripts()
    all_errors.extend(script_errors)

    if script_errors:
        print(f"❌ {len(script_errors)} script errors found")
        for error in script_errors:
            print(f"   - {error}")
    else:
        print("✅ All validation scripts valid")

    # Show statistics
    print("\n📊 Knowledge Base Statistics:")
    stats = count_knowledge_files()
    for key, value in stats.items():
        print(f"   {key}: {value}")

    # Summary
    print("\n" + "=" * 60)
    if all_errors:
        print(f"❌ Validation failed with {len(all_errors)} errors")
        return 1
    else:
        print("✅ All validations passed!")
        print(f"🎉 Maxwell v3 Smith knowledge system ready with {stats.get('routing_tasks', 0)} task patterns and {stats.get('total_files', 0)} knowledge files")
        return 0

if __name__ == '__main__':
    exit(main())