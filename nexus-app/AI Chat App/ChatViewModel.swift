//
//  ChatViewModel.swift
//  AI Chat App
//
//  Created by Allen Asa on 16/01/2025.
//

import SwiftUI

class ChatViewModel: ObservableObject {
    @Published var chats: [ChatSession] = []
    @Published var selectedChat: ChatSession? = nil
    
    init() {
        loadChats()
    }
    
    // load chats
    func loadChats() {
        do {
            // get all chats and have most recent at the top
            self.chats = try getAllChats().sorted { $0.createdAt > $1.createdAt }
            self.selectedChat = ChatSession(
                id: UUID(),
                title: "New Chat",
                messages: [],
                createdAt: Date(),
                chatContextFiles: [],
                chatContextUrls: []
            )
        } catch {
            print("Error loading chats")
            print(error.localizedDescription)
        }
    }
    
    func deleteChat(id: UUID){
        do{
            try deleteChatSession(id: id)
            self.chats = try getAllChats().sorted { $0.createdAt > $1.createdAt }
        } catch {
            print("Error deleting chats")
            print(error.localizedDescription)
        }
    }
    
    // open chat in new window
    func selectChat(_ chat: ChatSession) {
        self.selectedChat = chat
        print("Selected chat: \(chat.title)")
    }
    
    // function to create a new chat
    func newChat() {
        let newChat = ChatSession(id: UUID(), title: "New Chat", messages: [], createdAt: Date(), chatContextFiles: [], chatContextUrls: []) // create the new chat with the defaults
        self.selectedChat = newChat // set the current chat to the new chat
        
        // add the chat to the chats array and sor
        chats.append(newChat)
        self.chats = chats.sorted { $0.createdAt > $1.createdAt }
    }
    
    // save an already existing chat
    func saveChat(_ chat: ChatSession){
        // find the index of the chat
        let changeIndex = self.chats.firstIndex(where: { $0.id == chat.id })
        if(changeIndex != nil){
            self.chats[changeIndex!] = chat // save the chat in the model
        }else{
            self.chats.append(chat)
        }
        
        self.chats = chats.sorted { $0.createdAt > $1.createdAt } // sort chats
        
        do{
            try saveChatSession(chat) // save chat session locally
        }catch{
            print("Error saving new chat")
        }
    }
    
    // rename an existing chat
    func renameChat(renameTo: String, chatSession: ChatSession){
        do{
            let newChatSession = chatSession
            newChatSession.title = renameTo // rename the chat session
            
            self.chats.filter { $0.id == newChatSession.id }.forEach {
                $0.title = newChatSession.title // change the title in the chat view model
            }
            
            try saveChatSession(newChatSession) // save the chat session locally
        }catch{
            print("Error renaming chat")
        }
    }
}
