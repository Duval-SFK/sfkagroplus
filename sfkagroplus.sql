CREATE DATABASE IF NOT EXISTS sfkagroplus
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE sfkagroplus;

CREATE TABLE users (
    u_id VARCHAR(128) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    lokation VARCHAR(100),
    photo_url TEXT,
    rule VARCHAR(30) DEFAULT 'farmer',
    password_hash VARCHAR(255),  -- Ajouté pour stocker le hash du mot de passe
    preferences JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE champs_agricoles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    type_culture VARCHAR(50) NOT NULL,
    superficie DOUBLE NOT NULL,
    localisation_champ VARCHAR(255),
    latitude DOUBLE,
    longitude DOUBLE,
    statut VARCHAR(30) DEFAULT 'actif',
    date_ajoute TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_champ_user
        FOREIGN KEY (user_id)
        REFERENCES users(uid)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE analyses_tflite (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    champ_id INT NOT NULL,
    image_url TEXT NOT NULL,
    resultat VARCHAR(150) NOT NULL,
    confiance DOUBLE CHECK (confiance >= 0 AND confiance <= 1),
    recommandations TEXT,
    tags JSON,
    date_analyse TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_analyse_user
        FOREIGN KEY (user_id)
        REFERENCES users(uid)
        ON DELETE CASCADE,

    CONSTRAINT fk_analyse_champ
        FOREIGN KEY (champ_id)
        REFERENCES champs_agricoles(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE conversations_chatbot (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(128) NOT NULL,
    sujet VARCHAR(100),
    messages JSON NOT NULL,
    feedback INT CHECK (feedback BETWEEN 1 AND 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_chat_user
        FOREIGN KEY (user_id)
        REFERENCES users(uid)
        ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE donnees_meteo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    champ_id INT NOT NULL,
    localisation VARCHAR(150),
    temperature DOUBLE,
    humidite DOUBLE,
    description VARCHAR(100),
    alertes JSON,
    date_releve TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_meteo_champ
        FOREIGN KEY (champ_id)
        REFERENCES champs_agricoles(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

