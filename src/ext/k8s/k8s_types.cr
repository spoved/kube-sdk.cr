require "json"
require "yaml"
require "k8s"

::K8S::Kubernetes::Resource.define_object("ImageSpec", "K8S::Types", [
  {name: "name", kind: String, nilable: false},
  {name: "pull_policy", kind: String, nilable: true, key: "imagePullPolicy"},
  {name: "pull_secret", kind: String, nilable: true, key: "imagePullSecret"},
])

# Common spec structs for custom resource definitions
module K8S::Types
  # ImageSpec defines parameters for docker image executed on Kubernetes
  struct ImageSpec
    module Fields
      # Docker Image location including the tag
      abstract def name : String
      # Image pull policy. One of Always, Never, IfNotPresent. Defaults to Always if :latest tag is specified, or IfNotPresent otherwise. Cannot be updated. More info: https://kubernetes.io/docs/concepts/containers/images#updating-images
      abstract def pull_policy : String?
      # optional list of references to secrets in the same namespace to use for pulling the image
      abstract def pull_secret : String?

      macro included
        K8S::Kubernetes::Resource.define_prop(name: "name", kind: String, nilable: false)
        K8S::Kubernetes::Resource.define_prop(name: "pull_policy", kind: String, nilable: true, key: "imagePullPolicy")
        K8S::Kubernetes::Resource.define_prop(name: "pull_secret", kind: String, nilable: true, key: "imagePullSecret")
      end
    end

    include Fields

    def self.new(name : String, pull_policy : String? = nil, pull_secret : String? = nil)
      new_fields = {
        name:            name,
        imagePullPolicy: pull_policy,
        imagePullSecret: pull_secret,
      }.to_h.reject { |_, v| v.nil? }
      new(new_fields)
    end
  end
end

::K8S::Kubernetes::Resource.define_object("PodSchedulingSpec", "K8S::Types", [
  {name: "affinity", kind: K8S::Api::Core::V1::Affinity, nilable: true, description: "group of affinity scheduling rules"},
  {name: "tolerations", kind: Array(K8S::Api::Core::V1::Toleration), nilable: true, description: "If specified, the pod's tolerations"},
  {name: "node_selector", kind: Hash(String, K8S::Api::Core::V1::NodeSelector), nilable: true, key: "nodeSelector"},
  {name: "node_name", kind: String, nilable: true, key: "nodeName"},
])

module K8S::Types
  # PodSchedulingSpec encapsulates the scheduling related fields of a Kubernetes Pod
  struct PodSchedulingSpec
    module Fields
      # group of affinity scheduling rules
      abstract def affinity : K8S::Api::Core::V1::Affinity?

      # If specified, the pod's tolerations
      abstract def tolerations : Array(K8S::Api::Core::V1::Toleration)?

      # A node selector represents the union of the results of
      # one or more label queries over a set of nodes; that is,
      # it represents the OR of the selectors represented by the
      # node selector terms.
      abstract def node_selector : Hash(String, K8S::Api::Core::V1::NodeSelector)?

      # NodeName is a request to schedule this pod onto a specific node. If it is non-empty,
      # the scheduler simply schedules this pod onto that node, assuming that it fits resource
      # requirements.
      abstract def node_name : String?

      macro included
        K8S::Kubernetes::Resource.define_prop(name: "affinity", kind: K8S::Api::Core::V1::Affinity, nilable: true, description: "group of affinity scheduling rules")
        K8S::Kubernetes::Resource.define_prop(name: "tolerations", kind: Array(K8S::Api::Core::V1::Toleration), nilable: true, description: "If specified, the pod's tolerations")
        K8S::Kubernetes::Resource.define_prop(name: "node_selector", kind: Hash(String, K8S::Api::Core::V1::NodeSelector), nilable: true, key: "nodeSelector")
        K8S::Kubernetes::Resource.define_prop(name: "node_name", kind: String, nilable: true, key: "nodeName")
      end
    end

    include Fields

    def self.new(affinity = nil, tolerations = nil, node_selector = nil, node_name = nil)
      new_fields = {
        affinity:     affinity,
        tolerations:  tolerations,
        nodeSelector: node_selector,
        nodeName:     node_name,
      }.to_h.reject { |_, v| v.nil? }
      new(new_fields)
    end
  end
end

::K8S::Kubernetes::Resource.define_object("VolumeSpec", "K8S::Types", [
  {name: "name", kind: String, nilable: false},
  {name: "volume_source", kind: K8S::Api::Core::V1::Volume, nilable: true, key: "volumeSource"},
  {name: "persistent_volume_claim_spec", kind: K8S::Api::Core::V1::PersistentVolumeClaimSpec, nilable: true, key: "persistentVolumeClaimSpec"},
])

