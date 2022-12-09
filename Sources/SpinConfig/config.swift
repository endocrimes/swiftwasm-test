extension spin_config_string_t {
    func ToSwiftString() -> String? {
        return String(cString: self.ptr, encoding: .utf8)
    }
}
import CSpinConfig
import Foundation

extension spin_config_error_t: Error {
    func String() -> String? {
        switch tag {
        case 0:
            return val.provider.ToSwiftString()
        case 1:
            return val.invalid_key.ToSwiftString()
        case 2:
            return val.invalid_schema.ToSwiftString()
        case 3:
            return val.other.ToSwiftString()
        default:
            return "unknown tag \(tag)"
        }
    }
    
    public var errorDescription: String? {
        String()
    }
}

func spinConfigGetInternal(key: String) throws -> String? {
    var cKeyStr = key.cString(using: .utf8)!
    var spinKey = spin_config_string_t(ptr: &cKeyStr, len: key.count)
    var spinResponse = spin_config_expected_string_error_t()
    spin_config_get_config(&spinKey, &spinResponse)
    if spinResponse.is_err {
        throw spinResponse.val.err
    }
    return spinResponse.val.ok.ToSwiftString()
}

// get retrieves the provided key from the Spin Host.
public func get(_ key: String) throws -> String? {
    return try spinConfigGetInternal(key: key)
}
