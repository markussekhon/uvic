CREATE TABLE Campaign (
    CampaignID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    Focus VARCHAR(255),
    StartDate DATE,
    EndDate DATE
);

CREATE TABLE Event (
    EventID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    Date DATE,
    Location VARCHAR(255),
    CampaignID INTEGER,
    FOREIGN KEY (CampaignID) REFERENCES Campaign(CampaignID)
);

CREATE TABLE Member (
    MemberID SERIAL PRIMARY KEY,
    Name VARCHAR(255),
    Email VARCHAR(255),
    Number VARCHAR(50)
);

CREATE TABLE Volunteer (
    MemberID INTEGER PRIMARY KEY REFERENCES Member(MemberID),
    NumberOfCampaigns INTEGER
);

CREATE TABLE Employee (
    MemberID INTEGER PRIMARY KEY REFERENCES Member(MemberID),
    OrganizationRole VARCHAR(255)
);

CREATE TABLE Donor (
    MemberID INTEGER PRIMARY KEY REFERENCES Member(MemberID),
    IsLargeDonor BOOLEAN,
    IsAnon BOOLEAN
);

CREATE TABLE Finances (
    FinanceID SERIAL PRIMARY KEY,
    Amount DECIMAL(10, 2),
    Date DATE
);

CREATE TABLE Website (
    WebsiteID SERIAL PRIMARY KEY,
    CampaignID INTEGER REFERENCES Campaign(CampaignID),
    DateToPublish DATE,
    Description TEXT
);

CREATE TABLE Donations (
    DonationID SERIAL PRIMARY KEY,
    CampaignID INTEGER REFERENCES Campaign(CampaignID),
    MemberID INTEGER REFERENCES Donor(MemberID),
    Date DATE,
    Amount DECIMAL(10, 2)
);

CREATE TABLE VolsFor (
    CampaignID INTEGER REFERENCES Campaign(CampaignID),
    MemberID INTEGER REFERENCES Volunteer(MemberID),
    UNIQUE (CampaignID, MemberID)
);

CREATE TABLE WorksOn (
    CampaignID INTEGER REFERENCES Campaign(CampaignID),
    MemberID INTEGER REFERENCES Employee(MemberID),
    UNIQUE (CampaignID, MemberID)
);

CREATE TABLE Salary (
    FinanceID INTEGER PRIMARY KEY REFERENCES Finances(FinanceID),
    MemberID INTEGER NOT NULL REFERENCES Employee(MemberID)
);

CREATE TABLE Expenses (
    FinanceID INTEGER PRIMARY KEY REFERENCES Finances(FinanceID),
    CampaignID INTEGER NOT NULL REFERENCES Campaign(CampaignID),
    Amount DECIMAL(10, 2) NOT NULL,
    Date DATE NOT NULL,
    Description TEXT NOT NULL
);

-- Campaign
INSERT INTO Campaign (Name, Focus, StartDate, EndDate) VALUES ('Clean the Beach', 'Environment', '2023-04-01', '2023-04-30');
INSERT INTO Campaign (Name, Focus, StartDate, EndDate) VALUES ('Plant a Tree', 'Reforestation', '2023-05-01', '2023-05-31');

-- Event
INSERT INTO Event (Name, Date, Location, CampaignID) VALUES ('Beach Cleanup Kickoff', '2023-04-01', 'Sunny Beach', 1);
INSERT INTO Event (Name, Date, Location, CampaignID) VALUES ('Educational Workshop', '2023-04-08', 'Community Center', 1);
INSERT INTO Event (Name, Date, Location, CampaignID) VALUES ('Recycling Drive', '2023-04-15', 'Sunny Beach', 1);
INSERT INTO Event (Name, Date, Location, CampaignID) VALUES ('Beach Cleanup Wrap-up', '2023-04-22', 'Sunny Beach', 1);
INSERT INTO Event (Name, Date, Location, CampaignID) VALUES ('Celebration Event', '2023-04-29', 'Local Park', 1);

-- Volunteers (Members)
INSERT INTO Member (Name, Email, Number) VALUES ('Alice Smith', 'alice@example.com', '111-000-0100');
INSERT INTO Member (Name, Email, Number) VALUES ('Bob Jones', 'bob@example.com', '111-000-0101');
INSERT INTO Member (Name, Email, Number) VALUES ('Carol Danvers', 'carol@example.com', '111-000-0102');
INSERT INTO Member (Name, Email, Number) VALUES ('Dave Brown', 'dave@example.com', '111-000-0103');

-- Volunteers
INSERT INTO Volunteer (MemberID, NumberOfCampaigns) VALUES (1, 2);
INSERT INTO Volunteer (MemberID, NumberOfCampaigns) VALUES (2, 2);
INSERT INTO Volunteer (MemberID, NumberOfCampaigns) VALUES (3, 1);
INSERT INTO Volunteer (MemberID, NumberOfCampaigns) VALUES (4, 1);

-- VolsFor
INSERT INTO VolsFor (CampaignID, MemberID) VALUES (1, 1);
INSERT INTO VolsFor (CampaignID, MemberID) VALUES (1, 2);
INSERT INTO VolsFor (CampaignID, MemberID) VALUES (2, 1);
INSERT INTO VolsFor (CampaignID, MemberID) VALUES (2, 2);
INSERT INTO VolsFor (CampaignID, MemberID) VALUES (1, 3);
INSERT INTO VolsFor (CampaignID, MemberID) VALUES (2, 4);


