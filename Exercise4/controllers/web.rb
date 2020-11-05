require 'sinatra'
require_relative 'itemcontroller'
require_relative 'categorycontroller'
require_relative 'awscontroller'

# sets root as the parent-directory of the current file
set :root, File.join(File.dirname(__FILE__), '..')
# sets the view directory correctly
set :views, Proc.new { File.join(root, "views") } 


$ItemController = ItemController.new
$CategoryController = CategoryController.new
$AwsController = AwsController.new

get '/listfood' do
    $ItemController.listfood
end

get '/newfood' do
    $ItemController.newfood
end

post '/addfood' do
    $ItemController.addfood(params)
    redirect '/listfood'
end

get '/delete/:id' do
    $ItemController.delete_by_id(params)
    redirect '/listfood'
end

get '/edit/:id' do
    $ItemController.edit_by_id(params)
end

post '/edit/:id' do
    $AwsController.upload(params)
    $ItemController.action_edit_by_id(params)
    redirect '/listfood'
end

get '/show/:id' do
    $ItemController.show_by_id(params)
end

get '/newcategory' do
    $CategoryController.newcategory
end

post '/addcategory' do
    $CategoryController.action_newcategory(params)
    redirect '/newcategory'
end

get '/editcategory/:id' do
    $CategoryController.editcategory(params)
end

post '/editcategory/:id' do
    $CategoryController.action_editcategory(params)
    redirect "/editcategory/#{params["id"]}"
end

get '/deletecategory/:id' do
    $CategoryController.action_deletecategory(params)
    redirect '/newcategory'
end

