//
//  DocumentSnapshot.swift
//  FireStore
//
//  Created by José Donor on 14/01/2019.
//

import FirebaseFirestore
import SwiftXtend



extension DocumentSnapshot {

	public func map<T: Identifiable & Decodable>(_ type: T.Type) throws -> T? where T.Identifier == String {

		guard exists else { return nil }

		do {
			let data = try JSONSerialization.data(withJSONObject: self.data() as Any)

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970

			var value = try decoder.decode(type, from: data)
			value.id = documentID

			return value
		}
		catch let error as NSError {
			throw error
		}

	}

	public func mapWithMetadata<T: Identifiable & Decodable>(_ type: T.Type) throws -> (value: T, metadata: SnapshotMetadata)? where T.Identifier == String {

		guard exists else { return nil }

		do {
			let data = try JSONSerialization.data(withJSONObject: self.data() as Any)

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970

			var value = try decoder.decode(type, from: data)
			value.id = documentID

			let metadata = document.metadata

			return (value, metadata)
		}
		catch let error as NSError {
			throw error
		}

	}

}
