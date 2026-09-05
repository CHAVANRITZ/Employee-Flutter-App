const Employee = require('../models/employee.model');

// Registration: Creates full Employee account
const registerUser = async (req, res) => {
  try {
    const { emp_id, name, email, password, department, designation, city, gender, image } = req.body;

    // Validate mandatory fields
    if (!emp_id || !name || !email || !password || !department || !designation) {
      return res.status(400).json({ message: 'All required fields must be filled' });
    }

    const cleanEmail = email.trim().toLowerCase();
    const cleanEmpId = Number(emp_id);

    if (isNaN(cleanEmpId)) {
      return res.status(400).json({ message: 'Employee ID must be a valid number' });
    }

    // Check for existing duplicate records
    const existingEmp = await Employee.findOne({
      $or: [{ email: cleanEmail }, { emp_id: cleanEmpId }],
    });

    if (existingEmp) {
      const duplicateField = existingEmp.emp_id === cleanEmpId ? 'Employee ID' : 'Email';
      return res.status(400).json({ message: `${duplicateField} is already registered` });
    }

    // Create new employee
    const newEmployee = await Employee.create({
      emp_id: cleanEmpId,
      name: name.trim(),
      email: cleanEmail,
      password: password.trim(),
      department: department.trim(),
      designation: designation.trim(),
      city: city ? city.trim() : null,
      gender: gender || 'Male',
      image: image || null,
    });

    // Strip password before returning JSON response
    const responseData = newEmployee.toObject();
    delete responseData.password;

    res.status(201).json({
      message: 'Registration successful',
      employee: responseData,
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Login: Supports logging in via Email or Employee ID
const loginUser = async (req, res) => {
  try {
    const { email, username, password } = req.body;
    const identifier = (email || username || '').trim();

    if (!identifier || !password) {
      return res.status(400).json({ message: 'Email/Employee ID and password are required' });
    }

    // Search by email or numerical emp_id if digits are provided
    const queryConditions = [{ email: identifier.toLowerCase() }];
    if (!isNaN(Number(identifier)) && identifier !== '') {
      queryConditions.push({ emp_id: Number(identifier) });
    }

    const employee = await Employee.findOne({ $or: queryConditions });

    if (!employee || employee.password !== password.trim()) {
      return res.status(401).json({ message: 'Invalid credentials' });
    }

    res.status(200).json({
      message: 'Login successful',
      user: {
        id: employee._id,
        emp_id: employee.emp_id,
        name: employee.name,
        email: employee.email,
        department: employee.department,
        designation: employee.designation,
        image: employee.image,
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