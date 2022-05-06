require "spoved/ext/string"

# Defines kubernetes api methods for an object.
annotation ::K8S::Action; end

module Kube::SDK
  # :nodoc:
  macro _define_resource(kind, namespace, properties = [] of NamedTuple, description = nil, resource = false, api = nil)
    {% props = {} of String => NamedTuple %}
    {% for _properties in properties %}
      {% for vname, _def in _properties %}
        {% nilable = true %}{% default = nil %}{% json_key = nil %}{% subresource = false %}{% _sub_properties = nil %}
        {% required = false %}{% _getter = true %}{% _setter = true %}{% _description = nil %}
        {% if _def.is_a?(NamedTupleLiteral) %}
          {% type = _def[:kind] %}
          {% required = _def[:required].nil? ? false : _def[:required] %}
          {% nilable = !required %}
          {% default = _def[:default] %}
          {% json_key = _def[:name] || vname %}
          {% subresource = _def[:subresource] %}
          {% _sub_properties = _def[:properties] %}
          {% _getter = _def[:getter].nil? ? true : _def[:getter] %}
          {% _setter = _def[:setter].nil? ? true : _def[:setter] %}
          {% _description = _def[:description] %}
        {% else %}
          {% type = _def %}
          {% if type.is_a?(Path) && type.resolve? %}{% type = type.resolve %}{% nilable = type.resolve.nilable? %}{% end %}
          {% if type.is_a?(Generic) && type.resolve? %}{% type = type.resolve %}{% nilable = type.resolve.nilable? %}{% end %}
          {% if type.is_a?(Union) %}{% nilable = type.nilable? %}{% end %}
          {% required = !nilable %}
        {% end %}

        {% not_nilable_type = type.is_a?(Union) ? type.types.reject(&.resolve.nilable?).first : (type.is_a?(TypeNode) && type.union? ? type.union_types.reject(&.resolve.nilable?).first : type) %}
        {% props[vname.id] = {
             name: vname, kind: type.id, namespace: namespace,
             default: default, description: _description,
             subresource: subresource, properties: _sub_properties,
             type: type, not_nilable_type: not_nilable_type,
             required: required, nilable: nilable,
             json_key: json_key, getter: _getter, setter: _setter,
           } %}
      {% end %}
    {% end %}

    {% for name, prop in props %}{% if prop[:subresource] %}
      Kube::SDK._define_resource(
        kind: {{prop[:not_nilable_type]}},
        namespace: {{namespace}},
        description: {{prop[:description]}},
        resource: false,
        properties: [ {{prop[:properties].id}}],
      )
    {% end %}{% end %}

    {% if resource && api %}
      {% version = api[:version] %}
      {% group = api[:group] %}
      {% plural = api[:plural] %}

      @[::K8S::Action(name: "post", verb: "post",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: false,
        args: [{name: "context", type: String | Nil, default: nil}]
      )]
      @[::K8S::Action(name: "list", verb: "get",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: true,
        args: [{name: "context", type: String | Nil, default: nil},
              {name: "continue", type: String | Nil, default: nil},
              {name: "field_selector", type: String | Nil, default: nil},
              {name: "include_uninitialized", type: Bool | Nil, default: nil},
              {name: "label_selector", type: String | Nil, default: nil},
              {name: "limit", type: Int32 | Nil, default: nil},
              {name: "resource_version", type: String | Nil, default: nil},
              {name: "timeout_seconds", type: Int32 | Nil, default: nil},
              {name: "watch", type: Bool | Nil, default: nil},
              {name: "namespace", type: String, default: "default"}]
      )]
      @[::K8S::Action(name: "deletecollection", verb: "delete",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: true,
        args: [{name: "context", type: String | Nil, default: nil},
              {name: "continue", type: String | Nil, default: nil},
              {name: "field_selector", type: String | Nil, default: nil},
              {name: "include_uninitialized", type: Bool | Nil, default: nil},
              {name: "label_selector", type: String | Nil, default: nil},
              {name: "limit", type: Int32 | Nil, default: nil},
              {name: "resource_version", type: String | Nil, default: nil},
              {name: "timeout_seconds", type: Int32 | Nil, default: nil},
              {name: "watch", type: Bool | Nil, default: nil},
              {name: "namespace", type: String, default: "default"}]
      )]
      @[::K8S::Action(name: "get", verb: "get",
        path:%</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: true,
        args: [{name: "name", type: String},
              {name: "context", type: String | Nil, default: nil},
              {name: "exact", type: Bool | Nil, default: nil},
              {name: "export", type: Bool | Nil, default: nil},
              {name: "namespace", type: String, default: "default"}]
      )]
      @[::K8S::Action(name: "put", verb: "put",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: false,
        args: [{name: "context", type: String | Nil, default: nil}]
      )]
      @[::K8S::Action(name: "patch", verb: "path",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: false,
        args: [{name: "context", type: String | Nil, default: nil}]
      )]
      @[::K8S::Action(name: "delete", verb: "delete",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }>, toplevel: false,
        args: [{name: "api_version", type: String | Nil, default: nil},
              {name: "dry_run", type: Array(String) | Nil, default: nil},
              {name: "grace_period_seconds", type: Int32 | Nil, default: nil},
              {name: "kind", type: String | Nil, default: nil},
              {name: "orphan_dependents", type: Bool | Nil, default: nil},
              {name: "preconditions", type: Apimachinery::Apis::Meta::V1::Preconditions | Nil, default: nil},
              {name: "propagation_policy", type: String | Nil, default: nil},
              {name: "context", type: String | Nil, default: nil}]
      )]
      {% for name, prop in props %}{% if prop[:subresource] %}
      @[::K8S::Action(name: "get", verb: "get",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }/{{name.id}}>,
        toplevel: true,
        args: [{name: "name", type: String},
              {name: "context", type: String | Nil, default: nil}]
      )]
      @[::K8S::Action(name: "put", verb: "put",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }/{{name.id}}>,
        toplevel: false,
        args: [{name: "context", type: String | Nil, default: nil},
              {name: "dry_run", type: String | Nil, default: nil},
              {name: "field_manager", type: String | Nil, default: nil},
              {name: "field_validation", type: String | Nil, default: nil}]
      )]
      @[::K8S::Action(name: "patch", verb: "path",
        path: %</apis/#{ {{group}}.split(".").reverse.join(".") }/{{version.id}}/namespaces/{namespace}/#{ {{plural}} }/{{name.id}}>,
        toplevel: false,
        args: [{name: "context", type: String | Nil, default: nil},
              {name: "dry_run", type: String | Nil, default: nil},
              {name: "field_manager", type: String | Nil, default: nil},
              {name: "field_validation", type: String | Nil, default: nil},
              {name: "force", type: Bool | Nil, default: nil}]
      )]
      {% end %}{% end %}
    {% end %}
    {% if resource %}
      @[::Kube::Builder(
          generate: true, singular: {{kind.id.downcase.stringify}},
          {{**api}}
        )]
      ::K8S::Kubernetes::Resource.define_resource(
        group: {{group}}, kind: {{kind}}, version: {{version}},
        namespace: {{namespace}},
        properties: {{props.values}},
      )
    {% else %}
      ::K8S::Kubernetes::Resource.define_object(
        kind: {{kind}},
        namespace: {{namespace}},
        properties: {{props.values}},
      )
    {% end %}
  end

  macro define_crd(group, version, kind, properties, plural = nil, scope = :namespaced,
                   printcolumns = nil, validation = nil, description = nil, namespace = nil, **kwargs)

    {% if plural.nil? %}
      {% plural = kind.id.downcase %}
    {% end %}

    Kube::SDK._define_resource(
      kind: {{kind}},
      description: {{description}},
      namespace: {{namespace.id.stringify}},
      resource: true,
      api: {
        group: {{group}},
        version: {{version}},
        plural: {% if plural.nil? %} {{kind.id.downcase}}.pluralize {% else %} {{plural}} {% end %},
        scope: {{scope}},
        printcolumns: {{printcolumns}},
      },
      properties: [
        {{properties}}
      ]
    )

    ::K8S::Kubernetes::Resource.define_resource(
      group: {{group}}, kind: {{kind}}List, version: {{version}},
      namespace: {{namespace.id.stringify}},
      list: true,
      list_kind: {{namespace.id}}::{{kind.id}},
    )
  end

  macro define_resource(**kwargs)
    Kube::SDK._define_resource(**kwargs)
  end
end
