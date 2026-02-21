//
//  ChatView.swift
//  AI Chat App
//
//  Created by Allen Asa on 16/01/2025.
//
import SwiftUI
import Foundation
import MarkdownUI

struct ChatWindow: View {
    @EnvironmentObject var selectedChat: ChatSession
    @EnvironmentObject var chatViewModel: ChatViewModel
    @State private var prompt = ""
    private var apiRequest = APIRequests()
    
    private var models = AIModel.allCases
    @State private var selectedModel = AIModel.mistral
    
    @State private var showFilePicker = false
    @State private var showURLPicker = false
    @State private var showAttachmentsSheet = false
    @State private var uploadedFiles: [UploadedFile] = []
    @State private var uploadedUrls: [String] = []
    @State private var urlToAttach: String = ""
    
    
    // adds messages to chat array
    func addMessageToChat(content: String, role: ChatRole, date: Date, model: AIModel? = nil, files: [UploadedFile]? = nil, urls: [String]? = nil) {
        // create new chat message
        let newChatMessage = ChatMessage(content: content, role: role, date: date, model: model, uploadedFiles: files, uploadedUrls: urls)
        
        // add to chat array
        self.selectedChat.messages.append(newChatMessage)
        
        self.prompt = ""
        
        // add any files to the context and clear the currently uploaded files
        self.selectedChat.chatContextFiles.append(contentsOf: uploadedFiles)
        self.uploadedFiles.removeAll()
        
        // add any urls to the context and clear the currently uploaded urls
        self.selectedChat.chatContextUrls.append(contentsOf: uploadedUrls)
        self.uploadedUrls.removeAll()
        
        // save the chat
        self.chatViewModel.saveChat(self.selectedChat)
    }
    
