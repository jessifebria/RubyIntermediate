
require './gofood/db/db_connector'
require './gofood/models/category.rb'

$client = create_db_client

class Item
    attr_accessor :name, :price, :id, :categories
    def initialize(id, name, price, categories)
        @id= id
        @name = name
        @price = price
        @categories = categories
    end

    def save
        $client.query("insert into items(name,price) values ('#{name}',#{price})")
        if self.categories != nil
            categories = self.categories
            itemid = get_itemid_byname("#{name}")
            for category in categories do
                $client.query("insert into categorydetails(category_id, item_id) values ('#{category.id}','#{itemid}')")
            end
        end
    end

    def delete
        $client.query("DELETE from categorydetails where item_id = #{id}")
        $client.query("insert into categorydetails(category_id, item_id) values ('DEL','#{id}')")
    end

    def update(newname,newprice,newcategoryid)
        $client.query("UPDATE items SET name = '#{newname}', price= #{newprice} where id = #{id}")
        $client.query("DELETE from categorydetails where item_id = #{id}")
        categories = newcategoryid
        for category in categories do
            puts "insert into categorydetails(category_id, item_id) values ('#{category.id}','#{id}')"
            $client.query("insert into categorydetails(category_id, item_id) values ('#{category.id}','#{id}')")
        end
    end
end

def search_items(filter, key)
    puts "SELECT i.id FROM (items i JOIN categorydetails cd ON i.id = cd.item_id) 
    JOIN categories c ON cd.category_id = c.id
    WHERE #{filter} ( i.name LIKE '%#{key}%' or i.price LIKE '%#{key}%' OR i.id LIKE '%#{key}%' or c.name LIKE '%#{key}%' )
    order by i.id ASC"
    
    rawData = $client.query("SELECT i.id FROM (items i JOIN categorydetails cd ON i.id = cd.item_id) 
    JOIN categories c ON cd.category_id = c.id
    WHERE #{filter} ( i.name LIKE '%#{key}%' or i.price LIKE '%#{key}%' OR i.id LIKE '%#{key}%' or c.name LIKE '%#{key}%' )
    order by i.id ASC")
    items = Array.new
    rawData.each do | data |
        if  is_item_deleted?("#{data["id"]}")==false
            items.push(get_item_byid(data["id"]))
        end
    end
    return items
end

def is_item_deleted?(id)
    raw = $client.query("select count(*) from categorydetails where item_id = '#{id}' and category_id= 'DEL'")
    count = raw.each[0]["count(*)"]
    if count==1
        return true
    end
    false
end

def get_all_items
    rawData = $client.query("select id,name,price from items order by id ASC")
    items = Array.new
    rawData.each do | data |
        if  is_item_deleted?("#{data["id"]}")==false
            puts data["id"]
            items.push(get_item_byid(data["id"]))
        end
    end
    return items
end

def count_item_exist(name)
    raw = $client.query("select count(*) from (items join categorydetails on items.id = categorydetails.item_id ) where items.name= '#{name}' and categorydetails.category_id != 'DEL'")
    count = raw.each[0]["count(*)"]
    count
end

def count_item_exist_exceptid(id, name)
    raw = $client.query("select count(*) from (items join categorydetails on items.id = categorydetails.item_id ) where items.name= '#{name}' and categorydetails.category_id != 'DEL' and items.id !='#{id}'")
    count = raw.each[0]["count(*)"]
    count
end

def get_item_byid(id)
    rawData = $client.query("select * from items where id = '#{id}'")
    data = rawData.each[0]
    rawData2 = $client.query("select * from categorydetails where item_id = '#{data["id"]}' ")
    categories = Array.new
    rawData2.each do | c_data |
        category = get_category_byid(c_data["category_id"])
        categories.push(category)
    end
    item = Item.new(data["id"], data["name"], data["price"], categories)
    item
end

def get_itemid_byname(name)
    rawData = $client.query("select items.id from (items left join categorydetails on items.id = categorydetails.item_id ) where items.name= '#{name}' and (categorydetails.category_id IS NULL OR categorydetails.category_id !='DEL')")
    puts rawData
    data = rawData.each[0]
    puts data
    return data["id"]
end


def get_item_by_categoryid(id)
    rawData2 = $client.query("select * from categorydetails where category_id = '#{id}'")
    items = Array.new
    rawData2.each do | data |
        items.push(get_item_byid(data["item_id"]))
    end
    items
end



# puts get_item_byid(4).categories[0].name
# puts get_item_by_categoryid('F001')[0].name

# category = Array.new
# category.push(get_category_byid('F003'))
# category.push(get_category_byid('F005'))
# category.push(get_category_byid('F002'))
# items = Item.new(nil, 'Ayammmmlagi', '15000', category )
# items.save

# category2 = Array.new
# category2.push(get_category_byid('F001'))
# category2.push(get_category_byid('F002'))
# itemss = get_item_byid('13')
# itemss.delete

# puts get_item_by_categoryid('F003')

# puts get_all_categories
#  params = {"categoryid" =>['F004','F003', 'F002']}
# params = {}
# puts get_all_items_by_filter(params)

# puts is_item_deleted?("4")

# puts count_item_exist_exceptid(16, "Mango Juice")

# puts get_itemid_byname("Nasi Rawon")