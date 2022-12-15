# ppx\_optint

A ppx for [`Optint.t`][optint] and [`Optint.Int63.t`][optint] integer literals.
If the integer literal ends in `i` it is interpreted as a `Optint.t` while for `I` it is interpreted as a `Optint.Int63.t`.

```OCaml
# 1i;;
- : Optint.t = 1
# Optint.add 1023i 1i;;
- : Optint.t = 1024
# -1I;;
- : Optint.Int63.t = -1
# 4611686018427387903I;;
- : Optint.Int63.t = 4611686018427387903
```



[optint](https://github.com/mirage/optint/)
