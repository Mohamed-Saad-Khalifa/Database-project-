-- 1. Create Database
DROP DATABASE IF EXISTS HospitalDB;
CREATE DATABASE HospitalDB;
USE HospitalDB;

-- 2. Create Tables
-- Department Table
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Location VARCHAR(255) NOT NULL
);

-- RoomType Lookup Table
CREATE TABLE RoomType (
    RoomTypeID INT PRIMARY KEY AUTO_INCREMENT,
    Type VARCHAR(50) NOT NULL UNIQUE
);

-- Room Table
CREATE TABLE Room (
    RoomID INT PRIMARY KEY AUTO_INCREMENT,
    RoomTypeID INT NOT NULL,
    Status ENUM('Occupied', 'Vacant') DEFAULT 'Vacant',
    FOREIGN KEY (RoomTypeID) REFERENCES RoomType(RoomTypeID)
);

-- Patient Table
CREATE TABLE Patient (
    PatientID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    DOB DATE NOT NULL,
    Gender ENUM('Male', 'Female', 'Other'),
    ContactInfo VARCHAR(255),
    RoomID INT,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

-- Doctor Table
CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Specialty VARCHAR(255),
    DepartmentID INT NOT NULL,
    ContactInfo VARCHAR(255),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- Nurse Table
CREATE TABLE Nurse (
    NurseID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    DepartmentID INT NOT NULL,
    ContactInfo VARCHAR(255),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- Appointment Table
CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY AUTO_INCREMENT,
    DateTime DATETIME NOT NULL,
    Purpose TEXT,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

-- MedicalRecord Table
CREATE TABLE MedicalRecord (
    RecordID INT PRIMARY KEY AUTO_INCREMENT,
    Diagnosis TEXT NOT NULL,
    Date DATE NOT NULL,
    PatientID INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID)
);

-- TreatmentType Lookup Table
CREATE TABLE TreatmentType (
    TreatmentTypeID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    Description TEXT
);

-- Treatment Table
CREATE TABLE Treatment (
    TreatmentID INT PRIMARY KEY AUTO_INCREMENT,
    TreatmentTypeID INT NOT NULL,
    MedicalRecordID INT NOT NULL,
    DoctorID INT,
    NurseID INT,
    FOREIGN KEY (TreatmentTypeID) REFERENCES TreatmentType(TreatmentTypeID),
    FOREIGN KEY (MedicalRecordID) REFERENCES MedicalRecord(RecordID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
    CHECK (DoctorID IS NOT NULL OR NurseID IS NOT NULL)
);

-- Manufacturer Lookup Table
CREATE TABLE Manufacturer (
    ManufacturerID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL UNIQUE
);

-- Medication Table
CREATE TABLE Medication (
    MedicationID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    ManufacturerID INT NOT NULL,
    FOREIGN KEY (ManufacturerID) REFERENCES Manufacturer(ManufacturerID)
);

-- Prescription Table
CREATE TABLE Prescription (
    PrescriptionID INT PRIMARY KEY AUTO_INCREMENT,
    Date DATE NOT NULL,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID)
);

-- Prescription_Medication Junction Table
CREATE TABLE Prescription_Medication (
    PrescriptionID INT NOT NULL,
    MedicationID INT NOT NULL,
    Dosage VARCHAR(255) NOT NULL,
    Frequency VARCHAR(255) NOT NULL,
    PRIMARY KEY (PrescriptionID, MedicationID),
    FOREIGN KEY (PrescriptionID) REFERENCES Prescription(PrescriptionID),
    FOREIGN KEY (MedicationID) REFERENCES Medication(MedicationID)
);

-- Nurse_Room_Assignment Junction Table (Optional)
CREATE TABLE Nurse_Room_Assignment (
    NurseID INT NOT NULL,
    RoomID INT NOT NULL,
    PRIMARY KEY (NurseID, RoomID),
    FOREIGN KEY (NurseID) REFERENCES Nurse(NurseID),
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID)
);

-- 3. Create Roles and Permissions
-- Create Roles
CREATE ROLE IF NOT EXISTS 'Administrator', 'DoctorRole', 'NurseRole', 'PatientRole';

-- Administrator Permissions
GRANT ALL PRIVILEGES ON HospitalDB.* TO 'Administrator';

