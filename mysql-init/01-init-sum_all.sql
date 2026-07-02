--
-- BillSumExt MySQL initialization script
-- Creates the system database `sum_all` with its tables and seed data.
--

CREATE DATABASE IF NOT EXISTS `sum_all` CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `sum_all`;

-- -----------------------------------------------------------
-- Table: logs_name — register imported log table names per site
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `logs_name` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间-自动填充',
  `tbn` varchar(80) DEFAULT NULL COMMENT '表名',
  `stn` varchar(80) DEFAULT NULL COMMENT '站点名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='日志生成记录';

INSERT INTO `logs_name` (`id`, `create_at`, `tbn`, `stn`) VALUES
(105,'2026-05-29 17:29:55','logs20260101_20260430','ai'),
(106,'2026-05-29 17:48:41','logs20260101_20260430','wzg'),
(107,'2026-05-29 17:54:44','logs20260101_20260430','digitalcloud'),
(108,'2026-05-29 18:23:37','logs20260101_20260430','qn'),
(109,'2026-05-29 18:58:48','logs20260101_20260430','wzg'),
(110,'2026-05-30 00:22:42','logs20260101_20260430','ai'),
(111,'2026-05-30 01:56:56','logs20260101_20260430','ai'),
(112,'2026-05-30 04:40:25','logs20260101_20260430','csp'),
(113,'2026-05-30 08:38:27','logs20260101_20260430','pinova'),
(114,'2026-05-30 10:10:44','logs20260529_20260529','qn'),
(115,'2026-05-30 10:18:18','logs20260501_20260515','qn'),
(116,'2026-05-30 10:20:49','logs20260501_20260521','qn'),
(117,'2026-05-30 10:30:39','logs20260503_20260510','qn'),
(118,'2026-05-30 11:14:35','logs20260501_20260529','digitalcloud'),
(119,'2026-05-30 11:22:13','logs20260501_20260529','ai'),
(120,'2026-05-30 11:41:57','logs20260501_20260529','csp'),
(121,'2026-05-30 12:03:19','logs20260501_20260529','qn'),
(122,'2026-05-30 12:04:48','logs20260501_20260529','wzg'),
(123,'2026-05-30 12:18:24','logs20260501_20260529','pinova'),
(124,'2026-05-31 11:50:08','logs202605','digitalcloud'),
(125,'2026-05-31 16:27:01','logs202605','digitalcloud'),
(126,'2026-05-31 16:28:10','logs202605','qn'),
(127,'2026-05-31 16:29:37','logs202605','wzg'),
(128,'2026-05-31 16:40:16','logs202605','ai'),
(129,'2026-05-31 17:01:21','logs202605','csp'),
(130,'2026-05-31 17:29:31','logs202605','pinova'),
(131,'2026-06-01 16:23:02','logs202606','wzg'),
(132,'2026-06-01 16:23:41','logs202606','qn'),
(133,'2026-06-01 16:56:57','logs202605','ai'),
(134,'2026-06-01 17:27:13','logs202606','ai'),
(135,'2026-06-03 14:47:36','logs202606','qn'),
(136,'2026-06-09 02:22:49','logs202606','pinova'),
(137,'2026-06-09 02:27:52','logs20260601_20260608','pinova'),
(138,'2026-06-09 02:34:56','logs20260601_20260608','csp'),
(139,'2026-06-09 06:20:23','logs202605','wzg'),
(140,'2026-06-09 07:55:33','logs202605','wzg'),
(141,'2026-06-11 07:44:01','logs20260601_20260610','pinova'),
(142,'2026-06-11 09:32:54','logs20260601_20260611','pinova'),
(143,'2026-06-11 10:01:59','logs20260601_20260610','pinova'),
(144,'2026-06-12 03:48:53','logs202606','wzg'),
(145,'2026-06-22 06:45:31','logs20260601_20260622','pinova'),
(146,'2026-06-22 06:48:03','logs20260601_20260622','pinova'),
(147,'2026-06-23 07:48:58','logs20260601_20260620','pinova'),
(148,'2026-06-23 07:53:43','logs20260601_20260623','pinova'),
(149,'2026-06-23 10:00:16','logs202606','pinova'),
(150,'2026-06-24 06:51:12','logs20260601_20260624','pinova'),
(151,'2026-06-25 14:24:57','logs202606','qn'),
(152,'2026-06-29 08:39:10','logs20260601_20260629','pinova'),
(153,'2026-06-29 08:46:31','logs20260601_20260629','pinova'),
(154,'2026-06-29 08:50:01','logs20260601_20260629','pinova'),
(155,'2026-06-29 08:51:06','logs20260601_20260629','pinova'),
(156,'2026-06-29 08:51:57','logs20260601_20260629','pinova'),
(157,'2026-06-30 07:53:41','logs20260601_20260629','pinova'),
(158,'2026-06-30 08:23:51','logs20260601_20260629','pinova'),
(159,'2026-06-30 16:25:59','logs202606','ai'),
(160,'2026-06-30 16:40:16','logs202606','digitalcloud'),
(161,'2026-06-30 16:41:05','logs202606','qn'),
(162,'2026-06-30 16:44:57','logs202606','csp'),
(163,'2026-06-30 17:07:43','logs202606','pinova'),
(164,'2026-07-02 03:18:39','logs202606','wzg'),
(165,'2026-07-02 07:14:47','logs202606','wshk');

