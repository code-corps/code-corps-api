# How to generate API documentation locally

You can generate documentation a couple ways:

- [Apiary Client](#apiary-client) (recommended)
- [Atom](#atom)

### Apiary Client

[Apiary Client](https://help.apiary.io/tools/apiary-cli/) needs Ruby to run.

You can install the Apiary Client by running:

```shell
gem install apiaryio
```

You can now run the server:

```shell
apiary preview --path=blueprint/api.apib --server
```

This runs an Apiary CLI server on port `8080`. You can visit the documentation by visiting `localhost:8080` in your browser. Just refresh the page whenever you make changes to the documentation file at `/blueprint/api.apib`.

### Atom

If you're developing with [Atom](https://atom.io/), you can also use the [API Blueprint Preview](https://atom.io/packages/api-blueprint-preview) package to preview your blueprint changes in realtime.
