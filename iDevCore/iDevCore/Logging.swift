import Foundation
import Aspen

public func logVerbose(_ message: @autoclosure () -> String) { aspenVerbose(message) }
public func logInfo(_ message: @autoclosure () -> String) { aspenInfo(message) }
public func logWarn(_ message: @autoclosure () -> String) { aspenWarn(message) }
public func logError(_ message: @autoclosure () -> String) { aspenError(message) }

public struct iDevLogger {
    private var fileLogger: FileLogger!
    
    // MARK: Initialization
    // ====================================
    // Initialization
    // ====================================
    public init() {
        
    }
    
    /** Activates the logging infrastructure, including a file logger according to the receiver's
     // configuration, and a TTY (Xcode console) logger. */
    public mutating func install() {
        Aspen.setLoggingLevel(.verbose)
        
        // XCode console
        let ttyLogger = ConsoleLogger()
        Aspen.register(logger: ttyLogger)
        logWarn("ATTACHING TTY LOGGER")

        fileLogger = FileLogger()
        Aspen.register(logger: fileLogger)
    }
}
