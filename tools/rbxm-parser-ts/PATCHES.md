# Local patches to rbxm-parser-ts (v1.1.4, https://github.com/fiveman1/rbxm-parser-ts)

The vendored copy parses the project's `.rbxm` files (e.g. map models). Two
small patches were applied because the `lz4` native addon failed to build in
this environment:

1. `src/lib/roblox_file_reader.ts` / `src/lib/roblox_file_writer.ts` — the
   top-level `lz4`/`fzstd` imports were made lazy (`createRequire` at use
   site), so files with uncompressed chunks parse without native modules.
2. `node_modules/lz4/build/Release/xxhash.js` (new) — pure-JS shadow for the
   native xxhash addon; `node_modules/lz4/build/Release/lz4.js` (copy of
   `lib/binding.js`) — pure-JS shadow for the native lz4 binding. The block
   decode path used by the parser never calls the xxhash functions (they
   throw if accidentally hit).

Rebuild after editing with `npm run build` inside `tools/rbxm-parser-ts/`.
`node_modules/` and `dist/` are gitignored.
