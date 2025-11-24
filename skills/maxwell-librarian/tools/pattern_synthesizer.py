#!/usr/bin/env python3
"""
Pattern Synthesis Coordinator for Maxwell Librarian
Generates and manages pattern synthesis from imported documentation
"""

import os
import subprocess
import sqlite3
from pathlib import Path
from typing import Dict, List, Optional
import json

class PatternSynthesizer:
    def __init__(self):
        self.db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"
        self.conn = sqlite3.connect(self.db_path)
        self.skills_path = Path.home() / ".claude" / "skills"

    def synthesize_patterns(self, library_name: str) -> Dict:
        """Generate patterns for imported documentation"""
        print(f"🧠 Synthesizing patterns for {library_name}...")

        # Check if library exists
        if not self._library_exists(library_name):
            return {
                'success': False,
                'error': f'Library "{library_name}" not found in database'
            }

        # Get library statistics
        library_info = self._get_library_info(library_name)
        print(f"📊 Found {library_info['doc_count']} documents for {library_name}")

        # Determine synthesis strategy
        strategy = self._determine_synthesis_strategy(library_name, library_info)
        print(f"🎯 Using synthesis strategy: {strategy}")

        # Generate synthesis script
        script_result = self._generate_synthesis_script(library_name, strategy)

        # Execute synthesis if script was created
        synthesis_result = {'success': False, 'patterns_created': 0}
        if script_result['success']:
            synthesis_result = self._execute_synthesis(library_name, script_result['script_path'])

        # Validate patterns
        validation_result = self._validate_patterns(library_name) if synthesis_result['success'] else None

        result = {
            'library_name': library_name,
            'library_info': library_info,
            'strategy': strategy,
            'script_generated': script_result['success'],
            'synthesis_completed': synthesis_result['success'],
            'patterns_created': synthesis_result['patterns_created'],
            'validation': validation_result,
            'next_steps': self._generate_next_steps(library_name, synthesis_result['success'])
        }

        self._display_synthesis_results(result)
        return result

    def _library_exists(self, library_name: str) -> bool:
        """Check if library exists in database"""
        try:
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM reference WHERE library = ?
            ''', (library_name,))
            return cursor.fetchone()[0] > 0
        except Exception as e:
            print(f"⚠️ Error checking library existence: {e}")
            return False

    def _get_library_info(self, library_name: str) -> Dict:
        """Get comprehensive information about the library"""
        try:
            # Get basic stats
            cursor = self.conn.execute('''
                SELECT
                    COUNT(*) as doc_count,
                    COUNT(DISTINCT folder_path) as folder_count,
                    MIN(title) as sample_title
                FROM reference
                WHERE library = ?
            ''', (library_name,))

            stats = cursor.fetchone()

            # Get content samples
            cursor = self.conn.execute('''
                SELECT title, tags FROM reference
                WHERE library = ?
                LIMIT 5
            ''', (library_name,))

            samples = []
            for title, tags in cursor.fetchall():
                sample_tags = json.loads(tags) if tags else []
                samples.append({
                    'title': title,
                    'tags': sample_tags
                })

            return {
                'doc_count': stats[0],
                'folder_count': stats[1],
                'sample_title': stats[2],
                'samples': samples
            }
        except Exception as e:
            print(f"⚠️ Error getting library info: {e}")
            return {'doc_count': 0, 'folder_count': 0, 'samples': []}

    def _determine_synthesis_strategy(self, library_name: str, library_info: Dict) -> str:
        """Determine the best synthesis strategy based on library content"""
        doc_count = library_info['doc_count']

        # Check for existing synthesis scripts
        existing_scripts = self._find_existing_synthesis_scripts(library_name)
        if existing_scripts:
            print(f"📄 Found existing synthesis scripts: {existing_scripts}")
            return "update_existing"

        # Analyze content to determine strategy
        sample_titles = [sample['title'] for sample in library_info['samples']]
        all_tags = []
        for sample in library_info['samples']:
            all_tags.extend(sample['tags'])

        # Technology-specific strategies
        if any('tca' in tag.lower() for tag in all_tags):
            return "tca_specific"
        elif any('visionos' in tag.lower() or 'arkit' in tag.lower() for tag in all_tags):
            return "visionos_specific"
        elif any('swiftui' in tag.lower() for tag in all_tags):
            return "swiftui_specific"
        elif any('shareplay' in tag.lower() for tag in all_tags):
            return "shareplay_specific"

        # Size-based strategies
        if doc_count < 5:
            return "lightweight_synthesis"
        elif doc_count < 20:
            return "standard_synthesis"
        else:
            return "comprehensive_synthesis"

    def _find_existing_synthesis_scripts(self, library_name: str) -> List[str]:
        """Find existing synthesis scripts for the library"""
        scripts = []
        maxwell_root = Path.home() / ".claude" / "resources" / "maxwell"

        # Look for various synthesis script patterns
        patterns = [
            f"*{library_name.lower()}*synthesis*.py",
            f"synthesis-{library_name.lower()}*.py",
            f"{library_name.lower()}-patterns*.py"
        ]

        for pattern in patterns:
            try:
                found = list(maxwell_root.rglob(pattern))
                scripts.extend([str(f.relative_to(maxwell_root)) for f in found])
            except Exception:
                continue

        return scripts

    def _generate_synthesis_script(self, library_name: str, strategy: str) -> Dict:
        """Generate a synthesis script for the library"""
        print(f"⚙️ Generating synthesis script using {strategy} strategy...")

        script_templates = {
            "tca_specific": self._get_tca_synthesis_template(),
            "visionos_specific": self._get_visionos_synthesis_template(),
            "swiftui_specific": self._get_swiftui_synthesis_template(),
            "shareplay_specific": self._get_shareplay_synthesis_template(),
            "standard_synthesis": self._get_standard_synthesis_template(),
            "comprehensive_synthesis": self._get_comprehensive_synthesis_template(),
            "lightweight_synthesis": self._get_lightweight_synthesis_template(),
            "update_existing": self._get_update_template()
        }

        template = script_templates.get(strategy, script_templates["standard_synthesis"])

        # Customize template
        script_content = template.format(
            library_name=library_name,
            library_name_lower=library_name.lower(),
            library_name_snake=library_name.lower().replace(' ', '_').replace('-', '_')
        )

        # Write script to Maxwell resources
        maxwell_root = Path.home() / ".claude" / "resources" / "maxwell"
        maxwell_root.mkdir(parents=True, exist_ok=True)

        script_path = maxwell_root / f"synthesis-{library_name.lower().replace(' ', '-')}.py"

        try:
            with open(script_path, 'w') as f:
                f.write(script_content)

            # Make executable
            os.chmod(script_path, 0o755)

            print(f"✅ Synthesis script created: {script_path}")
            return {
                'success': True,
                'script_path': str(script_path),
                'strategy': strategy
            }
        except Exception as e:
            print(f"❌ Error creating synthesis script: {e}")
            return {
                'success': False,
                'error': str(e)
            }

    def _get_tca_synthesis_template(self) -> str:
        """Get TCA-specific synthesis template"""
        return '''#!/usr/bin/env python3
