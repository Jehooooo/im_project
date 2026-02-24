CREATE DATABASE IF NOT EXISTS campus_incidents
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE campus_incidents;

-- USERS
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('ADMIN','STAFF','COMMUNITY') NOT NULL DEFAULT 'COMMUNITY',
  status ENUM('ACTIVE','INACTIVE') NOT NULL DEFAULT 'ACTIVE',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- INCIDENTS
CREATE TABLE incidents (
  incident_id INT AUTO_INCREMENT PRIMARY KEY,
  reporter_id INT NOT NULL,
  category VARCHAR(80) NOT NULL,
  description TEXT NOT NULL,
  location VARCHAR(120) NOT NULL,
  incident_datetime DATETIME NOT NULL,
  priority ENUM('LOW','MEDIUM','HIGH','CRITICAL') NOT NULL DEFAULT 'LOW',
  status ENUM('SUBMITTED','UNDER_REVIEW','IN_PROGRESS','RESOLVED','CLOSED') NOT NULL DEFAULT 'SUBMITTED',
  photo_path VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_incidents_reporter
    FOREIGN KEY (reporter_id) REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- ASSIGNMENTS
CREATE TABLE assignments (
  assignment_id INT AUTO_INCREMENT PRIMARY KEY,
  incident_id INT NOT NULL,
  staff_id INT NOT NULL,
  assigned_by INT NOT NULL,
  assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  CONSTRAINT fk_assignments_incident
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_assignments_staff
    FOREIGN KEY (staff_id) REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_assignments_admin
    FOREIGN KEY (assigned_by) REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- INCIDENT UPDATES (AUDIT TRAIL)
CREATE TABLE incident_updates (
  update_id INT AUTO_INCREMENT PRIMARY KEY,
  incident_id INT NOT NULL,
  updated_by INT NOT NULL,
  old_status ENUM('SUBMITTED','UNDER_REVIEW','IN_PROGRESS','RESOLVED','CLOSED') NOT NULL,
  new_status ENUM('SUBMITTED','UNDER_REVIEW','IN_PROGRESS','RESOLVED','CLOSED') NOT NULL,
  remarks TEXT NOT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_updates_incident
    FOREIGN KEY (incident_id) REFERENCES incidents(incident_id)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_updates_user
    FOREIGN KEY (updated_by) REFERENCES users(user_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Helpful indexes
CREATE INDEX idx_incidents_status ON incidents(status);
CREATE INDEX idx_incidents_datetime ON incidents(incident_datetime);
CREATE INDEX idx_assignments_incident_active ON assignments(incident_id, is_active);
