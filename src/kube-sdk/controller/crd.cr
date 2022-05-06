require "crinja"

module Kube::SDK::Controller::CRD
  spoved_logger

  extend self
  extend Spoved::SystemCmd

  # Will create a wrapper script to generate CRDs files.
  def generate_crds(**options)
    logger.info { "Generating crd manifests..." }

    script = Crinja.render({{read_file("#{__DIR__}/../../../templates/controller/crd/gen.cr.j2")}}, options)
    tempfile = File.tempfile("crd_gen", suffix: ".cr")
    begin
      File.write(tempfile.path, script)
      cmd = "cat #{tempfile.path} | crystal eval -Dk8s_v#{options[:k8s_ver]}"
      result = system_cmd(cmd)
      if result[:status]
        logger.info { "[OK] CRD manifests." }
      else
        logger.error { "[FAIL] CRD manifests." }
      end
    ensure
      tempfile.delete
    end
  end

  macro from_type(type)
    {% model = type.resolve %}
    {% klass = model.union_types.empty? ? model : model.union_types.reject(&.==(Nil)).first %}

    {% if klass <= Int32 || klass <= Int64 || klass <= Float32 || klass <= Float64 || klass <= Nil || klass <= UUID || klass <= Bool || klass <= String || klass <= URI || model <= Time %}
      Open::Api::Schema.new(Open::Api.get_open_api_type({{klass}}), format: Open::Api.get_open_api_format({{klass}}))
    {% elsif klass < K8S::Kubernetes::Object %}
      Kube::SDK::Controller::CRD.klass_to_schema({{klass}})
    {% elsif model <= Hash %}
      {% vvar = klass.type_vars.last.union_types.reject(&.==(Nil)).first %}
      {
        type: "object",
        additionalProperties: Kube::SDK::Controller::CRD.from_type({{vvar.id}})
      }
    {% elsif model <= Array %}
      {
        type: "array",
        items: Kube::SDK::Controller::CRD.from_type({{klass.type_vars.first}})
      }
    {% else %}
      {
        type: "object",
        {% if model.instance_vars.size > 0 %}
        properties: {
          {% for var in model.instance_vars %}
          "{{var.name}}" => Kube::SDK::Controller::CRD.from_type({{var.type.union_types.reject(&.==(Nil)).first}}),
          {% end %}
        }
        {% end %}
      }
    {% end %}
  end

  macro prop_to_schema(**value)
    {% if value[:subresource] && value[:namespace] %}
      Kube::SDK::Controller::CRD.klass_to_schema({{value[:namespace].id}}::{{value[:kind].id}})
    {% else %}
      {% klass = value[:kind].resolve %}
      {% klass = klass.union_types.empty? ? klass : klass.union_types.reject(&.==(Nil)).first %}
      Kube::SDK::Controller::CRD.from_type({{klass}}).to_h{% if value[:description] %}.merge({"description" => {{value[:description]}},}){% end %}.reject {|_,v| v.nil?}
    {% end %}
  end

  # Will generate a openapi spec for the provided class
  macro klass_to_schema(klass)
    {% klass = klass.resolve %}
    {% required = [] of StringLiteral %}
    {
      type: "object",
      {% if klass.annotation(::K8S::ObjectProperties) %}
      properties: {
          {% for name, value in klass.annotation(::K8S::ObjectProperties).named_args %}
          {% if value[:key] && value[:key] != name %}{% name = value[:key] %}{% end %}
          {% if value[:required] %}{% required << name.id.stringify %}{% end %}
          {% if !(name =~ /^api_version|apiVersion|kind|metadata$/) %}
          {{name.id}}: Kube::SDK::Controller::CRD.prop_to_schema({{**value}}),
          {% end %}{% end %}
      },
      {% elsif klass < K8S::Kubernetes::Object %}
        {% props = [] of Annotation %}
        {% for method in klass.methods %}{% if method.annotation(::K8S::ObjectProperty) %}{% props << method.annotation(::K8S::ObjectProperty) %}{% end %}{% end %}
        {% if !props.empty? %}
        properties: {
          {% for prop in props %}
          {% for name, value in prop.named_args %}
          {% if value[:key] && value[:key] != name %}{% name = value[:key] %}{% end %}
          {% if value[:required] %}{% required << name.id.stringify %}{% end %}
          {% if !(name =~ /^api_version|apiVersion|kind|metadata$/) %}
          {{name.id}}: Kube::SDK::Controller::CRD.prop_to_schema({{**value}}),
          {% end %}{% end %}{% end %}
        },
        {% end %}
      {% end %}
      {% if !required.empty? %}
      required: {{required}},
      {% end %}
    }
  end

  # Will generte a `CustomResourceDefinition` for the given class.
  macro klass_to_crd(klass)
    {% klass = klass.resolve %}
    {% anno = klass.annotation(::Kube::Builder) %}
    {% ver_info = klass.annotation(::K8S::GroupVersionKind).named_args %}
    K8S::ApiextensionsApiserver::Apis::Apiextensions::V1::CustomResourceDefinition.new(
      metadata: {
        annotations: {
          "controller-gen.kube-sdk.cr/version" => Kube::SDK::VERSION.to_s
        },
        name: "{{anno[:plural].id}}.{{ver_info[:group].id}}",
      },
      spec: {
        group: {{ver_info[:group].id.stringify}},
        names: {
          kind:  {{ver_info[:kind].id.stringify}},
          listKind: "{{ver_info[:kind].id}}List",
          plural: {{anno[:plural].id.stringify}},
          singular: {{anno[:singular].id.stringify}},
        },
        scope: {% if anno[:scope] == :namespaced %}"Namespaced"{% else %}"Cluster"{% end %},
        versions: [
          {% for ver in klass.annotations(::K8S::GroupVersionKind) %}
          {
            name: {{ver[:version].id.stringify}},
            served: true,
            storage: true,
            schema: {
              openAPIV3Schema: Kube::SDK::Controller::CRD.klass_to_schema({{klass.id}}),
            }
          },
          {% end %}
        ]
      }
    )
  end

  # Will return a list of generated `CustomResourceDefinition` for all kubernetes objects with the `Kube::Builder(generate: true)` annotation.
  def crd_defs : K8S::ApiextensionsApiserver::Apis::Apiextensions::V1::CustomResourceDefinitionList
    items = [
      {% for klass in K8S::Kubernetes::Object.all_subclasses %}{% if !klass.abstract? %}
      {% anno = klass.annotation(::Kube::Builder) %}
      {% if anno && anno.named_args[:generate] %}
        Kube::SDK::Controller::CRD.klass_to_crd({{klass.id}})
      {% end %}{% end %}{% end %},
    ] of K8S::ApiextensionsApiserver::Apis::Apiextensions::V1::CustomResourceDefinition

    K8S::ApiextensionsApiserver::Apis::Apiextensions::V1::CustomResourceDefinitionList.new(items)
  end
end
