CREATE TABLE categories (
id VARCHAR(5) NOT NULL, 
name VARCHAR(50) NOT NULL,
PRIMARY KEY (id)
);

CREATE TABLE customers (
id INT NOT NULL AUTO_INCREMENT, 
name VARCHAR(50) NOT NULL, 
phone VARCHAR(15) NOT NULL,
UNIQUE (phone),
PRIMARY KEY (id)
);

CREATE TABLE orders (
id INT NOT NULL AUTO_INCREMENT, 
date DATE NOT NULL, 
customer_id INT NOT NULL,
FOREIGN KEY (customer_id) REFERENCES customers(id),
PRIMARY KEY (id)
);

CREATE TABLE items (
id INT NOT NULL AUTO_INCREMENT, 
name VARCHAR(50) NOT NULL, 
price INT DEFAULT 0, 
category_id VARCHAR(5) NOT NULL,
FOREIGN KEY (category_id) REFERENCES categories(id),
PRIMARY KEY (id)
);

CREATE TABLE orderdetails (
id INT NOT NULL AUTO_INCREMENT,
order_id INT NOT NULL, 
item_id INT NOT NULL,
jumlah INT NOT NULL,
pricenow INT NOT NULL,
FOREIGN KEY (order_id) REFERENCES orders(id),
FOREIGN KEY (item_id) REFERENCES items(id),
PRIMARY KEY(id)
);


INSERT INTO categories  VALUES
('F001', 'Main Dish'),
('F002', 'Side Dish'),
('F003', 'Juice'),
('F004', 'Soft Drink'),
('F005','Dessert');

INSERT INTO items (name, price, category_id) VALUES
('Nasi Goreng Gila', 18000, 'F001'),
('Sop Buntut', 35000, 'F001'),
('French Fries', 20000, 'F002'),
('Mango Juice', 15000, 'F003'),
('Orange Juice', 12000, 'F003'),
('Coca Cola', 8000, 'F004'),
('Fanta', 10000, 'F004'),
('Vanilla DessertBox', 45000, 'F005');

INSERT INTO customers (name, phone) VALUES
('Jessi Febria', '089690043454'),
('Raisa Andriana', '089134534345'),
('Boy William', '081234345341'),
('Stephen Hawking', '089766620123'),
('Maudy Ayunda', '083455500231');

INSERT INTO orders(date, customer_id)  VALUES
('2020-10-21', '1'),
('2020-10-21', '2'),
('2020-10-22', '2'),
('2020-10-22', '4'),
('2020-10-22', '5');

INSERT INTO orderdetails(order_id,item_id,jumlah,pricenow) VALUES
(1, 1, 1, 18000),
(1, 8, 2, 45000),
(1, 2, 2, 35000),
(2, 7, 1, 10000),
(2, 3, 1, 20000),
(3, 6, 1, 8000),
(3, 4, 3, 15000),
(3, 5, 1, 12000),
(4, 1, 1, 18000),
(4, 2, 1, 35000),
(4, 3, 2, 20000),
(5, 4, 2, 15000),
(5, 5, 1, 12000),
(5, 6, 2, 8000),
(5, 7, 3, 10000);

SELECT o.id 'Order ID', date_format(o.date,"%W %M %e %Y") 'Order Date', c.name 'Customer Name', 
c.phone 'Customer Phone', concat('Rp. ', format(sum(od.pricenow*od.jumlah),2)) 'Total' , group_concat(' ', i.name) 'Items Bought'
from ((orders o inner join customers c on o.customer_id = c.id) 
inner join orderdetails od on o.id =  od.order_id)
inner join items i on od.item_id = i.id
group by o.id;
