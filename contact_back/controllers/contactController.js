const Contact = require("../models/Contact");

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

// ✅ AJOUTEZ LA FONCTION DE RECHERCHE
exports.searchContacts = async (req, res) => {
  try {
    const { query } = req.query;
    
    if (!query || query.trim() === '') {
      return res.status(400).json({ message: "Le terme de recherche est requis" });
    }

    const contacts = await Contact.find({
      userId: req.user.id,
      $or: [
        { nom: { $regex: query, $options: 'i' } }, // Recherche insensible à la casse
        { numero: { $regex: query, $options: 'i' } }
      ]
    });

    res.json(contacts);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.updateContact = async (req, res) => {
  try {
    const { id } = req.params;
    const { nom, numero } = req.body;

    const contact = await Contact.findOneAndUpdate(
      { _id: id, userId: req.user.id },
      { nom, numero },
      { new: true, runValidators: true }
    );
    
    if (!contact) {
      return res.status(404).json({ message: "Contact non trouvé" });
    }
    
    res.json({ 
      message: "Contact modifié avec succès", 
      contact 
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteContact = async (req, res) => {
  try {
    const contact = await Contact.findOneAndDelete({ 
      _id: req.params.id, 
      userId: req.user.id 
    });
    
    if (!contact) {
      return res.status(404).json({ message: "Contact non trouvé" });
    }
    
    res.json({ message: "Contact supprimé" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};