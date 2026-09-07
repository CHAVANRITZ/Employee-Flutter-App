const express = require('express');
const http = require('http'); 
const mongoose = require('mongoose');
const cors = require('cors');
const { Server } = require('socket.io');

const employeeRoute = require("./routes/employee.route.js");
const authRoute = require("./routes/auth.route");

const app = express();
const PORT = 3000;

// 2. Create the Node HTTP server wrapping Express
const server = http.createServer(app);

// 3. Attach Socket.IO to the HTTP server
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST', 'PUT', 'DELETE'],
  },
});

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ limit: '10mb', extended: true }));

// 4. Attach `io` to every request so controllers can emit broadcast events
app.use((req, res, next) => {
  req.io = io;
  next();
});

// WebSocket connection listeners
io.on('connection', (socket) => {
  console.log('Client connected to WebSocket:', socket.id);

  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

// Routes
app.use("/api/employee", employeeRoute);
app.use("/api/auth", authRoute);

app.get('/', (req, res) => {
  res.send("Bhai server ban gaya");
});

// Database Connection
mongoose.connect('mongodb://127.0.0.1:27017/employee_db')
  .then(() => {
    console.log('Connected to local database!');
    // 5. Use server.listen instead of app.listen
    server.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Connection error:', err.message);
  });