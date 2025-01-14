# Cardano Serialization Lib

_This fork of the cardano-serialization-library includes a development shell
that sets the `WASM_BINDGEN_WEAKREF` environment variable. This ensures that
builds of the library will automatically `free()` pointers when their reference
in the JavaScript runtime is garbage collected._

##### Build

Ensure you have Nix installed and Flakes enabled.

```
nix develop
npm run rust:build-nodejs
```

The script will build the assets under `/rust/pkg`.
Other targets and scripts can be found in the root `packages.json`.


This is a library, written in Rust, for serialization & deserialization of data structures used in Cardano's Haskell implementation of Alonzo along with useful utility functions.

##### NPM packages

- [NodeJS WASM package](https://www.npmjs.com/package/@emurgo/cardano-serialization-lib-nodejs)
- [Browser (chrome/firefox) WASM package](https://www.npmjs.com/package/@emurgo/cardano-serialization-lib-browser)
- [Browser (pure JS - no WASM) ASM.js package](https://www.npmjs.com/package/@emurgo/cardano-serialization-lib-asmjs)

##### Rust crates

- [cardano-serialization-lib](https://crates.io/crates/cardano-serialization-lib)

##### Mobile bindings

- [React-Native mobile bindings](https://github.com/Emurgo/react-native-haskell-shelley)

## Documentation

You can find documentation [here](https://docs.cardano.org/cardano-components/cardano-serialization-lib)
