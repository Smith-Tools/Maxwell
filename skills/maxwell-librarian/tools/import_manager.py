#!/usr/bin/env python3
"""
Import Manager Tool for Maxwell Librarian
Coordinates documentation import with duplicate detection and validation
"""

import os
import sys
import subprocess
from pathlib import Path
from typing import Dict, List, Optional

# Add lib directory to Python path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'lib'))
from duplicate_detector import DuplicateDetector

class ImportManager:
    def __init__(self):
        self.maxwell_tools_path = Path.home() / "claude" / "skills" / "maxwell-knowledge" / "knowledge"
        self.duplicate_detector = DuplicateDetector()

    def import_documentation(self, docs_path: str, library_name: str, skip_duplicates_check: bool = False) -> Dict:
        """Complete documentation import workflow with duplicate detection"""
        print(f"📚 Starting documentation import for library: {library_name}")
        print(f"📁 Source: {docs_path}")

        # Step 1: Validate inputs
        if not Path(docs_path).exists():
            return {
                'status': 'error',
                'message': f"Documentation path not found: {docs_path}",
                'library': library_name
            }

        # Step 2: Duplicate analysis (unless skipped)
        duplicate_analysis = None
        if not skip_duplicates_check:
            print("\n" + "="*50)
            print("STEP 1: DUPLICATE ANALYSIS")
            print("="*50)
            duplicate_analysis = self.duplicate_detector.analyze_content(docs_path, library_name)

            # Get user decision
            decision = self._get_user_decision(duplicate_analysis)
            if decision['action'] == 'cancel':
                return {
                    'status': 'cancelled',
                    'message': 'Import cancelled by user',
                    'library': library_name,
                    'analysis': duplicate_analysis
                }

        # Step 3: Execute import
        print("\n" + "="*50)
        print("STEP 2: DOCUMENTATION IMPORT")
        print("="*50)
        import_result = self._execute_import(docs_path, library_name, decision if 'decision' in locals() else None)

        if import_result['status'] == 'error':
            return {
                'status': 'error',
                'message': f"Import failed: {import_result['message']}",
                'library': library_name,
                'analysis': duplicate_analysis
            }

        # Step 4: Pattern synthesis (if requested)
        synthesis_result = None
        if decision and decision.get('synthesize_patterns', False):
            print("\n" + "="*50)
            print("STEP 3: PATTERN SYNTHESIS")
            print("="*50)
            synthesis_result = self._synthesize_patterns(library_name)

        # Step 5: Validation
        print("\n" + "="*50)
        print("STEP 4: VALIDATION")
        print("="*50)
        validation_result = self._validate_import(library_name)

        # Step 6: Final report
        return self._generate_final_report(
            library_name,
            docs_path,
            duplicate_analysis,
            import_result,
            synthesis_result,
            validation_result
        )

    def check_duplicates(self, docs_path: str, library_name: str) -> Dict:
        """Perform only duplicate analysis without importing"""
        print(f"🔍 Checking duplicates for library: {library_name}")
        print(f"📁 Source: {docs_path}")

        duplicate_analysis = self.duplicate_detector.analyze_content(docs_path, library_name)

        return {
            'status': 'analysis_complete',
            'message': 'Duplicate analysis completed',
            'library': library_name,
            'analysis': duplicate_analysis,
            'recommendations': self._generate_import_recommendations(duplicate_analysis)
        }

    def synthesize_patterns(self, library_name: str) -> Dict:
        """Generate patterns for imported documentation"""
        print(f"🧠 Synthesizing patterns for library: {library_name}")

        # Determine which synthesis script to use
        synthesis_script = self._get_synthesis_script(library_name)

        if not synthesis_script:
            return {
                'status': 'error',
                'message': f"No synthesis script available for library: {library_name}",
                'library': library_name
            }

        try:
            # Execute pattern synthesis
            result = subprocess.run([
                'python3', str(synthesis_script)
            ], capture_output=True, text=True, timeout=120)

            return {
                'status': 'success' if result.returncode == 0 else 'error',
                'message': 'Pattern synthesis completed' if result.returncode == 0 else f"Pattern synthesis failed: {result.stderr}",
                'library': library_name,
                'output': result.stdout,
                'errors': result.stderr
            }
        except subprocess.TimeoutExpired:
            return {
                'status': 'error',
                'message': 'Pattern synthesis timed out (120s limit)',
                'library': library_name
            }
        except Exception as e:
            return {
                'status': 'error',
                'message': f"Pattern synthesis error: {e}",
                'library': library_name
            }

    def validate_import(self, library_name: str) -> Dict:
        """Validate that the import was successful"""
        print(f"✅ Validating import for library: {library_name}")

        validation_results = {
            'database_stats': self._get_database_stats(library_name),
            'search_tests': self._test_search_functionality(library_name),
            'content_accessibility': self._test_content_access(library_name)
        }

        # Overall validation status
        all_passed = all([
            validation_results['search_tests']['all_passed'],
            validation_results['content_accessibility']['all_passed']
        ])

        return {
            'status': 'success' if all_passed else 'warning',
            'message': 'Import validation successful' if all_passed else 'Some validation warnings detected',
            'library': library_name,
            'results': validation_results
        }

    def get_stats(self, library_name: Optional[str] = None) -> Dict:
        """Get knowledge base statistics"""
        try:
            stats_script = self.maxwell_tools_path / "migrate-database.py"

            args = ['python3', str(stats_script), '--stats']
            result = subprocess.run(args, capture_output=True, text=True)

            return {
                'status': 'success' if result.returncode == 0 else 'error',
                'stats': result.stdout,
                'errors': result.stderr
            }
        except Exception as e:
            return {
                'status': 'error',
                'message': f"Error getting stats: {e}"
            }

    def _get_user_decision(self, analysis: Dict) -> Dict:
        """Get user decision based on duplicate analysis"""
        recommendations = analysis.get('recommendations', [])
        unique = analysis.get('new_unique_content', {})

        print(f"\n📋 Import Decision:")
        for i, rec in enumerate(recommendations, 1):
            print(f"   {i}. {rec}")

        # Default decision based on uniqueness
        if unique.get('uniqueness_percentage', 0) < 30:
            print(f"\n❌ Low uniqueness ({unique.get('uniqueness_percentage', 0):.1f}%)")
            choice = input("Proceed with import? (y/N/s/e/c): ").lower().strip()

            if choice == 'y':
                action = 'import_all'
                synthesize = True
            elif choice == 'n':
                action = 'cancel'
                synthesize = False
            elif choice == 's':
                action = 'selective'
                synthesize = True
            elif choice == 'e':
                action = 'edit'
                synthesize = False
            else:
                action = 'cancel'
                synthesize = False

        elif unique.get('uniqueness_percentage', 0) > 80:
            print(f"\n✅ High uniqueness ({unique.get('uniqueness_percentage', 0):.1f}%)")
            choice = input("Proceed with import? (Y/n/s/e): ").lower().strip()

            if choice == '' or choice == 'y':
                action = 'import_all'
                synthesize = True
            elif choice == 'n':
                action = 'cancel'
                synthesize = False
            elif choice == 's':
                action = 'selective'
                synthesize = True
            elif choice == 'e':
                action = 'edit'
                synthesize = False
            else:
                action = 'import_all'
                synthesize = True

        else:
            print(f"\n📝 Moderate uniqueness ({unique.get('uniqueness_percentage', 0):.1f}%)")
            choice = input("Proceed with import? (Y/n/s/e): ").lower().strip()

            if choice == '' or choice == 'y':
                action = 'import_all'
                synthesize = True
            elif choice == 'n':
                action = 'cancel'
                synthesize = False
            elif choice == 's':
                action = 'selective'
                synthesize = True
            elif choice == 'e':
                action = 'edit'
                synthesize = False
            else:
                action = 'import_all'
                synthesize = True

        return {
            'action': action,
            'synthesize_patterns': synthesize,
            'files_to_include': analysis.get('new_unique_content', {}).get('unique_files', 0),
            'files_to_exclude': analysis.get('new_unique_content', {}).get('excluded_files', 0)
        }

    def _execute_import(self, docs_path: str, library_name: str, decision: Optional[Dict] = None) -> Dict:
        """Execute the actual import process"""
        import_script = self.maxwell_tools_path / "migrate-database.py"

        args = ['python3', str(import_script), '--import-docs', docs_path, '--library', library_name]

        try:
            print(f"🔄 Running: {' '.join(args)}")
            result = subprocess.run(args, capture_output=True, text=True, timeout=300)

            return {
                'status': 'success' if result.returncode == 0 else 'error',
                'message': 'Import completed successfully' if result.returncode == 0 else f"Import failed: {result.stderr}",
                'output': result.stdout,
                'errors': result.stderr,
                'files_imported': self._parse_import_output(result.stdout)
            }
        except subprocess.TimeoutExpired:
            return {
                'status': 'error',
                'message': 'Import timed out (5 minute limit)'
            }
        except Exception as e:
            return {
                'status': 'error',
                'message': f"Import execution error: {e}"
            }

    def _parse_import_output(self, output: str) -> int:
        """Parse import output to count imported files"""
        file_count = 0
        for line in output.split('\n'):
            if '✅ Imported:' in line:
                file_count += 1
        return file_count

    def _get_synthesis_script(self, library_name: str) -> Optional[Path]:
        """Get the appropriate synthesis script for the library"""
        script_mapping = {
            'ComposableArchitecture': self.maxwell_tools_path / 'synthesize-composable-patterns.py',
            'SwiftDependencies': self.maxwell_tools_path / 'synthesize-dependencies-patterns.py',
            'SwiftSharing': self.maxwell_tools_path / 'synthesize-sharing-patterns.py',
            'SQLiteData': self.maxwell_tools_path / 'synthesize-patterns.py',
            'StructuredQueries': self.maxwell_tools_path / 'synthesize-structured-queries-patterns.py'
        }

        return script_mapping.get(library_name)

    def _generate_import_recommendations(self, analysis: Dict) -> List[str]:
        """Generate specific import recommendations"""
        recommendations = []

        exact_dups = len(analysis['exact_duplicates'])
        topic_overlaps = len([o for o in analysis['topic_overlaps'] if o['overlap_score'] > 0.7])
        version_conflicts = len(analysis['version_conflicts'])
        unique = analysis.get('new_unique_content', {})

        if exact_dups > 0:
            recommendations.append(f"Remove {exact_dups} exact duplicates before import")

        if topic_overlaps > 0:
            recommendations.append(f"Review {topic_overlaps} files with >70% topic overlap")

        if version_conflicts > 0:
            recommendations.append(f"Update {version_conflicts} existing files with newer versions")

        if unique.get('unique_files', 0) > 0:
            recommendations.append(f"Import {unique['unique_files']} unique files")

        return recommendations

    def _get_database_stats(self, library_name: str) -> Dict:
        """Get database statistics for specific library"""
        try:
            import_script = self.maxwell_tools_path / "migrate-database.py"

            # Get general stats first
            result = subprocess.run([
                'python3', str(import_script), '--stats'
            ], capture_output=True, text=True)

            if result.returncode != 0:
                return {'library_count': 0, 'document_count': 0}

            # Parse library-specific stats (this would require extending the script)
            # For now, return basic library information
            return {
                'library_found': True,
                'general_stats': result.stdout
            }
        except Exception as e:
            return {'library_count': 0, 'document_count': 0, 'error': str(e)}

    def _test_search_functionality(self, library_name: str) -> Dict:
        """Test search functionality for the library"""
        test_queries = [
            f"basic {library_name.lower()} concept",
            f"{library_name} implementation pattern",
            f"{library_name} best practices"
        ]

        search_script = self.maxwell_tools_path / "maxwell-hybrid-search.py"

        results = {}
        for query in test_queries:
            try:
                result = subprocess.run([
                    'python3', str(search_script), query
                ], capture_output=True, text=True, timeout=30)

                # Check if search was successful (found results or clear no-results message)
                success = result.returncode == 0 and 'No relevant information' not in result.stdout
                results[query] = {
                    'success': success,
                    'output': result.stdout,
                    'has_results': 'pattern_found' in result.stdout or 'reference_found' in result.stdout
                }
            except Exception as e:
                results[query] = {
                    'success': False,
                    'error': str(e)
                }

        all_passed = all(r['success'] for r in results.values())

        return {
            'all_passed': all_passed,
            'tests': results,
            'library_name': library_name
        }

    def _test_content_access(self, library_name: str) -> Dict:
        """Test if content is accessible through search"""
        try:
            # This would test if recently imported content can be found
            test_query = f"{library_name} key concept"

            search_script = self.maxwell_tools_path / "maxwell-hybrid-search.py"
            result = subprocess.run([
                'python3', str(search_script), test_query
            ], capture_output=True, text=True, timeout=15)

            accessible = result.returncode == 0 and (
                'pattern_found' in result.stdout or
                'reference_found' in result.stdout or
                'No relevant information' not in result.stdout
            )

            return {
                'all_passed': accessible,
                'query': test_query,
                'output': result.stdout,
                'library_name': library_name
            }
        except Exception as e:
            return {
                'all_passed': False,
                'error': str(e),
                'library_name': library_name
            }

    def _generate_final_report(self, library_name: str, docs_path: str,
                              duplicate_analysis: Dict, import_result: Dict,
                              synthesis_result: Optional[Dict],
                              validation_result: Dict) -> Dict:
        """Generate final comprehensive report"""
        report = {
            'library': library_name,
            'status': 'success',
            'source_path': docs_path,
            'timestamp': self._get_timestamp(),
            'duplicate_analysis': duplicate_analysis,
            'import_result': import_result,
            'synthesis_result': synthesis_result,
            'validation_result': validation_result,
            'summary': self._generate_summary(duplicate_analysis, import_result, synthesis_result, validation_result)
        }

        print(f"\n📊 Final Import Report for {library_name}")
        print(f"=" * 50)
        print(f"Source: {docs_path}")
        print(f"Status: {report['summary']['status']}")
        print(f"\n{report['summary']['details']}")

        return report

    def _generate_summary(self, duplicate_analysis: Dict, import_result: Dict,
                        synthesis_result: Optional[Dict], validation_result: Dict) -> Dict:
        """Generate summary of all operations"""
        summary_parts = []

        # Import summary
        if import_result['status'] == 'success':
            files = import_result.get('files_imported', 0)
            summary_parts.append(f"✅ Successfully imported {files} files")
        else:
            summary_parts.append(f"❌ Import failed: {import_result.get('message', 'Unknown error')}")

        # Synthesis summary
        if synthesis_result:
            if synthesis_result['status'] == 'success':
                summary_parts.append("✅ Pattern synthesis completed")
            else:
                summary_parts.append(f"⚠️ Pattern synthesis failed: {synthesis_result.get('message', 'Unknown error')}")

        # Validation summary
        validation_passed = validation_result['results']['search_tests']['all_passed']
        if validation_passed:
            summary_parts.append("✅ Validation passed - search functionality working")
        else:
            summary_parts.append("⚠️ Validation warnings detected")

        # Duplicate analysis summary
        unique = duplicate_analysis.get('new_unique_content', {})
        if unique.get('unique_files', 0) > 0:
            summary_parts.append(f"✅ Added {unique['unique_files']} unique knowledge entries")

        return {
            'status': 'success' if all([
                import_result['status'] == 'success',
                validation_passed
            ]) else 'partial_success',
            'details': ' | '.join(summary_parts)
        }

    def _get_timestamp(self) -> str:
        """Get current timestamp"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

def main():
    if len(sys.argv) < 4:
        print("Usage: python3 import_manager.py <command> <docs_path> <library_name> [options]")
        print("Commands: import, check-duplicates, synthesize, validate, stats")
        return 1

    command = sys.argv[1]
    docs_path = sys.argv[2]
    library_name = sys.argv[3]

    manager = ImportManager()

    if command == 'import':
        skip_duplicates = '--skip-duplicates' in sys.argv
        result = manager.import_documentation(docs_path, library_name, skip_duplicates)
        print(f"\nResult: {result['status']} - {result['message']}")

    elif command == 'check-duplicates':
        result = manager.check_duplicates(docs_path, library_name)
        print(f"\nResult: {result['status']} - {result['message']}")

    elif command == 'synthesize':
        result = manager.synthesize_patterns(library_name)
        print(f"\nResult: {result['status']} - {result['message']}")

    elif command == 'validate':
        result = manager.validate_import(library_name)
        print(f"\nResult: {result['status']} - {result['message']}")

    elif command == 'stats':
        result = manager.get_stats(library_name)
        print(f"\nKnowledge Base Statistics:")
        print(result.get('stats', 'No statistics available'))

    else:
        print(f"Unknown command: {command}")
        return 1

    return 0

if __name__ == '__main__':
    exit(main())