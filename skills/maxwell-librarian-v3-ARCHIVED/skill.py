#!/usr/bin/env python3
"""
Maxwell Librarian Skill - Main Interface
Private knowledge base management for importing documentation, detecting duplicates, and synthesizing patterns
"""

import sys
import os
from pathlib import Path

# Add the tools directory to the path
skill_dir = Path(__file__).parent
tools_dir = skill_dir / "tools"
sys.path.insert(0, str(tools_dir))

try:
    from duplicate_detector import DuplicateDetector
    from import_manager import ImportManager
    from pattern_synthesizer import PatternSynthesizer
    from quality_validator import QualityValidator
except ImportError as e:
    print(f"❌ Error importing tools: {e}")
    print(f"📁 Skills directory: {skill_dir}")
    print(f"🔧 Tools directory: {tools_dir}")
    print(f"📄 Available files: {list(tools_dir.glob('*.py'))}")
    sys.exit(1)

class MaxwellLibrarian:
    """Main skill interface for Maxwell Librarian"""

    def __init__(self):
        self.import_manager = ImportManager()
        self.duplicate_detector = DuplicateDetector()
        self.pattern_synthesizer = PatternSynthesizer()
        self.quality_validator = QualityValidator()

    def import_documentation(self, docs_path: str, library_name: str, skip_duplicates_check: bool = False):
        """Main import workflow with duplicate detection"""
        print(f"📚 Starting Maxwell Librarian import process...")
        print(f"📁 Source: {docs_path}")
        print(f"🏷️ Library: {library_name}")

        # Step 1: Duplicate analysis (unless skipped)
        if not skip_duplicates_check:
            print(f"\n🔍 Step 1: Analyzing duplicates...")
            duplicate_analysis = self.duplicate_detector.analyze_content(docs_path, library_name)

            # Ask user for confirmation based on analysis
            unique_content = duplicate_analysis.get('new_unique_content', {})
            uniqueness_percentage = unique_content.get('uniqueness_percentage', 0)

            if uniqueness_percentage < 30:
                print(f"\n⚠️ Warning: Only {uniqueness_percentage:.1f}% unique content detected")
                confirmation = self._get_user_confirmation(
                    f"Proceed with import despite low uniqueness ({uniqueness_percentage:.1f}%)? (y/N): "
                )
                if not confirmation:
                    print("❌ Import cancelled by user")
                    return {'success': False, 'reason': 'cancelled_by_user'}
            else:
                print(f"✅ Good uniqueness ({uniqueness_percentage:.1f}%) - proceeding with import")
        else:
            print(f"\n⏭️ Skipping duplicate analysis as requested")
            duplicate_analysis = None

        # Step 2: Import documentation
        print(f"\n📥 Step 2: Importing documentation...")
        import_result = self.import_manager.import_documentation(
            docs_path, library_name, skip_duplicates_check
        )

        if not import_result['success']:
            print(f"❌ Import failed: {import_result.get('error', 'Unknown error')}")
            return import_result

        # Step 3: Pattern synthesis
        print(f"\n🧠 Step 3: Synthesizing patterns...")
        synthesis_result = self.pattern_synthesizer.synthesize_patterns(library_name)

        # Step 4: Validation
        print(f"\n🔍 Step 4: Validating import...")
        validation_result = self.quality_validator.validate_import(library_name)

        # Compile final result
        final_result = {
            'success': import_result['success'],
            'library_name': library_name,
            'docs_path': docs_path,
            'steps_completed': {
                'duplicate_analysis': duplicate_analysis is not None,
                'import': import_result['success'],
                'synthesis': synthesis_result['synthesis_completed'],
                'validation': validation_result['overall_score'] >= 0.7
            },
            'duplicate_analysis': duplicate_analysis,
            'import_result': import_result,
            'synthesis_result': synthesis_result,
            'validation_result': validation_result,
            'overall_status': 'success' if (
                import_result['success'] and
                validation_result['overall_score'] >= 0.5
            ) else 'partial_success'
        }

        self._display_final_summary(final_result)
        return final_result

    def check_duplicates(self, docs_path: str, library_name: str):
        """Analyze duplicates without importing"""
        print(f"🔍 Analyzing duplicates for potential import...")
        print(f"📁 Source: {docs_path}")
        print(f"🏷️ Library: {library_name}")

        analysis = self.duplicate_detector.analyze_content(docs_path, library_name)

        # Generate recommendations
        recommendations = self._generate_duplicate_recommendations(analysis)

        return {
            'analysis': analysis,
            'recommendations': recommendations,
            'docs_path': docs_path,
            'library_name': library_name
        }

    def synthesize_patterns(self, library_name: str):
        """Run pattern synthesis for existing library"""
        print(f"🧠 Synthesizing patterns for existing library: {library_name}")

        synthesis_result = self.pattern_synthesizer.synthesize_patterns(library_name)

        if synthesis_result['synthesis_completed']:
            print(f"✅ Pattern synthesis completed successfully")
        else:
            print(f"❌ Pattern synthesis failed or incomplete")

        return synthesis_result

    def validate_import(self, library_name: str):
        """Validate existing library import"""
        print(f"🔍 Validating library import: {library_name}")

        validation_result = self.quality_validator.validate_import(library_name)

        return validation_result

    def generate_report(self, library_name: str):
        """Generate comprehensive library report"""
        print(f"📊 Generating report for library: {library_name}")

        report_result = self.quality_validator.generate_library_report(library_name)

        return report_result

    def get_knowledge_base_stats(self):
        """Get overall knowledge base statistics"""
        print(f"📊 Getting knowledge base statistics...")

        health_result = self.quality_validator.validate_knowledge_base()

        return health_result

    def clean_duplicates(self, library_name: str = None):
        """Clean duplicate content (optional library filter)"""
        print(f"🧹 Cleaning duplicate content...")

        if library_name:
            print(f"🎯 Targeting library: {library_name}")
            # Library-specific cleanup logic would go here
        else:
            print(f"🌐 Cleaning duplicates across all libraries...")
            # Global cleanup logic would go here

        return {
            'success': True,
            'message': 'Duplicate cleaning not yet implemented',
            'library_name': library_name
        }

    def optimize_search(self, library_name: str = None):
        """Optimize search index performance"""
        print(f"⚡ Optimizing search performance...")

        if library_name:
            print(f"🎯 Targeting library: {library_name}")
        else:
            print(f"🌐 Optimizing across all libraries...")

        return {
            'success': True,
            'message': 'Search optimization not yet implemented',
            'library_name': library_name
        }

    def _get_user_confirmation(self, prompt: str) -> bool:
        """Get user confirmation for critical actions"""
        try:
            response = input(prompt).strip().lower()
            return response in ['y', 'yes', 'Y', 'YES']
        except (KeyboardInterrupt, EOFError):
            print("\n❌ Operation cancelled by user")
            return False

    def _generate_duplicate_recommendations(self, analysis: Dict) -> List[str]:
        """Generate recommendations based on duplicate analysis"""
        recommendations = []

        unique_content = analysis.get('new_unique_content', {})
        uniqueness_percentage = unique_content.get('uniqueness_percentage', 0)

        if uniqueness_percentage >= 80:
            recommendations.append("🎉 Excellent uniqueness - Highly recommended for import")
        elif uniqueness_percentage >= 60:
            recommendations.append("✅ Good uniqueness - Recommended for import")
        elif uniqueness_percentage >= 40:
            recommendations.append("🤔 Moderate uniqueness - Consider reviewing content first")
        else:
            recommendations.append("⚠️ Low uniqueness - Review content before import")

        # Specific recommendations based on analysis
        exact_duplicates = analysis.get('exact_duplicates', [])
        if exact_duplicates:
            recommendations.append(f"⛔️ Skip {len(exact_duplicates)} exact duplicates")

        topic_overlaps = analysis.get('topic_overlaps', [])
        high_overlap = [o for o in topic_overlaps if o.get('overlap_score', 0) > 0.7]
        if high_overlap:
            recommendations.append(f"⚠️ Review {len(high_overlap)} files with high topic overlap")

        version_conflicts = analysis.get('version_conflicts', [])
        if version_conflicts:
            recommendations.append(f"📈 Consider updating {len(version_conflicts)} existing files")

        return recommendations

    def _display_final_summary(self, result: Dict):
        """Display final import summary"""
        print(f"\n🎉 Maxwell Librarian Import Summary")
        print(f"=" * 50)

        status_emoji = "✅" if result['overall_status'] == 'success' else "⚠️"
        print(f"{status_emoji} Overall Status: {result['overall_status'].replace('_', ' ').title()}")

        print(f"\n📋 Steps Completed:")
        steps = result['steps_completed']
        step_emojis = {
            'duplicate_analysis': "🔍",
            'import': "📥",
            'synthesis': "🧠",
            'validation': "✅"
        }

        for step, completed in steps.items():
            emoji = "✅" if completed else "❌"
            step_name = step.replace('_', ' ').title()
            print(f"   {step_emojis.get(step, '📋')} {step_name}: {emoji}")

        # Key metrics
        import_result = result.get('import_result', {})
        if import_result.get('success'):
            print(f"\n📊 Import Metrics:")
            print(f"   📄 Documents imported: {import_result.get('documents_imported', 'N/A')}")
            print(f"   🧠 Patterns created: {result.get('synthesis_result', {}).get('patterns_created', 'N/A')}")

        validation_result = result.get('validation_result', {})
        if validation_result.get('overall_score') is not None:
            print(f"   🔍 Validation score: {validation_result['overall_score']:.2f}")

        # Next steps
        print(f"\n📋 Next Steps:")
        if result['overall_status'] == 'success':
            print(f"   ✅ Library '{result['library_name']}' is ready for use")
            print(f"   🔍 Test search functionality with: /skill maxwell-librarian validate {result['library_name']}")
            print(f"   📊 Generate detailed report with: /skill maxwell-librarian report {result['library_name']}")
        else:
            print(f"   🔧 Review validation results above")
            print(f"   🔄 Consider reimporting if issues persist")
            print(f"   📞 Check source documentation quality")

