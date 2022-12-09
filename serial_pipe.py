import serial
s = serial.Serial(port="COM7", baudrate=9600)
o = serial.Serial(port="COM6", baudrate=9600)
while(True):
    
    if s.in_waiting > 0:

        # Read data out of the buffer until a carraige return / new line is found
        serialString = s.readline()
        o.write(serialString)

        # Print the contents of the serial data
        try:
            print(serialString.decode("Ascii"),end='')
        except:
            pass