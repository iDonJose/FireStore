//
//  Firestore_Spec.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 01/02/2019.
//

import FirebaseCore
import FirebaseFirestore
@testable import FireStore
import Nimble
import Quick



class Firestore_Spec: QuickSpec {
	override func spec() {

		AsyncDefaults.Timeout = 3

		var id: String!
		var data: [String: Any]!
		var collection: CollectionPath!


		beforeEach {

			id = "id"

			data = [
				"string": "some text",
				"boolean": true,
				"number": 3,
				"array": [1, 2, 3],
				"dictionary": ["key": "value"]
 			]

			collection = CollectionPath(path: "documents")!

			waitUntil(timeout: 5) { done in
				store.batchDelete(path: collection,
								  query: nil,
								  batchSize: 10,
								  source: .server,
								  completed: { _ in done() },
								  failed: { _ in })
			}

		}


		describe("Firestore") {

			describe("get(path:source:completed:failed:)") {
				it("gets data at the given path") {

					let path = collection.document(withId: id)

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: path,
								   completed: { _ in done() },
								   failed: { _ in })
					}

					var dataExists = false

					store.get(path: path,
							  source: .server,
							  completed: { dataExists = ($0?.data() ?? [:]) == data },
							  failed: Error.catchError)

					expect(dataExists).toEventually(beTrue())

				}
			}

