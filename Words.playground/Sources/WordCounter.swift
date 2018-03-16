import Foundation


public struct WordCounter
{
    let wordCounts: NSCountedSet
    let sortedWordCounts: [String]
    public let uniqueWords: Int

    public init(text: String)
    {
        wordCounts = WordCounter.wordCounts(for: text)
        uniqueWords = wordCounts.count
        sortedWordCounts = WordCounter.sortedWordCounts(with: wordCounts)
    }

    public func wordCount(for word: String) -> Int
    {
        let cleanWord = WordCounter.sanitizedWord(word)
        guard !cleanWord.isEmpty else { return 0 }
        return wordCounts.count(for: cleanWord)
    }

    public func nthMostFrequentWord(_ n: Int) -> String
    {
        guard 0 < n else { return "" }
        guard n <= sortedWordCounts.count else { return "" }
        return sortedWordCounts[n - 1];
    }

    public func topFilteredWords(_ n: Int, filter: ((String)->Bool)? = nil) -> Array<String> {
        if let filter = filter {
            let filteredWords = sortedWordCounts.filter({ filter($0) })
            return Array(filteredWords[0...n-1])
        } else {
            return Array(sortedWordCounts[0...n-1])
        }
    }
}


extension WordCounter
{
    static func sanitizedComponents(_ text: String) -> [String]
    {
        return text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
            .map { $0.lowercased().trimmingCharacters(in: .punctuationCharacters) }
            .filter { !$0.isEmpty }
    }

    static func sanitizedWord(_ word: String) -> String
    {
        let words = sanitizedComponents(word)
        return words.count == 1 ? words.first! : ""
    }

    static func wordCounts(for text: String) -> NSCountedSet
    {
        return NSCountedSet(array: sanitizedComponents(text))
    }

    static func sortedWordCounts(with counts: NSCountedSet) -> [String]
    {
        guard let wordCounts = counts.allObjects as? [String] else { return [] }
        return wordCounts.sorted(by: { (firstWord: String, secondWord: String) -> Bool in
            let firstCount = counts.count(for: firstWord)
            let secondCount = counts.count(for: secondWord)
            if firstCount == secondCount {
                return firstWord < secondWord
            }
            return firstCount > secondCount
        })
    }
}