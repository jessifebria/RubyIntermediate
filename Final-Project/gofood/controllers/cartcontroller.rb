
require './gofood/models/order'
require './gofood/models/customer'
require './gofood/controllers/itemcontroller'
require './gofood/controllers/categorycontroller'
require './gofood/controllers/customercontroller'
require './gofood/controllers/ordercontroller'

class CartController

    $cartlist = []
    $message = ""

    def self.showcart 
        cart = $cartlist
        message = $message
        customers = Customer.get_all_customers
        puts "#{$cartlist}"
        CartController.setcartlength($cartlist.length)
        renderer = ERB.new(File.read("gofood/views/cart.erb"))
        renderer.result(binding)
    end

    def self.addcart(itemid)
        cart_listid = Array.new($cartlist.length()) {|i| $cartlist[i].item.id }
        if cart_listid.include?(itemid.to_i)
            index = cart_listid.find_index(itemid.to_i)
            CartController.addquantity(index)
            $message = "Quantity #{$cartlist[index].item.name} diubah menjadi #{$cartlist[index].quantity}"
            puts "Quantity #{$cartlist[index].item.name} diubah menjadi #{$cartlist[index].quantity}"
        else
            item = get_item_byid(itemid)
            $cartlist.push(Order.new(item,1))
            $message = "#{item.name} berhasil ditambah ke dalam Cart"
            puts "#{item.name} berhasil ditambah ke dalam Cart"
            CartController.setcartlength($cartlist.length)
            
        end
    end

    def self.setcartlength(length)
        CategoryController.setcart(length)
        ItemController.setcart(length)
        CustomerController.setcart(length)
        OrderController.setcart(length)
    end
    
    def self.deletecart(index)
        $message = "#{$cartlist[index.to_i].item.name} berhasil dihapus dari Cart"
        CartController.setcartlength($cartlist.length)
        $cartlist.delete_at(index.to_i)
    end

    def self.addorder(params)
        customerid = params["customerid"]
        if  $cartlist.length==0
            return $message = "Minimal 1 item di cart untuk bisa submit order!"
        end
        idorder = Order.saveorder($cartlist, customerid)
        CartController.setcartlength(0)
        CartController.deleteorder
        $message = "Berhasil menambahkan order baru, ID ORDER = #{idorder} <b4> Mohon cek di tab Orders untuk melihat detailnya"
        OrderController.resetallorder
    end

    def self.deleteorder
        $cartlist.clear
        CartController.setcartlength(0)
        $message = "Semua menu di cart berhasil dihapus"
    end

    def self.addquantity(index)
        index = index.to_i
        $cartlist[index].quantity +=1
        $message = "Quantity #{$cartlist[index].item.name} diubah menjadi #{$cartlist[index].quantity}"
        puts "Quantity #{$cartlist[index].item.name} diubah menjadi #{$cartlist[index].quantity}"
    end

    def self.minquantity(index)
        index = index.to_i
        $cartlist[index].quantity = $cartlist[index].quantity-1
        if $cartlist[index].quantity == 0 
            CartController.deletecart(index.to_s)
        else
            $message = "Quantity #{$cartlist[index].item.name} diubah menjadi #{$cartlist[index].quantity}"
        end
    end
end

# CartController.addcart('4')
# CartController.addcart('4')
# CartController.addquantity('0')
# CartController.minquantity('0')
# puts "---"
# CartController.test
# CartController.setcartlength