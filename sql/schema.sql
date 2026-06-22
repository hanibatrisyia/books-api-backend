CREATE DATABASE IF NOT EXISTS books_api 
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; 
USE books_api; 
    
CREATE TABLE IF NOT EXISTS audit_log ( 
    id          BIGINT AUTO_INCREMENT PRIMARY KEY, 
    occurred_at DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    actor_id    INT         NULL, 
    action      VARCHAR(50) NOT NULL, 
    target      VARCHAR(80) NULL, 
    ip_address  VARCHAR(45) NULL, 
    detail      VARCHAR(500) NULL, 
    INDEX idx_action (action), 
    INDEX idx_actor  (actor_id) 
) ENGINE=InnoDB;

DROP TABLE IF EXISTS books; 
  
CREATE TABLE books ( 
    id          INT AUTO_INCREMENT PRIMARY KEY, 
    title       VARCHAR(200) NOT NULL, 
    author      VARCHAR(150) NOT NULL, 
    year        SMALLINT     NOT NULL, 
    genre       VARCHAR(80)  NOT NULL DEFAULT 'Uncategorised', 
    created_by  INT          NULL,
    created_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    updated_at  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP 
                              ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_books_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB; 
  
INSERT INTO books (title, author, year, genre) VALUES 
  ('Clean Code',          'Robert C. Martin',  2008, 'Software Engineering'), 
  ('Eloquent JavaScript', 'Marijn Haverbeke',   2018, 'Programming'), 
  ('Vue.js 3 By Example', 'John Au-Yeung',      2021, 'Web Development'); 
 
UPDATE books SET created_by = 1 WHERE id IN (1, 3); 
UPDATE books SET created_by = 2 WHERE id = 2; 