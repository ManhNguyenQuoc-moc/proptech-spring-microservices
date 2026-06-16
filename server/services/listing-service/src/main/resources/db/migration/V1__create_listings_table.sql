CREATE TABLE IF NOT EXISTS listings (
    id UUID PRIMARY KEY,
    title VARCHAR(250) NOT NULL,
    description VARCHAR(2000),
    price NUMERIC(19, 2) NOT NULL,
    address VARCHAR(500)
);
