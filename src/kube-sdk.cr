module Kube; end

{% begin %}
  {% if Kube.resolve.constants.includes?("Client".id) %}
    # puts K8S::Kubernetes::VERSION
  {% else %}
    {% flag_provided = false %}
    {% for ver in (11..23) %}
      {% flag = :k8s_v1 + "." + "#{ver}" %}
      {% if flag?(flag) %}
        {% flag_provided = true %}
        require "kube-client/v1.{{ver}}"
      {% end %}
    {% end %}
    {% unless flag_provided %}
      require "kube-client/v1.23"
    {% end %}
  {% end %}
{% end %}

require "spoved/logger"
require "./kube-sdk/version"

module Kube::SDK
  extend self
  spoved_logger
end

Kube::SDK.logger.debug &.emit "Kube SDK Version", **Kube::SDK.version

require "./kube-sdk/*"
