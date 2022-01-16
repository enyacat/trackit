require 'pg'
require 'bcrypt'

def create_user(email, password, role)
    password_digest = BCrypt::Password.create(password)
    sql = "INSERT INTO users (email, password_digest, role) VALUES ($1, $2, $3);"
    db_query(sql, [email, password_digest, role])
end

def find_user_by_id(id)
    db_query('SELECT * FROM users where id = $1', [id]).first
end