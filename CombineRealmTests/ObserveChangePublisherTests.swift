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

typealias TodoResultsChange = RealmCollectionChange<Results<Todo>>

class ObserveChangePublisherTests: RealmTestsCase {
    typealias TestRecorder = Recorder<TodoResultsChange, Never>
    
    var publisher: ObserveChangePublisher<Todo>!
    
    override func setUp() {
        super.setUp()
        
        publisher = ObserveChangePublisher(
            results: realm.objects(Todo.self)
        )
    }
    
    func testObserveChangesOfResults() throws {
        let recorder = TestRecorder()
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            expectation.fulfill()
        }
        
        waitForExpectations { error in
            XCTAssertNil(error)
            
            XCTAssertEqual(recorder.recordedValues.count, 4)
            assertInitial(recorder.recordedValues[0])
            assertUpdate(recorder.recordedValues[1])
            assertUpdate(recorder.recordedValues[2])
            assertUpdate(recorder.recordedValues[3])

            XCTAssertEqual(recorder.recordedCompletions.count, 0)
        }
    }
    
    func testCancel() throws {
        let recorder = TestRecorder()
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
             
            try! self.realm.write {
                self.realm.add(todo3)
            }
            
            try! self.realm.write {
                self.realm.add(todo4)
            }
             
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                expectation.fulfill()
            }
         }
        
        waitForExpectations { error in
            XCTAssertNil(error)
            
            XCTAssertEqual(recorder.recordedValues.count, 2)
            assertInitial(recorder.recordedValues[0])
            assertUpdate(recorder.recordedValues[1])

            XCTAssertEqual(recorder.recordedCompletions.count, 0)
        }
    }
}
