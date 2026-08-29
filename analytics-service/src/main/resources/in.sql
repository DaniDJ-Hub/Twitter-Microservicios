
-- Create schema if it doesn't exist (notice will still appear but is harmless)
CREATE SCHEMA IF NOT EXISTS analytics;

-- Set search path to analytics schema
SET search_path TO analytics;

-- Drop existing table if you want to recreate it (careful - this will delete data)
-- DROP TABLE IF EXISTS twitter_analytics;

-- Create table only if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname = 'analytics' AND tablename = 'twitter_analytics') THEN
        CREATE TABLE twitter_analytics (
            id UUID NOT NULL,
            word VARCHAR(255) NOT NULL,
            word_count BIGINT NOT NULL,
            record_date TIMESTAMP NOT NULL,
            CONSTRAINT pk_twitter_analytics PRIMARY KEY (id)
        );
        
        -- Create indexes for better query performance
        CREATE INDEX idx_twitter_analytics_word ON twitter_analytics (word);
        CREATE INDEX idx_twitter_analytics_record_date ON twitter_analytics (record_date);
        CREATE INDEX idx_twitter_analytics_word_count ON twitter_analytics (word_count);
        
        -- Add comments for documentation
        COMMENT ON TABLE twitter_analytics IS 'Table to store Twitter analytics data including word counts and timestamps';
        COMMENT ON COLUMN twitter_analytics.id IS 'Unique identifier for each analytics record';
        COMMENT ON COLUMN twitter_analytics.word IS 'The word being tracked for analytics';
        COMMENT ON COLUMN twitter_analytics.word_count IS 'Number of occurrences of the word';
        COMMENT ON COLUMN twitter_analytics.record_date IS 'Timestamp when the analytics record was created';
        
        RAISE NOTICE 'Table twitter_analytics created successfully';
    ELSE
        RAISE NOTICE 'Table twitter_analytics already exists, skipping creation';
    END IF;
END $$;

-- Insert sample data with conflict handling
INSERT INTO twitter_analytics (id, word, word_count, record_date) VALUES
-- Technology trending words
('550e8400-e29b-41d4-a716-446655440001', 'AI', 1250, '2025-06-02 08:00:00'),
('550e8400-e29b-41d4-a716-446655440002', 'blockchain', 890, '2025-06-02 08:15:00')
ON CONFLICT (id) DO NOTHING;

-- Insert sample data into existing twitter_analytics table
INSERT INTO twitter_analytics (id, word, word_count, record_date) VALUES
-- Technology trending words
('550e8400-e29b-41d4-a716-446655440003', 'cryptocurrency', 2340, '2025-06-02 08:30:00'),
('550e8400-e29b-41d4-a716-446655440004', 'microservices', 567, '2025-06-02 08:45:00'),
('550e8400-e29b-41d4-a716-446655440005', 'docker', 823, '2025-06-02 09:00:00'),

-- Social media and culture
('550e8400-e29b-41d4-a716-446655440006', 'trending', 1890, '2025-06-02 09:15:00'),
('550e8400-e29b-41d4-a716-446655440007', 'viral', 3456, '2025-06-02 09:30:00'),
('550e8400-e29b-41d4-a716-446655440008', 'meme', 2234, '2025-06-02 09:45:00'),
('550e8400-e29b-41d4-a716-446655440009', 'influencer', 1678, '2025-06-02 10:00:00'),
('550e8400-e29b-41d4-a716-446655440010', 'content', 4567, '2025-06-02 10:15:00'),

-- Business and finance
('550e8400-e29b-41d4-a716-446655440011', 'startup', 1123, '2025-06-02 10:30:00'),
('550e8400-e29b-41d4-a716-446655440012', 'investment', 2890, '2025-06-02 10:45:00'),
('550e8400-e29b-41d4-a716-446655440013', 'economy', 3234, '2025-06-02 11:00:00'),
('550e8400-e29b-41d4-a716-446655440014', 'market', 4123, '2025-06-02 11:15:00'),
('550e8400-e29b-41d4-a716-446655440015', 'innovation', 1567, '2025-06-02 11:30:00'),

-- Sports and entertainment
('550e8400-e29b-41d4-a716-446655440016', 'football', 5678, '2025-06-02 11:45:00'),
('550e8400-e29b-41d4-a716-446655440017', 'basketball', 4321, '2025-06-02 12:00:00'),
('550e8400-e29b-41d4-a716-446655440018', 'streaming', 3890, '2025-06-02 12:15:00'),
('550e8400-e29b-41d4-a716-446655440019', 'gaming', 6789, '2025-06-02 12:30:00'),
('550e8400-e29b-41d4-a716-446655440020', 'esports', 2456, '2025-06-02 12:45:00'),

-- News and current events
('550e8400-e29b-41d4-a716-446655440021', 'breaking', 7890, '2025-06-02 13:00:00'),
('550e8400-e29b-41d4-a716-446655440022', 'news', 9876, '2025-06-02 13:15:00'),
('550e8400-e29b-41d4-a716-446655440023', 'politics', 5432, '2025-06-02 13:30:00'),
('550e8400-e29b-41d4-a716-446655440024', 'climate', 3210, '2025-06-02 13:45:00'),
('550e8400-e29b-41d4-a716-446655440025', 'sustainability', 1890, '2025-06-02 14:00:00'),

-- Travel and lifestyle
('550e8400-e29b-41d4-a716-446655440026', 'travel', 4567, '2025-06-02 14:15:00'),
('550e8400-e29b-41d4-a716-446655440027', 'food', 6543, '2025-06-02 14:30:00'),
('550e8400-e29b-41d4-a716-446655440028', 'fitness', 3456, '2025-06-02 14:45:00'),
('550e8400-e29b-41d4-a716-446655440029', 'wellness', 2345, '2025-06-02 15:00:00'),
('550e8400-e29b-41d4-a716-446655440030', 'photography', 1987, '2025-06-02 15:15:00'),

-- Historical data (previous days)
('550e8400-e29b-41d4-a716-446655440031', 'AI', 1100, '2025-06-01 14:00:00'),
('550e8400-e29b-41d4-a716-446655440032', 'cryptocurrency', 2100, '2025-06-01 14:30:00'),
('550e8400-e29b-41d4-a716-446655440033', 'viral', 3200, '2025-06-01 15:00:00'),
('550e8400-e29b-41d4-a716-446655440034', 'gaming', 6200, '2025-05-31 16:00:00'),
('550e8400-e29b-41d4-a716-446655440035', 'news', 8900, '2025-05-31 17:00:00'),

-- Additional recent data for better testing
('550e8400-e29b-41d4-a716-446655440036', 'machine learning', 1876, '2025-06-02 16:00:00'),
('550e8400-e29b-41d4-a716-446655440037', 'data science', 1456, '2025-06-02 16:15:00'),
('550e8400-e29b-41d4-a716-446655440038', 'cloud computing', 2987, '2025-06-02 16:30:00'),
('550e8400-e29b-41d4-a716-446655440039', 'cybersecurity', 2134, '2025-06-02 16:45:00'),
('550e8400-e29b-41d4-a716-446655440040', 'automation', 1765, '2025-06-02 17:00:00');

-- Add more records as needed following the same pattern

-- Verify the insertion
SELECT 'Data insertion completed' as status;
SELECT COUNT(*) as total_records FROM twitter_analytics;
SELECT word, word_count, record_date FROM twitter_analytics ORDER BY word_count DESC LIMIT 10;