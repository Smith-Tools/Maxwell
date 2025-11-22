-- Maxwell Pattern Database Schema
-- Supports contradiction detection and pattern management

-- Main patterns table
CREATE TABLE IF NOT EXISTS patterns (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    domain TEXT NOT NULL,
    problem TEXT NOT NULL,
    solution TEXT NOT NULL,
    code_example TEXT,
    notes TEXT,
    source_name TEXT NOT NULL,
    source_type TEXT NOT NULL, -- 'official', 'expert', 'derived', 'opinion'
    authority_level TEXT NOT NULL, -- 'canonical', 'expert', 'derived', 'opinion'
    credibility INTEGER CHECK (credibility BETWEEN 1 AND 5),
    created_at TEXT DEFAULT CURRENT_TIMESTAMP,
    updated_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Contradiction tracking
CREATE TABLE IF NOT EXISTS contradictions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern_a_id INTEGER NOT NULL,
    pattern_b_id INTEGER NOT NULL,
    contradiction_type TEXT NOT NULL, -- 'architectural', 'implementation', 'source_authority'
    severity TEXT NOT NULL, -- 'critical', 'warning', 'info'
    detected_at TEXT DEFAULT CURRENT_TIMESTAMP,
    keywords TEXT, -- JSON array of contradictory keywords found
    description TEXT,
    FOREIGN KEY (pattern_a_id) REFERENCES patterns (id),
    FOREIGN KEY (pattern_b_id) REFERENCES patterns (id)
);

-- Contradiction resolutions
CREATE TABLE IF NOT EXISTS contradiction_resolutions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    contradiction_id INTEGER NOT NULL,
    resolution_strategy TEXT NOT NULL, -- 'follow_highest_credibility', 'synthesize', 'human_decision'
    chosen_pattern_id INTEGER,
    deprecated_pattern_id INTEGER,
    decision_notes TEXT,
    decided_at TEXT DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (contradiction_id) REFERENCES contradictions (id),
    FOREIGN KEY (chosen_pattern_id) REFERENCES patterns (id),
    FOREIGN KEY (deprecated_pattern_id) REFERENCES patterns (id)
);

-- Full-text search for patterns
CREATE VIRTUAL TABLE IF NOT EXISTS pattern_search USING fts5(
    name,
    domain,
    problem,
    solution,
    notes,
    content='patterns',
    content_rowid='id'
);

-- Triggers to maintain FTS index
CREATE TRIGGER IF NOT EXISTS patterns_fts_insert AFTER INSERT ON patterns BEGIN
    INSERT INTO pattern_search(rowid, name, domain, problem, solution, notes)
    VALUES (new.id, new.name, new.domain, new.problem, new.solution, new.notes);
END;

CREATE TRIGGER IF NOT EXISTS patterns_fts_update AFTER UPDATE ON patterns BEGIN
    UPDATE pattern_search SET
        name = new.name,
        domain = new.domain,
        problem = new.problem,
        solution = new.solution,
        notes = new.notes
    WHERE rowid = new.id;
END;

CREATE TRIGGER IF NOT EXISTS patterns_fts_delete AFTER DELETE ON patterns BEGIN
    DELETE FROM pattern_search WHERE rowid = old.id;
END;

-- Contradiction detection trigger
CREATE TRIGGER IF NOT EXISTS detect_contradiction_on_insert
BEFORE INSERT ON patterns
BEGIN
    -- This would be handled by skill logic, not SQLite triggers
    -- Left as placeholder for future enhancement
    SELECT RAISE(IGNORE);
END;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_patterns_domain ON patterns(domain);
CREATE INDEX IF NOT EXISTS idx_patterns_source_type ON patterns(source_type);
CREATE INDEX IF NOT EXISTS idx_patterns_credibility ON patterns(credibility);
CREATE INDEX IF NOT EXISTS idx_contradictions_severity ON contradictions(severity);
CREATE INDEX IF NOT EXISTS idx_contradictions_patterns ON contradictions(pattern_a_id, pattern_b_id);

-- Views for common queries

-- High-credibility patterns by domain
CREATE VIEW IF NOT EXISTS high_credibility_patterns AS
SELECT
    id, name, domain, problem, solution, source_name, credibility
FROM patterns
WHERE credibility >= 4
ORDER BY domain, credibility DESC;

-- Patterns with contradictions
CREATE VIEW IF NOT EXISTS patterns_with_contradictions AS
SELECT
    p.*,
    c.severity as contradiction_severity,
    c.contradiction_type
FROM patterns p
JOIN contradictions c ON (p.id = c.pattern_a_id OR p.id = c.pattern_b_id)
GROUP BY p.id;

-- Contradiction summary by domain
CREATE VIEW IF NOT EXISTS contradiction_summary AS
SELECT
    p.domain,
    COUNT(*) as contradiction_count,
    COUNT(CASE WHEN c.severity = 'critical' THEN 1 END) as critical_count,
    COUNT(CASE WHEN c.severity = 'warning' THEN 1 END) as warning_count,
    COUNT(CASE WHEN c.severity = 'info' THEN 1 END) as info_count
FROM contradictions c
JOIN patterns p ON (p.id = c.pattern_a_id OR p.id = c.pattern_b_id)
GROUP BY p.domain;

-- Sample queries for contradiction detection

-- Find potential contradictory patterns in same domain
-- Query: SELECT * FROM find_potential_contradictions('TCA');
WITH RECURSIVE find_potential_contradictions(domain_name) AS (
    SELECT domain_name
    UNION
    SELECT id, name, recommendation, source, credibility
    FROM patterns
    WHERE domain = domain_name
    AND (
        recommendation LIKE '%single%' OR recommendation LIKE '%multiple%' OR
        recommendation LIKE '%only%' OR recommendation LIKE '%both%' OR
        recommendation LIKE '%owner%' OR recommendation LIKE '%shared%' OR
        recommendation LIKE '%writer%' OR recommendation LIKE '%readers%'
    )
)
SELECT * FROM find_potential_contradictions;