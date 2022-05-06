class K8S::Internals::HashObject(V)
  def self.deep_cast_value(value : Open::Api::Schema)
    deep_cast_value(value.to_h.reject { |_, v| v.nil? })
  end
end
