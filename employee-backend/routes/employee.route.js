const express = require("express");
const Employee = require("../models/employee.model.js");
const router = express.Router();
const {getEmployees, getEmployee, createEmployee, updateEmployee, deleteEmployee} = require('../controllers/employee.controller.js');


// Get All & Search
router.get('/',getEmployees );

//Get Sigle
router.get ("/:id", getEmployee);

//Create Employee
router.post("/", createEmployee);

//Update Employee
router.put("/:id", updateEmployee)


//delete Employee
router.delete("/:id", deleteEmployee);



module.exports = router;