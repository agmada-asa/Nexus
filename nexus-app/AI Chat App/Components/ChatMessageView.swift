//
//  ChatMessageView.swift
//  AI Chat App
//
//  Created by Allen Asa on 08/02/2025.
//
import SwiftUI
import MarkdownUI

struct ChatMessageView: View {
        var chat: ChatMessage
        
        var body: some View {
            HStack (alignment: .top) {
                if chat.role == .assistant {
                    VStack{
                        Image(
                            systemName: "sparkles"
                        ).foregroundColor(Color.newblue).imageScale(.medium)
                        switch chat.model {
                            case .mistral:
                                Text("Mistral").font(.caption)
                            case .gemma:
                                Text("Gemma 2").font(.caption)
                            case .gemma3:
                                Text("Gemma 3").font(.caption)
                            case .llama:
                                Text("Llama").font(.caption)
                            case .phi4:
                                Text("Phi4").font(.caption)
                            case .r1:
                                Text("R1-8B").font(.caption)
                            case .r1_14b:
                                Text("R1-14B").font(.caption)
                            case .none:
                                Text("").font(.caption)
                        }
                    }.padding()
                    // if model response display as a markdown text ui
                    if chat.content != CONTENT_PENDING {
                        VStack(alignment: .leading){
                            MarkdownView(markdown: chat.content)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.botblue)
                                .cornerRadius(10)
                                .frame(maxWidth: 900, alignment: .leading)
                                .textSelection(.enabled)
                            Button(action: {
                                // copy response to clipboard
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(chat.content, forType: NSPasteboard.PasteboardType.string)
                            }) {
                                Image(systemName: "document.on.document").padding(5)
                            }.background(Color.botblue)
                                .foregroundColor(Color.white)
                                .cornerRadius(5)
                                .clipShape(Rectangle())
                        }
                    } else {
                        ProgressView().scaleEffect(0.5)
                    }
                    Spacer()
                } else if(chat.role == .logger){
                    VStack{
                        Image(
                            systemName: "exclamationmark.circle.fill"
                        ).foregroundColor(Color.red).imageScale(.medium)
                        switch chat.model {
                            case .mistral:
                                Text("Mistral").font(.caption)
                            case .gemma:
                                Text("Gemma 2").font(.caption)
                            case .gemma3:
                                Text("Gemma 3").font(.caption)
                            case .llama:
                                Text("Llama").font(.caption)
                            case .phi4:
                                Text("Phi4").font(.caption)
                            case .r1:
                                Text("R1-8B").font(.caption)
                            case .r1_14b:
                                Text("R1-14B").font(.caption)
                        case .none:
                            Text("").font(.caption)
                        }
                    }.padding()
                    // if model response display as a markdown text ui
                    VStack(alignment: .leading){
                        Text(chat.content)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(10)
                            .frame(maxWidth: 900, alignment: .leading)
                            .textSelection(.enabled)
                    }
                    Spacer()
                } else {
                    Spacer()
                    VStack (alignment: .trailing) {
                        Text(chat.content)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .frame(maxWidth: 900, alignment: .trailing)
                            .textSelection(.enabled)
                        
                        if(chat.uploadedFiles != nil || chat.uploadedUrls != nil){
                            HStack{
                                ForEach(chat.uploadedFiles!, id: \.self){ file in
                                    HStack {
                                        Image(systemName: "document.fill")
                                        Text(file.name)
                                    }.padding()
                                        .foregroundColor(.white)
                                        .background(Color.gray)
                                        .opacity(0.8)
                                        .cornerRadius(10)
                                }
                                ForEach(chat.uploadedUrls!, id: \.self){ url in
                                    HStack {
                                        Image(systemName: "link")
                                        Text(url.count > 30 ? String(url.prefix(30)) + "..." : url)
                                    }.padding()
                                        .foregroundColor(.white)
                                        .background(Color.gray)
                                        .opacity(0.8)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        Button(action: {
                            // copy response to clipboard
                            NSPasteboard.general.clearContents()
                            NSPasteboard.general.setString(chat.content, forType: NSPasteboard.PasteboardType.string)
                        }) {
                            Image(systemName: "document.on.document").padding(5)
                        }.background(Color.botblue)
                            .foregroundColor(Color.white)
                            .cornerRadius(5)
                            .clipShape(Rectangle())
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    }
                    Image(
                        systemName: "person.fill"
                    ).foregroundColor(Color.newblue).imageScale(.medium).padding()
                }
            }
        }
    }
