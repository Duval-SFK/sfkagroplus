const express = require('express');
const mysql = require('mysql2/promise');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = process.env.PORT || 3000;

// Pont entre le système opérant et la base de données
app.use(cors());
app.use(bodyParser.json());

// Connection à la base données
const dbConfig = {
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'sfkagroplus'
};

let db;

async function connectDB() {
  try {
    db = await mysql.createConnection(dbConfig);
    console.log('Connecté à la base de donnée sfkagroplus');
  } catch (error) {
    console.error('Echec de connection à la base de données:', error);
  }
}

connectDB();

// Routes

// Inscription de l'utilisateur
app.post('/register', async (req, res) => {
  const { name, email, password, culture, surface, location } = req.body;

  try {
    // Vérifie si l'utilisateur existe
    const [existingUser] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUser.length > 0) {
      return res.status(400).json({ error: 'User already exists' });
    }

    // Hashage du mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insertion de l'utilisateur
    const uid = Date.now().toString(); // Génération d'un simple UID
    await db.execute(
      'INSERT INTO users (uid, name, email, password_hash, location) VALUES (?, ?, ?, ?, ?)',
      [uid, name, email, hashedPassword, location]
    );

    // Insertion du champs agricole
    await db.execute(
      'INSERT INTO champs_agricoles (user_id, type_culture, superficie, localisation_champ) VALUES (?, ?, ?, ?)',
      [uid, culture, parseFloat(surface), location]
    );

    // Génération de JWT
    const token = jwt.sign({ uid, email }, 'your-secret-key', { expiresIn: '1h' });

    res.status(200).json({ token, user: { uid, name, email, location } });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Registration failed' });
  }
});

// Connexion de l'utilisateur
app.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    const isValidPassword = await bcrypt.compare(password, user.password_hash);
    if (!isValidPassword) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    // Generate JWT
    const token = jwt.sign({ uid: user.uid, email: user.email }, 'your-secret-key', { expiresIn: '1h' });

    res.status(200).json({ token, user: { uid: user.uid, name: user.name, email: user.email, location: user.location } });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Récupère le profile de l'utilisateur
app.get('/user/:uid', async (req, res) => {
  const { uid } = req.params;

  try {
    const [users] = await db.execute('SELECT uid, name, email, location FROM users WHERE uid = ?', [uid]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(users[0]);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Utilisateur introuvable' });
  }
});

// Récupération du champs de l'utilisateur
app.get('/user/:uid/fields', async (req, res) => {
  const { uid } = req.params;

  try {
    const [fields] = await db.execute('SELECT * FROM champs_agricoles WHERE user_id = ?', [uid]);
    res.json(fields);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Champ introuvalbe' });
  }
});

// Récupération de l'analyse faite pour l'utilisateur
app.get('/user/:uid/analyses', async (req, res) => {
  const { uid } = req.params;

  try {
    const [analyses] = await db.execute('SELECT * FROM analyses_tflite WHERE user_id = ?', [uid]);
    res.json(analyses);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Failed to fetch analyses' });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});