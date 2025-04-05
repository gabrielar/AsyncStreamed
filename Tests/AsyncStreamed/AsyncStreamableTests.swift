//
//  AsyncStreamableTests.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 01.04.25.
//

import Testing
@testable import AsyncStreamed

@Suite(
    "AsyncStreamable tests", .serialized, .timeLimit(.minutes(2))
) struct AsyncStreamableTests {
    
    @Test func testIntStreaming() async throws {
        
        let mock = StreamableMock()
        
        let task = Task {
            var elements: [Int] = []
            for await element in await mock.$intWithStream {
                elements.append(element)
                if element == 5 {
                    break
                }
            }
            return elements
        }
        
        await mock.startIntStreaming()
        #expect(await task.value == [1, 2, 3, 4, 5])
    }
    
#if MEMORY_LEAKS_TESTING
    @Test func testForMemoryLeaks() async throws {
        
        try #require(await __AsyncStreamable_Observer_objectCount == 0)
        try #require(await __AsyncStreamable_ObserverList_objectCount == 0)
        
        var mock: StreamableMock? = StreamableMock()
        
        #expect(await __AsyncStreamable_Observer_objectCount == 0)
        #expect(await __AsyncStreamable_ObserverList_objectCount > 0)
        
        let task = Task {
            guard let mock else {
                Issue.record("Mock not found")
                return
            }
            for await element in await mock.$intWithStream {
                if element == 5 {
                    break
                }
            }
        }
        
        await mock?.startIntStreaming()
        
        try await Task.sleep(for: .milliseconds(500))
        
        #expect(await __AsyncStreamable_Observer_objectCount > 0)
        #expect(await __AsyncStreamable_ObserverList_objectCount > 0)
        
        await task.value
        
        mock = nil
        try await Task.sleep(for: .milliseconds(500))
        
        #expect(await __AsyncStreamable_Observer_objectCount == 0)
        #expect(await __AsyncStreamable_ObserverList_objectCount == 0)
    }
#endif
}
