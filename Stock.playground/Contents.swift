import Foundation


let signing = Date.grantDate(month: 1, day: 1, year: 2016)
let signingGrant = StockGrant(shares: 10000, grantDate: signing, strikePrice: 1.00)

let twoYears = signing.after(.year(2))
let fourYears = signing.after(.year(4))

// Before cliff: should be zero
signingGrant.value(at: 10, after: .month(11))

// Zero months elapsed: should be zero
signingGrant.value(at: 10, after: .month(0))

// Two years: should be 50k
signingGrant.value(at: 11, after: .month(24))
signingGrant.value(at: 11, after: .year(2))
signingGrant.value(at: 11, onDate: twoYears)

// Four years: should be 100k
signingGrant.value(at: 11, after: .month(48))
signingGrant.value(at: 11, after: .year(4))
signingGrant.value(at: 11, onDate: fourYears)

// After end date: should be equal to end date value
signingGrant.value(at: 11, after: .month(49))
signingGrant.value(at: 11, onDate: signing.after(.month(49)))
signingGrant.value(at: 11, after: .year(5))

let rsuGrant = StockGrant(shares: 10000, grantDate: twoYears)
rsuGrant.value(at: 10, after:.month(11))
rsuGrant.value(at: 10, after:.month(12))
rsuGrant.value(at: 10, after:.year(1))
rsuGrant.value(at: 10, after:.month(48))
rsuGrant.value(at: 10, after:.month(48))
rsuGrant.value(at: 10, after:.month(49))

let bonusGrant = StockGrant(shares: 10000, grantDate: fourYears, vestingSchedule: .instant)
bonusGrant.value(at: 10, after: .month(0))
bonusGrant.value(at: 20, after: .month(0))
bonusGrant.value(at: 20, after: .month(20))
