require 'sinatra'
require './db_connector'

$message = ""

get '/listfood' do
    items = get_all_items
    pesan = $message
    erb :index, locals: {
    items: items,
    message: pesan 
    }
end

get '/newfood' do
    categories = get_all_categories
    erb :newfood, locals:{
        categories: categories
    }
end

post '/addfood' do
    name = params['name']
    price = params['price']
    categoryid = params['categoryid']
    category = get_category_byid(categoryid)
    if price.to_i.to_s != price
        $message = "Menu gagal ditambahkan : Isi harga dengan angka bukan string!"
    elsif count_item_exist(name) == 0
        if price.to_i<=0
            $message = "Menu gagal ditambahkan : Isi harga dengan angka positif!"
        else
            create_new_items(name,price,categoryid)
            $message = "Menu baru berhasil ditambahkan : #{name}, Harga #{price}, Category #{category.name}"
        end
        
    else
        $message = "Menu gagal ditambahkan! Sudah ada nama menu #{name}! "
    end
    redirect '/listfood'
end

get '/delete/:id' do
    id = params['id']
    delete_item(id)
    $message = "Berhasil delete item id #{id} dari database"
    redirect '/listfood'
end

get '/edit/:id' do
    categories = get_all_categories
    id = params['id']
    item = get_item_byid(id)
    categoryid = item.category.id[0][-1].to_i 
    categoryid-=1
    categories[categoryid].id[0] = "#{categories[categoryid].id[0]} selected"
    erb :editfood, locals:{
        categories: categories,
        item: item
    }
end

post '/edit/:id' do
    id = params['id']
    name = params['name']
    price = params['price']
    categoryid = params['categoryid']
    category = get_category_byid(categoryid)
    puts("-----------------------")
    puts(price)
    puts (price.to_i)
    if price.to_i.to_s != price
        $message = "Menu gagal diupdate : Isi harga dengan angka bukan string!"
    elsif count_item_exist_exceptid(id,name) == 0 
        if price.to_i<=0
            $message = "Menu gagal ditambahkan : Isi harga dengan angka positif!"
        else
            update_item(id,name,price,categoryid)
            $message = "Menu id #{id} berhasil diupdate menjadi nama: #{name}, Harga #{price}, Category #{category.name}"
        end
    else
        $message = "Menu gagal diupdate! Sudah ada nama menu lain dengan nama #{name}! "
    end
    redirect '/listfood'
end

get '/show/:id' do
    id = params['id']
    item = get_item_byid(id)
    erb :showfood, locals:{
        item: item
    }
end

get '/newcategory' do
    categories = get_all_categories 
    erb :newcategory, locals: {
        categories: categories,
        messagecategory: $messagecategory 
        }
end

$messagecategory = ""

post '/addcategory' do
    name = params['name']
    categories = get_all_categories 
    if count_category_exist(name) == 0
        categories_length = categories.length + 1
        new_id = "F00#{categories_length}"
        create_new_category(new_id,name)
        $messagecategory = "Category baru berhasil ditambahkan : #{name}, ID #{new_id}"
    else
        $messagecategory = "Category gagal ditambahkan! Sudah ada nama Category #{name}"
    end
    redirect '/newcategory'
end