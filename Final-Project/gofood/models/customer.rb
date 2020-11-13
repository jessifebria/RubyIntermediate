require './gofood/db/db_connector'

$client = create_db_client

class Customer
    attr_accessor :id, :name, :phone, :status , :totalorder
    def initialize(id,name,phone,status=nil)
        @id = id
        @name = name
        @phone = phone
        @status = status
    end

    def validate_phone(phone_num)
        if phone_num.length < 12 or phone_num.length > 14 or phone_num[0..1]!="08"
            return false
        end
        return true
    end

    def save
        message=""
        if  validate_phone(phone)==false
            return "Nomor handphone harus diawali dengan 08, lebih dari 12 karakter dan kurang dari 14 karakter"
        end
        begin
            $client.query("insert into customers(name,phone,status) value('#{name}','#{phone}','active')")
            message = "Berhasil insert data customers nama #{name}, phone #{phone}"
        rescue => exception
            message = "Gagal Insert, sudah ada nomor handphone yang sama di database!"
        end
        message
    end

    def update(newname,newphone) 
        message=""
        if  validate_phone(newphone)==false
            return "Nomor handphone harus diawali dengan 08, lebih dari 12 karakter dan kurang dari 14 karakter"
        end
        begin
            $client.query("UPDATE customers SET name = '#{newname}', phone= '#{newphone}' where id = #{id}")
            message = "Berhasil update data customers ID #{id} menjadi #{newname}, phone #{newphone}"
        rescue => exception
            message = "Gagal Update, sudah ada nomor handphone yang sama di database! "
        end
        message
    end

    def delete
        $client.query("UPDATE customers SET status='nonactive' where id = #{id}")
    end

    def self.get_all_customers 
        rawData = $client.query("select * from customers where status='active'")
        customers = Array.new
        rawData.each do | data |
            customer= get_customer_byid(data["id"])
            customers.push(customer)
        end
        customers
    end

    def self.get_customer_byid(id)
        rawData = $client.query("select * from customers where id = '#{id}'")
        data = rawData.each[0]
        customer = Customer.new(data["id"], data["name"], data["phone"],data["status"])
        customer
    end

    def get_customer_order
        rawData = $client.query("SELECT o.id 'Order ID', concat(date_format(o.date,\"<br> %e-%m-%Y\"), time_format(o.date,\"%H:%i:%s WIB\")) 'Order Date', 
        concat('Rp. ', format(sum(od.pricenow*od.jumlah),2)) 'Total' , group_concat(concat(od.jumlah,' <a href=\"/show/',i.id,'\" class=\"a1\">', i.name,'</a>') SEPARATOR '<br>') 'Items Bought'
        from ((orders o inner join customers c on o.customer_id = c.id) 
        inner join orderdetails od on o.id =  od.order_id)
        inner join items i on od.item_id = i.id
        where c.id = #{id}
        group by o.id")
        data = rawData.each
        data
    end

    def get_customer_total_order
        total =0
        rawData = $client.query("SELECT sum(od.pricenow*od.jumlah) 'total'
        from ((orders o inner join customers c on o.customer_id = c.id) 
        inner join orderdetails od on o.id =  od.order_id)
        inner join items i on od.item_id = i.id
        where c.id = #{id}
        group by o.id")
        rawData.each do | data |
            total += data["total"]
        end
        total
    end

    def self.get_customers_bysearch(keyword)
        rawData = $client.query("SELECT  c.id, c.name, c.phone, concat('Rp. ', format(sum(od.pricenow*od.jumlah),2)) AS total 
        from ((orders o inner join customers c on o.customer_id = c.id) 
        inner join orderdetails od on o.id =  od.order_id)
        inner join items i on od.item_id = i.id
        where c.status = 'active'
        group by c.id
        having c.id LIKE '%#{keyword}%' or c.name LIKE '%#{keyword}%' or c.phone LIKE '%#{keyword}%' or total LIKE '%#{keyword}%' ")
        customers = Array.new
        rawData.each do | data |
            customer= get_customer_byid(data["id"])
            customers.push(customer)
        end
        customers
    end
end

# puts Customer.get_customers_bysearch('jessi')


# cust = Customer.new(nil,'CC','0891231127372')
# message = cust.save
# cust1 = Customer.new(6,'CC','0891231128372')
# puts cust1.update('aa','0891231127371')

# cust3 = Customer.get_customer_byid(2)
# puts cust3.get_customer_total_order
# puts cust3.name
# puts cust3.get_customer_order