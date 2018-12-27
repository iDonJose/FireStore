//
//  SignalProducerProtocol.swift
//  FireStore-iOS
//
//  Created by José Donor on 27/12/2018.
//

import FirebaseFirestore
import ReactiveSwift
import SwiftXtend



extension SignalProducerProtocol where Value == DocumentSnapshot?, Error == NSError {

	public func mapData() -> SignalProducer<(id: String, data: [String: Any]?)?, Error> {
		return producer.lift { $0.mapData() }
	}

	public func map<T: Identifiable & Decodable>(_ type: T.Type)
		-> SignalProducer<T?, Error> where T.Identifier == String {

			return producer.lift { $0.map(type) }
	}

	public func mapWithMetadata<T: Identifiable & Decodable>(_ type: T.Type)
		-> SignalProducer<(value: T, metadata: SnapshotMetadata)?, Error> where T.Identifier == String {

			return producer.lift { $0.mapWithMetadata(type) }
	}

}


extension SignalProducerProtocol where Value == QuerySnapshot?, Error == NSError {

	public func mapData() -> SignalProducer<[String: [String: Any]], Error> {
		return producer.lift { $0.mapData() }
	}

	public func mapArray<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<[T], Error> where T.Identifier == String {

			return producer.lift { $0.mapArray(of: type) }
	}

	public func mapSet<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<Set<T>, Error> where T.Identifier == String {

			return producer.lift { $0.mapSet(of: type) }
	}

	public func mapArrayWithMetadata<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<(values: [T], metadatas: [SnapshotMetadata], queryMetadata: SnapshotMetadata?), Error> where T.Identifier == String {

			return producer.lift { $0.mapArrayWithMetadata(of: type) }
	}

	public func mapChanges<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<[Change<T>], Error> where T.Identifier == String {

			return producer.lift { $0.mapChanges(of: type) }
	}

}
