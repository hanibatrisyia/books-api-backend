-- 1. DROP EXISTING TABLES IN REVERSE ORDER OF DEPENDENCY
DROP TABLE IF EXISTS audit_log;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS users;

-- 2. CREATE USERS TABLE FIRST
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(190) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('member', 'admin') NOT NULL DEFAULT 'member',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. SEED INITIAL USERS DATA
INSERT INTO users (id, name, email, password_hash, role) VALUES
(1, 'Test Member', 'member@books.test', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'member'),
(2, 'Test Admin', 'admin@books.test', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin');

-- 4. CREATE BOOKS TABLE
CREATE TABLE books (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(150) NOT NULL,
    year SMALLINT NOT NULL,
    genre VARCHAR(80) NOT NULL DEFAULT 'Uncategorised',
    created_by INT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. ADD FOREIGN KEY CONSTRAINT LINKING BOOKS TO USERS
ALTER TABLE books ADD CONSTRAINT fk_books_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;

-- 6. SEED INITIAL BOOKS DATA
INSERT INTO books (title, author, year, genre) VALUES
('Clean Code', 'Robert C. Martin', 2008, 'Software Engineering'),
('Eloquent JavaScript', 'Marijn Haverbeke', 2018, 'Programming'),
('Vue.js 3 By Example', 'John Au-Yeung', 2021, 'Web Development');

-- 7. LINK THE SEEDED BOOKS TO THE GENERATED USERS
UPDATE books SET created_by = 1 WHERE id = 1 OR id = 3;

UPDATE books SET created_by = 2 WHERE id = 2;

-- 8. CREATE AUDIT LOG TABLE
CREATE TABLE audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    actor_id INT NULL,
    action VARCHAR(50) NOT NULL,
    target VARCHAR(80) NULL,
    ip_address VARCHAR(45) NULL,
    detail VARCHAR(500) NULL,
    INDEX idx_action (action),
    INDEX idx_actor (actor_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;