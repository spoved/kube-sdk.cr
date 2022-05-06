require "spoved/cli"

# :nodoc:
class Kube::SDK::Cli < Spoved::Cli::Main
  # :nodoc:
  def config(cmd : Commander::Command)
    cmd.use = "kube-sdk"
    cmd.long = "kubernetes sdk for crystal"

    opt_k8s_ver(cmd)
  end

  # :nodoc:
  @[Spoved::Cli::Command(name: :version, descr: "Print SDK version and exit")]
  class Version
    def run(cmd, options, arguments)
      puts Kube::SDK.version.to_json
    end
  end

  macro opt_k8s_ver(c)
    {{c}}.flags.add do |flag|
      flag.name = "k8s_ver"
      # flag.short = "-k"
      flag.long = "--k8s"
      flag.description = "The version of kubernetes API to use."
      flag.default = "1.23"
      flag.persistent = true
    end
  end

  macro opt_in_file(c)
    {{c}}.flags.add do |flag|
      flag.name = "in_file"
      flag.short = "-f"
      flag.long = "--file"
      flag.description = "Input file."
      flag.default = ""
    end
  end

  macro opt_out_dir(c)
    {{c}}.flags.add do |flag|
      flag.name = "out_dir"
      flag.short = "-o"
      flag.long = "--out-dir"
      flag.description = "Output directory."
      flag.default = ""
    end
  end
end

require "./cli/**"
