CREATE TABLE IF NOT EXISTS {schema}.todos (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS {schema}.users (
    id VARCHAR(255) PRIMARY KEY, -- Matches Cognito Sub
    email VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'member'
);
