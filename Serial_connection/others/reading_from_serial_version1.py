import serial
import time
import csv
from datetime import datetime


    
ser = serial.Serial('COM3')

ser.flushInput()

i=0
 # time object
#print(now.second)

time_values_epoch = []
new_time_values = []
decoded_pressure_values = []


while True:
    try:
        i+=1
        ser_bytes = ser.readline()
        decoded_bytes = float(ser_bytes[0:len(ser_bytes)-2].decode("utf-8"))
        print(decoded_bytes)
        with open("test_data.csv","a") as f:
            writer = csv.writer(f,delimiter=",")
            writer.writerow([time.time(),decoded_bytes])
            time_values_epoch.append(time.time())
            decoded_pressure_values.append(decoded_bytes)
    except:
        print("Keyboard Interrupt")
        break

new_time_values.append(0) # add the first value, which is zero
print(time_values_epoch[0])
first_value_epoch = time_values_epoch[0]
first_pressure_value = decoded_pressure_values[0]


        
for i in range (0, len(decoded_pressure_values)):
    if i > 0:
        new_time_values.append(abs(first_value_epoch - time_values_epoch[i]))
    with open("new_values2.csv", "a") as f:
        writer = csv.writer(f,delimiter=",")
        if i == 0:
            writer.writerow([new_time_values[0], decoded_pressure_values[i]])
        else:
            writer.writerow([new_time_values[i], decoded_pressure_values[i]])
