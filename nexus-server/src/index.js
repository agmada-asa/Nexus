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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const ollama_1 = require("./ollama");
const cors = require("cors");
// create express app
const app = (0, express_1.default)();
app.use(cors());
app.use(express_1.default.json());
const PORT = 3030;
// list of valid models
const VALID_MODELS = ['mistral-nemo', 'llama3.2', 'gemma3:12b', 'gemma2:9b', 'phi4', 'deepseek-r1:8b', 'deepseek-r1:14b'];
// endpoint to get response from model
app.post('/prompt/:model', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // get model and chat from request
    const model = req.params.model;
    // get a list of all chat messages from request in order to provide contextually relevant responses
    const chatMessages = req.body.chatMessages;
    // log details of request
    console.log(`Received prompt for ${model}: ${chatMessages[chatMessages.length - 1].content}`);
    // check if model is valid
    if (!VALID_MODELS.includes(model)) {
        res.send('Invalid model'); // if not, return error message
    }
    else {
        // get response from model and send
        let response = yield (0, ollama_1.askModel)(chatMessages, model);
        res.send(response);
    }
}));
// endpoint to get response from model
app.post('/promptWithMedia/:model', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    // get model and chat from request
    const model = req.params.model;
    const files = req.body.files;
    const urls = req.body.urls;
    // get a list of all chat messages from request in order to provide contextually relevant responses
    const chatMessages = req.body.chatMessages;
    // log details of request
    console.log(`Received prompt for ${model}: ${chatMessages[chatMessages.length - 1].content}`);
    // check if model is valid
    if (!VALID_MODELS.includes(model)) {
        res.send('Invalid model'); // if not, return error message
    }
    else {
        // get response from model and send
        let response = yield (0, ollama_1.askModelWithMedia)(chatMessages, model, files, urls);
        res.send(response);
    }
}));
// endpoint to get a chat title from the model
app.post('/getChatTitle', (req, res) => __awaiter(void 0, void 0, void 0, function* () {
    const chatMessages = req.body.chatMessages;
    const chatTitle = yield (0, ollama_1.getChatTitle)(chatMessages);
    res.send(chatTitle);
}));
app.get('/', (req, res) => {
    res.send('Hello World');
});
app.listen(PORT, () => {
    console.log(`AI Chat App Server Listening On: ${PORT}`);
});
