require "spectator"
require "../src/kube-sdk"

Spectator.configure do |config|
  config.before_suite {
  # spoved_logger :trace, bind: true, clear: true
  }

  config.before_all do
    ENV["KUBECONFIG"] = ""
  end
end
