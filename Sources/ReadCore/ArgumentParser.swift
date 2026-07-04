public enum ArgumentsError: Error, Equatable, CustomStringConvertible {
    case missingPIDValue
    case invalidPIDValue(String)
    case unknownArgument(String)

    public var description: String {
        switch self {
        case .missingPIDValue:
            return "--pid requires a value"
        case .invalidPIDValue(let value):
            return "invalid --pid value '\(value)', expected an integer"
        case .unknownArgument(let value):
            return "unknown argument '\(value)'"
        }
    }
}

public struct Arguments: Equatable {
    public let pid: Int32?

    public init(pid: Int32? = nil) {
        self.pid = pid
    }
}

public enum ArgumentParser {
    public static func parse(_ arguments: [String]) -> Result<Arguments, ArgumentsError> {
        var pid: Int32?
        var iterator = arguments.makeIterator()

        while let argument = iterator.next() {
            switch argument {
            case "--pid":
                guard let value = iterator.next() else {
                    return .failure(.missingPIDValue)
                }
                guard let parsed = Int32(value) else {
                    return .failure(.invalidPIDValue(value))
                }
                pid = parsed
            default:
                return .failure(.unknownArgument(argument))
            }
        }

        return .success(Arguments(pid: pid))
    }
}
