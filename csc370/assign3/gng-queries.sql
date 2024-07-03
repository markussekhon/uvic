-- Query 1: Select Total Amount Spent Per Campaign

CREATE VIEW Query1 AS
SELECT
    CampaignID,
    Sum(Amount) AS TotalSpent
FROM
    Expenses
GROUP BY
    CampaignID;

-- Query 2: Total Number of Events Per Campaign

CREATE VIEW Query2 AS
SELECT
    COUNT(CampaignID) AS TotalEvents
FROM
    Event
GROUP BY
    CampaignID;

-- Query 3: AVG Number Of Events Hosted By Campaigns

CREATE VIEW Query3 AS
SELECT
    AVG(TotalEvents) AS AvgEventsPerCampaign
FROM (
    SELECT
        COUNT(CampaignID) AS TotalEvents
    FROM
        Event
    GROUP BY
        CampaignID
) AS EventCounts;

-- Query 4: Count Number of Campaigns That Have Events

CREATE VIEW Query4 AS
SELECT
    COUNT(DISTINCT CampaignID) AS NumOfCampaignsWithEvents
FROM
    Event;

-- Query 5: Total Donations to a Campaign is Higher Than Average of All Donations

CREATE VIEW Query5 AS
SELECT
    d1.CampaignID,
    SUM(d1.Amount) as TotalDonations
FROM
    Donations d1
GROUP BY
    d1.CampaignID
HAVING
    SUM(d1.Amount) > (
        SELECT
            AVG(d2.Amount)
        FROM
            Donations d2
    );

-- Query 6: Donations Greater than Average Donation to that chairty

CREATE VIEW Query6 AS
SELECT
    d1.CampaignID,
    d1.Amount
FROM
    Donations d1
WHERE
    d1.Amount > (
        SELECT
            AVG(d2.Amount)
        FROM
            Donations d2
        WHERE
            d1.CampaignID = d1.CampaignID
    );

-- Query 7: Which Volunteers Vol For All Campaigns

CREATE VIEW Query7 AS
SELECT
    v.MemberID
FROM
    VolsFor v
JOIN
    Member m ON v.MemberID = m.MemberID
GROUP BY
    v.MemberID,
    m.Name
HAVING
    COUNT(DISTINCT v.CampaignID) = 
    (SELECT
        COUNT (*)
    FROM
        Campaign);


-- Query 8: Order Campaign By Duration

CREATE VIEW Query8 AS
SELECT
    CampaignID,
    Name,
    (EndDate - StartDate) AS Duration
FROM
    Campaign
ORDER BY
    Duration;

-- Query 9: Order Employee By Number of Active Campaigns Participated In

CREATE VIEW Query9 AS
SELECT
    MemberID,
    COUNT (*) AS NumOfCampaigns
FROM
    WorksOn
GROUP BY
    MemberID
ORDER BY
    NumOfCampaigns DESC;

-- Query 10: Top 3 Donators

CREATE VIEW Query10 AS
SELECT
    MemberID,
    SUM(Amount) as TotalDonated
FROM
    Donations
GROUP BY
    MemberID
ORDER BY
    TotalDonated DESC
LIMIT
    3;

-- Query 11: Campaigns with Donations that have a single donation >= 1250

CREATE VIEW Query11 AS
SELECT
    c.CampaignID,
    c.Name
FROM
    Campaign c
WHERE
    EXISTS(
        SELECT
            d.Amount AS DonationAmount
        FROM
            Donations d
        WHERE
            d.CampaignID = c.CampaignID AND d.Amount >= 1250
    );