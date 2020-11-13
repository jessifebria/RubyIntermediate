require_relative '../models/item'
require_relative '../models/category'
require_relative 'awscontroller'

class ItemController
    $message = ""
    $listimage = Hash.new
    for data in get_all_items do
        $listimage["#{data.id}"] = AwsController.getimage("#{data.id}")
    end
    $all_items = get_all_items
    $items = $all_items[0..4]
    $itemsperpage = 5
    $active = "1"
    $cart = 0

    def self.setcart(cart)
        $cart = cart
    end

    def self.listfood
        items = $items
        cart = $cart
        message = $message
        listimage = $listimage
        listcategories = Hash.new
        categories = get_all_categories
        totalpage = ($all_items.length/$itemsperpage.to_f).ceil()
        active = $active
        for data in items do
            temp = Array.new
            for value in data.categories do
                temp.push(value.name)
            end
            listcategories["#{data.id}"] = temp.join(", ")\
        end
        renderer = ERB.new(File.read("gofood/views/index.erb"))
        renderer.result(binding)
    end

    def self.filter(params)
        $all_items = get_all_items_by_filter(params)
        key= params.keys
        if key.include?("showitems")
            $itemsperpage = params["showitems"][-1]
            $itemsperpage = $itemsperpage.to_i
        end
    end

    def self.search(key)
        $all_items = search_items(key)
        puts $all_items
    end

    def self.getpage(id)
        start = $itemsperpage*(id.to_i-1)
        finish = start.to_i + $itemsperpage - 1
        $items = $all_items[start..finish]
        $active = id
        puts "ACTIVE PAGE #{id}"
        puts "ITEMS PER PAGE #{$itemsperpage}"
        puts "START #{start}"
        puts "FINISH #{finish}"
    end

    def self.newfood
        categories = get_all_categories
        cart = $cart
        renderer = ERB.new(File.read("gofood/views/newfood.erb"))
        renderer.result(binding)
    end

    def self.addfood(params)
        name = params['name']
        price = params['price']
        categoryid = params[:categoryid]
        puts "CATEGORY ID === #{categoryid}"
        categories = Array.new
        categoryname = Array.new
        for category in categoryid do
            categorycur= get_category_byid(category)
            categories.push(categorycur)
            categoryname.push(categorycur.name)
        end
        # validasi di model harusnya
        if price.to_i.to_s != price
            $message = "Menu gagal ditambahkan : Isi harga dengan angka bukan string!"
        elsif count_item_exist(name) == 0
            if price.to_i<=0
                $message = "Menu gagal ditambahkan : Isi harga dengan angka positif!"
            else
                item = Item.new(nil,name,price,categories)
                puts categories
                item.save
                id = get_itemid_byname(item.name)
                AwsController.uploadnew(id, params)
                $listimage["#{id}"] = AwsController.getimage("#{id}")
                $all_items = get_all_items
                totalpage = ($all_items.length/$itemsperpage.to_f).ceil()
                self.getpage(totalpage)
                $message = "Menu baru berhasil ditambahkan : #{name}, Harga #{price}, Category #{categoryname.join(', ')}"
            end
        else
            $message = "Menu gagal ditambahkan! Sudah ada nama menu #{name}! "
        end
    end

    def self.delete_by_id(params)
        id = params['id']
        item = get_item_byid(id)
        item.delete
        $all_items = get_all_items
        $message = "Berhasil delete #{item.name} dari database"
        AwsController.delete(id)
        $all_items = get_all_items
        self.getpage($active)
    end

    def self.edit_by_id(params)
        categories = get_all_categories
        id = params['id']
        item = get_item_byid(id)
        itemcategory = Array.new
        image = $listimage["#{id}"]
        cart = $cart
        for data in item.categories do
            itemcategory.push(data.id)
        end
        for data in categories do
            data_id = data.id
            if itemcategory.include?(data_id)
                curr_id = data_id[-1].to_i
                curr_id-=1
                categories[curr_id].id = "#{categories[curr_id].id} checked" 
            end
        end
        renderer = ERB.new(File.read("gofood/views/editfood.erb"))
        renderer.result(binding)
    end

    def self.action_edit_by_id(params)
        id = params['id']
        name = params['name']
        price = params['price']
        categoryid = params[:categoryid]
        categories = Array.new
        categoryname = Array.new
        for category in categoryid do
            categorycur= get_category_byid(category)
            categories.push(categorycur)
            categoryname.push(categorycur.name)
        end
        puts params
        item = get_item_byid(id)
        if params['reqdelete']=="1"
            AwsController.delete(id)
        end
        if price.to_i.to_s != price
            $message = "Menu gagal diupdate : Isi harga dengan angka bukan string!"
        elsif count_item_exist_exceptid(id,name) == 0 
            if price.to_i<=0
                $message = "Menu gagal ditambahkan : Isi harga dengan angka positif!"
            else
                item.update(name,price,categories)
                $all_items = get_all_items
                self.getpage($active)
                $listimage["#{id}"] = AwsController.getimage("#{id}")
                $message = "Menu id #{id} berhasil diupdate menjadi nama: #{name}, Harga #{price}, Category #{categoryname.join(', ')}"
            end
        else
            $message = "Menu gagal diupdate! Sudah ada nama menu lain dengan nama #{name}! "
        end
    end

    def self.show_by_id(params)
        id = params['id']
        item = get_item_byid(id)
        temp = Array.new
        cart = $cart
        image = AwsController.getimage(id)
        for value in item.categories do
            temp.push(value.name)
        end
        listcategories = temp.join(", ")
        renderer = ERB.new(File.read("gofood/views/showfood.erb"))
        renderer.result(binding)
    end

end