-- Doctor Permissions
GRANT SELECT, INSERT, UPDATE ON HospitalDB.Patient TO 'DoctorRole';
GRANT SELECT, INSERT, UPDATE ON HospitalDB.MedicalRecord TO 'DoctorRole';
GRANT SELECT, INSERT, UPDATE ON HospitalDB.Treatment TO 'DoctorRole';
GRANT SELECT, INSERT, UPDATE ON HospitalDB.Prescription TO 'DoctorRole';
GRANT SELECT ON HospitalDB.Medication TO 'DoctorRole';

-- Nurse Permissions
GRANT SELECT ON HospitalDB.Patient TO 'NurseRole';
GRANT SELECT, INSERT, UPDATE ON HospitalDB.Treatment TO 'NurseRole';
GRANT SELECT ON HospitalDB.Room TO 'NurseRole';

-- Patient Permissions (Read-only access to their records)
GRANT SELECT ON HospitalDB.Patient TO 'PatientRole';
GRANT SELECT ON HospitalDB.MedicalRecord TO 'PatientRole';
GRANT SELECT ON HospitalDB.Prescription TO 'PatientRole';

-- 4. Create Users and Assign Roles
-- Administrator User
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'SecureAdminPass123!';
GRANT 'Administrator' TO 'admin_user'@'localhost';

-- Doctor User
CREATE USER 'dr_smith'@'localhost' IDENTIFIED BY 'DoctorPass123!';
GRANT 'DoctorRole' TO 'dr_smith'@'localhost';

-- Nurse User
CREATE USER 'nurse_jones'@'localhost' IDENTIFIED BY 'NursePass123!';
GRANT 'NurseRole' TO 'nurse_jones'@'localhost';

-- Patient User
CREATE USER 'patient_doe'@'localhost' IDENTIFIED BY 'PatientPass123!';
GRANT 'PatientRole' TO 'patient_doe'@'localhost';

-- 5. Populate Lookup Tables (Example Data)
INSERT INTO RoomType (Type) VALUES
('ICU'),
('General Ward'),
('Operating Room'),
('Maternity Ward'),
('Emergency Room'),
('Pediatric Ward'),
('Isolation Room'),
('Cardiac Ward'),
('Oncology Ward'),
('Recovery Room'),
('Neonatal ICU'),
('Orthopedic Ward'),
('Psychiatric Ward'),
('Burn Unit'),
('Trauma Center'),
('Endoscopy Suite'),
('Dialysis Unit'),
('Labor & Delivery'),
('Post-Op Recovery'),
('Palliative Care');

INSERT INTO Appointment (DateTime, Purpose, PatientID, DoctorID) VALUES
('2023-10-01 09:00:00', 'Heart Checkup', 1, 1),
('2023-10-01 10:00:00', 'Child Vaccination', 2, 2),
('2023-10-02 11:00:00', 'Cancer Consultation', 3, 3),
('2023-10-03 14:00:00', 'Neurology Exam', 4, 4),
('2023-10-04 15:00:00', 'Bone Fracture', 5, 5),
('2023-10-05 16:00:00', 'Prenatal Care', 6, 6),
('2023-10-06 10:30:00', 'Emergency Visit', 7, 7),
('2023-10-07 12:00:00', 'Skin Allergy', 8, 8),
('2023-10-08 13:00:00', 'Surgery Follow-up', 9, 9),
('2023-10-09 14:30:00', 'Eye Exam', 10, 10),
('2023-10-10 15:00:00', 'ENT Checkup', 11, 11),
('2023-10-11 16:00:00', 'Diabetes Management', 12, 12),
('2023-10-12 09:00:00', 'Psychiatry Session', 13, 13),
('2023-10-13 10:00:00', 'Diet Plan', 14, 14),
('2023-10-14 11:00:00', 'Physical Therapy', 15, 15),
('2023-10-15 12:00:00', 'Brain Scan', 16, 16),
('2023-10-16 13:00:00', 'Burns Treatment', 17, 17),
('2023-10-17 14:00:00', 'Thyroid Test', 18, 18),
('2023-10-18 15:00:00', 'Lab Report', 19, 19),
('2023-10-19 16:00:00', 'Blood Test', 20, 20);

