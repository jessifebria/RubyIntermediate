require 'mysql2'
require './item.rb'
require './category.rb'

def create_db_client
    client = Mysql2::Client.new(
    :host => "127.0.0.1",
    :username => "root",
    :password => "jessi",
    :database => "ruby"
    )
    client
end

$client = create_db_client

def get_all_items
    rawData = $client.query("select items.id, items.name, items.price, categories.id AS category_id, categories.name AS category_name from items inner join categories on categories.id = items.category_id where category_id != 'DEL' order by items.id")
    items = Array.new
    rawData.each do | data |
        category = Category.new(data["category_id"], data["category_name"])
        item = Item.new(data["id"], data["name"], data["price"],category)
        items.push(item)
    end
    items
end

def get_all_categories
    raw = $client.query("select * from categories where id != 'DEL'")
    categories = Array.new
    raw.each do |data|
        category = Category.new(data["id"], data["name"])
        categories.push(category)
    end
    categories
end

def create_new_items(name,price,categoryid)
    $client.query("insert into items(name,price,category_id) values ('#{name}',#{price},'#{categoryid}')")
end

def create_new_category(id,name)
    $client.query("insert into categories values ('#{id}','#{name}')")
end


def count_item_exist(name)
    raw = $client.query("select count(*) from items where name= '#{name}' and category_id != 'DEL'")
    count = raw.each[0]["count(*)"]
    count
end

def count_item_exist_exceptid(id, name)
    raw = $client.query("select count(*) from items where name= '#{name}' and category_id != 'DEL' and id != #{id}")
    count = raw.each[0]["count(*)"]
    count
end

def count_category_exist(name)
    raw = $client.query("select count(*) from categories where name= '#{name}'")
    count = raw.each[0]["count(*)"]
    count
end

def delete_item(id)
    $client.query("UPDATE items SET category_id = 'DEL' where id = #{id}")
end

def update_item(id,name,price,categoryid)
    $client.query("UPDATE items SET name = '#{name}', price= #{price}, category_id = '#{categoryid}' where id = #{id}")
end

def get_item_byid(id)
    rawData = $client.query("select * from items where id = #{id}")
    data = rawData.each[0]
    category = Category.new(data["category_id"], data["category_name"])
    item = Item.new(data["id"], data["name"], data["price"],category)
    item
end

def get_category_byid(id)
    rawData = $client.query("select * from categories where id = '#{id}'")
    data = rawData.each[0]
    category = Category.new(data["id"], data["name"])
    category
end




items = get_all_items()
puts("LIST ITEM")
puts(items[0])

categories = get_all_categories()
puts("LIST CATEGORY")
puts(categories[0].id[0])

item = get_item_byid(9)
puts(item.id[0])

puts(categories.length)





