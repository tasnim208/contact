const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const connectDB = require("./config/db");

dotenv.config();

const app = express();

connectDB();

// CORS pour Windows
app.use(cors({
  origin: '*', // Autorise tout pour les tests
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));

app.use(express.json());

// Route de test
app.get("/api/test", (req, res) => {
  res.json({ 
    message: "✅ Backend fonctionne!",
    timestamp: new Date().toISOString()
  });
});

// Routes
app.use("/api/auth", require("./routes/authRoutes"));
app.use("/api/contacts", require("./routes/contactRoutes"));

// ⚠️ IMPORTANT: Écouter sur 0.0.0.0 pour Windows
const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Serveur démarré sur http://localhost:${PORT}`);
  console.log(`📍 Accessible via: http://127.0.0.1:${PORT}`);
  console.log(`📍 Et via votre IP réseau`);
});