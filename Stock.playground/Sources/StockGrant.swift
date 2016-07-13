import Foundation


public typealias Money = Double


public struct StockGrant
{
    // MARK: Vesting

    public enum VestingSchedule
    {
        case Instant
        case Monthly(cliff: Time, end: Time)

        var cliffMonths: UInt {
            if case Monthly(let cliff, _) = self {
                return cliff.months
            }
            return 0
        }

        var endMonths: UInt {
            if case Monthly(_, let end) = self {
                return end.months
            }
            return 0
        }
    }

    // MARK: Time

    public enum Time
    {
        case month(UInt)
        case year(UInt)

        var months: UInt {
            switch self {
            case .year(let count):
                return count * 12
            case .month(let count):
                return count
            }
        }
    }

    let shares: UInt
    let strikePrice: Money
    let grantDate: Date
    let vestingSchedule: VestingSchedule

    // RSU grants will use default value for strikePrice (0).
    // NSO grants will set a strike price.
    public init(shares: UInt, grantDate: Date, vestingSchedule: VestingSchedule = .Monthly(cliff: .year(1), end: .year(4)), strikePrice: Double = 0)
    {
        self.strikePrice = strikePrice
        self.shares = shares
        self.grantDate = grantDate
        self.vestingSchedule = vestingSchedule
    }

    // MARK: Value Over Time

    public func value(at price: Money, after time: Time) -> Money
    {
        if case .Instant = vestingSchedule { return value(at: price, sharesAccrued: shares) }

        guard time.months >= vestingSchedule.cliffMonths else { return 0 }
        guard price > strikePrice else { return 0 }

        let percentageAccrued = Double(time.months) / Double(vestingSchedule.endMonths)
        let sharesAccrued = UInt(floor(percentageAccrued * Double(shares)))
        return value(at: price, sharesAccrued: sharesAccrued)
    }

    public func value(at price: Money, onDate date: Date) -> Money
    {
        let monthsElapsed = date.monthsSince(grantDate)
        guard monthsElapsed >= 0 else { return 0 }
        return value(at: price, after: .month(UInt(monthsElapsed)))
    }

    // MARK: Private

    func value(at price: Money, sharesAccrued: UInt) -> Money
    {
        let shareValue = price - strikePrice
        let value = max(0, shareValue)
        let shareCount = max(0, min(Double(shares), Double(sharesAccrued)))
        return value * shareCount
    }
}


extension Date
{
    public static func grantDate(month: Int, day: Int, year: Int) -> Date
    {
        let components = DateComponents(calendar: Calendar.grantDateCalendar(), month: month, day: day, year: year)
        return components.date!
    }

    public func after(_ time: StockGrant.Time) -> Date
    {
        return Calendar.grantDateCalendar().date(byAdding: .month, value: Int(time.months), to: self)!
    }

    // MARK: Private

    func monthsSince(_ date: Date) -> Int
    {
        let components = Calendar.grantDateCalendar().components(.month, from: date, to: self)
        return components.month!
    }
}


extension Calendar
{
    static func grantDateCalendar() -> Calendar
    {
        return Calendar(calendarIdentifier: .gregorian)!
    }
}
