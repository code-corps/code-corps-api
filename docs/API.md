# How to generate API documentation locally

You can generate documentation a few ways:

- [Apiary CLI](#apiary-cli) (recommended)
- [`aglio`](#aglio)
- [Atom](#atom)

### Apiary CLI

[Apiary CLI](https://help.apiary.io/tools/apiary-cli/) comes preloaded when you run `docker-compose up` like normal.

Once Docker is running your containers, `apiary` runs an Apiary CLI server on port `8081`. You can visit the documentation by visiting `localhost:8081` in your browser. Just refresh the page any time you make changes to the documentation file at `/blueprint/api.apib`.

### aglio

Navigate into the `/blueprint` directory.

If installing for the first time, run:

```shell
docker-compose build
```

Then start the `aglio` service with:

```shell
docker-compose up
```

Now you can generate the docs with our shell script:

```bash
./generate
```

You should be able to view the docs by opening the newly generated `index.html` in your browser.

### Atom

If you're developing with [Atom](https://atom.io/), you can also use the [API Blueprint Preview](https://atom.io/packages/api-blueprint-preview) package to preview your blueprint changes in realtime.
