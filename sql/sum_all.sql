/*
 Navicat Premium Dump SQL

 Source Server         : billSum
 Source Server Type    : MySQL
 Source Server Version : 90600 (9.6.0)
 Source Host           : localhost:23306
 Source Schema         : sum_all

 Target Server Type    : MySQL
 Target Server Version : 90600 (9.6.0)
 File Encoding         : 65001

 Date: 03/07/2026 11:18:39
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for logs_name
-- ----------------------------
DROP TABLE IF EXISTS `logs_name`;
CREATE TABLE `logs_name`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `create_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间-自动填充',
  `tbn` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '表名',
  `stn` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '站点名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 166 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '日志生成记录' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of logs_name
-- ----------------------------
INSERT INTO `logs_name` VALUES (105, '2026-05-29 17:29:55', 'logs20260101_20260430', 'ai');
INSERT INTO `logs_name` VALUES (106, '2026-05-29 17:48:41', 'logs20260101_20260430', 'wzg');
INSERT INTO `logs_name` VALUES (107, '2026-05-29 17:54:44', 'logs20260101_20260430', 'digitalcloud');
INSERT INTO `logs_name` VALUES (108, '2026-05-29 18:23:37', 'logs20260101_20260430', 'qn');
INSERT INTO `logs_name` VALUES (109, '2026-05-29 18:58:48', 'logs20260101_20260430', 'wzg');
INSERT INTO `logs_name` VALUES (110, '2026-05-30 00:22:42', 'logs20260101_20260430', 'ai');
INSERT INTO `logs_name` VALUES (111, '2026-05-30 01:56:56', 'logs20260101_20260430', 'ai');
INSERT INTO `logs_name` VALUES (112, '2026-05-30 04:40:25', 'logs20260101_20260430', 'csp');
INSERT INTO `logs_name` VALUES (113, '2026-05-30 08:38:27', 'logs20260101_20260430', 'pinova');
INSERT INTO `logs_name` VALUES (114, '2026-05-30 10:10:44', 'logs20260529_20260529', 'qn');
INSERT INTO `logs_name` VALUES (115, '2026-05-30 10:18:18', 'logs20260501_20260515', 'qn');
INSERT INTO `logs_name` VALUES (116, '2026-05-30 10:20:49', 'logs20260501_20260521', 'qn');
INSERT INTO `logs_name` VALUES (117, '2026-05-30 10:30:39', 'logs20260503_20260510', 'qn');
INSERT INTO `logs_name` VALUES (118, '2026-05-30 11:14:35', 'logs20260501_20260529', 'digitalcloud');
INSERT INTO `logs_name` VALUES (119, '2026-05-30 11:22:13', 'logs20260501_20260529', 'ai');
INSERT INTO `logs_name` VALUES (120, '2026-05-30 11:41:57', 'logs20260501_20260529', 'csp');
INSERT INTO `logs_name` VALUES (121, '2026-05-30 12:03:19', 'logs20260501_20260529', 'qn');
INSERT INTO `logs_name` VALUES (122, '2026-05-30 12:04:48', 'logs20260501_20260529', 'wzg');
INSERT INTO `logs_name` VALUES (123, '2026-05-30 12:18:24', 'logs20260501_20260529', 'pinova');
INSERT INTO `logs_name` VALUES (124, '2026-05-31 11:50:08', 'logs202605', 'digitalcloud');
INSERT INTO `logs_name` VALUES (125, '2026-05-31 16:27:01', 'logs202605', 'digitalcloud');
INSERT INTO `logs_name` VALUES (126, '2026-05-31 16:28:10', 'logs202605', 'qn');
INSERT INTO `logs_name` VALUES (127, '2026-05-31 16:29:37', 'logs202605', 'wzg');
INSERT INTO `logs_name` VALUES (128, '2026-05-31 16:40:16', 'logs202605', 'ai');
INSERT INTO `logs_name` VALUES (129, '2026-05-31 17:01:21', 'logs202605', 'csp');
INSERT INTO `logs_name` VALUES (130, '2026-05-31 17:29:31', 'logs202605', 'pinova');
INSERT INTO `logs_name` VALUES (131, '2026-06-01 16:23:02', 'logs202606', 'wzg');
INSERT INTO `logs_name` VALUES (132, '2026-06-01 16:23:41', 'logs202606', 'qn');
INSERT INTO `logs_name` VALUES (133, '2026-06-01 16:56:57', 'logs202605', 'ai');
INSERT INTO `logs_name` VALUES (134, '2026-06-01 17:27:13', 'logs202606', 'ai');
INSERT INTO `logs_name` VALUES (135, '2026-06-03 14:47:36', 'logs202606', 'qn');
INSERT INTO `logs_name` VALUES (136, '2026-06-09 02:22:49', 'logs202606', 'pinova');
INSERT INTO `logs_name` VALUES (137, '2026-06-09 02:27:52', 'logs20260601_20260608', 'pinova');
INSERT INTO `logs_name` VALUES (138, '2026-06-09 02:34:56', 'logs20260601_20260608', 'csp');
INSERT INTO `logs_name` VALUES (139, '2026-06-09 06:20:23', 'logs202605', 'wzg');
INSERT INTO `logs_name` VALUES (140, '2026-06-09 07:55:33', 'logs202605', 'wzg');
INSERT INTO `logs_name` VALUES (141, '2026-06-11 07:44:01', 'logs20260601_20260610', 'pinova');
INSERT INTO `logs_name` VALUES (142, '2026-06-11 09:32:54', 'logs20260601_20260611', 'pinova');
INSERT INTO `logs_name` VALUES (143, '2026-06-11 10:01:59', 'logs20260601_20260610', 'pinova');
INSERT INTO `logs_name` VALUES (144, '2026-06-12 03:48:53', 'logs202606', 'wzg');
INSERT INTO `logs_name` VALUES (145, '2026-06-22 06:45:31', 'logs20260601_20260622', 'pinova');
INSERT INTO `logs_name` VALUES (146, '2026-06-22 06:48:03', 'logs20260601_20260622', 'pinova');
INSERT INTO `logs_name` VALUES (147, '2026-06-23 07:48:58', 'logs20260601_20260620', 'pinova');
INSERT INTO `logs_name` VALUES (148, '2026-06-23 07:53:43', 'logs20260601_20260623', 'pinova');
INSERT INTO `logs_name` VALUES (149, '2026-06-23 10:00:16', 'logs202606', 'pinova');
INSERT INTO `logs_name` VALUES (150, '2026-06-24 06:51:12', 'logs20260601_20260624', 'pinova');
INSERT INTO `logs_name` VALUES (151, '2026-06-25 14:24:57', 'logs202606', 'qn');
INSERT INTO `logs_name` VALUES (152, '2026-06-29 08:39:10', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (153, '2026-06-29 08:46:31', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (154, '2026-06-29 08:50:01', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (155, '2026-06-29 08:51:06', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (156, '2026-06-29 08:51:57', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (157, '2026-06-30 07:53:41', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (158, '2026-06-30 08:23:51', 'logs20260601_20260629', 'pinova');
INSERT INTO `logs_name` VALUES (159, '2026-06-30 16:25:59', 'logs202606', 'ai');
INSERT INTO `logs_name` VALUES (160, '2026-06-30 16:40:16', 'logs202606', 'digitalcloud');
INSERT INTO `logs_name` VALUES (161, '2026-06-30 16:41:05', 'logs202606', 'qn');
INSERT INTO `logs_name` VALUES (162, '2026-06-30 16:44:57', 'logs202606', 'csp');
INSERT INTO `logs_name` VALUES (163, '2026-06-30 17:07:43', 'logs202606', 'pinova');
INSERT INTO `logs_name` VALUES (164, '2026-07-02 03:18:39', 'logs202606', 'wzg');
INSERT INTO `logs_name` VALUES (165, '2026-07-02 07:14:47', 'logs202606', 'wshk');

-- ----------------------------
-- Table structure for model_price_official
-- ----------------------------
DROP TABLE IF EXISTS `model_price_official`;
CREATE TABLE `model_price_official`  (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `status` int NULL DEFAULT 1,
  `currency` int NULL DEFAULT 1,
  `price_level` bigint NULL DEFAULT 0,
  `model_name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `model_label` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `model_type` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `remark` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '',
  `prompt_price` decimal(10, 6) NULL DEFAULT NULL,
  `completion_price` decimal(10, 6) NULL DEFAULT NULL,
  `cache_price` decimal(10, 6) NULL DEFAULT NULL,
  `cache_creation_price` decimal(10, 6) NULL DEFAULT NULL,
  `cache_creation_5M_price` decimal(10, 6) NULL DEFAULT NULL,
  `prompt_price_level` decimal(10, 6) NULL DEFAULT NULL,
  `completion_price_level` decimal(10, 6) NULL DEFAULT NULL,
  `cache_price_level` decimal(10, 6) NULL DEFAULT NULL,
  `cache_creation_price_level` decimal(10, 6) NULL DEFAULT NULL,
  `cache_creation_5M_price_level` decimal(10, 6) NULL DEFAULT NULL,
  PRIMARY KEY (`id` DESC) USING BTREE,
  INDEX `model_price_official_idx_id`(`id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of model_price_official
-- ----------------------------
INSERT INTO `model_price_official` VALUES (6, 1, 0, 2000, 'glm-5', 'glm 5', 'glm', '', 4.000000, 18.000000, 1.000000, 0.000000, 0.000000, 6.000000, 22.000000, 1.500000, 0.000000, 0.000000);
INSERT INTO `model_price_official` VALUES (5, 1, 0, 2000, 'glm-5.1', 'glm 5.1', 'glm', '', 6.000000, 24.000000, 1.300000, 0.000000, 0.000000, 8.000000, 28.000000, 2.000000, 0.000000, 0.000000);
INSERT INTO `model_price_official` VALUES (4, 1, 1, 200000, 'gemini-3.1-pro-preview', 'Gemini 3 Pro 预览版', 'Gemini', '创建缓存5M以小时为单位，即12个5M开始计费', 2.000000, 12.000000, 0.200000, 0.000000, 0.375000, 4.000000, 18.000000, 0.400000, 0.000000, 0.375000);
INSERT INTO `model_price_official` VALUES (3, 1, 1, 0, 'claude-haiku-4-5', 'Claude Haiku 4.5', 'claude', '', 1.000000, 5.000000, 0.100000, 2.000000, 1.250000, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `model_price_official` VALUES (2, 1, 1, 0, 'claude-sonnet-4-6', 'Claude Sonnet 4.6', 'claude', '', 3.000000, 15.000000, 0.300000, 6.000000, 3.750000, NULL, NULL, NULL, NULL, NULL);
INSERT INTO `model_price_official` VALUES (1, 1, 1, 0, 'claude-opus-4-6', 'Claude Opus 4.6', 'claude', '', 5.000000, 25.000000, 0.500000, 10.000000, 6.250000, NULL, NULL, NULL, NULL, NULL);

-- ----------------------------
-- Table structure for site_dbn
-- ----------------------------
DROP TABLE IF EXISTS `site_dbn`;
CREATE TABLE `site_dbn`  (
  `id` bigint NOT NULL AUTO_INCREMENT COMMENT '自增ID',
  `name` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '站点名',
  `url` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '站点地址',
  `dbn` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '数据库名',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '渠道数据库' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of site_dbn
-- ----------------------------
INSERT INTO `site_dbn` VALUES (1, 'pinova', 'https://pinova.ai', 'sum_pinova');
INSERT INTO `site_dbn` VALUES (2, 'ai', 'https://ai.burncloud.com', 'sum_ai');
INSERT INTO `site_dbn` VALUES (3, 'csp', 'https://csp.burncloud.com', 'sum_csp');
INSERT INTO `site_dbn` VALUES (4, '旺掌柜', 'http://llm.wangzhanggui.com:8080', 'sum_wzg');
INSERT INTO `site_dbn` VALUES (5, '七牛', 'http://120.26.136.61:8080', 'sum_qn');
INSERT INTO `site_dbn` VALUES (6, 'digitalcloud', 'https://www.digitalcloud.asia', 'sum_digitalcloud');
INSERT INTO `site_dbn` VALUES (7, 'wshk', 'https://wshk.burncloud.com', 'sum_wshk');

SET FOREIGN_KEY_CHECKS = 1;
