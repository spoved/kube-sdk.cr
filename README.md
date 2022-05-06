# kube-sdk

A toolkit for Kubernetes development in Crystal.

[![.github/workflows/ci.yml](https://github.com/spoved/kube-sdk.cr/actions/workflows/ci.yml/badge.svg)](https://github.com/spoved/kube-sdk.cr/actions/workflows/ci.yml) [![.github/workflows/docs.yml](https://github.com/spoved/kube-sdk.cr/actions/workflows/docs.yml/badge.svg)](https://github.com/spoved/kube-sdk.cr/actions/workflows/docs.yml) [![GitHub release](https://img.shields.io/github/release/spoved/kube-sdk.cr.svg)](https://github.com/spoved/kube-sdk.cr/releases) [![Chat on Telegram](https://img.shields.io/badge/chat-telegram-blue)](https://t.me/k8s_cr)

## Installation

TODO: Write installation instructions here

## Usage

Specify the kubernetes api version of the client to use before requiring the sdk:

```crystal
require "kube-sdk/v1.23"
require "kube-sdk"
```

Or you can specify the kubernetes api version at compile time via the `-Dk8s_v{major}.{minor}` flag:

```crystal
require "kube-sdk"

client = Kube::Client.autoconfig
```

Generate the CLI using shards build:

```shell
shards build -Dk8s_v1.23
```

If no version is specified the latest version will be used.

### CRD Generation

CRDs can be defined using the `Kube::SDK.define_crd` method.

```crystal
Kube::SDK.define_crd(
  group: "examples.spoved.io",
  version: "v1alpha1",
  kind: TestObject,
  plural: "testobjects",
  scope: :namespaced,
  namespace: ::Spoved::Examples::V1alpha1,
  properties: {
    spec: {
      kind: TestObjectSpec,
      required: true,
      subresource: true,
      description: "Defines the specification of TestObject",
      properties:  {
        created: Bool,
        healthy: Bool,
      },
    }
  }
)
```

A more complex example can be seen in the [plex-controller/crd.cr](examples/plex-controller/crd.cr) file.

CRD Manafests can be generated using the cli command.

```shell
./bin/kube-sdk controller gen --file ./examples/plex-controller/main.cr --out-dir ./tmp
```

This will generate manifests into the output directory under `config/crd/bases/`.

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/spoved/kube-sdk.cr/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Holden Omans](https://github.com/kalinon) - creator and maintainer
