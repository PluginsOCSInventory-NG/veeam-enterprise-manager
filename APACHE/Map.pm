###############################################################################
## OCSINVENTORY-NG
## Copyleft Gilles Dubois 2017
## Web : http://www.ocsinventory-ng.org
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################

package Apache::Ocsinventory::Plugins::Veeam_Enterprise_Manager::Map;

use strict;

use Apache::Ocsinventory::Map;

$DATA_MAP{VEEAM_BACKUP_SERVERS} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      UID => {}
    }
  };

$DATA_MAP{VEEAM_REPOSITORIES} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      KIND => {},
      UID => {},
      FREESPACE => {},
      CAPACITY => {},
      TYPE => {}
    }
  };

$DATA_MAP{VEEAM_JOBS} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      DESCRIPTION => {},
      UID => {},
      JOBTYPE => {},
      IS_SCHEDULED => {},
      IS_CONFIGURED => {},
      PLATFORM => {},
      NEXT_RUN => {},
      RETRY_ENABLED => {},
      BACKUP_TYPE => {},
      BACKUP_KIND => {},
      BACKUP_OPTIONS => {}
    }
  };

$DATA_MAP{VEEAM_JOBS} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      DESCRIPTION => {},
      UID => {},
      JOBTYPE => {},
      IS_SCHEDULED => {},
      IS_CONFIGURED => {},
      PLATFORM => {},
      NEXT_RUN => {},
      RETRY_ENABLED => {},
      BACKUP_TYPE => {},
      BACKUP_KIND => {},
      BACKUP_OPTIONS => {}
    }
  };

$DATA_MAP{VEEAM_JOBS_BACKUP_SESSIONS} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      UID => {},
      JOB_NAME => {},
      JOB_TYPE => {},
      RESULT => {},
      RETRY_ENABLED => {},
      STATE => {},
      CREATION_TIME => {},
      END_TIME => {}
    }
  };

$DATA_MAP{VEEAM_JOBS_VMS} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      DISPLAY_NAME => {},
      JOB_NAME => {},
      HIERARCHY_REF => {},
      VM_UID => {}
    }
  };

$DATA_MAP{VEEAM_VM_RESTORE_POINT} = {
    mask => 0,
    multi => 1,
    auto => 1,
    delOnReplace => 1,
    sortBy => 'NAME',
    writeDiff => 0,
    cache => 0,
    fields => {
      NAME => {},
      UID => {},
      BACKUP_SERVER => {},
      VAPP_NAME => {},
      FILE_REFERENCE => {},
      CREATION_DATE => {}
    }
  };
