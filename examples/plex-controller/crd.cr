module Spoved::Plex
  module V1alpha1
    # VolumesSpec defines the MediaServer volumes
    struct VolumesSpec < ::K8S::Kubernetes::Object
      # ConfigVolume is the path where you wish Plex Media Server to store its configuration data.
      # This database can grow to be quite large depending on the size of your media collection.
      # This is usually a few GB but for large libraries or libraries where index files are
      # generated, this can easily hit the 100s of GBs. If you have an existing database
      # directory see the section below on the directory setup. Note: the underlying filesystem
      # needs to support file locking. This is known to not be default enabled on remote filesystems
      # like NFS, SMB, and many many others. The 9PFS filesystem used by FreeNAS Corral is known
      # to work but the vast majority will result in database corruption. Use a network share at your own risk.
      K8S::Kubernetes::Resource.define_prop(config_volume : K8S::Types::VolumeSpec? = nil, key: "config")

      # TranscodeVolume is the path where you would like Plex Media Server to store its transcoder temp files.
      # If not provided, the storage space within the container will be used. Expect sizes in the 10s of GB.
      K8S::Kubernetes::Resource.define_prop(transcode_volume : K8S::Types::VolumeSpec? = nil, key: "transcode")

      # LogVolume is the path where you would like Plex Media Server to store its logs.
      K8S::Kubernetes::Resource.define_prop(log_volume : K8S::Types::VolumeSpec? = nil, key: "log")

      # DataVolume is the path where you would like Plex Media Server to store its data files.
      # If not provided, the storage space within the container will be used. Expect sizes in the 10s of GB.
      K8S::Kubernetes::Resource.define_prop(data_volume : K8S::Types::VolumeSpec? = nil, key: "data")

      # MediaVolumes is used to provided media into the container. The exact structure of
      # how the media is organized and presented inside the container is a matter of user
      # preference. You can define as many or as few of these volumes as required to provide
      # your media to the container.
      K8S::Kubernetes::Resource.define_prop(media_volumes : Array(K8S::Types::VolumeSpec)? = nil, key: "media")
    end

    # MediaServerSpec defines the MediaServer spec
    struct MediaServerSpec < ::K8S::Kubernetes::Object
      K8S::Kubernetes::Resource.define_prop(image : K8S::Types::ImageSpec)

      # Hostname Sets the hostname inside the docker container. For example -h PlexServer will set the servername
      # to PlexServer. Not needed in Host Networking.
      K8S::Kubernetes::Resource.define_prop(hostname : String? = nil)

      # Set the timezone inside the container. For example: Europe/London. The complete list
      # can be found here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      K8S::Kubernetes::Resource.define_prop(timezone : String? = nil)

      # ClaimToken is the claim token for the server to obtain a real server token.
      # If not provided, server is will not be automatically logged in. If server is already
      # logged in, this parameter is ignored. You can obtain a claim token to login your server
      # to your plex account by visiting https://www.plex.tv/claim.
      K8S::Kubernetes::Resource.define_prop(claim_token : String? = nil, key: "claimToken")

      # AdvertiseIPs This variable defines the additional IPs on which the server may
      # be be found. For example: http://10.1.1.23:32400. This adds to the list where
      # the server advertises that it can be found. This is only needed in Bridge Networking.
      K8S::Kubernetes::Resource.define_prop(advertise_ips : Array(String)? = nil, key: "advertiseIps")

      # PlexUser is the user id of the plex user created inside the container.
      K8S::Kubernetes::Resource.define_prop(plex_user : Int32? = nil, key: "plexUser")

      # PlexGroup is the group id of the plex group created inside the container.
      K8S::Kubernetes::Resource.define_prop(plex_group : Int32? = nil, key: "plexGroup")

      # ChangeConfigDirOwnership is to change ownership of config directory to the plex user.
      # Defaults to true. If you are certain permissions are already set such that the plex
      # user within the container can read/write data in it's config directory,
      # you can set this to false to speed up the first run of the container.
      K8S::Kubernetes::Resource.define_prop(change_config_dir_ownership : Bool? = nil, key: "changeConfigDirOwnership")

      # AllowedNetworks IP/netmask entries which allow access to the server without requiring
      # authorization. We recommend you set this only if you do not sign in your server. For
      # example 192.168.1.0/24,172.16.0.0/16 will allow access to the entire 192.168.1.x
      # range and the 172.16.x.x range. Note: If you are using Bridge networking, then
      # localhost will appear to plex as coming from the docker networking gateway
      # which is often 172.16.0.1.
      K8S::Kubernetes::Resource.define_prop(allowed_networks : Array(String)? = nil, key: "allowedNetworks")

      # Volumes defines the pre-existing or new VolumeSpecs for the MediaServer
      K8S::Kubernetes::Resource.define_prop(volumes : Array(Spoved::Plex::V1alpha1::VolumesSpec)? = nil)

      include ::K8S::Types::PodConfigurationSpec::Fields
    end
  end
end

Kube::SDK.define_crd(
  group: "plex.spoved.io", version: "v1alpha1",
  kind: MediaServer, plural: "mediaservers",
  scope: :namespaced,
  namespace: ::Spoved::Plex::V1alpha1,
  properties: {
    # Use an existing `::K8S::Kubernetes::Object`
    spec: Spoved::Plex::V1alpha1::MediaServerSpec,
    # Define a new `::K8S::Kubernetes::Object`
    status: {
      kind:        MediaServerStatus,
      required:    false,
      subresource: true,
      description: "Defines the observed state of MediaServer",
      properties:  {
        created: Bool,
        healthy: Bool,
      },
    },
  },
  printcolumns: [
    {name: "Created", type: Bool, jsonpath: "status.created"},
    {name: "Healthy", type: Bool, jsonpath: "status.healthy"},
  ]
)
