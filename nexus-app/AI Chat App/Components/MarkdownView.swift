//
//  MarkdownView.swift
//  Nexus
//
//  Created by Allen Asa on 17/02/2025.
//
import SwiftUI
import MarkdownUI

// The main SwiftUI view that renders markdown.
struct MarkdownView: View {
    let markdown: String
    
    var body: some View {
        // Parse the markdown into elements.
        let elements = parseMarkdown(markdown)
        return VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
                switch element {
                case .heading(let level, let text):
                    Text(text)
                        .font(fontForHeading(level: level))
                        .padding(.vertical, 4)
                case .paragraph(let text):
                    Markdown(text).font(.body)
                case .codeBlock(let language, let code):
                    VStack(alignment: .leading) {
                        HStack{
                            if(language != nil){
                                Text(language ?? "Code")
                            }
                            Spacer()
                            Button(action: {
                                // copy code to clipboard
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(code, forType: NSPasteboard.PasteboardType.string)
                            }) {
                                Image(systemName: "document.on.document").padding(5).imageScale(.small)
                            }.background(Color.black.opacity(0.3))
                                .foregroundColor(Color.white)
                                .cornerRadius(2)
                        }.padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity)
                        
                        HStack{
                            ScrollView(.horizontal) {
                                Text(code)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }.padding()
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .frame(maxWidth: .infinity)
                    }
                case .table(let header, let rows):
                    TableView(header: header, rows: rows)
                }
            }
        }
        .padding()
    }
}

// A helper to choose a font based on heading level.
func fontForHeading(level: Int) -> Font {
    switch level {
    case 1: return .largeTitle
    case 2: return .title
    case 3: return .title2
    case 4: return .headline
    default: return .subheadline
    }
}

// A simple table view built using VStacks and HStacks.
struct TableView: View {
    let header: [String]
    let rows: [[String]]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header row.
            HStack {
                ForEach(header, id: \.self) { cell in
                    Text(cell)
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .overlay(
                            Rectangle()
                                .frame(width: 1)
                                .foregroundColor(.gray),
                            alignment: .trailing
                        )
                }
            }
            .background(Color.gray.opacity(0.2))
            
            // Data rows.
            ForEach(rows.indices, id: \.self) { rowIndex in
                HStack {
                    ForEach(0..<header.count, id: \.self) { colIndex in
                        let cellText = colIndex < rows[rowIndex].count ? rows[rowIndex][colIndex] : ""
                        Text(cellText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .overlay(
                                Rectangle()
                                    .frame(width: 1)
                                    .foregroundColor(.gray),
                                alignment: .trailing
                            )
                    }
                }
                .background(Color.gray.opacity(0.1))
            }
        }
        .overlay(
            Rectangle()
                .stroke(Color.gray, lineWidth: 1)
        )
        .cornerRadius(4)
    }
}
