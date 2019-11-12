//
//  CombineRealmTests
//
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import XCTest
import CombineRealm
import RealmSwift
import Combine

class ObserveElementsPublisherTestsBase: RealmTestsCase {
    var publisher: ObserveElementsPublisher<Todo>!
    
    override func setUp() {
        super.setUp()
        
        publisher = ObserveElementsPublisher(results: realm.objects(Todo.self))
    }
    
    func testObserveElementsOfResults() throws {
        try runTestObserveElementsOfResults(for: publisher)
    }
    
    func testObserveElementsOfResultsSugarSyntax() throws {
        let publisher = realm.objects(Todo.self).observeElementsPublisher()
        try runTestObserveElementsOfResults(for: publisher)
    }
    
    func testObserveElementsOfResultsSugarSyntaxObservePublisher() throws {
        let publisher = realm.objectsPublisher(Todo.self)
        try runTestObserveElementsOfResults(for: publisher)
    }
    
    private func runTestObserveElementsOfResults(
        for publisher: ObserveElementsPublisher<Todo>,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let recorder = Recorder<[Todo], Error>()
        publisher.subscribe(recorder)
        recorder.store(in: &cancellables)
        
        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        let todo3 = Todo("Todo 3")
        let todo4 = Todo("Todo 4")
        
        try realm.write {
            realm.add(todo1)
            realm.add(todo2)
        }
        
        try realm.write {
            realm.add(todo3)
        }
        
        try realm.write {
            realm.add(todo4)
        }
        
        let expectation = self.expectation(description: #function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        waitForExpectations { error in
            XCTAssertNil(error, "Expectation error", file: file, line: line)
            
            XCTAssertEqual(
                recorder.recordedValues.count,
                4,
                "Number of recorded values",
                file: file,
                line: line
            )
            assertEqual(
                recorder.recordedValues[0],
                [],
                description: "Value[0]",
                file: file,
                line: line
            )
            assertEqual(
                recorder.recordedValues[1],
                [todo1, todo2],
                description: "Value[1]",
                file: file,
                line: line
            )
            assertEqual(
                recorder.recordedValues[2],
                [todo1, todo2, todo3],
                description: "Value[2]",
                file: file,
                line: line
            )
            assertEqual(
                recorder.recordedValues[3],
                [todo1, todo2, todo3, todo4],
                description: "Value[3]",
                file: file,
                line: line
            )
            XCTAssertEqual(
                recorder.recordedCompletions.count,
                0,
                "Number of recorded completions",
                file: file,
                line: line
            )
        }
    }
    
    func testCancel() throws {
        let recorder = Recorder<[Todo], Error>()
        publisher.subscribe(recorder)

        let todo1 = Todo("Todo 1")
        let todo2 = Todo("Todo 2")
        let todo3 = Todo("Todo 3")
        let todo4 = Todo("Todo 4")
       
        try realm.write {
            realm.add(todo1)
            realm.add(todo2)
        }
                  
        let expectation = self.expectation(description: #function)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            recorder.cancel()
            
            do {
                try self.realm.write {
                    self.realm.add(todo3)
                }
               
                try self.realm.write {
                    self.realm.add(todo4)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    expectation.fulfill()
                }
            } catch let error {
                XCTFail(error.localizedDescription)
            }
        }
        
        waitForExpectations { error in
            XCTAssertNil(error)

            XCTAssertEqual(recorder.recordedValues.count, 2)
            assertEqual(recorder.recordedValues[0], [])
            assertEqual(recorder.recordedValues[1], [todo1, todo2])
            XCTAssertEqual(recorder.recordedCompletions.count, 0)
        }
    }
}
