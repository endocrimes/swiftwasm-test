TARGET=release

format: $(shell find . -name '*.swift' -type f)
	swift-format format --parallel -i --recursive .

.build/$(TARGET)/swiftwasm-test.wasm: format $(shell find Sources -type f)
	xcrun --toolchain swiftwasm swift build --triple wasm32-unknown-wasi \
		-c $(TARGET) \
		-Xlinker "--export=main"

out.wasm: .build/$(TARGET)/swiftwasm-test.wasm
	cp .build/$(TARGET)/swiftwasm-test.wasm out.wasm
	wasm2wat ./out.wasm > out.wat
	#wasm-opt -Os .build/$(TARGET)/swiftwasm-test.wasm -o out.wasm

clean:
	rm -rf .build || true
	rm out.wasm

.DEFAULT_GOAL=default
default: out.wasm