module K8S::Types
  # VolumeSpec contains the Volume Definition used for the pod.
  # It can point to an EmptyDir, HostPath, already existing PVC or PVC
  # to be created.
  struct VolumeSpec
    GENERATED_PVC = "GENERATED"

    module Fields
      # Volume's name.
      # Must be a DNS_LABEL and unique within the pod.
      # More info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names
      abstract def name : String?

      # VolumeSource represents the source of the volume, e.g. EmptyDir,
      # HostPath, Ceph, PersistentVolumeClaim, etc.
      # PersistentVolumeClaim.claimName can be set to point to an already
      # existing PVC or could be set to 'GENERATED'. When set to 'GENERATED'
      # The PVC will be created based on the PersistentVolumeClaimSpec provided
      # to the VolumeSpec.
      # More info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims
      abstract def volume_source : K8S::Api::Core::V1::Volume?

      # PersistentVolumeClaimSpec describes the persistent volume claim that will be
      # created and used by the pod. If specified, the VolumeSource.PersistentVolumeClaim's
      # claimName must be set to 'GENERATED'
      abstract def persistent_volume_claim_spec : K8S::Api::Core::V1::PersistentVolumeClaimSpec?

      # Validate method validates that the provided VolumeSpec meets the requirements:
      # * If PersistentVolumeClaimSpec is provided, then the VolumeSource's
      # * PersistentVolumClaim's ClaimName should be set to GeneratedPVC
      def _init_validate!
        if self.persistent_volume_claim_spec
          source = self.volume_source
          if !source.nil? && source.persistent_volume_claim && source.persistent_volume_claim.not_nil!.claim_name != GENERATED_PVC
            return false, K8S::Error.new("persistent_volume_claim_spec is set but the claim name is not #{GENERATED_PVC}")
          end
        end
        return true, nil
      end

      macro included
        K8S::Kubernetes::Resource.define_prop(name: "name", kind: String, nilable: false)
        K8S::Kubernetes::Resource.define_prop(name: "volume_source", kind: K8S::Api::Core::V1::Volume, nilable: true)
        K8S::Kubernetes::Resource.define_prop(name: "persistent_volume_claim_spec", kind: K8S::Api::Core::V1::PersistentVolumeClaimSpec, nilable: true)
      end
    end

    include Fields

    def self.new(name : String, volume_source : K8S::Api::Core::V1::Volume? = nil, persistent_volume_claim_spec : K8S::Api::Core::V1::PersistentVolumeClaimSpec? = nil)
      new_fields = {
        name:                      name,
        volumeSource:              volume_source,
        persistentVolumeClaimSpec: persistent_volume_claim_spec,
      }.to_h.reject { |_, v| v.nil? }
      new(new_fields)
    end
  end
end

::K8S::Kubernetes::Resource.define_object("PodConfigurationSpec", "K8S::Types", [
  {name: "annotations", kind: Hash(String, String), nilable: true},
  {name: "labels", kind: Hash(String, String), nilable: true},
  {name: "scheduling", kind: K8S::Types::PodSchedulingSpec, nilable: true},
  {name: "resources", kind: K8S::Api::Core::V1::ResourceRequirements, nilable: true},
])

module K8S::Types
  # PodConfigurationSpec contains the configuration for the pods
  struct PodConfigurationSpec
    module Fields
      # Annotations is an unstructured key value map stored with a resource that may be set by external tools to store and retrieve arbitrary metadata. They are not queryable and should be preserved when modifying objects. More info: [http://kubernetes.io/docs/user-guide/annotations](http://kubernetes.io/docs/user-guide/annotations)
      abstract def annotations : Hash(String, String)?

      # Map of string keys and values that can be used to organize and categorize (scope and select) objects. May match selectors of replication controllers and services. More info: [http://kubernetes.io/docs/user-guide/labels](http://kubernetes.io/docs/user-guide/labels)
      abstract def labels : Hash(String, String)?

      # Scheduling contains options to determine which node the pod should be scheduled on
      abstract def scheduling : K8S::Types::PodSchedulingSpec?

      # Resources required by the pod container
      # More info: https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/
      abstract def resources : K8S::Api::Core::V1::ResourceRequirements?

      macro included
        K8S::Kubernetes::Resource.define_prop(name: "annotations", kind: Hash(String, String), nilable: true)
        K8S::Kubernetes::Resource.define_prop(name: "labels", kind: Hash(String, String), nilable: true)
        K8S::Kubernetes::Resource.define_prop(name: "scheduling", kind: K8S::Types::PodSchedulingSpec, nilable: true)
        K8S::Kubernetes::Resource.define_prop(name: "resources", kind: K8S::Api::Core::V1::ResourceRequirements, nilable: true)
      end
    end

    include Fields
  end
end