"""
TCA Pattern Synthesis for {library_name}
Generates TCA-specific patterns from imported documentation
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = [
            "tca_reducer_patterns",
            "tca_state_management",
            "tca_effect_patterns",
            "tca_dependency_patterns",
            "tca_navigation_patterns"
        ]

    def extract_patterns(self):
        """Extract TCA-specific patterns"""
        patterns = []

        # Query for TCA-related content
        tca_content = self.query_library("""
            SELECT title, content, tags FROM reference
            WHERE library = ? AND (
                content LIKE '%Reducer%' OR
                content LIKE '%@Reducer%' OR
                content LIKE '%State%' OR
                content LIKE '%Action%' OR
                content LIKE '%Effect%'
            )
        """, (self.library_name,))

        for title, content, tags in tca_content:
            # Extract TCA patterns
            patterns.extend(self._extract_tca_patterns(title, content))

        return patterns

    def _extract_tca_patterns(self, title, content):
        """Extract specific TCA patterns from content"""
        patterns = []

        # Add TCA-specific pattern extraction logic here
        # This would analyze the content for TCA patterns

        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_visionos_synthesis_template(self) -> str:
        """Get visionOS-specific synthesis template"""
        return '''#!/usr/bin/env python3
"""
visionOS Pattern Synthesis for {library_name}
Generates visionOS-specific patterns from imported documentation
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = [
            "visionos_arkit_patterns",
            "visionos_realitykit_patterns",
            "visionos_spatial_patterns",
            "visionos_immersive_patterns",
            "visionos_collaboration_patterns"
        ]

    def extract_patterns(self):
        """Extract visionOS-specific patterns"""
        patterns = []

        # Query for visionOS-related content
        visionos_content = self.query_library('''
            SELECT title, content, tags FROM reference
            WHERE library = ? AND (
                content LIKE '%ARKit%' OR
                content LIKE '%RealityKit%' OR
                content LIKE '%visionOS%' OR
                content LIKE '%Spatial%' OR
                content LIKE '%Immersive%'
            )
        ''', (self.library_name,))

        for title, content, tags in visionos_content:
            # Extract visionOS patterns
            patterns.extend(self._extract_visionos_patterns(title, content))

        return patterns

    def _extract_visionos_patterns(self, title, content):
        """Extract specific visionOS patterns from content"""
        patterns = []

        # Add visionOS-specific pattern extraction logic here

        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_standard_synthesis_template(self) -> str:
        """Get standard synthesis template"""
        return '''#!/usr/bin/env python3
"""
Standard Pattern Synthesis for {library_name}
Generates general patterns from imported documentation
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = [
            "general_patterns",
            "implementation_patterns",
            "best_practices",
            "common_solutions"
        ]

    def extract_patterns(self):
        """Extract general patterns"""
        patterns = []

        # Query all content
        content = self.query_library('''
            SELECT title, content, tags FROM reference
            WHERE library = ?
        ''', (self.library_name,))

        for title, content, tags in content:
            # Extract general patterns
            patterns.extend(self._extract_general_patterns(title, content))

        return patterns

    def _extract_general_patterns(self, title, content):
        """Extract general patterns from content"""
        patterns = []

        # Add general pattern extraction logic here

        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_comprehensive_synthesis_template(self) -> str:
        """Get comprehensive synthesis template"""
        return '''#!/usr/bin/env python3
