# Avalon — OxCaml Bonsai client

A port of the [avalon](../avalon) Vue 3 + Vuetify + Firebase **client** into an
[OxCaml](https://oxcaml.org) [Bonsai](https://github.com/janestreet/bonsai) web app
(client side only). It talks to the same real backend: Firebase Auth (anonymous +
email-link), Firestore real-time listeners, and the `/api` REST server.

## Layout

```
src/
  util, types, avalonlib, game, analysis   pure game logic (roles, derived state, achievements)
  ffi        js_of_ocaml bindings: compat Firebase SDK, fetch, window
  parse      Firestore JS objects -> typed model
  api        REST client (POST /api/*)
  toast      imperative toast (replaces vue-toastification)
  state      reactive store: Model in a Bonsai.Expert.Var; Firebase listeners + actions
  view       all UI components in Vdom (replaces the Vuetify components)
bin/
  main.ml             entry point
  runtime_avalon.js   runtime stub for a primitive missing in the jsoo runtime
web/
  index.html          loads Firebase compat SDK + FontAwesome/MDI fonts + the bundle
  style.css           Vuetify-ish styling
```

## Prerequisites

- opam switch `5.2.0+ox` (the OxCaml compiler) with `bonsai_web` installed:
  ```
  opam install bonsai_web
  ```

## Build

```
eval $(opam env --switch=5.2.0+ox)
dune build bin/main.bc.js
```

Outputs to `_build/default/bin/`: `index.html`, `style.css`, `main.bc.js`.

## Run

Serve the build directory behind a proxy that forwards `/api` to the Avalon REST server
(as the original Vite dev server does, proxying to `https://avalon.onl/api`):

```
cd _build/default/bin && python3 -m http.server 8000   # static files only; /api needs a proxy
```

Then open `http://localhost:8000/`. Anonymous login, the lobby list, and live stats work
directly against the production Firebase project; lobby/game actions require the `/api`
proxy.

## Notes

- Built with the cont Bonsai API; the imperative Firebase listeners push snapshots into a
  single `Bonsai.Expert.Var` that drives the whole UI.
- Icons use FontAwesome 6 + Material Design Icons web fonts (loaded via CDN in
  `index.html`) instead of Vuetify's bundled icon sets.
- The dev bundle is large and unminified; pass `--profile release` / `dune build
  bin/main.bc.js --profile release` for an optimized build.
