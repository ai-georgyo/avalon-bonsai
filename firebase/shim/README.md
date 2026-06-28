# Firebase shim (tree-shaken, self-hosted)

`entry.mjs` imports exactly the Firebase v12 modular functions the OCaml `firebase`
library calls and exposes them on `window.__fb` (see `../firebase.ml`). esbuild bundles +
tree-shakes + minifies it into the committed `../../web/firebase-shim.js`, which
`web/index.html` loads as a single same-origin `<script defer>` — no runtime dependency on
gstatic.com, and one request instead of three.

## Regenerate

```sh
cd firebase/shim
npm install      # firebase + esbuild
npm run build    # -> ../../web/firebase-shim.js  (commit the result)
```

The committed bundle was produced with firebase 12.15.0 + esbuild 0.28.1.

## On size

Tree-shaking trims `app`/`auth`, but firestore's realtime `onSnapshot` needs nearly the
whole firestore module, so the bundle is ~163 KB gzip (vs ~178 KB for the three CDN
files) — the win here is self-hosting and a single request, not bytes. Firestore Lite
(`firebase/firestore/lite`) is far smaller (~25 KB gzip) but has no realtime listeners,
which the live multiplayer board relies on.
