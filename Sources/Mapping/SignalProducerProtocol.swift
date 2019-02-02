//
//  SignalProducerProtocol.swift
//  FireStore-iOS
//
//  Created by José Donor on 27/12/2018.
//

#if USE_REACTIVESWIFT
import FirebaseFirestore
import ReactiveSwift
import SwiftXtend



extension SignalProducerProtocol where Value == DocumentSnapshot?, Error == NSError {

	/// Maps document snapshots to a dictionary.
	///
	/// - Returns: A signal producer
	public func mapData() -> SignalProducer<(id: String, data: [String: Any]?)?, Error> {
		return producer.lift { $0.mapData() }
	}

	/// Maps document snapshots to the given type.
	///
	/// - Returns: A signal producer
	public func map<T: Identifiable & Decodable>(_ type: T.Type)
		-> SignalProducer<T?, Error> where T.Identifier == String {

			return producer.lift { $0.map(type) }
	}

	/// Maps document snapshots to the given type and adds metadata.
	///
	/// - Returns: A signal producer
	public func mapWithMetadata<T: Identifiable & Decodable>(_ type: T.Type)
		-> SignalProducer<(value: T, metadata: SnapshotMetadata)?, Error> where T.Identifier == String {

			return producer.lift { $0.mapWithMetadata(type) }
	}

}


extension SignalProducerProtocol where Value == QuerySnapshot?, Error == NSError {

	/// Maps query snapshots to a dictionary of dictionaries.
	///
	/// - Returns: A signal producer
	public func mapData() -> SignalProducer<[String: [String: Any]], Error> {
		return producer.lift { $0.mapData() }
	}

	/// Maps query snapshots to an array of the given types.
	///
	/// - Returns: A signal producer
	public func mapArray<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<[T], Error> where T.Identifier == String {

			return producer.lift { $0.mapArray(of: type) }
	}

	/// Maps query snapshots to a set of the given types.
	///
	/// - Returns: A signal producer
	public func mapSet<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<Set<T>, Error> where T.Identifier == String {

			return producer.lift { $0.mapSet(of: type) }
	}

	/// Maps query snapshots to an array of the given types and adds metadata.
	///
	/// - Returns: A signal producer
	public func mapArrayWithMetadata<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<(values: [T], metadatas: [SnapshotMetadata], queryMetadata: SnapshotMetadata?), Error> where T.Identifier == String {

			return producer.lift { $0.mapArrayWithMetadata(of: type) }
	}

	/// Maps query snapshots to an array of changes.
	///
	/// - Returns: A signal producer
	public func mapChanges<T: Identifiable & Decodable>(of type: T.Type)
		-> SignalProducer<[Change<T>], Error> where T.Identifier == String {

			return producer.lift { $0.mapChanges(of: type) }
	}

}
#endif
