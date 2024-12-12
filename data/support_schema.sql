CREATE TABLE IF NOT EXISTS Support_User (
        id SERIAL PRIMARY KEY,
        email text,
        role text
    );

CREATE UNIQUE INDEX idx_support_user_email 
ON Support_User (email);

-- Sample Support_user row:
-- email,id,role
-- angela.martin@lynch-miller.com,1, customer
-- email,id,role
-- john.mills@hasura.io,2, agent


    CREATE TABLE IF NOT EXISTS Support_Ticket (
        id SERIAL PRIMARY KEY,
        is_public BOOLEAN NOT NULL,
        priority TEXT,
        status TEXT,
        subject TEXT,
        description TEXT,
        type TEXT,
        assignee_id INTEGER,
        requester_id INTEGER,
        created_at TIMESTAMPTZ,
        url TEXT,
        FOREIGN KEY (assignee_id) REFERENCES Support_User(id),
        FOREIGN KEY (requester_id) REFERENCES Support_User(id)
    );

-- First, create the trigger function
CREATE OR REPLACE FUNCTION set_ticket_url()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the url field with the formatted URL
    UPDATE Support_Ticket
    SET url = 'https://support.hasura.io/tickets/' || NEW.id::text
    WHERE id = NEW.id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Then, create the trigger
DROP TRIGGER IF EXISTS set_ticket_url_trigger ON Support_Ticket;
CREATE TRIGGER set_ticket_url_trigger
    AFTER INSERT ON Support_Ticket
    FOR EACH ROW
    EXECUTE FUNCTION set_ticket_url();


CREATE TABLE IF NOT EXISTS Support_Ticket_Comment (
        id SERIAL PRIMARY KEY,
        ticket_id INTEGER,
        body TEXT,
        created_at TIMESTAMPTZ,
        user_id INTEGER,
        FOREIGN KEY (user_id) REFERENCES Support_User(id),
        FOREIGN KEY (ticket_id) REFERENCES Support_Ticket(id)
    );