"""
Comprehensive Pattern Synthesis for {library_name}
Generates detailed patterns with cross-reference analysis
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = [
            "architecture_patterns",
            "implementation_patterns",
            "integration_patterns",
            "optimization_patterns",
            "troubleshooting_patterns"
        ]

    def extract_patterns(self):
        """Extract comprehensive patterns"""
        patterns = []

        # Multi-pass analysis for comprehensive coverage
        content = self.query_library('''
            SELECT title, content, tags FROM reference
            WHERE library = ?
        ''', (self.library_name,))

        # Pass 1: Architecture patterns
        patterns.extend(self._extract_architecture_patterns(content))

        # Pass 2: Implementation patterns
        patterns.extend(self._extract_implementation_patterns(content))

        # Pass 3: Cross-reference patterns
        patterns.extend(self._extract_cross_reference_patterns(content))

        return patterns

    def _extract_architecture_patterns(self, content):
        """Extract architecture-level patterns"""
        patterns = []
        # Architecture pattern extraction logic
        return patterns

    def _extract_implementation_patterns(self, content):
        """Extract implementation-level patterns"""
        patterns = []
        # Implementation pattern extraction logic
        return patterns

    def _extract_cross_reference_patterns(self, content):
        """Extract patterns that cross-reference multiple documents"""
        patterns = []
        # Cross-reference pattern extraction logic
        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_lightweight_synthesis_template(self) -> str:
        """Get lightweight synthesis template"""
        return '''#!/usr/bin/env python3
"""
Lightweight Pattern Synthesis for {library_name}
Quick pattern extraction for small libraries
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = ["quick_patterns"]

    def extract_patterns(self):
        """Quick pattern extraction"""
        patterns = []

        content = self.query_library('''
            SELECT title, content FROM reference
            WHERE library = ?
        ''', (self.library_name,))

        for title, content in content:
            # Quick pattern extraction
            if len(content) > 100:
                patterns.append({
                    'type': 'quick_pattern',
                    'title': title,
                    'content': content[:500] + "...",
                    'source': self.library_name
                })

        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_shareplay_synthesis_template(self) -> str:
        """Get SharePlay-specific synthesis template"""
        return '''#!/usr/bin/env python3
"""
SharePlay Pattern Synthesis for {library_name}
Generates SharePlay-specific patterns from imported documentation
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = [
            "shareplay_groupactivity_patterns",
            "shareplay_synchronization_patterns",
            "shareplay_session_patterns",
            "shareplay_collaboration_patterns",
            "shareplay_immersive_patterns"
        ]

    def extract_patterns(self):
        """Extract SharePlay-specific patterns"""
        patterns = []

        shareplay_content = self.query_library('''
            SELECT title, content, tags FROM reference
            WHERE library = ? AND (
                content LIKE '%SharePlay%' OR
                content LIKE '%GroupActivity%' OR
                content LIKE '%Session%' OR
                content LIKE '%Collaboration%' OR
                content LIKE '%Spatial Persona%'
            )
        ''', (self.library_name,))

        for title, content, tags in shareplay_content:
            patterns.extend(self._extract_shareplay_patterns(title, content))

        return patterns

    def _extract_shareplay_patterns(self, title, content):
        """Extract specific SharePlay patterns from content"""
        patterns = []

        # Add SharePlay-specific pattern extraction logic here

        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_swiftui_synthesis_template(self) -> str:
        """Get SwiftUI-specific synthesis template"""
        return '''#!/usr/bin/env python3
