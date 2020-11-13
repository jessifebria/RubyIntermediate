require './gofood/db/db_connector.rb'

$client = create_db_client

class Category
    attr_accessor :id, :name
    def initialize(id, name)
        @id= id
        @name = name
    end

    def save
        $client.query("insert into categories values ('#{@id}','#{@name}')")
    end

    def delete 
        $client.query("delete from categorydetails where category_id = '#{@id}'")
        $client.query("delete from categories where id = '#{@id}'")
    end

    def update(newname) 
        $client.query("UPDATE categories SET name = '#{newname}' where id = '#{@id}'")
    end

end

def get_all_categories
    raw = $client.query("select * from categories where id != 'DEL' order by convert(substring(id,4,6),SIGNED) ASC")
    categories = Array.new
    raw.each do |data|
        category = Category.new(data["id"], data["name"])
        categories.push(category)
    end
    categories
end

def get_all_categories_bysearch(keyword)
    raw = $client.query("select c.id, c.name , group_concat(' ',i.name) AS Items 
        from (categories c inner join categorydetails cd on c.id = cd.category_id) 
        inner join items i on i.id = cd.item_id
        where c.id != 'DEL'
        group by c.id
        HAVING c.id LIKE '%#{keyword}%' or c.name LIKE '%#{keyword}%' or Items LIKE '%#{keyword}%' 
        order by convert(substring(c.id,4,6),SIGNED) ASC;")
    categories = Array.new
    raw.each do |data|
        categories.push(get_category_byid(data["id"]))
    end
    categories
end

def count_category_exist(name)
    raw = $client.query("select count(*) from categories where name= '#{name}'")
    count = raw.each[0]["count(*)"]
    count
end

def count_category_exist_exceptid(id,name)
    raw = $client.query("select count(*) from categories where name= '#{name}' and id != '#{id}'")
    count = raw.each[0]["count(*)"]
    count
end

def get_category_byid(id)
    rawData = $client.query("select * from categories where id = '#{id}'")
    data = rawData.each[0]
    category = Category.new(data["id"], data["name"])
    category
end

def get_max_id
    raw = $client.query("select max(convert(substring(id,4,6),SIGNED)) from categories")
    max = raw.each[0]["max(convert(substring(id,4,6),SIGNED))"]
    max
end




# category2 = Category.new('COBA2', 'test')
# category2.save

# category = Category.new('COBA', 'test')
# # category.save
# # category.update("cobaajalagi")
# category.delete

# puts get_all_categories

# puts get_category_byid('F003').name

# puts get_all_categories_bysearch("fan")