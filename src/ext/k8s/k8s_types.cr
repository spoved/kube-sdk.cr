require "json"
require "yaml"

# Common spec values for custom resource definitions
module K8S::Types
  # ImageSpec defines parameters for docker image executed on Kubernetes
  class ImageSpec
    module Fields
      # Docker Image location including the tag
      property name : String

      @[::JSON::Field(key: "pull_policy", emit_null: false)]
      @[::YAML::Field(key: "pull_policy", emit_null: false)]
      property pull_policy : String?

      # optional list of references to secrets in the same namespace to use for pulling the image
      @[::JSON::Field(key: "pull_secret", emit_null: false)]
      @[::YAML::Field(key: "pull_secret", emit_null: false)]
      property pull_secret : String?
    end

    include Fields

    def initialize(@name, @pull_policy = nil, @pull_secret = nil); end
  end

  # PodSchedulingSpec encapsulates the scheduling related fields of a Kubernetes Pod
  class PodSchedulingSpec
    module Fields
      @[::JSON::Field(emit_null: false)]
      @[::YAML::Field(emit_null: false)]
      # group of affinity scheduling rules
      property affinity : K8S::Api::Core::V1::Affinity? = nil

      @[::JSON::Field(emit_null: false)]
      @[::YAML::Field(emit_null: false)]
      # If specified, the pod's tolerations
      property tolerations : Array(K8S::Api::Core::V1::Toleration)? = nil

      # A node selector represents the union of the results of
      # one or more label queries over a set of nodes; that is,
      # it represents the OR of the selectors represented by the
      # node selector terms.
      @[::JSON::Field(key: "nodeSelector", emit_null: false)]
      @[::YAML::Field(key: "nodeSelector", emit_null: false)]
      property node_selector : Hash(String, K8S::Api::Core::V1::NodeSelector)? = nil

      # NodeName is a request to schedule this pod onto a specific node. If it is non-empty,
      # the scheduler simply schedules this pod onto that node, assuming that it fits resource
      # requirements.
      @[::JSON::Field(key: "nodeName", emit_null: false)]
      @[::YAML::Field(key: "nodeName", emit_null: false)]
      property node_name : String? = nil
    end

    include Fields
  end

  # VolumeSpec contains the Volume Definition used for the pod.
  # It can point to an EmptyDir, HostPath, already existing PVC or PVC
  # to be created.
  class VolumeSpec
    GENERATED_PVC = "GENERATED"

    module Fields
      # Volume's name.
      # Must be a DNS_LABEL and unique within the pod.
      # More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
      @[::JSON::Field(key: "name", emit_null: false)]
      @[::YAML::Field(key: "name", emit_null: false)]
      property name : String?

      # VolumeSource represents the source of the volume, e.g. EmptyDir,
      # HostPath, Ceph, PersistentVolumeClaim, etc.
      # PersistentVolumeClaim.claimName can be set to point to an already
      # existing PVC or could be set to 'GENERATED'. When set to 'GENERATED'
      # The PVC will be created based on the PersistentVolumeClaimSpec provided
      # to the VolumeSpec.
      # More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
      @[::JSON::Field(key: "volumeSource", emit_null: false)]
      @[::YAML::Field(key: "volumeSource", emit_null: false)]
      property volume_source : K8S::Api::Core::V1::Volume?

      # PersistentVolumeClaimSpec describes the persistent volume claim that will be
      # created and used by the pod. If specified, the VolumeSource.PersistentVolumeClaim's
      # claimName must be set to 'GENERATED'
      @[::JSON::Field(key: "persistentVolumeClaimSpec", emit_null: false)]
      @[::YAML::Field(key: "persistentVolumeClaimSpec", emit_null: false)]
      property persistent_volume_claim_spec : K8S::Api::Core::V1::PersistentVolumeClaimSpec?

      # Validate method validates that the provided VolumeSpec meets the requirements:
      # * If PersistentVolumeClaimSpec is provided, then the VolumeSource's
      # * PersistentVolumClaim's ClaimName should be set to GeneratedPVC
      def validate
        if self.persistent_volume_claim_spec
          source = self.volume_source
          if !source.nil? && source.persistent_volume_claim && source.persistent_volume_claim.not_nil!.claim_name != GENERATED_PVC
            return false, K8S::Error.new("persistent_volume_claim_spec is set but the claim name is not #{GENERATED_PVC}")
          end
        end
        return true, nil
      end
    end

    include Fields
  end

  # PodConfigurationSpec contains the configuration for the pods
  class PodConfigurationSpec
    module Fields
      # Annotations is an unstructured key value map stored with a resource that may be set by external tools to store and retrieve arbitrary metadata. They are not queryable and should be preserved when modifying objects. More info: [http://kubernetes.io/docs/user-guide/annotations](http://kubernetes.io/docs/user-guide/annotations)
      @[::JSON::Field(key: "annotations", emit_null: false)]
      @[::YAML::Field(key: "annotations", emit_null: false)]
      property annotations : Hash(String, String) | Nil

      # Map of string keys and values that can be used to organize and categorize (scope and select) objects. May match selectors of replication controllers and services. More info: [http://kubernetes.io/docs/user-guide/labels](http://kubernetes.io/docs/user-guide/labels)
      @[::JSON::Field(key: "labels", emit_null: false)]
      @[::YAML::Field(key: "labels", emit_null: false)]
      property labels : Hash(String, String) | Nil

      # Scheduling contains options to determine which node the pod should be scheduled on
      @[::JSON::Field(key: "scheduling", emit_null: false)]
      @[::YAML::Field(key: "scheduling", emit_null: false)]
      property scheduling : K8S::Types::PodSchedulingSpec?

      # Resources required by the pod container
      # More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
      @[::JSON::Field(key: "resources", emit_null: false)]
      @[::YAML::Field(key: "resources", emit_null: false)]
      property resources : K8S::Api::Core::V1::ResourceRequirements?
    end

    include Fields
  end
end
