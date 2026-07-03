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
-- Table structure for table `ex_tokens`
--

DROP TABLE IF EXISTS `ex_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `ex_tokens` (
  `id` int NOT NULL,
  `user_id` int DEFAULT NULL,
  `username` varchar(80) DEFAULT NULL,
  `name` varchar(200) DEFAULT NULL,
  `discount` double DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ex_tokens_idx_id` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ex_tokens`
--

SET @OLD_AUTOCOMMIT=@@AUTOCOMMIT, @@AUTOCOMMIT=0;
LOCK TABLES `ex_tokens` WRITE;
/*!40000 ALTER TABLE `ex_tokens` DISABLE KEYS */;
INSERT INTO `ex_tokens` VALUES
(1,3,'aidev','Gemini-YI',1),
(2,3,'aidev','Gemini-zl',1),
(3,3,'aidev','Gemini-WT',1),
(4,2,'Tal-wangzong','gemini',1),
(5,4,'老张','gemini',1),
(6,4,'老张','laozhang-2',1),
(7,5,'wangzong','gemini',1),
(8,6,'poloai','gemini',1),
(9,5,'wangzong','g',1),
(10,8,'weiyunqichuang','gemini',1),
(11,1,'root','TEST',1),
(12,9,'csp.burncloud','csp.burncloud.com gemini',0.2),
(13,1,'root','GEMINI-FAST-csp.burncloud.com',0.15),
(14,9,'csp.burncloud','ai.burncloud.com',0.2),
(15,10,'tuling','FAST06X',0.06),
(16,12,'lingke','gemini',1),
(17,13,'douhui','douhui’s Default Token',1),
(18,11,'yuexiao7','GEMINI-FAST-2',1),
(19,14,'lingke-xianggang','gemini',1),
(20,15,'koukoutu','koukoutu',1),
(21,16,'ceshi_wang','gemini',1),
(22,17,'nanopro','gemini-1.1411',1),
(23,18,'facedrawing','gemini',1),
(24,19,'caikaifeng','caikaifeng’s Default Token',1),
(25,20,'sanye','gemini',1),
(26,22,'koukoutu-4','gemini-4k',1),
(27,21,'aibaobao','陈威-gemini-3-pro-imag-0.3',1),
(28,1,'root','gemini4k-test',1),
(29,26,'wangzong2','sora',1),
(30,23,'halaoban','哈士奇',1),
(31,27,'dange','0.9',1),
(32,17,'nanopro','1',1),
(33,28,'aacockjt523','aacockjt523’s Default Token',1),
(34,29,'otjaocur','otjaocur’s Default Token',1),
(35,2,'Tal-wangzong','zhuanxian',1),
(36,18,'facedrawing','nano2',1),
(37,18,'facedrawing','glm',1),
(38,2,'Tal-wangzong','gemin-20260305',1),
(39,1,'root','doubao',1),
(40,9,'csp.burncloud','csp.burncloud.com-halaoba-ym',0.2),
(41,2,'Tal-wangzong','gemini-260307-Ym-2.3折',0.23),
(42,30,'pinova','gemini',1),
(43,31,'abao_shushua_gemini','1',0.15),
(44,32,'谢多多','谢多多’s Default Token',1),
(45,33,'wz_glm','glm',1),
(46,1,'root','Kimi',1),
(47,1,'root','sora2',1),
(48,36,'dange2','aws测试',1),
(49,30,'pinova','gpt',1),
(50,9,'csp.burncloud','grok',0.5),
(51,37,'user_dh0kw8zy','user_dh0kw8zy’s Default Token',0.15),
(52,38,'user_td5zuacf','user_td5zuacf’s Default Token',1),
(53,39,'user_0qgg','user_0qgg’s Default Token',1),
(54,40,'user_ptnq','user_ptnq’s Default Token',1);
/*!40000 ALTER TABLE `ex_tokens` ENABLE KEYS */;
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

-- Dump completed on 2026-07-03  3:03:59