    // send message to model
    func sendMessage () async {
        // if there is text in the prompt
        if(!prompt.isEmpty) {
            // add the user's prompt to the chat and clear the text input
            addMessageToChat(content: prompt, role: .user, date: Date(), files: uploadedFiles, urls: uploadedUrls)
                
            // add a placeholder message for the model whilst its response is pending
            addMessageToChat(content: CONTENT_PENDING, role: .assistant, date: Date(), model: selectedModel)
            
            if(!self.selectedChat.chatContextFiles.isEmpty || !self.selectedChat.chatContextUrls.isEmpty){ // there are files to post with the prompt
                do {
                    // get the model's response to the prompt
                    let modelResponse = try await apiRequest.getModelResponseWithMedia(
                        chatMessages: self.selectedChat.messages.dropLast(1),
                        files: self.selectedChat.chatContextFiles,
                        urls: self.selectedChat.chatContextUrls,
                        model: selectedModel.rawValue
                    ) // using dropLast to get rid of "CONTENT_PENDING" placeholder message
                    
                    // update the temporary model response to be the new actual response
                    self.selectedChat.messages.removeLast()
                    addMessageToChat(content: modelResponse.data, role: .assistant, date: Date(), model: selectedModel)
                    
                    print(modelResponse.data)
                } catch{
                    // show error in chat
                    addMessageToChat(content: "Error Getting Model Response", role: .logger, date: Date())
                    print("Error getting model response")
                    print(error.localizedDescription)
                }
            }else{
                do {
                    // get the model's response to the prompt
                    let modelResponse = try await apiRequest.getModelResponse(chatMessages: self.selectedChat.messages.dropLast(1), model: selectedModel.rawValue) // using dropLast to get rid of "CONTENT_PENDING" placeholder message
                    
                    // update the temporary model response to be the new actual response
                    self.selectedChat.messages.removeLast()
                    addMessageToChat(content: modelResponse.data, role: .assistant, date: Date(), model: selectedModel)
                    
                    print(modelResponse.data)
                } catch{
                    // show error in chat
                    addMessageToChat(content: "Error Getting Model Response", role: .logger, date: Date())
                    print("Error getting model response")
                    print(error.localizedDescription)
                }
            }
            
            if(self.selectedChat.messages.count == 2){ // if this is the first interaction
                do {
                    // get a title for the chat from the model
                    let modelResponse = try await apiRequest.getChatTitle(chatMessages: self.selectedChat.messages)
                    
                    // set the title from the model's response
                    self.selectedChat.title = modelResponse.data
                    self.chatViewModel.renameChat(renameTo: modelResponse.data, chatSession: self.selectedChat)
                    NSApp.keyWindow?.title = modelResponse.data // set the window title
                } catch{
                    print("Error getting chat title")
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack {
                Picker("Selected Model", selection: $selectedModel) {
                    ForEach(models, id: \.self) { model in
                        switch model {
                            case .mistral:
                                Text("Mistral").padding()
                            case .gemma:
                                Text("Gemma 2").padding()
                            case .gemma3:
                                Text("Gemma 3").padding()
                            case .llama:
                                Text("Llama").padding()
                            case .phi4:
                                Text("Phi4").padding()
                            case .r1:
                                Text("R1-8B").padding()
                            case .r1_14b:
                                Text("R1-14B").padding()
                        }
                    }
                }.padding()
                Spacer()
            }
            
            ScrollView {
                VStack {
                    ForEach(self.selectedChat.messages, id: \.self.date) { chat in
                        ChatMessageView(chat: chat).padding(.vertical, 5)
                    }
                }.frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity).padding()
            
            HStack {
                Button(action: {
                    showAttachmentsSheet.toggle()
                }){
                    Image(systemName: "paperclip")
                        .padding()
                }.sheet(isPresented: $showAttachmentsSheet){
                    VStack(alignment: .leading){
                        Button(action: {
                            // Add file action
                            showFilePicker.toggle()
                        }) {
                            HStack{
                                Image(systemName: "doc")
                                Text("Upload File")
                            }.padding()
                        }.background(Color.newblue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .fileImporter(
                                isPresented: $showFilePicker, allowedContentTypes: ALLOWED_FILE_TYPES, allowsMultipleSelection: true, onCompletion: { result in
                                            switch result {
                                            case .success(let files):
                                                if(files.count > 0){
                                                    showAttachmentsSheet.toggle()
                                                }
                                                
                                                for fileURL in files {
                                                    // get file details
                                                    let fileType = fileURL.pathExtension
                                                    let path = fileURL.path
                                                    let name = fileURL.lastPathComponent
                                                    
                                                    // create uploaded file object
                                                    let uploadedFile = UploadedFile(filePath: path, name: name, fileType: fileType)
                                                    
                                                    // add file to uploaded files
                                                    self.uploadedFiles.append(uploadedFile)
                                                }
                                            case .failure(let error):
                                                print("Error reading file: \(error.localizedDescription)")
                                            }
                                }
                            )
                        
                        Button(action: {
                            showURLPicker.toggle()
                        }) {
                            HStack{
                                Image(systemName: "link")
                                Text("Attach URL")
                            }.padding()
                        }.background(Color.newblue)
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                            .sheet(isPresented: $showURLPicker) {
                                TextField(
                                    "Enter a url...",
                                    text: $urlToAttach
                                ).onSubmit({
                                    self.uploadedUrls.append(urlToAttach)
                                    self.urlToAttach = ""
                                    showAttachmentsSheet.toggle()
                                    showURLPicker.toggle()
                                }).padding()
                            }
                        
                        Button(action: {
                            showAttachmentsSheet.toggle()
                        }) {
                            HStack{
                                Image(systemName: "xmark.circle.fill")
                                Text("Cancel")
                            }.padding()
                        }
                            .foregroundColor(Color.white)
                            .cornerRadius(10)
                    }.padding(50)
                }.background(Color.newblue)
                    .foregroundColor(Color.white)
                    .clipShape(Circle())
                
                VStack (alignment: .leading) {
                    if(!uploadedFiles.isEmpty || !uploadedUrls.isEmpty){
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                ForEach(uploadedFiles, id: \.self){ file in
                                    HStack {
                                        Image(systemName: "document.fill")
                                        Text(file.name)
                                        Button(action: {
                                            self.uploadedFiles.remove(at: self.uploadedFiles.firstIndex(of: file)!)
                                        }){
                                            Image(systemName: "xmark.circle.fill")
                                        }.clipShape(Circle())
                                    }.padding()
                                        .foregroundColor(.white)
                                        .background(Color.green.opacity(0.8))
                                        .cornerRadius(10)
                                }
                                ForEach(uploadedUrls, id: \.self){ url in
                                    HStack {
                                        Image(systemName: "link")
                                        Text(url)
                                        Button(action: {
                                            self.uploadedUrls.remove(at: self.uploadedUrls.firstIndex(of: url)!)
                                        }){
                                            Image(systemName: "xmark.circle.fill")
                                        }.clipShape(Circle())
                                    }.padding()
                                        .foregroundColor(.white)
                                        .background(Color.green.opacity(0.8))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                    
                    TextField(
                        "Start a chat...",
                        text: $prompt
                    ).onSubmit({
                        Task{
                            await sendMessage()
                        }
                    })
                }.padding()
                    .background(Color.newblue.opacity(0.8))
                    .cornerRadius(10)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .background(Color.bg.opacity(0.9))
        }.background(Color.bg.edgesIgnoringSafeArea(.all))
    }
}
