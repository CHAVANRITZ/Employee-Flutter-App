const Employee = require('../models/employee.model');
const DEFAULT_AVATAR = "https://clipart-library.com/new_gallery/301-3016414_headshot-silhouette.png";

// GET ALL + SEARCH
const getEmployees = async (req, res) => {
  try {
    const { search } = req.query;
    let query = {};

    if (search) {
      const searchRegex = new RegExp(search.trim(), "i");
      query = {
        $or: [
          { name: searchRegex },
          { designation: searchRegex },
          { department: searchRegex },
        ],
      };
    }

    // Exclude password from the results
    const employees = await Employee.find(query)
      .select('-password')
      .sort({ createdAt: -1 });

    res.status(200).json(employees);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// GET SINGLE
const getEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const employee = await Employee.findById(id).select('-password');

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    res.status(200).json(employee);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// CREATE EMPLOYEE
const createEmployee = async (req, res) => {
  try {
    const payload = { ...req.body };

    // Apply DEFAULT_AVATAR if image is null, undefined, or empty string
    if (!payload.image || payload.image.trim() === '') {
      payload.image = DEFAULT_AVATAR;
    }

    if (payload.email) {
      payload.email = payload.email.trim().toLowerCase();
    }

    const employee = await Employee.create(payload);

    const responseData = employee.toObject();
    delete responseData.password;

    // Real-time broadcast notification
    if (req.io) {
      req.io.emit('employee_notification', {
        type: 'CREATED',
        title: 'New Employee Added',
        message: `${employee.name} (#${employee.emp_id}) was added to the directory.`,
        employee: responseData,
      });
    }

    res.status(201).json(responseData);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// UPDATE EMPLOYEE
const updateEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = { ...req.body };

    // Prevent blanking out the password if edit form leaves it empty
    if (!updateData.password || updateData.password.trim() === '') {
      delete updateData.password;
    }

    // Ensure fallback avatar if image is cleared
    if (updateData.image !== undefined && (!updateData.image || updateData.image.trim() === '')) {
      updateData.image = DEFAULT_AVATAR;
    }

    if (updateData.email) {
      updateData.email = updateData.email.trim().toLowerCase();
    }

    const updatedEmployee = await Employee.findByIdAndUpdate(
      id,
      updateData,
      { new: true, runValidators: true }
    ).select('-password');

    if (!updatedEmployee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    // Real-time broadcast notification
    if (req.io) {
      req.io.emit('employee_notification', {
        type: 'UPDATED',
        title: 'Employee Details Updated',
        message: `Profile details for ${updatedEmployee.name} were updated.`,
        employee: updatedEmployee,
      });
    }

    res.status(200).json(updatedEmployee);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// DELETE EMPLOYEE
const deleteEmployee = async (req, res) => {
  try {
    const { id } = req.params;
    const employee = await Employee.findByIdAndDelete(id);

    if (!employee) {
      return res.status(404).json({ message: "Employee not found" });
    }

    // Real-time broadcast notification
    if (req.io) {
      req.io.emit('employee_notification', {
        type: 'DELETED',
        title: 'Employee Removed',
        message: `${employee.name} was removed from the directory.`,
        id: employee._id,
      });
    }

    res.status(200).json({ message: "Employee deleted successfully" });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

module.exports = {
  getEmployee,
  getEmployees,
  createEmployee,
  updateEmployee,
  deleteEmployee,
};