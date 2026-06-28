// Tree-shaken entry for the Firebase v12 modular SDK. esbuild bundles only these imports
// (plus their transitive deps) and we expose them on `window.__fb` for the js_of_ocaml
// bindings in ../firebase.ml. Firing `firebase-ready` lets Firebase.on_ready proceed.
import { initializeApp } from "firebase/app";
import {
  getAuth, onAuthStateChanged, signInAnonymously,
  signInWithEmailLink, sendSignInLinkToEmail, signOut,
} from "firebase/auth";
import { getFirestore, doc, onSnapshot, getDoc } from "firebase/firestore";

window.__fb = {
  initializeApp,
  getAuth, onAuthStateChanged, signInAnonymously,
  signInWithEmailLink, sendSignInLinkToEmail, signOut,
  getFirestore, doc, onSnapshot, getDoc,
};
window.dispatchEvent(new Event("firebase-ready"));
