import Foundation


public class WordCounter
{
    // MARK: - Public Variables

    public lazy var uniqueWords: Int = {
        return wordCounts.count
    }()

    // MARK: - Internal Variables

    let text: String

    lazy var wordCounts: NSCountedSet = {
        return WordCounter.wordCounts(for: text)
    }()

    lazy var sortedWordCounts: [String] = {
        return WordCounter.sortedWordCounts(with: wordCounts)
    }()

    // MARK: - Lifecycle

    public init(text: String)
    {
        self.text = text
    }

    // MARK: - Public Methods

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

// MARK: - Static Helpers

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