INSERT INTO Department (Name, Location) VALUES
('Cardiology', 'Floor 5'),
('Pediatrics', 'Floor 3'),
('Oncology', 'Floor 7'),
('Neurology', 'Floor 2'),
('Orthopedics', 'Floor 4'),
('Gynecology', 'Floor 6'),
('Emergency Medicine', 'Floor 1'),
('Radiology', 'Floor 8'),
('Dermatology', 'Floor 9'),
('General Surgery', 'Floor 10'),
('Ophthalmology', 'Floor 11'),
('ENT', 'Floor 12'),
('Internal Medicine', 'Floor 13'),
('Psychiatry', 'Floor 14'),
('Nutrition', 'Floor 15'),
('Physiotherapy', 'Floor 16'),
('Neurosurgery', 'Floor 17'),
('Plastic Surgery', 'Floor 18'),
('Nuclear Medicine', 'Floor 19'),
('Laboratory', 'Floor 20');

INSERT INTO Doctor (Name, Specialty, DepartmentID, ContactInfo) VALUES
('Dr. Ahmed Ali', 'Cardiologist', 1, 'ahmed.ali@hospital.com'),
('Dr. Mohamed Hassan', 'Pediatrician', 2, 'mohamed.hassan@hospital.com'),
('Dr. Ali Mahmoud', 'Oncologist', 3, 'ali.mahmoud@hospital.com'),
('Dr. Hassan Abdullah', 'Neurologist', 4, 'hassan.abdullah@hospital.com'),
('Dr. Fatima Omar', 'Orthopedist', 5, 'fatima.omar@hospital.com'),
('Dr. Layla Khaled', 'Gynecologist', 6, 'layla.khaled@hospital.com'),
('Dr. Omar Ibrahim', 'Emergency Physician', 7, 'omar.ibrahim@hospital.com'),
('Dr. Nora Saeed', 'Radiologist', 8, 'nora.saeed@hospital.com'),
('Dr. Youssef Nasser', 'Dermatologist', 9, 'youssef.nasser@hospital.com'),
('Dr. Sara Mohamed', 'Surgeon', 10, 'sara.mohamed@hospital.com'),
('Dr. Khaled Walid', 'Ophthalmologist', 11, 'khaled.walid@hospital.com'),
('Dr. Rania Fadel', 'ENT Specialist', 12, 'rania.fadel@hospital.com'),
('Dr. Amin Rachid', 'Internist', 13, 'amine.rachid@hospital.com'),
('Dr. Heba Ali', 'Psychiatrist', 14, 'heba.ali@hospital.com'),
('Dr. Basel Kamal', 'Nutritionist', 15, 'basel.kamal@hospital.com'),
('Dr. Nada Samir', 'Physiotherapist', 16, 'nada.samir@hospital.com'),
('Dr. Wael Adel', 'Neurosurgeon', 17, 'wael.adel@hospital.com'),
('Dr. Iman Farouk', 'Plastic Surgeon', 18, 'iman.farouk@hospital.com'),
('Dr. Tarek Nabil', 'Nuclear Physician', 19, 'tarek.nabil@hospital.com'),
('Dr. Salma Rami', 'Pathologist', 20, 'salma.rami@hospital.com');

IINSERT INTO TreatmentType (Name, Description) VALUES
('Surgery', 'Invasive procedure'),
('Physiotherapy', 'Physical rehabilitation'),
('Chemotherapy', 'Cancer treatment'),
('Dialysis', 'Kidney treatment'),
('Radiotherapy', 'Radiation therapy'),
('Endoscopy', 'Internal examination'),
('MRI Scan', 'Magnetic resonance imaging'),
('CT Scan', 'Computed tomography'),
('Blood Transfusion', 'Transfer of blood'),
('Vaccination', 'Immunization'),
('Biopsy', 'Tissue sampling'),
('ECG', 'Heart monitoring'),
('Angioplasty', 'Heart vessel repair'),
('Cataract Surgery', 'Eye surgery'),
('Dermatology Exam', 'Skin checkup'),
('Colonoscopy', 'Colon examination'),
('Bone Marrow Transplant', 'Transplant procedure'),
('Laser Therapy', 'Light-based treatment'),
('Psychotherapy', 'Mental health therapy'),
('Hormone Therapy', 'Endocrine treatment');

