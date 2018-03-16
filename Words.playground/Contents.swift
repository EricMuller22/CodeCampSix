// API with two parts:
// 1. Given a long input string and some word, return the number of times that word appears
// 2. Given a long input string and some number n, return the nth most frequent word in that string
// Then, if we have time, let's load gatsby.txt and use these methods on it

import Foundation


let runGatsby = true

if (runGatsby) {
    let gatsbyFile = Bundle.main.url(forResource: "gatsby", withExtension: "txt")!
    let gatsbyText = try String(contentsOf: gatsbyFile)
    let gatsbyCounter = WordCounter(text: gatsbyText)
    gatsbyCounter.uniqueWords
    gatsbyCounter.wordCount(for: "Daisy")
    gatsbyCounter.nthMostFrequentWord(1)

    let topWords = gatsbyCounter.topFilteredWords(100)
    topWords

    let colors: Set = ["red", "orange", "blue", "green", "yellow", "indigo", "violet", "black", "white", "gold"]
    let topColors = gatsbyCounter.topFilteredWords(7, filter: {(word: String)->Bool in
        return colors.contains(word)
    })
    topColors

} else {
    let testString = "Then wear the gold hat, if that will move her;\n" +
    "If you can bounce high, bounce for her too,\n" +
    "Till she cry “Lover, gold-hatted, high-bouncing lover,\n" +
    "I must have you!”\n" +
    "\t- Thomas Parke D'Invilliers."

    let wordCounter = WordCounter(text: testString)

    wordCounter.wordCount(for: "Yo")
    wordCounter.wordCount(for: "")
    wordCounter.wordCount(for: "That isn't a word")
    wordCounter.wordCount(for: "lOvEr,")
    wordCounter.wordCount(for: "Gold-Hatted?")

    wordCounter.nthMostFrequentWord(0)
    wordCounter.nthMostFrequentWord(1)
    wordCounter.nthMostFrequentWord(2)
    wordCounter.nthMostFrequentWord(3)
    wordCounter.nthMostFrequentWord(4)
    let largestN = wordCounter.uniqueWords
    wordCounter.nthMostFrequentWord(largestN)
    wordCounter.nthMostFrequentWord(largestN + 1)
}
