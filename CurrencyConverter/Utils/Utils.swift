//
//  Utils.swift
//  CurrencyConverter
//
//  Created by MasterBi on 13/01/2025.
//
import Foundation

/// Number formatter for regular currency display
///
/// # Configuration
/// - Decimal style
/// - Max 2 decimal places
/// - Min 0 decimal places
/// - At least 1 integer digit
///
/// # Usage Example
/// ```swift
/// let amount = 1234.56
/// let formatted = numberFormatter.string(from: NSNumber(value: amount))
/// // Result: "1,234.56"
/// ```
public let numberFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.maximumFractionDigits = 2
		formatter.minimumFractionDigits = 0
		formatter.minimumIntegerDigits = 1
		return formatter
	}()

/// Number formatter for scientific notation
///
/// # Configuration
/// - Scientific style
/// - Max 2 decimal places
/// - Uses 'e' as exponent symbol
///
/// # Usage Example
/// ```swift
/// let amount = 1234567.89
/// let formatted = scientificFormatter.string(from: NSNumber(value: amount))
/// // Result: "1.23e6"
/// ```
public let scientificFormatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.numberStyle = .scientific
	formatter.maximumFractionDigits = 2
	formatter.exponentSymbol = "e"
	return formatter
}()