"""
SwiftUI Pattern Synthesis for {library_name}
Generates SwiftUI-specific patterns from imported documentation
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Synthesis(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"
        self.pattern_types = [
            "swiftui_view_patterns",
            "swiftui_state_patterns",
            "swiftui_animation_patterns",
            "swiftui_navigation_patterns",
            "swiftui_performance_patterns"
        ]

    def extract_patterns(self):
        """Extract SwiftUI-specific patterns"""
        patterns = []

        swiftui_content = self.query_library('''
            SELECT title, content, tags FROM reference
            WHERE library = ? AND (
                content LIKE '%View%' OR
                content LIKE '%@State%' OR
                content LIKE '%@StateObject%' OR
                content LIKE '%NavigationView%' OR
                content LIKE '%Animation%'
            )
        ''', (self.library_name,))

        for title, content, tags in swiftui_content:
            patterns.extend(self._extract_swiftui_patterns(title, content))

        return patterns

    def _extract_swiftui_patterns(self, title, content):
        """Extract specific SwiftUI patterns from content"""
        patterns = []

        # Add SwiftUI-specific pattern extraction logic here

        return patterns

if __name__ == "__main__":
    synthesizer = {library_name_snake}_Synthesis()
    synthesizer.run_synthesis()
'''

    def _get_update_template(self) -> str:
        """Get template for updating existing synthesis"""
        return '''#!/usr/bin/env python3
"""
Update Existing Synthesis for {library_name}
Updates and extends existing pattern synthesis
"""

import sys
sys.path.append(str(Path.home() / ".claude" / "resources" / "maxwell"))

from maxwell_pattern_synthesis import PatternSynthesizerBase

class {library_name_snake}_Update(PatternSynthesizerBase):
    def __init__(self):
        super().__init__()
        self.library_name = "{library_name}"

    def run_update(self):
        """Update existing synthesis"""
        print(f"🔄 Updating existing synthesis for {self.library_name}")

        # Get new content since last synthesis
        new_content = self.get_new_content_since_last_synthesis()

        if new_content:
            print(f"📄 Found {len(new_content)} new documents to synthesize")
            self.synthesize_new_content(new_content)
        else:
            print("✅ No new content found - synthesis is up to date")

    def get_new_content_since_last_synthesis(self):
        """Get content added since last synthesis run"""
        # This would check timestamps or track last synthesis
        return []

    def synthesize_new_content(self, new_content):
        """Synthesize only the new content"""
        # Add logic to synthesize new content only
        pass

if __name__ == "__main__":
    updater = {library_name_snake}_Update()
    updater.run_update()
'''

    def _execute_synthesis(self, library_name: str, script_path: str) -> Dict:
        """Execute the synthesis script"""
        print(f"🚀 Executing synthesis script...")

        try:
            # Run the synthesis script
            result = subprocess.run(
                ['python3', script_path],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )

            if result.returncode == 0:
                print("✅ Synthesis completed successfully")

                # Count patterns created
                patterns_created = self._count_patterns_created(library_name)

                return {
                    'success': True,
                    'patterns_created': patterns_created,
                    'output': result.stdout
                }
            else:
                print(f"❌ Synthesis failed: {result.stderr}")
                return {
                    'success': False,
                    'error': result.stderr,
                    'patterns_created': 0
                }
        except subprocess.TimeoutExpired:
            print("❌ Synthesis timed out (5 minutes)")
            return {
                'success': False,
                'error': 'Synthesis timed out',
                'patterns_created': 0
            }
        except Exception as e:
            print(f"❌ Error executing synthesis: {e}")
            return {
                'success': False,
                'error': str(e),
                'patterns_created': 0
            }

    def _count_patterns_created(self, library_name: str) -> int:
        """Count how many patterns were created for the library"""
        try:
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM patterns WHERE library = ?
            ''', (library_name,))
            return cursor.fetchone()[0]
        except Exception:
            return 0

    def _validate_patterns(self, library_name: str) -> Dict:
        """Validate synthesized patterns"""
        print(f"🔍 Validating patterns for {library_name}...")

        try:
            # Count patterns
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM patterns WHERE library = ?
            ''', (library_name,))
            pattern_count = cursor.fetchone()[0]

            # Test pattern search
            cursor = self.conn.execute('''
                SELECT title FROM patterns WHERE library = ? LIMIT 3
            ''', (library_name,))
            sample_patterns = [row[0] for row in cursor.fetchall()]

            validation = {
                'pattern_count': pattern_count,
                'sample_patterns': sample_patterns,
                'searchable': len(sample_patterns) > 0,
                'quality_score': self._assess_pattern_quality(library_name)
            }

            print(f"✅ Found {pattern_count} patterns, quality score: {validation['quality_score']}")
            return validation
        except Exception as e:
            print(f"⚠️ Error validating patterns: {e}")
            return {'error': str(e)}

    def _assess_pattern_quality(self, library_name: str) -> float:
        """Assess quality of synthesized patterns"""
        try:
            cursor = self.conn.execute('''
                SELECT AVG(LENGTH(content)) FROM patterns WHERE library = ?
            ''', (library_name,))

            avg_length = cursor.fetchone()[0] or 0

            # Simple quality metric based on content length
            if avg_length < 100:
                return 0.5  # Low quality
            elif avg_length < 300:
                return 0.7  # Medium quality
            else:
                return 0.9  # High quality
        except Exception:
            return 0.0

    def _generate_next_steps(self, library_name: str, synthesis_success: bool) -> List[str]:
        """Generate next steps for the user"""
        steps = []

        if synthesis_success:
            steps.append("✅ Test pattern search functionality")
            steps.append("🔍 Verify patterns appear in Maxwell responses")
            steps.append("📊 Monitor knowledge base performance")
            steps.append("🔄 Schedule periodic synthesis updates")
        else:
            steps.append("🔧 Check synthesis script for errors")
            steps.append("📄 Review source documentation quality")
            steps.append("⚙️ Manually create patterns if needed")
            steps.append("🔄 Try alternative synthesis strategy")

        steps.append(f"📈 Track usage patterns for {library_name}")
        steps.append("🧹 Consider cleanup of unused content")

        return steps

    def _display_synthesis_results(self, result: Dict):
        """Display synthesis results in user-friendly format"""
        print(f"\n🧠 Pattern Synthesis Results")
        print(f"=" * 40)
        print(f"📚 Library: {result['library_name']}")
        print(f"📄 Documents: {result['library_info']['doc_count']}")
        print(f"🎯 Strategy: {result['strategy']}")
        print(f"⚙️ Script generated: {'✅' if result['script_generated'] else '❌'}")
        print(f"🚀 Synthesis completed: {'✅' if result['synthesis_completed'] else '❌'}")
        print(f"🔍 Patterns created: {result['patterns_created']}")

        if result.get('validation'):
            validation = result['validation']
            if 'error' not in validation:
                print(f"✅ Patterns validated: {validation['pattern_count']} patterns")
                print(f"📊 Quality score: {validation['quality_score']}")
            else:
                print(f"⚠️ Validation error: {validation['error']}")

        if result['next_steps']:
            print(f"\n📋 Next Steps:")
            for step in result['next_steps']:
                print(f"   {step}")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 pattern_synthesizer.py <library_name>")
        return 1

    library_name = sys.argv[1]
    synthesizer = PatternSynthesizer()
    result = synthesizer.synthesize_patterns(library_name)

    return 0 if result['synthesis_completed'] else 1

if __name__ == '__main__':
    import sys
    exit(main())