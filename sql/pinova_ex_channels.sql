/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.6-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: test-mysql8    Database: sum_pinova
-- ------------------------------------------------------
-- Server version	9.6.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*M!100616 SET @OLD_NOTE_VERBOSITY=@@NOTE_VERBOSITY, NOTE_VERBOSITY=0 */;

--
-- Table structure for table `ex_channels`
--

DROP TABLE IF EXISTS `ex_channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ex_channels` (
  `id` int NOT NULL,
  `name` varchar(160) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道名称',
  `buyer` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购员',
  `supplier` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商',
  `discount_orig` double DEFAULT NULL,
  `discount` double DEFAULT NULL COMMENT '应用折扣',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `ex_channels_idx_channel_id` (`id`),
  KEY `ex_channels_idx_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ex_channels`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ex_channels` WRITE;
/*!40000 ALTER TABLE `ex_channels` DISABLE KEYS */;
INSERT INTO `ex_channels` VALUES
(1,'20.81.200.199-azure','奔云','XX',0.15,0.15),
(2,'35.196.164.92-vertex-T1','奔云','XX',0.15,0.15),
(3,'34.67.237.149-gemini','奔云','XX',0.15,0.15),
(4,'34.28.84.219-gemini','奔云','XX',0.15,0.15),
(5,'20.57.20.74-azure','奔云','XX',0.15,0.15),
(6,'20.57.20.74-aws','奔云','XX',0.15,0.15),
(7,'20.81.200.199-azure-sora','奔云','XX',0.15,0.15),
(9,'20.55.246.89-azure-sora','奔云','XX',0.15,0.15),
(10,'20.55.246.89-anthropic','奔云','XX',0.15,0.15),
(12,'20.55.246.89-gemini-T3','奔云','XX',0.15,0.15),
(14,'veo3@pinova','奔云','XX',0.15,0.15),
(15,'20.57.20.74-gemini-T3','奔云','XX',0.15,0.15),
(16,'34.60.89.226-vertex-T1','奔云','XX',0.15,0.15),
(17,'20.81.200.199-aws','奔云','XX',0.15,0.15),
(18,'34.170.227.119-vertex-T1','奔云','XX',0.15,0.15),
(19,'34.63.136.70-vertex-T3','奔云','XX',0.15,0.15),
(20,'20.81.200.199-aws_openai','奔云','XX',0.15,0.15),
(21,'35.188.219.30-azure','奔云','XX',0.15,0.15),
(22,'35.188.219.30-azure-sora','奔云','XX',0.15,0.15),
(23,'35.188.219.30-aws','奔云','XX',0.15,0.15),
(24,'34.68.153.110-azure','奔云','XX',0.15,0.15),
(25,'34.68.153.110-azure-sora','奔云','XX',0.15,0.15),
(26,'34.28.84.219-aws','奔云','XX',0.15,0.15),
(27,'claude@poloai.top@2.2元/刀','奔云','poloai',2.2,0.32),
(28,'gpt@polo@gpt-vip@3.5元/刀','奔云','poloai',3.5,0.51),
(29,'gemini@wzg@pinova@gemini@2折','旺掌柜','burncloud',0.2,0.2),
(30,'gemini@zeta@gemini-for-pinova@gemini-for-pinova@2元/刀','奔云','zeta',2,0.29),
(31,'gpt@zeta@gpt-pinova@1.4元/刀','奔云','zeta',1.4,0.2),
(32,'gemini@zeta@gemini-for-pinova-sp@gemini-for-pinova@1元/刀','奔云','zeta',1,0.14),
(33,'20.186.53.11-aws','奔云','zeta',0.14,0.14),
(34,'claude@yunwu.ai@2.8元/刀','奔云','yunwu',2.8,0.41),
(35,'claude@api.xgapi.top@2.2一刀梁哥','梁哥','xgapi',2.2,0.32),
(36,'gemini@api.xgapi.top@1元一刀梁哥','梁哥','xgapi',1,0.14),
(37,'gemini@poloaip@1.5倍','奔云','poloai',1.5,0.22),
(38,'gemini@poloapi@2倍','奔云','poloai',2,0.29),
(39,'test-136.112.115.177-gemini-T3','奔云','XX',0.15,0.15),
(44,'gpt@wzg@pinova@2折','旺掌柜','burncloud',0.2,0.2),
(46,'gemini@gptnb@http://api-b64.one-ai.top:3001@0.8一刀@梁哥','梁哥','gptnb',0.8,0.12),
(47,'gemini@gptnb@http://api-b64.one-ai.top:3001@1.2元一刀梁哥','梁哥','gptnb',1.2,0.17),
(48,'gemini@https://4sapi.com/console@4sapi@2元一刀梁哥','梁哥','4sapi',2,0.29),
(49,'claude@api.xgapi.top@xgapi@2.2元一刀@梁哥','梁哥','xgapi',2.2,0.32),
(50,'claude@dataeyes.ai@4.7折','奔云','dataeyes',0.47,0.47),
(51,'gpt@https://4sapi.com@4sapi@1.5元一刀@梁哥','梁哥','4sapi',1.5,0.22),
(52,'claude@api.chatfire.ai@当乐@陈威@2.6一刀','陈威','chatfire',2.6,0.38),
(54,'claude@api.chatfire.ai@当乐@陈威@2.6一刀','陈威','chatfire',2.6,0.38),
(55,'claude@api-b64.one-ai.top:3001@gptnb@2.3元一刀梁哥','梁哥','gptnb',2.3,0.33),
(56,'claude@dataeyes.ai@4.7折','奔云','dataeyes',0.47,0.47),
(57,'claude@opengw.com@5.5折','奔云','opengw',0.55,0.55),
(60,'aws claude@阿宝@陈威@3一刀','陈威','阿宝',3,0.43),
(61,'	aws claude@阿宝@陈威@2.6一刀','陈威','阿宝',2.6,0.38),
(62,'gemini@api-b64.one-ai.top:300@gptnb@1.5元一刀@梁哥','梁哥','one-ai',0.22,0.22),
(63,'gemini@69.164.253.106:8818@chengfeng@1.5元一刀@梁哥','梁哥','chengfeng',0.22,0.22),
(64,'gpt@sunzong@gpt@0.5元/刀','奔云','sunzong',0.07,0.07),
(65,'claude@poloai.top@2.2元/刀','奔云','poloai',0.32,0.32),
(66,'gpt@api.xgapi.top@xgapi@一元一刀梁哥','梁哥','xgapi',0.14,0.14),
(67,'gpt-image@s.lconai.com@智创@0.1张@梁哥','梁哥','智创',0.15,0.15),
(68,'当乐@陈威@claude@官转@3.2一刀','陈威','当乐',0.46,0.46),
(69,'gpt-image@n.lconai.com@智创01一次@梁哥','梁哥','智创',0.15,0.15),
(70,'gemini@aigc.x-see.cn@粤小七@1元一刀@梁哥','梁哥','粤小七',0.14,0.14),
(72,'claude@https://api.ikuncode.cc@2.7元一刀@鸡哥@梁哥','梁哥','鸡哥',0.39,0.39),
(73,'gpt-image@api.ikuncode.cc@autust@鸡哥@0.06一次@梁哥','梁哥','鸡哥',0.15,0.15),
(74,'gpt-image@aigc.x-see.cn@粤小七@0.07一次@梁哥','梁哥','粤小七',0.15,0.15),
(75,'阿宝@陈威@gpt-imagen-2@3.5一刀','陈威','阿宝',0.51,0.51),
(76,'kfc@陈威@gpt-iamge-2@0.04张','陈威','KFC',0.15,0.15),
(77,'claude@七牛@claude.pinva@4.5折--禁止启用','七牛','claude',0.45,0.45),
(78,'阿宝@陈威@claude@3.6一刀@5.2折','陈威','阿宝',0.52,0.52),
(79,'gpt-image@otuapi.com@章鱼@0.06一次@梁哥','梁哥','章鱼',0.15,0.15),
(80,'aws claude@当乐@陈威@3一刀 @4.4折','陈威','当乐',0.44,0.44),
(82,'claude@awsclaude.gagawenai@heny@6折@梁哥','梁哥','heny',0.6,0.6),
(83,'claude@dataeyes.ai@claude-ws-zhuanyong@7.5折-注意价格','奔云','dataeyes',0.75,0.75),
(84,'claude@七牛@claude.pinva@4.5折_接旺掌柜换模型名称','七牛','claude',0.45,0.45),
(85,'gemini@api-b64.one-ai.top:3001@gptnb@1.8一刀@梁哥','梁哥','one-ai',0.26,0.26),
(86,'deepseek@api.xgapi.top@xgapi@梁哥2.5一刀','奔云','xgapi',0.36,0.36),
(87,'sora@69.164.253.106:8818@chengfeng@梁哥','奔云','chengfeng',0.15,0.15),
(88,'qwen@internal-api.maas.netnic.cn','奔云','netnic',0.15,0.15),
(89,'openrouter-claude@api.ikuncode.cc@claude@鸡哥@2.3元一刀@梁哥','梁哥','ikuncode',0.33,0.33),
(90,'gemini@api.xgapi.top@xgapi@2元一刀@梁哥','梁哥','xgapi',0.29,0.29),
(92,'当乐@陈威@kimi@4折','陈威','XX',0.4,0.4),
(93,'gemini@69.164.253.106:8818@chengfeng@1元一刀@梁哥','梁哥','chengfeng',0.14,0.14),
(94,'claude@tokshub@siqi@4.5折@梁哥','梁哥','tokshub',0.45,0.45),
(96,'kimi@aigc.x-see.cn@粤小七@1元一刀@梁哥','梁哥','x-see',0.14,0.14),
(97,'kfc@陈威@gemini-3.1-pro-preview@0.38刀','陈威','gemini-3',0.05,0.05),
(98,'gemini@gptnb@1元一刀@梁哥','梁哥','gptnb',0.14,0.14),
(99,'kfc@陈威@gemini-3.1-pro-preview@0.65刀','陈威','KFC',0.09,0.09),
(100,'蛋壳@陈威@gemini@0.6一刀','陈威','蛋壳',0.09,0.09),
(101,'kfc@陈威@gemini-3.1-pro-preview@0.55刀','陈威','KFC',0.08,0.08),
(102,'当乐@陈威@gemini-3.1-pro-preview@1元1刀','陈威','当乐',0.14,0.14),
(103,'gemini@vip.123everything.com@顺@0.6一刀','奔云','123everything',0.09,0.09),
(104,'蛋壳@陈威@gemini-3.1-pro-preview@1元1刀','陈威','阿宝',0.14,0.14),
(107,'阿宝@陈威@gemini-3.1-pro-preview@1.8元1刀','陈威','阿宝',0.14,0.14),
(109,'阿宝@陈威@gemini-3.1-pro-preview@1.8刀','陈威','阿宝',0.26,0.26),
(110,'gemini@chengfeng@0.6一刀','奔云','chengfeng',0.09,0.09),
(111,'蛋壳@陈威@gemini@0.8一刀','陈威','蛋壳',0.12,0.12),
(112,'当乐@陈威@gpt-iamge-2@0.06','陈威','当乐',0.01,0.01),
(113,'cladue@tokshub.com@claude@4.5折--钟老板key停用','钟老板','tokshub',0.45,0.45),
(114,'星云@陈威@veo@8折','陈威','星',0.8,0.8),
(115,'claude@sunzong@claude@0.5元/刀','奔云','sunzong',0.07,0.07),
(116,'gpt-image-2@xgapi@2元一刀@梁哥','梁哥','xgapi',0.29,0.29),
(117,'当乐@陈威@gemini-3.1-pro-preview@1.2一刀','陈威','当乐',0.17,0.17),
(118,'sora@chengfeng@梁哥','梁哥','chengfeng',0.15,0.15),
(119,'gpt-image-2@grasai@梁哥@0.13','梁哥','grasai',0.02,0.02),
(120,'cladue@tokshub.com@claude@4.5折','奔云','tokshub',0.45,0.45),
(121,'gpt-5-mini@蛋哥@1元一刀@梁哥','梁哥','蛋哥',0.14,0.14),
(122,'gpt@chengfeng@一元一刀@梁哥','梁哥','chengfeng',0.14,0.14),
(123,'openRouter@5折@梁哥','梁哥','openRouter',0.5,0.5),
(124,'gpt@aigc.x-see.cn@粤小七@1元一刀','粤小七','x-see',0.14,0.14),
(127,'claude@七牛@claude.pinva@4.5折_接wskj香港换模型名称','奔云','七牛',0.45,0.45),
(128,'claude@ai-api-cn.db-kj@顺@5折','顺','ai-api-cn',0.5,0.5),
(129,'claude@dataeyes.ai@5.5折','奔云','dataeyes',0.55,0.55),
(130,'claude@api.xgapi.top@2.6元一刀@梁哥','梁哥','xgapi',0.38,0.38),
(131,'claude@api.xgapi.top@@xgapi2.5元一刀@梁哥','梁哥','xgapi',0.36,0.36),
(132,'claude@poloai.top@2.5元/刀','奔云','poloai',0.36,0.36),
(133,'gemini@69.164.253.106:8818@chengfeng@3元一刀@梁哥','梁哥','chengfeng',0.43,0.43),
(134,'claude@poloai.top@2.5元/刀_复制','奔云','poloai',0.36,0.36),
(135,'aws claude@阿宝@陈威@3元一刀','陈威','阿宝',0.43,0.43),
(136,'claude@api.xgapi@xgapi@2.4元一刀@梁哥','梁哥','xgapi',0.35,0.35),
(137,'gpt@swiftapi.top@蛋哥@0.6一刀@梁哥','梁哥','swiftapi',0.09,0.09),
(139,'claude@api.xgapi.top@xgapi@2.7元一刀@梁哥','梁哥','xgapi',0.39,0.39),
(140,'claude@蛋哥@2.4元一刀@梁哥','梁哥','蛋哥',0.35,0.35),
(141,'Claude@tokenflowsolution@2.9元一刀@顺','顺','tokenflowsolution',0.42,0.42),
(142,'gemini@api.xgapi.top@xgapi@2元一刀官@梁哥','梁哥','xgapi',0.29,0.29),
(143,'claude@api.crazyrouter@4折@顺','顺','crazyrouter',0.4,0.4);
/*!40000 ALTER TABLE `ex_channels` ENABLE KEYS */;
UNLOCK TABLES;
COMMIT;
SET AUTOCOMMIT=@OLD_AUTOCOMMIT;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*M!100616 SET NOTE_VERBOSITY=@OLD_NOTE_VERBOSITY */;

-- Dump completed on 2026-07-03  3:02:58
