//
//  Mocks.swift
//  AsyncStreamed
//
//  Created by Gabriel Radu on 03.04.25.
//

import AsyncStreamed

actor StreamableMock {
    
    private var tasks: [Task<(), any Error>] = []
    
    deinit {
        for task in tasks {
            task.cancel()
        }
    }
    
    @AsyncStreamable
    var intWithStream: Int = 0
    
    func startIntStreaming() async {
        tasks.append(Task { [weak self] in
            while !Task.isCancelled {
                try await Task.sleep(for: .milliseconds(500))
                await self?.incrementIntWithStream()
            }
        })
    }
    
    private func incrementIntWithStream() {
        self.intWithStream += 1
    }
}
