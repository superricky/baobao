set names utf8;
use freedom_production;
-- MySQL dump 10.13  Distrib 5.5.37, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: freedom_development
-- ------------------------------------------------------
-- Server version	5.5.37-0ubuntu0.14.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `login_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `encrypted_password` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `reset_password_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmation_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `failed_attempts` int(11) DEFAULT '0',
  `unlock_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_accounts_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_accounts_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_accounts_on_login_id` (`login_id`),
  UNIQUE KEY `index_accounts_on_email` (`email`),
  KEY `index_accounts_on_phone` (`phone`),
  KEY `index_accounts_on_shop_id` (`shop_id`),
  KEY `index_accounts_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (1,'admin','admin','exchange@tuodanbao.com','$2a$10$cd5JZNC7PEYwAyzJUcTeueKQ51pdsugQwnKtSL8lBfu9kvP9MPz1m','127.0.0.1','13800138000','2014-05-24 15:34:24','2014-05-24 15:34:42',1,NULL,NULL,NULL,1,'2014-05-24 15:34:42','2014-05-24 15:34:42','127.0.0.1',NULL,'2014-05-24 15:34:33','2014-05-24 15:34:24',0,NULL,NULL,NULL);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_branches`
--

DROP TABLE IF EXISTS `accounts_branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_branches` (
  `account_id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_branches`
--

LOCK TABLES `accounts_branches` WRITE;
/*!40000 ALTER TABLE `accounts_branches` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_roles`
--

DROP TABLE IF EXISTS `accounts_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_roles` (
  `account_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  KEY `index_accounts_roles_on_account_id_and_role_id` (`account_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_roles`
--

LOCK TABLES `accounts_roles` WRITE;
/*!40000 ALTER TABLE `accounts_roles` DISABLE KEYS */;
INSERT INTO `accounts_roles` VALUES (1,1);
/*!40000 ALTER TABLE `accounts_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_rels`
--

DROP TABLE IF EXISTS `agent_rels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_rels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `agent_id` int(11) DEFAULT NULL,
  `agent_zone_id` int(11) DEFAULT NULL,
  `agent_from` datetime DEFAULT NULL,
  `agent_to` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_rels`
--

LOCK TABLES `agent_rels` WRITE;
/*!40000 ALTER TABLE `agent_rels` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_rels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agent_zones`
--

DROP TABLE IF EXISTS `agent_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agent_zones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_agent_zone_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_agent_zones_on_parent_agent_zone_id` (`parent_agent_zone_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agent_zones`
--

LOCK TABLES `agent_zones` WRITE;
/*!40000 ALTER TABLE `agent_zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `agent_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `agents`
--

DROP TABLE IF EXISTS `agents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `agents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `aid` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `balance` decimal(8,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `agents`
--

LOCK TABLES `agents` WRITE;
/*!40000 ALTER TABLE `agents` DISABLE KEYS */;
/*!40000 ALTER TABLE `agents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `angel_types`
--

DROP TABLE IF EXISTS `angel_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `angel_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `discount` decimal(3,2) DEFAULT '1.00',
  `max_valid_times` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `rebates_credits_return` int(11) DEFAULT '0',
  `rebates_wallet_return` decimal(8,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_angel_types_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `angel_types`
--

LOCK TABLES `angel_types` WRITE;
/*!40000 ALTER TABLE `angel_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `angel_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `angels`
--

DROP TABLE IF EXISTS `angels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `angels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `angel_number` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `angel_type_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `rebates_credits` int(11) DEFAULT '0',
  `rebates_wallet` decimal(8,2) DEFAULT '0.00',
  `orders_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_angels_on_angel_type_id` (`angel_type_id`),
  KEY `index_angels_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `angels`
--

LOCK TABLES `angels` WRITE;
/*!40000 ALTER TABLE `angels` DISABLE KEYS */;
/*!40000 ALTER TABLE `angels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_keys`
--

DROP TABLE IF EXISTS `api_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_keys` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `access_token` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  `expires_at` datetime DEFAULT NULL,
  `owner_id` int(11) NOT NULL,
  `owner_type` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  `ip_address` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  `location` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_keys`
--

LOCK TABLES `api_keys` WRITE;
/*!40000 ALTER TABLE `api_keys` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `articles`
--

DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `articles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `pic_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` text COLLATE utf8_unicode_ci,
  `owner_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `owner_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `img_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `link_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `expiration_time` datetime DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `support_promotion` tinyint(1) DEFAULT NULL,
  `introduction` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_articles_on_owner_id` (`owner_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `articles`
--

LOCK TABLES `articles` WRITE;
/*!40000 ALTER TABLE `articles` DISABLE KEYS */;
/*!40000 ALTER TABLE `articles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `awards`
--

DROP TABLE IF EXISTS `awards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `awards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `branch_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_awards_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `awards`
--

LOCK TABLES `awards` WRITE;
/*!40000 ALTER TABLE `awards` DISABLE KEYS */;
/*!40000 ALTER TABLE `awards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `base_users`
--

DROP TABLE IF EXISTS `base_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `base_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `phone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `default_address` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `fake_user_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email_address` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subscribe_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `last_login_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `orders_count` int(11) DEFAULT NULL,
  `credits` int(11) DEFAULT '0',
  `vip_no` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sent_validation_code_time` datetime DEFAULT NULL,
  `sent_validation_code_times_in_today` int(11) DEFAULT '0',
  `last_latitude` decimal(10,6) DEFAULT NULL,
  `last_longitude` decimal(10,6) DEFAULT NULL,
  `last_location_label` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_location_time` datetime DEFAULT NULL,
  `is_blocked` tinyint(1) DEFAULT '0',
  `vip_level_id` int(11) DEFAULT NULL,
  `pay_password_hash` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `wallet` decimal(8,2) DEFAULT '0.00',
  `total_amount` decimal(8,2) DEFAULT '0.00',
  `angel_id` int(11) DEFAULT NULL,
  `recommend_user_id` int(11) DEFAULT NULL,
  `is_apply_vip_user` tinyint(1) DEFAULT '0',
  `my_fake_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8_unicode_ci DEFAULT '',
  `encrypted_password` varchar(191) COLLATE utf8_unicode_ci DEFAULT '',
  `reset_password_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order_webstores_count` int(11) DEFAULT '0',
  `confirmation_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `host` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `member_id` int(11) DEFAULT NULL,
  `ticket` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `scene_id` int(11) DEFAULT NULL,
  `generalize_user_id` int(11) DEFAULT NULL,
  `audiences_count` int(11) DEFAULT '0',
  `nickname` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `headimgurl` text COLLATE utf8_unicode_ci,
  PRIMARY KEY (`id`),
  KEY `index_base_users_on_fake_user_name` (`fake_user_name`),
  KEY `index_base_users_on_shop_id` (`shop_id`),
  KEY `index_base_users_on_angel_id` (`angel_id`),
  KEY `index_base_users_on_recommend_user_id` (`recommend_user_id`),
  KEY `index_base_users_on_generalize_user_id` (`generalize_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `base_users`
--

LOCK TABLES `base_users` WRITE;
/*!40000 ALTER TABLE `base_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `base_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_comments`
--

DROP TABLE IF EXISTS `branch_comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `level` int(11) DEFAULT '5',
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `can_pub` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_branch_comments_on_user_id` (`user_id`),
  KEY `index_branch_comments_on_shop_id` (`shop_id`),
  KEY `index_branch_comments_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_comments`
--

LOCK TABLES `branch_comments` WRITE;
/*!40000 ALTER TABLE `branch_comments` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_sliders`
--

DROP TABLE IF EXISTS `branch_sliders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_sliders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `img` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `desc` text COLLATE utf8_unicode_ci,
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_branch_sliders_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_sliders`
--

LOCK TABLES `branch_sliders` WRITE;
/*!40000 ALTER TABLE `branch_sliders` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_sliders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branch_types`
--

DROP TABLE IF EXISTS `branch_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branch_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branches_count` int(11) DEFAULT '0',
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_branch_types_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branch_types`
--

LOCK TABLES `branch_types` WRITE;
/*!40000 ALTER TABLE `branch_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `branch_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches`
--

DROP TABLE IF EXISTS `branches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branches` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_open` tinyint(1) DEFAULT '1',
  `service_period_start` time DEFAULT '00:00:00',
  `service_period_end` time DEFAULT '23:59:00',
  `expiration_time` datetime DEFAULT NULL,
  `notice` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `income` decimal(10,2) DEFAULT '0.00',
  `telephone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `zip_code` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `latitude` decimal(10,6) DEFAULT NULL,
  `longitude` decimal(10,6) DEFAULT NULL,
  `products_count` int(11) DEFAULT '0',
  `carts_count` int(11) DEFAULT '0',
  `orders_count` int(11) DEFAULT '0',
  `introduction` text COLLATE utf8_unicode_ci,
  `use_min_order_charge` tinyint(1) DEFAULT '0',
  `min_order_charge` decimal(8,2) DEFAULT NULL,
  `non_service_order_charge` decimal(8,2) DEFAULT '0.00',
  `delivery_radius` decimal(6,1) DEFAULT '1.5',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `charge_method` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'by_time',
  `left_order_count` int(11) DEFAULT '0',
  `supported_order_types` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'delivery,eat_in_hall,order_seat',
  `notify_new_order` tinyint(1) DEFAULT '1',
  `sms_msgs_count` int(11) DEFAULT '0',
  `use_sms` tinyint(1) DEFAULT '0',
  `max_sms_count` int(11) DEFAULT '0',
  `use_sms_validation` tinyint(1) DEFAULT '0',
  `sms_to` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_scrachpad` tinyint(1) DEFAULT '0',
  `first_prize_possibility` int(11) DEFAULT '5',
  `second_prize_possibility` int(11) DEFAULT '10',
  `third_prize_possibility` int(11) DEFAULT '15',
  `first_prize` varchar(191) COLLATE utf8_unicode_ci DEFAULT '8折优惠',
  `second_prize` varchar(191) COLLATE utf8_unicode_ci DEFAULT '9折优惠',
  `third_prize` varchar(191) COLLATE utf8_unicode_ci DEFAULT '95折优惠',
  `no_prize` varchar(191) COLLATE utf8_unicode_ci DEFAULT '谢谢惠顾',
  `valid_before` datetime DEFAULT NULL,
  `min_charge_for_scratch` decimal(8,2) DEFAULT '10.00',
  `max_scratch_times_in_day` int(11) DEFAULT '5',
  `supported_scratchpad_order_types` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'delivery,eat_in_hall,order_seat',
  `min_order_time_gap` int(11) DEFAULT '30',
  `check_stock` tinyint(1) DEFAULT '1',
  `credits_given` int(11) DEFAULT '0',
  `credits_consume` int(11) DEFAULT '0',
  `position` int(11) DEFAULT NULL,
  `separate_notice_of_praise_and_new_order` tinyint(1) DEFAULT '0',
  `deleted_at` datetime DEFAULT NULL,
  `wallet_given` decimal(8,2) DEFAULT '0.00',
  `wallet_consume` decimal(8,2) DEFAULT '0.00',
  `product_list_style` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'thumb',
  `delivery_radius_txt` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_type_id` int(11) DEFAULT NULL,
  `branch_comments_count` int(11) DEFAULT '0',
  `average_level` decimal(2,1) DEFAULT '5.0',
  `brand_chain_id` int(11) DEFAULT NULL,
  `type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branches_count` int(11) DEFAULT '0',
  `supported_send_sms_order_types` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivery_charge` varchar(191) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `terms` text COLLATE utf8_unicode_ci,
  `allow_remind_order_msg` tinyint(1) DEFAULT '0',
  `enabled_verify_service_periods` tinyint(1) DEFAULT '0',
  `fixed_delivery_time` tinyint(1) DEFAULT '0',
  `rect_image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_branches_on_shop_id` (`shop_id`),
  KEY `index_branches_on_brand_chain_id` (`brand_chain_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches`
--

LOCK TABLES `branches` WRITE;
/*!40000 ALTER TABLE `branches` DISABLE KEYS */;
/*!40000 ALTER TABLE `branches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `branches_zones`
--

DROP TABLE IF EXISTS `branches_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `branches_zones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL,
  `zone_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_branches_zones_on_branch_id` (`branch_id`),
  KEY `index_branches_zones_on_zone_id` (`zone_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `branches_zones`
--

LOCK TABLES `branches_zones` WRITE;
/*!40000 ALTER TABLE `branches_zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `branches_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carts`
--

DROP TABLE IF EXISTS `carts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `carts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `line_items_count` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `user_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_carts_on_shop_id` (`shop_id`),
  KEY `index_carts_on_user_id` (`user_id`),
  KEY `index_carts_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carts`
--

LOCK TABLES `carts` WRITE;
/*!40000 ALTER TABLE `carts` DISABLE KEYS */;
/*!40000 ALTER TABLE `carts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories`
--

DROP TABLE IF EXISTS `categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT '0',
  `category_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_categories_on_shop_id` (`shop_id`),
  KEY `index_categories_on_branch_id` (`branch_id`),
  KEY `index_categories_on_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories`
--

LOCK TABLES `categories` WRITE;
/*!40000 ALTER TABLE `categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categories_products`
--

DROP TABLE IF EXISTS `categories_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `categories_products` (
  `product_id` int(11) DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  KEY `index_categories_products_on_product_id` (`product_id`),
  KEY `index_categories_products_on_category_id` (`category_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categories_products`
--

LOCK TABLES `categories_products` WRITE;
/*!40000 ALTER TABLE `categories_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `categories_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ckeditor_assets`
--

DROP TABLE IF EXISTS `ckeditor_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ckeditor_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `data_file_name` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  `data_content_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `data_file_size` int(11) DEFAULT NULL,
  `assetable_id` int(11) DEFAULT NULL,
  `assetable_type` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `type` varchar(30) COLLATE utf8_unicode_ci DEFAULT NULL,
  `width` int(11) DEFAULT NULL,
  `height` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ckeditor_assetable_type` (`assetable_type`,`type`,`assetable_id`),
  KEY `idx_ckeditor_assetable` (`assetable_type`,`assetable_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ckeditor_assets`
--

LOCK TABLES `ckeditor_assets` WRITE;
/*!40000 ALTER TABLE `ckeditor_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `ckeditor_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credits_logs`
--

DROP TABLE IF EXISTS `credits_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credits_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `credit_log_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `credits` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `credits_log_owner_id` int(11) NOT NULL DEFAULT '0',
  `order_id` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `shop_credits_given_after` int(11) DEFAULT NULL,
  `shop_credits_consume_after` int(11) DEFAULT NULL,
  `branch_credits_given_after` int(11) DEFAULT NULL,
  `branch_credits_consume_after` int(11) DEFAULT NULL,
  `user_credits_balance_after` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `consume_log_id` int(11) DEFAULT NULL,
  `angel_id` int(11) DEFAULT NULL,
  `credits_log_owner_type` varchar(191) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'User',
  PRIMARY KEY (`id`),
  KEY `index_credits_logs_on_shop_id` (`shop_id`),
  KEY `index_credits_logs_on_branch_id` (`branch_id`),
  KEY `index_credits_logs_on_order_id` (`order_id`),
  KEY `index_credits_logs_on_angel_id` (`angel_id`),
  KEY `index_credits_logs_on_owner_id` (`credits_log_owner_id`),
  KEY `index_credits_logs_on_credits_log_owner_type` (`credits_log_owner_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credits_logs`
--

LOCK TABLES `credits_logs` WRITE;
/*!40000 ALTER TABLE `credits_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `credits_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `currency_symbols`
--

DROP TABLE IF EXISTS `currency_symbols`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `currency_symbols` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `symbol` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `decoration` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_currency_symbols_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `currency_symbols`
--

LOCK TABLES `currency_symbols` WRITE;
/*!40000 ALTER TABLE `currency_symbols` DISABLE KEYS */;
/*!40000 ALTER TABLE `currency_symbols` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `custom_ui_settings`
--

DROP TABLE IF EXISTS `custom_ui_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `custom_ui_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order_delivery_btn` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order_eat_in_hall_btn` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order_order_seat` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `pay_on_receive` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pay_by_wallet` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pay_by_credits` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note_place_holder` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `custom_ui_settings`
--

LOCK TABLES `custom_ui_settings` WRITE;
/*!40000 ALTER TABLE `custom_ui_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `custom_ui_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_times`
--

DROP TABLE IF EXISTS `delivery_times`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delivery_times` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL,
  `delivery_time_start` time DEFAULT NULL,
  `delivery_time_end` time DEFAULT NULL,
  `time_advance` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_delivery_times_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_times`
--

LOCK TABLES `delivery_times` WRITE;
/*!40000 ALTER TABLE `delivery_times` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_times` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery_zones`
--

DROP TABLE IF EXISTS `delivery_zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `delivery_zones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `zone_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `charge` decimal(8,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_delivery_zones_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery_zones`
--

LOCK TABLES `delivery_zones` WRITE;
/*!40000 ALTER TABLE `delivery_zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `delivery_zones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `events`
--

DROP TABLE IF EXISTS `events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `events` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `event` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `event_key` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `material_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `is_system_keyword` tinyint(1) DEFAULT NULL,
  `system_keyword` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_events_on_material_id` (`material_id`),
  KEY `index_events_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `events`
--

LOCK TABLES `events` WRITE;
/*!40000 ALTER TABLE `events` DISABLE KEYS */;
/*!40000 ALTER TABLE `events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_contents`
--

DROP TABLE IF EXISTS `form_contents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_contents` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `deleted_at` datetime DEFAULT NULL,
  `form_element_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `label` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_contents`
--

LOCK TABLES `form_contents` WRITE;
/*!40000 ALTER TABLE `form_contents` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_contents` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `form_elements`
--

DROP TABLE IF EXISTS `form_elements`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `form_elements` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `statement` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `regex` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sequence` int(11) DEFAULT NULL,
  `form_element_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `need` tinyint(1) DEFAULT NULL,
  `placeholder` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `form_elements`
--

LOCK TABLES `form_elements` WRITE;
/*!40000 ALTER TABLE `form_elements` DISABLE KEYS */;
/*!40000 ALTER TABLE `form_elements` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `frozen_assets`
--

DROP TABLE IF EXISTS `frozen_assets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `frozen_assets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `credits` int(11) DEFAULT NULL,
  `amount` decimal(8,2) DEFAULT '0.00',
  `frozen_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_frozen_assets_on_shop_id` (`shop_id`),
  KEY `index_frozen_assets_on_branch_id` (`branch_id`),
  KEY `index_frozen_assets_on_order_id` (`order_id`),
  KEY `index_frozen_assets_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `frozen_assets`
--

LOCK TABLES `frozen_assets` WRITE;
/*!40000 ALTER TABLE `frozen_assets` DISABLE KEYS */;
/*!40000 ALTER TABLE `frozen_assets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `guests`
--

DROP TABLE IF EXISTS `guests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `guests` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(191) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `encrypted_password` varchar(191) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `reset_password_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_sign_in_ip` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_guests_on_email` (`email`),
  UNIQUE KEY `index_guests_on_reset_password_token` (`reset_password_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `guests`
--

LOCK TABLES `guests` WRITE;
/*!40000 ALTER TABLE `guests` DISABLE KEYS */;
/*!40000 ALTER TABLE `guests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `impressions`
--

DROP TABLE IF EXISTS `impressions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `impressions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `impressionable_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `impressionable_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `controller_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `action_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `view_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `request_hash` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `ip_address` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `session_hash` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `message` text COLLATE utf8_unicode_ci,
  `referrer` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `impressionable_type_message_index` (`impressionable_type`,`message`(191),`impressionable_id`),
  KEY `poly_request_index` (`impressionable_type`,`impressionable_id`,`request_hash`),
  KEY `poly_ip_index` (`impressionable_type`,`impressionable_id`,`ip_address`),
  KEY `poly_session_index` (`impressionable_type`,`impressionable_id`,`session_hash`),
  KEY `controlleraction_request_index` (`controller_name`,`action_name`,`request_hash`),
  KEY `controlleraction_ip_index` (`controller_name`,`action_name`,`ip_address`),
  KEY `controlleraction_session_index` (`controller_name`,`action_name`,`session_hash`),
  KEY `index_impressions_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `impressions`
--

LOCK TABLES `impressions` WRITE;
/*!40000 ALTER TABLE `impressions` DISABLE KEYS */;
/*!40000 ALTER TABLE `impressions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `line_items`
--

DROP TABLE IF EXISTS `line_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `line_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `cart_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `quantity` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_line_items_on_cart_id` (`cart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `line_items`
--

LOCK TABLES `line_items` WRITE;
/*!40000 ALTER TABLE `line_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `line_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_settings`
--

DROP TABLE IF EXISTS `mail_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `enable_mail` tinyint(1) DEFAULT '0',
  `delivery_method` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'smtp',
  `address` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `port` int(11) DEFAULT '25',
  `domain` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `user_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `password` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `authentication` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'login',
  `enable_starttls_auto` tinyint(1) DEFAULT '0',
  `reply_to` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `use_system_setting` tinyint(1) DEFAULT '1',
  `notify_shop_manager` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_settings`
--

LOCK TABLES `mail_settings` WRITE;
/*!40000 ALTER TABLE `mail_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `materials`
--

DROP TABLE IF EXISTS `materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `materials` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `msg_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `material_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `title` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `music_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hq_music_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_materials_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `materials`
--

LOCK TABLES `materials` WRITE;
/*!40000 ALTER TABLE `materials` DISABLE KEYS */;
/*!40000 ALTER TABLE `materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus`
--

DROP TABLE IF EXISTS `menus`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menus` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `event_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_menu_id` int(11) DEFAULT NULL,
  `menu_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `event_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `keyword` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `material_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_menus_on_shop_id` (`shop_id`),
  KEY `index_menus_on_material_id` (`material_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus`
--

LOCK TABLES `menus` WRITE;
/*!40000 ALTER TABLE `menus` DISABLE KEYS */;
/*!40000 ALTER TABLE `menus` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `menus_system_configs`
--

DROP TABLE IF EXISTS `menus_system_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `menus_system_configs` (
  `menu_id` int(11) NOT NULL,
  `system_config_id` int(11) NOT NULL,
  UNIQUE KEY `menu_id` (`menu_id`,`system_config_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `menus_system_configs`
--

LOCK TABLES `menus_system_configs` WRITE;
/*!40000 ALTER TABLE `menus_system_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `menus_system_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_threads`
--

DROP TABLE IF EXISTS `message_threads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `message_threads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `last_update_time` datetime DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_message_threads_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_threads`
--

LOCK TABLES `message_threads` WRITE;
/*!40000 ALTER TABLE `message_threads` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_threads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `msg_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `to_user_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `from_user_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `create_time` int(11) DEFAULT NULL,
  `msg_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `pic_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `location_x` decimal(10,0) DEFAULT NULL,
  `location_y` decimal(10,0) DEFAULT NULL,
  `scale` int(11) DEFAULT NULL,
  `label` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `title` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `event` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `event_key` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `message_thread_id` int(11) DEFAULT NULL,
  `music_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `hq_music_url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_leave_msg` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_messages_on_message_thread_id` (`message_thread_id`),
  KEY `index_messages_on_is_leave_msg` (`is_leave_msg`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mobile_alipays`
--

DROP TABLE IF EXISTS `mobile_alipays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mobile_alipays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pid` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pkey` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `email` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_mobile_alipay` tinyint(1) DEFAULT '0',
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mobile_alipays_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mobile_alipays`
--

LOCK TABLES `mobile_alipays` WRITE;
/*!40000 ALTER TABLE `mobile_alipays` DISABLE KEYS */;
/*!40000 ALTER TABLE `mobile_alipays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `order_items`
--

DROP TABLE IF EXISTS `order_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `order_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `quantity` int(11) DEFAULT '0',
  `product_unit` varchar(191) COLLATE utf8_unicode_ci DEFAULT '份',
  `product_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_order_items_on_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `order_items`
--

LOCK TABLES `order_items` WRITE;
/*!40000 ALTER TABLE `order_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `order_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `orders`
--

DROP TABLE IF EXISTS `orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `address` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `note` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `amount` decimal(8,2) DEFAULT NULL,
  `delivery_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `state` int(11) DEFAULT '1',
  `user_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `credits` int(11) DEFAULT '0',
  `order_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'delivery',
  `guest_num` int(11) DEFAULT NULL,
  `desk_no` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `arrive_time` datetime DEFAULT NULL,
  `pay_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `consume_credit` int(11) DEFAULT '0',
  `consume_wallet` decimal(8,2) DEFAULT '0.00',
  `cash_amount` decimal(8,2) DEFAULT '0.00',
  `angel_id` int(11) DEFAULT NULL,
  `type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `delivery_zone_id` int(11) DEFAULT NULL,
  `is_paid` tinyint(1) DEFAULT '0',
  `nonce_str` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_remind_date` datetime DEFAULT NULL,
  `delivery_period` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_orders_on_shop_id` (`shop_id`),
  KEY `index_orders_on_state` (`state`),
  KEY `index_orders_on_user_id` (`user_id`),
  KEY `index_orders_on_branch_id` (`branch_id`),
  KEY `index_orders_on_angel_id` (`angel_id`),
  KEY `index_orders_on_delivery_zone_id` (`delivery_zone_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `orders`
--

LOCK TABLES `orders` WRITE;
/*!40000 ALTER TABLE `orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_thread_labels`
--

DROP TABLE IF EXISTS `post_thread_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_thread_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_thread_labels`
--

LOCK TABLES `post_thread_labels` WRITE;
/*!40000 ALTER TABLE `post_thread_labels` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_thread_labels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_thread_labels_threads`
--

DROP TABLE IF EXISTS `post_thread_labels_threads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_thread_labels_threads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_thread_id` int(11) DEFAULT NULL,
  `post_thread_label_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_thread_labels_threads`
--

LOCK TABLES `post_thread_labels_threads` WRITE;
/*!40000 ALTER TABLE `post_thread_labels_threads` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_thread_labels_threads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `post_threads`
--

DROP TABLE IF EXISTS `post_threads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `post_threads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `last_requestd_at` datetime DEFAULT NULL,
  `requested_times` int(11) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `workflow_state` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `is_published` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_post_threads_on_account_id` (`account_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `post_threads`
--

LOCK TABLES `post_threads` WRITE;
/*!40000 ALTER TABLE `post_threads` DISABLE KEYS */;
/*!40000 ALTER TABLE `post_threads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `posts`
--

DROP TABLE IF EXISTS `posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `content` text COLLATE utf8_unicode_ci,
  `account_id` int(11) DEFAULT NULL,
  `post_thread_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_posts_on_account_id` (`account_id`),
  KEY `index_posts_on_post_thread_id` (`post_thread_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `posts`
--

LOCK TABLES `posts` WRITE;
/*!40000 ALTER TABLE `posts` DISABLE KEYS */;
/*!40000 ALTER TABLE `posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `printers`
--

DROP TABLE IF EXISTS `printers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `printers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `memberCode` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `deviceNo` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `apiKey` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `print_on_order` tinyint(1) DEFAULT '1',
  `branch_id` int(11) DEFAULT NULL,
  `copy_count` int(11) DEFAULT '1',
  `phone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `printer_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `printers`
--

LOCK TABLES `printers` WRITE;
/*!40000 ALTER TABLE `printers` DISABLE KEYS */;
/*!40000 ALTER TABLE `printers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_sliders`
--

DROP TABLE IF EXISTS `product_sliders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_sliders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `img` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `desc` text COLLATE utf8_unicode_ci,
  `branch_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT NULL,
  `product_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_product_sliders_on_branch_id` (`branch_id`),
  KEY `index_product_sliders_on_product_id` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_sliders`
--

LOCK TABLES `product_sliders` WRITE;
/*!40000 ALTER TABLE `product_sliders` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_sliders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `product_units`
--

DROP TABLE IF EXISTS `product_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `product_units` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `product_units`
--

LOCK TABLES `product_units` WRITE;
/*!40000 ALTER TABLE `product_units` DISABLE KEYS */;
/*!40000 ALTER TABLE `product_units` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products`
--

DROP TABLE IF EXISTS `products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `price` decimal(8,2) DEFAULT '0.00',
  `stock` int(11) DEFAULT '1000',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `tag_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `product_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'NORMAL',
  `pic` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `position` int(11) DEFAULT '1',
  `product_unit` varchar(191) COLLATE utf8_unicode_ci DEFAULT '份',
  `deleted_at` datetime DEFAULT NULL,
  `credit_times` decimal(8,2) DEFAULT '1.00',
  `down` tinyint(1) NOT NULL DEFAULT '0',
  `choice` tinyint(1) NOT NULL DEFAULT '0',
  `choice_position` int(11) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_products_on_shop_id` (`shop_id`),
  KEY `index_products_on_branch_id` (`branch_id`),
  KEY `index_products_on_pic` (`pic`),
  KEY `index_products_on_choice` (`choice`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products`
--

LOCK TABLES `products` WRITE;
/*!40000 ALTER TABLE `products` DISABLE KEYS */;
/*!40000 ALTER TABLE `products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `products_subjects`
--

DROP TABLE IF EXISTS `products_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `products_subjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `subject_id` int(11) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_products_subjects_on_product_id` (`product_id`),
  KEY `index_products_subjects_on_subject_id` (`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `products_subjects`
--

LOCK TABLES `products_subjects` WRITE;
/*!40000 ALTER TABLE `products_subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `products_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotion_configs`
--

DROP TABLE IF EXISTS `promotion_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotion_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `promotion_id` int(11) DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `key` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `config_value_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `config_value_b` tinyint(1) DEFAULT NULL,
  `config_value_i` int(11) DEFAULT NULL,
  `config_value_str` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `config_value_d` decimal(10,0) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_promotion_configs_on_promotion_id` (`promotion_id`),
  KEY `index_promotion_configs_on_key` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotion_configs`
--

LOCK TABLES `promotion_configs` WRITE;
/*!40000 ALTER TABLE `promotion_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotion_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotion_details`
--

DROP TABLE IF EXISTS `promotion_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotion_details` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `product_id` int(11) DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `promotion_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotion_details`
--

LOCK TABLES `promotion_details` WRITE;
/*!40000 ALTER TABLE `promotion_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotion_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotion_logs`
--

DROP TABLE IF EXISTS `promotion_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotion_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `article_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `sharer` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `browser` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `sharer_nickname` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `browser_nickname` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_promotion_logs_on_article_id` (`article_id`),
  KEY `index_promotion_logs_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotion_logs`
--

LOCK TABLES `promotion_logs` WRITE;
/*!40000 ALTER TABLE `promotion_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotion_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promotions`
--

DROP TABLE IF EXISTS `promotions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `promotions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL,
  `key` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_promotions_on_key` (`key`),
  KEY `index_promotions_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promotions`
--

LOCK TABLES `promotions` WRITE;
/*!40000 ALTER TABLE `promotions` DISABLE KEYS */;
/*!40000 ALTER TABLE `promotions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `push_regs`
--

DROP TABLE IF EXISTS `push_regs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `push_regs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `registration_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `binder_id` int(11) DEFAULT NULL,
  `binder_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_push_regs_on_binder_id_and_binder_type` (`binder_id`,`binder_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `push_regs`
--

LOCK TABLES `push_regs` WRITE;
/*!40000 ALTER TABLE `push_regs` DISABLE KEYS */;
/*!40000 ALTER TABLE `push_regs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `author` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `content` text COLLATE utf8_unicode_ci,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_reports_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `resource_id` int(11) DEFAULT NULL,
  `resource_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_roles_on_name` (`name`),
  KEY `index_roles_on_name_and_resource_type_and_resource_id` (`name`,`resource_type`,`resource_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'boss',NULL,NULL,'2014-05-24 15:34:25','2014-05-24 15:34:25');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `scrachpads`
--

DROP TABLE IF EXISTS `scrachpads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `scrachpads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_result` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `valid_before` datetime DEFAULT NULL,
  `user_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_used` tinyint(1) DEFAULT '0',
  `is_opened` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `used_time` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_scrachpads_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `scrachpads`
--

LOCK TABLES `scrachpads` WRITE;
/*!40000 ALTER TABLE `scrachpads` DISABLE KEYS */;
/*!40000 ALTER TABLE `scrachpads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_periods`
--

DROP TABLE IF EXISTS `service_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_periods` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `branch_id` int(11) DEFAULT NULL,
  `service_period_start` time DEFAULT NULL,
  `service_period_end` time DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_service_periods_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_periods`
--

LOCK TABLES `service_periods` WRITE;
/*!40000 ALTER TABLE `service_periods` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_periods` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_products`
--

DROP TABLE IF EXISTS `service_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_products` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `quantity` int(11) DEFAULT '1',
  `description` text COLLATE utf8_unicode_ci,
  `position` int(11) DEFAULT '1',
  `product_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `available_shop_versions` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_products`
--

LOCK TABLES `service_products` WRITE;
/*!40000 ALTER TABLE `service_products` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_products` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `service_sale_orders`
--

DROP TABLE IF EXISTS `service_sale_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `service_sale_orders` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subject` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `out_trade_no` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `price` decimal(8,2) DEFAULT NULL,
  `quantity` int(11) DEFAULT NULL,
  `discount` decimal(10,0) DEFAULT NULL,
  `workflow_state` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `service_product_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_service_sale_orders_on_shop_id` (`shop_id`),
  KEY `index_service_sale_orders_on_service_product_id` (`service_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `service_sale_orders`
--

LOCK TABLES `service_sale_orders` WRITE;
/*!40000 ALTER TABLE `service_sale_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `service_sale_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `session_id` varchar(191) COLLATE utf8_unicode_ci NOT NULL,
  `data` text COLLATE utf8_unicode_ci,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_sessions_on_session_id` (`session_id`),
  KEY `index_sessions_on_updated_at` (`updated_at`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
INSERT INTO `sessions` VALUES (2,'660d956d76fbb139b7346149e7a8d89d','BAh7CEkiCmZsYXNoBjoGRVR7B0kiDGRpc2NhcmQGOwBUWwBJIgxmbGFzaGVz\nBjsAVHsGSSILbm90aWNlBjsARkkiEueZu+W9leaIkOWKny4GOwBUSSIcd2Fy\nZGVuLnVzZXIuYWNjb3VudC5rZXkGOwBUWwdbBmkGSSIiJDJhJDEwJGNkNUpa\nTkM3UEVZd0F5ekpVY1RldWUGOwBUSSIQX2NzcmZfdG9rZW4GOwBGSSIxNTZR\nSGYvVEREQlB6ZFY5am5LdjRrMFVSQ01uUmp0SWZxOFFvdVRJZVMxYz0GOwBG\n','2014-05-24 15:34:42','2014-05-24 15:34:42');
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `shops`
--

DROP TABLE IF EXISTS `shops`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shops` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `slug` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `is_open` tinyint(1) DEFAULT '1',
  `expiration_time` datetime DEFAULT NULL,
  `orders_count` int(11) DEFAULT '0',
  `income` decimal(10,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `telephone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `accounts_count` int(11) DEFAULT '0',
  `users_count` int(11) DEFAULT '0',
  `introduction` text COLLATE utf8_unicode_ci,
  `max_branches_count` int(11) DEFAULT '1',
  `image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_credits` tinyint(1) DEFAULT '1',
  `money_for_each_credit` decimal(8,2) DEFAULT '1.00',
  `default_reply_content_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'news',
  `charge_method` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'by_time',
  `left_order_count` int(11) DEFAULT '0',
  `welcome_msg` text COLLATE utf8_unicode_ci,
  `use_sms` tinyint(1) DEFAULT '0',
  `max_sms_count` int(11) DEFAULT '0',
  `use_sms_validation` tinyint(1) DEFAULT '0',
  `sms_msgs_count` int(11) DEFAULT '0',
  `max_validation_code_times_in_day` int(11) DEFAULT '5',
  `credits_given` int(11) DEFAULT '0',
  `credits_consume` int(11) DEFAULT '0',
  `support_credits_pay` tinyint(1) DEFAULT NULL,
  `credit_for_each_money` int(11) DEFAULT '1',
  `wallet_given` decimal(8,2) DEFAULT '0.00',
  `wallet_consume` decimal(8,2) DEFAULT '0.00',
  `support_wallet_pay` tinyint(1) DEFAULT NULL,
  `enable_new_version` tinyint(1) DEFAULT '1',
  `hide_support_company` tinyint(1) DEFAULT '0',
  `award_credits_at_follow` tinyint(1) DEFAULT '0',
  `award_credits` int(11) DEFAULT '0',
  `max_branch_sliders` int(11) DEFAULT '1',
  `branch_comments_count` int(11) DEFAULT '0',
  `least_promotion_number` int(11) DEFAULT NULL,
  `workflow_state` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `qrcode` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `subdomain` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `product_image_limit` int(11) DEFAULT '5',
  `product_slider_limit` int(11) DEFAULT '1',
  `support_auto_buy_service` tinyint(1) DEFAULT '0',
  `support_link_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `support_link` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `domain` varchar(191) COLLATE utf8_unicode_ci NOT NULL DEFAULT '',
  `validated_domain` tinyint(1) NOT NULL DEFAULT '0',
  `copy_right_footer` text COLLATE utf8_unicode_ci,
  `enable_foreign_currency` tinyint(1) DEFAULT '0',
  `foreign_currency_symbol` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `reply_num_of_orders` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `aid` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `enable_unrecognized_reply_message` tinyint(1) DEFAULT '1',
  `show_detail_for_branch` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_shops_on_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `shops`
--

LOCK TABLES `shops` WRITE;
/*!40000 ALTER TABLE `shops` DISABLE KEYS */;
INSERT INTO `shops` VALUES (1,'admin','admin',1,'2014-05-31 15:34:24',0,0.00,'2014-05-24 15:34:24','2014-05-24 15:34:25','13800138000',1,0,NULL,1,NULL,1,1.00,'news','by_time',0,NULL,0,0,0,0,5,0,0,NULL,1,0.00,0.00,NULL,0,0,0,0,1,0,NULL,'trial',NULL,NULL,5,1,0,NULL,NULL,'',0,NULL,0,NULL,NULL,NULL,1,0);
/*!40000 ALTER TABLE `shops` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `site_configs`
--

DROP TABLE IF EXISTS `site_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `site_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `key` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `display_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value_s` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `value_b` tinyint(1) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `site_configs`
--

LOCK TABLES `site_configs` WRITE;
/*!40000 ALTER TABLE `site_configs` DISABLE KEYS */;
INSERT INTO `site_configs` VALUES (1,'title','站点名称','string','融商',NULL,'2014-05-24 15:32:20','2014-05-24 15:32:20'),(2,'support_company','技术支持','string','拓单宝',NULL,'2014-05-24 15:32:50','2014-05-24 15:32:50'),(3,'weixin_help_msg','帮助消息','string','以下是本微信公众账号的使用说明:\n回复0:获得使用帮助\n回复1:获得点餐链接\n回复2:获得当前的促销活动\n回复3:获得最近历史订单\n回复4:查询我的会员信息\n点击+发送位置:获得最近的商铺\n留言请发送\'@+留言内容\'',NULL,'2014-05-24 15:33:02','2014-05-24 15:33:02');
/*!40000 ALTER TABLE `site_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sms_msgs`
--

DROP TABLE IF EXISTS `sms_msgs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sms_msgs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `to` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sms_message_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `date_created` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `msg_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `user_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `order_msg_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'order',
  `sms_msg_owner_id` int(11) DEFAULT NULL,
  `sms_msg_owner_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sms_msgs_on_to` (`to`),
  KEY `index_sms_msgs_on_sms_message_id` (`sms_message_id`),
  KEY `index_sms_msgs_on_date_created` (`date_created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sms_msgs`
--

LOCK TABLES `sms_msgs` WRITE;
/*!40000 ALTER TABLE `sms_msgs` DISABLE KEYS */;
/*!40000 ALTER TABLE `sms_msgs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subjects`
--

DROP TABLE IF EXISTS `subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subjects` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `sale` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `start_time` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `show_image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `image` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subjects`
--

LOCK TABLES `subjects` WRITE;
/*!40000 ALTER TABLE `subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_configs`
--

DROP TABLE IF EXISTS `system_configs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_configs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `url` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `appId` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `appSecret` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `my_fake_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `gonghao_type` tinyint(1) DEFAULT NULL,
  `public_account_name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `be_verified` tinyint(1) DEFAULT '0',
  `support_weixin_pay` tinyint(1) DEFAULT '0',
  `paySignKey` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `partnerId` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `partnerKey` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `access_token` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `last_update_access_token_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_system_configs_on_shop_id` (`shop_id`),
  KEY `index_system_configs_on_my_fake_id` (`my_fake_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_configs`
--

LOCK TABLES `system_configs` WRITE;
/*!40000 ALTER TABLE `system_configs` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_configs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tags_on_shop_id` (`shop_id`),
  KEY `index_tags_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tenpays`
--

DROP TABLE IF EXISTS `tenpays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tenpays` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) DEFAULT NULL,
  `pid` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `pkey` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `use_tenpay` tinyint(1) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tenpays_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tenpays`
--

LOCK TABLES `tenpays` WRITE;
/*!40000 ALTER TABLE `tenpays` DISABLE KEYS */;
/*!40000 ALTER TABLE `tenpays` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `themes`
--

DROP TABLE IF EXISTS `themes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `themes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `background_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `text_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_bg_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `header_text_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `navbar_bg_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `navbar_text_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `menu_bg_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `menu_text_color` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `theme_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT 'theme_system',
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_themes_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `themes`
--

LOCK TABLES `themes` WRITE;
/*!40000 ALTER TABLE `themes` DISABLE KEYS */;
/*!40000 ALTER TABLE `themes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trade_rels`
--

DROP TABLE IF EXISTS `trade_rels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trade_rels` (
  `user_id` int(11) NOT NULL,
  `branch_id` int(11) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  KEY `index_trade_rels_on_user_id` (`user_id`),
  KEY `index_trade_rels_on_branch_id` (`branch_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trade_rels`
--

LOCK TABLES `trade_rels` WRITE;
/*!40000 ALTER TABLE `trade_rels` DISABLE KEYS */;
/*!40000 ALTER TABLE `trade_rels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `trades`
--

DROP TABLE IF EXISTS `trades`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `trades` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `trade_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `trade_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `query` text COLLATE utf8_unicode_ci,
  `body` text COLLATE utf8_unicode_ci,
  `partner` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `total_fee` decimal(10,0) DEFAULT NULL,
  `out_trade_no` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `trades`
--

LOCK TABLES `trades` WRITE;
/*!40000 ALTER TABLE `trades` DISABLE KEYS */;
/*!40000 ALTER TABLE `trades` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transaction_logs`
--

DROP TABLE IF EXISTS `transaction_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transaction_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text COLLATE utf8_unicode_ci,
  `buyer_email` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `service_sale_order_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transaction_logs_on_shop_id` (`shop_id`),
  KEY `index_transaction_logs_on_service_sale_order_id` (`service_sale_order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transaction_logs`
--

LOCK TABLES `transaction_logs` WRITE;
/*!40000 ALTER TABLE `transaction_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `transaction_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `validated_phones`
--

DROP TABLE IF EXISTS `validated_phones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `validated_phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `phone_owner_id` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_validated_phones_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `validated_phones`
--

LOCK TABLES `validated_phones` WRITE;
/*!40000 ALTER TABLE `validated_phones` DISABLE KEYS */;
/*!40000 ALTER TABLE `validated_phones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `validation_codes`
--

DROP TABLE IF EXISTS `validation_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `validation_codes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `code_owner_id` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_validation_codes_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `validation_codes`
--

LOCK TABLES `validation_codes` WRITE;
/*!40000 ALTER TABLE `validation_codes` DISABLE KEYS */;
/*!40000 ALTER TABLE `validation_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `vip_levels`
--

DROP TABLE IF EXISTS `vip_levels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vip_levels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `shop_id` int(11) DEFAULT NULL,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `discount` decimal(4,2) DEFAULT '1.00',
  `base_users_count` int(11) DEFAULT '0',
  `integer` int(11) DEFAULT '0',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `auto_upgrade` tinyint(1) DEFAULT '0',
  `min_total_amount` decimal(8,2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_vip_levels_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `vip_levels`
--

LOCK TABLES `vip_levels` WRITE;
/*!40000 ALTER TABLE `vip_levels` DISABLE KEYS */;
/*!40000 ALTER TABLE `vip_levels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `wallet_logs`
--

DROP TABLE IF EXISTS `wallet_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `wallet_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `wallet_log_owner_id` int(11) NOT NULL DEFAULT '0',
  `shop_id` int(11) DEFAULT NULL,
  `branch_id` int(11) DEFAULT NULL,
  `wallet_log_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `money` decimal(8,2) DEFAULT NULL,
  `account_id` int(11) DEFAULT NULL,
  `note` text COLLATE utf8_unicode_ci,
  `shop_wallet_given_after` decimal(8,2) DEFAULT '0.00',
  `shop_wallet_consume_after` decimal(8,2) DEFAULT '0.00',
  `branch_wallet_given_after` decimal(8,2) DEFAULT '0.00',
  `branch_wallet_consume_after` decimal(8,2) DEFAULT '0.00',
  `user_wallet_balance_after` decimal(8,2) DEFAULT '0.00',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `order_id` int(11) DEFAULT NULL,
  `recharge_log_id` int(11) DEFAULT NULL,
  `angel_id` int(11) DEFAULT NULL,
  `wallet_log_owner_type` varchar(191) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'User',
  PRIMARY KEY (`id`),
  KEY `index_wallet_logs_on_shop_id` (`shop_id`),
  KEY `index_wallet_logs_on_branch_id` (`branch_id`),
  KEY `index_wallet_logs_on_account_id` (`account_id`),
  KEY `index_wallet_logs_on_order_id` (`order_id`),
  KEY `index_wallet_logs_on_angel_id` (`angel_id`),
  KEY `index_wallet_logs_on_owner_id` (`wallet_log_owner_id`),
  KEY `index_wallet_logs_on_wallet_log_owner_type` (`wallet_log_owner_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `wallet_logs`
--

LOCK TABLES `wallet_logs` WRITE;
/*!40000 ALTER TABLE `wallet_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `wallet_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weixinpay_feedbacks`
--

DROP TABLE IF EXISTS `weixinpay_feedbacks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weixinpay_feedbacks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `feedback_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `openid` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `appid` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `trade_id` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `body` text COLLATE utf8_unicode_ci,
  `msg_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weixinpay_feedbacks`
--

LOCK TABLES `weixinpay_feedbacks` WRITE;
/*!40000 ALTER TABLE `weixinpay_feedbacks` DISABLE KEYS */;
/*!40000 ALTER TABLE `weixinpay_feedbacks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `weixinpay_warnings`
--

DROP TABLE IF EXISTS `weixinpay_warnings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `weixinpay_warnings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `error_type` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `appId` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `description` text COLLATE utf8_unicode_ci,
  `alarm_content` text COLLATE utf8_unicode_ci,
  `body` text COLLATE utf8_unicode_ci,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `weixinpay_warnings`
--

LOCK TABLES `weixinpay_warnings` WRITE;
/*!40000 ALTER TABLE `weixinpay_warnings` DISABLE KEYS */;
/*!40000 ALTER TABLE `weixinpay_warnings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `zones`
--

DROP TABLE IF EXISTS `zones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(191) COLLATE utf8_unicode_ci DEFAULT NULL,
  `parent_zone_id` int(11) DEFAULT NULL,
  `shop_id` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_zones_on_parent_zone_id` (`parent_zone_id`),
  KEY `index_zones_on_shop_id` (`shop_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `zones`
--

LOCK TABLES `zones` WRITE;
/*!40000 ALTER TABLE `zones` DISABLE KEYS */;
/*!40000 ALTER TABLE `zones` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2014-05-24 23:48:22
