//
//  Change.swift
//  FireStore-iOS
//
//  Created by José Donor on 27/12/2018.
//

import FirebaseFirestore
import SwiftXtend



public enum Change<T: Identifiable & Decodable> where T.Identifier == String {

	case delete(T, at: Int)
	case insert(T, at: Int)
	case move(T, from: Int, to: Int)
	case update(T, at: Int)


	// MARK: - Initialize

	public init(change: DocumentChange,
				ofType type: T.Type) throws {

		let document = change.document

		let data = try JSONSerialization.data(withJSONObject: document.data())

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .millisecondsSince1970

		var value = try decoder.decode(type, from: data)
		value.id = document.documentID

		switch change.type {
		case .removed:
			self = .delete(value, at: Int(change.oldIndex))
		case .added:
			self = .insert(value, at: Int(change.newIndex))
		case .modified:

			if change.oldIndex != change.newIndex {
				self = .move(value, from: Int(change.oldIndex), to: Int(change.newIndex))
			}
			else {
				self = .update(value, at: Int(change.newIndex))
			}
		}

	}


	public var value: T {
		switch self {
		case let .delete(value, _),
			 let .insert(value, _),
			 let .move(value, _, _),
			 let .update(value, _):
			return value
		}
	}

	public var oldIndex: Int? {
		switch self {
		case let .delete(_, index),
			 let .move(_, index, _),
			 let .update(_, index):
			return index
		case .insert:
			return nil
		}
	}

	public var newIndex: Int? {
		switch self {
		case let .insert(_, index),
			 let .move(_, _, index),
			 let .update(_, index):
			return index
		case .delete:
			return nil
		}
	}

}
