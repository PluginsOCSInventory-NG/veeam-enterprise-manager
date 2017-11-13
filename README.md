# Plugin Veeam Enterprise Manager

<p align="center">
  <img src="https://cdn.ocsinventory-ng.org/common/banners/banner660px.png" height=300 width=660 alt="Banner">
</p>

<h1 align="center">Plugin Veeam Enterprise Manager</h1>
<p align="center">
  <b>Some Links:</b><br>
  <a href="http://ask.ocsinventory-ng.org">Ask question</a> |
  <a href="https://www.ocsinventory-ng.org/?utm_source=github-ocs">Website</a> |
  <a href="https://www.ocsinventory-ng.org/en/#ocs-pro-en">OCS Professional</a>
</p>

## Description

This plugin is made to retrieve all Veeam backup informations using the new REST api from Veeam Enterprise Manager.
Link : https://helpcenter.veeam.com/docs/backup/rest/em_web_api_reference.html?ver=95

*NOTE : This plugin still not have any visual representation of inventoried data (WIP)*

## Prerequisite

*The following configuration need to be installed on your VCenter :*
1. Veeam Backup & Replication 9.5 and newer
2. A user with read rights on the API

*The following OCS configuration need to be installed :*
1. Unix agent 2.3 and newer
2. OCS Inventory 2.3.X recommended

*The following dependencies need to be installed on agent :*
1. LWP::UserAgent
2. XML::Simple
3. Perl::Switch

## Used API routes

This following routes are used by the API :
- enterprisemanager:9399/api/sessionMngr/?v=latest
- enterprisemanager:9399/api/jobs
- enterprisemanager:9399/api/backupServers
- enterprisemanager:9399/api/replicas
- enterprisemanager:9399/api/repositories
- enterprisemanager:9399/api/vmRestorePoints

## Configuration

To configure a new server to scan you need to edit the Veeam.pm file.

See more about authentification here :
https://helpcenter.veeam.com/docs/backup/rest/http_authentication.html?ver=95

Line 18 :  
```
my @auth_hashes = (
    {
       URL  => "my_enterprisemanager:9399/api/",
       AUTH_DIG     => "user:password encode in base 64",
    },
);
```

You need to change the URL to your Veeam Enterprise Manager server url / ip and set the AUTH_DIG to user + pass encoded in base 64

If you have more than one server you need to add the following line below the last URL + AUTH_DIG values :

```
    {
       URL => "my_other_enterprisemanager:9399/api/",
       AUTH_DIG    => "user:password encode in base 64",
    },
```

*Note : there is no limit on server number*

## Todo

1. Add GUI representations for inventoried data in ocsreports
