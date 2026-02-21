"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __asyncValues = (this && this.__asyncValues) || function (o) {
    if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
    var m = o[Symbol.asyncIterator], i;
    return m ? m.call(o) : (o = typeof __values === "function" ? __values(o) : o[Symbol.iterator](), i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function () { return this; }, i);
    function verb(n) { i[n] = o[n] && function (v) { return new Promise(function (resolve, reject) { v = o[n](v), settle(resolve, reject, v.done, v.value); }); }; }
    function settle(resolve, reject, d, v) { Promise.resolve(v).then(function(v) { resolve({ value: v, done: d }); }, reject); }
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.getChatTitle = exports.askModelWithMedia = exports.askModel = void 0;
const ollama_1 = __importDefault(require("ollama"));
const llamaindex_1 = require("llamaindex");
const crypto_1 = require("crypto");
const filereader_1 = require("./filereader");
const tools_1 = require("./tools");
// function to chunk large text with overlap
const chunkTextWithOverlap = (text, maxTokens, overlapTokens) => {
    const chunks = [];
    let start = 0;
    while (start < text.length) {
        // define end of the chunk
        let end = Math.min(start + maxTokens, text.length);
        chunks.push(text.slice(start, end));
        // move start forward by maxTokens - overlapTokens to include overlapping content
        start += (maxTokens - overlapTokens);
    }
    return chunks;
};
// main function to handle interactions with models using ollama
const askModel = (chatMessages, model) => __awaiter(void 0, void 0, void 0, function* () {
    const maxTokens = 10000; // define max tokens for chunking
    const overlapTokens = 500; // define overlap between chunks
    // get the last message content
    const latestMessageContent = chatMessages[chatMessages.length - 1].content;
    // xhunk the content of the latest message (if it's too large)
    const chunks = chunkTextWithOverlap(latestMessageContent, maxTokens, overlapTokens);
    // initialise response array
    let responses = [];
    // process each chunk separately
    for (const chunk of chunks) {
        // replace the content of the last message with the current chunk
        const updatedChatMessages = [...chatMessages];
        updatedChatMessages[updatedChatMessages.length - 1].content = chunk;
        // get response from the model for each chunk
        const response = yield ollama_1.default.chat({
            model: model,
            messages: updatedChatMessages,
        });
        responses.push(response.message.content);
    }
    // combine responses from all chunks
    const fullResponse = responses.join(' ');
    return { data: fullResponse };
});
exports.askModel = askModel;
llamaindex_1.Settings.embedModel = new llamaindex_1.HuggingFaceEmbedding({
    modelType: "BAAI/bge-small-en-v1.5",
});
// hanlde interactions with models using ollama and files
const askModelWithMedia = (chatMessages, model, files, urls) => __awaiter(void 0, void 0, void 0, function* () {
    var _a, e_1, _b, _c;
    // get the last message content
    const latestMessageContent = chatMessages[chatMessages.length - 1].content;
    llamaindex_1.Settings.llm = new llamaindex_1.Ollama({
        model: model,
    });
    const documents = [];
    // read all files and create documents for the the vector store
    yield Promise.all(files.map((file) => __awaiter(void 0, void 0, void 0, function* () {
        if (["png", "jpg", "jpeg", "svg"].includes(file.fileType)) {
            // if its an image use OCR to read the text
            const ocrText = yield (0, filereader_1.readFile)(file.filePath, file.fileType);
            // get a description of the image using the model
            const response = yield ollama_1.default.chat({
                model: 'llava-llama3',
                messages: [{ role: 'user', content: `Describe this image in detail`, images: [file.filePath] }],
            });
            const documentContent = `TEXT IN IMAGE: ${ocrText} \n DESCRIPTION OF IMAGE: ${response.message.content}`;
            const document = new llamaindex_1.Document({ text: documentContent, id_: (0, crypto_1.randomUUID)() });
            documents.push(document);
        }
        else { // else use the utility function to read the file
            const documentContent = yield (0, filereader_1.readFile)(file.filePath, file.fileType);
            const document = new llamaindex_1.Document({ text: `DOCUMENT TITLE: ${file.name}\nDOCUMENT CONTENT: ${documentContent}`, id_: (0, crypto_1.randomUUID)() });
            documents.push(document);
        }
    })));
    // read the content of all the web pages
    yield Promise.all(urls.map((url) => __awaiter(void 0, void 0, void 0, function* () {
        const webpageContent = yield (0, tools_1.getWebpageContents)({ url: url.url });
        const document = new llamaindex_1.Document({ text: `CONTENTS OF ${url.url}\n${webpageContent}`, id_: (0, crypto_1.randomUUID)() });
        documents.push(document);
    })));
    // store documents in a persistent VectorStoreIndex
    const PERSIST_DIR = `./storage/${model}`;
    const storageContext = yield (0, llamaindex_1.storageContextFromDefaults)({ persistDir: PERSIST_DIR });
    const index = yield llamaindex_1.VectorStoreIndex.init({ storageContext });
    if (documents.length > 0) {
        yield index.insertNodes(documents);
    }
    // create a chat engine from the provided context
    const retriever = index.asRetriever();
    const chatEngine = new llamaindex_1.ContextChatEngine({ retriever, chatHistory: chatMessages });
    // start chatting
    const stream = yield chatEngine.chat({ message: latestMessageContent, stream: true });
    let finalResponse = "";
    try {
        // add the streamed responses to the final response
        for (var _d = true, stream_1 = __asyncValues(stream), stream_1_1; stream_1_1 = yield stream_1.next(), _a = stream_1_1.done, !_a; _d = true) {
            _c = stream_1_1.value;
            _d = false;
            const chunk = _c;
            finalResponse += chunk.message.content;
        }
    }
    catch (e_1_1) { e_1 = { error: e_1_1 }; }
    finally {
        try {
            if (!_d && !_a && (_b = stream_1.return)) yield _b.call(stream_1);
        }
        finally { if (e_1) throw e_1.error; }
    }
    return { data: finalResponse };
});
exports.askModelWithMedia = askModelWithMedia;
// function to get a chat title formatted in JSON
const getChatTitle = (chatMessages) => __awaiter(void 0, void 0, void 0, function* () {
    let initialChat = chatMessages[0].content;
    const response = yield ollama_1.default.chat({
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
    });
    return { data: JSON.parse(response.message.content).title };
});
exports.getChatTitle = getChatTitle;
