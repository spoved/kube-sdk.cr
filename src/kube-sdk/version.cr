require "compiler/crystal/config"

module Kube::SDK
  VERSION = "0.1.0"

  def client_version
    Kube::Client::VERSION
  end

  def api_version
    K8S::Kubernetes::VERSION
  end

  def version
    {
      kube_sdk:    Kube::SDK::VERSION,
      kube_client: Kube::SDK.client_version.to_s,
      k8s_api:     Kube::SDK.api_version.to_s,
      crystal:     Crystal::Config.version,
      llvm:        LibLLVM::VERSION,
      arch:        _compiler_arch,
      vendor:      _compiler_vendor,
      platform:    _compiler_os_platform,
      git_commit:  {{system("git rev-parse HEAD").chomp.stringify}},
      git_state:   {{system("git status --porcelain").chomp.empty? ? "clean" : "dirty"}},
    }
  end

  private macro _compiler_arch
    {% if flag?(:aarch64) %}
      "aarch64"
    {% elsif flag?(:arm) %}
      "arm"
    {% elsif flag?(:i386) %}
      "i386"
    {% elsif flag?(:x86_64) %}
      "x86_64"
    {% elsif flag?(:bits32) %}
      "bits32"
    {% elsif flag?(:bits64) %}
      "bits64"
    {% else %}
      "unknown"
    {% end %}
  end

  private macro _compiler_vendor
    {% if flag?(:macosx) %}
      "macosx"
    {% elsif flag?(:portbld) %}
      "linux"
    {% elsif flag?(:unknown) %}
      "unknown"
    {% else %}
      "unknown"
    {% end %}
  end

  private macro _compiler_os_platform
    {% if flag?(:bsd) %}
      "bsd"
    {% elsif flag?(:linux) %}
      "linux"
    {% elsif flag?(:darwin) %}
      "darwin"
    {% elsif flag?(:windows) %}
      "windows"
    {% elsif flag?(:dragonfly) %}
      "dragonfly"
    {% elsif flag?(:freebsd) %}
      "freebsd"
    {% elsif flag?(:netbsd) %}
      "netbsd"
    {% elsif flag?(:openbsd) %}
      "openbsd"
    {% elsif flag?(:unix) %}
      "unix"
    {% else %}
      "unknown"
    {% end %}
  end
end
