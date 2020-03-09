
import matlab.engine
eng = matlab.engine.connect_matlab('my_engine') 

filename = '20200308-225050.csv'
[output1, output2, output3] = eng.main3(filename,nargout=3)


print("{}/{}".format(int(output1), int(output3)))
