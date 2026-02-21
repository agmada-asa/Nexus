import express, { Express } from 'express'
import { askModel, askModelWithMedia, getChatTitle } from './ollama'

const cors = require("cors")

// create express app
const app: Express = express()
app.use(cors())
app.use(express.json())
const PORT = 3030

// list of valid models
const VALID_MODELS = ['mistral-nemo', 'llama3.2', 'gemma3:12b', 'gemma2:9b', 'phi4', 'deepseek-r1:8b', 'deepseek-r1:14b']

// endpoint to get response from model
app.post('/prompt/:model', async (req, res) => {
  // get model and chat from request
  const model = req.params.model

  // get a list of all chat messages from request in order to provide contextually relevant responses
  const chatMessages = req.body.chatMessages

  // log details of request
  console.log(`Received prompt for ${model}: ${chatMessages[chatMessages.length - 1].content}`)

  // check if model is valid
  if (!VALID_MODELS.includes(model)) {
    res.send('Invalid model') // if not, return error message
  } else {
    // get response from model and send
    let response = await askModel(chatMessages, model)
    res.send(response)
  }
})

// endpoint to get response from model
app.post('/promptWithMedia/:model', async (req, res) => {
  // get model and chat from request
  const model = req.params.model
  const files = req.body.files
  const urls = req.body.urls

  // get a list of all chat messages from request in order to provide contextually relevant responses
  const chatMessages = req.body.chatMessages

  // log details of request
  console.log(`Received prompt for ${model}: ${chatMessages[chatMessages.length - 1].content}`)

  // check if model is valid
  if (!VALID_MODELS.includes(model)) {
    res.send('Invalid model') // if not, return error message
  } else {
    // get response from model and send
    let response = await askModelWithMedia(chatMessages, model, files, urls)
    res.send(response)
  }
})

// endpoint to get a chat title from the model
app.post('/getChatTitle', async (req, res) => {
  const chatMessages = req.body.chatMessages

  const chatTitle = await getChatTitle(chatMessages)

  res.send(chatTitle)
})

app.get('/', (req, res) => {
  res.send('Hello World')
})

app.listen(PORT, () => {
  console.log(`AI Chat App Server Listening On: ${PORT}`)
})