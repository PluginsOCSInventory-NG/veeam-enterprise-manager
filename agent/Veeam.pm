###############################################################################
## OCSINVENTORY-NG
## Copyleft Gilles Dubois 2017
## Web : http://www.ocsinventory-ng.org
##
## This code is open source and may be copied and modified as long as the source
## code is always made freely available.
## Please refer to the General Public Licence http://www.gnu.org/ or Licence.txt
################################################################################

package Ocsinventory::Agent::Modules::Veeam;

use LWP::UserAgent;
use XML::Simple;
use Switch;

# Auth
my @auth_hashes = (
    {
       URL  => "my_enterprisemanager:9399/api/",
       AUTH_DIG     => "",
    },
  );

# Configuration
my $server_url = "";
my $web_server_url = "";
my $session_id = "";
my $auth_digest = "";
my $api_filter;

# sub routines var
my $server_endpoint;
my $restpath;
my $auth_dig;
my $lwp_useragent;
my $resp;
my $req;
my $message;

# vm index
my $vm_index = "{vmname}";

# Veeam references api hash
my %veeam_api_references = (
    "veeam_login" => "sessionMngr/?v=latest",
    "veeam_jobs" =>  "jobs",
    "veeam_backup_servers" => "backupServers",
    "veeam_replicas" => "replicas",
    "veeam_repositories" =>  "repositories",
    "veeam_vm_restore_point" =>  "vmRestorePoints",
);

sub new {

   my $name="veeam";   # Name of the module

   my (undef,$context) = @_;
   my $self = {};

   #Create a special logger for the module
   $self->{logger} = new Ocsinventory::Logger ({
            config => $context->{config}
   });

   $self->{logger}->{header}="[$name]";

   $self->{context}=$context;

   $self->{structure}= {
                        name => $name,
                        start_handler => undef,    #or undef if don't use this hook
                        prolog_writer => undef,    #or undef if don't use this hook
                        prolog_reader => undef,    #or undef if don't use this hook
                        inventory_handler => $name."_inventory_handler",    #or undef if don't use this hook
                        end_handler => undef    #or undef if don't use this hook
   };

   bless $self;
}

######### Hook methods ############

