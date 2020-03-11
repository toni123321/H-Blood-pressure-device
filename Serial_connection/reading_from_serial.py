import serial
import time
import csv
import datetime
import matplotlib.pyplot as plt
from scipy.signal import butter, lfilter
import sys
import os
import shutil

from signal import signal, SIGINT
from sys import exit

import matlab.engine
from test.test_decimal import file

def get_data_from_device (com_port):
    print("You're now here")
    error = 0
    
    print("Are you here")
    ser = serial.Serial('COM3')
    ser.flushInput()

    time_values = []
    pressure_values = []
    
    over_max_pressure_count = 0

    i = 0
    while True:
        ser_bytes = ser.readline()
        pressure = float(ser_bytes[:len(ser_bytes)-2].decode("utf-8")) 
#                 if pressure > 180:
#                     over_max_pressure_count += 1
#                     if over_max_pressure_count == 10:
#                         break
#                 else:
#                     over_max_pressure_count = 0
        time_values.append(time.time())
        pressure_values.append(int(pressure))
        if i == 0:
            start_time = time_values[0]
        
        time_values[i] = int((time_values[i] - start_time) * 10**3)
        if time_values[i] >= 19685:
            break;
        
        i+=1
    
    
    
#     for i in range (len (time_values)-1):
#         time_values[i] = int((time_values[i] - start_time) * 10**3)            
    return time_values, pressure_values


def save_values (filename, time_values, pressure_values):
    with open(filename + ".csv", "w") as f:
        writer = csv.writer(f,delimiter=",")
        writer.writerow(["Time", "Values"])
        for i in range (len (time_values)-1):
            writer.writerow([time_values[i], pressure_values[i]])     
     
     
#     f = open(filename + ".csv", "w")
#     f.write("Times" + ", " + "Values")
#     for i in range (len (time_values)-1):
#         f.write(str(time_values[i]) +  ", " + str(pressure_values[i]))     
#     os.fsync (f)
#     f.close()
    
    
def plot_values (filename, time_values, pressure_values):
#     time_values = time_values[10:-10]
#     pressure_values = pressure_values[10:-10]
     
    plt.plot(time_values, pressure_values, color='lightblue', linewidth=1)

    fs = 5000
    nyq = 0.5 * fs
    low = 100 / nyq
    high = 500 / nyq
#     b, a = butter(5, [low , high], btype='band')
#     filter_pressure = lfilter(b, a, pressure_values)
#     
#     plt.plot(time_values, filter_pressure, color='red', linewidth=1)

    plt.savefig(filename)
    plt.show()
    

def load_values (filename):
    time_values = []
    pressure_values = []
    
    with open (filename, "r") as f:
        reader = csv.reader(f,delimiter=",")
        next(reader)
        for row in reader:
            if row:
                time_value = int(row[0])            
                pressure_value = int(row[1])
                time_values.append (time_value)
                pressure_values.append (pressure_value)
    
    return time_values, pressure_values


def handler(signal_received, frame):
    # Handle any cleanup here
    print('SIGINT or CTRL-C detected. Exiting gracefully')
    exit(0)
    
def last_file():
    path = 'C:/Users/User/Desktop/Diplomna/others'
    os.chdir(path)
    files = sorted(os.listdir(os.getcwd()), key=os.path.getmtime)
    
    oldest = files[0]
    newest = files[-1]
    return newest
    
    
def main():
    #get a result from a given file
    if len(sys.argv) == 2:
            if sys.argv[1] == 'history':
                # list values from database
                
            else:
                filename = sys.argv[1]
                time_values, pressure_values = load_values (filename)
                
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
        
        
        # start matlab function
        eng = matlab.engine.connect_matlab('my_engine')
        [output1, output2, output3, output4] = eng.data_processing(name,nargout=4)
        print("{}/{}, MAP={}, pulse={}".format(int(output1), int(output3), int(output2), int(output4)))
        
#     
#         
#         #plot_values (filename, time_values, pressure_values)
    #print (time_values, pressure_values)

if __name__ == '__main__':
    main()
    
    
    
