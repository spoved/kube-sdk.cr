require "spoved/cli"

# :nodoc:
class Kube::SDK::Cli < Spoved::Cli::Main
  # :nodoc:
  def config(cmd : Commander::Command)
    cmd.use = "kube-sdk"
    cmd.long = "kubernetes sdk for crystal"
  end

  # :nodoc:
  @[Spoved::Cli::Command(name: :version, descr: "print SDK version and exit")]
  class Version
    def run(cmd, options, arguments)
      puts Kube::SDK.version.to_json
    end
  end
end
