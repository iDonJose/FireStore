//
//  Car.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 02/02/2019.
//

import Foundation
import SwiftXtend



struct Car: Identifiable, Codable {

	var id: String = ""

	var name: String = ""
	var cylinders: Int = 0
	var usesGaz: Bool = false
	var seats: [Int] = []

	init(id: String) {
		self.id = id
	}

	static var `default`: Car {
		var car = Car(id: "")
		car.name = "Camaro"
		car.cylinders = 12
		car.usesGaz = true
		car.seats = [2, 2]
		return car
	}

	static var twingo: Car {
		var car = Car(id: "")
		car.name = "Twingo"
		car.cylinders = 4
		car.usesGaz = true
		car.seats = [2, 3]
		return car
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
