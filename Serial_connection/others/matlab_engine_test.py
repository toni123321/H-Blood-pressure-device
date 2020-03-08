
import matlab.engine
eng = matlab.engine.connect_matlab('my_engine') 

filename = '20200306-165004.csv'
[output1, output2, output3] = eng.main2(filename,nargout=3)


print("{}/{}".format(int(output1), int(output3)))
