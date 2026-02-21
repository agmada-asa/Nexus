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
exports.transcribeLocally = exports.readFile = void 0;
const pdf_parse_1 = __importDefault(require("pdf-parse"));
const fs_1 = __importDefault(require("fs"));
const child_process_1 = require("child_process");
const path_1 = __importDefault(require("path"));
var textract = require('textract');
const readFile = (filePath, fileType) => __awaiter(void 0, void 0, void 0, function* () {
    // Video/audio transcription via Whisper
    if (['mp4', 'mov', 'wav', 'mp3', 'm4a'].includes(fileType)) {
        try {
            const text = yield (0, exports.transcribeLocally)(filePath);
            // Return the transcribed text
            return text;
        }
        catch (error) {
            console.error('Error transcribing media file:', error);
            throw new Error('Error transcribing media file');
        }
    }
    else if (fileType == "pdf") {
        try {
            // Read the PDF file
            const dataBuffer = yield fs_1.default.promises.readFile(filePath);
            const pdfData = yield (0, pdf_parse_1.default)(dataBuffer);
            // Return the extracted text from the PDF
            return pdfData.text;
        }
        catch (error) {
            console.error("Error reading PDF file:", error);
            throw new Error("Error reading PDF file");
        }
    }
    else {
        return new Promise((resolve, reject) => {
            // use textract to read the file
            textract.fromFileWithPath(filePath, (error, text) => {
                if (error) {
                    // log error
                    console.error("Error reading file:", error);
                    reject("Error reading file");
                }
                else {
                    // return the text
                    resolve(text);
                }
            });
        });
    }
});
exports.readFile = readFile;
const transcribeLocally = (filePath) => {
    return new Promise((resolve, reject) => {
        const script = path_1.default.resolve(__dirname, 'whisper_transcribe.py');
        const proc = (0, child_process_1.spawn)('python3', [script, filePath]);
        let stdout = '';
        proc.stdout.on('data', (chunk) => {
            stdout += chunk.toString();
        });
        proc.stderr.on('data', (err) => {
            console.error('[whisper stderr]', err.toString());
        });
        proc.on('close', (code) => {
            if (code === 0) {
                resolve(stdout);
            }
            else {
                reject(new Error(`Whisper exited with ${code}`));
            }
        });
    });
};
exports.transcribeLocally = transcribeLocally;
