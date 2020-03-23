import serial
import time
import csv
import datetime
import sys
import os
import sqlite3

from signal import signal, SIGINT
from sys import exit

import matlab.engine
from test.test_decimal import file

def get_data_from_device (com_port):
        print("Start measurement now")
        ser = serial.Serial('COM3')
        ser.flushInput()
    
        time_values = []
        pressure_values = []
        
        over_max_pressure_count = 0
    
        i = 0
        while True:
            ser_bytes = ser.readline()
            pressure = float(ser_bytes[:len(ser_bytes)-2].decode("utf-8")) 
            
            time_values.append(time.time())
            pressure_values.append(int(pressure))
            if i == 0:
                start_time = time_values[0]
            
            time_values[i] = int((time_values[i] - start_time) * 10**3)
            if (time_values[i] >= 19685 and pressure_values[i] >= 300) or (pressure_values[i] >= 280 and i>0 and time_values[i] >= 19200):
                break;
            
            i+=1
                    
        return time_values, pressure_values


def save_values (filename, time_values, pressure_values):
    with open(filename + ".csv", "w") as f:
        writer = csv.writer(f,delimiter=",")
        writer.writerow(["Time", "Values"])
        for i in range (len (time_values)-1):
            writer.writerow([time_values[i], pressure_values[i]])     

def create_db ():
    sql_connection = sqlite3.connect ('data.db')
    cur = sql_connection.cursor ()
    cur.execute ('CREATE TABLE History (id INTEGER PRIMARY KEY, date_time DATETIME, systolic_pressure INT, medium_pressure INT, diastolic_pressure INT, pulse INT )')
    sql_connection.commit ()
    
def add_measurement(date_time, sp, mp, dp, pulse):
    sql_connection = sqlite3.connect ('data.db')
    cur = sql_connection.cursor ()
    cur.execute ('INSERT INTO History (date_time, systolic_pressure, medium_pressure, diastolic_pressure, pulse) VALUES ("{}", "{}", "{}", "{}", "{}")'.format (date_time, sp, mp, dp, pulse))
    sql_connection.commit ()
    sql_connection.close ()
    

def list_measurements ():
    sql_connection = sqlite3.connect ('data.db')
    sql_connection.row_factory = sqlite3.Row
    cur = sql_connection.cursor ()
    cur.execute ('SELECT * FROM History')
    all_rows = cur.fetchall ()
    print("Data format")
    print("Datetime -> Systolic pressure/Diastolic pressure, Medium pressure=?, pulse=?\n")
    for row in all_rows:
        print ("{} -> {}/{}, Medium pressure={}, Pulse={}".format(row['date_time'], row['systolic_pressure'], row['medium_pressure'] ,row['diastolic_pressure'], row['pulse']))
    
    sql_connection.close ()
    
def main():
     # start matlab engine
    eng = matlab.engine.connect_matlab('my_engine')
    
    
    if not os.path.isfile ('data.db'): create_db ()
    #get a result from a given file
    if len(sys.argv) == 2:
            if sys.argv[1] == 'history':
                # list values from database
                list_measurements()
                
            else:
                filename = sys.argv[1]
                name = filename
                
                # start matlab function
                [output1, output2, output3, output4] = eng.data_processing(name,nargout=4)
                print("{}/{}, MAP={}, pulse={}".format(int(output1), int(output3), int(output2), int(output4)))
    else:
        time_values, pressure_values = get_data_from_device ('COM3')
        
        filename = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")
        
        save_values ("data", time_values, pressure_values)
        save_values (filename, time_values, pressure_values)
        name = "data.csv"
        
        #invoke matlab function for processing input data
        [output1, output2, output3, output4] = eng.data_processing(name,nargout=4)
        
        date_time = datetime.datetime.now().strftime("%Y/%m/%d-%H:%M:%S")
        
        #add values to database in order to create a history storage with all data
        add_measurement(date_time, int(output1), int(output3), int(output2), int(output4))
        
        #print the current result
        print("{}/{}, MAP={}, pulse={}".format(int(output1), int(output3), int(output2), int(output4)))


if __name__ == '__main__':
    main()
    
