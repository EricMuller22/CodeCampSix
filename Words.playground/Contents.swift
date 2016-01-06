// API with two parts:
// 1. Given a long input string and some word, return the number of times that word appears
// 2. Given a long input string and some number n, return the nth most frequent word in that string
// Then, if we have time, let's load gatsby.txt and use these methods on it

import Foundation


struct WordCounter
{
    var wordCounts: NSCountedSet
    var sortedWordCounts: [String]

    init(text: String)
    {
        self.wordCounts = WordCounter.wordCountsForString(text)
        self.sortedWordCounts = WordCounter.sortedWordCountsWithCounts(self.wordCounts)
    }

    func wordCountForWord(word: String) -> Int
    {
        guard let cleanWord = WordCounter.sanitizedWord(word) else { return 0 }
        return self.wordCounts.countForObject(cleanWord)
    }

    func nthMostFrequentWord(n: Int) -> String?
    {
        guard 0 < n else { return nil }
        guard n <= self.sortedWordCounts.count else { return nil }
        return self.sortedWordCounts[n - 1];
    }

    func topFilteredWords(n: Int, filter:(String)->Bool) -> Array<String> {
        let filteredWords = self.sortedWordCounts.filter({ filter($0) })
        return Array(filteredWords[0...n-1])
    }
}


extension WordCounter
{
    static func sanitizedStringComponents(text: String) -> [String]
    {
        return text .componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            .map { $0.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.punctuationCharacterSet()) }
            .filter { !$0.isEmpty }
    }

    static func sanitizedWord(word: String) -> String?
    {
        let words = sanitizedStringComponents(word)
        return words.count == 1 ? words.first : nil
    }

    static func wordCountsForString(text: String) -> NSCountedSet
    {
        return NSCountedSet.init(array: sanitizedStringComponents(text))
    }

    static func sortedWordCountsWithCounts(counts: NSCountedSet) -> [String]
    {
        guard let wordCounts = counts.allObjects as? [String] else { return [] }
        return wordCounts.sort({ (firstWord: String, secondWord: String) -> Bool in
            let firstCount = counts.countForObject(firstWord)
            let secondCount = counts.countForObject(secondWord)
            if firstCount == secondCount {
                return firstWord < secondWord
            }
            return counts.countForObject(firstWord) > counts.countForObject(secondWord)
        })
    }
}



let runGatsby = true

let testString = "Then wear the gold hat, if that will move her;\nIf you can bounce high, bounce for her too,\nTill she cry “Lover, gold-hatted, high-bouncing lover,\nI must have you!”\n- Thomas Parke D'Invilliers."
let wordCounter : WordCounter? = runGatsby ? nil : WordCounter(text: testString)

wordCounter?.wordCountForWord("Yo")
wordCounter?.wordCountForWord("")
wordCounter?.wordCountForWord("That isn't a word")
wordCounter?.wordCountForWord("lOvEr,")
wordCounter?.wordCountForWord("Gold-Hatted?")

wordCounter?.nthMostFrequentWord(0)
wordCounter?.nthMostFrequentWord(1)
wordCounter?.nthMostFrequentWord(2)
wordCounter?.nthMostFrequentWord(3)
wordCounter?.nthMostFrequentWord(4)
let largestN = wordCounter?.sortedWordCounts.count
wordCounter?.nthMostFrequentWord(largestN!)
wordCounter?.nthMostFrequentWord(largestN! + 1)

let gatsbyFile = NSBundle.mainBundle().URLForResource("gatsby", withExtension: "txt")!
let gatsbyText = try String(contentsOfURL: gatsbyFile)
let gatsbyCounter : WordCounter? = runGatsby ? WordCounter(text: gatsbyText) : nil
gatsbyCounter?.sortedWordCounts
gatsbyCounter?.wordCountForWord("Daisy")
gatsbyCounter?.nthMostFrequentWord(1)

let topWords = gatsbyCounter?.topFilteredWords(100, filter: {(word: String)->Bool in return true })
topWords

let colors = NSSet(array: ["red", "orange", "blue", "green", "yellow", "indigo", "violet", "black", "white", "gold"])
let topColors = gatsbyCounter?.topFilteredWords(7, filter: {(word: String)->Bool in
    return colors.containsObject(word)
})
