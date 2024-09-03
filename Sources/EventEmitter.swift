import Foundation

public class EventEmitter<T> {
  package let id = UUID()
  private let queue: DispatchQueue

  private(set) public var listeners: [EventListener<T>] = []

  public init () {
    self.queue = DispatchQueue(label: "EventEmitter.\(self.id.uuidString).queue")
  }

  public func emit(_ value: T) {
    self.queue.async { [weak self] in
      guard let self = self else { return }
      var listenersToRemove: [EventListener<T>] = []
      for listener in self.listeners.filter({ $0.listening }) {
        listener.handler(value)
        if listener.once {
          listenersToRemove.append(listener)
        }
      }
      self.listeners = self.listeners.filter { !listenersToRemove.contains($0) }
    }
  }

  @discardableResult
  public func on(
    _ handler: @escaping (T) -> Void,
    onQueue queue: DispatchQueue? = nil
  ) -> EventListener<T> {
    let listener = EventListener(
      handler: handler,
      queue: queue
    )

    self.queue.async { [weak self] in
      self?.listeners.append(listener)
    }

    return listener
  }

  @discardableResult
  public func once(
    _ handler: @escaping (T) -> Void,
    onQueue queue: DispatchQueue? = nil
  ) -> EventListener<T> {
    let listener = EventListener(
      once: true,
      handler: handler,
      queue: queue
    )
    self.queue.async { [weak self] in
      self?.listeners.append(listener)
    }
    return listener
  }

  public func off(_ listener: EventListener<T>) {
    queue.async { [weak self] in
      self?.listeners = self?.listeners.filter { $0 != listener } ?? []
    }
  }

  deinit {
    self.queue.sync { [weak self] in
      self?.listeners = []
    }
  }
}

extension EventEmitter: Equatable {
  public static func == (lhs: EventEmitter, rhs: EventEmitter) -> Bool {
    return lhs.id == rhs.id
  }
}

public extension EventEmitter where T == Void {
  func emit() {
    self.emit(())
  }
}
