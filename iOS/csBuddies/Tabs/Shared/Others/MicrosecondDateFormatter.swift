// Source: https://stackoverflow.com/a/43130186

public final class MicrosecondPrecisionDateFormatter: DateFormatter {

    private let microsecondsPrefix = "."

    override public init() {
        super.init()
        locale = Locale(identifier: "en_US_POSIX")
        timeZone = TimeZone(secondsFromGMT: 0)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func string(from date: Date) -> String {
        dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"
        let components = calendar.dateComponents(Set([Calendar.Component.nanosecond]), from: date)

        let nanosecondsInMicrosecond = Double(1000)
        let microseconds = lrint(Double(components.nanosecond!) / nanosecondsInMicrosecond)

        // Subtract nanoseconds from date to ensure string(from: Date) doesn't attempt faulty rounding.
        let updatedDate = calendar.date(byAdding: .nanosecond, value: -(components.nanosecond!), to: date)!
        let dateTimeString = super.string(from: updatedDate)

        let string = String(format: "%@.%06ldZ",
                            dateTimeString,
                            microseconds)

        return string
    }

    override public func date(from string: String) -> Date? {
        dateFormat = "yyyy-MM-dd HH:mm:ssZZZZZ"
        
        guard let microsecondsPrefixRange = string.range(of: microsecondsPrefix) else { return nil }
        let microsecondsWithTimeZoneString = String(string.suffix(from: microsecondsPrefixRange.upperBound))

        let nonDigitsCharacterSet = CharacterSet.decimalDigits.inverted
        guard let timeZoneRangePrefixRange = microsecondsWithTimeZoneString.rangeOfCharacter(from: nonDigitsCharacterSet) else { return nil }

        let microsecondsString = String(microsecondsWithTimeZoneString.prefix(upTo: timeZoneRangePrefixRange.lowerBound))
        guard let microsecondsCount = Double(microsecondsString) else { return nil }

        let dateStringExludingMicroseconds = string
            .replacingOccurrences(of: microsecondsString, with: "")
            .replacingOccurrences(of: microsecondsPrefix, with: "")

        guard let date = super.date(from: dateStringExludingMicroseconds) else { return nil }
        let microsecondsInSecond = Double(1000000)
        let dateWithMicroseconds = date + microsecondsCount / microsecondsInSecond

        return dateWithMicroseconds
    }
}
