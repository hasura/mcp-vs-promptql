    CREATE TABLE IF NOT EXISTS Users (
        id UUID PRIMARY KEY,
        email TEXT NOT NULL,
        customer_id TEXT UNIQUE NOT NULL,
        created_at TIMESTAMPTZ NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL,
        first_name TEXT,
        last_name TEXT
    );

-- Sample Users row: 
-- id,customerId
-- fa87abc9-ef26-42e9-9fbd-1c90a26a2ddb,cus_b7f6887cf4874bc1


    CREATE TABLE IF NOT EXISTS Projects (
        id UUID PRIMARY KEY,
        name TEXT NOT NULL,
        owner_id UUID NOT NULL,
        created_at TIMESTAMPTZ NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL,
        deleted_at TIMESTAMPTZ,
        active_models INTEGER,
        FOREIGN KEY (owner_id) REFERENCES Users(id)
    );

-- Sample Projects row:
-- createdAt,deletedAt,id,name,ownerId,updatedAt
-- 2023-03-03T09:25:46.902232,,75b6aba0-e6c6-4500-a2f0-86d0dea54f41,game-pelican-6670,fa87abc9-ef26-42e9-9fbd-1c90a26a2ddb,2023-03-03T09:25:46.902232

    CREATE TABLE IF NOT EXISTS Invoice (
        stripe_invoice_id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        subscription_id TEXT,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        invoice_url TEXT,
        attempt_count INTEGER,
        created_at TIMESTAMPTZ NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES Users(customer_id)
    );

-- attemptCount,createdAt,customerId,description,invoiceUrl,month,status,stripeInvoiceId,subscriptionId,updatedAt,year
-- ,2022-12-26T09:00:41.625067,cus_b7f6887cf4874bc1,,,12,paid,inv_fa87abc9-ef26-42e9-9fbd-1c90a26a2ddb_12_2022,,2022-12-26T09:00:41.625067,2022

        CREATE TABLE IF NOT EXISTS Invoice_item (
        id UUID PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        amount NUMERIC NOT NULL,
        description TEXT,
        project_id UUID NOT NULL,
        type TEXT NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL,
        has_updated_to_stripe BOOLEAN NOT NULL,
        error TEXT,
        created_at TIMESTAMPTZ NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES Invoice(stripe_invoice_id),
        FOREIGN KEY (project_id) REFERENCES Projects(id)
    );

-- Sample Invoice_item row:
-- amount,createdAt,description,error,hasUpdatedToStripe,id,invoiceId,month,projectId,type,updatedAt,year
-- 55,2022-11-26T09:00:41.625067,,,False,d632e80e-7e2e-4ec2-9296-311c4d5c6690,inv_eda2b9d8-caec-4913-85ac-953fff43a439_11_2022,11,12bd371e-a556-4384-8b8d-d32c3f338331,active-model-count,2022-11-26T09:00:41.625067,2022


    CREATE TABLE IF NOT EXISTS Plans (
        id UUID PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TIMESTAMPTZ NOT NULL,
        updated_at TIMESTAMPTZ NOT NULL
    );

-- Sample Plans row:
-- createdAt,id,name,updatedAt
-- 2023-11-21T08:28:23.277447,2d41d1de-51fa-41ed-8acd-6ee63bcd316e,free,2023-11-21T08:28:23.277447

        CREATE TABLE IF NOT EXISTS Project_Plan_Changelogs (
        id UUID PRIMARY KEY,
        plan_id UUID NOT NULL,
        project_id UUID NOT NULL,
        comment TEXT,
        created_at TIMESTAMPTZ NOT NULL,
        FOREIGN KEY (plan_id) REFERENCES Plans(id),
        FOREIGN KEY (project_id) REFERENCES Projects(id)
    );

-- Sample Project_Plan_Changelogs Row:
-- comment,createdAt,id,planId,projectId
-- Initial plan assignment,2023-03-03T09:25:46.902232,114f72e4-c9ab-422f-a0e5-ebf4984ea188,28058da3-610f-4d2f-94d8-10bf0a340d6b,75b6aba0-e6c6-4500-a2f0-86d0dea54f41

CREATE TABLE IF NOT EXISTS Requests_Daily_Count (
        project_id  UUID,
        date DATE NOT NULL,
        request_count INTEGER NOT NULL,
        PRIMARY KEY (project_id, date),
        FOREIGN KEY (project_id) REFERENCES Projects(id)
    );

-- Sample Requests_Daily_Count row:
-- date,projectId,requestCount
-- 2023-03-03,75b6aba0-e6c6-4500-a2f0-86d0dea54f41,0

CREATE TABLE IF NOT EXISTS Error_Rate_Daily (
        project_id  UUID ,
        date DATE NOT NULL,
        success_count INTEGER,
        error_count INTEGER,
        error_rate FLOAT,
        PRIMARY KEY (project_id, date),
        FOREIGN KEY (project_id) REFERENCES Projects(id)    
    );


create table data_generation_seeds(project_id uuid, initial_request_pattern_type text, price_per_model_advanced integer, support_request_pattern_type text, ticket_frequency text);
