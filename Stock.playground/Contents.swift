import Foundation


struct StockGrant
{
    struct GrantDate
    {
        private(set) var foundationDate: NSDate

        init (month: Int, day: Int, year: Int)
        {
            let signing = NSDateComponents.init()
            signing.calendar = NSCalendar.currentCalendar()
            signing.month = month
            signing.day = day
            signing.year = year
            self.foundationDate = signing.date!
        }
    }


    let shares: UInt
    let strikePrice: Double
    let grantDate: GrantDate
    let cliffMonths: UInt
    let endMonths: UInt


    // RSUs
    init(shares: UInt, grantDate: GrantDate, cliffMonths: UInt, endMonths: UInt)
    {
        self.strikePrice = 0
        self.shares = shares
        self.grantDate = grantDate
        self.cliffMonths = cliffMonths
        self.endMonths = endMonths
    }

    // NSOs
    init (shares: UInt, grantDate: GrantDate, cliffMonths: UInt, endMonths: UInt, strikePrice: Double)
    {
        self.strikePrice = strikePrice
        self.shares = shares
        self.grantDate = grantDate
        self.cliffMonths = cliffMonths
        self.endMonths = endMonths
    }

    func valueAfter(months: Int, atPrice: Double) -> Double
    {
        guard months >= Int(self.cliffMonths) else { return 0 }
        guard months <= Int(self.endMonths) else { return self.valueAfter(Int(self.endMonths), atPrice: atPrice) }
        guard atPrice > self.strikePrice else { return 0 }

        let shareValue = atPrice - self.strikePrice
        let sharesAccrued = floor(Double(months) / Double(self.endMonths) * Double(self.shares))
        return shareValue * sharesAccrued
    }

    func monthsSince(date: GrantDate) -> Int
    {
        let futureDate = date.foundationDate
        let grantDate = self.grantDate.foundationDate

        let dateComponents = NSCalendar.currentCalendar().components(NSCalendarUnit.Month, fromDate: grantDate, toDate: futureDate, options: NSCalendarOptions(rawValue: 0))
        return dateComponents.month
    }

    func valueBy(date: GrantDate, atPrice: Double) -> Double
    {
        return self.valueAfter(self.monthsSince(date), atPrice: atPrice)
    }

    func valuesBy(dates: [GrantDate], atPrice: Double) -> [Double]
    {
        return dates.map({ self.valueBy($0, atPrice: atPrice) })
    }

    func curriedValueBy(date: GrantDate) -> (Double) -> Double
    {
        return { price in return self.valueAfter(self.monthsSince(date), atPrice: price) }
    }

    func curriedValueAt(price: Double) -> (GrantDate) -> Double
    {
        return { date in return self.valueAfter(self.monthsSince(date), atPrice: price) }
    }
}


let signing = StockGrant.GrantDate(month: 1, day: 1, year: 2016)
let signingGrant = StockGrant(shares: 20000, grantDate: signing, cliffMonths: 12, endMonths: 48, strikePrice: 1.22)

// Two years at $22 (using months or StockGrant.GrantDate)
let twoYears = StockGrant.GrantDate(month: 1, day: 1, year: 2018)
signingGrant.valueBy(twoYears, atPrice: 22)
signingGrant.valueAfter(24, atPrice: 22)

// Strike price higher than hypothetical price
signingGrant.valueBy(twoYears, atPrice: 0.22)

// Vesting cliff not yet hit
let sixMonths = StockGrant.GrantDate(month: 6, day: 1, year: 2016)
signingGrant.valueBy(sixMonths, atPrice: 2.00)

// Vesting schedule completed
let fiveYears = StockGrant.GrantDate(month: 1, day: 1, year: 2021)
signingGrant.valueBy(fiveYears, atPrice: 2.00)

// Currying (date)
let twoYearsCurried = signingGrant.curriedValueBy(twoYears)
twoYearsCurried(11)
twoYearsCurried(22)

// Currying (price)
let twentyTwoPriceCurried = signingGrant.curriedValueAt(22)
twentyTwoPriceCurried(twoYears)
twentyTwoPriceCurried(fiveYears)
