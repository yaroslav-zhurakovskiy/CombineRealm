//    
//  CombineRealm
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import RealmSwift
import Combine

public extension Realm {
    final class Write<Input>: Subscriber, Cancellable {
        public typealias Failure = Never
        
        public let combineIdentifier: CombineIdentifier

        private let writeBlock: (Realm, Input) -> Void
        private let handleFailure: ((Swift.Error) -> Void)?
        private let realm: Realm?

        private var subscription: Subscription?

        public init(
           realm: Realm,
           writeBlock: @escaping (Realm, Input) -> Void,
           handleFailure: ((Swift.Error) -> Void)? = nil
        ) {
            self.realm = realm
            self.writeBlock = writeBlock
            self.handleFailure = handleFailure
            self.combineIdentifier = CombineIdentifier()
        }
        
        public init(
           writeBlock: @escaping (Realm, Input) -> Void,
           handleFailure: ((Swift.Error) -> Void)? = nil
        ) {
            self.realm = nil
            self.writeBlock = writeBlock
            self.handleFailure = handleFailure
            self.combineIdentifier = CombineIdentifier()
        }

        public func receive(subscription: Subscription) {
            self.subscription = subscription
            
            subscription.request(.unlimited)
        }

        public func receive(_ input: Input) -> Subscribers.Demand {
            do {
                let realm = try self.realm ?? Realm()
                try realm.write {
                   self.writeBlock(realm, input)
                }
            } catch let error {
                handleFailure?(error)
            }
            return .unlimited
        }

        public func receive(completion: Subscribers.Completion<Failure>) {
            
        }

        public func cancel() {
            subscription?.cancel()
        }
    }
}

public extension Publisher where Failure == Never {
    func write(
        to realm: Realm,
        writeBlock: @escaping (Realm, Output) -> Void
    ) -> AnyCancellable {
        let subscriber = Realm.Write(realm: realm, writeBlock: writeBlock)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
    
    func writeToRealm(writeBlock: @escaping (Realm, Output) -> Void) -> AnyCancellable {
        let subscriber = Realm.Write(writeBlock: writeBlock)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}
