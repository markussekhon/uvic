import psycopg2
    
def query1(cursor):
    query = """
            SELECT CampaignID, SUM(Amount) AS TotalSpent
            FROM Expenses
            GROUP BY CampaignID;
            """
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Campaign ID: {row[0]}, Total Spent: {row[1]:.2f}")
    
    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")
        

def query2(cursor):
    query = """
            SELECT CampaignID, COUNT(*) AS TotalEvents
            FROM Event
            GROUP BY CampaignID;
            """
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Campaign ID: {row[0]}, Total Events: {row[1]}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query3(cursor):
    query = """
            SELECT AVG(TotalEvents) AS AvgEventsPerCampaign
            FROM (
                SELECT COUNT(CampaignID) AS TotalEvents
                FROM Event
                GROUP BY CampaignID
            ) AS EventCounts;
            """
    try:
        cursor.execute(query)
        row = cursor.fetchone()
        print(f"Average Events: {row[0]:.2f}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query4(cursor):
    query = """
            SELECT COUNT(DISTINCT CampaignID) AS NumOfCampaignsWithEvents
            FROM Event;
            """
    try:
        cursor.execute(query)
        row = cursor.fetchone()
        print("Number of Campaigns That Have Events:")
        print(f"Number of Campaigns with Events: {row[0]}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query5(cursor):
    query = """
            SELECT d1.CampaignID, SUM(d1.Amount) as TotalDonations
            FROM Donations d1
            GROUP BY d1.CampaignID
            HAVING SUM(d1.Amount) > (
                SELECT AVG(d2.Amount)
                FROM Donations d2
            );
            """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Campaign ID: {row[0]}, Total Donations: {row[1]:.2f}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query6(cursor):
    query = """
            SELECT d1.CampaignID, d1.Amount
            FROM Donations d1
            WHERE d1.Amount > (
                SELECT AVG(d2.Amount)
                FROM Donations d2
                WHERE d2.CampaignID = d1.CampaignID
            );
            """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Campaign ID: {row[0]}, Donation Amount: {row[1]:.2f}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query7(cursor):
    query = """
            SELECT v.MemberID, COUNT(DISTINCT v.CampaignID) as Campaigns
            FROM VolsFor v
            JOIN Campaign ON v.CampaignID = Campaign.CampaignID
            GROUP BY v.MemberID
            HAVING COUNT(DISTINCT v.CampaignID) = (SELECT COUNT(*) FROM Campaign);
            """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Member ID: {row[0]}, Campaigns Volunteered: {row[1]}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query8(cursor):
    query = """
            SELECT CampaignID, Name, EXTRACT(day FROM AGE(EndDate, StartDate)) AS Duration
            FROM Campaign
            ORDER BY Duration DESC;
            """
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Campaign ID: {row[0]}, Name: {row[1]}, Duration: {row[2]} days")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")


def query9(cursor):
    query = """
            SELECT MemberID, COUNT(*) AS NumOfCampaigns
            FROM WorksOn
            GROUP BY MemberID
            ORDER BY NumOfCampaigns DESC;
            """
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Member ID: {row[0]}, Number of Campaigns: {row[1]}")
    
    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query10(cursor):
    query = """
            SELECT MemberID, SUM(Amount) AS TotalDonated
            FROM Donations
            GROUP BY MemberID
            ORDER BY TotalDonated DESC
            LIMIT 3;
            """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Member ID: {row[0]}, Total Donated: {row[1]:.2f}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def query11(cursor):
    query = """
            SELECT c.CampaignID, c.Name
            FROM Campaign c
            WHERE EXISTS (
                SELECT 1
                FROM Donations d
                WHERE d.CampaignID = c.CampaignID AND d.Amount >= 1250
            );
            """
    
    try:
        cursor.execute(query)
        rows = cursor.fetchall()
        for row in rows:
            print(f"Campaign ID: {row[0]}, Campaign Name: {row[1]}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to execute query")

def run_query(selection, cursor, queries):

    print(f"Running {selection}... \n{queries[selection]}\n\n")

    if selection == 1:
        query1(cursor)

    elif selection == 2:
        query2(cursor)

    elif selection == 3:
        query3(cursor)

    elif selection == 4:
        query4(cursor)

    elif selection == 5:
        query5(cursor)

    elif selection == 6:
        query6(cursor)

    elif selection == 7:
        query7(cursor)

    elif selection == 8:
        query8(cursor)

    elif selection == 9:
        query9(cursor)

    elif selection == 10:
        query10(cursor)

    elif selection == 11:
        query11(cursor)

def query_menu(cursor):

    queries = {
        0: "Exit.",
        1: "Total amount spent per campaign",
        2: "Total number of events per campaign",
        3: "Average number of events hosted by campaigns",
        4: "Number of campaigns that have events",
        5: "Campaigns that have total donation amount higher than average of all donations (to all charities)",
        6: "Donations to a charity that are higher than average donations to the charity",
        7: "Which volunteers volunteer for all campaigns",
        8: "Order campaigns by donations",
        9: "Order employees by number of active campaigns",
        10: "Top 3 overall donators",
        11: "Campaigns that have a single donation >= 1250"
    }
    
    print("\nList of queries:")
    for i in queries:
        print(f"{i}. {queries[i]}")

    selection = int(input("\nWhat option are you picking? (enter int):"))
    if selection == 0:
        return
    elif selection <= len(queries):
        run_query(selection, cursor, queries)
    else:
        print("Invalid selection.")

    query_menu(cursor)

def add_new_campaign(cursor):
    print("\nInput new campaign details: ")

    change = 'n'

    while change.lower() != 'y':
        name = input("Name: ")
        focus = input("Focus: ")
        start_date = input("Start Date (YYYY-MM-DD): ")
        end_date = input("End Date (YYYY-MM-DD): ")

        print("\nReview the entered details: ")
        print(f"Name: {name}")
        print(f"Focus: {focus}")
        print(f"Start Date: {start_date}")
        print(f"End Date: {end_date}")

        change = input("\nEnter 'y' to confirm, 'n' to re-enter, 'c' to cancel: ")

        if change.lower() == 'c':
            return
    
    try:
        query = """
                INSERT INTO Campaign (Name, Focus, StartDate, EndDate)
                VALUES (%s, %s, %s, %s) RETURNING CampaignID;
                """
        cursor.execute(query, (name, focus, start_date, end_date))
        campaign_id = cursor.fetchone()[0]
        cursor.connection.commit()
        print(f"New Campaign Added. Campaign ID is {campaign_id}")
    
    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()
        print("Failed to add new campaignn.")


def add_new_volunteer(cursor):
    print("\nInput new volunteer details: ")

    change = 'n'

    while change.lower() != 'y':
        name = input("Name: ")
        email = input("Email: ")
        phone = input("Phone: ")

        print("\nReview the entered details:")
        print(f"Name: {name}")
        print(f"Email: {email}")
        print(f"Phone: {phone}")

        change = input("\nEnter 'y' to confirm, 'n' to re-enter, 'c' to cancel: ")
        
        if change.lower() == 'c':
            return

    try:
        query = """
                INSERT INTO Member (Name, Email, Number)
                VALUES (%s, %s, %s) RETURNING MemberID;
                """
        cursor.execute(query, (name, email, phone))
        member_id = cursor.fetchone()[0]
        cursor.connection.commit()
        print(f"New volunteer added successfully with Member ID: {member_id}")
    
    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()
        print("Failed to add new volunteer.")


    try:
        cursor.execute("""
        INSERT INTO Volunteer (MemberID, NumberOfCampaigns)
        VALUES (%s, %s);
        """, (member_id, 0))
        cursor.connection.commit()
        print(f"Volunteer record created successfully: {member_id}")
        
    except psycopg2.Error as e:
        
        print(f"An error occurred while creating volunteer: {e}")
        cursor.connection.rollback()
        print("Failed to add new volunteer to Volunteer table.")

def schedule_event(cursor):
    print("\nSchedule event for campaign")

    change = 'n'
    while change.lower() != 'y':

        event_name = input("Name: ")
        event_date = input("Date (YYYY-MM-DD): ")
        event_location = input("Location: ")
        campaign_id = input("Campaign ID: ")

        print("\nReview the entered details:")
        print(f"Name: {event_name}")
        print(f"Date: {event_date}")
        print(f"Location: {event_location}")
        print(f"Campaign ID: {campaign_id}")

        change = input("\nenter 'y' to confirm, 'n' to re-enter, 'c' to cancel: ")
        if change.lower() == 'c':
            return

    try:
        query = """
                INSERT INTO Event (Name, Date, Location, CampaignID)
                VALUES (%s, %s, %s, %s);
                """
        cursor.execute(query, (event_name, event_date, event_location, campaign_id))
        cursor.connection.commit()
        print(f"Event '{event_name}' successfully scheduled.")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()
        print("Failed to schedule the event. ")

def add_volunteer_campaign(cursor):
    print("\nLink a Volunteer with a Campaign")

    change = 'n'

    while change.lower() != 'y':
        volunteer_id = input("Volunteer ID: ")
        campaign_id = input("Campaign ID: ")

        print("\nReview the entered details:")
        print(f"Volunteer ID: {volunteer_id}")
        print(f"Campaign ID: {campaign_id}")

        change = input("\nEnter 'y' to confirm, 'n' to re-enter, 'c' to cancel: ")
        if change.lower() == 'c':
            return

    try:
        query = """
                INSERT INTO VolsFor (MemberID, CampaignID)
                VALUES (%s, %s);
                """
        cursor.execute(query, (volunteer_id, campaign_id))
        cursor.connection.commit()
        print(f"Volunteer ID {volunteer_id} successfully linked to Campaign ID {campaign_id}.")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()
        print("Failed to link the volunteer. ")

def view_state_of_campaign(cursor):
    
    change = 'n'

    while change.lower() != 'y':
        campaign_id = input("\nEnter the Campaign ID to view details: ")

        print("\nReview the entered details:")
        print(f"Campaign ID: {campaign_id}")

        change = input("\nEnter 'y' to confirm, 'n' to re-enter, 'c' to cancel: ")
        if change.lower() == 'c':
            return

    try:

        cursor.execute("SELECT * FROM Campaign WHERE CampaignID = %s;", (campaign_id,))
        campaign = cursor.fetchone()
        print("\nCampaign details:")
        print(f"Name: {campaign[1]}, Focus: {campaign[2]}, Start Date: {campaign[3]}, End Date: {campaign[4]}")

        cursor.execute("SELECT Name, Date, Location FROM Event WHERE CampaignID = %s;", (campaign_id,))
        events = cursor.fetchall()
        print("\nEvents:")
        for event in events:
            print(f"{event[0]} on {event[1]} at {event[2]}")

        cursor.execute("SELECT Member.Name FROM Member JOIN VolsFor ON Member.MemberID = VolsFor.MemberID WHERE VolsFor.CampaignID = %s;", (campaign_id,))
        volunteers = cursor.fetchall()
        print("\nVolunteers:")
        for volunteer in volunteers:
            print(volunteer[0])

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to retrieve campaign details. ")

def edit_menu(cursor):
    print("\nChoices to edit database: ")
    print("0. Exit")
    print("1. Add New Campaign")
    print("2. Add New Volunteer")
    print("3. Schedule Event")
    print("4. Assign Volunteers to Campaign")
    print("5. View Campaign Details")

    selection = int(input("\nSelect an option: "))

    if selection == 0:
        return
    
    elif selection == 1:
        add_new_campaign(cursor)

    elif selection == 2:
        add_new_volunteer(cursor)

    elif selection == 3:
        schedule_event(cursor)

    elif selection == 4:
        add_volunteer_campaign(cursor)
    
    elif selection == 5:
        view_state_of_campaign(cursor)
    
    else:
        print("Undefined input")

    edit_menu(cursor)

def financial_report(cursor, visual):
    print("\nNumerical Report")
    
    try:
        cursor.execute("""
            SELECT 
                COALESCE(d.CampaignID, e.CampaignID) AS CampaignID, 
                COALESCE(d.TotalDonations, 0) AS TotalDonations, 
                COALESCE(e.TotalExpenses, 0) AS TotalExpenses
            FROM 
                (SELECT CampaignID, SUM(Amount) AS TotalDonations FROM Donations GROUP BY CampaignID) d
            FULL OUTER JOIN 
                (SELECT CampaignID, SUM(Amount) AS TotalExpenses FROM Expenses GROUP BY CampaignID) e
            ON d.CampaignID = e.CampaignID
            ORDER BY COALESCE(d.CampaignID, e.CampaignID);
        """)

        results = cursor.fetchall()

        print("\nCampaign Financials:")
        for result in results:
            campaign_id, total_donations, total_expenses = result
            net = total_donations - total_expenses
            print(f"\nCampaign ID: {campaign_id}")

            if visual == 1:
                
                max_length = 80
                scale = max_length / max(total_donations, total_expenses, 1)
                donation_bar = '[]' * int(total_donations * scale)
                expense_bar = '[]' * int(total_expenses * scale)

                print(f"  Donations: ${total_donations:,.2f}")
                print(f"  [{donation_bar}]")
                print(f"  Expenses: ${total_expenses:,.2f}")
                print(f"  [{expense_bar}]")
                print(f"  Net: ${net:,.2f}")

            else:

                print(f"  Total Donations: ${total_donations:,.2f}")
                print(f"  Total Expenses: ${total_expenses:,.2f}")
                print(f"  Net: ${net:,.2f}")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Unable to retrieve financial data. ")


def financial_menu(cursor):
    print("\nFinances: ")
    print("0. Exit")
    print("1. Numerical Report")
    print("2. Visual Report")

    selection = int(input("\nSelect an option: "))

    if selection == 0:
        return
    
    elif selection == 1:
        financial_report(cursor, 0)
    
    elif selection == 2:
        financial_report(cursor, 1)
    
    else:
        print("Undefined input")
    
    financial_menu(cursor)

def view_member_history(cursor):

    change = 'n'

    while change.lower() != 'y':
        member_id = input("Enter the Member ID to view history: ")

        print("\nReview the entered details: ")
        print(f"Member ID: {member_id}")

        change = input("\nEnter 'y' to confirm, 'n' to re-enter, 'c' to cancel: ")
        if change.lower() == 'c':
            return


    try:
        
        cursor.execute("""
            SELECT m.Name, c.Name, c.StartDate, c.EndDate
            FROM Member m
            JOIN VolsFor v ON m.MemberID = v.MemberID
            JOIN Campaign c ON v.CampaignID = c.CampaignID
            WHERE m.MemberID = %s;
        """, (member_id,))
        history = cursor.fetchall()
        
        print(f"\nMember history of member {member_id}:")

        if history:
            for item in history:
                member_name, campaign_name, start_date, end_date = item
                print(f"- {campaign_name} (from {start_date} to {end_date})")

        else:
            print("No campaign participation found.")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to retrieve member history")

def add_annotation(cursor):
    choice = input("Annotate a member or a campaign  ? [m/c]: ")

    if choice.lower() == 'm':
        member_id = input("Enter Member ID to annotate: ")
        note = input("Enter your annotation: ")
        table_name = 'Member'
        id_field = 'MemberID'
        id_value = member_id

    elif choice.lower() == 'c':
        campaign_id = input("Enter Campaign ID to annotate: ")
        note = input("Enter your annotation: ")
        table_name = 'Campaign'
        id_field = 'CampaignID'
        id_value = campaign_id

    else:
        print("Invalid option selected.")
        return

    try:
        cursor.execute(f"""
            INSERT INTO Annotations (TableReferenced, RecordID, Note)
            VALUES (%s, %s, %s);
        """, (table_name, id_value, note))
        cursor.connection.commit()
        print(f"Annotation added to {table_name} ID {id_value}.")
        
    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()
        print("Failed to add annotation.")

def view_annotations(cursor):
    choice_type = input("Would you like to view Member or Campaign annotation: ").capitalize()

    if choice_type not in ['Member', 'Campaign']:
        print("Invalid entity type. Please choose 'Member' or 'Campaign'.")
        return
    
    choice_id = input(f"Enter the {choice_type} ID to view annotations: ")

    try:
        query = """
                SELECT AnnotationID, Note, DateAdded
                FROM Annotations
                WHERE TableReferenced = %s AND RecordID = %s;
                """
        cursor.execute(query, (choice_type, choice_id))
        annotations = cursor.fetchall()
        
        if annotations:
            print(f"\nAnnotations for {choice_type} ID {choice_id}:")
            for annotation in annotations:
                print(f"Annotation ID: {annotation[0]}, Note: {annotation[1]}, Date Added: {annotation[2]}")
        else:
            print(f"No annotations found for {choice_type} ID {choice_id}.")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        print("Failed to retrieve annotations.")


def membership_menu(cursor):
    print("\nMembership: ")
    print("0. Exit")
    print("1. Annotate")
    print("2. Print history")
    print("3. View history")

    selection = int(input("\nSelect an option: "))

    if selection == 0:
        return
    
    elif selection == 1:
        add_annotation(cursor)
    
    elif selection == 2:
        view_member_history(cursor)

    elif selection == 3:
        view_annotations(cursor)
    
    else:
        print("Undefined input")
    
    membership_menu(cursor)

def add_expense(cursor):

    campaign_id = input("Enter Campaign ID for the expense: ")
    amount = float(input("Enter the expense amount: "))
    description = input("Enter a brief description of the expense: ")

    try:
        cursor.execute("""
            INSERT INTO Finances (Amount, Date) VALUES (%s, CURRENT_DATE) RETURNING FinanceID;
        """, (amount,))
        finance_id = cursor.fetchone()[0]
        cursor.connection.commit()
        
        cursor.execute("""
            INSERT INTO Expenses (CampaignID, Amount, Description, FinanceID, Date)
            VALUES (%s, %s, %s, %s, CURRENT_DATE);
        """, (campaign_id, amount, description, finance_id))
        cursor.connection.commit()
        print(f"Expense added successfully finance id {finance_id} used for this transaction")
    

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()

def update_expense(cursor):

    finance_id = input("Enter the Finance ID to update: ")
    new_amount = float(input("Enter the new expense amount: "))
    new_description = input("Enter the new description of the expense: ")

    try:
        cursor.execute("""
            UPDATE Expenses
            SET Amount = %s, Description = %s
            WHERE FinanceID = %s;
        """, (new_amount, new_description, finance_id))
        cursor.connection.commit()
        print("Expense updated successfully")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        cursor.connection.rollback()

def view_expense(cursor):
    print("\nExpense Overview")

    try:

        cursor.execute("""
            SELECT CampaignID, SUM(Amount) AS TotalExpenses
            FROM Expenses
            GROUP BY CampaignID;
        """)

        results = cursor.fetchall()

        if results:
            for result in results:
                print(f"Campaign ID{result[0]}, Total Expenses: ${result[1]:,.2f}")
        else:
            print("No expenses recorde")

    except psycopg2.Error as e:
        print(f"An error occurred: {e}")
        return
    
    print()

    try:
        cursor.execute("""
            SELECT FinanceID, CampaignID, Amount, Description, Date
            FROM Expenses
            ORDER BY Date DESC, CampaignID;
        """)
        results = cursor.fetchall()

        if results:
            print("Details of all expenses: ")
            for result in results:
                print(f"  Finance ID: {result[0]}, Campaign ID: {result[1]}, Amount: ${result[2]:,.2f}, Description: '{result[3]}', Date: {result[4]}")
        
        else:
            print("No individual expenses recorded")

    except psycopg2.Error as e:
        print(f"error with getting individual expenses{e}")

def expenses_menu(cursor):
    print("\nExpenses: ")
    print("0. Exit")
    print("1. Add expense")
    print("2. Update expense")
    print("3. View expenses")

    selection = int(input("\nSelect an option: "))

    if selection == 0:
        return
    
    elif selection == 1:
        add_expense(cursor)
    
    elif selection == 2:
        update_expense(cursor)

    elif selection == 3:
        view_expense(cursor)
    
    else:
        print("Undefined input")
    
    expenses_menu(cursor)


def menu(cursor):
    print("\nGnG Database: Chose from the following options.")
    print("0. Exit")
    print("1. Run queries")
    print("2. Edit database")
    print("3. Finances")
    print("4. Membership History & Annotation")
    print("5. Manage expenses")
    
    selection = int(input("Enter your choice number: "))

    if(selection == 0):
        print("exiting")
        return
        
    elif(selection==1):
        query_menu(cursor)
    
    elif(selection==2):
        edit_menu(cursor)

    elif(selection==3):
        financial_menu(cursor)

    elif(selection==4):
        membership_menu(cursor)

    elif(selection==5):
        expenses_menu(cursor)

    else:
        print("Undefined selection")
    
    menu(cursor)


def main():
    dbconn = psycopg2.connect(host='', user='', password='',)
    cursor = dbconn.cursor()
    menu(cursor)
    cursor.close()
    dbconn.close()


if __name__ == "__main__":
    main()
