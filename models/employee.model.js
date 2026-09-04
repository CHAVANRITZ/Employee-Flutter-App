const mongoose = require('mongoose');

const EmployeeSchema = mongoose.Schema(
  { 
    name: {
      type: String,
      required: [true, "Enter Employee Name"],
      trim: true,
    },
    emp_id: {
      type: Number,
      required: [true, "Enter Employee ID"],
      unique: true,
    },
     department: {
      type: String,
      required: [true, "Enter Department"],
      trim: true,
    },
    designation: {
      type: String,
      required: [true, "Enter Designation"],
      trim: true,
    },
    city: {
      type: String,
      required: false,
      trim: true,
    },
    gender: {
      type: String,
      required: false,
    },
   
    image: {
      type: String,
      required: false,
      default: "https://clipart-library.com/new_gallery/301-3016414_headshot-silhouette-grey-headshot-silhouette.png",
    },
  },
  {
    timestamps: true,
  }
);

const Employee = mongoose.model("Employee", EmployeeSchema);

module.exports = Employee;