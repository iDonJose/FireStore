//
//  SignalProducerProtocol_Spec.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 02/02/2019.
//

// swiftlint:disable force_try

import FirebaseFirestore
@testable import FireStore
import Nimble
import Quick



class SignalProducerProtocol_Spec: QuickSpec {
	override func spec() {

		AsyncDefaults.Timeout = 3

		var collection: CollectionPath!
		var path: DocumentPath!
		var id: String!


		beforeEach {

			collection = CollectionPath(path: "documents")!
			id = "id"
			path = collection.document(withId: id)

			waitUntil(timeout: 5) { done in
				store.batchDelete(path: collection,
								  query: nil,
								  batchSize: 10,
								  source: .server,
								  completed: { _ in done() },
								  failed: { _ in })
			}

			waitUntil(timeout: 3) { done in
				store.save(data: try! Car.default.data(),
						   path: path,
						   completed: { _ in done() },
						   failed: { _ in })
			}

			waitUntil(timeout: 3) { done in
				store.save(data: try! Car.twingo.data(),
						   path: collection.document(withId: "twingo"),
						   completed: { _ in done() },
						   failed: { _ in })
			}

		}



		describe("SignalProducerProtocol") {

			context("Value is a DocumentSnapshot") {

				describe("mapData()") {
					it("maps document snapshot to a dictionary") {

						var mapSucceeded = false

						store.reactive
							.get(path: path,
								 source: .server)
							.mapData()
							.catchError()
							.startWithValues {
								if let value = $0 {
									mapSucceeded = try! value.id == id
										&& value.data == Car.default.data()
								}
							}

						expect(mapSucceeded).toEventually(beTrue())

					}
				}

				describe("map(_:)") {
					it("maps document snapshot to the given type") {

						var car = Car.default
						car.id = id

						var mapSucceeded = false

						store.reactive
							.get(path: path,
								 source: .server)
							.map(Car.self)
							.catchError()
							.startWithValues { mapSucceeded = $0 == car }

						expect(mapSucceeded).toEventually(beTrue())

					}
				}

			}


			context("Value is a QuerySnapshot") {

				describe("mapData()") {
					it("maps query snapshot to a dictionary of dictionaries") {

						let expectedData = [
							id: try! Car.default.data(),
							"twingo": try! Car.twingo.data()
						]

						var mapSucceeded = false

						store.reactive
							.get(path: collection,
								 query: nil,
								 source: .server)
							.mapData()
							.catchError()
							.startWithValues { mapSucceeded = $0 == expectedData }

						expect(mapSucceeded).toEventually(beTrue())

					}
				}

				describe("mapArray(of:)") {
					it("maps document snapshot to an array of the given types") {

						var car = Car.default
						car.id = id

						var twingo = Car.twingo
						twingo.id = "twingo"

						let expectedData = [car, twingo]

						var mapSucceeded = false

						store.reactive
							.get(path: collection,
								 query: nil,
								 source: .server)
							.mapArray(of: Car.self)
							.catchError()
							.startWithValues { mapSucceeded = $0 == expectedData }

						expect(mapSucceeded).toEventually(beTrue())

					}
				}

				describe("mapChanges(of:)") {
					it("maps document snapshot to an array of changes") {

						var car = Car.default
						car.id = id

						var twingo = Car.twingo
						twingo.id = "twingo"

						var mapSucceeded = false

						store.reactive
							.get(path: collection,
								 query: nil,
								 source: .server)
							.mapChanges(of: Car.self)
							.catchError()
							.startWithValues { changes in
								if changes.count == 2 {
									if case .insert = changes[0],
										case .insert = changes[1] {

										mapSucceeded = changes[0].value == car
											&& changes[1].value == twingo
									}
								}
							}

						expect(mapSucceeded).toEventually(beTrue())

					}
				}

			}

		}

	}
}
