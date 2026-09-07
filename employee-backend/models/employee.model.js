const mongoose = require('mongoose');

const EmployeeSchema = new mongoose.Schema(
  {
    emp_id: {
      type: Number,
      required: true,
      unique: true,
    },
    name: {
      type: String,
      required: true,
      trim: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
      trim: true,
      lowercase: true,
    },
    password: {
      type: String,
      required: true,
    },
    department: {
      type: String,
      required: true,
      trim: true,
    },
    designation: {
      type: String,
      required: true,
      trim: true,
    },
    city: {
      type: String,
      default: null,
    },
    gender: {
      type: String,
      default: 'Male',
    },
    image: {
      type: String,
      default: "https://clipart-library.com/new_gallery/301-3016414_headshot-silhouette-png.png",
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Employee', EmployeeSchema);