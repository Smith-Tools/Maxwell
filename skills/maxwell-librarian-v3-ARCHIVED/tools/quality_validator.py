#!/usr/bin/env python3
"""
Quality Validation and Reporting for Maxwell Librarian
Validates imported content and generates comprehensive reports
"""

import sqlite3
import json
import os
import subprocess
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from datetime import datetime

class QualityValidator:
    def __init__(self):
        self.db_path = Path.home() / ".claude" / "resources" / "databases" / "maxwell.db"
        self.conn = sqlite3.connect(self.db_path)

    def validate_import(self, library_name: str) -> Dict:
        """Comprehensive validation of imported content"""
        print(f"🔍 Validating {library_name} import...")

        # Check library existence
        if not self._library_exists(library_name):
            return {
                'success': False,
                'error': f'Library "{library_name}" not found',
                'validation_score': 0.0
            }

        # Run all validation checks
        checks = {
            'content_integrity': self._validate_content_integrity(library_name),
            'search_functionality': self._validate_search_functionality(library_name),
            'pattern_synthesis': self._validate_pattern_synthesis(library_name),
            'database_health': self._validate_database_health(library_name),
            'accessibility': self._validate_accessibility(library_name),
            'performance': self._validate_performance(library_name)
        }

        # Calculate overall score
        overall_score = self._calculate_overall_score(checks)

        # Generate recommendations
        recommendations = self._generate_recommendations(checks, overall_score)

        validation_result = {
            'library_name': library_name,
            'validation_date': datetime.now().isoformat(),
            'checks': checks,
            'overall_score': overall_score,
            'status': 'passed' if overall_score >= 0.7 else 'failed',
            'recommendations': recommendations,
            'summary': self._generate_validation_summary(checks, overall_score)
        }

        self._display_validation_results(validation_result)
        return validation_result

    def generate_library_report(self, library_name: str) -> Dict:
        """Generate comprehensive library report"""
        print(f"📊 Generating report for {library_name}...")

        if not self._library_exists(library_name):
            return {
                'success': False,
                'error': f'Library "{library_name}" not found'
            }

        report = {
            'library_name': library_name,
            'report_date': datetime.now().isoformat(),
            'statistics': self._get_library_statistics(library_name),
            'content_analysis': self._analyze_content(library_name),
            'search_analysis': self._analyze_search_performance(library_name),
            'pattern_analysis': self._analyze_patterns(library_name),
            'quality_metrics': self._calculate_quality_metrics(library_name),
            'usage_insights': self._get_usage_insights(library_name),
            'recommendations': self._generate_improvement_recommendations(library_name)
        }

        self._display_library_report(report)
        return report

    def validate_knowledge_base(self) -> Dict:
        """Validate entire knowledge base health"""
        print(f"🏥 Validating knowledge base health...")

        # Database integrity checks
        integrity_checks = self._check_database_integrity()

        # Performance analysis
        performance_metrics = self._analyze_database_performance()

        # Content quality across all libraries
        content_quality = self._assess_overall_content_quality()

        # Search functionality test
        search_health = self._test_overall_search_health()

        overall_health = self._calculate_knowledge_base_health(
            integrity_checks, performance_metrics, content_quality, search_health
        )

        health_report = {
            'validation_date': datetime.now().isoformat(),
            'database_integrity': integrity_checks,
            'performance_metrics': performance_metrics,
            'content_quality': content_quality,
            'search_health': search_health,
            'overall_health_score': overall_health,
            'status': 'healthy' if overall_health >= 0.8 else 'needs_attention',
            'alerts': self._generate_health_alerts(overall_health),
            'maintenance_recommendations': self._generate_maintenance_recommendations()
        }

        self._display_health_report(health_report)
        return health_report

    def _library_exists(self, library_name: str) -> bool:
        """Check if library exists in database"""
        try:
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM reference WHERE library = ?
            ''', (library_name,))
            return cursor.fetchone()[0] > 0
        except Exception:
            return False

    def _validate_content_integrity(self, library_name: str) -> Dict:
        """Validate content integrity and completeness"""
        print("  🔍 Checking content integrity...")

        try:
            # Check for corrupted or incomplete content
            cursor = self.conn.execute('''
                SELECT
                    COUNT(*) as total_docs,
                    COUNT(CASE WHEN content IS NULL OR LENGTH(content) < 50 THEN 1 END) as incomplete_docs,
                    COUNT(CASE WHEN title IS NULL OR LENGTH(title) < 3 THEN 1 END) as untitled_docs,
                    AVG(LENGTH(content)) as avg_content_length
                FROM reference
                WHERE library = ?
            ''', (library_name,))

            result = cursor.fetchone()

            integrity_score = 1.0 - (result[1] + result[2]) / result[0] if result[0] > 0 else 0.0

            issues = []
            if result[1] > 0:
                issues.append(f"{result[1]} documents with incomplete content")
            if result[2] > 0:
                issues.append(f"{result[2]} documents without proper titles")
            if result[3] < 100:
                issues.append("Average content length is very short")

            return {
                'score': integrity_score,
                'total_documents': result[0],
                'incomplete_documents': result[1],
                'untitled_documents': result[2],
                'average_content_length': result[3],
                'issues': issues,
                'status': 'passed' if integrity_score >= 0.9 else 'needs_review'
            }
        except Exception as e:
            return {
                'score': 0.0,
                'error': str(e),
                'status': 'error'
            }

    def _validate_search_functionality(self, library_name: str) -> Dict:
        """Test search functionality for the library"""
        print("  🔍 Testing search functionality...")

        try:
            # Test various search queries
            test_queries = self._generate_test_queries(library_name)
            search_results = []

            for query in test_queries:
                result = self._test_search_query(query, library_name)
                search_results.append(result)

            # Calculate search effectiveness
            successful_searches = sum(1 for r in search_results if r['found_results'])
            search_score = successful_searches / len(search_results) if search_results else 0.0

            return {
                'score': search_score,
                'test_queries': len(test_queries),
                'successful_searches': successful_searches,
                'search_results': search_results,
                'status': 'passed' if search_score >= 0.8 else 'needs_improvement'
            }
        except Exception as e:
            return {
                'score': 0.0,
                'error': str(e),
                'status': 'error'
            }

    def _validate_pattern_synthesis(self, library_name: str) -> Dict:
        """Validate pattern synthesis quality"""
        print("  🔍 Checking pattern synthesis...")

        try:
            # Check if patterns exist
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM patterns WHERE library = ?
            ''', (library_name,))
            pattern_count = cursor.fetchone()[0]

            # Check pattern quality
            cursor = self.conn.execute('''
                SELECT
                    COUNT(*) as total_patterns,
                    AVG(LENGTH(content)) as avg_pattern_length,
                    COUNT(CASE WHEN content IS NULL OR LENGTH(content) < 50 THEN 1 END) as poor_patterns
                FROM patterns WHERE library = ?
            ''', (library_name,))

            if pattern_count > 0:
                result = cursor.fetchone()
                quality_score = 1.0 - (result[2] / result[0]) if result[0] > 0 else 0.0
            else:
                quality_score = 0.0
                result = (0, 0, 0)

            return {
                'score': quality_score,
                'pattern_count': pattern_count,
                'average_pattern_length': result[1],
                'poor_quality_patterns': result[2],
                'status': 'passed' if quality_score >= 0.7 and pattern_count > 0 else 'needs_attention'
            }
        except Exception as e:
            return {
                'score': 0.0,
                'error': str(e),
                'status': 'error'
            }

    def _validate_database_health(self, library_name: str) -> Dict:
        """Check database-specific health for the library"""
        print("  🔍 Checking database health...")

        try:
            # Check for database issues
            cursor = self.conn.execute('''
                SELECT
                    COUNT(*) as total_entries,
                    COUNT(CASE WHEN tags IS NULL OR tags = '[]' THEN 1 END) as untagged_entries,
                    COUNT(DISTINCT folder_path) as folder_count
                FROM reference WHERE library = ?
            ''', (library_name,))

            result = cursor.fetchone()

            # Health score based on organization
            untagged_ratio = result[1] / result[0] if result[0] > 0 else 0.0
            health_score = 1.0 - untagged_ratio

            return {
                'score': health_score,
                'total_entries': result[0],
                'untagged_entries': result[1],
                'folder_count': result[2],
                'organization_quality': health_score,
                'status': 'healthy' if health_score >= 0.8 else 'needs_organization'
            }
        except Exception as e:
            return {
                'score': 0.0,
                'error': str(e),
                'status': 'error'
            }

    def _validate_accessibility(self, library_name: str) -> Dict:
        """Test content accessibility and retrieval"""
        print("  🔍 Testing content accessibility...")

        try:
            # Test random document access
            cursor = self.conn.execute('''
                SELECT id, title FROM reference WHERE library = ? ORDER BY RANDOM() LIMIT 5
            ''', (library_name,))

            sample_docs = cursor.fetchall()
            accessible_docs = 0

            for doc_id, title in sample_docs:
                if self._test_document_access(doc_id):
                    accessible_docs += 1

            accessibility_score = accessible_docs / len(sample_docs) if sample_docs else 0.0

            return {
                'score': accessibility_score,
                'sample_documents': len(sample_docs),
                'accessible_documents': accessible_docs,
                'status': 'accessible' if accessibility_score >= 0.9 else 'has_issues'
            }
        except Exception as e:
            return {
                'score': 0.0,
                'error': str(e),
                'status': 'error'
            }

    def _validate_performance(self, library_name: str) -> Dict:
        """Validate performance characteristics"""
        print("  🔍 Checking performance...")

        try:
            # Test query performance
            import time
            start_time = time.time()

            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM reference WHERE library = ?
            ''', (library_name,))
            result = cursor.fetchone()

            query_time = time.time() - start_time

            # Performance score based on query time
            performance_score = 1.0 if query_time < 0.1 else max(0.0, 1.0 - query_time)

            return {
                'score': performance_score,
                'query_time_seconds': query_time,
                'document_count': result[0],
                'status': 'optimal' if performance_score >= 0.8 else 'needs_optimization'
            }
        except Exception as e:
            return {
                'score': 0.0,
                'error': str(e),
                'status': 'error'
            }

    def _generate_test_queries(self, library_name: str) -> List[str]:
        """Generate test search queries for the library"""
        # Get sample content to generate relevant queries
        cursor = self.conn.execute('''
            SELECT title, tags FROM reference WHERE library = ? LIMIT 3
        ''', (library_name,))

        queries = []
        for title, tags in cursor.fetchall():
            # Extract keywords from title
            title_words = title.lower().split()[:3]  # First 3 words
            if title_words:
                queries.append(' '.join(title_words))

            # Extract keywords from tags if available
            if tags:
                try:
                    tag_list = json.loads(tags)
                    if tag_list:
                        queries.append(tag_list[0].lower())
                except:
                    pass

        # Add some generic queries
        queries.extend(['implementation', 'pattern', 'example', 'usage'])

        return queries[:5]  # Return up to 5 queries

    def _test_search_query(self, query: str, library_name: str) -> Dict:
        """Test a single search query"""
        try:
            # Simulate search query (this would use the actual Maxwell search system)
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM reference
                WHERE library = ? AND (title LIKE ? OR content LIKE ?)
            ''', (library_name, f'%{query}%', f'%{query}%'))

            result_count = cursor.fetchone()[0]

            return {
                'query': query,
                'found_results': result_count > 0,
                'result_count': result_count
            }
        except Exception as e:
            return {
                'query': query,
                'found_results': False,
                'error': str(e)
            }

    def _test_document_access(self, doc_id: int) -> bool:
        """Test if a document can be accessed properly"""
        try:
            cursor = self.conn.execute('''
                SELECT title, content FROM reference WHERE id = ?
            ''', (doc_id,))

            result = cursor.fetchone()
            return result is not None and result[0] is not None and result[1] is not None
        except Exception:
            return False

    def _calculate_overall_score(self, checks: Dict) -> float:
        """Calculate overall validation score"""
        scores = []
        for check_name, check_result in checks.items():
            if isinstance(check_result, dict) and 'score' in check_result:
                scores.append(check_result['score'])

        return sum(scores) / len(scores) if scores else 0.0

    def _generate_recommendations(self, checks: Dict, overall_score: float) -> List[str]:
        """Generate improvement recommendations"""
        recommendations = []

        # Content integrity recommendations
        content_check = checks.get('content_integrity', {})
        if content_check.get('score', 1.0) < 0.9:
            recommendations.append("📝 Review and fix incomplete or untitled documents")

        # Search functionality recommendations
        search_check = checks.get('search_functionality', {})
        if search_check.get('score', 1.0) < 0.8:
            recommendations.append("🔍 Improve search index quality and content metadata")

        # Pattern synthesis recommendations
        pattern_check = checks.get('pattern_synthesis', {})
        if pattern_check.get('score', 1.0) < 0.7 or pattern_check.get('pattern_count', 0) == 0:
            recommendations.append("🧠 Run pattern synthesis to generate searchable patterns")

        # Database health recommendations
        db_check = checks.get('database_health', {})
        if db_check.get('score', 1.0) < 0.8:
            recommendations.append("🏷️ Add proper tags and organization to improve discoverability")

        # Overall recommendations
        if overall_score < 0.6:
            recommendations.append("⚠️ Library requires significant attention - consider reimport")
        elif overall_score < 0.8:
            recommendations.append("🔧 Library needs minor improvements")
        else:
            recommendations.append("✅ Library is in good condition")

        return recommendations

    def _generate_validation_summary(self, checks: Dict, overall_score: float) -> str:
        """Generate a brief validation summary"""
        passed_checks = sum(1 for check in checks.values()
                          if isinstance(check, dict) and check.get('status') in ['passed', 'healthy', 'accessible', 'optimal'])
        total_checks = len([check for check in checks.values() if isinstance(check, dict)])

        if overall_score >= 0.9:
            return f"Excellent: {passed_checks}/{total_checks} checks passed"
        elif overall_score >= 0.7:
            return f"Good: {passed_checks}/{total_checks} checks passed"
        elif overall_score >= 0.5:
            return f"Fair: {passed_checks}/{total_checks} checks passed"
        else:
            return f"Poor: {passed_checks}/{total_checks} checks passed"

    def _get_library_statistics(self, library_name: str) -> Dict:
        """Get detailed library statistics"""
        try:
            # Reference table stats
            cursor = self.conn.execute('''
                SELECT
                    COUNT(*) as total_documents,
                    COUNT(DISTINCT folder_path) as unique_folders,
                    AVG(LENGTH(content)) as avg_content_length,
                    MIN(LENGTH(content)) as min_content_length,
                    MAX(LENGTH(content)) as max_content_length
                FROM reference WHERE library = ?
            ''', (library_name,))

            ref_stats = cursor.fetchone()

            # Pattern table stats
            cursor = self.conn.execute('''
                SELECT COUNT(*) as total_patterns
                FROM patterns WHERE library = ?
            ''', (library_name,))

            pattern_stats = cursor.fetchone()

            return {
                'documents': {
                    'total': ref_stats[0],
                    'folders': ref_stats[1],
                    'avg_content_length': ref_stats[2],
                    'content_length_range': [ref_stats[3], ref_stats[4]]
                },
                'patterns': {
                    'total': pattern_stats[0]
                }
            }
        except Exception as e:
            return {'error': str(e)}

    def _analyze_content(self, library_name: str) -> Dict:
        """Analyze content characteristics"""
        try:
            # Content analysis
            cursor = self.conn.execute('''
                SELECT
                    content,
                    tags,
                    LENGTH(content) as content_length
                FROM reference WHERE library = ?
            ''', (library_name,))

            contents = cursor.fetchall()

            # Analyze tags
            all_tags = set()
            tagged_docs = 0
            for _, tags, _ in contents:
                if tags:
                    try:
                        tag_list = json.loads(tags)
                        if tag_list:
                            all_tags.update(tag_list)
                            tagged_docs += 1
                    except:
                        pass

            # Analyze content lengths
            lengths = [length for _, _, length in contents]
            avg_length = sum(lengths) / len(lengths) if lengths else 0

            return {
                'total_documents': len(contents),
                'tagged_documents': tagged_docs,
                'unique_tags': list(all_tags),
                'tag_coverage': tagged_docs / len(contents) if contents else 0,
                'average_content_length': avg_length
            }
        except Exception as e:
            return {'error': str(e)}

    def _analyze_search_performance(self, library_name: str) -> Dict:
        """Analyze search performance characteristics"""
        try:
            # Test search with sample queries
            test_queries = self._generate_test_queries(library_name)
            search_times = []
            result_counts = []

            import time
            for query in test_queries:
                start_time = time.time()
                cursor = self.conn.execute('''
                    SELECT COUNT(*) FROM reference
                    WHERE library = ? AND (title LIKE ? OR content LIKE ?)
                ''', (library_name, f'%{query}%', f'%{query}%'))
                count = cursor.fetchone()[0]
                query_time = time.time() - start_time

                search_times.append(query_time)
                result_counts.append(count)

            return {
                'test_queries': len(test_queries),
                'average_search_time': sum(search_times) / len(search_times) if search_times else 0,
                'average_result_count': sum(result_counts) / len(result_counts) if result_counts else 0,
                'search_effectiveness': sum(1 for count in result_counts if count > 0) / len(result_counts) if result_counts else 0
            }
        except Exception as e:
            return {'error': str(e)}

    def _analyze_patterns(self, library_name: str) -> Dict:
        """Analyze synthesized patterns"""
        try:
            cursor = self.conn.execute('''
                SELECT
                    title,
                    content,
                    LENGTH(content) as content_length
                FROM patterns WHERE library = ?
            ''', (library_name,))

            patterns = cursor.fetchall()

            if not patterns:
                return {
                    'total_patterns': 0,
                    'message': 'No patterns found - synthesis may be needed'
                }

            lengths = [length for _, _, length in patterns]
            avg_length = sum(lengths) / len(lengths)

            return {
                'total_patterns': len(patterns),
                'average_pattern_length': avg_length,
                'pattern_quality': 'good' if avg_length > 200 else 'needs_improvement',
                'sample_titles': [title for title, _, _ in patterns[:5]]
            }
        except Exception as e:
            return {'error': str(e)}

    def _calculate_quality_metrics(self, library_name: str) -> Dict:
        """Calculate overall quality metrics"""
        try:
            # Get data for quality calculation
            cursor = self.conn.execute('''
                SELECT
                    LENGTH(content) as content_len,
                    tags,
                    title
                FROM reference WHERE library = ?
            ''', (library_name,))

            docs = cursor.fetchall()

            if not docs:
                return {'overall_score': 0.0, 'error': 'No documents found'}

            # Calculate quality factors
            content_quality_scores = []
            tag_coverage = 0
            title_quality = 0

            for content_len, tags, title in docs:
                # Content quality (based on length)
                content_score = min(1.0, content_len / 500)  # Normalize to 500 chars as ideal
                content_quality_scores.append(content_score)

                # Tag quality
                if tags:
                    try:
                        tag_list = json.loads(tags)
                        if tag_list:
                            tag_coverage += 1
                    except:
                        pass

                # Title quality
                if title and len(title.strip()) > 3:
                    title_quality += 1

            avg_content_quality = sum(content_quality_scores) / len(content_quality_scores)
            tag_quality_score = tag_coverage / len(docs)
            title_quality_score = title_quality / len(docs)

            # Overall quality score
            overall_score = (avg_content_quality * 0.5 +
                           tag_quality_score * 0.3 +
                           title_quality_score * 0.2)

            return {
                'overall_score': overall_score,
                'content_quality': avg_content_quality,
                'tag_quality': tag_quality_score,
                'title_quality': title_quality_score,
                'grade': 'A' if overall_score >= 0.9 else 'B' if overall_score >= 0.7 else 'C' if overall_score >= 0.5 else 'D'
            }
        except Exception as e:
            return {'error': str(e)}

    def _get_usage_insights(self, library_name: str) -> Dict:
        """Get usage insights and recommendations"""
        # This would integrate with Maxwell's usage tracking
        # For now, provide mock insights
        return {
            'last_accessed': 'Unknown',
            'search_frequency': 'Not tracked',
            'popular_content': 'Not tracked',
            'recommendations': [
                'Enable usage tracking to get insights',
                'Monitor which patterns are most useful',
                'Track search query patterns'
            ]
        }

    def _generate_improvement_recommendations(self, library_name: str) -> List[str]:
        """Generate specific improvement recommendations"""
        recommendations = []

        # Get quality metrics to inform recommendations
        quality_metrics = self._calculate_quality_metrics(library_name)

        if 'error' not in quality_metrics:
            if quality_metrics['content_quality'] < 0.7:
                recommendations.append("📝 Enhance content depth and detail")

            if quality_metrics['tag_quality'] < 0.8:
                recommendations.append("🏷️ Add comprehensive tags for better discoverability")

            if quality_metrics['title_quality'] < 0.9:
                recommendations.append("📋 Improve title clarity and descriptiveness")

        # Check pattern synthesis
        pattern_analysis = self._analyze_patterns(library_name)
        if pattern_analysis.get('total_patterns', 0) == 0:
            recommendations.append("🧠 Run pattern synthesis to generate searchable patterns")
        elif pattern_analysis.get('pattern_quality') == 'needs_improvement':
            recommendations.append("🔧 Improve pattern synthesis quality")

        return recommendations or ["✅ Library is well-optimized"]

    def _check_database_integrity(self) -> Dict:
        """Check overall database integrity"""
        try:
            # Check table structures
            cursor = self.conn.execute("SELECT name FROM sqlite_master WHERE type='table'")
            tables = [row[0] for row in cursor.fetchall()]

            expected_tables = ['reference', 'patterns']
            missing_tables = [table for table in expected_tables if table not in tables]

            # Check for corrupt data
            cursor = self.conn.execute('''
                SELECT COUNT(*) FROM reference WHERE content IS NULL
            ''')
            null_content_count = cursor.fetchone()[0]

            integrity_score = 1.0 if not missing_tables and null_content_count == 0 else 0.5

            return {
                'score': integrity_score,
                'expected_tables': expected_tables,
                'missing_tables': missing_tables,
                'null_content_count': null_content_count,
                'status': 'integrity_good' if integrity_score >= 0.9 else 'needs_repair'
            }
        except Exception as e:
            return {'score': 0.0, 'error': str(e)}

    def _analyze_database_performance(self) -> Dict:
        """Analyze database performance"""
        try:
            import time
            start_time = time.time()

            # Test basic query performance
            cursor = self.conn.execute('SELECT COUNT(*) FROM reference')
            total_docs = cursor.fetchone()[0]

            query_time = time.time() - start_time

            performance_score = 1.0 if query_time < 0.1 else max(0.0, 1.0 - query_time)

            return {
                'score': performance_score,
                'total_documents': total_docs,
                'query_time_seconds': query_time,
                'status': 'optimal' if performance_score >= 0.8 else 'needs_optimization'
            }
        except Exception as e:
            return {'score': 0.0, 'error': str(e)}

    def _assess_overall_content_quality(self) -> Dict:
        """Assess content quality across all libraries"""
        try:
            cursor = self.conn.execute('''
                SELECT
                    COUNT(*) as total_documents,
                    AVG(LENGTH(content)) as avg_content_length,
                    COUNT(CASE WHEN tags IS NOT NULL AND tags != '[]' THEN 1 END) as tagged_documents,
                    COUNT(DISTINCT library) as library_count
                FROM reference
            ''')

            result = cursor.fetchone()

            # Calculate quality scores
            tag_coverage = result[2] / result[0] if result[0] > 0 else 0
            content_quality = min(1.0, (result[1] or 0) / 300)  # 300 chars as baseline

            overall_quality = (tag_coverage * 0.4 + content_quality * 0.6)

            return {
                'score': overall_quality,
                'total_documents': result[0],
                'library_count': result[3],
                'average_content_length': result[1],
                'tag_coverage': tag_coverage,
                'status': 'good' if overall_quality >= 0.7 else 'needs_improvement'
            }
        except Exception as e:
            return {'score': 0.0, 'error': str(e)}

    def _test_overall_search_health(self) -> Dict:
        """Test search functionality across knowledge base"""
        try:
            # Test common search terms
            test_terms = ['swift', 'pattern', 'implementation', 'example']
            successful_searches = 0

            for term in test_terms:
                cursor = self.conn.execute('''
                    SELECT COUNT(*) FROM reference
                    WHERE content LIKE ? OR title LIKE ?
                ''', (f'%{term}%', f'%{term}%'))

                if cursor.fetchone()[0] > 0:
                    successful_searches += 1

            search_health = successful_searches / len(test_terms)

            return {
                'score': search_health,
                'test_terms': len(test_terms),
                'successful_searches': successful_searches,
                'status': 'healthy' if search_health >= 0.8 else 'needs_attention'
            }
        except Exception as e:
            return {'score': 0.0, 'error': str(e)}

    def _calculate_knowledge_base_health(self, integrity: Dict, performance: Dict,
                                       content: Dict, search: Dict) -> float:
        """Calculate overall knowledge base health score"""
        scores = [
            integrity.get('score', 0.0),
            performance.get('score', 0.0),
            content.get('score', 0.0),
            search.get('score', 0.0)
        ]

        return sum(scores) / len(scores)

    def _generate_health_alerts(self, health_score: float) -> List[str]:
        """Generate health alerts based on score"""
        alerts = []

        if health_score < 0.5:
            alerts.append("🚨 Critical: Knowledge base requires immediate attention")
        elif health_score < 0.7:
            alerts.append("⚠️ Warning: Knowledge base health needs improvement")
        elif health_score < 0.9:
            alerts.append("📝 Note: Some optimizations recommended")
        else:
            alerts.append("✅ Knowledge base is healthy")

        return alerts

    def _generate_maintenance_recommendations(self) -> List[str]:
        """Generate maintenance recommendations"""
        return [
            "🧹 Run regular cleanup of duplicate content",
            "🏷️ Ensure all content has proper tags",
            "🔍 Validate search index integrity",
            "📊 Monitor knowledge base growth and usage",
            "🔄 Schedule periodic pattern synthesis updates",
            "💾 Regular database backups recommended"
        ]

    def _display_validation_results(self, result: Dict):
        """Display validation results in user-friendly format"""
        print(f"\n🔍 Validation Results for {result['library_name']}")
        print(f"=" * 50)
        print(f"📅 Validated: {result['validation_date']}")
        print(f"📊 Overall Score: {result['overall_score']:.2f}")
        print(f"📋 Status: {result['status'].upper()}")
        print(f"📝 Summary: {result['summary']}")

        print(f"\n🧪 Check Results:")
        for check_name, check_result in result['checks'].items():
            if isinstance(check_result, dict):
                status = check_result.get('status', 'unknown')
                score = check_result.get('score', 0.0)
                print(f"   {check_name.replace('_', ' ').title()}: {status} (score: {score:.2f})")

        if result['recommendations']:
            print(f"\n📋 Recommendations:")
            for rec in result['recommendations']:
                print(f"   {rec}")

    def _display_library_report(self, report: Dict):
        """Display comprehensive library report"""
        print(f"\n📊 Library Report: {report['library_name']}")
        print(f"=" * 50)
        print(f"📅 Generated: {report['report_date']}")

        # Statistics
        stats = report.get('statistics', {})
        if 'error' not in stats:
            print(f"\n📈 Statistics:")
            print(f"   📄 Documents: {stats.get('documents', {}).get('total', 0)}")
            print(f"   📁 Folders: {stats.get('documents', {}).get('folders', 0)}")
            print(f"   🧠 Patterns: {stats.get('patterns', {}).get('total', 0)}")

        # Quality metrics
        quality = report.get('quality_metrics', {})
        if 'error' not in quality:
            print(f"\n🎯 Quality Metrics:")
            print(f"   Overall Score: {quality.get('overall_score', 0):.2f} ({quality.get('grade', 'N/A')})")
            print(f"   Content Quality: {quality.get('content_quality', 0):.2f}")
            print(f"   Tag Quality: {quality.get('tag_quality', 0):.2f}")

        # Recommendations
        if report.get('recommendations'):
            print(f"\n📋 Improvement Recommendations:")
            for rec in report['recommendations']:
                print(f"   {rec}")

    def _display_health_report(self, report: Dict):
        """Display knowledge base health report"""
        print(f"\n🏥 Knowledge Base Health Report")
        print(f"=" * 40)
        print(f"📅 Checked: {report['validation_date']}")
        print(f"💓 Overall Health: {report['overall_health_score']:.2f}")
        print(f"📊 Status: {report['status'].replace('_', ' ').title()}")

        print(f"\n🔍 Health Components:")
        components = [
            ('Database Integrity', report.get('database_integrity', {})),
            ('Performance', report.get('performance_metrics', {})),
            ('Content Quality', report.get('content_quality', {})),
            ('Search Health', report.get('search_health', {}))
        ]

        for name, component in components:
            score = component.get('score', 0.0)
            status = component.get('status', 'unknown')
            print(f"   {name}: {status} ({score:.2f})")

        if report.get('alerts'):
            print(f"\n🚨 Health Alerts:")
            for alert in report['alerts']:
                print(f"   {alert}")

        if report.get('maintenance_recommendations'):
            print(f"\n🔧 Maintenance Recommendations:")
            for rec in report['maintenance_recommendations']:
                print(f"   {rec}")

def main():
    import sys

    if len(sys.argv) < 2:
        print("Usage: python3 quality_validator.py <command> [library_name]")
        print("Commands:")
        print("  validate <library_name>  - Validate specific library import")
        print("  report <library_name>    - Generate library report")
        print("  health                   - Check knowledge base health")
        return 1

    command = sys.argv[1]
    validator = QualityValidator()

    if command == "validate" and len(sys.argv) >= 3:
        library_name = sys.argv[2]
        result = validator.validate_import(library_name)
        return 0 if result['overall_score'] >= 0.7 else 1

    elif command == "report" and len(sys.argv) >= 3:
        library_name = sys.argv[2]
        validator.generate_library_report(library_name)
        return 0

    elif command == "health":
        result = validator.validate_knowledge_base()
        return 0 if result['overall_health_score'] >= 0.8 else 1

    else:
        print("Invalid command or missing arguments")
        return 1

if __name__ == '__main__':
    exit(main())