INSERT INTO Manufacturer (Name) VALUES
('Pfizer'),
('Novartis'),
('Johnson & Johnson'),
('AstraZeneca'),
('GlaxoSmithKline'),
('Merck'),
('Sanofi'),
('Roche'),
('Bayer'),
('Abbott'),
('Novo Nordisk'),
('Bristol-Myers Squibb'),
('Eli Lilly'),
('Gilead Sciences'),
('Amgen'),
('Biogen'),
('Takeda'),
('Teva Pharmaceuticals'),
('Moderna'),
('Siemens Healthineers');

INSERT INTO Nurse (Name, DepartmentID, ContactInfo) VALUES
('Nurse Samira Ahmed', 1, 'samira.ahmed@hospital.com'),
('Nurse Alya Mohamed', 2, 'alya.mohamed@hospital.com'),
('Nurse Nora Khaled', 3, 'nora.khaled@hospital.com'),
('Nurse Rania Hussein', 4, 'rania.hussein@hospital.com'),
('Nurse Huda Walid', 5, 'huda.walid@hospital.com'),
('Nurse Lina Omar', 6, 'lina.omar@hospital.com'),
('Nurse Yasmin Nasser', 7, 'yasmin.nasser@hospital.com'),
('Nurse Mariam Ali', 8, 'mariam.ali@hospital.com'),
('Nurse Fatima Ibrahim', 9, 'fatima.ibrahim@hospital.com'),
('Nurse Sahar Mahmoud', 10, 'sahar.mahmoud@hospital.com'),
('Nurse Ghada Rachid', 11, 'ghada.rachid@hospital.com'),
('Nurse Nada Saeed', 12, 'nada.saeed@hospital.com'),
('Nurse Dalia Kamal', 13, 'dalia.kamal@hospital.com'),
('Nurse Inas Hassan', 14, 'inas.hassan@hospital.com'),
('Nurse Ragda Wael', 15, 'raghda.wael@hospital.com'),
('Nurse Heba Farouk', 16, 'heba.farouk@hospital.com'),
('Nurse Samar Tarek', 17, 'samar.tarek@hospital.com'),
('Nurse Maha Nabil', 18, 'maha.nabil@hospital.com'),
('Nurse Nasreen Rami', 19, 'nasreen.rami@hospital.com'),
('Nurse Amel Samir', 20, 'amel.samir@hospital.com');

INSERT INTO Patient (Name, DOB, Gender, ContactInfo, RoomID) VALUES
('Mohamed Abdelrahman', '1990-05-15', 'Male', 'mohamed.abdo@email.com', 1),
('Fatima Elsayed', '1985-08-22', 'Female', 'fatima.elsayed@email.com', 2),
('Ali Hassan', '1978-03-10', 'Male', 'ali.hassan@email.com', 3),
('Aya Mohamed', '2000-12-05', 'Female', 'aya.mohamed@email.com', 4),
('Khaled Amin', '1995-07-19', 'Male', 'khaled.amine@email.com', 5),
('Nora Kamal', '1982-09-30', 'Female', 'nora.kamal@email.com', 6),
('Walid Rachid', '1993-01-25', 'Male', 'walid.rachid@email.com', 7),
('Samar Ali', '1970-04-12', 'Female', 'samar.ali@email.com', 8),
('Ahmed Nabil', '2005-11-08', 'Male', 'ahmed.nabil@email.com', 9),
('Layla Farouk', '1988-06-14', 'Female', 'layla.farouk@email.com', 10),
('Mahmoud Saeed', '1999-02-18', 'Male', 'mahmoud.saeed@email.com', 11),
('Hanna Wael', '2002-07-23', 'Female', 'hanna.wael@email.com', 12),
('Omar Khalil', '1987-10-30', 'Male', 'omar.khalil@email.com', 13),
('Rana Adel', '1994-12-14', 'Female', 'rana.adel@email.com', 14),
('Yasser Tarek', '1975-05-05', 'Male', 'yasser.tarek@email.com', 15),
('Siham Nasser', '2001-08-19', 'Female', 'siham.nasser@email.com', 16),
('Nader Rami', '1997-03-22', 'Male', 'nader.rami@email.com', 17),
('Maha Samir', '1989-09-09', 'Female', 'maha.samir@email.com', 18),
('Farid Kamal', '1965-11-11', 'Male', 'farid.kamal@email.com', 19),
('Eman Hussein', '2003-04-25', 'Female', 'eman.hussein@email.com', 20);

