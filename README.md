# Nexus – Local AI Chat Application

Nexus is a privacy-first, local AI chat application built with a Swift native client and a Node/TypeScript backend. It features Retrieval-Augmented Generation (RAG) capabilities, allowing for the ingestion of unlimited local documents and web content into a local vector store for offline analysis.

It is designed to balance performance and privacy by running language model inference entirely locally using Ollama.

## Key Features
* **Privacy-First Local Inference:** All computation and inference run locally using Ollama, ensuring zero data leakage to external APIs.
* **Retrieval-Augmented Generation (RAG):** Built-in capability to ingest local files (PDFs, Markdown, Images, Code) and web URLs.
* **Multi-Modal Support:**
  * **Images & OCR:** Extracts text from uploaded images using OCR. If required, passes images through a vision model (e.g., `llava-llama3`) for deep description and context extraction before dropping into the vector store.
  * **Web Scraping:** Fetches content from URLs and incorporates the context into the vector store.
  * **Documents:** General document parsing and tokenization into chunks.
* **Smart UI & Markdown Output:** The Swift frontend beautifully renders Markdown tables, code blocks with syntax highlighting, and general formatted text.

## Architecture

* **Frontend:** A native macOS application written in Swift and SwiftUI. Handles user interactions, maintains conversation history, and coordinates document uploads.
* **Backend:** A Node.js and TypeScript Express server. It intercepts requests from the frontend to format them for Ollama and process files.
* **AI Engine:** [Ollama](https://ollama.com/) running various models (e.g., `llama3.2`, `mistral-nemo`, `phi4`, `deepseek-r1`).
* **Vector Data Store & RAG:** Handled by [LlamaIndex](https://ts.llamaindex.ai/), utilizing HuggingFace embeddings (`BAAI/bge-small-en-v1.5`) for semantic search and context retrieval during token generation.

## Prerequisites

Before running Nexus, ensure you have the following installed on your Mac:
1. **Node.js** (v18 or higher recommended)
2. **Xcode** (for compiling and running the Swift frontend)
3. **Ollama:** Download from [ollama.com](https://ollama.com/).

### Pulling Required Models

After installing Ollama, start the Ollama application and open your terminal to pull the necessary models. At a minimum, you will need a chat model and the vision model for image processing:

```bash
ollama run llama3.2       # General chat model
ollama run llava-llama3   # Vision model for image interpretation
```

Other supported models that you can pull to have them show up in the app:
* `mistral-nemo`
* `gemma3:12b`
* `gemma2:9b`
* `phi4`
* `deepseek-r1:8b`
* `deepseek-r1:14b`

## Setup & Running

This project is split into two parts: the server and the app. Both must be running simultaneously.

### 1. Start the Node Server

Navigate to the `nexus-server` directory, install the dependencies, and start the development server.

```bash
cd nexus-server
npm install
npm run dev
```

The server will start listening on port `3030`. Leave this terminal tab open.

### 2. Run the Swift Application

1. Open the `nexus-app/Nexus.xcodeproj` workspace in Xcode.
2. Select your target destination (My Mac).
3. Build and Run the application (`Cmd + R`).

The Nexus window will open. Ensure the Node server is running and Ollama is active in the background to start chatting and uploading documents.
