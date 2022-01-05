# Used to define your CRD generation
#
# ```
# @[Kube::Builder(group: "plex.spoved.io", version: "v1alpha1", generate: true)]
# module V1alpha1
#   @[Kube::Builder(root: true, subresource: Status)]
#   @[Kube::Builder(:printcolumn, name: "Created", type: Bool, jsonpath: "status.created")]
#   @[Kube::Builder(:printcolumn, name: "Healthy", type: Bool, jsonpath: "status.healthy")]
#   class MediaServer < ::K8S::Kubernetes::Resource
#     property spec : Spec
#
#     class Spec
#     end
#
#     class Status
#       property created : Bool
#       property healthy : Bool
#     end
#   end
# end
# ```
annotation Kube::Builder; end

# macro finished
