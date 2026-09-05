const Employee = require('../models/employee.model');

// Registration: creates the full Employee account
const registerUser = async (req, res) => {
  try {
    const { emp_id, name, email, password, department, designation, city, gender, image } = req.body;

    if (!emp_id || !name || !email || !password || !department || !designation) {
      return res.status(400).json({ message: 'All required fields must be filled' });
    }

    const existingEmp = await Employee.findOne({
      $or: [{ email: email.toLowerCase() }, { emp_id }],
    });

    if (existingEmp) {
      return res.status(400).json({ message: 'Employee ID or Email already registered' });
    }

    const newEmployee = await Employee.create({
      emp_id,
      name,
      email: email.toLowerCase(),
      password,
      department,
      designation,
      city: city || null,
      gender: gender || 'Male',
      image: image || null,
    });

    res.status(201).json({
      message: 'Registration successful',
      employee: newEmployee,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Login: matches email/username and password
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: 'Email and password required' });
    }

    const employee = await Employee.findOne({ email: email.toLowerCase() });

    if (!employee || employee.password !== password) {
      return res.status(401).json({ message: 'Invalid Email or Password' });
    }

    res.status(200).json({
      message: 'Login successful',
      user: {
        id: employee._id,
        name: employee.name,
        email: employee.email,
        department: employee.department,
      },
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  registerUser,
  loginUser,
};