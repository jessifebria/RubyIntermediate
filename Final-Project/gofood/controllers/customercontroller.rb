require_relative '../models/customer'

class CustomerController
    $message = ""
    $cart = 0
    $customers = Customer.get_all_customers

    def self.setcart(cart)
        $cart = cart
    end

    def self.listcustomers
        customers = $customers
        message = $message
        cart = $cart
        renderer = ERB.new(File.read("gofood/views/customers.erb"))
        renderer.result(binding)
    end

    def self.searchcustomers(params)
        $customers = Customer.get_customers_bysearch(params["keyword"])
    end

    def self.showcustomer(id)
        customer = Customer.get_customer_byid(id)
        listorder = customer.get_customer_order
        cart = $cart
        renderer = ERB.new(File.read("gofood/views/showcustomer.erb"))
        renderer.result(binding)
    end

    def self.editcustomer(id)
        cart = $cart
        customer = Customer.get_customer_byid(id)
        renderer = ERB.new(File.read("gofood/views/editcustomer.erb"))
        renderer.result(binding)
    end

    def self.action_editcustomer(params)
        id = params["id"]
        name = params["name"]
        phone = params["phone"]
        customer = Customer.get_customer_byid(id)
        $message = customer.update(name,phone)
    end

    def self.addcustomer
        cart = $cart
        renderer = ERB.new(File.read("gofood/views/addcustomer.erb"))
        renderer.result(binding)
    end

    def self.action_addcustomer(params)
        name = params["name"]
        phone = params["phone"]
        customer = Customer.new(nil,name,phone)
        $message = customer.save
    end

    def self.deletecustomer(id)
        customer = Customer.get_customer_byid(id)
        customer.delete
        $message = "Customer ID #{customer.id} berhasil di delete dari database"
    end


end