require 'pg'

def db_query(sql, params = [])
    conn = PG.connect(ENV['DATABASE_URL']) || { dbname: 'inventory' })
    result = conn.exec_params(sql, params)

    conn.close
    return result
end

def all_items()
    db_query('SELECT * FROM houseware order by name;')
end

def items_by_tag(tag)
    sql = "SELECT * FROM houseware WHERE tag = '#{tag}' and user_id = '2';"
    db_query(sql)
end

def get_tags()
    db_query('SELECT DISTINCT tag FROM houseware order by tag;')
end

def create_item(name, variant, image_url, tag, user_id, purchase_date, quantity, expiry_date)
    sql = "INSERT INTO houseware (name, variant, image_url, tag, user_id, purchase_date, quantity, expiry_date) VALUES ($1, $2, $3, $4, $5, $6, $7, $8)"
    db_query(sql, [name, variant, image_url, tag, user_id, purchase_date, quantity, expiry_date])
end

def delete_item(id)
    db_query("delete from houseware where id = $1;", [id])
end
 
def update_item(name, variant, image_url, tag, purchase_date, quantity, expiry_date, id)
    sql = "UPDATE houseware set name = $1, variant = $2, image_url = $3, tag = $4, purchase_date = $5, quantity = $6, expiry_date = $7 WHERE id = $8;"
    db_query(sql, [name, variant, image_url, tag, purchase_date, quantity, expiry_date, id])
end

# below is user customised list

def show_user_list(user_id)
    sql = "SELECT * from houseware WHERE user_id = '#{user_id}' order by tag"
    db_query(sql)
end

def add_item_to_list(item_id)
    sql = "INSERT INTO houseware (name, variant, image_url, tag, user_id, purchase_date, quantity, expiry_date)
    select name, variant, image_url, tag, '#{current_user.id}', purchase_date, quantity, expiry_date from houseware
    where user_id = '2' and id = '#{item_id}';"
    db_query(sql)
end

# def sort_list_by_name_tag(sql, params = [])
#     sql = "SELECT * from houseware WHERE user_id = '#{user_id}' order by LOWER($1), $2;"
#     db_query(sql)    
# end