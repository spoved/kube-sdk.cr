{% begin %}
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

require "./kube-sdk/*"
