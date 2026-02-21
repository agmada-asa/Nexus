import pdfParse from 'pdf-parse'
import fs from 'fs'
import { spawn } from 'child_process';
import path from 'path';

var textract = require('textract')

export const readFile = async (filePath: string, fileType: string): Promise<string> => {
   // Video/audio transcription via Whisper
  if (['mp4', 'mov', 'wav', 'mp3', 'm4a'].includes(fileType)) {
    try {
      const text = await transcribeLocally(filePath)

      // Return the transcribed text
      return text
    } catch (error) {
      console.error('Error transcribing media file:', error)
      throw new Error('Error transcribing media file')
    }
  } else if (fileType == "pdf") {
    try {
      // Read the PDF file
      const dataBuffer = await fs.promises.readFile(filePath)
      const pdfData = await pdfParse(dataBuffer)

      // Return the extracted text from the PDF
      return pdfData.text
    } catch (error) {
      console.error("Error reading PDF file:", error);
      throw new Error("Error reading PDF file");
    }
  } else {
    return new Promise((resolve, reject) => {
      // use textract to read the file
      textract.fromFileWithPath(filePath, (error: any, text: any) => {
        if (error) {
          // log error
          console.error("Error reading file:", error)
          reject("Error reading file")
        } else {
          // return the text
          resolve(text)
        }
      })
    })
  }
}

export const transcribeLocally = (filePath: string): Promise<string> => {
  return new Promise((resolve, reject) => {
    const script = path.resolve(__dirname, 'whisper_transcribe.py');
    const proc = spawn('python3', [script, filePath]);

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
      } else {
        reject(new Error(`Whisper exited with ${code}`));
      }
    });
  });
};