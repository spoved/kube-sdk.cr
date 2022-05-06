require "file_utils"
require "spoved/system_cmd"

@[Spoved::Cli::SubCommand(name: :controller, descr: "Kubernetes controller commands.")]
class Kube::SDK::Controller; end

require "./controller/*"

class Kube::SDK::Controller
  spoved_logger

  @[Spoved::Cli::Command(name: :gen, descr: "Generate controller code.", opts: [:in_file, :out_dir], flags: [
    {
      name: "gen_crds",
      # short:       "-c",
      long:        "--crds",
      description: "generate CRDs",
      default:     true,
      # persistent:  true,
    },
  ])]
  def gen(cmd, options, arguments)
    opts = {
      k8s_ver:  options.string["k8s_ver"],
      in_file:  options.string["in_file"],
      out_dir:  options.string["out_dir"]? || FileUtils.pwd,
      gen_crds: options.bool["gen_crds"],
    }

    validate_options!(opts)

    logger.info { "Generating controller code..." }
    logger.debug &.emit "Options", **opts

    if opts[:gen_crds]
      Kube::SDK::Controller::CRD.generate_crds(**opts)
    end
  end

  private def validate_options!(opts)
    if opts[:in_file].empty?
      logger.error { "Must provide an input file to parse. Use -f or --file." }
      exit 1
    end

    if !File.exists?(opts[:in_file])
      logger.error { "Input file not found: #{opts[:in_file]}" }
      exit 1
    end

    if !Dir.exists?(opts[:out_dir])
      logger.error { "Output directory not found: #{opts[:in_file]}" }
      exit 1
    end
  end
end
