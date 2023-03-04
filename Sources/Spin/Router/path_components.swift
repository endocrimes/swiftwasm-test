import Foundation

/// A single path component of a `Route`. An array of these components describes
/// a route's path, including which parts are constant and which parts are dynamic.
public enum PathComponent: ExpressibleByStringInterpolation, CustomStringConvertible {
  /// A normal, constant path component.
  case constant(String)

  /// A dynamic parameter component.
  ///
  /// The supplied identifier will be used to fetch the associated
  /// value from `Parameters`.
  ///
  /// Represented as `:` followed by the identifier.
  case parameter(String)

  /// A dynamic parameter component with discarded value.
  ///
  /// Represented as `*`
  case anything

  /// `ExpressibleByStringLiteral` conformance.
  public init(stringLiteral value: String) {
    if value.hasPrefix(":") {
      self = .parameter(.init(value.dropFirst()))
    } else if value == "*" {
      self = .anything
    } else {
      self = .constant(value)
    }
  }

  /// `CustomStringConvertible` conformance.
  public var description: String {
    switch self {
    case .anything:
      return "*"
    case .parameter(let name):
      return ":" + name
    case .constant(let constant):
      return constant
    }
  }
}

extension String {
  /// Converts a string into `[PathComponent]`.
  public var pathComponents: [PathComponent] {
    return self.split(separator: "/").map { .init(stringLiteral: .init($0)) }
  }
}

extension Sequence where Element == PathComponent {
  /// Converts an array of `PathComponent` into a readable path string.
  ///
  ///     people/:userID/hobbies
  ///
  public var string: String {
    return self.map(\.description).joined(separator: "/")
  }

  /// Converts an array of `PathComponent` into an array of strings representing components
  public var stringArray: [String] {
    return self.map(\.description)
  }
}
