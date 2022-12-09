TARGET=release

.build/release/swiftwasm-test.wasm: $(shell find Sources -type f)
	xcrun --toolchain swiftwasm swift build --triple wasm32-unknown-wasi -c release -Xlinker "--export=spin_http_handle_http_request"

.build/debug/swiftwasm-test.wasm: $(shell find Sources -type f)
	xcrun --toolchain swiftwasm swift build --triple wasm32-unknown-wasi -c debug -Xlinker "--export=spin_http_handle_http_request"
out.wasm: .build/$(TARGET)/swiftwasm-test.wasm
	#cp .build/$(TARGET)/swiftwasm-test.wasm out.wasm
	wasm-opt -Os .build/$(TARGET)/swiftwasm-test.wasm -o out.wasm

.DEFAULT_GOAL=default
default: out.wasm
