const mongoose = require("mongoose");

const medicineSchema = mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  expiryDate: {
    type: Date,
    required: true
  },
  quantity: {
    type: Number,
    required: true
  },
  timings: [{
    type: String,
    required: true
  }]
});

const Medicine = mongoose.model("Medicine", medicineSchema);
module.exports = Medicine;