-- Employees (Members)
INSERT INTO Member (Name, Email, Number) VALUES ('Eve Adams', 'eve@example.com', '111-000-0200');
INSERT INTO Member (Name, Email, Number) VALUES ('Frank Castle', 'frank@example.com', '111-000-0201');
INSERT INTO Member (Name, Email, Number) VALUES ('Grace Lee', 'grace@example.com', '111-000-0202');

-- Employees
INSERT INTO Employee (MemberID, OrganizationRole) VALUES (5, 'Coordinator');
INSERT INTO Employee (MemberID, OrganizationRole) VALUES (6, 'Project Manager');
INSERT INTO Employee (MemberID, OrganizationRole) VALUES (7, 'Outreach Specialist');

-- WorksOn
INSERT INTO WorksOn (CampaignID, MemberID) VALUES (1, 5);
INSERT INTO WorksOn (CampaignID, MemberID) VALUES (1, 6);
INSERT INTO WorksOn (CampaignID, MemberID) VALUES (1, 7);
INSERT INTO WorksOn (CampaignID, MemberID) VALUES (2, 7);

-- Donors (Members)
INSERT INTO Member (Name, Email, Number) VALUES ('Henry Ford', 'henry@example.com', '111-000-0300');
INSERT INTO Member (Name, Email, Number) VALUES ('Isabel Wright', 'isabel@example.com', '111-000-0301');
INSERT INTO Member (Name, Email, Number) VALUES ('Jack Black', 'jack@example.com', '111-000-0302');
INSERT INTO Member (Name, Email, Number) VALUES ('Karen Hill', 'karen@example.com', '111-000-0303');
INSERT INTO Member (Name, Email, Number) VALUES ('Liam Neeson', 'liam@example.com', '111-000-0304');

-- Donors
INSERT INTO Donor (MemberID, IsLargeDonor, IsAnon) VALUES (8, TRUE, FALSE);
INSERT INTO Donor (MemberID, IsLargeDonor, IsAnon) VALUES (9, FALSE, TRUE);
INSERT INTO Donor (MemberID, IsLargeDonor, IsAnon) VALUES (10, TRUE, TRUE);
INSERT INTO Donor (MemberID, IsLargeDonor, IsAnon) VALUES (11, FALSE, FALSE);
INSERT INTO Donor (MemberID, IsLargeDonor, IsAnon) VALUES (12, TRUE, FALSE);

-- Donations
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (1, 8, '2023-04-02', 500);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (1, 9, '2023-04-03', 150);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (1, 10, '2023-04-04', 1250);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (1, 11, '2023-04-05', 300);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (1, 12, '2023-04-06', 1200);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (1, 8, '2023-04-07', 500);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (2, 9, '2023-05-02', 100);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (2, 10, '2023-05-03', 1200);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (2, 11, '2023-05-04', 150);
INSERT INTO Donations (CampaignID, MemberID, Date, Amount) VALUES (2, 12, '2023-05-05', 1250);

-- Website
INSERT INTO Website (CampaignID, DateToPublish, Description) VALUES (1, '2023-03-30', 'Join our Clean the Beach campaign!');
INSERT INTO Website (CampaignID, DateToPublish, Description) VALUES (2, '2023-04-30', 'Help us plant a tree this May!');
INSERT INTO Website (CampaignID, DateToPublish, Description) VALUES (1, '2023-04-15', 'Beach Cleanup halfway point - progress update!');

-- Finances
INSERT INTO Finances (Amount, Date) VALUES (1000, '2023-04-01');
INSERT INTO Finances (Amount, Date) VALUES (800, '2023-05-01');
INSERT INTO Finances (Amount, Date) VALUES (1500, '2023-04-02');
INSERT INTO Finances (Amount, Date) VALUES (700, '2023-05-02');
INSERT INTO Finances (Amount, Date) VALUES (500, '2023-04-15');
INSERT INTO Finances (Amount, Date) VALUES (500, '2023-04-30');
INSERT INTO Finances (Amount, Date) VALUES (500, '2023-05-15');
INSERT INTO Finances (Amount, Date) VALUES (500, '2023-05-30');
INSERT INTO Finances (Amount, Date) VALUES (500, '2023-04-15');
INSERT INTO Finances (Amount, Date) VALUES (500, '2023-05-15');
INSERT INTO Finances (Amount, Date) VALUES (250, '2023-05-30');

-- Salary
INSERT INTO Salary (FinanceID, MemberID) VALUES (5, 5);
INSERT INTO Salary (FinanceID, MemberID) VALUES (6, 5);
INSERT INTO Salary (FinanceID, MemberID) VALUES (7, 5);
INSERT INTO Salary (FinanceID, MemberID) VALUES (8, 5);
INSERT INTO Salary (FinanceID, MemberID) VALUES (9, 6);
INSERT INTO Salary (FinanceID, MemberID) VALUES (10, 6);
INSERT INTO Salary (FinanceID, MemberID) VALUES (11, 7);

-- Expenses
INSERT INTO Expenses (FinanceID, CampaignID, Amount, Date, Description) VALUES (1, 1, 1000.00, '2023-04-01', 'Marketing for Beach Cleanup');
INSERT INTO Expenses (FinanceID, CampaignID, Amount, Date, Description) VALUES (3, 1, 1500.00, '2023-04-02', 'Cleanup Supplies');
INSERT INTO Expenses (FinanceID, CampaignID, Amount, Date, Description) VALUES (2, 2, 800.00, '2023-05-01', 'Tree Planting Supplies');
INSERT INTO Expenses (FinanceID, CampaignID, Amount, Date, Description) VALUES (4, 2, 700.00, '2023-05-02', 'Rental Equipment for Tree Planting');