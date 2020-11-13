require 'sinatra'
require_relative '../gofood/controllers/itemcontroller'
require_relative '../gofood/controllers/categorycontroller'
require_relative '../gofood/controllers/customercontroller'
require_relative '../gofood/controllers/cartcontroller'
require_relative '../gofood/controllers/ordercontroller'
require_relative '../gofood/controllers/awscontroller'

# MENUS
get '/menus' do
    ItemController.listfood
end

post '/filter' do
    ItemController.filter(params)
    ItemController.getpage(1)
    redirect '/menus'
end

get '/newfood' do
    ItemController.newfood
end

post '/getpage/:id' do
    ItemController.getpage(params["id"])
    redirect '/menus'
end

post '/search' do
    ItemController.search(params["keyword"])
    ItemController.getpage(1)
    redirect '/menus'
end

post '/addfood' do
    ItemController.addfood(params)
    redirect '/menus'
end

get '/delete/:id' do
    ItemController.delete_by_id(params)
    redirect '/menus'
end

get '/edit/:id' do
    ItemController.edit_by_id(params)
end

post '/edit/:id' do
    AwsController.upload(params)
    ItemController.action_edit_by_id(params)
    redirect '/menus'
end

get '/show/:id' do
    ItemController.show_by_id(params)
end

# CATEGORIES
get '/categories' do
    CategoryController.newcategory
end

post '/searchcategories' do
    CategoryController.searchcategories(params)
    redirect '/categories'
end

post '/addcategory' do
    CategoryController.action_newcategory(params)
    redirect '/categories'
end

get '/editcategory/:id' do
    CategoryController.editcategory(params)
end

post '/editcategory/:id' do
    CategoryController.action_editcategory(params)
    redirect "/editcategory/#{params["id"]}"
end

get '/deletecategory/:id' do
    CategoryController.action_deletecategory(params)
    redirect '/categories'
end

# CUSTOMERS

get '/customers' do
    CustomerController.listcustomers
end

post '/searchcustomers' do
    CustomerController.searchcustomers(params)
    redirect '/customers'
end

get '/showcustomer/:id' do
    CustomerController.showcustomer(params["id"])
end

get '/editcustomer/:id' do
    CustomerController.editcustomer(params["id"])
end

post '/editcustomer/:id' do
    CustomerController.action_editcustomer(params)
    redirect '/customers'
end

get '/newcustomer' do
    CustomerController.addcustomer
end

post '/addcustomer' do
    CustomerController.action_addcustomer(params)
    redirect '/customers'
end

get '/deletecustomer/:id' do
    CustomerController.deletecustomer(params["id"])
    redirect '/customers'
end

# ORDERS

get '/orders' do
    OrderController.listorder
end

post '/searchorders' do
    OrderController.searchorders(params,1)
    redirect '/orders'
end

post '/filterorders' do
    OrderController.searchorders(params,2)
    redirect '/orders'
end

post '/getorderpage/:id' do
    OrderController.getpage(params["id"])
    redirect '/orders'
end

# CART

get '/cart' do
    CartController.showcart
end

get '/addcart/:id' do
    CartController.addcart(params["id"])
    redirect '/menus'
end

get '/deletecart/:id' do
    CartController.deletecart(params["id"])
    redirect '/cart'
end

get '/deleteorder' do
    CartController.deleteorder
    redirect '/cart'
end

get '/addquantity/:id' do
    CartController.addquantity(params["id"])
    redirect '/cart'
end

get '/minquantity/:id' do
    CartController.minquantity(params["id"])
    redirect '/cart'
end

post '/addorder' do
    CartController.addorder(params)
    redirect '/cart'
end