.build/release/swiftwasm-test.wasm: $(shell find Sources -type f)
	xcrun --toolchain swiftwasm swift build --triple wasm32-unknown-wasi -c release
out.wasm: .build/release/swiftwasm-test.wasm
	wasm-opt -Os .build/release/swiftwasm-test.wasm -o out.wasm

.DEFAULT_GOAL=default
default: out.wasm
