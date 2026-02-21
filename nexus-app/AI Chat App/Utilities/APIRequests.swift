//
//  APIRequests.swift
//  AI Chat App
//
//  Created by Allen Asa on 10/01/2025.
//

import SwiftUI
import Foundation

class APIRequests: @unchecked Sendable {
    var modelResponse: ModelResponse? = nil
    
    // get a response from the node server running the ai models
    func getModelResponse(chatMessages: [ChatMessage], model: String = "llama3.2") async throws -> ModelResponse {
        // define the URL with the specified model or default to llama 3.2
        guard let url = URL(string: "http://localhost:3030/prompt/\(model)") else {
            throw ModelResponseError.invalidURL
        }

        // create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        request.timeoutInterval = model == AIModel.r1.rawValue || model == AIModel.r1_14b.rawValue ? 600 : 120 // increase timeout interval for responses from deepseek r1

        request.timeoutInterval = 1000000000000000000
        // set the request headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // keep user and model responses and format the chat messgaes to be sent to the server
        let formattedChatMessages: [APIChatMessage] = chatMessages.map { message in
            APIChatMessage(content: message.content, role: message.role)
        }.filter{ $0.role != .logger }

        // define the request body as the current conversation history to provide contextual responses
        let requestBody = [
            "chatMessages": formattedChatMessages
        ]

        do {
            // serialize the request body using JSONEncoder
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            throw ModelResponseError.invalidRequestBody
        }

        // use await to fetch data asynchronously
        let (data, response) = try await URLSession.shared.data(for: request)

        // check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ModelResponseError.invalidResponse
        }

        // parse the data
        let decoder = JSONDecoder()
        let modelResponse = try decoder.decode(ModelResponse.self, from: data)

        // return response
        return modelResponse
    }
    
    func getChatTitle(chatMessages: [ChatMessage], model: String = "llama3.2") async throws -> ModelResponse {
        // define the URL with the specified model or default to llama 3.2
        guard let url = URL(string: "http://localhost:3030/getChatTitle") else {
            throw ModelResponseError.invalidURL
        }

        // create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // set the request headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // keep user and model responses and format the chat messgaes to be sent to the server
        let formattedChatMessages: [APIChatMessage] = chatMessages.map { message in
            APIChatMessage(content: message.content, role: message.role)
        }.filter{ $0.role != .logger }

        // define the request body as the current conversation history to provide contextual responses
        let requestBody = [
            "chatMessages": formattedChatMessages
        ]

        do {
            // serialize the request body using JSONEncoder
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            throw ModelResponseError.invalidRequestBody
        }

        // use await to fetch data asynchronously
        let (data, response) = try await URLSession.shared.data(for: request)

        // check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ModelResponseError.invalidResponse
        }

        // parse the data
        let decoder = JSONDecoder()
        let chatTitle = try decoder.decode(ModelResponse.self, from: data)

        // return response
        return chatTitle
    }
    
    // get a response from the node server running the ai models
    func getModelResponseWithMedia(chatMessages: [ChatMessage], files: [UploadedFile], urls: [String], model: String = "llama3.2") async throws -> ModelResponse {
        // define the URL with the specified model or default to llama 3.2
        guard let url = URL(string: "http://localhost:3030/promptWithMedia/\(model)") else {
            throw ModelResponseError.invalidURL
        }

        // create the URLRequest object
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 1000000000000000000
        
        // set the request headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // keep user and model responses and format the chat messgaes to be sent to the server
        let formattedChatMessages: [APIChatMessage] = chatMessages.map { message in
            APIChatMessage(content: message.content, role: message.role)
        }.filter{ $0.role != .logger }

        // define the request body as the current conversation history to provide contextual responses
        let requestBody = [
            "chatMessages": formattedChatMessages.map { message in
                [
                    "content": message.content,
                    "role": message.role.rawValue
                ]
            },
            "files": files.map { file in
                [
                    "filePath": file.filePath,
                    "name": file.name,
                    "fileType": file.fileType
                ]
            },
            "urls": urls.map { url in
                [
                    "url" : url
                ]
            }
        ]

        do {
            // serialize the request body using JSONEncoder
            let jsonData = try JSONEncoder().encode(requestBody)
            request.httpBody = jsonData
        } catch {
            throw ModelResponseError.invalidRequestBody
        }

        // use await to fetch data asynchronously
        let (data, response) = try await URLSession.shared.data(for: request)

        // check for HTTP errors
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw ModelResponseError.invalidResponse
        }

        // parse the data
        let decoder = JSONDecoder()
        let modelResponse = try decoder.decode(ModelResponse.self, from: data)

        // return response
        return modelResponse
    }
}
