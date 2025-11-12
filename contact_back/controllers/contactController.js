const Contact = require("../models/Contact"); // ✅ chemin correct

exports.addContact = async (req, res) => {
  try {
    const contact = new Contact({ ...req.body, userId: req.user.id });
    await contact.save();
    res.status(201).json(contact);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getContacts = async (req, res) => {
  try {
    const contacts = await Contact.find({ userId: req.user.id });
    res.json(contacts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteContact = async (req, res) => {
  try {
    await Contact.findByIdAndDelete(req.params.id);
    res.json({ message: "Contact supprimé" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
