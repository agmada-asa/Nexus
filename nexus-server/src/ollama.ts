import ollama, { Message } from 'ollama'
import {
  ContextChatEngine,
  Document,
  HuggingFaceEmbedding,
  Metadata,
  Ollama,
  serviceContextFromDefaults,
  Settings,
  storageContextFromDefaults,
  VectorStoreIndex,
} from "llamaindex";
import { randomUUID } from 'crypto';
import { readFile } from './filereader';
import { getWebpageContents } from './tools';


// function to chunk large text with overlap
const chunkTextWithOverlap = (text: string, maxTokens: number, overlapTokens: number) => {
  const chunks = []
  let start = 0

  while (start < text.length) {
    // define end of the chunk
    let end = Math.min(start + maxTokens, text.length)
    chunks.push(text.slice(start, end))
    // move start forward by maxTokens - overlapTokens to include overlapping content
    start += (maxTokens - overlapTokens)
  }
  return chunks;
}

// main function to handle interactions with models using ollama
export const askModel = async (chatMessages: any[], model: string) => {
  const maxTokens = 10000  // define max tokens for chunking
  const overlapTokens = 500  // define overlap between chunks

  // get the last message content
  const latestMessageContent = chatMessages[chatMessages.length - 1].content

  // xhunk the content of the latest message (if it's too large)
  const chunks = chunkTextWithOverlap(latestMessageContent, maxTokens, overlapTokens)

  // initialise response array
  let responses = []

  // process each chunk separately
  for (const chunk of chunks) {
    // replace the content of the last message with the current chunk
    const updatedChatMessages = [...chatMessages]
    updatedChatMessages[updatedChatMessages.length - 1].content = chunk

    // get response from the model for each chunk
    const response = await ollama.chat({
      model: model,
      messages: updatedChatMessages,
    })

    responses.push(response.message.content)
  }

  // combine responses from all chunks
  const fullResponse = responses.join(' ')

  return { data: fullResponse }
}

type UploadedFile = {
  name: string,
  filePath: string,
  fileType: string,
}

type UploadedUrl = {
  url: string,
}


Settings.embedModel = new HuggingFaceEmbedding({
  modelType: "BAAI/bge-small-en-v1.5",
})

// hanlde interactions with models using ollama and files
export const askModelWithMedia = async (chatMessages: any[], model: string, files: UploadedFile[], urls: UploadedUrl[]) => {
  // get the last message content
  const latestMessageContent = chatMessages[chatMessages.length - 1].content

  Settings.llm = new Ollama({
    model: model,
  })

  const documents: Document<Metadata>[] = []

  // read all files and create documents for the the vector store
  await Promise.all(files.map(async (file) => {
    if (["png", "jpg", "jpeg", "svg"].includes(file.fileType)) {
      // if its an image use OCR to read the text
      const ocrText = await readFile(file.filePath, file.fileType)

      // get a description of the image using the model
      const response = await ollama.chat({
        model: 'llava-llama3',
        messages: [{ role: 'user', content: `Describe this image in detail`, images: [file.filePath] }],
      })

      const documentContent = `TEXT IN IMAGE: ${ocrText} \n DESCRIPTION OF IMAGE: ${response.message.content}`
      const document = new Document({ text: documentContent, id_: randomUUID() })
      documents.push(document)
    } else { // else use the utility function to read the file
      const documentContent = await readFile(file.filePath, file.fileType)
      const document = new Document({ text: `DOCUMENT TITLE: ${file.name}\nDOCUMENT CONTENT: ${documentContent}`, id_: randomUUID() })
      documents.push(document)
    }
  }))

  // read the content of all the web pages
  await Promise.all(urls.map(async (url) => {
    const webpageContent = await getWebpageContents({ url: url.url })
    const document = new Document({ text: `CONTENTS OF ${url.url}\n${webpageContent}`, id_: randomUUID() })
    documents.push(document)
  }))

  // store documents in a persistent VectorStoreIndex
  const PERSIST_DIR = `./storage/${model}`
  const storageContext = await storageContextFromDefaults({ persistDir: PERSIST_DIR })
  const index = await VectorStoreIndex.init({ storageContext })

  if (documents.length > 0) {
    await index.insertNodes(documents)
  }

  // create a chat engine from the provided context
  const retriever = index.asRetriever();
  const chatEngine = new ContextChatEngine({ retriever, chatHistory: chatMessages });

  // start chatting
  const stream = await chatEngine.chat({ message: latestMessageContent, stream: true })

  let finalResponse = ""

  // add the streamed responses to the final response
  for await (const chunk of stream) {
    finalResponse += chunk.message.content
  }

  return { data: finalResponse }
}

// function to get a chat title formatted in JSON
export const getChatTitle = async (chatMessages: Message[]) => {
  let initialChat = chatMessages[0].content

  const response = await ollama.chat({
    model: "llama3.2",
    messages: [{ role: "user", content: `Make a basic title for a chat with this opening message: "${initialChat}" Respond using JSON"` }],
    format: {
      "type": "object",
      "properties": {
        "title": {
          "type": "string"
        }
      },
      "required": ["title"]
    }
  })

  return { data: JSON.parse(response.message.content).title }
}