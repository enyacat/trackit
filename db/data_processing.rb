require 'json'
file = File.read('houseware.json')
data_hash=JSON.parse(file)
require_relative "../models/houseware.rb"



# conn = PG.connect(dbname: 'inventory')
data_hash.each {|key, value|
    i = 0
    while i < value.length
        name = key
        if value[i]['variant'] == nil
            variant = 0
        else
            variant = value[i]['variant']
        end
        image_url = value[i]['image_uri']
        if value[i]['tag'] == nil
            tag = 0
        else
            tag = value[i]['tag']
        end
        user_id = "2"
        purchase_date = '2022-01-01'
        quantity = 1
        expiry_date = '9999-01-01'
        create_item(name, variant, image_url, tag, user_id, purchase_date, quantity, expiry_date)
        i += 1
    end
}

p "done"
# p objects.buy-price
# p objects["buy-price"]