-INSERT INTO Room (RoomTypeID, Status) VALUES
(1, 'Occupied'),
(2, 'Vacant'),
(3, 'Vacant'),
(4, 'Occupied'),
(5, 'Occupied'),
(6, 'Vacant'),
(7, 'Vacant'),
(8, 'Occupied'),
(9, 'Vacant'),
(10, 'Occupied'),
(11, 'Occupied'),
(12, 'Vacant'),
(13, 'Occupied'),
(14, 'Vacant'),
(15, 'Occupied'),
(16, 'Vacant'),
(17, 'Vacant'),
(18, 'Occupied'),
(19, 'Vacant'),
(20, 'Occupied');

INSERT INTO MedicalRecord (Diagnosis, Date, PatientID) VALUES
('Hypertension', '2023-09-01', 1),
('Influenza', '2023-09-02', 2),
('Fractured Femur', '2023-09-03', 3),
('Pneumonia', '2023-09-04', 4),
('Migraine', '2023-09-05', 5),
('Type 2 Diabetes', '2023-09-06', 6),
('Eczema', '2023-09-07', 7),
('Chronic Kidney Disease', '2023-09-08', 8),
('Osteoarthritis', '2023-09-09', 9),
('Appendicitis', '2023-09-10', 10),
('Asthma', '2023-09-11', 11),
('Hypothyroidism', '2023-09-12', 12),
('Depression', '2023-09-13', 13),
('Ulcerative Colitis', '2023-09-14', 14),
('Breast Cancer', '2023-09-15', 15),
('Hepatitis B', '2023-09-16', 16),
('Epilepsy', '2023-09-17', 17),
('Psoriasis', '2023-09-18', 18),
('Rheumatoid Arthritis', '2023-09-19', 19),
('Glaucoma', '2023-09-20', 20);

INSERT INTO Treatment (TreatmentTypeID, MedicalRecordID, DoctorID, NurseID) VALUES
(1, 1, 1, NULL),   -- Surgery by Dr. Ahmed Ali
(3, 2, NULL, 1),    -- Chemotherapy by Nurse Samira Ahmed
(5, 3, 3, NULL),    -- Radiotherapy by Dr. Ali Mahmoud
(4, 4, NULL, 2),    -- Dialysis by Nurse Alya Mohamed
(2, 5, 5, NULL),    -- Physiotherapy by Dr. Fatima Omar
(6, 6, NULL, 3),    -- Endoscopy by Nurse Nora Khaled
(7, 7, 7, NULL),    -- MRI Scan by Dr. Omar Ibrahim
(8, 8, NULL, 4),    -- CT Scan by Nurse Rania Hussein
(9, 9, 9, NULL),    -- Blood Transfusion by Dr. Youssef Nasser
(10, 10, NULL, 5),  -- Vaccination by Nurse Huda Walid
(11, 11, 11, NULL), -- Biopsy by Dr. Khaled Walid
(12, 12, NULL, 6),  -- ECG by Nurse Lina Omar
(13, 13, 13, NULL), -- Angioplasty by Dr. Amin Rachid
(14, 14, NULL, 7),  -- Cataract Surgery by Nurse Yasmin Nasser
(15, 15, 15, NULL), -- Dermatology Exam by Dr. Basel Kamal
(16, 16, NULL, 8),  -- Colonoscopy by Nurse Mariam Ali
(17, 17, 17, NULL), -- Bone Marrow Transplant by Dr. Wael Adel
(18, 18, NULL, 9),  -- Laser Therapy by Nurse Fatima Ibrahim
(19, 19, 19, NULL), -- Psychotherapy by Dr. Tarek Nabil
(20, 20, NULL, 10); -- Hormone Therapy by Nurse Sahar Mahmoud

INSERT INTO Medication (Name, ManufacturerID) VALUES
('Paracetamol', 1),
('Insulin', 11),
('Amoxicillin', 3),
('Ibuprofen', 4),
('Omeprazole', 5),
('Lisinopril', 6),
('Metformin', 7),
('Atorvastatin', 8),
('Aspirin', 9),
('Cetirizine', 10),
('Warfarin', 2),
('Levothyroxine', 12),
('Albuterol', 13),
('Hydrocodone', 14),
('Losartan', 15),
('Gabapentin', 16),
('Sertraline', 17),
('Tramadol', 18),
('Prednisone', 19),
('Doxycycline', 20);

