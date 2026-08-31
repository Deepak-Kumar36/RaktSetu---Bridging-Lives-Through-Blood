-- ================================================================
--  RaktSetu — Blood Bank Management System
--  Complete Database Schema  |  All 10 Tables  (v2)
--  NEW in v2:
--    ✅ TABLE 10: blood_components (lookup table)
--    ✅ component ENUM replaced with component_id FK in:
--       blood_requests, blood_stock, blood_inventory
--    ✅ age VARCHAR(3) → TINYINT UNSIGNED in patients & donors
--    ✅ is_read TINYINT(1) → BOOLEAN in notifications
-- ================================================================

DROP DATABASE IF EXISTS raktsetu;
CREATE DATABASE raktsetu CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE raktsetu;


-- ================================================================
-- TABLE 1 : users  🔴 Heavy
-- ================================================================
CREATE TABLE users (
    user_id     INT          AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    email       VARCHAR(40)  NOT NULL UNIQUE,
    password    VARCHAR(255) NOT NULL,
    phone       VARCHAR(15),
    role        ENUM('Donor','Patient','Admin') NOT NULL,
    is_verified ENUM('Pending','Rejected','Accepted') DEFAULT 'Pending',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ================================================================
-- TABLE 2 : patients  🟡 Medium
-- ================================================================
CREATE TABLE patients (
    patient_id         INT              AUTO_INCREMENT PRIMARY KEY,
    user_id            INT              NOT NULL,
    blood_group_needed ENUM('A+','A-','AB+','AB-','B+','B-','O+','O-'),
    age                TINYINT UNSIGNED,
    city               VARCHAR(50),
    state              VARCHAR(40),
    address            TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- ================================================================
-- TABLE 3 : donors  🟡 Medium
-- ================================================================
CREATE TABLE donors (
    donor_id           INT              AUTO_INCREMENT PRIMARY KEY,
    user_id            INT              NOT NULL,
    blood_group        ENUM('A+','A-','AB+','AB-','B+','B-','O+','O-') NOT NULL,
    age                TINYINT UNSIGNED,
    city               VARCHAR(50),
    state              VARCHAR(40),
    address            TEXT,
    is_available       ENUM('Yes','No') DEFAULT 'Yes',
    last_donation_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- ================================================================
-- TABLE 10 : blood_components  🟢 Light  ← NEW TABLE
-- Lookup table for all blood component types.
-- Add new components with a simple INSERT — no ALTER TABLE needed.
-- ================================================================
CREATE TABLE blood_components (
    component_id   INT          AUTO_INCREMENT PRIMARY KEY,
    component_name VARCHAR(100) NOT NULL UNIQUE,
    description    TEXT,
    created_at     TIMESTAMP    DEFAULT CURRENT_TIMESTAMP
);

-- Pre-fill all known components (from your images)
INSERT INTO blood_components (component_name) VALUES
('Cryo Poor Plasma'),
('Cryoprecipitate'),
('Fresh Frozen Plasma'),
('Irradiated RBC'),
('Leukoreduced RBC'),
('Packed Red Blood Cells'),
('Plasma'),
('Platelet Concentrate'),
('Platelet Rich Plasma'),
('Random Donor Platelets'),
('SAGM Packed Red Blood Cells'),
('Single Donor Plasma'),
('Single Donor Platelet'),
('Whole Blood');


-- ================================================================
-- TABLE 4 : blood_requests  🔴 Heavy
-- component ENUM replaced with component_id FK
-- ================================================================
CREATE TABLE blood_requests (
    request_id       INT  AUTO_INCREMENT PRIMARY KEY,
    patient_id       INT  NOT NULL,
    blood_group      ENUM('A+','A-','AB+','AB-','B+','B-','O+','O-') NOT NULL,
    component_id     INT  NOT NULL,
    units_needed     INT  NOT NULL,
    urgency          ENUM('Normal','Emergency')              DEFAULT 'Normal',
    status           ENUM('Pending','Fulfilled','Cancelled') DEFAULT 'Pending',
    contact_number   VARCHAR(15) NOT NULL,
    location_details TEXT,
    additional_note  TEXT,
    created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id)   REFERENCES patients(patient_id)           ON DELETE CASCADE,
    FOREIGN KEY (component_id) REFERENCES blood_components(component_id) ON DELETE RESTRICT
);


-- ================================================================
-- TABLE 5 : donations  🟢 Light
-- ================================================================
CREATE TABLE donations (
    donation_id   INT  AUTO_INCREMENT PRIMARY KEY,
    donor_id      INT  NOT NULL,
    request_id    INT  DEFAULT NULL,
    units_donated INT  NOT NULL,
    quantity_ml   INT,
    donation_date DATE NOT NULL,
    status        ENUM('Pending','Completed','Cancelled') DEFAULT 'Pending',
    FOREIGN KEY (donor_id)   REFERENCES donors(donor_id)           ON DELETE CASCADE,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id) ON DELETE SET NULL
);


-- ================================================================
-- TABLE 6 : blood_stock  🟢 Light
-- component ENUM replaced with component_id FK
-- UNIQUE(blood_group, component_id) — one row per combination
-- ================================================================
CREATE TABLE blood_stock (
    stock_id        INT  AUTO_INCREMENT PRIMARY KEY,
    blood_group     ENUM('A+','A-','AB+','AB-','B+','B-','O+','O-') NOT NULL,
    component_id    INT  NOT NULL,
    units_available INT  DEFAULT 0,
    last_updated    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                              ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_blood_component (blood_group, component_id),
    FOREIGN KEY (component_id) REFERENCES blood_components(component_id) ON DELETE RESTRICT
);


-- ================================================================
-- TABLE 7 : blood_inventory  🔴 Heavy
-- component ENUM replaced with component_id FK
-- ================================================================
CREATE TABLE blood_inventory (
    inventory_id  INT         AUTO_INCREMENT PRIMARY KEY,
    bag_number    VARCHAR(50) NOT NULL UNIQUE,
    blood_group   ENUM('A+','A-','AB+','AB-','B+','B-','O+','O-') NOT NULL,
    component_id  INT         NOT NULL,
    quantity_ml   INT         NOT NULL,
    received_date DATE        NOT NULL,
    expiry_date   DATE        NOT NULL,
    status        ENUM('Available','Used','Expired','Discarded') DEFAULT 'Available',
    added_by      INT         DEFAULT NULL,
    created_at    TIMESTAMP   DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (component_id) REFERENCES blood_components(component_id) ON DELETE RESTRICT,
    FOREIGN KEY (added_by)     REFERENCES users(user_id)                 ON DELETE SET NULL
);


-- ================================================================
-- TABLE 8 : emergency_alerts  🟡 Medium
-- ================================================================
CREATE TABLE emergency_alerts (
    alert_id     INT AUTO_INCREMENT PRIMARY KEY,
    request_id   INT NOT NULL,
    donor_id     INT NOT NULL,
    sent_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response     ENUM('Accepted','Declined','No_Response') DEFAULT 'No_Response',
    responded_at TIMESTAMP NULL DEFAULT NULL,
    FOREIGN KEY (request_id) REFERENCES blood_requests(request_id) ON DELETE CASCADE,
    FOREIGN KEY (donor_id)   REFERENCES donors(donor_id)           ON DELETE CASCADE
);


-- ================================================================
-- TABLE 9 : notifications  🟢 Light
-- ================================================================
CREATE TABLE notifications (
    notification_id INT       AUTO_INCREMENT PRIMARY KEY,
    user_id         INT       NOT NULL,
    message         TEXT      NOT NULL,
    type            ENUM('Request','Donation','Alert','System') DEFAULT 'System',
    is_read         BOOLEAN   DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);


-- ================================================================
-- Verify all 10 tables
-- ================================================================
SHOW TABLES;

-- ================================================================
-- Relationships Summary
-- ================================================================
-- users            ──< patients         (one user → one patient profile)
-- users            ──< donors           (one user → one donor profile)
-- users            ──< notifications    (one user → many notifications)
-- users            ──< blood_inventory  (admin adds bags)
-- patients         ──< blood_requests   (one patient → many requests)
-- blood_components ──< blood_requests   (one component → many requests)
-- blood_components ──< blood_stock      (one component → stock row)
-- blood_components ──< blood_inventory  (one component → many bags)
-- donors           ──< donations        (one donor → many donations)

