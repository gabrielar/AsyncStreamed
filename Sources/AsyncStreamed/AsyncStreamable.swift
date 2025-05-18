//
//  AsyncStreamable.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 01.04.25.
//

import Foundation
import LeakCheck

@propertyWrapper
public struct AsyncStreamable<T: Sendable>: Sendable {
    
    @TrackedInstances(tag: "AsyncStreamed.AsyncStreamable.Observer")
    private final class Observer: Sendable {
        
        private let continuation: AsyncStream<T>.Continuation
        
        init(continuation: AsyncStream<T>.Continuation) {
            self.continuation = continuation
        }
        
        deinit {
            continuation.finish()
        }
        
        func send(element: T) {
            continuation.yield(element)
        }
    }
    
    @TrackedInstances(tag: "AsyncStreamed.AsyncStreamable.ObserverList")
    private final class ObserverList: @unchecked Sendable {
        
        private let lock = NSLock()
        
        private var observers: [Observer] = []
                
        func add(observer: Observer) {
            lock.lock()
            observers.append(observer)
            lock.unlock()
        }
        func remove(observer: Observer?) {
            lock.lock()
            observers.removeAll { $0 === observer }
            lock.unlock()
        }
        func send(element: T) {
            lock.lock()
            observers.forEach { $0.send(element: element) }
            lock.unlock()
        }
    }
    
    private let observerList: ObserverList = .init()
    
    private var value: T
    
    public var wrappedValue: T {
        get { value }
        set {
            value = newValue
            observerList.send(element: newValue)
        }
    }
    
    public var projectedValue: AsyncStream<T> {
        let observerList = self.observerList
        return AsyncStream { @Sendable (continuation: AsyncStream<T>.Continuation) -> Void in
            let observer = Observer(continuation: continuation)
            observerList.add(observer: observer)
            continuation.onTermination = { @Sendable [weak observerList, weak observer] _ in
                observerList?.remove(observer: observer)
            }
        }
    }
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
    }
}