-- -----------------------------------------------------------
-- Table: site_dbn — upstream site registry (database mapping)
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `site_dbn` (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `name` varchar(80) DEFAULT NULL COMMENT '站点名',
  `url` varchar(200) DEFAULT NULL COMMENT '站点地址',
  `dbn` varchar(80) DEFAULT NULL COMMENT '数据库名',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='渠道数据库';

INSERT INTO `site_dbn` (`id`, `name`, `url`, `dbn`) VALUES
(1,'pinova','https://pinova.ai','sum_pinova'),
(2,'ai','https://ai.burncloud.com','sum_ai'),
(3,'csp','https://csp.burncloud.com','sum_csp'),
(4,'旺掌柜','http://llm.wangzhanggui.com:8080','sum_wzg'),
(5,'七牛','http://120.26.136.61:8080','sum_qn'),
(6,'digitalcloud','https://www.digitalcloud.asia','sum_digitalcloud'),
(7,'wshk','https://wshk.burncloud.com','sum_wshk');

-- -----------------------------------------------------------
-- Table: model_price_official — official model pricing table
-- -----------------------------------------------------------
CREATE TABLE IF NOT EXISTS `model_price_official` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` int DEFAULT '1',
  `currency` int DEFAULT '1',
  `price_level` bigint DEFAULT '0',
  `model_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `model_label` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `model_type` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `remark` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `prompt_price` decimal(10,6) DEFAULT NULL,
  `completion_price` decimal(10,6) DEFAULT NULL,
  `cache_price` decimal(10,6) DEFAULT NULL,
  `cache_creation_price` decimal(10,6) DEFAULT NULL,
  `cache_creation_5M_price` decimal(10,6) DEFAULT NULL,
  `prompt_price_level` decimal(10,6) DEFAULT NULL,
  `completion_price_level` decimal(10,6) DEFAULT NULL,
  `cache_price_level` decimal(10,6) DEFAULT NULL,
  `cache_creation_price_level` decimal(10,6) DEFAULT NULL,
  `cache_creation_5M_price_level` decimal(10,6) DEFAULT NULL,
  PRIMARY KEY (`id` DESC),
  KEY `model_price_official_idx_id` (`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci ROW_FORMAT=DYNAMIC;

INSERT INTO `model_price_official` (`id`, `status`, `currency`, `price_level`, `model_name`, `model_label`, `model_type`, `remark`, `prompt_price`, `completion_price`, `cache_price`, `cache_creation_price`, `cache_creation_5M_price`, `prompt_price_level`, `completion_price_level`, `cache_price_level`, `cache_creation_price_level`, `cache_creation_5M_price_level`) VALUES
(6,1,0,2000,'glm-5','glm 5','glm','',4.000000,18.000000,1.000000,0.000000,0.000000,6.000000,22.000000,1.500000,0.000000,0.000000),
(5,1,0,2000,'glm-5.1','glm 5.1','glm','',6.000000,24.000000,1.300000,0.000000,0.000000,8.000000,28.000000,2.000000,0.000000,0.000000),
(4,1,1,200000,'gemini-3.1-pro-preview','Gemini 3 Pro 预览版','Gemini','创建缓存5M以小时为单位，即12个5M开始计费',2.000000,12.000000,0.200000,0.000000,0.375000,4.000000,18.000000,0.400000,0.000000,0.375000),
(3,1,1,0,'claude-haiku-4-5','Claude Haiku 4.5','claude','',1.000000,5.000000,0.100000,2.000000,1.250000,NULL,NULL,NULL,NULL,NULL),
(2,1,1,0,'claude-sonnet-4-6','Claude Sonnet 4.6','claude','',3.000000,15.000000,0.300000,6.000000,3.750000,NULL,NULL,NULL,NULL,NULL),
(1,1,1,0,'claude-opus-4-6','Claude Opus 4.6','claude','',5.000000,25.000000,0.500000,10.000000,6.250000,NULL,NULL,NULL,NULL,NULL);
