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
-- Table structure for table `ex_users`
--

DROP TABLE IF EXISTS `ex_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ex_users` (
  `id` int DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `remark` text,
  `seller` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
  `discount` decimal(10,2) DEFAULT NULL,
  `onmon` tinyint DEFAULT NULL,
  KEY `ex_users_idx_user_id` (`id`),
  KEY `ex_users_idx_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ex_users`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ex_users` WRITE;
/*!40000 ALTER TABLE `ex_users` DISABLE KEYS */;
INSERT INTO `ex_users` VALUES
(1,'root',NULL,'奔云',0.20,0),
(2,'Cloudsway',NULL,'奔云',0.50,0),
(3,'KYZG_KIMI','陈威 成本6折  - 6折','陈威',0.60,0),
(4,'qingfeng','PoloAPI','奔云',0.25,0),
(5,'toktok','名贝','奔云',0.30,0),
(6,'SCSD_Claude','生成时代','奔云',0.40,0),
(7,'groupTester',NULL,'奔云',0.40,0),
(8,'linjz','阿雅','奔云',0.40,0),
(9,'sora2','yuazong','奔云',0.40,0),
(10,'danghong','yuanzong','奔云',0.40,0),
(11,'sungong_ip',NULL,'奔云',0.40,0),
(12,'even','claude 3折','奔云',0.35,0),
(13,'xiaojing',NULL,'奔云',0.30,0),
(14,'HLB',NULL,'奔云',0.20,0),
(15,'yang','杨灵龙 claude5折 gemini4折 梁哥跟','梁哥',0.50,0),
(16,'stark','2折Gemini 4月3日起 4.8折gemini','奔云',0.20,0),
(17,'API易',NULL,'奔云',0.17,0),
(18,'艺术照项目','艺术照项目-专用用户','奔云',0.20,0),
(19,'王建超',NULL,'奔云',0.40,0),
(20,'dange','梁哥2折','梁哥',0.20,0),
(21,'bao','陈威 - 1元1刀','陈威',0.15,0),
(22,'Tal-wangzong','gemini-2.5-flash-image','奔云',0.30,0),
(23,'digitalcloud','神州数码','奔云',0.45,0),
(24,'ZetaTechs','0.65元/刀 速刷方老板 ZHAO-ZX-3折 ZHAO-YM 2折','奔云',0.30,0),
(25,'gooki','蔡总','奔云',0.40,0),
(26,'weiyunqichuang','陈威，0.7元/美元','陈威',0.10,0),
(28,'ljx','梁哥 李俊贤 - 用于医疗评估的 5折 gemini','梁哥',0.50,0),
(29,'caizong-pingtai','蔡总平台账户-17.74.66.177','奔云',0.40,0),
(30,'4Sapi','梁哥 gemini - 0.8￥','梁哥',0.13,0),
(31,'tech_LiTaoJian','奔云技术-李涛剑','奔云',0.20,0),
(32,'tech_LiangGe','奔云技术-梁哥','奔云',0.20,0),
(33,'tech_YuanZhengHui','奔云技术-袁正辉','奔云',0.20,0),
(34,'tech_ZhuoRongYao','奔云技术-卓荣垚','奔云',0.20,0),
(35,'tech_LiZhi','奔云技术-李智','奔云',0.20,0),
(36,'tech_Kelly','奔云技术-Kelly','奔云',0.20,0),
(37,'tech_ZhenTianFeng','奔云技术-郑天锋','奔云',0.20,0),
(38,'tech_GuanGuoSong','奔云技术-关国松','奔云',0.20,0),
(39,'tech_caiziming','奔云技术-蔡梓明','奔云',0.20,0),
(40,'tech_chenwei','奔云技术 - 陈威','陈威',0.20,0),
(42,'even-gemini','gemini 3折','奔云',0.30,0),
(43,'koukoutu-1','梁哥2折','梁哥',0.20,0),
(44,'tech_rudyqau','奔云技术 - 丘杜茂','奔云',0.20,0),
(45,'duo','奔云销售谢总测试','奔云',0.20,0),
(46,'tech_yulaoban','奔云技术-余','奔云',0.20,0),
(47,'aionly','aionly 5折','奔云',0.70,0),
(48,'gitee-1','开源中国 5折','奔云',0.60,0),
(49,'gitee-2','开源中国 5折','奔云',0.60,0),
(50,'sunme2','梁哥 sunmi','梁哥',0.30,0),
(51,'tianhuan','梁哥 天环','梁哥',0.30,0),
(52,'FangZong','方老板 2.7元/刀','奔云',0.40,0),
(53,'kyzg_01','开源中国 公有云  - 6折','奔云',0.60,0),
(54,'kyzg_02','开源中国 私有云  - 6折','奔云',0.60,0),
(55,'kyzg_03','开源中国 已用未计算  - 6折','奔云',0.60,0),
(56,'kyzg_04','开源中国 AI - 6折','奔云',0.60,0),
(57,'JunchenKeJi','陈威 俊臣科技','陈威',0.50,0),
(58,'tianyi','梁哥 天翼','梁哥',0.40,0),
(59,'spark','陈威 尚总 3折 国外大模型 gpt gemini clade','陈威',0.30,0),
(60,'spark1','陈威 尚总 国内大模型 kimi-2.5 5折','陈威',0.50,0),
(62,'wangsu','黄微','奔云',0.50,0),
(63,'FENA','陈威 冯同学 9折','陈威',0.90,0),
(64,'Orange','叶笑尘-6折','叶笑尘',0.60,0),
(65,'Ken','叶笑尘-6折','叶笑尘',0.60,0),
(66,'Joyce','叶笑尘-6折','叶笑尘',0.60,0),
(67,'Harry','叶笑尘-6折','叶笑尘',0.60,0),
(68,'Dolores','叶笑尘-6折','叶笑尘',0.60,0),
(69,'ZENGBOWEN','叶笑尘-6折','叶笑尘',0.60,0),
(70,'Guicai','叶笑尘-6折','叶笑尘',0.60,0),
(71,'Caiyijun','叶笑尘-6折','叶笑尘',0.60,0),
(72,'fendc','陈威 冯同学 9折','陈威',0.90,0),
(73,'junabc','陈威 冯同学 9折','陈威',0.90,0),
(74,'Kelic','陈威 冯同学 9折','陈威',0.90,0),
(75,'Junche','陈威 冯同学 9折','陈威',0.90,0),
(76,'JunKe','陈威 冯同学 7折','陈威',0.70,0),
(79,'aitao','陈威 冯同学 7折','陈威',0.70,0),
(80,'weyyu','陈威 冯同学 7折','陈威',0.70,0),
(81,'keaya','陈威 冯同学 7折','陈威',0.70,0),
(82,'qiuqiu','陈威 冯同学 7折','陈威',0.70,0),
(83,'wangyehui','陈威 华为云 全价','陈威',1.00,0),
(84,'bxyw','博思云为 AWS 5折 VC3折','奔云',0.50,0),
(85,'chenchen','陈威 王星 陈臣 测试先还没有谈价格 ','陈威',0.50,0),
(86,'jumo','陈威 王星 科来 测试还没报价','陈威',0.50,0),
(87,'dylan','陈威 dylan 新站 http://8.217.59.73:8080/','陈威',0.40,0),
(88,'bxyw-aws','博思云为 AWS 5折 刷AWS','奔云',0.50,0),
(89,'amy','陈威 北京蔡总新站','陈威',0.40,0),
(90,'tech_haitao','奔云技术-海涛','奔云',0.20,0),
(91,'qingchun','梁哥5折','梁哥',0.50,0),
(92,'aibaobao','陈威 肥猪 引力','陈威',0.30,0),
(93,'zhangzong','gemini7折','奔云',0.70,0),
(94,'binzong','小慧6折','小慧',0.60,0),
(95,'yinyue',NULL,'奔云',0.30,0),
(96,'xiaoxiao',NULL,'奔云',0.30,0),
(97,'tech_yinweirong','奔云技术-尹巍荣','尹巍荣',0.20,0),
(98,'kyzg_stable','开源中国-稳定大号9折','奔云',0.90,0),
(99,'leo',NULL,'奔云',0.05,NULL),
(100,'gaosheng',NULL,'奔云',0.05,NULL),
(101,'zhidao','顺6折','顺',0.60,NULL),
(102,'budeyijiao','顺6折','顺',0.60,NULL),
(103,'Linjinkeji','灵鲸科技','灵鲸科技',0.05,NULL),
(104,'shang','陈威','陈威',0.05,NULL),
(105,'deerapi','DeerApi 5折预付','DeerAp',0.50,NULL),
(106,'Austin','陈威  Austin qwen 5折','陈威',0.50,NULL),
(107,'huangHanJie','黄汉杰 5 折 江振','黄汉杰',0.50,NULL),
(108,'qiniuyun','陈威 七牛云 2.5折 逆向claude','陈威',0.25,NULL),
(109,'Ray雷子','小惠6折','小惠',0.60,NULL),
(110,'z888','明claude6折','明',0.60,NULL),
(111,'z666','明gemini4折','明',0.40,NULL),
(112,'z777','明3折gpt','明',0.30,NULL),
(113,'chuangyue','梁0.2一张','梁',0.20,NULL),
(114,'lazyday','沈跃 9折 非开源中国','沈跃',0.90,NULL),
(118,'wangsu_claude','网宿科技-8.4折','网宿科技',0.84,NULL),
(119,'wph','维品会 陈威 6折','维品会',0.60,NULL),
(120,'shunke','顺3折','顺',0.30,NULL),
(121,'kelan','陈威 开源中国李总还没谈价测试','陈威',0.05,NULL),
(122,'zimu','顺','顺',0.05,NULL),
(123,'xin','陈威 开源中国李总 还没讲价格','陈威',0.05,NULL),
(124,'quanwang','顺跑图0.2一张','顺跑图',0.20,NULL),
(125,'huiyan','顺2折gpt','顺',0.20,NULL),
(126,'liuNing','刘宁 孙建龙客户 claude 6折','刘宁',0.60,NULL),
(127,'bxyw_gemini','博思运维-刷gemini-黄耀令 2.8元成本，55分','博思运维',0.41,NULL),
(128,'tech_wangyuhao','奔云技术 王育浩','奔云技术',0.05,NULL),
(129,'fengyun','陈威 烽云','陈威',0.05,NULL),
(130,'shang123',NULL,'奔云',0.05,NULL),
(131,'do',NULL,'奔云',0.05,NULL),
(132,'guzong','顾玉麟 - 沈云肖 6折claude5折gpt','顾玉麟',0.60,NULL),
(133,'sbqy','拾贝启源 莎莎姐','拾贝启源',0.05,NULL),
(134,'yuanZong','袁中亚 5.5折claude 普通','袁中亚',0.55,NULL),
(135,'chengZong','程总，蒸馏5折','程总',0.50,NULL),
(136,'Ustinov','阿顺 Ustinov','阿顺',0.05,NULL),
(137,'yuanZongC','袁总 5.5折','袁总',0.55,NULL),
(138,'qiniuu123','陈威 七牛云 赵娇娇采购gpt-image-2   2折','陈威',0.20,NULL),
(139,'jingDong','京东5折claude','京东',0.50,NULL),
(140,'kyzg_05','开源中国 沈总  - 6折','开源中国',0.60,NULL);
/*!40000 ALTER TABLE `ex_users` ENABLE KEYS */;
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

-- Dump completed on 2026-07-03  3:02:43
