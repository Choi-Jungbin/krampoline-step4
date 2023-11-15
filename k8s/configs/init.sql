CREATE SCHEMA IF NOT EXISTS `krampoline` DEFAULT CHARACTER SET utf8mb4;

CREATE USER 'root'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;

USE `krampoline`;

-- 외래키 체크 설정 해제
SET foreign_key_checks = 0;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS rewards;
DROP TABLE IF EXISTS progresses;
DROP TABLE IF EXISTS titles;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS albums;
DROP TABLE IF EXISTS album_pages;
DROP TABLE IF EXISTS album_images;
DROP TABLE IF EXISTS album_members;
DROP TABLE IF EXISTS trashes;
-- 외래키 체크 설정
SET foreign_key_checks = 1;

-- 유저 테이블
CREATE TABLE users
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    email  VARCHAR(128)  NOT NULL  UNIQUE,
    nickname  VARCHAR(32)  NOT NULL,
    title  VARCHAR(128),
    image  VARCHAR(512)  NOT NULL,
    user_role  VARCHAR(16)  NOT NULL,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 도전과제 테이블
CREATE TABLE rewards
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    reward_name  VARCHAR(128)  NOT NULL,
    description  VARCHAR(256)  NOT NULL,
    reward_level  VARCHAR(16)  NOT NULL,
    goal_count  INTEGER  NOT NULL,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 도전과제 진행도 테이블
CREATE TABLE progresses
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    progress_count  INTEGER  NOT NULL,
    success  CHAR(1)  NOT NULL,
    user_id  BIGINT,
    reward_id  BIGINT,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (reward_id) REFERENCES rewards (id)
);

-- 칭호 테이블
CREATE TABLE titles
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    title_name  VARCHAR(128)  NOT NULL,
    reward_id  BIGINT,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (reward_id) REFERENCES rewards (id)
);

-- 유저 달성 칭호 테이블
CREATE TABLE collections
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    user_id  BIGINT,
    title_id  BIGINT,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (title_id) REFERENCES titles (id)
);

-- 앨범 테이블
CREATE TABLE albums
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    album_name  VARCHAR(128)  NOT NULL,
    description  VARCHAR(512)  NOT NULL,
    image  VARCHAR(512)  NOT NULL,
    category  VARCHAR(16)  NOT NULL,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 앨범 페이지 테이블
CREATE TABLE album_pages
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    album_id  BIGINT,
    shapes  LONGTEXT,
    bindings  LONGTEXT,
    capture_page_url  VARCHAR(512),
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (album_id) REFERENCES albums (id)
);

-- 앨범 페이지 이미지 테이블
CREATE TABLE album_images
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    album_page_id  BIGINT,
    asset_id  VARCHAR(128)  NOT NULL,
    file_name  VARCHAR(128)  NOT NULL,
    type  VARCHAR(16)  NOT NULL,
    x_size  DOUBLE  NOT NULL,
    y_size  DOUBLE  NOT NULL,
    url VARCHAR(2056),
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (album_page_id) REFERENCES album_pages (id)
);

-- 앨범 멤버 테이블
CREATE TABLE album_members
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    user_id  BIGINT,
    album_id  BIGINT,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (album_id) REFERENCES albums (id)
);

-- 휴지통 테이블
CREATE TABLE trashes
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    user_id  BIGINT  NOT NULL,
    album_page_id  BIGINT  NOT NULL,
    delete_at  DATETIME  DEFAULT CURRENT_TIMESTAMP  NOT NULL,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users (id),
    FOREIGN KEY (album_page_id) REFERENCES album_pages (id)
);

-- 에러 테이블
CREATE TABLE error
(
    id  BIGINT  AUTO_INCREMENT  PRIMARY KEY,
    massage VARCHAR(1024),
    stack_trace VARCHAR(4096)  NOT NULL,
    create_at  DATETIME  DEFAULT CURRENT_TIMESTAMP,
    update_at  DATETIME  DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 유저
INSERT INTO users (`email`, `nickname`, `title`, `image`, `user_role`) VALUES ('admin', 'admin', '내가 관리자라니!!', '이미지', 'ROLE_ADMIN');

-- 도전과제
INSERT INTO rewards (`reward_name`, `description`, `reward_level`, `goal_count`) VALUES ('어드민 유저가 뭔데?', '관리자가 되어보세요.', 'challenger', '10000000');
INSERT INTO rewards (`reward_name`, `description`, `reward_level`, `goal_count`) VALUES ('우리들의 첫번째 추억 기록', '첫번째 앨범 페이지를 생성해보세요.', 'bronze', '1');
INSERT INTO rewards (`reward_name`, `description`, `reward_level`, `goal_count`) VALUES ('콜롬버스 등장', '네모에 오신 것을 환영합니다.', 'gold', '1');

-- 진행도
INSERT INTO progresses (`progress_count`, `success`, `user_id`, `reward_id`) VALUES ('10000000', 'Y', '1', '1');
INSERT INTO progresses (`progress_count`, `success`, `user_id`, `reward_id`) VALUES ('0', 'N', '1', '2');
INSERT INTO progresses (`progress_count`, `success`, `user_id`, `reward_id`) VALUES ('0', 'Y', '1', '3');

-- 앨범
INSERT INTO albums (`album_name`, `description`, `image`, `category`) VALUES ('테스트 앨범', '테스트용 앨범', '""', 'Friends');

-- 칭호
INSERT INTO titles (`title_name`, `reward_id`) VALUES ('내가 관리자라니!!', '1');
INSERT INTO titles (`title_name`, `reward_id`) VALUES ('추억 앨범 관리자', '2');
INSERT INTO titles (`title_name`, `reward_id`) VALUES ('방문객', '3');

-- 칭호 획득
INSERT INTO collections (`user_id`, `title_id`) VALUES ('1', '1');
INSERT INTO collections (`user_id`, `title_id`) VALUES ('1', '3');
