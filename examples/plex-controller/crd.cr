module Spoved::Plex
  @[Kube::Builder(group: "plex.spoved.io", version: "v1alpha1", generate: true)]
  module V1alpha1
    @[Kube::Builder(root: true, subresource: Status)]
    @[Kube::Builder(:printcolumn, name: "Created", type: Bool, jsonpath: "status.created")]
    @[Kube::Builder(:printcolumn, name: "Healthy", type: Bool, jsonpath: "status.healthy")]
    class MediaServer < ::K8S::Kubernetes::Resource
      property spec : Spec? = nil
      property status : Status? = nil

      class Spec
        property image : K8S::Types::ImageSpec

        # Hostname Sets the hostname inside the docker container. For example -h PlexServer will set the servername
        # to PlexServer. Not needed in Host Networking.
        property hostname : String? = nil

        # Set the timezone inside the container. For example: Europe/London. The complete list
        # can be found here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        property timezone : String? = nil

        # ClaimToken is the claim token for the server to obtain a real server token.
        # If not provided, server is will not be automatically logged in. If server is already
        # logged in, this parameter is ignored. You can obtain a claim token to login your server
        # to your plex account by visiting https://www.plex.tv/claim.
        @[::JSON::Field(key: "claimToken")]
        @[::YAML::Field(key: "claimToken")]
        property claim_token : String? = nil

        # AdvertiseIPs This variable defines the additional IPs on which the server may
        # be be found. For example: http://10.1.1.23:32400. This adds to the list where
        # the server advertises that it can be found. This is only needed in Bridge Networking.
        @[::JSON::Field(key: "advertiseIps")]
        @[::YAML::Field(key: "advertiseIps")]
        property advertise_ips : Array(String)? = nil

        # PlexUser is the user id of the plex user created inside the container.
        @[::JSON::Field(key: "plexUser")]
        @[::YAML::Field(key: "plexUser")]
        property plex_user : Int32? = nil

        # PlexGroup is the group id of the plex group created inside the container.
        @[::JSON::Field(key: "plexGroup")]
        @[::YAML::Field(key: "plexGroup")]
        property plex_group : Int32? = nil

        # ChangeConfigDirOwnership is to change ownership of config directory to the plex user.
        # Defaults to true. If you are certain permissions are already set such that the plex
        # user within the container can read/write data in it's config directory,
        # you can set this to false to speed up the first run of the container.
        @[::JSON::Field(key: "changeConfigDirOwnership")]
        @[::YAML::Field(key: "changeConfigDirOwnership")]
        property change_config_dir_ownership : Bool? = nil

        # AllowedNetworks IP/netmask entries which allow access to the server without requiring
        # authorization. We recommend you set this only if you do not sign in your server. For
        # example 192.168.1.0/24,172.16.0.0/16 will allow access to the entire 192.168.1.x
        # range and the 172.16.x.x range. Note: If you are using Bridge networking, then
        # localhost will appear to plex as coming from the docker networking gateway
        # which is often 172.16.0.1.
        @[::JSON::Field(key: "allowedNetworks")]
        @[::YAML::Field(key: "allowedNetworks")]
        property allowed_networks : Array(String)? = nil

        # Volumes defines the pre-existing or new VolumeSpecs for the MediaServer
        property volumes : Array(VolumesSpec)? = nil

        include ::K8S::Types::PodConfigurationSpec::Fields
      end

      # Status defines the observed state of MediaServer
      class Status
        property created : Bool
        property healthy : Bool
      end

      # VolumesSpec defines the MediaServer volumes
      class VolumesSpec
        # ConfigVolume is the path where you wish Plex Media Server to store its configuration data.
        # This database can grow to be quite large depending on the size of your media collection.
        # This is usually a few GB but for large libraries or libraries where index files are
        # generated, this can easily hit the 100s of GBs. If you have an existing database
        # directory see the section below on the directory setup. Note: the underlying filesystem
        # needs to support file locking. This is known to not be default enabled on remote filesystems
        # like NFS, SMB, and many many others. The 9PFS filesystem used by FreeNAS Corral is known
        # to work but the vast majority will result in database corruption. Use a network share at your own risk.
        @[::JSON::Field(key: "config")]
        @[::YAML::Field(key: "config")]
        property config_volume : K8S::Types::VolumeSpec? = nil

        # TranscodeVolume is the path where you would like Plex Media Server to store its transcoder temp files.
        # If not provided, the storage space within the container will be used. Expect sizes in the 10s of GB.
        @[::JSON::Field(key: "transcode")]
        @[::YAML::Field(key: "transcode")]
        property transcode_volume : K8S::Types::VolumeSpec? = nil

        # LogVolume is the path where you would like Plex Media Server to store its logs.
        @[::JSON::Field(key: "log")]
        @[::YAML::Field(key: "log")]
        property log_volume : K8S::Types::VolumeSpec? = nil

        # DataVolume is the path where you would like Plex Media Server to store its data files.
        # If not provided, the storage space within the container will be used. Expect sizes in the 10s of GB.
        @[::JSON::Field(key: "data")]
        @[::YAML::Field(key: "data")]
        property data_volume : K8S::Types::VolumeSpec? = nil

        # MediaVolumes is used to provided media into the container. The exact structure of
        # how the media is organized and presented inside the container is a matter of user
        # preference. You can define as many or as few of these volumes as required to provide
        # your media to the container.
        @[::JSON::Field(key: "media")]
        @[::YAML::Field(key: "media")]
        property media_volumes : Array(K8S::Types::VolumeSpec)? = nil
      end
    end

    @[Kube::Builder(root: true)]
    class MediaServerList < ::K8S::Kubernetes::ResourceList(MediaServer); end
  end
end
