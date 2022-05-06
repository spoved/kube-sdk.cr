require "../spec_helper"

Spectator.describe K8S::Types do
  # TODO: Write tests
  context ImageSpec do
    let(:subject) { K8S::Types::ImageSpec }

    it "#initialize" do
      image = K8S::Types::ImageSpec.new(
        name: "nginx:latest",
        pull_policy: "IfNotPresent",
      )
      expect(image.pull_policy).to eq "IfNotPresent"
    end
  end
end
