CREATE DATABASE inventory;

CREATE TABLE houseware (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    variant TEXT,
    image_url TEXT,
    tag TEXT,
    user_id INTEGER,
    purchase_date DATE,
    quantity NUMERIC(10,2),
    expiry_date DATE
);

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username TEXT,
  email TEXT,
  password_digest TEXT
);

