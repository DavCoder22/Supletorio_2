-- Create databases for each microservice
CREATE DATABASE IF NOT EXISTS microservicio1;
CREATE DATABASE IF NOT EXISTS microservicio2;
CREATE DATABASE IF NOT EXISTS microservicio3;
CREATE DATABASE IF NOT EXISTS microservicio4;
CREATE DATABASE IF NOT EXISTS microservicio5;

-- Create users and grant privileges for each microservice
DELIMITER //

CREATE PROCEDURE create_service_user(IN db_name VARCHAR(100), IN username VARCHAR(100), IN password VARCHAR(100))
BEGIN
    DECLARE user_exists INT;
    
    -- Check if user exists
    SELECT COUNT(*) INTO user_exists FROM mysql.user WHERE user = username AND host = '%';
    
    -- Create user if not exists
    IF user_exists = 0 THEN
        SET @create_user = CONCAT('CREATE USER ''', username, '''@''%'' IDENTIFIED BY ''', password, '''');
        PREPARE stmt FROM @create_user;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        -- Grant privileges
        SET @grant_privs = CONCAT('GRANT ALL PRIVILEGES ON ', db_name, '.* TO ''', username, '''@''%''');
        PREPARE stmt FROM @grant_privs;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        
        SELECT CONCAT('Created user and granted privileges for database: ', db_name) AS message;
    ELSE
        SELECT CONCAT('User already exists for database: ', db_name) AS message;
    END IF;
END //

DELIMITER ;

-- Create users and grant privileges for each microservice
CALL create_service_user('microservicio1', 'user_microservicio1', 'password1');
CALL create_service_user('microservicio2', 'user_microservicio2', 'password2');
CALL create_service_user('microservicio3', 'user_microservicio3', 'password3');
CALL create_service_user('microservicio4', 'user_microservicio4', 'password4');
CALL create_service_user('microservicio5', 'user_microservicio5', 'password5');

-- Flush privileges
FLUSH PRIVILEGES;

-- Clean up
DROP PROCEDURE IF EXISTS create_service_user;
