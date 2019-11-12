//    
//  CombineRealmTests
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import XCTest
import Combine
import CombineRealm
import RealmSwift

class ObserveObjectPublisherTests: RealmTestsCase {
    func testObserveObjct() throws {
        let todo = Todo("Test")
        try realm.write {
            realm.add(todo)
        }
        let publisher = ObserveObjectPublisher(object: todo)
        let recorder = Recorder<ObserveObjectPublisher.ObjectChange, Error>()
        publisher.subscribe(recorder)
        recorder.store(in: &cancellables)
        
        try realm.write {
            todo.title = ""
            todo.isDone = false
        }
        
        try realm.write {
            todo.isDone = true
        }
        
        try realm.write {
            todo.title = ""
        }
        
        try realm.write {
            realm.delete(todo)
        }
        
        let expectation = self.expectation(description: #function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            expectation.fulfill()
        }
        
        waitForExpectations { error in
            XCTAssertNil(error)
            
            XCTAssertTrue(publisher.object === todo)
            XCTAssertEqual(recorder.recordedValues.count, 4)
            assert(
                recorder.recordedValues[0],
                change: [
                    String(from: \Todo.title),
                    String(from: \Todo.isDone)
                ]
            )
            assert(
                recorder.recordedValues[1],
                change: [
                    String(from: \Todo.isDone)
                ]
            )
            assert(
               recorder.recordedValues[2],
               change: [
                   String(from: \Todo.title)
               ]
            )
            assertDeleted(recorder.recordedValues[3])
        }
    }
    
    func testObserveObjectSugarSyntax() {
        let todo = Todo("Test")
        let publisher: ObserveObjectPublisher = todo.observePublisher()
        
        XCTAssertTrue(publisher.object === todo)
    }
    
    func testObserverCancel() throws {
        let todo = Todo("Test")
        try realm.write {
           realm.add(todo)
        }
        let publisher = ObserveObjectPublisher(object: todo)
        let recorder = Recorder<ObserveObjectPublisher.ObjectChange, Error>()
        publisher.subscribe(recorder)

        try realm.write {
           todo.title = ""
           todo.isDone = false
        }

        try realm.write {
           todo.isDone = true
        }
        
        let expectation = self.expectation(description: #function)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            recorder.cancel()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                do {
                    try self.realm.write {
                        todo.title = ""
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        expectation.fulfill()
                    }
                } catch let error {
                    XCTFail(error.localizedDescription)
                }
            }
        }

        waitForExpectations { error in
           XCTAssertNil(error)
           
           XCTAssertEqual(recorder.recordedValues.count, 2)
           assert(
               recorder.recordedValues[0],
               change: [
                   String(from: \Todo.title),
                   String(from: \Todo.isDone)
               ]
           )
           assert(
               recorder.recordedValues[1],
               change: [
                   String(from: \Todo.isDone)
               ]
           )
        }
    }
}

func assertDeleted(
    _ change: ObserveObjectPublisher.ObjectChange,
    file: StaticString = #file,
    line: UInt = #line
) {
    guard case .deleted = change else {
        XCTFail("\(change) is not deleted", file: file, line: line)
        return
    }
}

func assert(
    _ change: ObserveObjectPublisher.ObjectChange,
    change expectedProperties: [String],
    file: StaticString = #file,
    line: UInt = #line
) {
    guard case .change(let properties) = change else {
        XCTFail("\(change) is not change", file: file, line: line)
        return
    }
    
    XCTAssertEqual(
        properties.count,
        expectedProperties.count,
        "Number of properties",
        file: file,
        line: line
    )
    
    assert(
        properties.map { $0.name },
        contains: expectedProperties,
        description: " (property name)",
        file: file,
        line: line
    )
}