def main():
    """Main skill entry point"""
    if len(sys.argv) < 2:
        print("Maxwell Librarian - Private Knowledge Base Management")
        print("=" * 60)
        print("\nUsage:")
        print("  python3 skill.py <command> [arguments]")
        print("\nAvailable Commands:")
        print("  import <docs_path> <library_name> [--skip-duplicates]")
        print("    Import documentation with duplicate detection and pattern synthesis")
        print("\n  check-duplicates <docs_path> <library_name>")
        print("    Analyze content for duplicates without importing")
        print("\n  synthesize <library_name>")
        print("    Generate patterns for existing library")
        print("\n  validate <library_name>")
        print("    Validate existing library import")
        print("\n  report <library_name>")
        print("    Generate comprehensive library report")
        print("\n  health")
        print("    Check overall knowledge base health")
        print("\n  clean-duplicates [library_name]")
        print("    Clean duplicate content (optional library filter)")
        print("\n  optimize-search [library_name]")
        print("    Optimize search performance (optional library filter)")
        print("\nExamples:")
        print("  python3 skill.py import \"/path/to/docs\" \"MyLibrary\"")
        print("  python3 skill.py check-duplicates \"/path/to/docs\" \"MyLibrary\"")
        print("  python3 skill.py validate \"MyLibrary\"")
        return 1

    command = sys.argv[1]
    librarian = MaxwellLibrarian()

    try:
        if command == "import":
            if len(sys.argv) < 4:
                print("❌ Error: import command requires <docs_path> and <library_name>")
                print("Usage: python3 skill.py import <docs_path> <library_name> [--skip-duplicates]")
                return 1

            docs_path = sys.argv[2]
            library_name = sys.argv[3]
            skip_duplicates = "--skip-duplicates" in sys.argv

            result = librarian.import_documentation(docs_path, library_name, skip_duplicates)
            return 0 if result['success'] else 1

        elif command == "check-duplicates":
            if len(sys.argv) < 4:
                print("❌ Error: check-duplicates command requires <docs_path> and <library_name>")
                return 1

            docs_path = sys.argv[2]
            library_name = sys.argv[3]
            librarian.check_duplicates(docs_path, library_name)
            return 0

        elif command == "synthesize":
            if len(sys.argv) < 3:
                print("❌ Error: synthesize command requires <library_name>")
                return 1

            library_name = sys.argv[2]
            result = librarian.synthesize_patterns(library_name)
            return 0 if result['synthesis_completed'] else 1

        elif command == "validate":
            if len(sys.argv) < 3:
                print("❌ Error: validate command requires <library_name>")
                return 1

            library_name = sys.argv[2]
            validation = librarian.validate_import(library_name)
            return 0 if validation['overall_score'] >= 0.7 else 1

        elif command == "report":
            if len(sys.argv) < 3:
                print("❌ Error: report command requires <library_name>")
                return 1

            library_name = sys.argv[2]
            librarian.generate_report(library_name)
            return 0

        elif command == "health":
            health = librarian.get_knowledge_base_stats()
            return 0 if health['overall_health_score'] >= 0.8 else 1

        elif command == "clean-duplicates":
            library_name = sys.argv[2] if len(sys.argv) > 2 else None
            result = librarian.clean_duplicates(library_name)
            return 0 if result['success'] else 1

        elif command == "optimize-search":
            library_name = sys.argv[2] if len(sys.argv) > 2 else None
            result = librarian.optimize_search(library_name)
            return 0 if result['success'] else 1

        else:
            print(f"❌ Error: Unknown command '{command}'")
            print("Use 'python3 skill.py' to see available commands")
            return 1

    except KeyboardInterrupt:
        print(f"\n❌ Operation cancelled by user")
        return 1
    except Exception as e:
        print(f"❌ Error: {e}")
        return 1

if __name__ == '__main__':
    exit(main())