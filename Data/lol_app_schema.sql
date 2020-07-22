SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `name` varchar(255),
  `email_id` varchar(255),
  `password` varchar(255),
  `signup_time` timestamp
);

DROP TABLE IF EXISTS `user_topics`;
CREATE TABLE `user_topics` (
  `user_id` int,
  `topic` varchar(255)
);

DROP TABLE IF EXISTS `memes`;
CREATE TABLE `memes` (
  `id` int PRIMARY KEY AUTO_INCREMENT,
  `upload_time` timestamp,
  `data` text,
  `upload_user_id` int
);

DROP TABLE IF EXISTS `meme_topics`;
CREATE TABLE `meme_topics` (
  `meme_id` int,
  `topic` varchar(255)
);

DROP TABLE IF EXISTS `user_meme_interaction`;
CREATE TABLE `user_meme_interaction` (
  `user_id` int,
  `meme_id` int,
  `reaction` varchar(255) DEFAULT NULL,
  `score` int DEFAULT NULL
);

ALTER TABLE `user_topics` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `memes` ADD FOREIGN KEY (`upload_user_id`) REFERENCES `users` (`id`);

ALTER TABLE `meme_topics` ADD FOREIGN KEY (`meme_id`) REFERENCES `memes` (`id`);

ALTER TABLE `user_meme_interaction` ADD FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

ALTER TABLE `user_meme_interaction` ADD FOREIGN KEY (`meme_id`) REFERENCES `memes` (`id`);