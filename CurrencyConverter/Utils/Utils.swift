//
//  Utils.swift
//  CurrencyConverter
//
//  Created by MasterBi on 13/01/2025.
//
import Foundation

public let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 0
		formatter.minimumIntegerDigits = 1
		return formatter
	}()

public let scientificFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.numberStyle = .scientific
	formatter.maximumFractionDigits = 2
	formatter.exponentSymbol = "e"
	return formatter
}()
