SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS=0;
DROP DATABASE IF EXISTS cobuy;
CREATE DATABASE cobuy CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE cobuy;

CREATE TABLE users (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,username VARCHAR(50) NOT NULL UNIQUE,email VARCHAR(160) NOT NULL UNIQUE,phone VARCHAR(30) NOT NULL UNIQUE,password_hash VARCHAR(255) NOT NULL,city VARCHAR(80),district VARCHAR(80),bio VARCHAR(500),avatar VARCHAR(255),trust_score TINYINT UNSIGNED NOT NULL DEFAULT 70,role ENUM('user','seller','admin') NOT NULL DEFAULT 'user',status ENUM('active','suspended','deleted') NOT NULL DEFAULT 'active',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE categories (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,name VARCHAR(100) NOT NULL,slug VARCHAR(110) NOT NULL UNIQUE,icon VARCHAR(20),sort_order INT DEFAULT 0,status ENUM('active','passive') DEFAULT 'active') ENGINE=InnoDB;
CREATE TABLE products (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,category_id INT UNSIGNED NOT NULL,brand VARCHAR(100),name VARCHAR(180) NOT NULL,model VARCHAR(120),variant VARCHAR(120),barcode VARCHAR(80),market_price DECIMAL(12,2) NOT NULL DEFAULT 0,image VARCHAR(255),description TEXT,specifications JSON,status ENUM('active','passive') DEFAULT 'active',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(category_id) REFERENCES categories(id)) ENGINE=InnoDB;
CREATE TABLE sellers (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,user_id INT UNSIGNED NOT NULL UNIQUE,company_name VARCHAR(180) NOT NULL,tax_number VARCHAR(30) NOT NULL,address TEXT,website VARCHAR(255),verification_status ENUM('pending','verified','rejected') DEFAULT 'pending',seller_score TINYINT UNSIGNED DEFAULT 0,status ENUM('active','suspended') DEFAULT 'active',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE group_carts (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,creator_id INT UNSIGNED NOT NULL,product_id INT UNSIGNED NOT NULL,title VARCHAR(220) NOT NULL,city VARCHAR(80),scope ENUM('national','local') DEFAULT 'national',target_quantity INT UNSIGNED NOT NULL,minimum_discount DECIMAL(5,2) DEFAULT 0,expected_max_price DECIMAL(12,2) DEFAULT 0,starts_at DATETIME NOT NULL,ends_at DATETIME NOT NULL,status ENUM('draft','active','offer','completed','cancelled','expired') DEFAULT 'active',description TEXT,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(creator_id) REFERENCES users(id),FOREIGN KEY(product_id) REFERENCES products(id),INDEX(status,ends_at)) ENGINE=InnoDB;
CREATE TABLE cart_participants (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,cart_id INT UNSIGNED NOT NULL,user_id INT UNSIGNED NOT NULL,participation_type ENUM('interested','conditional','committed') DEFAULT 'conditional',maximum_price DECIMAL(12,2) DEFAULT 0,quantity INT UNSIGNED DEFAULT 1,payment_verified TINYINT(1) DEFAULT 0,status ENUM('active','left','converted') DEFAULT 'active',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,UNIQUE KEY uq_cart_user(cart_id,user_id),FOREIGN KEY(cart_id) REFERENCES group_carts(id) ON DELETE CASCADE,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE seller_offers (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,cart_id INT UNSIGNED NOT NULL,seller_id INT UNSIGNED NOT NULL,unit_price DECIMAL(12,2) NOT NULL,minimum_quantity INT UNSIGNED NOT NULL,maximum_quantity INT UNSIGNED NOT NULL,shipping_cost DECIMAL(12,2) DEFAULT 0,delivery_days INT DEFAULT 3,warranty_type VARCHAR(160),installment_info VARCHAR(160),gift_info VARCHAR(255),expires_at DATETIME,status ENUM('active','selected','expired','withdrawn') DEFAULT 'active',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(cart_id) REFERENCES group_carts(id) ON DELETE CASCADE,FOREIGN KEY(seller_id) REFERENCES sellers(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE offer_tiers (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,offer_id INT UNSIGNED NOT NULL,minimum_quantity INT UNSIGNED NOT NULL,unit_price DECIMAL(12,2) NOT NULL,FOREIGN KEY(offer_id) REFERENCES seller_offers(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE cart_votes (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,cart_id INT UNSIGNED NOT NULL,offer_id INT UNSIGNED NOT NULL,user_id INT UNSIGNED NOT NULL,vote TINYINT NOT NULL DEFAULT 1,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,UNIQUE KEY uq_cart_vote(cart_id,user_id),FOREIGN KEY(cart_id) REFERENCES group_carts(id) ON DELETE CASCADE,FOREIGN KEY(offer_id) REFERENCES seller_offers(id) ON DELETE CASCADE,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE orders (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,user_id INT UNSIGNED NOT NULL,cart_id INT UNSIGNED NOT NULL,offer_id INT UNSIGNED NOT NULL,seller_id INT UNSIGNED NOT NULL,quantity INT UNSIGNED DEFAULT 1,unit_price DECIMAL(12,2) NOT NULL,shipping_cost DECIMAL(12,2) DEFAULT 0,total_amount DECIMAL(12,2) NOT NULL,status ENUM('pending','paid','preparing','shipped','delivered','cancelled','refunded') DEFAULT 'pending',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(user_id) REFERENCES users(id),FOREIGN KEY(cart_id) REFERENCES group_carts(id),FOREIGN KEY(offer_id) REFERENCES seller_offers(id),FOREIGN KEY(seller_id) REFERENCES sellers(id)) ENGINE=InnoDB;
CREATE TABLE payments (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,order_id INT UNSIGNED NOT NULL,provider_reference VARCHAR(120),amount DECIMAL(12,2) NOT NULL,payment_status VARCHAR(40),paid_at DATETIME,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE shipments (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,order_id INT UNSIGNED NOT NULL,cargo_company VARCHAR(100),tracking_number VARCHAR(100),shipped_at DATETIME,delivered_at DATETIME,status VARCHAR(40),FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE returns (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,order_id INT UNSIGNED NOT NULL,reason TEXT,status VARCHAR(40) DEFAULT 'open',created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,completed_at DATETIME,FOREIGN KEY(order_id) REFERENCES orders(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE reviews (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,order_id INT UNSIGNED NOT NULL,reviewer_id INT UNSIGNED NOT NULL,seller_id INT UNSIGNED NOT NULL,rating TINYINT UNSIGNED NOT NULL,comment TEXT,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(order_id) REFERENCES orders(id),FOREIGN KEY(reviewer_id) REFERENCES users(id),FOREIGN KEY(seller_id) REFERENCES sellers(id)) ENGINE=InnoDB;
CREATE TABLE price_history (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,product_id INT UNSIGNED NOT NULL,seller_id INT UNSIGNED NULL,price DECIMAL(12,2) NOT NULL,recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(product_id) REFERENCES products(id),FOREIGN KEY(seller_id) REFERENCES sellers(id) ON DELETE SET NULL) ENGINE=InnoDB;
CREATE TABLE reports (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,reporter_id INT UNSIGNED NOT NULL,target_type VARCHAR(60),target_id INT UNSIGNED,reason TEXT,evidence VARCHAR(255),status ENUM('open','reviewing','resolved','rejected','withdrawn','resolved_positive') DEFAULT 'open',resolution_note TEXT NULL,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(reporter_id) REFERENCES users(id)) ENGINE=InnoDB;
CREATE TABLE notifications (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,user_id INT UNSIGNED NOT NULL,type VARCHAR(50),content VARCHAR(500),read_at DATETIME,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE) ENGINE=InnoDB;
CREATE TABLE audit_logs (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,actor_id INT UNSIGNED NULL,action VARCHAR(80),entity_type VARCHAR(80),entity_id INT UNSIGNED NULL,metadata JSON,created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,INDEX(actor_id),FOREIGN KEY(actor_id) REFERENCES users(id) ON DELETE SET NULL) ENGINE=InnoDB;


ALTER TABLE users ADD COLUMN report_count INT UNSIGNED NOT NULL DEFAULT 0 AFTER trust_score;
ALTER TABLE sellers ADD COLUMN logo VARCHAR(255) NULL AFTER website, ADD COLUMN shop_photo VARCHAR(255) NULL AFTER logo, ADD COLUMN city VARCHAR(80) NULL AFTER website, ADD COLUMN district VARCHAR(80) NULL AFTER city, ADD COLUMN shop_address TEXT NULL AFTER district, ADD COLUMN sales_channel ENUM('store','online','both') NOT NULL DEFAULT 'both' AFTER shop_address;

CREATE TABLE seller_listings (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, seller_id INT UNSIGNED NOT NULL, product_id INT UNSIGNED NOT NULL, title VARCHAR(220) NOT NULL, price DECIMAL(12,2) NOT NULL, stock INT UNSIGNED NOT NULL DEFAULT 0, city VARCHAR(80), district VARCHAR(80), shop_address TEXT, sales_channel ENUM('store','online','both') NOT NULL DEFAULT 'both', image VARCHAR(255), description TEXT, status ENUM('active','passive','soldout') NOT NULL DEFAULT 'active', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(seller_id) REFERENCES sellers(id) ON DELETE CASCADE, FOREIGN KEY(product_id) REFERENCES products(id) ON DELETE CASCADE, INDEX(city,sales_channel,status)
) ENGINE=InnoDB;
CREATE TABLE roommate_listings (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, user_id INT UNSIGNED NOT NULL, title VARCHAR(220) NOT NULL, city VARCHAR(80) NOT NULL, district VARCHAR(80), university VARCHAR(160), monthly_rent DECIMAL(12,2) NOT NULL DEFAULT 0, deposit DECIMAL(12,2) NOT NULL DEFAULT 0, total_roommates INT UNSIGNED NOT NULL DEFAULT 2, available_spots INT UNSIGNED NOT NULL DEFAULT 1, move_in_date DATE NULL, address_area VARCHAR(220), image VARCHAR(255), description TEXT, status ENUM('active','closed','passive') NOT NULL DEFAULT 'active', created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE, INDEX(city,status)
) ENGINE=InnoDB;
CREATE TABLE messages (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, sender_id INT UNSIGNED NOT NULL, receiver_id INT UNSIGNED NOT NULL, subject VARCHAR(180), body TEXT NOT NULL, context_type VARCHAR(40) DEFAULT 'general', context_id INT UNSIGNED DEFAULT 0, read_at DATETIME NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(sender_id) REFERENCES users(id) ON DELETE CASCADE, FOREIGN KEY(receiver_id) REFERENCES users(id) ON DELETE CASCADE, INDEX(sender_id,receiver_id,created_at)
) ENGINE=InnoDB;

INSERT INTO users(username,email,phone,password_hash,city,role,status,trust_score) VALUES
('demo','user@cobuy.local','05550000001','$2y$12$ALDs7x7s/neZyMN02lcC.uYbLiXft3wj9G.Cyu9oqR52TLJk8IN/W','İstanbul','user','active',88),
('satıcı','seller@cobuy.local','05550000002','$2y$12$ALDs7x7s/neZyMN02lcC.uYbLiXft3wj9G.Cyu9oqR52TLJk8IN/W','İstanbul','seller','active',95),
('yonetici','admin@cobuy.local','05550000003','$2y$12$ALDs7x7s/neZyMN02lcC.uYbLiXft3wj9G.Cyu9oqR52TLJk8IN/W','İstanbul','admin','active',100),
('ayse','ayse@cobuy.local','05550000004','$2y$12$ALDs7x7s/neZyMN02lcC.uYbLiXft3wj9G.Cyu9oqR52TLJk8IN/W','Ankara','user','active',84),
('mert','mert@cobuy.local','05550000005','$2y$12$ALDs7x7s/neZyMN02lcC.uYbLiXft3wj9G.Cyu9oqR52TLJk8IN/W','İzmir','user','active',90);
INSERT INTO categories(name,slug,icon,sort_order) VALUES ('Elektronik','elektronik','💻',1),('Ev Elektroniği','ev-elektronigi','🏠',2),('Mobilya','mobilya','🪑',3),('Otomotiv','otomotiv','🚗',4),('Eğitim','egitim','🎓',5),('Hizmet','hizmet','🛠️',6),('İşletme','isletme','🏢',7);
INSERT INTO products(category_id,brand,name,model,variant,market_price,image,description) VALUES
(2,'Roborock','Robot Süpürge','Q8 Max','Siyah',18999,NULL,'Akıllı navigasyonlu robot süpürge'),
(2,'Philips','Kahve Makinesi','LatteGo 5400','Siyah',23999,NULL,'Tam otomatik kahve makinesi'),
(2,'Daikin','Klima','Sensira','12000 BTU',31999,NULL,'A++ inverter klima'),
(3,'Ergoflex','Ofis Sandalyesi','ProMesh','Siyah',8999,NULL,'Ergonomik çalışma sandalyesi'),
(4,'Michelin','Araç Lastiği','Primacy 4+','205/55 R16',5200,NULL,'Yaz lastiği tek adet'),
(1,'Apple','Tablet','iPad 10. Nesil','64 GB',17999,NULL,'10.9 inç tablet'),
(5,'EduPro','YKS Hazırlık Paketi','2026','12 Ay',6999,NULL,'Online eğitim ve deneme paketi');
INSERT INTO sellers(user_id,company_name,tax_number,address,website,verification_status,seller_score,status) VALUES(2,'Nova Teknoloji A.Ş.','1234567890','İstanbul','https://example.com','verified',92,'active');

INSERT INTO seller_listings(seller_id,product_id,title,price,stock,city,district,shop_address,sales_channel,description,status) VALUES
(1,1,'Roborock Q8 Max - Mağaza ve Online Satış',17490,18,'İstanbul','Kadıköy','Caferağa Mah. Teknoloji Sok. No:12 Kadıköy/İstanbul','both','Mağazadan teslim veya Türkiye geneli kargo.','active'),
(1,2,'Philips LatteGo 5400 Online Fırsat',22490,9,'İstanbul','Kadıköy','Caferağa Mah. Teknoloji Sok. No:12 Kadıköy/İstanbul','online','Ücretsiz kargo ve 2 yıl garanti.','active');
INSERT INTO roommate_listings(user_id,title,city,district,university,monthly_rent,deposit,total_roommates,available_spots,move_in_date,address_area,description,status) VALUES
(4,'Ankara’da üniversite öğrencisi için 2 ev arkadaşı','Ankara','Çankaya','Ankara Üniversitesi',6000,6000,3,2,DATE_ADD(CURDATE(),INTERVAL 20 DAY),'Beşevler metroya yakın','3+1 ev. Kişi başı kira yaklaşık 6.000 TL. Öğrenci ve düzenli kişiler tercih edilir.','active'),
(5,'İzmir Bornova’da öğrenci evi için 1 kişi','İzmir','Bornova','Ege Üniversitesi',7500,5000,3,1,DATE_ADD(CURDATE(),INTERVAL 30 DAY),'Küçükpark yakını','Faturalar ortak paylaşılır. Ev eşyalıdır.','active');

INSERT INTO group_carts(creator_id,product_id,title,city,scope,target_quantity,minimum_discount,expected_max_price,starts_at,ends_at,status,description) VALUES
(1,1,'50 kişilik Roborock Q8 Max alımı','İstanbul','national',50,12,16000,NOW(),DATE_ADD(NOW(),INTERVAL 8 DAY),'offer','Türkiye geneli ücretsiz kargo ve distribütör garantisi arıyoruz.'),
(4,3,'Ankara toplu klima alımı ve kurulum','Ankara','local',30,15,27000,NOW(),DATE_ADD(NOW(),INTERVAL 12 DAY),'active','Aynı hafta içinde toplu kurulum tercihi.'),
(5,4,'Ergonomik ofis sandalyesi ortak alımı','İzmir','national',25,10,7500,NOW(),DATE_ADD(NOW(),INTERVAL 6 DAY),'offer','Siyah renk ve en az 2 yıl garanti.'),
(1,2,'LatteGo kahve makinesi toplu alımı','İstanbul','national',20,10,20500,NOW(),DATE_ADD(NOW(),INTERVAL 10 DAY),'active','Hediye kahve paketi olan teklifler tercih edilir.'),
(4,6,'Öğrenciler için iPad ortak sepeti','Ankara','national',40,8,16000,NOW(),DATE_ADD(NOW(),INTERVAL 15 DAY),'active','Öğrenci indirimi ve taksit avantajı bekleniyor.');
INSERT INTO cart_participants(cart_id,user_id,participation_type,maximum_price,quantity,status) VALUES(1,1,'committed',16000,1,'active'),(1,4,'conditional',16500,1,'active'),(1,5,'committed',15800,1,'active'),(2,4,'conditional',27500,1,'active'),(3,5,'committed',7500,1,'active'),(3,1,'conditional',7700,1,'active'),(4,1,'interested',21000,1,'active'),(5,4,'conditional',16000,1,'active');
INSERT INTO seller_offers(cart_id,seller_id,unit_price,minimum_quantity,maximum_quantity,shipping_cost,delivery_days,warranty_type,installment_info,gift_info,expires_at,status) VALUES(1,1,15900,25,80,0,4,'2 yıl distribütör garantisi','6 taksit','Yedek filtre hediyesi',DATE_ADD(NOW(),INTERVAL 3 DAY),'active'),(3,1,7390,20,60,0,5,'3 yıl üretici garantisi','3 taksit','Ücretsiz montaj',DATE_ADD(NOW(),INTERVAL 3 DAY),'active');
INSERT INTO offer_tiers(offer_id,minimum_quantity,unit_price) VALUES(1,10,17500),(1,25,15900),(1,50,14950),(2,10,7990),(2,20,7390),(2,40,6990);
INSERT INTO messages(sender_id,receiver_id,subject,body,context_type,context_id) VALUES
(1,2,'Robot süpürge hakkında','Merhaba, mağazadan teslimde fiyat değişiyor mu?','listing',1),
(2,1,'Robot süpürge hakkında','Merhaba, mağazadan teslimde aynı fiyat geçerli.','listing',1),
(4,1,'Ev arkadaşı ilanı','Ankara ilanınız için evin konumunu biraz daha anlatabilir misiniz?','roommate',1);

INSERT INTO notifications(user_id,type,content) VALUES(1,'offer','Roborock sepetine 15.900 TL teklif geldi.'),(1,'cart','LatteGo sepetine katılımınız kaydedildi.');
SET FOREIGN_KEY_CHECKS=1;
