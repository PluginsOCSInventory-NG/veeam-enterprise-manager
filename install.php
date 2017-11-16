<?php
/*
 * Copyright 2005-2017 PluginsOCSInventory-NG/vveeam-enterprise-manager contributors.
 * See the Contributors file for more details about them.
 *
 * This file is part of PluginsOCSInventory-NG/vveeam-enterprise-manager.
 *
 * PluginsOCSInventory-NG/vveeam-enterprise-manager is free software: you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * PluginsOCSInventory-NG/vveeam-enterprise-manager is distributed in the hope that it
 * will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
 * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with PluginsOCSInventory-NG/vmware-vcenter. if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */


function plugin_version_veeam()
{
return array('name' => 'Veeam inventory',
'version' => '1.0',
'author'=> 'Gilles Dubois',
'license' => 'GPLv3',
'verMinOcs' => '2.3');
}

function plugin_init_veeam()
{

$object = new plugins;

// Add menu
$object -> add_menu ("veeam","21000","veeam","Veeam Backup Management","plugins");

// Veeam backup server table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VEEAM_BACKUP_SERVERS` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `UID` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// Veeam repositories table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VEEAM_REPOSITORIES` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `KIND` VARCHAR(255) DEFAULT NULL,
                      `UID` VARCHAR(255) DEFAULT NULL,
                      `FREESPACE` VARCHAR(255) DEFAULT NULL,
                      `CAPACITY` VARCHAR(255) DEFAULT NULL,
                      `TYPE` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// Veeam jobs table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VEEAM_JOBS` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `DESCRIPTION` VARCHAR(255) DEFAULT NULL,
                      `UID` VARCHAR(255) DEFAULT NULL,
                      `JOBTYPE` VARCHAR(255) DEFAULT NULL,
                      `IS_SCHEDULED` VARCHAR(255) DEFAULT NULL,
                      `IS_CONFIGURED` VARCHAR(255) DEFAULT NULL,
                      `PLATFORM` VARCHAR(255) DEFAULT NULL,
                      `NEXT_RUN` VARCHAR(255) DEFAULT NULL,
                      `RETRY_ENABLED` VARCHAR(255) DEFAULT NULL,
                      `BACKUP_TYPE` VARCHAR(255) DEFAULT NULL,
                      `BACKUP_KIND` VARCHAR(255) DEFAULT NULL,
                      `BACKUP_OPTIONS` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// Veeam jobs backup sessions table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VEEAM_JOBS_BACKUP_SESSIONS` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `UID` VARCHAR(255) DEFAULT NULL,
                      `JOB_NAME` VARCHAR(255) DEFAULT NULL,
                      `JOB_TYPE` VARCHAR(255) DEFAULT NULL,
                      `RESULT` VARCHAR(255) DEFAULT NULL,
                      `RETRY_ENABLED` VARCHAR(255) DEFAULT NULL,
                      `STATE` VARCHAR(255) DEFAULT NULL,
                      `CREATION_TIME` VARCHAR(255) DEFAULT NULL,
                      `END_TIME` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// Veeam jobs backup sessions table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VEEAM_JOBS_VMS` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `DISPLAY_NAME` VARCHAR(255) DEFAULT NULL,
                      `JOB_NAME` VARCHAR(255) DEFAULT NULL,
                      `HIERARCHY_REF` VARCHAR(255) DEFAULT NULL,
                      `VM_UID` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

// Veeam jobs backup sessions table
$object -> sql_query("CREATE TABLE IF NOT EXISTS `VEEAM_VM_RESTORE_POINT` (
                      `ID` INT(11) NOT NULL AUTO_INCREMENT,
                      `HARDWARE_ID` INT(11) NOT NULL,
                      `NAME` VARCHAR(255) DEFAULT NULL,
                      `UID` VARCHAR(255) DEFAULT NULL,
                      `BACKUP_SERVER` VARCHAR(255) DEFAULT NULL,
                      `VAPP_NAME` VARCHAR(255) DEFAULT NULL,
                      `FILE_REFERENCE` VARCHAR(255) DEFAULT NULL,
                      `CREATION_DATE` VARCHAR(255) DEFAULT NULL,
                      PRIMARY KEY  (`ID`,`HARDWARE_ID`)
                      ) ENGINE=INNODB;");

}

function plugin_delete_veeam()
{

$object = new plugins;
// Del menu
$object -> del_menu ("veeam","21000","Veeam Backup Management","plugins");
// Veeam tables drop
$object -> sql_query("DROP TABLE `VEEAM_BACKUP_SERVERS`");
$object -> sql_query("DROP TABLE `VEEAM_REPOSITORIES`");
$object -> sql_query("DROP TABLE `VEEAM_JOBS`");
$object -> sql_query("DROP TABLE `VEEAM_JOBS_BACKUP_SESSIONS`");
$object -> sql_query("DROP TABLE `VEEAM_JOBS_VMS`");
$object -> sql_query("DROP TABLE `VEEAM_VM_RESTORE_POINT`");
}
