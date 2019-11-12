//    
//  CombineRealm
//    
//  Created by Yaroslav Zhurakovskiy on 06.11.2019.
//  Copyright © 2019 Yaroslav Zhurakovskiy. All rights reserved.
//

import Combine
import RealmSwift

public struct ObserveObjectPublisher: Publisher {
    public enum ObjectChange {
        case change([PropertyChange])
        case deleted
    }

    public typealias Output = ObjectChange
    public typealias Failure = Error

    public let object: Object

    public init(object: Object) {
        self.object = object
    }

    public func receive<S>(
        subscriber: S
    ) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        subscriber.receive(
            subscription: Subscription(
                object: object,
                subscriber: AnySubscriber(subscriber)
            )
        )
    }

    private class Subscription: Combine.Subscription {
        private let object: Object
        private let subscriber: AnySubscriber<Output, Failure>
        private var token: NotificationToken?

        let combineIdentifier: CombineIdentifier = CombineIdentifier()

        init(object: Object, subscriber: AnySubscriber<Output, Failure>) {
            self.object = object
            self.subscriber = subscriber
            self.token = nil
        }

        func request(_ demand: Subscribers.Demand) {
            token = object.observe { [weak self] change in
                guard let self = self else { return }

                switch change {
                case .change(let properties):
                    self.updateChange(properties)
                case .deleted:
                    self.updateDeleted()
                case .error(let error):
                    self.updateError(error)
                }
            }
        }

        func cancel() {
            token?.invalidate()
            token = nil
        }

        private func updateDeleted() {
           // TODO: Implement custom Demand
            _ = subscriber.receive(.deleted)
        }

        private func updateError(_ error: Error) {
            self.token = nil
            self.subscriber.receive(completion: .failure(error))
        }

        private func updateChange(_ properties: [PropertyChange]) {
            // TODO: Implement custom Demand
           _ = subscriber.receive(.change(properties))
        }
    }
}
