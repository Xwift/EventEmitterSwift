import Foundation

public class EventListener<T>: Equatable {
  public let id = UUID()
  public var handler: (T) -> Void
  public var listening: Bool = true

  package init (handler: @escaping (T) -> Void) {
    self.handler = handler
  }

  public func pause () {
    listening = false
  }

  public func resume () {
    listening = true
  }

  public static func == (lhs: EventListener, rhs: EventListener) -> Bool {
    return lhs.id == rhs.id
  }
}