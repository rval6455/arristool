-- MySQL dump 10.13  Distrib 5.7.19, for Linux (x86_64)
--
-- Host: db    Database: arristool_development
-- ------------------------------------------------------
-- Server version	5.7.19

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
-- Current Database: `arristool_development`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `arristool_development` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `arristool_development`;

--
-- Table structure for table `ar_internal_metadata`
--

DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ar_internal_metadata`
--

LOCK TABLES `ar_internal_metadata` WRITE;
/*!40000 ALTER TABLE `ar_internal_metadata` DISABLE KEYS */;
INSERT INTO `ar_internal_metadata` VALUES ('environment','development','2017-12-27 08:22:01','2017-12-27 08:22:01');
/*!40000 ALTER TABLE `ar_internal_metadata` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `arris_headends`
--

DROP TABLE IF EXISTS `arris_headends`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `arris_headends` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `host` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `downstream_freq` float DEFAULT NULL,
  `polarity` varchar(255) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `arris_headends`
--

LOCK TABLES `arris_headends` WRITE;
/*!40000 ALTER TABLE `arris_headends` DISABLE KEYS */;
INSERT INTO `arris_headends` VALUES (1,'cmts1.mm','Mingus Mt CMTS 1 (West Sec 1) (231Mhz)',2509,'Vertical','2013-11-13 23:37:42','2013-11-15 18:53:36'),(2,'cmts2.mm','Mingus Mt CMTS 2 (East Sec 1) (225Mhz)',2503,'Vertical','2013-11-13 23:59:55','2013-11-15 18:53:47'),(3,'cmts3.mm','Mingus Mt CMTS 3 (East Sec 2) (309Mhz)',2587,'Vertical','2013-11-14 21:53:51','2013-11-15 18:54:00'),(4,'cmts4.mm','Mingus Mt CMTS 4 (East Sec 3) (243Mhz)',2521,'Vertical','2013-11-14 23:36:31','2013-11-15 18:54:12'),(5,'cmts5.mm','Mingus Mt CMTS 5 (West Sec 2) (309Mhz)',309,'Vertical','2014-01-31 23:22:16','2014-01-31 23:22:16'),(6,'cmts6.mm','Mingus Mt CMTS 6 (East Sec 3) (243Mhz)',2521,'Vertical','2013-11-14 23:36:31','2013-11-15 18:54:12'),(7,'cmts7.mm','Mingus Mt CMTS 7 (East Sec 3) (243Mhz)',2521,'Vertical','2013-11-14 23:36:31','2013-11-15 18:54:12'),(8,'cmts8.mm','Mingus Mt CMTS 8 (East Sec 3) (243Mhz)',2521,'Vertical','2013-11-14 23:36:31','2013-11-15 18:54:12'),(9,'cmts1.twm','Towers Mt CMTS 1 (345Mhz)',2623,'Vertical','2013-12-07 16:27:57','2013-12-10 17:22:57'),(10,'cmts1.tbm','Table Mt CMTS 1 (Sec 1) (225Mhz)',2503,'Horizontal','2013-11-14 21:54:08','2013-11-15 18:59:08'),(11,'cmts2.tbm','Table Mt CMTS 2 (Sec 2) (243Mhz)',2531,'Horizontal','2013-11-14 21:54:26','2013-11-15 18:59:14'),(12,'cmts3.tbm','Table Mt CMTS 3 (Sec 3) (249Mhz)',2587,'Vertical','2014-01-04 06:12:00','2014-01-04 06:12:00'),(13,'cmts4.tbm','Table Mt CMTS 4 (Sec 4) (2550.0Mhz)',2550,'Vertical','2015-12-10 15:23:59','2015-12-10 15:23:59'),(14,'cmts1.bwm','Bill Williams CMTS 1 (West Sec 1) (221Mhz)',221,'Vertical','2014-03-12 19:50:51','2014-03-12 19:50:51'),(15,'cmts1.sqpk','Squaw Peak CMTS 1 (Sec 1 u0026 3) (303Mhz)',2581,'Vertical','2013-11-14 21:54:44','2013-11-15 18:59:21'),(16,'cmts2.sqpk','Squaw Peak CMTS 2 (Sec 4) (231Mhz)',2509,'Vertical','2013-11-14 21:54:59','2013-11-15 18:59:25'),(17,'cmts3.sqpk','Squaw Peak CMTS 3 (Sec ?) (?Mhz)',2587,'Vertical','2016-04-11 22:32:09','2016-04-11 22:32:09'),(18,'cmts4.sqpk','Squaw Peak CMTS 4 (Sec 6) (309Mhz)',2587,'Vertical','2016-04-27 07:01:03','2016-04-27 07:01:03');
/*!40000 ALTER TABLE `arris_headends` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cmtsflaphistories`
--

DROP TABLE IF EXISTS `cmtsflaphistories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cmtsflaphistories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cmts` varchar(255) DEFAULT NULL,
  `lastcleared` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cmtsflaphistories`
--

LOCK TABLES `cmtsflaphistories` WRITE;
/*!40000 ALTER TABLE `cmtsflaphistories` DISABLE KEYS */;
/*!40000 ALTER TABLE `cmtsflaphistories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20150309225757'),('20160914155920');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'arristool_development'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-12-27  4:24:42
