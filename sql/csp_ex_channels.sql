/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19-11.8.6-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: test-mysql8    Database: sum_csp
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
  `name` varchar(200) DEFAULT NULL,
  `buyer` varchar(80) DEFAULT NULL,
  `supplier` varchar(80) DEFAULT NULL,
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
(4,'claude@gala@claude_4x@4￥','奔云','gala',NULL,0.578),
(5,'gemini@galaapi@gemini_0.7@0.7￥','奔云','gala',NULL,0.1),
(6,'gpt@galaapi@gpt_0.5@0.5￥','奔云','gala',NULL,0.072),
(11,'qwen@submodel.ai@20%','奔云','submodel',NULL,0.2),
(12,'gpt@19-azure@0.3￥','奔云','shijiu',0.04341534,0.04341534),
(13,'qwen@submodel.ai@20%','奔云','submodel',0,0.2),
(15,'gemini@BeanAi@gemini-0.2￥','奔云','BeanAi',0.02894356,0.02894356),
(16,'claudeCode@Poloapi@csp_claude@0.4￥','奔云','poloai',0.05788712,0.05788712),
(17,'gpt@zeta@ent_azure/sp@1.4','奔云','zeta',0.20260492,0.20260492),
(18,'claude@Tang@ent_claude@2￥','奔云','tang',0.289435601,0.289435601),
(19,'claude@xiaohuMiniApi@','奔云','xiaohu',0,0.1),
(20,'sora@zeta@ent_openai/official@106.8%','奔云','zeta',0,1.068),
(21,'sora@zeta_azure/sp@20%','奔云','zeta',0,0.2),
(22,'veo3@zeta_ent_vertexsp@1.156￥/次','奔云','zeta',NULL,0.167293777),
(23,'claude@19_aws_claude@2.2￥','奔云','shijiu',NULL,0.318379161),
(24,'claude@ai.burncloud.com@50%','奔云','burncloud',0,0.5),
(26,'gemini-3-pro@zeta_aistudio/sp2@3.5折','奔云','zeta',0,0.35),
(27,'claude@Poloapi@csp_claude@1.5￥','奔云','poloai',NULL,0.2170767),
(29,'claude@20.81.200.199:8080','奔云','burncloud',0,0.15),
(30,'claude@74.249.29.91:8080','奔云','burncloud',0,0.15),
(31,'claude@74.249.29.91:8080','奔云','burncloud',0,0.15),
(32,'gemini@36.116.126.210:8080','奔云','burncloud',0,0.15),
(33,'claude@Tang@ent_claude@2￥','奔云','tang',0.289435601,0.289435601),
(34,'gemini@zeta_csp_gemini@aistudio/sp','奔云','zeta',0.20260492,0.20260492),
(35,'gpt-image@jayai.fun@0.08￥/张','奔云','jayai',0.011577424,0.011577424),
(36,'gemini@20.246.88.31-stark@1.4元','奔云','burncloud',0.20260492,0.20260492),
(37,'gemini@fanglaoban@0.2￥','奔云','fanglaoban',0.02894356,0.02894356),
(40,'gemini@API易-CSP-BURNCLOUD@35.196.164.92:8080','奔云','burncloud',0.17366136,0.17366136),
(41,'gemini@HLB-CSP-BURNCLOUD@35.196.164.92:8080','奔云','burncloud',0.17366136,0.17366136),
(42,'gemini@艺术照项目token@35.196.164.92:8080','奔云','burncloud',0,0.15),
(43,'claude@poloapi.top-claude_aws@3.2￥','奔云','poloai',0.463096961,0.463096961),
(44,'gpt@poloapi.top@1.5￥','奔云','poloai',0.2170767,0.2170767),
(45,'gpt@poloai.top@gpt-vip@3.5￥','奔云','poloai',0.506512301,0.506512301),
(46,'sora-2@yunwu.zeabur.app','陈威','zeabur',0,0.6),
(47,'qwen@csp.burncloud.com@小马','奔云','小马',0,0.4),
(48,'gpt@19-gpt-企业组@3.65￥','奔云','shijiu',0.528219971,0.528219971),
(49,'claude@main.burncloud@claude@0.2','奔云','burncloud',0,0.2),
(50,'即梦@poloai.top@1￥','奔云','poloai',0.1447178,0.1447178),
(52,'gemini@main.burncloud@gemini-149@0.2','奔云','burncloud',0,0.2),
(53,'mj@yunwu.zeabur.app@szsm-mj','陈威','zeabur',0,0.15),
(54,'kling@yunwu.zeabur.app@szsm-kling','陈威','zeabur',0,0.2),
(55,'gpt@蛋壳-swiftapi.top@gpt-az-csp','陈威','蛋壳',0,0.2),
(56,'deepseek@小马国内模型@tokenpony.cn','奔云','小马',0,0.4),
(57,'gpt@yunwu.zeabur.app@szsm-gpt','陈威','zeabur',0,0.1),
(58,'sora-2@aabao.vip@burncloud专用@1.2￥','陈威','阿宝',0.17366136,0.17366136),
(59,'gemini@main.burncloud@gemini-219@0.2','奔云','burncloud',0,0.2),
(64,'kling@ztf@7折','奔云','burncloud',0,0.7),
(65,'gemini@fanglaoban@0.4￥','奔云','fanglaoban',0.05788712,0.05788712),
(66,'gpt@yunwu.zeabur.app@csp_gpt','陈威','zeabur',0,0.1),
(68,'gemini@wangzhanggui.com@0.4￥','奔云','旺掌柜',0.05788712,0.05788712),
(69,'gemini@fanglaoban@1.5￥','奔云','fanglaoban',0.2170767,0.2170767),
(70,'genini@45.79.42.181-用户burncloud@ALLf@0.2￥','奔云','burncloud',0.02894356,0.02894356),
(71,'gemini@fanglaoban@64.32.13.138:9001@0.25￥','奔云','fanglaoban',0.03617945,0.03617945),
(73,'gpt@main.burncloud@gpt3折@0.3','奔云','burncloud',0,0.3),
(75,'doubao@api.chatfire.cn_doubao-6折-seedance-2.0@6折','陈威','当乐',0,0.6),
(77,'gemini@halaoban-YangMaoChi@1.5折','奔云','halaoban',0,0.15),
(78,'gpt@poloai.top@xiaomujiang-2aws@gpt-vip@3.5￥','奔云','poloai',0.506512301,0.506512301),
(79,'gpt@zeta@ent_azure/sp@1.4','奔云','zeta',0.20260492,0.20260492),
(80,'claude@poloapi.top-claude_aws@2.2￥/刀','奔云','poloai',0.318379161,0.318379161),
(81,'claude@yunwu.ai@2.8元/刀','奔云','yunwu',0.405209841,0.405209841),
(82,'gpt@yunwu.ai@官方渠道@3￥/刀','奔云','yunwu',0.434153401,0.434153401),
(83,'kimi@api.chatfire.ai@kimi k2.5@4折','陈威','当乐',0,0.4),
(86,'claude@api.xgapi.top@2.2￥一刀@梁哥','梁哥','xgapi',0.318379161,0.318379161),
(87,'claude@ezmodel.cloud@liangyunlong@5-7折','梁云龙','ezmodel.cloud',0,0.55),
(88,'claude@api.xgapi.top@2.2￥_非opus4.6@梁哥','梁哥','xgapi',0.318379161,0.318379161),
(89,'claude@poloapi.top-claude_aws@2.2￥/刀-yang','奔云','poloai',0.318379161,0.318379161),
(90,'cluade@当乐@陈威@2折','陈威','当乐',0,0.2),
(91,'claude@poloapi.top-claude_aws-new@2.2￥/刀-停用','奔云','poloai',0.318379161,0.318379161),
(93,'claude@yunwu.ai@2.8元/刀','奔云','yunwu',0.405209841,0.405209841),
(94,'claude@poloapi.top-claude_aws-new@2.2￥/刀','奔云','poloai',0.318379161,0.318379161),
(95,'claude@poloapi.top-claude_aws-new@2.2￥/刀','奔云','poloai',0.318379161,0.318379161),
(96,'claude@19_aws_claude@2.2￥','奔云','shijiu',0.318379161,0.318379161),
(97,'claude-code@poloapi.top@1.5￥/刀','奔云','poloai',0.2170767,0.2170767),
(98,'claude@ezmodel.cloud@liangyunlong@5-7折','梁云龙','ezmodel.cloud',0,5.5),
(99,'claude@api.xgapi.top@2.2￥梁哥','梁哥','xgapi',0.318379161,0.318379161),
(100,'claude@api.xgapi.top@2.2￥_非opus4.6梁哥','梁哥','xgapi',0.318379161,0.318379161),
(101,'grok@wzg@BC-INNER@2.5元/刀','奔云','旺掌柜',0.361794501,0.361794501),
(102,'claude@poloapi.top-claude_aws@2.2￥/刀','奔云','poloai',0.318379161,0.318379161),
(103,'claude@poloapi.top-claude_aws-new@2.2￥/刀','奔云','poloai',0.318379161,0.318379161),
(107,'\\t王总-中通服-3.5折 kimi-k2.5','梁哥','中通服',0,0.35),
(109,'claude-code@api.xgapi.top@0.5元一刀@梁哥','梁哥','xgapi',0.0723589,0.0723589),
(111,'阿里千问@陈威@3.5折@官方','陈威','阿里',0,0.35),
(112,'gemini@http://69.164.253.106:8818/@chengfeng@0.75一刀梁哥','梁哥','chengfeng',0.10853835,0.10853835),
(113,'gemini@https://api.xgapi.top/@1元一刀梁哥','梁哥','xgapi',0.1447178,0.1447178),
(114,'claude@https://api.xgapi.top/@0.5元一刀梁哥','梁哥','xgapi',0.0723589,0.0723589),
(115,'gpt@https://4sapi.com/@1.5元一刀梁哥','梁哥','4sapi',0.2170767,0.2170767),
(116,'gemini@ai-nebula.com@8折','奔云','ai-nebula',0,0.8),
(117,'gpt@ai-nebula.com@8折','奔云','ai-nebula',0,0.8),
(118,'GLM-5@https://wishub-x6.ctyun.cn/v1@天翼@2.5折','梁哥','ctyun.cn',0,0.25),
(119,'gpt@anyint.ai@5.5折','梁云龙','anyint',0,0.55),
(120,'dell-3@api.chatfire.cn@0.03元/张','陈威','chengfeng',0,0.3),
(121,'gemini@http://69.164.253.106:8818@chengfeng@1.5一刀梁哥','梁哥','chengfeng',0.2170767,0.2170767),
(122,'claude-gpt@https://api.xgapi.top@xgapi@1元一刀@梁哥','梁哥','xgapi',0.1447178,0.1447178),
(123,'gpt@https://4sapi.com/@4sapi@1元一刀@梁哥','梁哥','4sapi',0.1447178,0.1447178),
(124,'当乐@陈威@aws claude@2.6一刀','陈威','当乐',0.376266281,0.376266281),
(125,'claude@dataeyes.ai@4.7折','奔云','dataeyes',0,0.47),
(126,'seedance@api.xgapi.top@3.5折','梁哥','xgapi',0,0.35),
(127,'claude@poloapi.top-claude_aws-new@2.2￥/刀','奔云','poloai',0.318379161,0.318379161),
(128,'当乐@陈威@aws claude@2.6一刀','陈威','当乐',0.376266281,0.376266281),
(129,'claude@gptnb@api-b64.one-ai.top:3001@2.3元一刀梁哥','梁哥','GPTNB',0.332850941,0.332850941),
(130,'gpt@当乐@陈威@2折','陈威','当乐',0,0.2),
(131,'claude@anyint.a@郑老板渠道','奔云','anyint',0,0.55),
(133,'claude@京东云@陈威@7折','陈威','京东云',0,0.7),
(134,'gpt@anyint.ai@tiaoshi@5.5折','奔云','anyint',0,0.55),
(135,'claude@api.gpt2share.com@GPT2share@3元一刀梁哥','梁哥','GPT2share',0.434153401,0.434153401),
(136,'gpt@ai.azure.com@yunlinghy@outlook.com@5折','梁云龙','yunlinghy',0,0.5),
(137,'claude@dataeyes.ai@4.7折_复制','奔云','dataeyes',0,0.47),
(138,'claude@aigc.x-see.cn@粤小七@2.8元一刀@梁哥','梁哥','粤小七',0.405209841,0.405209841),
(139,'claude@aigc.x-see.cn@粤小七@0.5元一刀逆向@梁哥','梁哥','粤小七',0.0723589,0.0723589),
(140,'gemini@aigc.x-see.cn@粤小七@0.5元一刀逆向@梁哥','梁哥','粤小七',0.0723589,0.0723589),
(141,'gpt@aigc.x-see.cn@粤小七@0.5元一刀@梁哥','梁哥','粤小七',0.0723589,0.0723589),
(142,'claude@kfc@陈威@kior 0.65刀','陈威','KFC',0.09406657,0.09406657),
(143,'claude@kfc@陈威@kior 0.75刀','陈威','KFC',0.10853835,0.10853835),
(144,'claude@api.ikuncode.cc@qq🐏@2.8元一刀@梁','梁哥','ikuncode',0.405209841,0.405209841),
(145,'claude@opengw.com@5.5折','奔云','opengw',0.795947902,0.795947902),
(146,'gemini@api-b64.one-ai.top:3001@gptnb@1元一刀梁哥','梁哥','GPTNB',0.1447178,0.1447178),
(147,'aws claude@阿宝@陈威@2.6一刀','陈威','阿宝',0.376266281,0.376266281),
(148,'kfc@陈威@gemini@2元一刀','陈威','KFC',0.289435601,0.289435601),
(149,'gemini@api.xgapi.top@xgapi@2元一刀梁哥','梁哥','xgapi',0.1447178,0.1447178),
(150,'gemini@zeta_csp_gemini@aistudio/sp','奔云','zeta',0.20260492,0.20260492),
(151,'gptnb@api-b64.one-ai.top:3001@gptnb@1元一刀','梁哥','GPTNB',0.1447178,0.1447178),
(152,'claude@dataeyes.ai@4.7折_复制','奔云','dataeyes',0,0.47),
(153,'claude@unifiedapi.cloud博思云为@8.2折--专用不能给别的分组','奔云','博思云为',0,0.82),
(154,'kfc@陈威@claude@2.9一刀','陈威','KFC',0.42,0.42),
(155,'当乐@陈威@gemini@0.16张','陈威','当乐',0.15,0.15),
(156,'gemini@4sapi.com@2元一刀@梁哥','梁哥','4sapi',0.29,0.29),
(158,'claude@poloapi.top-claude_aws-new@2.2￥/刀','奔云','poloapi',0.32,0.32),
(159,'gpt@sunzong@gpt@0.5元/刀-单号','奔云','sunzong',0.07,0.07),
(160,'gemini@69.164.253.106:8818@chengfeng@梁哥1元一刀','chengfeng','梁哥',0.14,0.14),
(161,'gemini@https://4sapi.com/2元一刀@梁哥','4sapi','梁哥',0.29,0.29),
(163,'gemini@xgapi@梁哥@2元一刀','梁哥','xgapi',0.29,0.29),
(164,'gemini@https://aigc.x-see.cn@粤小七@1元一刀梁哥','粤小七','梁哥',0.14,0.14),
(165,'gemini@api.xgapi.top@xgapi@1元一刀@梁哥','梁哥','xgapi',0.14,0.14),
(166,'gemini@69.164.253.106:8818@chengfeng@0.6一刀@梁哥0.1元一张','梁哥','chengfeng',0.09,0.09),
(167,'gemini@69.164.253.106:8818@chengfeng@0.6一刀@梁哥0.1一张','梁哥','chengfeng',0.09,0.09),
(168,'gemini@api-b64.one-ai.top:3001@gptnb@1.5元一刀@梁哥','梁哥','one-ai',0.22,0.22),
(169,'gpt@api-b64.one-ai.top:3001@gptnb@梁哥0.3一刀','梁哥','one-ai',0.04,0.04),
(170,'claude@dataeyes.ai@claude-ws-zhuanyong@7.5折-专用不可分配给别人','奔云','dataeyes',0.75,0.75),
(171,'当乐@陈威@claude@官转@3.2一刀','陈威','当乐',0.46,0.46),
(172,'gpt-image@api.xgapi.top@0.04一张@xgapi@梁哥','奔云','xgapi',0.15,0.15),
(173,'claude@api.ikuncode.cc@autust@梁哥@2.7一刀','梁哥','ikuncode',0.39,0.39),
(174,'claude@七牛@default@4.5折','七牛','default',0.45,0.45),
(175,'阿宝@陈威@gpt-imagen-2@3.5元一刀','陈威','XX',0.51,0.51),
(176,'gpt-image@api.xgapi.top@xgapi@梁哥@2元一刀','梁哥','xgapi',0.29,0.29),
(177,' kfc@陈威@gpt-iamge-2@0.04张','陈威','KFC',0.15,0.15),
(178,'gemini@zeta@gemini-csp.shua@sp4@2.8元/刀','sp4','zeta',0.41,0.41),
(179,'gemini@20.246.88.31-stark@1.4元_复制','奔云','XX',0.15,0.15),
(180,'gemini@七牛@gemini@6.8折','七牛','XX',0.68,0.68),
(181,'阿宝@陈威@awscaude优质@3.6一刀@5.3折','陈威','阿宝',0.53,0.53),
(182,'aws claude@当乐@陈威@3一刀 @4.4折','陈威','当乐',0.44,0.44),
(183,'claude@dataeyes.ai@ccmax@4折','ccmax','dataeyes',0.4,0.4),
(184,'gpt-image@69.164.253.106:8818@chengfeng@0.04一次@梁哥','奔云','chengfeng',0.15,0.15),
(185,'aws claude@阿宝@陈威@2.8一刀','陈威','阿宝',0.41,0.41),
(186,'claude@七牛@default@4.5折_接旺掌柜换模型名称','default','七牛',0.45,0.45),
(187,'openrouter-claude@api.ikuncode.cc@claude@鸡哥@2.3元一刀@梁哥','梁哥','ikuncode',0.33,0.33),
(188,'阿宝@陈威@sd2@1倍','陈威','阿宝',0.5,0.5),
(189,'claude@洪总@企业号直连@5.7折--小心操作','企业号直连','洪总',0.57,0.57),
(190,'当乐@陈威@glm-5.1@4折','陈威','glm-5',0.4,0.4),
(192,'claude@dataeyes.ai@4.7折_复制','奔云','dataeyes',0.47,0.47),
(193,'claude@tokshub@siqi@4.5折@梁哥','梁哥','tokshub',0.45,0.45),
(194,'kfc@陈威@gemini@0.38一刀','陈威','KFC',0.05,0.05),
(195,'蛋壳@陈威@gemini@0.6一刀','陈威','蛋壳',0.09,0.09),
(196,'gpt-image@s.lconai@梁哥@0.125一张','梁哥','lconai',0.15,0.15),
(197,'当乐@陈威@gpt-image-2@0.06张','陈威','当乐',0.15,0.15),
(198,'cladue@tokshub.com@claude@4.5折-钟老板key-不用','钟老板','tokshub',0.45,0.45),
(199,'claude@sunzong@claude-0.5/刀@0.5元/刀-单号','奔云','sunzong',0.07,0.07),
(201,'claude@dataeyes.ai@claude-aws-稳定号-8折@8折-专用不可分配给别人','奔云','dataeyes',0.8,0.8),
(202,'claude@dataeyes.ai@aws-An-svip@1.6折','奔云','dataeyes',0.16,0.16),
(203,'claude@dataeyes.ai@claude-aws-vip-svip@5.5折','奔云','dataeyes',0.55,0.55),
(204,'阿宝@陈威@gpt@0.4一刀','陈威','阿宝',0.06,0.06),
(205,'gptgemini@粤小七@1元一刀@梁哥','梁哥','粤小七',0.14,0.14),
(206,'cladue@tokshub.com@claude@4.5折','奔云','tokshub',0.45,0.45),
(207,'Kiro@47.251.115.42:1455@haiTao号池','haiTao','Kiro',0.15,0.15);
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

-- Dump completed on 2026-07-03  3:02:10