INSERT INTO Prescription (Date, PatientID, DoctorID) VALUES
('2023-09-01', 1, 1),
('2023-09-02', 2, 2),
('2023-09-03', 3, 3),
('2023-09-04', 4, 4),
('2023-09-05', 5, 5),
('2023-09-06', 6, 6),
('2023-09-07', 7, 7),
('2023-09-08', 8, 8),
('2023-09-09', 9, 9),
('2023-09-10', 10, 10),
('2023-09-11', 11, 11),
('2023-09-12', 12, 12),
('2023-09-13', 13, 13),
('2023-09-14', 14, 14),
('2023-09-15', 15, 15),
('2023-09-16', 16, 16),
('2023-09-17', 17, 17),
('2023-09-18', 18, 18),
('2023-09-19', 19, 19),
('2023-09-20', 20, 20);

INSERT INTO Prescription_Medication (PrescriptionID, MedicationID, Dosage, Frequency) VALUES
(1, 1, '500mg', 'Every 6 hours'),
(2, 2, '10 units', 'Daily'),
(3, 3, '250mg', 'Twice daily'),
(4, 4, '400mg', 'Every 8 hours'),
(5, 5, '20mg', 'Once daily'),
(6, 6, '5mg', 'Once daily'),
(7, 7, '500mg', 'Twice daily'),
(8, 8, '10mg', 'At bedtime'),
(9, 9, '81mg', 'Once daily'),
(10, 10, '10mg', 'Once daily'),
(11, 11, '5mg', 'Daily'),
(12, 12, '50mcg', 'Morning'),
(13, 13, '2 puffs', 'As needed'),
(14, 14, '10mg', 'Every 4-6 hours'),
(15, 15, '50mg', 'Once daily'),
(16, 16, '300mg', 'Three times daily'),
(17, 17, '50mg', 'Once daily'),
(18, 18, '50mg', 'Every 6 hours'),
(19, 19, '10mg', 'Once daily'),
(20, 20, '100mg', 'Twice daily');

INSERT INTO Nurse_Room_Assignment (NurseID, RoomID) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10),
(11, 11),
(12, 12),
(13, 13),
(14, 14),
(15, 15),
(16, 16),
(17, 17),
(18, 18),
(19, 19),
(20, 20);

--1
-- -- Find all patients named "Ahmed" and sort by admission date (newest first):
--SELECT p.Name, p.DOB, p.Gender, r.Type AS RoomType, mr.Date AS AdmissionDate
--FROM Patient p
--JOIN MedicalRecord mr ON p.PatientID = mr.PatientID
--JOIN Room rm ON p.RoomID = rm.RoomID
--JOIN RoomType rt ON rm.RoomTypeID = rt.RoomTypeID
--WHERE p.Name LIKE '%Ahmed%'
--ORDER BY mr.Date DESC;

--2
-- -- Count the number of patients by gender:
--SELECT Gender, COUNT(*) AS TotalPatients
--FROM Patient
--GROUP BY Gender
--ORDER BY TotalPatients DESC;

--3
-- -- Find total "Paracetamol" prescriptions and total dosage:
--SELECT m.Name AS Medication, 
--COUNT(*) AS TotalPrescriptions,
--SUM(pm.Dosage) AS TotalDosage
--FROM Prescription_Medication pm
--JOIN Medication m ON pm.MedicationID = m.MedicationID
--WHERE m.Name = 'Paracetamol'
--GROUP BY m.Name;

--4
-- -- List all doctors in the Cardiology department sorted alphabetically:
--SELECT d.Name AS DoctorName, d.Specialty, dep.Name AS Department
--FROM Doctor d
--JOIN Department dep ON d.DepartmentID = dep.DepartmentID
--WHERE dep.Name = 'Cardiology'
--ORDER BY d.Name ASC;

--5
-- -- Show the 5 most frequently prescribed medications:
--SELECT m.Name AS Medication, 
--COUNT(pm.MedicationID) AS PrescriptionCount,
--SUM(pm.Dosage) AS TotalDosage
--FROM Prescription_Medication pm
--JOIN Medication m ON pm.MedicationID = m.MedicationID
--GROUP BY m.Name
--ORDER BY PrescriptionCount DESC
--LIMIT 5;
