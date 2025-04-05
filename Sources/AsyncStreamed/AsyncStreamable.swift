//
//  AsyncStreamable.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 01.04.25.
//

import Foundation

@propertyWrapper
public struct AsyncStreamable<T: Sendable>: Sendable {
    
    private final class Observer: Sendable {
        
        private let continuation: AsyncStream<T>.Continuation
        
        init(continuation: AsyncStream<T>.Continuation) {
            self.continuation = continuation
            #if MEMORY_LEAKS_TESTING
            __AsyncStreamable_Observer_objectCount_inc()
            #endif
        }
        
        deinit {
            #if MEMORY_LEAKS_TESTING
            __AsyncStreamable_Observer_objectCount_dec()
            #endif
            continuation.finish()
        }
        
        func send(element: T) {
            continuation.yield(element)
        }
    }
    
    private final class ObserverList: @unchecked Sendable {
        
        private let lock = NSLock()
        
        private var observers: [Observer] = []
        
        #if MEMORY_LEAKS_TESTING
        init() {
            __AsyncStreamable_ObserverList_objectCount_inc()
        }
        deinit {
            __AsyncStreamable_ObserverList_objectCount_dec()
        }
        #endif
        
        func add(observer: Observer) {
            lock.lock()
            observers.append(observer)
            lock.unlock()
        }
        func remove(observer: Observer) {
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
            continuation.onTermination = { @Sendable _ in
                observerList.remove(observer: observer)
            }
        }
    }
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
    }
}

#if MEMORY_LEAKS_TESTING

@MainActor
var __AsyncStreamable_Observer_objectCount: Int = 0
func __AsyncStreamable_Observer_objectCount_inc() {
    Task { @MainActor in
        __AsyncStreamable_Observer_objectCount += 1
    }
}
func __AsyncStreamable_Observer_objectCount_dec() {
    Task { @MainActor in
        __AsyncStreamable_Observer_objectCount -= 1
    }
}

@MainActor
var __AsyncStreamable_ObserverList_objectCount: Int = 0
func __AsyncStreamable_ObserverList_objectCount_inc() {
    Task { @MainActor in
        __AsyncStreamable_ObserverList_objectCount += 1
    }
}
func __AsyncStreamable_ObserverList_objectCount_dec() {
    Task { @MainActor in
        __AsyncStreamable_ObserverList_objectCount -= 1
    }
}

#endif
