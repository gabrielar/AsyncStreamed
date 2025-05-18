//
//  AsyncStream+Sink.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 07.04.25.
//

public typealias CancellableSet = Set<Cancellable>

public class Cancellable {
    
    private let task: Task<Void, Never>
    
    fileprivate init(task: Task<Void, Never>) {
        self.task = task
    }
    
    deinit {
        task.cancel()
    }
    
    public func addTo(_ cancelablesSet: inout CancellableSet) {
        cancelablesSet.insert(self)
    }
}

extension Cancellable: Hashable {
    public static func == (lhs: Cancellable, rhs: Cancellable) -> Bool {
        lhs.task == rhs.task
    }
    public func hash(into hasher: inout Hasher) {
        task.hash(into: &hasher)
    }
}

public extension AsyncStream where Element : Sendable {
    
    func sink(onElement: sending @escaping (Element) async -> Void) -> Cancellable {
        return Cancellable(task: Task {
            for await element in self {
                if Task.isCancelled { return }
                await onElement(element)
            }
        })
    }
}
