//
//  DocumentSnapshot.swift
//  FireStore
//
//  Created by José Donor on 14/01/2019.
//

import FirebaseFirestore
import SwiftXtend



extension DocumentSnapshot {

	public func map<T: Identifiable & Decodable>(_ type: T.Type) -> Either<T?, NSError> where T.Identifier == String {

		guard exists else { return .init(nil) }

		do {
			let data = try JSONSerialization.data(withJSONObject: self.data() as Any)

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970

			var value = try decoder.decode(type, from: data)
			value.id = documentID

			return .init(value)
		}
		catch let error as NSError {
			return .init(error)
		}

	}

	public func mapWithMetadata<T: Identifiable & Decodable>(_ type: T.Type) -> Either<(value: T, metadata: SnapshotMetadata)?, NSError> where T.Identifier == String {

		guard exists else { return .init(nil) }

		do {
			let data = try JSONSerialization.data(withJSONObject: self.data() as Any)

			let decoder = JSONDecoder()
			decoder.dateDecodingStrategy = .millisecondsSince1970

			var value = try decoder.decode(type, from: data)
			value.id = documentID

            return .init((value, metadata))
		}
		catch let error as NSError {
            return .init(error)
		}

	}

}
