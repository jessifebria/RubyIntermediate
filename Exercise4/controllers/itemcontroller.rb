require_relative '../models/item'
require_relative '../models/category'
require_relative 'awscontroller'

# # sets root as the parent-directory of the current file
# set :root, File.join(File.dirname(__FILE__), '..')
# # sets the view directory correctly
# set :views, Proc.new { File.join(root, "views") } 

class ItemController
    $message = ""
    
    
    def listfood
        items = get_all_items
        message = $message
        items = get_all_items
        listimage = Hash.new
        listcategories = Hash.new
        for data in items do
            temp = Array.new
            for value in data.categories do
                temp.push(value.name)
            end
            listcategories["#{data.id}"] = temp.join(", ")
            listimage["#{data.id}"] = AwsController.getimage("#{data.id}",1)
        end
        renderer = ERB.new(File.read("gofood/views/index.erb"))
        renderer.result(binding)
    end

    def newfood
        categories = get_all_categories
        renderer = ERB.new(File.read("gofood/views/newfood.erb"))
        renderer.result(binding)
    end

    def addfood(params)
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
        if price.to_i.to_s != price
            $message = "Menu gagal ditambahkan : Isi harga dengan angka bukan string!"
        elsif count_item_exist(name) == 0
            if price.to_i<=0
                $message = "Menu gagal ditambahkan : Isi harga dengan angka positif!"
            else
                item = Item.new(nil,name,price,categories)
                item.save
                AwsController.uploadnew(get_itemid_byname(item.name), params)
                $message = "Menu baru berhasil ditambahkan : #{name}, Harga #{price}, Category #{categoryname.join(', ')}"
            end
        else
            $message = "Menu gagal ditambahkan! Sudah ada nama menu #{name}! "
        end
    end

    def delete_by_id(params)
        id = params['id']
        item = get_item_byid(id)
        item.delete
        $message = "Berhasil delete #{item.name} dari database"
        AwsController.delete(id)
    end

    def edit_by_id(params)
        categories = get_all_categories
        id = params['id']
        item = get_item_byid(id)
        itemcategory = Array.new
        image = AwsController.getimage(id,0)
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

    def action_edit_by_id(params)
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
                $message = "Menu id #{id} berhasil diupdate menjadi nama: #{name}, Harga #{price}, Category #{categoryname.join(', ')}"
            end
        else
            $message = "Menu gagal diupdate! Sudah ada nama menu lain dengan nama #{name}! "
        end
        
    end

    def show_by_id(params)
        id = params['id']
        item = get_item_byid(id)
        temp = Array.new
        image = AwsController.getimage(id,0)
        for value in item.categories do
            temp.push(value.name)
        end
        listcategories = temp.join(", ")
        renderer = ERB.new(File.read("gofood/views/showfood.erb"))
        renderer.result(binding)
    end

end
