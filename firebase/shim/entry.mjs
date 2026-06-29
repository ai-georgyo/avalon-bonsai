// Entry point for the vendored Firebase v12 modular SDK bundle.
//
// esbuild bundles exactly these imports (plus their transitive deps) into one minified IIFE
// and we expose them on globalThis.__fb, which the js_of_ocaml bindings in ../firebase.ml
// dispatch through (see `call`/`on_ready`). The built artifact (../vendor/firebase-shim.js)
// is embedded directly into main.bc.js via `(js_of_ocaml (javascript_files ...))` in ../dune,
// so the SDK is present synchronously at startup — no gstatic CDN, no runtime `import()`.
//
// Keep this list in sync with the free functions firebase.ml passes to `call`. Methods on
// handles (e.g. user.getIdToken, snapshot.exists/data) need no import. Rebuild after changing
// it: `npm install && npm run build`.
import { initializeApp } from "firebase/app";
import {
  getAuth,
  onAuthStateChanged,
  signInAnonymously,
  signInWithEmailLink,
  sendSignInLinkToEmail,
  signOut,
} from "firebase/auth";
import { getFirestore, doc, onSnapshot, getDoc } from "firebase/firestore";

globalThis.__fb = {
  initializeApp,
  getAuth,
  onAuthStateChanged,
  signInAnonymously,
  signInWithEmailLink,
  sendSignInLinkToEmail,
  signOut,
  getFirestore,
  doc,
  onSnapshot,
  getDoc,
};
