class Item
    attr_accessor :name, :price, :id, :category
    def initialize(id, name, price, category)
        @id= id,
        @name = name,
        @price = price,
        @category = category
    end
end