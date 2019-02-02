//
//  DocumentSnapshot_Spec.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 02/02/2019.
//

// swiftlint:disable force_try

import FirebaseFirestore
@testable import FireStore
import Nimble
import Quick



class DocumentSnapshot_Spec: QuickSpec {
	override func spec() {

		AsyncDefaults.Timeout = 3

		var collection: CollectionPath!


		beforeEach {

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



		describe("DocumentSnapshot") {

			describe("map(_:)") {
				it("maps document snapshot to the given type") {

					let path = collection.document(withId: "id")

					var car = Car.default
					let data = try! car.data()
					car.id = "id"

					waitUntil(timeout: 3) { done in
						store.save(data: data,
								   path: path,
								   completed: { _ in done() },
								   failed: { _ in })
					}


					var mapSucceeded = false

					let completed: (DocumentSnapshot?) -> Void = { document in
						if let document = document {
							if let value = document.map(Car.self).a,
								let mappedCar = value {

								mapSucceeded = mappedCar == car
							}
						}
					}

					store.get(path: path,
							  source: .server,
							  completed: completed,
							  failed: Error.catchError)

					expect(mapSucceeded).toEventually(beTrue())

				}
			}

		}

	}
}
