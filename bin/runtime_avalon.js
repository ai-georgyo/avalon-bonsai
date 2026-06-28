// Runtime stub for a primitive that OxCaml's stdlib Domain module references but the
// installed js_of_ocaml runtime (6.0.1+ox2) does not provide. Mirrors the native
// runtime's Max_domains (128). Single-domain under js_of_ocaml, so the exact value only
// bounds domain-local-storage sizing.
//Provides: caml_max_domain_count const
//Version: >= 5
function caml_max_domain_count(_unit) {
  return 128;
}
