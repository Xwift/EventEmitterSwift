import Foundation

public class EventListener<T>: Equatable {
  package let id = UUID()
  public let handler: (T) -> Void
  public var listening: Bool = true
  package let once: Bool

  package init(
    once: Bool = false,
    handler: @escaping (T) -> Void,
    queue: DispatchQueue? = nil
  ) {
    self.once = once
    if let queue = queue {
      self.handler = { [weak queue] value in
        queue?.async { handler(value) }
      }
    } else {
      self.handler = { value in
        handler(value)
      }
    }
  }

  public func pause() {
    listening = false
  }

  public func resume() {
    listening = true
  }

  public static func == (lhs: EventListener, rhs: EventListener) -> Bool {
    return lhs.id == rhs.id
  }
}
