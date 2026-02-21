//
//  Definitions.swift
//  AI Chat App
//
//  Created by Allen Asa on 16/01/2025.
//

import SwiftUI
import UniformTypeIdentifiers

let CONTENT_PENDING = "CONTENT_PENDING"

let ALLOWED_FILE_TYPES: [UTType] = [
    // JavaScript
    .init(filenameExtension: "js")!,
    
    // All text MIME types
    .plainText,   // text/plain
    .utf8PlainText, // UTF-8 text
    
    // HTML and XML
    .html,        // text/html
    .xml,         // application/xml
    
    // Markdown
    .init(filenameExtension: "md")!,  // Markdown

    // EPUB
    .init(filenameExtension: "epub")!, // EPUB

    // PDF
    .pdf,        // application/pdf
    
    // Images
    .image,

    // Video formats
    .video,      // public.video
    .movie,      // public.movie
    .init(filenameExtension: "mp4")!,  // MP4 video
    .init(filenameExtension: "mov")!,  // QuickTime movie
    .init(filenameExtension: "m4v")!,  // Apple video
    .init(filenameExtension: "avi")!,  // AVI video
    .init(filenameExtension: "mkv")!,  // Matroska video
    
    // Audio formats
    .audio,      // public.audio
    .init(filenameExtension: "mp3")!,  // MP3 audio
    .init(filenameExtension: "wav")!,  // WAV audio
    .init(filenameExtension: "m4a")!,  // M4A audio
    .init(filenameExtension: "aac")!,  // AAC audio
    .init(filenameExtension: "flac")!, // FLAC audio
    .init(filenameExtension: "ogg")!,  // OGG audio

    // Microsoft Office Documents
    .init(filenameExtension: "doc")!,  // Word DOC
    .init(filenameExtension: "docx")!, // Word DOCX
    .init(filenameExtension: "rtf")!,  // Rich Text Format
    .init(filenameExtension: "xls")!,  // Excel XLS
    .init(filenameExtension: "xlsx")!, // Excel XLSX
    .init(filenameExtension: "xlsb")!, // Excel XLSB
    .init(filenameExtension: "xlsm")!, // Excel XLSM
    .init(filenameExtension: "xltx")!, // Excel XLTX
    .init(filenameExtension: "csv")!,  // CSV

    // OpenDocument Formats
    .init(filenameExtension: "ods")!,  // OpenDocument Spreadsheet (ODS)
    .init(filenameExtension: "ots")!,  // OpenDocument Spreadsheet Template (OTS)
    .init(filenameExtension: "odp")!,  // OpenDocument Presentation (ODP)
    .init(filenameExtension: "otp")!,  // OpenDocument Presentation Template (OTP)
    .init(filenameExtension: "odg")!,  // OpenDocument Graphics (ODG)
    .init(filenameExtension: "otg")!,  // OpenDocument Graphics Template (OTG)

    // PowerPoint Presentations
    .init(filenameExtension: "pptx")!, // PowerPoint Presentation (PPTX)
    .init(filenameExtension: "potx")!, // PowerPoint Template (POTX)
    
    // RSS and ATOM
    .init(filenameExtension: "rss")!,  // RSS
    .init(filenameExtension: "atom")!  // Atom
]

struct ChatMessage: Codable{
    var content: String
    var role: ChatRole
    var date: Date
    var model: AIModel? = nil
    var uploadedFiles: [UploadedFile]? = nil
    var uploadedUrls: [String]? = nil
}

enum ChatRole: String, Codable {
    case user
    case system
    case assistant
    case logger
}

enum AIModel: String, Codable, CaseIterable {
    case mistral = "mistral-nemo"
    case llama = "llama3.2"
    case gemma = "gemma2:9b"
    case gemma3 = "gemma3:12b"
    case phi4 = "phi4"
    case r1 = "deepseek-r1:8b"
    case r1_14b = "deepseek-r1:14b"
}

struct ModelResponse: Codable {
    let data: String
}

struct APIChatMessage: Codable {
    var content: String,
        role: ChatRole
}

enum ModelResponseError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidRequestBody
}

struct UploadedFile: Codable, Hashable {
    var filePath: String
    var name: String
    var fileType: String
}

class ChatSession: Codable, Identifiable, ObservableObject {
    let id: UUID
    @Published var title: String
    @Published var messages: [ChatMessage]
    @Published var chatContextFiles: [UploadedFile]
    @Published var chatContextUrls: [String]
    let createdAt: Date
    
    init(id: UUID, title: String, messages: [ChatMessage], createdAt: Date, chatContextFiles: [UploadedFile], chatContextUrls: [String]) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.chatContextFiles = chatContextFiles
        self.chatContextUrls = chatContextUrls
    }
    
    // CodingKeys to exclude @Published from automatic encoding/decoding
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case messages
        case createdAt
        case chatContextFiles
        case chatContextUrls
    }
    
    // implementing Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        messages = try container.decode([ChatMessage].self, forKey: .messages)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        chatContextFiles = try container.decode([UploadedFile].self, forKey: .chatContextFiles)
        chatContextUrls = try container.decode([String].self, forKey: .chatContextUrls)
    }
    
    // implementing Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(messages, forKey: .messages)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(chatContextFiles, forKey: .chatContextFiles)
        try container.encode(chatContextUrls, forKey: .chatContextUrls)
    }
}

// define the types of markdown elements supported
enum MarkdownElement {
    case heading(level: Int, text: String)
    case paragraph(String)
    case codeBlock(language: String?, code: String)
    case table(header: [String], rows: [[String]])
}