sub veeam_inventory_handler {

  my $self = shift;
  my $logger = $self->{logger};

  my $common = $self->{context}->{common};

  # Processing part
  my $org_infos;
  my $vdc_infos;
  my $vdc_org_infos;
  my $vapps_infos;
  my $vapps_org_infos;
  my $networks_infos;
  my $vms_infos;

  # Debug log for inventory
  $logger->debug("Starting Veeam inventory plugin");

  foreach (@auth_hashes){

      # Get auth informations
      $server_url = $_->{'URL'};
      $auth_digest = $_->{'AUTH_DIG'};

      # Get login link
      $session_id = send_auth_api_query($server_url, $veeam_api_references{"veeam_login"}, $auth_digest);

      # Log connected server
      $logger->debug("Connected to the veeam server : ".$server_url);

      # Get backup informations
      my $backup_servers = send_api_query($server_url, $veeam_api_references{"veeam_backup_servers"}, $session_id, "");
      $logger->debug("Processing backup servers");
      if(ref($backup_servers->{'Ref'}) eq 'ARRAY'){
        foreach (@{$backup_servers->{'Ref'}}){
            #Create xml for backup servers
            generate_backup_servers_xml($_, $common);
        }
      }else{
        #Create xml for backup servers
        generate_backup_servers_xml($backup_servers->{'Ref'}, $common);
      }

      # Get repositories informations
      my $repository_list = send_api_query($server_url, $veeam_api_references{"veeam_repositories"}, $session_id, "");
      $logger->debug("Processing repositories");
      foreach (@{$repository_list->{'Ref'}}){
          my $repository_details = send_api_query($_->{'Href'}, "", $session_id, "?format=Entity");

          # Add XML
          push @{$common->{xmltags}->{VEEAM_REPOSITORIES}},
          {
             NAME => [$repository_details->{'Name'}],
             KIND => [$repository_details->{'Kind'}],
             UID => [$repository_details->{'UID'}],
             FREESPACE => [$repository_details->{'FreeSpace'}],
             CAPACITY => [$repository_details->{'Capacity'}],
             TYPE => [$repository_details->{'Type'}],
          };
      }

      # Get Jobs list
      my $count = 0;
      my $jobs_list = send_api_query($server_url, $veeam_api_references{"veeam_jobs"}, $session_id, "");
      $logger->debug("Processing jobs");
      foreach (@{$jobs_list->{'Ref'}}){
        $count ++;
        my $jobs_details = send_api_query($_->{'Href'}, "", $session_id, "");

        # Get entity details instead of hierachy one
        my $jobs_entity_details = send_api_query($_->{'Href'}, "", $session_id, "?format=Entity");

        # Get backup recurrance type.
        my $backup_type = "";
        my $recurrence = "";
        my $dates = "";
        my $dates_ref = "";

        if($jobs_entity_details->{'JobScheduleOptions'}->{'OptionsDaily'}->{'Enabled'} eq 'true'){ # Check for daily

          $backup_type = "Daily";
          $recurrence = $jobs_entity_details->{'JobScheduleOptions'}->{'OptionsDaily'}->{'Kind'};
          $dates_ref = $jobs_entity_details->{'JobScheduleOptions'}->{'OptionsDaily'}->{'Days'};

        } elsif($jobs_entity_details->{'JobScheduleOptions'}->{'OptionsMonthly'}->{'Enabled'} eq 'true'){ # Check for monthly

          $backup_type = "Monthly";
          $recurrence = $jobs_entity_details->{'JobScheduleOptions'}->{'OptionsMonthly'}->{'DayNumberInMonth'};
          $dates_ref = $jobs_entity_details->{'JobScheduleOptions'}->{'OptionsMonthly'}->{'Months'};

        } elsif($jobs_entity_details->{'JobScheduleOptions'}->{'OptionsPeriodically'}->{'Enabled'} eq 'true'){ # Check for Periodicaly

          $backup_type = "Periodically";
          $recurrence = $jobs_entity_details->{'JobScheduleOptions'}->{'OptionsPeriodically'}->{'Kind'};
          $dates = $jobs_entity_details->{'JobScheduleOptions'}->{'OptionsPeriodically'}->{'FullPeriod'};

        }

        # Check if dates are in a array or not
        if(ref($dates_ref) eq 'ARRAY' && $dates_ref ne ""){
          # Join array as string
          $dates = join(',',@{$dates_ref});
        }elsif($dates_ref ne ""){
          $dates = $dates_ref;
        }

        # Add XML
        push @{$common->{xmltags}->{VEEAM_JOBS}},
        {
           NAME => [$jobs_entity_details->{'Name'}],
           DESCRIPTION => [$jobs_entity_details->{'Description'}],
           UID => [$jobs_entity_details->{'UID'}],
           JOBTYPE => [$jobs_entity_details->{'JobType'}],
           IS_SCHEDULED => [$jobs_entity_details->{'ScheduleEnabled'}],
           IS_CONFIGURED => [$jobs_entity_details->{'ScheduleConfigured'}],
           PLATFORM => [$jobs_entity_details->{'Platform'}],
           NEXT_RUN => [$jobs_entity_details->{'NextRun'}],
           RETRY_ENABLED => [$jobs_entity_details->{'JobScheduleOptions'}->{'RetryOptions'}->{'RetrySpecified'}],
           BACKUP_TYPE => [$backup_type],
           BACKUP_KIND => [$recurrence],
           BACKUP_OPTIONS => [$dates],
        };

        # Get job backup sessions
        my $job_backup = send_api_query($jobs_details->{'Href'}, "", $session_id, "/backupSessions?format=Entity");
        $logger->debug("Processing jobs backup sessions for job : ".$_->{'Name'});
        # Process Job Back up sessions
        if(ref($job_backup->{'BackupJobSession'}) eq 'ARRAY'){
          foreach (@{$job_backup->{'BackupJobSession'}}){
            generate_jobs_backup_sessions_xml($_, $common);
          }
        }else{
          generate_jobs_backup_sessions_xml($job_backup->{'BackupJobSession'}, $common);
        }

        $logger->debug("Processing vms in job : ".$_->{'Name'});
        # Process VM Datas
        if(ref($jobs_entity_details->{'JobInfo'}->{'BackupJobInfo'}->{'Includes'}->{'ObjectInJob'}) eq 'ARRAY'){
          foreach (@{$jobs_entity_details->{'JobInfo'}->{'BackupJobInfo'}->{'Includes'}->{'ObjectInJob'}}){
            generate_jobs_vm_xml($_, $jobs_entity_details->{'Name'}, $common);
          }
        }else{
          generate_jobs_vm_xml($jobs_entity_details->{'JobInfo'}->{'BackupJobInfo'}->{'Includes'}->{'ObjectInJob'}, $jobs_entity_details->{'Name'}, $common);
        }

      }
      # Debug on job count processed
      $logger->debug("Job number processed : ".$count);

      # Get vmRestorePoints
      my $vm_restore_point = send_api_query($server_url, $veeam_api_references{"veeam_vm_restore_point"}, $session_id, "");

      # Process vm restore point
      foreach (@{$vm_restore_point->{'Ref'}}){
        $logger->debug("Process vm restore points : ".$_->{'Name'});

        # Get links infos
        my $backup_server_name = "";
        my $creation_date = "";
        my $file_reference = "";
        my $vapp_name = "";

        # Iterate on link to get datas
        foreach (@{$_->{'Links'}->{'Link'}}){

          switch ($_->{'Type'}) {
            case ("BackupServerReference") {$backup_server_name = $_->{'Name'}; next}
            case ("RestorePointReference") {$creation_date = $_->{'Name'}; next}
            case ("BackupFileReference") {$file_reference = $_->{'Name'}; next}
            case ("VAppRestorePoint") {$vapp_name = $_->{'Name'}; next}
          }
        }

        # Debug restore point
        $logger->debug("Process restore point : ".$_->{'Name'});

        # Add XML
        push @{$common->{xmltags}->{VEEAM_VM_RESTORE_POINT}},
        {
           NAME => [$_->{'Name'}],
           UID => [$_->{'UID'}],
           BACKUP_SERVER => [$backup_server_name],
           VAPP_NAME => [$vapp_name],
           FILE_REFERENCE => [$file_reference],
           CREATION_DATE => [$creation_date],
        };

      }


  }

}

