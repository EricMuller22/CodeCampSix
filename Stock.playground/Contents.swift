import Foundation


struct StockGrant
{
    let shares: UInt
    let strikePrice: Double
    let grantDate: Date
    let cliffMonths: UInt
    let endMonths: UInt

    // RSU grants will use default value for strikePrice, NSO grants will set a strike price.
    init(shares: UInt, grantDate: Date, cliffMonths: UInt, endMonths: UInt, strikePrice: Double = 0)
    {
        self.strikePrice = strikePrice
        self.shares = shares
        self.grantDate = grantDate
        self.cliffMonths = cliffMonths
        self.endMonths = endMonths
    }

    // Bonus grants: vest instantly
    init(shares: UInt, grantDate: Date, strikePrice: Double = 0)
    {
        self.shares = shares
        self.strikePrice = strikePrice
        self.grantDate = grantDate
        cliffMonths = 0
        endMonths = 0
    }

    func valueAt(_ price: Double, monthsElapsed months: UInt) -> Double
    {
        guard months >= cliffMonths else { return 0 }
        guard months <= endMonths else { return valueAt(price, sharesAccrued: Double(shares)) }
        guard price > strikePrice else { return 0 }

        let percentageAccrued = Double(months) / Double(endMonths)
        let sharesAccrued = floor(percentageAccrued * Double(shares))
        return valueAt(price, sharesAccrued: sharesAccrued)
    }

    func valueAt(_ price: Double, date: Date) -> Double
    {
        let monthsElapsed = date.monthsSince(grantDate)
        if (monthsElapsed < 0) { return 0 }
        return valueAt(price, monthsElapsed: UInt(monthsElapsed))
    }

    private func valueAt(_ price: Double, sharesAccrued: Double) -> Double
    {
        let shareValue = price - strikePrice
        let value = max(0, shareValue)
        let shareCount = max(0, min(Double(shares), sharesAccrued))
        return value * shareCount
    }
}


extension Date
{
    static func grantDate(month: Int, day: Int, year: Int) -> Date
    {
        let signing = NSDateComponents.init()
        signing.calendar = Calendar.grantDateCalendar()
        signing.month = month
        signing.day = day
        signing.year = year
        return signing.date!
    }

    func monthsSince(_ date: Date) -> Int
    {
        let dateComponents = Calendar.grantDateCalendar().components(.month, from: date, to: self)
        return dateComponents.month!
    }

    func after(months: Int) -> Date
    {
        return after(months, unit: .month)
    }

    func after(years: Int) -> Date
    {
        return after(years, unit: .year)
    }

    private func after(_ amount: Int, unit: Calendar.Unit) -> Date
    {
        return Calendar.grantDateCalendar().date(byAdding: unit, value: amount, to: self)!
    }
}


extension Calendar
{
    static func grantDateCalendar() -> Calendar
    {
        return Calendar(calendarIdentifier: .gregorian)!
    }
}


let signing = Date.grantDate(month: 1, day: 1, year: 2016)
let signingGrant = StockGrant(shares: 20000, grantDate: signing, cliffMonths: 12, endMonths: 48, strikePrice: 1.22)

let twoYears = signing.after(years: 2)
let fourYears = signing.after(years: 4)

// Before cliff: should be zero
signingGrant.valueAt(22, monthsElapsed: signingGrant.cliffMonths - 1)

// Zero months elapsed: should be zero
assert(signingGrant.cliffMonths > 0)
signingGrant.valueAt(22, monthsElapsed: 0)

// Negative years (invalid): should be zero
let negativeYears = signing.after(years: -1)
signingGrant.valueAt(22, date: negativeYears)

// Progression up to end date:
signingGrant.valueAt(22, monthsElapsed: 24)
signingGrant.valueAt(22, date: twoYears)
signingGrant.valueAt(22, monthsElapsed: 48)
signingGrant.valueAt(22, date: fourYears)

// After end date: should be equal to end date value
signingGrant.valueAt(22, monthsElapsed: signingGrant.endMonths)
signingGrant.valueAt(22, monthsElapsed: signingGrant.endMonths + 1)
signingGrant.valueAt(22, date: signingGrant.grantDate.after(months: Int(signingGrant.endMonths)))
signingGrant.valueAt(22, date: signingGrant.grantDate.after(months: Int(signingGrant.endMonths + 1)))

let rsuGrant = StockGrant(shares: 10000, grantDate: twoYears, cliffMonths: 12, endMonths: 48)
rsuGrant.valueAt(22, monthsElapsed:rsuGrant.cliffMonths - 1)
rsuGrant.valueAt(22, monthsElapsed:rsuGrant.cliffMonths)
rsuGrant.valueAt(11, monthsElapsed:rsuGrant.endMonths)
rsuGrant.valueAt(22, monthsElapsed:rsuGrant.endMonths)
rsuGrant.valueAt(22, monthsElapsed:rsuGrant.endMonths + 1)

let bonusGrant = StockGrant(shares: 2000, grantDate: fourYears)
bonusGrant.valueAt(22, date: bonusGrant.grantDate.after(months: -1))
bonusGrant.valueAt(11, monthsElapsed: 0)
bonusGrant.valueAt(22, monthsElapsed: 0)
bonusGrant.valueAt(22, monthsElapsed: 20)

// Poke at private implementation details a bit:
signingGrant.valueAt(-1, sharesAccrued: 100)
signingGrant.valueAt(22, sharesAccrued: -1)
signingGrant.valueAt(22, sharesAccrued: Double(signingGrant.shares + 1))
