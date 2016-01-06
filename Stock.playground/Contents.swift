import Foundation


struct StockGrant
{
    struct GrantDate
    {
        private let date: NSDate

        init (month: Int, day: Int, year: Int)
        {
            let signing = NSDateComponents.init()
            signing.calendar = NSCalendar.currentCalendar()
            signing.month = month
            signing.day = day
            signing.year = year
            self.date = signing.date!
        }

        func foundationDate() -> NSDate
        {
            return self.date
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
        if months < Int(self.cliffMonths) { return 0 }
        if months > Int(self.endMonths) { return self.valueAfter(Int(self.endMonths), atPrice: atPrice) }
        if atPrice <= self.strikePrice { return 0 }

        let shareValue = atPrice - self.strikePrice
        let sharesAccrued = floor(Double(months) / Double(self.endMonths) * Double(self.shares))
        return shareValue * sharesAccrued
    }

    func monthsSince(date: GrantDate) -> Int
    {
        let futureDate = date.foundationDate()
        let grantDate = self.grantDate.foundationDate()

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

signingGrant.valueAfter(24, atPrice: 22)

let twoYears = StockGrant.GrantDate(month: 1, day: 1, year: 2018)
signingGrant.valueBy(twoYears, atPrice: 22)

let twoYearsCurried = signingGrant.curriedValueBy(twoYears)
twoYearsCurried(11)
twoYearsCurried(22)

let fourYears = StockGrant.GrantDate(month: 1, day: 1, year: 2020)
let twentyTwoPriceCurried = signingGrant.curriedValueAt(22)
twentyTwoPriceCurried(twoYears)
twentyTwoPriceCurried(fourYears)

