import sqlite3
from datetime import datetime

def lambda_handler(event, context):
    # Connect to the SQLite database
    conn = sqlite3.connect('/tmp/employee_database.db')
    c = conn.cursor()

    # Assuming event['action'] determines the Lambda function's operation
    action = event.get('action')

    if action == "get_available_vacation_days":
        employee_id = event.get('employee_id')
        # Fetch available vacation days
        c.execute("SELECT employee_vacation_days_available FROM vacations WHERE employee_id = ? ORDER BY year DESC LIMIT 1", (employee_id,))
        result = c.fetchone()
        available_days = result[0] if result else 0
        return {'employee_id': employee_id, 'available_vacation_days': available_days}

    elif action == "book_vacation":
        employee_id = event.get('employee_id')
        start_date = event.get('start_date')
        end_date = event.get('end_date')
        # Example logic to book vacation
        c.execute("INSERT INTO planned_vacations (employee_id, vacation_start_date, vacation_end_date) VALUES (?, ?, ?)", (employee_id, start_date, end_date))
        conn.commit()
        return {'msg': 'Vacation booked successfully', 'employee_id': employee_id}

    else:
        return {'error': 'Invalid action provided'}

    conn.close()
