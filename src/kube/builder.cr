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

macro finished
  # {% objs = [] of TypeNode %}
  # {% for obj in Object.all_subclasses %}
  #   {% if obj.annotation(Kube::Builder) && !objs.includes?(obj) %}
  #     {% objs << obj %}
  #   {% end %}
  # {% end %}

  # {% groups = {} of StringLiteral => HashLiteral %}
  # {% for obj in objs %}
  #   {% for anno in obj.annotations(Kube::Builder) %}
  #     {% if anno[:group] && anno[:root] %}
  #       {% if !groups[anno[:group]] %}{% groups[anno[:group]] = {} of StringLiteral => HashLiteral %}{% end %}
  #       {% if !groups[anno[:group]][anno[:version]] %}{% groups[anno[:group]][anno[:version]] = {} of StringLiteral => HashLiteral %}{% end %}
  #       {% groups[anno[:group]][anno[:version]][obj.id] = obj %}
  #     {% end %}
  #   {% end %}
  # {% end %}


  # # Add resource annotations
  # {% for group, vers in groups %}
  #   {% for ver, items in vers %}
  #     {% for name, item in items %}
  #       {% kind = name.id.split("::").last %}
  #       {% annos = item.annotations(Kube::Builder) %}
  #       # api_group = group.split(".").reverse.join(".")
  #       {% vars = {} of StringLiteral => Def %}

  #       {% for meth in item.resolve.methods.select { |m| m.name =~ /=$/ && m.body.is_a?(Assign) && m.body.target.is_a?(InstanceVar) } %}
  #         {% arg = meth.args[0] %}
  #         {% vars[arg.name] = meth %}
  #       {% end %}
  #       {% for anc in item.ancestors %}
  #         {% for meth in anc.resolve.methods.select { |m| m.name =~ /=$/ && m.body.is_a?(Assign) && m.body.target.is_a?(InstanceVar) } %}
  #           {% arg = meth.args[0] %}
  #           {% vars[arg.name] = meth %}
  #         {% end %}
  #       {% end %}

  #       {% p vars %}
  #       @[::K8S::GroupVersionKind(group: {{group}}, kind: {{kind}}, version: {{ver}})]
  #       @[::K8S::Properties(
  #         api_version: {type: String, nilable: true, key: "apiVersion", getter: false, setter: false},
  #         kind: {type: String, nilable: true, key: "kind", getter: false, setter: false},
  #         metadata: {type: Apimachinery::Apis::Meta::V1::ObjectMeta, nilable: true, key: "metadata", getter: false, setter: false},
  #         {% for vname, meth in vars %} {% var = meth.args[0] %}
  #         {{vname.id}}: {type: {{var.restriction.id}}, nilable: {{var.restriction.nilable?}}, getter: false, setter: false },
  #         {% end %}
  #       )]
  #       class {{name.id}}
  #         include ::K8S::Kubernetes::Resource::Object
  #         include ::JSON::Serializable
  #         include ::JSON::Serializable::Unmapped
  #         include ::YAML::Serializable
  #         include ::YAML::Serializable::Unmapped

  #         @[::JSON::Field(key: "apiVersion")]
  #         @[::YAML::Field(key: "apiVersion")]
  #         getter api_version : String = {{ver}}
  #         getter kind : String = {{kind}}

  #         # Standard object's metadata. More info:
  #         # [https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata](https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata)
  #         property metadata : K8S::Apimachinery::Apis::Meta::V1::ObjectMeta?

  #         def initialize(*,
  #           {% for vname, meth in vars %} {% var = meth.args[0] %}
  #             @{{vname}} {% if var.restriction %}: {{var.restriction.id}}{% end %} {% if var.default_value %} = {{var.default_value.id}}{% end %},
  #           {% end %}
  #           @metadata : Apimachinery::Apis::Meta::V1::ObjectMeta | Nil = nil)
  #         end
  #       end

  #       @[::K8S::GroupVersionKind(group: {{group}}, kind: {{kind}}, version: {{ver}})]
  #       class {{name.id}}List < ::K8S::Kubernetes::ResourceList({{name.id}}); end

  #     {% end %}
  #   {% end %}
  # {% end %}
end
