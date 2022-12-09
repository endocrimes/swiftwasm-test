import Foundation

// This is absolute hacks in order to write something basic.
// None of it is safe, to spec, or particularly reusable. Sorry!
struct WAGIKit {
    let rawEnv: [String: String]

    init(env: [String: String] = ProcessInfo.processInfo.environment) {
        rawEnv = env
    }

    func path() -> String {
        rawEnv["PATH_TRANSLATED"]!
    }

    func query() -> [String: String] {
        let queryList = rawEnv["QUERY_STRING"]?.split {$0 == "&"}.map (String.init)
        let splitQueryList = queryList?.map { unparsed in
            return unparsed.split {$0 == "="}.map (String.init)
        }
        return splitQueryList?.reduce(into: [String: String]()) { accu, components in
            accu[components[0]] = components[1]
        } ?? [String: String]()
    }
}

let wk = WAGIKit()

print("content-type: text/plain\n")

print("got path: \(wk.path())")
print("got query: \(wk.query())")
