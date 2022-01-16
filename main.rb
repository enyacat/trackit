require 'sinatra'
require 'sinatra/base'
require 'pg'
require 'bcrypt'

require_relative 'models/houseware.rb'
require_relative 'models/user.rb'

enable :sessions

before do
  @tags = get_tags()
end

def logged_in?()
  if session[:user_id]
    return true
  else
    return false
  end
end

def current_user() 
  sql = "SELECT * FROM users WHERE id = #{ session[:user_id] }"
  user = db_query(sql).first
  return OpenStruct.new(user)
end

class HelloWorld < Sinatra::Base
  get '/' do
    result = show_user_list(2)
    erb :index, locals: {
      items: result,
      user_id: 2,
    }
  end
end

get '/' do
  result = show_user_list(2)
  erb :index, locals: {
    items: result,
    user_id: 2,
  }
end

get '/items/new' do
  redirect '/login' unless logged_in?
  erb :new
end

get '/items/:tag' do
  erb(:index_by_category, locals: { 
    tag: params['tag'] 
  })

end

get '/id/:id' do
  item_id = params['id']
  item = db_query("SELECT * FROM houseware WHERE id = $1", [item_id]).first
  
  if item.class == NilClass
    erb :not_found
  else
    erb(:show, locals: { 
    item: item
    })
  end
end

post '/items' do
  redirect '/login' unless logged_in?
  create_item(
    params['name'],
    params['variant'],
    params['image_url'],
    params['tag'],
    current_user.id,
    params['purchase_date'],
    params['quantity'],
    params['expiry_date']
  )
  redirect "/"
end

get '/items/:id/edit' do
  redirect '/login' unless logged_in?
  sql = "SELECT * FROM houseware WHERE id = $1;"
  item = db_query(sql, [
    params['id']
  ]).first
  
  erb(:edit, locals:{
    item: item
  })
end

put '/items/:id' do
  update_item(
    params['name'],
    params['variant'],
    params['image_url'],
    params['tag'],
    params['purchase_date'],
    params['quantity'],
    params['expiry_date'],
    params['id']
  )
  redirect "/list/#{current_user.id}"
end

delete '/items/:id' do
  redirect '/login' unless logged_in?
  delete_item(params['id'])
  redirect request.referrer
end

# below is related to user registration and login
get '/users/new' do
  erb :register
end

post "/users" do
    create_user(params['email'], params['password'], 'STAFF')
    redirect '/login'
end

get '/login' do
  erb :login
end

post '/session' do
  email = params["email"]
  password = params["password"]
  conn = PG.connect(dbname: 'inventory')
  sql = "SELECT * FROM users WHERE email = '#{email}';"
  result = conn.exec(sql) 
  conn.close

  if result.count > 0 && BCrypt::Password.new(result[0]['password_digest']) == password
      session[:user_id] = result[0]['id']
      redirect '/'
  else
    erb :login
  end
end

delete "/session" do 
    session[:user_id] = nil
    redirect "/login"
end

# below is test part to let user create their own list

get '/list/sorting/ascending/:column' do
  redirect '/login' unless logged_in?
  query = params['column']
  column_names = ["name", "variant", "tag", "purchase_date", "quantity", "expiry_date"]
  if column_names.include? query
    sql = "SELECT * from houseware WHERE user_id = #{current_user.id} order by LOWER(CAST(#{query} AS VARCHAR)), LOWER(tag);"
    result = db_query(sql,[])
    erb(:customised_list, locals: {
    items: result,
    })
  else 
    erb :not_found
  end

end

get '/list/sorting/descending/:column' do
  redirect '/login' unless logged_in?
  query = params['column']
  column_names = ["name", "variant", "tag", "purchase_date", "quantity", "expiry_date"]
  if column_names.include? query
    sql = "SELECT * from houseware WHERE user_id = #{current_user.id} order by LOWER(CAST(#{query} AS VARCHAR)) DESC, LOWER(tag);"
    result = db_query(sql,[])
    erb(:customised_list, locals: {
    items: result,
    })
  else 
    erb :not_found
  end

end

get '/list/:user_id' do
  redirect '/login' unless logged_in?
  user_id = params['user_id']
  if user_id == current_user.id
    result = show_user_list(user_id)
    erb(:customised_list, locals: {
      items: result,
      user_id: user_id
    })
  else
    erb :not_found
  end
end

post '/list/item/:id' do
  item_id = params['id']
  add_item_to_list(item_id)
  redirect request.referrer
end

