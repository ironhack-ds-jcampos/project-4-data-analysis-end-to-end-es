-- `ironhack-project`.authors definition

CREATE TABLE `authors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `authors_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=359 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.books definition

CREATE TABLE `books` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `synopsis` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci,
  `code` varchar(32) NOT NULL,
  `cover_url` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `books_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=501 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.categories definition

CREATE TABLE `categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `categories_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=202 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.regions definition

CREATE TABLE `regions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `regions_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.book_authors definition

CREATE TABLE `book_authors` (
  `book_id` int NOT NULL,
  `author_id` int NOT NULL,
  PRIMARY KEY (`book_id`,`author_id`),
  KEY `book_authors_authors_FK` (`author_id`),
  CONSTRAINT `book_authors_authors_FK` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`),
  CONSTRAINT `book_authors_books_FK` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.book_categories definition

CREATE TABLE `book_categories` (
  `book_id` int NOT NULL,
  `category_id` int NOT NULL,
  PRIMARY KEY (`category_id`,`book_id`),
  KEY `book_categories_books_FK` (`book_id`),
  CONSTRAINT `book_categories_books_FK` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`),
  CONSTRAINT `book_categories_categories_FK` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.book_regions definition

CREATE TABLE `book_regions` (
  `book_id` int NOT NULL,
  `region_id` int NOT NULL,
  PRIMARY KEY (`book_id`,`region_id`),
  KEY `book_regions_regions_FK` (`region_id`),
  CONSTRAINT `book_regions_books_FK` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`),
  CONSTRAINT `book_regions_regions_FK` FOREIGN KEY (`region_id`) REFERENCES `regions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;


-- `ironhack-project`.chapters definition

CREATE TABLE `chapters` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(256) NOT NULL,
  `book_id` int NOT NULL,
  `number` int NOT NULL,
  `code` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `chapters_unique` (`book_id`,`number`),
  CONSTRAINT `chapters_books_FK` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=40540 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Views

-- `ironhack-project`.author_books_count source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `ironhack-project`.`author_books_count` AS
select
    `a`.`name` AS `author_name`,
    count(distinct `ba`.`book_id`) AS `book_count`
from
    (`ironhack-project`.`authors` `a`
left join `ironhack-project`.`book_authors` `ba` on
    ((`ba`.`author_id` = `a`.`id`)))
group by
    `a`.`name`;


-- `ironhack-project`.books_per_author source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `ironhack-project`.`books_per_author` AS
select
    `a`.`id` AS `author_id`,
    `a`.`name` AS `author_name`,
    count(`b`.`id`) AS `books_count`
from
    ((`ironhack-project`.`authors` `a`
left join `ironhack-project`.`book_authors` `ba` on
    ((`a`.`id` = `ba`.`author_id`)))
left join `ironhack-project`.`books` `b` on
    ((`ba`.`book_id` = `b`.`id`)))
group by
    `a`.`id`,
    `a`.`name`;


-- `ironhack-project`.category_books_count source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `ironhack-project`.`category_books_count` AS
select
    `c`.`name` AS `name`,
    count(`bc`.`category_id`) AS `count`
from
    (`ironhack-project`.`categories` `c`
left join `ironhack-project`.`book_categories` `bc` on
    ((`bc`.`category_id` = `c`.`id`)))
group by
    `c`.`name`;


-- `ironhack-project`.chapters_per_book source

CREATE OR REPLACE
ALGORITHM = UNDEFINED VIEW `ironhack-project`.`chapters_per_book` AS
select
    `b`.`id` AS `book_id`,
    `b`.`name` AS `book_name`,
    count(`c`.`id`) AS `chapters_count`
from
    (`ironhack-project`.`books` `b`
left join `ironhack-project`.`chapters` `c` on
    ((`b`.`id` = `c`.`book_id`)))
group by
    `b`.`id`,
    `b`.`name`;