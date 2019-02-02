//
//  Error.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 01/02/2019.
//

import Foundation
import ReactiveSwift
import Result



struct Error {

	static func catchError(_ error: NSError) {
		print("⚠️ Failed : \(error)")
	}

}


extension SignalProducerProtocol where Error == NSError {

	func catchError() -> SignalProducer<Value, NoError> {

		return producer
			.on(failed: { print("⚠️ Failed : \($0)") })
			.flatMapError { _ in SignalProducer.empty }
	}

}
