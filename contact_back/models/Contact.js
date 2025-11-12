const mongoose = require("mongoose");

const contactSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  nom: { type: String, required: true },
  numero: { type: String, required: true },
});

module.exports = mongoose.model("Contact", contactSchema);
