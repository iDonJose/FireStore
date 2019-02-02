//
//  SequenceCondition.swift
//  FireStore-Tests-iOS
//
//  Created by José Donor on 01/02/2019.
//


final class SequenceCondition<T> {

	/// Condition is fulfilled
	private(set) var result = false

	/// Targeted sequence to fulfill condition
	private let sequence: [T]
	/// Wether stream of values must match sequence exactly
	private let allowsFailing: Bool
	/// Equality test
	private let areEqual: (T, T) -> Bool

	/// Current index
	private var index = 0
	/// Still listen to incoming values
	private var isActive = true


	convenience init(_ sequence: T...,
					allowsFailing: Bool = true,
					areEqual: @escaping (_ lhs: T, _ rhs: T) -> Bool) {
		self.init(sequence, allowsFailing: allowsFailing, areEqual: areEqual)
	}

	init(_ sequence: [T],
		 allowsFailing: Bool = true,
		 areEqual: @escaping (_ lhs: T, _ rhs: T) -> Bool) {

		assert(sequence.isNotEmpty, "Sequence must contain at least 1 element")

		self.sequence = sequence
		self.allowsFailing = allowsFailing
		self.areEqual = areEqual
	}


	func send(_ value: T) {
		guard isActive else { return }

		if areEqual(value, sequence[index]) {
			if index == sequence.lastIndex {
				isActive = false
				result = true
			}
			else { index += 1 }
		}
	}

}
