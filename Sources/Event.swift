import Foundation

public class Event<T>: Equatable, Sendable {
  public let id = UUID()
  private(set) public var listeners: [EventListener<T>] = []

  public init () {

  }

  public func emit (_ value: T, queue: DispatchQueue = .main) {
    queue.async { [weak self] in
      guard let self = self else { return }
      for listener in self.listeners.filter({ $0.listening }) {
        listener.handler(value)
      }
    }
  }

  public func on (_ handler: @escaping (T) -> Void) {
    
  }

  public func once (_ handler: @escaping (T) -> Void) {
    
  }

  public static func == (lhs: Event, rhs: Event) -> Bool {
    return lhs.id == rhs.id
  }
}