//
//  MarkdownToComponents.swift
//  Nexus
//
//  Created by Allen Asa on 17/02/2025.
//

import SwiftUI

// A simple parser that splits the markdown string into elements.
func parseMarkdown(_ markdown: String) -> [MarkdownElement] {
    var elements: [MarkdownElement] = []
    let lines = markdown.components(separatedBy: "\n")
    var index = 0
    var currentParagraphLines: [String] = []
    
    // Helper to flush accumulated paragraph lines.
    func flushParagraph() {
        if !currentParagraphLines.isEmpty {
            let paragraph = currentParagraphLines.joined(separator: " ")
            elements.append(.paragraph(paragraph))
            currentParagraphLines.removeAll()
        }
    }
    
    while index < lines.count {
        let line = lines[index]
        
        // --- Code Block ---
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("```") {
            flushParagraph()
            let codeLangLine = line.trimmingCharacters(in: .whitespaces)
            var language: String? = nil
            if codeLangLine.count > 3 {
                language = String(codeLangLine.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                if language == "" { language = nil }
            }
            index += 1
            var codeLines: [String] = []
            while index < lines.count && !lines[index].trimmingCharacters(in: .whitespaces).hasPrefix("```") {
                codeLines.append(lines[index])
                index += 1
            }
            index += 1  // Skip the closing ```
            let code = codeLines.joined(separator: "\n")
            elements.append(.codeBlock(language: language, code: code))
            continue
        }
        
        // --- Heading ---
        if line.trimmingCharacters(in: .whitespaces).hasPrefix("#") {
            flushParagraph()
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            var level = 0
            var textStartIndex = trimmed.startIndex
            for char in trimmed {
                if char == "#" {
                    level += 1
                    textStartIndex = trimmed.index(after: textStartIndex)
                } else {
                    break
                }
            }
            let text = trimmed[textStartIndex...].trimmingCharacters(in: .whitespaces)
            elements.append(.heading(level: level, text: text))
            index += 1
            continue
        }
        
        // --- Table ---
        if line.contains("|") {
            // Look ahead to see if the next line is a table separator (only dashes, colons, pipes, and spaces)
            if index + 1 < lines.count {
                let nextLine = lines[index + 1]
                let allowedSet = CharacterSet(charactersIn: "|-: ").inverted
                if nextLine.rangeOfCharacter(from: allowedSet) == nil && nextLine.contains("-") {
                    flushParagraph()
                    // Parse header row.
                    let header = line
                        .split(separator: "|")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    index += 2  // Skip header and separator
                    
                    var rows: [[String]] = []
                    while index < lines.count && lines[index].contains("|") {
                        let row = lines[index]
                            .split(separator: "|")
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .filter { !$0.isEmpty }
                        if !row.isEmpty {
                            rows.append(row)
                        }
                        index += 1
                    }
                    elements.append(.table(header: header, rows: rows))
                    continue
                }
            }
        }
        
        // --- Paragraph ---
        if line.trimmingCharacters(in: .whitespaces).isEmpty {
            flushParagraph()
        } else {
            currentParagraphLines.append(line)
        }
        index += 1
    }
    flushParagraph()
    return elements
}
