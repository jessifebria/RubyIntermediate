
require './gofood/models/order'

class OrderController
    $cart = 0
    $listorder = Order.get_all_order[0..4]
    $dayparam = ""
    $monthparam = ""
    $yearparam =""
    $keyword = ""
    $dayarray = Array.new
    $montharray = Array.new
    $yeararray = Array.new
    $itemsorderperpage = 5
    $allorder = Order.get_all_order
    $active = "1"

    def self.setcart(cart)
        $cart = cart
    end

    def self.listorder 
        orderpage = $itemsorderperpage
        listorder = $listorder
        message = $message
        cart = $cart
        keyword = $keyword
        dayarray = $dayarray
        active = $active
        montharray = $montharray
        yeararray = $yeararray
        totalpage = ($allorder.length/$itemsorderperpage.to_f).ceil()
        renderer = ERB.new(File.read("gofood/views/order.erb"))
        renderer.result(binding)
    end
    
    def self.resetallorder
        $allorder = Order.get_all_order
        OrderController.getpage(1)
        puts "in reset order"
    end

    def self.searchorders(params,code)
        if code == 1
            $keyword = params["keyword"]
        else 
            temp = ""
            key = params.keys
            if key.include?("day")
                $dayarray = params["day"]
                $dayparam = 'IN (' + params["day"].join(',') +')'
            else
                $dayarray.clear
                $dayparam = ''
            end
            if key.include?("month")
                $montharray = params["month"]
                $monthparam = 'IN (' + params["month"].join(',') +')'
            else
                $montharray.clear
                $monthparam = ''
            end
            if key.include?("year")
                $yeararray = params["year"]
                $yearparam = 'IN (' + params["year"].join(',') +')'
            else
                $yeararray.clear
                $yearparam = ''
            end
            if key.include?("page")
                $itemsorderperpage = params["page"].to_i
            else
                $itemsorderperpage = 5
            end
        end
            puts key
            puts params
        $allorder = Order.get_all_order_bysearch($keyword, $dayparam, $monthparam, $yearparam)
        OrderController.getpage(1)
    end

    def self.getpage(id)
        start = $itemsorderperpage*(id.to_i-1)
        finish = start + $itemsorderperpage - 1
        $listorder = $allorder[start..finish]
        $active = id
        puts "ACTIVE PAGE #{id}"
        puts "ITEMS PER PAGE #{$itemsperpage}"
        puts "START #{start}"
        puts "FINISH #{finish}"
    end
end

# params = {"month"=>["13"], "year"=>["2020"]}
# params 
# OrderController.searchorders(params,2)

# c = []
# puts c.include?("a")

# params = {"keyword"=>"jessi"}
# puts OrderController.searchorders(params,1)
