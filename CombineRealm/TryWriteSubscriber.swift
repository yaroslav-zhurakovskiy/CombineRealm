//    
//  CombineRealm
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import RealmSwift
import Combine

public extension Realm {
    final class TryWrite<Input>: Subscriber, Cancellable {
        public typealias Failure = Never
        
        public let combineIdentifier: CombineIdentifier

        private let writeBlock: (Realm, Input) throws -> Void
        private let handleFailure: ((Swift.Error) -> Void)?
        private let receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)?
        private let realm: Realm?

        private var subscription: Subscription?

        public init(
           realm: Realm,
           writeBlock: @escaping (Realm, Input) throws -> Void,
           handleFailure: ((Swift.Error) -> Void)? = nil,
           receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil
        ) {
            self.realm = realm
            self.writeBlock = writeBlock
            self.handleFailure = handleFailure
            self.receiveCompletion = receiveCompletion
            self.combineIdentifier = CombineIdentifier()
        }
        
        public init(
           writeBlock: @escaping (Realm, Input) throws -> Void,
           handleFailure: ((Swift.Error) -> Void)? = nil,
           receiveCompletion: ((Subscribers.Completion<Failure>) -> Void)? = nil
        ) {
            self.realm = nil
            self.writeBlock = writeBlock
            self.handleFailure = handleFailure
            self.receiveCompletion = receiveCompletion
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
                   try self.writeBlock(realm, input)
                }
            } catch let error {
                handleFailure?(error)
            }
            return .unlimited
        }

        public func receive(completion: Subscribers.Completion<Failure>) {
           receiveCompletion?(completion)
        }

        public func cancel() {
            subscription?.cancel()
        }
    }
}

public extension Publisher where Failure == Never {
    func tryWrite(
        to realm: Realm,
        writeBlock: @escaping (Realm, Output) throws -> Void,
        handleFailure: ((Error) -> Void)? = nil
    ) -> AnyCancellable {
        let subscriber = Realm.TryWrite(
            realm: realm,
            writeBlock: writeBlock,
            handleFailure: handleFailure
        )
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
    
    func tryWriteToRealm(writeBlock: @escaping (Realm, Output) throws -> Void) -> AnyCancellable {
        let subscriber = Realm.TryWrite(writeBlock: writeBlock)
        self.subscribe(subscriber)
        return AnyCancellable(subscriber)
    }
}
