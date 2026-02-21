//
//  AI_Chat_AppApp.swift
//  AI Chat App
//
//  Created by Allen Asa on 10/01/2025.
//

import SwiftUI

@main
struct AI_Chat_AppApp: App {
    @StateObject private var chatViewModel = ChatViewModel()  // view model to manage chats
    
    var body: some Scene {
            WindowGroup {
                ChatWindow()
                    .environmentObject(chatViewModel.selectedChat ?? chatViewModel.chats.last!)
                    .environmentObject(chatViewModel)
                    .navigationTitle(chatViewModel.selectedChat?.title ?? "New Chat")
            }
            .commands {
                CommandMenu("Chats") {
                    Button(action: {
                        chatViewModel.newChat()
                    }){
                        Text("✨ Start A New Chat")
                    }
                    Divider()
                    // display all the chats
                    ForEach(chatViewModel.chats) { chat in
                        Menu(chat.title){
                            Button("Delete Chat", action: {
                                chatViewModel.deleteChat(id: chat.id)
                            })
                        } primaryAction: {
                            chatViewModel.selectChat(chat)
                        }
                        
                    }
                }
            }
        }
}