			describe("observe(path:includeMetadataChanges:completed:failed:)") {
				it("observes data at the given path") {

					let path = collection.document(withId: id)

					let values: [[String: Any]?] = [nil, data]
					let condition = SequenceCondition(values,
													  areEqual: { $0 == $1 })

					_ = store.observe(path: path,
									  includeMetadataChanges: false,
									  completed: { condition.send($0?.data()) },
									  failed: Error.catchError)

					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						store.save(data: data,
								   path: path,
								   completed: { _ in },
								   failed: { _ in })
					}

					expect(condition.result).toEventually(beTrue())

				}
			}


			describe("get(path:query:source:completed:failed:)") {
				it("gets data at the given path") {

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: collection.document(withId: id + "1"),
								   completed: { _ in done() },
								   failed: { _ in })
					}

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: collection.document(withId: id + "2"),
								   completed: { _ in done() },
								   failed: { _ in })
					}

					var dataExists = false

					let completed: (QuerySnapshot?) -> Void = { snapshot in
						if snapshot?.count == 2 {
							dataExists = snapshot!.documents[0].data() == data
								&& snapshot!.documents[1].data() == data
						}
					}

					store.get(path: collection,
							  query: nil,
							  source: .server,
							  completed: completed,
							  failed: Error.catchError)

					expect(dataExists).toEventually(beTrue())

				}
			}

			describe("observe(path:query:includeMetadataChanges:completed:failed:)") {
				it("observes data at the given path") {

					let values: [[[String: Any]]] = [[], [data], [data, data]]

					let areEqual: ([[String: Any]], [[String: Any]]) -> Bool = { lhs, rhs in
						guard lhs.count == rhs.count else { return false }
						for (i, element) in lhs.enumerated() {
							if element != rhs[i] { return false }
						}
						return true
					}

					let condition = SequenceCondition(values,
													  areEqual: areEqual)


					let completed: (QuerySnapshot?) -> Void = { snapshot in
						condition.send(snapshot?.documents.map({ $0.data() }) ?? [])
					}

					_ = store.observe(path: collection,
									  query: nil,
									  includeMetadataChanges: false,
									  completed: completed,
									  failed: Error.catchError)


					DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
						store.save(data: data,
								   path: collection.document(withId: id + "1"),
								   completed: { _ in },
								   failed: { _ in })
					}

					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						store.save(data: data,
								   path: collection.document(withId: id + "2"),
								   completed: { _ in },
								   failed: { _ in })
					}

					expect(condition.result).toEventually(beTrue())

				}
			}


			describe("save(data:path:completed:failed:)") {
				it("saves data at the given path") {

					let path = collection.document(withId: id)

					var wasSaved = false

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: path,
								   completed: { _ in wasSaved = true; done() },
								   failed: { _ in })
					}

					var dataExists = false

					store.get(path: path,
							  source: .server,
							  completed: { dataExists = ($0?.data() ?? [:]) == data },
							  failed: Error.catchError)

					expect(wasSaved).toEventually(beTrue())
					expect(dataExists).toEventually(beTrue())

				}
			}

			describe("merge(data:fields:path:completed:failed:)") {
				it("merges data to an existing one") {

					let path = collection.document(withId: id)

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: path,
								   completed: { _ in done() },
								   failed: { _ in })
					}

					var wasMerged = false

					waitUntil(timeout: 3) { done in
						store.merge(data: ["new field": 10],
									fields: ["new field"],
									path: path,
									completed: { _ in wasMerged = true; done() },
									failed: { _ in })
					}

					var newData = data!
					newData["new field"] = 10

					var dataIsUpToDate = false

					store.get(path: path,
							  source: .server,
							  completed: { dataIsUpToDate = ($0?.data() ?? [:]) == newData },
							  failed: Error.catchError)

					expect(wasMerged).toEventually(beTrue())
					expect(dataIsUpToDate).toEventually(beTrue())

				}
			}

			describe("updateOnly(data:path:completed:failed:)") {

				context("no data has been saved yet") {
					it("doesn't update or save data") {

						let path = collection.document(withId: id)

						var didNotUpdate = false

						store.updateOnly(data: data,
										 path: path,
										 completed: { _ in },
										 failed: { didNotUpdate = $0.code == 5 })

						expect(didNotUpdate).toEventually(beTrue())

					}
				}

				context("data already exists") {
					it("does update data") {

						let path = collection.document(withId: id)

						waitUntil(timeout: 3) { done in
							store.save(data: data,
									   path: path,
									   completed: { _ in done() },
									   failed: { _ in })
						}

						var newData = data!
						newData["new field"] = 10

						var didUpdate = false

						store.updateOnly(data: newData,
										 path: path,
										 completed: { _ in didUpdate = true },
										 failed: Error.catchError)

						var dataIsUpToDate = false

						store.get(path: path,
								  source: .server,
								  completed: { dataIsUpToDate = ($0?.data() ?? [:]) == newData },
								  failed: Error.catchError)

						expect(didUpdate).toEventually(beTrue())
						expect(dataIsUpToDate).toEventually(beTrue())

					}
				}

			}

			describe("delete(path:completed:failed:)") {
				it("deletes data at the given path") {

					let path = collection.document(withId: id)

					var wasSaved = false

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: path,
								   completed: { _ in wasSaved = true; done() },
								   failed: { _ in })
					}

					var wasDeleted = false

					store.delete(path: path,
								 completed: { _ in wasDeleted = true },
								 failed: { _ in })

					var dataIsDeleted = false

					store.get(path: path,
							  source: .server,
							  completed: { dataIsDeleted = $0?.data() == nil },
							  failed: Error.catchError)

					expect(wasSaved).toEventually(beTrue())
					expect(wasDeleted).toEventually(beTrue())
					expect(dataIsDeleted).toEventually(beTrue())

				}
			}


			describe("runTransaction(transaction:completed:failed:)") {
				it("makes changes atomically") {

					let path = collection.document(withId: id)

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: path,
								   completed: { _ in done() },
								   failed: { _ in })
					}


					let transaction: (Transaction, Firestore) throws -> Bool = { transaction, store in

						if var data = transaction.get(path: path, store: store).a?.data() {

							data["new field"] = 10
							transaction.save(data: data, path: path, store: store)
							return true
						}

						return false
					}

					var didRanTransaction = false

					waitUntil(timeout: 3) { done in
						store.runTransaction(transaction: transaction,
											 completed: { didRanTransaction = $0; done() },
											 failed: Error.catchError)
					}

					var newData = data!
					newData["new field"] = 10

					var dataIsUpToDate = false

					store.get(path: path,
							  source: .server,
							  completed: { dataIsUpToDate = $0?.data() == newData },
							  failed: Error.catchError)


					expect(didRanTransaction).toEventually(beTrue())
					expect(dataIsUpToDate).toEventually(beTrue())

				}
			}


			describe("batchUpdate(batch:completed:failed:)") {
				it("performs multiple writes atomically") {

					let path = collection.document(withId: id)

					let batch: (WriteBatch, Firestore) throws -> Bool = { batch, store in

						data.forEach { tuple in
							batch.merge(data: [tuple.key: tuple.value], fields: nil, path: path, store: store)
						}

						return true
					}

					var didBatchUpdate = false

					waitUntil(timeout: 3) { done in
						store.batchUpdate(batch: batch,
										  completed: { didBatchUpdate = $0; done() },
										  failed: Error.catchError)
					}

					var dataExists = false

					store.get(path: path,
							  source: .server,
							  completed: { dataExists = $0?.data() == data },
							  failed: Error.catchError)


					expect(didBatchUpdate).toEventually(beTrue())
					expect(dataExists).toEventually(beTrue())

				}
			}

			describe("batchDelete(path:query:batchSize:source:completed:failed:)") {
				it("performs multiple deletions atomically") {

					let batch: (WriteBatch, Firestore) throws -> Bool = { batch, store in

						batch.save(data: ["1": 1], path: collection.document(withId: id + "1"), store: store)
						batch.save(data: ["2": 2], path: collection.document(withId: id + "2"), store: store)
						batch.save(data: ["3": 3], path: collection.document(withId: id + "3"), store: store)

						return true
					}

					var didBatchWrite = false

					waitUntil(timeout: 3) { done in
						store.batchUpdate(batch: batch,
										  completed: { didBatchWrite = $0; done() },
										  failed: Error.catchError)
					}

					var didBatchDelete = false

					waitUntil(timeout: 3) { done in
						store.batchDelete(path: collection,
										  query: nil,
										  batchSize: 2,
										  source: .server,
										  completed: { _ in didBatchDelete = true; done() },
										  failed: Error.catchError)
					}


					var dataIsDeleted = false

					store.get(path: collection,
							  query: nil,
							  source: .server,
							  completed: { dataIsDeleted = $0?.documents.isEmpty ?? false },
							  failed: Error.catchError)


					expect(didBatchWrite).toEventually(beTrue())
					expect(didBatchDelete).toEventually(beTrue())
					expect(dataIsDeleted).toEventually(beTrue())

				}
			}

		}

	}

}
