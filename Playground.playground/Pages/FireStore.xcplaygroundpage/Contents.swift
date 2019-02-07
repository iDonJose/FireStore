import FirebaseCore
import FirebaseFirestore
import FireStore
import Foundation
import ReactiveSwift
import Result
import SwiftXtend


// Setup

private final class Mock {}

private let app: FirebaseApp = {

    let path = Bundle(for: Mock.self)
        .path(forResource: "GoogleService-Info", ofType: "plist")!

    let options = FirebaseOptions(contentsOfFile: path)!
    FirebaseApp.configure(options: options)

    return FirebaseApp.app()!
}()


let store: Firestore = {

    let settings = FirestoreSettings()
    settings.dispatchQueue = DispatchQueue(label: "Firestore",
                                           qos: .default)
    settings.isPersistenceEnabled = true
    settings.areTimestampsInSnapshotsEnabled = true

    let store = Firestore.firestore(app: app)
    store.settings = settings

    return store
}()


struct Message: Identifiable, Codable {

    var id: String = ""

    var sender: String = ""
    var receiver: String = ""
    var text: String = ""
    var date: Double = 0

    init(id: String) {
        self.id = id
    }

    init(id: String = "",
         sender: String = "",
         receiver: String = "",
         text: String = "",
         date: Double = 0) {
        self.id = id
        self.sender = sender
        self.receiver = receiver
        self.text = text
        self.date = date
    }


    func data() throws -> [String: Any] {

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970

        let encoded = try encoder.encode(self)
        let data = try JSONSerialization.jsonObject(with: encoded)

        if let data = data as? [String: Any] {
            return data
        }
        else {
            let userInfo = [
                NSLocalizedFailureReasonErrorKey: "Failed to encode \(type(of: self)) to a dictionary [String: Any]",
                NSLocalizedDescriptionKey: "\(type(of: self)) is not encodable to a data of type [String: Any]"
            ]
            throw NSError(domain: "Tests", code: 1, userInfo: userInfo)
        }

    }

}



/*:
 # `FireStore`
 */

let messages = CollectionPath(path: "messages")!

/*:
 ## `observe(path:query:includeMetadataChanges:)`
 Observes and filters query snapshots at the given path.
 > See also `get(path:query:source:)`.

 ## `mapChange(of:)`
 Converts query snapshots to an array of changes.
 > See also `mapArray(of:)`, `mapSet(of:)`, `mapArrayWithMetadata(of:)`.
 */

// Observes all my messages

let disposable_1 = store.reactive
    .observe(path: messages,
             query: { $0.whereField("receiver", isEqualTo: "me") },
             includeMetadataChanges: false)
    .mapChanges(of: Message.self)
    .flatMapError { _ in SignalProducer.empty }
    .startWithValues { if $0.isNotEmpty { print("You received a new message", $0.map { $0.value }) } }

// Observes messages that I send

let disposable_2 = store.reactive
    .observe(path: messages,
             query: { $0.whereField("receiver", isEqualTo: "friend") },
             includeMetadataChanges: false)
    .mapChanges(of: Message.self)
    .flatMapError { _ in SignalProducer.empty }
    .startWithValues { if $0.isNotEmpty { print("You have sent a message", $0.map { $0.value }) } }


/*:
 ## `save(data:path:)`
 Saves data at the given path.
 > See also `updateOnly(data:path:)`, `merge(data:fields:path:)`.
 */

// Creates a new message from friend

store.reactive
    .save(data: Message(sender: "friend",
                        receiver: "me",
                        text: "👋 hey buddy",
                        date: 1).data(),
          path: messages.newDocument())
    .wait()

// Answers my friend with a new message

store.reactive
    .save(data: Message(sender: "me",
                        receiver: "friend",
                        text: "Hi ! Do you time for a ☕️ ?",
                        date: 2).data(),
          path: messages.document(withId: "my message"))
    .wait()


/*:
 ## `updateOnly(data:path:)`
 Updates data at the given path only if it exists.
 */

store.reactive
    .updateOnly(data: Message(sender: "me",
                              receiver: "friend",
                              text: "Hi ! Do you time to 🏃‍♂️ ?",
                              date: 3).data(),
          path: messages.document(withId: "my message"))
    .wait()


/*:
 ## `batchDelete(path:query:batchSize:source:)`
 Performs deletions in a single atomic operation.
 > See also `batchUpdate(batch:)`, `runTransaction(transaction:)`.
 */

// Cleans up every messages

disposable_1.dispose()
disposable_2.dispose()

store.reactive
    .batchDelete(path: messages,
                 query: nil,
                 batchSize: 10,
                 source: .server)
    .wait()

print("Messages were cleaned up")


/*:
 ## `get(path:query:source:)`
 Gets and filters a query snapshot at the given path.

 ## `mapArray(of:)`
 Converts query snapshots to an array of the given types.
 */

// Checks messages on the database

store.reactive
    .get(path: messages,
         query: nil,
         source: .server)
    .mapArray(of: Message.self)
    .flatMapError { _ in SignalProducer.empty }
    .startWithValues { print("Messages on the server", $0) }


//: < [Summary](Summary) | [Next](@next) >
