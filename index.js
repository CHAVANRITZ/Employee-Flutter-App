const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const employeeRoute = require ("./routes/employee.route.js");


const app = express();
const PORT = 3000;


//middle ware
app.use(cors());
app.use(express.json());


//routes
app.use("/api/employee", employeeRoute);

app.get('/', (req, res) => {
  res.send("Bhai server ban gaya");
});



// Connection to DB
mongoose.connect('mongodb://127.0.0.1:27017/employee_db')
  .then(() => {
    console.log('Connected to local database!');
    app.listen(PORT, () => {
      console.log(`Server is running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Connection error:', err.message);
  });