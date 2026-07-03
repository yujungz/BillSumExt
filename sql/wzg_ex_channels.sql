/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.6-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: test-mysql8    Database: sum_wzg
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
  `name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '渠道名称',
  `buyer` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '采购员',
  `supplier` varchar(80) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL COMMENT '供应商',
  `discount_orig` double DEFAULT NULL,
  `discount` double DEFAULT NULL COMMENT '折扣',
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
(1,'gemini@fang@0.4￥','奔云','fang',0.056,0.056),
(2,'gemini@pinova@1￥','奔云','pinova',0.15,0.15),
(3,'gemini-2.5-flash@chengfeng@0.0195￥-image-3-preview-0.1￥@0.6￥/刀梁哥','梁哥','chengfeng',0.09,0.09),
(4,'gemini@KFC@zhang的令牌 01-20@0.048￥/张@0.2￥/刀','陈威','KFC',0.028,0.028),
(5,'gemini@fang@0.25￥','奔云','fang',0.036,0.036),
(9,'gemini@GPTNB.AI@gemini-45@0.35￥/刀','梁哥','GPTNB',0.05,0.05),
(10,'qwen@ChatfireAPI@0.17折','梁哥','Chatfire',0.17,0.17),
(11,'doubao@豆包-5折-视频@api.chatfire.cn@5折','陈威','Chatfire',0.5,0.5),
(12,'sora@chatfireapi@0.15￥/条@0.7￥/刀','陈威','Chatfire',0.1,0.1),
(13,'KFC@gemini-0.45￥/刀@0.108￥/张@0.45￥/刀','陈威','KFC',0.065,0.065),
(14,'gemini@zeta_gemini-for-llm-wangzhanggui@1￥','奔云','zeta',0.15,0.15),
(15,'gemini@poloai-gemini-llm-wangzhanggui@1￥','奔云','poloai',0.15,0.15),
(16,'gemini@pinova-gemini-219-wangzong-1.5折@1￥','奔云','pinova',0.15,0.15),
(18,'KFC@gemini-0.7￥/刀@0.168￥/张@0.7￥/刀','陈威','KFC',0.1,0.1),
(19,'gemini@GPTNB.AI@gemini-25@0.25￥/刀','梁哥','GPTNB',0.036,0.036),
(20,'gemini@GPTNB.AI@gemini-25@0.25￥/刀','梁哥','GPTNB',0.036,0.036),
(22,'gemini@pinova-gemini-219-wangzong-1.5折@4K@1￥','奔云','pinova',0.15,0.15),
(24,'KFC@gemini-0.45￥/刀@4k@0.108￥/张@0.45￥/刀','陈威','KFC',0.065,0.065),
(25,'gemini@KFC@zhang的令牌 01-20@4k@0.048￥/张@0.2￥/刀','陈威','KFC',0.028,0.028),
(29,'geimini@KFC@zhang的令牌 01-20@4K@0.048￥/张@0.2￥/刀','陈威','KFC',0.028,0.028),
(30,'gemini@xgapi.top_gemini@4k@0.1￥/张','梁哥','xgapi',0.1,0.1),
(31,'gemini@庄老板_gpt.315432151.xyz@0.7￥','奔云','庄老板',0.1,0.1),
(32,'gemini@庄老板_gpt.315432151.xyz@4k@0.7￥/刀','奔云','庄老板',0.1,0.1),
(33,'gemini@当乐-gemini@0.1￥/张','陈威','Chatfire',0.1,0.1),
(34,'gemini@当乐-gemini@4k@0.1￥/张','陈威','Chatfire',0.1,0.1),
(35,'gemini@xgapi.top_gemini@0.1￥/张','梁哥','xgapi',0.1,0.1),
(37,'gemini@四智@0.1￥/张','梁哥','四智',0.1,0.1),
(38,'gemini@四智@4K@0.1￥/张','梁哥','四智',0.1,0.1),
(39,'gemini@梁云龙@0.09￥/张@0.67￥/刀','奔云','梁云龙',0.1,0.1),
(40,'gemini@梁云龙@0.09/张@4K@0.67￥/刀','奔云','梁云龙',0.1,0.1),
(41,'gemini@四智@4K@0.1￥/张','梁哥','四智',0.1,0.1),
(42,'gemini@四智@0.1￥/张','梁哥','四智',0.1,0.1),
(43,'gemini@庄老板_gpt.315432151.xyz@0.7￥/刀','奔云','庄老板',0.1,0.1),
(44,'gemini@chengfeng@0.1￥/张@0.6￥/刀梁哥','梁哥','chengfeng',0.09,0.09),
(45,'gemini@KFC@gemini-vertey-wending 0.7@0.7￥/刀','陈威','KFC',0.1,0.1),
(47,'gemini@庄老板_gpt.315432151.xyz@0.7￥','奔云','庄老板',0.1,0.1),
(48,'gemini@gala@gemini_0.7@0.7￥','奔云','gala',0.1,0.1),
(49,'gemini@庄老板_gpt.315432151.xyz@0.7￥','奔云','庄老板',0.1,0.1),
(50,'kimi-k2.5@ChatfireAPI@4折','陈威','Chatfire',0.4,0.4),
(52,'sora2@kfc@视频@0.08条@1￥/刀--标1倍倍率','陈威','KFC',0.15,0.15),
(54,'gemini@zeta_gemini-for-llm-wangzhanggui@1￥','奔云','zeta',0.15,0.15),
(55,'gemini@gala@gemini_0.7@0.7￥','奔云','gala',0.1,0.1),
(57,'gemini@梁云龙@0.09￥/张@0.67￥/刀','奔云','梁云龙',0.1,0.1),
(58,'gemini@xgapi.top_gemini@0.03￥/张','梁哥','xgapi',0.1,0.1),
(59,'gemini@GPTNB.AI@gemini@0http://api-b64.one-ai.top:300@0.8一刀梁哥','梁哥','GPTNB',0.115,0.115),
(60,'gemini@当乐-gemini@0.03￥/张','陈威','Chatfire',0.1,0.1),
(61,'KFC@gemini2.5 *0.5@0.02￥/张@0.5￥/刀','陈威','KFC',0.072,0.072),
(62,'KFC@gemini 2.5@0.02￥/张@0.48￥/刀','陈威','KFC',0.072,0.072),
(64,'gemini@poloai-gemini-llm-wangzhanggui@0.014￥/张','奔云','poloai',0.1,0.1),
(66,'gemini@poloai-gemini-llm-wangzhanggui@0.014￥/张_复制','奔云','poloai',0.1,0.1),
(67,'gemini@api.aabao.vip@0.024￥/张 -直连1','陈威','阿宝',0.15,0.15),
(70,'gemini@yinli.ai@chenwei-gemini@0.6￥/刀','梁哥','yinli',0.09,0.09),
(71,'gemini@api.aabao.vip_Gemini直连-2@0.2￥/刀','陈威','阿宝',0.028,0.028),
(73,'gemini@yinli.ai@chenwei-gemini@0.01￥/张','梁哥','yinli',0.1,0.1),
(74,'gemini@api.aabao.vip@0.6￥/刀- 直连1','陈威','阿宝',0.09,0.09),
(75,'seedance-1-5-pro@api.n1n.ai@1元一刀','陈威','阿宝',0.15,0.15),
(76,'gemini@pinova-taotao@1￥','奔云','pinova',0.15,0.15),
(79,'gemini@pinova@1￥','奔云','pinova',0.15,0.15),
(80,'glm-5@ai.burncloud.com@4折','奔云','burncloud',0.4,0.4),
(81,'gemini@xgapi.top_gemini@0.03￥/张 1￥/刀','梁哥','xgapi',0.15,0.15),
(83,'gemini@fang@1￥/刀','奔云','fang',0.15,0.15),
(85,'gemini@api.aabao.vip_Gemini直连-3@0.8￥/刀','陈威','阿宝',0.15,0.15),
(86,'gemini@api.aabao.vip_Gemini直连-3@0.8￥/刀','陈威','阿宝',0.12,0.12),
(87,'doubao','陈威','tiktok',0.35,0.35),
(88,'gemini@haLaoBan-YangMao@1.5折','奔云','halaoban',0.15,0.15),
(89,'gemini@xgapi.top_gemini@0.03￥/张 1￥/刀梁哥','梁哥','xgapi',0.15,0.15),
(91,'gemini@poloai-gemini-llm-wangzhanggui@1￥','奔云','poloai',0.15,0.15),
(92,'gemini@halaobao@1.5折4K计费（专用）','奔云','poloai',0.15,0.15),
(93,'gemini@poloai.top@画图@1倍率','奔云','poloai',0.15,0.15),
(94,'grok@yunwu.ai@grok@llm.wangzhanggui.com@1元/刀','奔云','yunwu',0.15,0.15),
(95,'kimi-k2.5@当乐糯@chenwei@4折','陈威','Chatfire',0.4,0.4),
(96,'gemini@fang@0.8￥','奔云','fang',0.12,0.12),
(97,'gemini-T3@chengfeng@http:69.164.253.106:8818@0.75一刀梁哥','梁哥','chengfeng',0.12,0.12),
(98,'gpt@当乐糯@陈威@1折多','陈威','Chatfire',0.1,0.1),
(99,'claude @当乐@陈威@1折多','陈威','Chatfire',0.1,0.1),
(100,'gemini@当乐@陈威@0.16张','陈威','Chatfire',0.15,0.15),
(101,'claude@xgapi@https://api.xgapi.top@1元一刀','梁哥','xgapi',0.15,0.15),
(104,'gpt@gptnb@http://api-b64.one-ai.top:3001@1元一刀','梁哥','GPTNB',0.15,0.15),
(105,'gpt@https://4sapi.com@梁哥/@1.5元1刀直连','梁哥','4sapi',0.2,0.2),
(106,'grok@https://www.swiftapi.top@梁哥-蛋哥@2.5元一刀官转','梁哥','swiftapi',0.35,0.35),
(107,'王总-中通服-3.5折 kimi-k2.5','梁哥','中通服',0.35,0.35),
(108,'王总-中通服-3.5折 minimax','梁哥','中通服',0.35,0.35),
(109,'王总-中通服-3.5折qwen','梁哥','中通服',0.35,0.35),
(110,'引力api@陈威@gemin@0.9折','gemin','陈威',0.09,0.09),
(111,'mnapi@陈威@banana pro2@0.15次','陈威','banana pro2',0.15,0.15),
(112,'mnapi@陈威@gemini-3-flash-preview@0.8刀','陈威','XX',0.12,0.12),
(113,'云api@new.yunai.lin@0.6折','奔云','yunai',0.06,0.06),
(114,'gemini@http://api-b64.one-ai.top:3001/@gpenb@1元一刀梁哥','gpenb','one-ai',0.14,0.14),
(116,'ds2@api.xgapi.top@sdance2-fast-15s@梁哥@3.5折','梁哥','xgapi',0.35,0.35),
(117,'gemini@aigc.x-see.cn@粤小七@0.5元一刀@梁哥','梁哥','x-see',0.07,0.07),
(118,'gemini@aigc.x-see.cn@粤小七7@0.7一刀@梁哥','梁哥','x-see',0.1,0.1),
(119,'gemini@69.164.253.106:8818@chengfeng0.6一刀@梁哥','奔云','XX',0.09,0.09),
(120,'gemini@/69.164.253.106:8818@chengfeng@1元一刀梁哥','梁哥','chengfeng',0.14,0.14),
(121,'claude@api.xgapi.top@xgapi@0.5元一刀梁哥','梁哥','xgapi',0.07,0.07),
(123,'ds2@opengw.com@doubao-seedance-2.0@黄老板@110%','黄老板','opengw',1.1,1.1),
(124,'阿宝@陈威@gpt-5.4@3.8元一刀','陈威','gpt-5',0.55,0.55),
(125,'当乐@陈威@gemini-3.1-flash-image-preview@0.16张','陈威','gemini-3',0.15,0.15),
(126,'引力@陈威@gemini@0.149一张','陈威','149一张',0.15,0.15),
(127,'kfc@陈威@gemini@0.8一刀@0.192张','奔云','陈威',0.12,0.12),
(128,'gemini@api-b64.one-ai.top:3001@gptnb@1.5元一刀@梁哥','梁哥','one-ai',0.22,0.22),
(129,'阿宝@陈威@sd2@1倍','sd2','陈威',1,1),
(130,'gpt@api.xgapi.to@xgapi@1元一刀梁哥','梁哥','xgapi',0.14,0.14),
(131,'gpt-image@https://s.lconai.com@智创@1.5元一刀@梁哥','梁哥','lconai',0.22,0.22),
(132,'claude@69.164.253.106:8818@chengfeng@0.4一刀@梁哥','梁哥','chengfeng',0.06,0.06),
(133,'claude@七牛@default@4.5折','七牛','default',0.45,0.45),
(134,'sora2@http://69.164.253.106:8818/@chengfeng@梁哥@1元一次','梁哥','253',0.15,0.15),
(135,'骉云@陈威@sd2.0@1倍','陈威','sd2',1,1),
(136,'ds2@gemini-api.cn@doubao-seedance-2.0@峰哥0.35/s','奔云','doubao-seedance-2',0.15,0.15),
(137,'默默火山@陈威@sd2@95折','sd2','陈威',9.5,9.5),
(138,'ds2@aicloud.fzyinghe.com@doubao-seedance-2.0@陈威95折','奔云','fzyinghe',9.5,9.5),
(139,'智能平台demo-千问','奔云','XX',0.15,0.15),
(140,'智能平台demo-豆包','奔云','XX',0.15,0.15),
(141,'gemini@七牛@gemini@4.5折','七牛','XX',0.45,0.45),
(142,'gemini@aigc.x-see.cn@粤小七@1一刀','粤小七','x-see',0.14,0.14),
(143,'阿宝高刷站@陈威@gemini-3.1-pro-preview@1.8元1刀','陈威','gemini-3',0.14,0.14),
(144,'阿顺@.moxin.studio@gemini-3.1-pro-preview@1.4元一刀','奔云','moxin',0.2,0.2),
(145,'蛋壳@陈威@gemini-3.1-pro-preview@1元1刀','陈威','gemini-3',0.14,0.14),
(146,'gpt-image@moxin.studio@顺@0.09一张','奔云','moxin',0.15,0.15),
(147,'gpt-image@moxin.studio@顺','奔云','moxin',0.15,0.15),
(149,'当乐@陈威@gpt-iamge-2@0.06','陈威','XX',0.01,0.01),
(150,'kfc@陈威@gpt-image-2@0.04张','陈威','04张',0.15,0.15),
(151,'gpt-image-2@api.xgapi.top@xgapi@2元一刀@梁哥','梁哥','xgapi',0.29,0.29),
(152,'gpt-image-2@万量引擎@3元一刀@梁哥','万量引擎','XX',0.43,0.43),
(153,'gpt-image-2@api.suyu.io@速语@3元一刀号池@梁哥','号池','suyu',0.43,0.43),
(154,'gpt-image-2@智创@0.125一张','智创','125一张',0.15,0.15),
(155,'cc','奔云','XX',0.15,0.15),
(156,'gpt-image-2@grsai@0.13一张@梁哥','奔云','grsai',0.15,0.15),
(157,'gpt-image@llm.wangzhanggui.com:8000@api.wuyinkeji.com@0.1元/张','奔云','wangzhanggui',1,1),
(159,'gemini@llm.wangzhanggui.com:8000@api.wuyinkeji.com@0.1元/张','奔云','wangzhanggui',1,1),
(160,'引力@陈威@香蕉2按量@0.06一张','香蕉2按量','陈威',0.15,0.15),
(161,'gpt-image-2@s顺@0.12一张@https://api.tu-zi.com','奔云','s顺',0.15,0.15),
(162,'gemini@智创@1元一刀@梁哥','智创','XX',0.14,0.14),
(163,'移动豆包','奔云','XX',0.15,0.15);
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

-- Dump completed on 2026-07-03  3:03:45
