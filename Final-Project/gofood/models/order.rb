
require './gofood/db/db_connector'
require './gofood/models/item'
require 'date'

class Order
    $client = create_db_client

    attr_accessor :item, :quantity
    def initialize(item,quantity)
        @item = item
        @quantity = quantity
    end
        
    def self.saveorder(cartlist, customerid)
        date = DateTime.now.strftime("%Y-%m-%d %H:%M:%S")
        $client.query("INSERT INTO orders(date,customer_id) VALUES('#{date}',#{customerid})")
        lastorderid = Order.getlastorder
        for detail in cartlist do
            $client.query("INSERT INTO orderdetails(order_id,item_id,jumlah,pricenow) VALUES(#{lastorderid},#{detail.item.id}, #{detail.quantity}, #{detail.item.price})")
        end    
        return lastorderid
    end

    def self.getlastorder
        raw = $client.query("SELECT id FROM ruby.orders order by id desc limit 1")
        data =raw.each[0]["id"]
        data
    end

    def self.get_all_order
        rawData = $client.query("SELECT o.id 'Order ID', 
        concat(date_format(o.date,\"%e-%m-%Y\"), time_format(o.date,\" %H:%i:%s WIB\")) 'Order Date',
        concat('<a href=\"/showcustomer/',c.id,'\">',c.name,'<br> (ID - ',c.id,') </a>') 'Customer',
        concat('Rp. ', format(sum(i.price*od.jumlah),2)) 'Total' ,
        group_concat(concat(od.jumlah, ' <a href=\"/show/',i.id,'\" class=\"a1\">', i.name,'</a> &#10153; ', od.jumlah, ' * ', od.pricenow, ' = ', od.pricenow*od.jumlah ,'<br>' ) SEPARATOR ' ') 'Items Bought'
        from ((orders o inner join customers c on o.customer_id = c.id) 
        inner join orderdetails od on o.id =  od.order_id)
        inner join items i on od.item_id = i.id
        group by o.id;")
        data = rawData.each
        data
    end

    def self.get_all_order_bysearch(keyword, day, month, year)
        puts "#{keyword} , #{day}, #{month}, #{year}"
        puts "SELECT o.id,
        concat(date_format(o.date,\"%e-%m-%Y\"), time_format(o.date,\" %H:%i:%s WIB\")) AS Orderr, 
        concat(c.name,'(ID - ',c.id,')') AS Customer,
        concat('Rp. ', format(sum(i.price*od.jumlah),2)) AS Total, 
        group_concat(concat(od.jumlah,' ',  i.name,' ' ,od.jumlah,' * ', od.pricenow, ' = ', od.pricenow*od.jumlah) SEPARATOR ' ') AS items
        from ((orders o inner join customers c on o.customer_id = c.id) 
        inner join orderdetails od on o.id =  od.order_id)
        inner join items i on od.item_id = i.id
        where day(o.date) #{day} and month(o.date) #{month} and year(o.date) #{year}
        group by o.id
        HAVING o.id LIKE '%#{keyword}%' or Orderr LIKE '%#{keyword}%' or Customer LIKE '%#{keyword}%' or Total LIKE '%#{keyword}%' or items LIKE '%#{keyword}%'"
        
        rawData = $client.query("SELECT o.id,
        concat(date_format(o.date,\"%e-%m-%Y\"), time_format(o.date,\" %H:%i:%s WIB\")) AS Orderr, 
        concat(c.name,'(ID - ',c.id,')') AS Customer,
        concat('Rp. ', format(sum(i.price*od.jumlah),2)) AS Total, 
        group_concat(concat(od.jumlah,' ',  i.name,' ' ,od.jumlah,' * ', od.pricenow, ' = ', od.pricenow*od.jumlah) SEPARATOR ' ') AS items
        from ((orders o inner join customers c on o.customer_id = c.id) 
        inner join orderdetails od on o.id =  od.order_id)
        inner join items i on od.item_id = i.id
        where day(o.date) #{day} and month(o.date) #{month} and year(o.date) #{year}
        group by o.id
        HAVING o.id LIKE '%#{keyword}%' or Orderr LIKE '%#{keyword}%' or Customer LIKE '%#{keyword}%' or Total LIKE '%#{keyword}%' or items LIKE '%#{keyword}%'")
        data = rawData.each
        id_list = Array.new(data.length()) {|i| data[i]["id"] } 
        puts id_list
        if id_list.length>0
            rawData2 = $client.query("SELECT o.id 'Order ID', 
            concat(date_format(o.date,\"%e-%m-%Y\"), time_format(o.date,\" %H:%i:%s WIB\")) 'Order Date',
            concat('<a href=\"/showcustomer/',c.id,'\">',c.name,'<br> (ID - ',c.id,') </a>') 'Customer',
            concat('Rp. ', format(sum(i.price*od.jumlah),2)) 'Total' ,
            group_concat(concat(od.jumlah, ' <a href=\"/show/',i.id,'\" class=\"a1\">', i.name,'</a> &#10153; ', od.jumlah, ' * ', od.pricenow, ' = ', od.pricenow*od.jumlah ,'<br>' ) SEPARATOR ' ') 'Items Bought'
            from ((orders o inner join customers c on o.customer_id = c.id) 
            inner join orderdetails od on o.id =  od.order_id)
            inner join items i on od.item_id = i.id
            where o.id in (#{id_list.join(',')})
            group by o.id;")
            result = rawData2.each
            result
        end
    end
end

# order = Order.new(get_item_byid(4),1)
# order.quantity = 2

# puts Order.get_all_order
# puts "==="