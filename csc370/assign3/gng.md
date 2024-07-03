# Relational Schema for Green-not-Greed (GnG)

## Entities and Attributes

### Campaign

Campaign(CampaignID (Key), Name, Focus, StartDate, EndDate)

### Event

Event(EventID (Key), Name, Date, Location, CampaignID)

### Member

Member(MemberID (Key), Name, Email, Number)

### Volunteer (ISA Member)

Volunteer(MemberID, NumberOfCampaigns)

### Employee (ISA Member)

Employee(MemberID, Role)

### Donor (ISA Member)

Donor(MemberID, IsLargeDonor, IsAnon)

### Finances

Finances(FinanceID (Key), Amount, Date)

### Website

Website(WebsiteID (Key), CampaignID, DateToPublish, Description)

- Description (could format with eventID in description if specific to event of campaign)

## Relationships

### Campaign to Event: "EventOf"

Event should house info about that campaign it is tied to, so its just added to event.

- CampaignID added to Event

### Campaign to Donors: "Donations"

A new set of relations as we can track donations in specific then.

Donations(DonationID (Key), CampaignID, MemberID, Date, Amount)

### Campaign to Volunteers: "VolsFor"

A set of relations to understand which campaigns someone volunteers for.

VolsFor(CampaignID (Key), MemberID (Key))

-key together


### Campaign to Employees: "WorksOn"

A set of relations to understand which campaigns someone works for.

WorksOn(CampaignID (Key), MemberID (Key) )

-key together

### Employee to Finances: "Salary"

A set of relations to find out salary payments of employees (Changed to 1:M)

Salary(MemberID, FinanaceID (Key))

### Campaign to Finances: "Expenses"

A set of relations to understand expenses

Expenses(FinanceID (Key), CampaignID, Description)

- Description (could format with eventID in description if specific to event of campaign)

### Website to Campaign: "Content"

So, I changed this and brought it all into website instead. Made more sense. Also I made website m:1 w/ campaign.