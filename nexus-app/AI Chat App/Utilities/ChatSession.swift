//
//  ChatSession.swift
//  AI Chat App
//
//  Created by Allen Asa on 16/01/2025.
//

import SwiftUI

func saveChatSession(_ chatSession: ChatSession) throws {
    // get working directory
    let directory = getChatDirectory()
    // create json path for chat to be stored
    let filePath = directory.appendingPathComponent("\(chatSession.id).json")

    // encode data to JSON
    let encoder = JSONEncoder()
    let data = try encoder.encode(chatSession)

    // write data
    try data.write(to: filePath)
}

func getAllChats() throws -> [ChatSession] {
    // get the chat directory
    let directory = getChatDirectory()
    let fileManager = FileManager.default

    // get file urls
    let fileURLs = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)

    let decoder = JSONDecoder()
    var chats: [ChatSession] = []

    // append all file urls to chat session array
    for fileURL in fileURLs {
        let data = try Data(contentsOf: fileURL)
        let chat = try decoder.decode(ChatSession.self, from: data)
        chats.append(chat)
    }

    // return chats
    return chats
}


func listAllChats(chats: [ChatSession]) {
    for (index, chat) in chats.enumerated() {
        print("\(index + 1). \(chat.title) - \(chat.createdAt)")
    }
}

func deleteChatSession(id: UUID) throws {
    let directory = getChatDirectory()
    let filePath = directory.appendingPathComponent("\(id).json")

    try FileManager.default.removeItem(at: filePath)
}

// get the current chat directory
func getChatDirectory() -> URL {
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let chatDirectory = documentsDirectory.appendingPathComponent("Nexus").appendingPathComponent("Chats")

    if !fileManager.fileExists(atPath: chatDirectory.path) {
        try? fileManager.createDirectory(at: chatDirectory, withIntermediateDirectories: true)
    }
    
    return chatDirectory
}
