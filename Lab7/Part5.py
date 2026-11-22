import mysql.connector
from getpass import getpass

connection = mysql.connector.connect(
    host="localhost",
    user="root",
    password='root',
    database="RLMS"
)

cursor = connection.cursor()
print("Q3:")
#Q3 
lab_name = "Physics Laboratory"

query = """
SELECT E.serialNo, M.commercialName
FROM EquipmentUnit E
JOIN EquipmentModel M ON M.modelId = E.modelId
JOIN Laboratory L ON L.labId = E.labId
WHERE L.name = %s
  AND E.status = 'InService'
"""

cursor.execute(query, (lab_name,))

for serial_no, model_name in cursor:
    print(serial_no, model_name)

print("q4")
#Q4
query = """
SELECT *
from LaboratoryStockSummary
where stockLevel='LOW'
"""

cursor.execute(query)
for row in cursor:
    print(row)

#q5
print("Q5:")
result = cursor.callproc("RestockLab", (1, 1, 10, 0))
connection.commit()
print(result[3])

#Q6
print("Q6:")

try:
    cursor.execute(
        "INSERT INTO Reserves (resId, serialNo) VALUES (%s, %s)",
        (11, "SN-UM6P-001")
    )
except mysql.connector.Error as error:
    connection.rollback()
    print("the error:",error.msg)

cursor.close()

connection.close()