sub generate_jobs_vm_xml
{

  my $jobs_vm_data;
  my $job_name;
  my $inventory_common;

  # Get passed arguments
  ($jobs_vm_data, $job_name, $inventory_common) = @_;

  # Add XML
  push @{$inventory_common->{xmltags}->{VEEAM_JOBS_VMS}},
  {
     NAME => [$jobs_vm_data->{'Name'}],
     DISPLAY_NAME => [$jobs_vm_data->{'DisplayName'}],
     JOB_NAME => [$job_name],
     HIERARCHY_REF => [$jobs_vm_data->{'HierarchyObjRef'}],
     VM_UID => [$jobs_vm_data->{'ObjectInJobId'}],
  };

}
sub generate_jobs_backup_sessions_xml
{

  my $backup_sessions_data;
  my $inventory_common;

  # Get passed arguments
  ($backup_sessions_data, $inventory_common) = @_;

  # Add XML
  push @{$inventory_common->{xmltags}->{VEEAM_JOBS_BACKUP_SESSIONS}},
  {
     NAME => [$backup_sessions_data->{'Name'}],
     UID => [$backup_sessions_data->{'UID'}],
     JOB_NAME => [$backup_sessions_data->{'JobName'}],
     JOB_TYPE => [$backup_sessions_data->{'JobType'}],
     RESULT => [$backup_sessions_data->{'Result'}],
     RETRY_ENABLED=> [$backup_sessions_data->{'IsRetry'}],
     STATE => [$backup_sessions_data->{'State'}],
     CREATION_TIME => [$backup_sessions_data->{'CreationTimeUTC'}],
     END_TIME => [$backup_sessions_data->{'EndTimeUTC'}],
  };

}

sub generate_backup_servers_xml
{
  my $backup_server_data;
  my $inventory_common;

  # Get passed arguments
  ($backup_server_data, $inventory_common) = @_;

  # Add XML
  push @{$inventory_common->{xmltags}->{VEEAM_BACKUP_SERVERS}},
  {
     NAME => [$backup_server_data->{'Name'}],
     UID => [$backup_server_data->{'UID'}],
  };
}

sub replace_string_to
{

  my $initial_string;
  my $replace_from;
  my $replace_to;

  # Get passed arguments
  ($initial_string, $replace_from, $replace_to) = @_;

  $replace_from = quotemeta $replace_from; # escape regex metachars if present

  $initial_string =~ s/$replace_from/$replace_to/g;

  return $initial_string;

}

# Auth to the veeam server
sub send_auth_api_query
{
  # Get passed arguments
  ($server_endpoint, $restpath, $auth_dig) = @_;

  $lwp_useragent = LWP::UserAgent->new;

  # set custom HTTP request header fields
  $req = HTTP::Request->new(POST => $server_endpoint . $restpath);
  $req->header('authorization' => "Basic $auth_dig");
  $req->header('cache-control' => 'no-cache');
  $req->header('Content_Length' => 0);
  $req->header('Content_Type' => 'text/xml');

  # Disable SSL Verify hostname
  $lwp_useragent->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);

  $resp = $lwp_useragent->request($req);
  if ($resp->is_success) {

      # return Veeam api token
      return $resp->{"_headers"}->{"x-restsvcsessionid"};
  }
  else {
      return $resp->message;
  }
}

# Query api and return the xml decoded
sub send_api_query
{

  my $filter;

  # Get passed arguments
  ($server_endpoint, $restpath, $session_id, $filter) = @_;

  $lwp_useragent = LWP::UserAgent->new;

  # set custom HTTP request header fields
  $req = HTTP::Request->new(GET => $server_endpoint . $restpath . $filter);

  $req->header('cache-control' => 'no-cache');
  $req->header('X-RestSvcSessionId' => $session_id);
  $req->header('Content_Length' => 0);
  $req->header('Content_Type' => 'text/xml');

  # Disable SSL Verify hostname
  $lwp_useragent->ssl_opts( verify_hostname => 0 ,SSL_verify_mode => 0x00);

  $resp = $lwp_useragent->request($req);
  if ($resp->is_success) {
      $message = $resp->decoded_content;

      my $data = XMLin($message);
      return $data;
  }
  else {
      return $resp->message;
  }
}
