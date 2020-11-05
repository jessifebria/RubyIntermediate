require_relative '../models/category'
require_relative '../models/item'

# # sets root as the parent-directory of the current file
# set :root, File.join(File.dirname(__FILE__), '..')
# # sets the view directory correctly
# set :views, Proc.new { File.join(root, "views") } 


class CategoryController
    $messagecategory = ""
    $messageedit = ""
    $messagedelete = ""
    $delete =0

    def newcategory
        categories = get_all_categories 
        messagecategory = $messagecategory
        messagedelete = $messagedelete
        edit = 0
        delete = $delete
        listitems = Hash.new
        for value in categories do
            items = get_item_by_categoryid(value.id)
            temp = Array.new
            for data in items do
                temp.push(data.name)
            end
            listitems["#{value.id}"] = temp.join(", ")
        end
        renderer = ERB.new(File.read("gofood/views/newcategory.erb"))
        renderer.result(binding)
    end

    def action_newcategory(params)
        name = params['name']
        categories = get_all_categories 
        if count_category_exist(name) == 0
            new_id = get_max_id.to_i + 1
            new_id2 = 'F00' + new_id.to_s 
            category = Category.new(new_id2, name)
            category.save
            $messagecategory = "Category baru berhasil ditambahkan : #{name}, ID #{new_id2}"
        else
            $messagecategory = "Category gagal ditambahkan! Sudah ada nama Category #{name}"
        end
    end

    def editcategory(params)
        id = params['id']
        categories = get_all_categories 
        category = get_category_byid(id)
        temp_name = category.name
        edit= 1
        delete = 0
        judul = "Edit Category ID #{category.id}"
        messageedit = $messageedit
        listitems = Hash.new
        for value in categories do
            items = get_item_by_categoryid(value.id)
            temp = Array.new
            for data in items do
                temp.push(data.name)
            end
            listitems["#{value.id}"] = temp.join(", ")
        end
        renderer = ERB.new(File.read("gofood/views/newcategory.erb"))
        renderer.result(binding)
    end

    def action_editcategory(params)
        id = params['id']
        name = params['name']
        category = get_category_byid(id)
        if count_category_exist_exceptid(id,name) == 0
            category.update(name)
            $messageedit = "Category ID #{id} berhasil diupdate menjadi Nama : #{name}"
        else
            $messageedit = "Category gagal diupdate! Sudah ada nama Category #{name}"
        end
    end

    def action_deletecategory(params)
        id = params["id"]
        category = get_category_byid(id)
        $messagedelete = "Berhasil delete Category ID #{category.id}, Nama #{category.name}"
        category.delete
        $delete = 1
    end

end
