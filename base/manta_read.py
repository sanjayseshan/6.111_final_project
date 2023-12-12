import time
from manta import Manta
m = Manta('manta.yaml') # create manta python instance using yaml

# val3 = 11
# val4 = 9101
#for val3, val4 in [(11,9101), (5,10), (2,100),(25,100),(25,1000),(110,91010), (50,100), (20,1000),(250,1000),(250,10000)]:
x = 0
y = 1
prev_a = 0
count = 0

#   // assign    query_in_real[0] = 5;
#   // assign    query_in_real[1] = 7;
#   // assign    query_in_real[2] = 1;
#   // assign    query_in_real[3] = 1;
#   // assign    query_in_real[5] = 5;
#   // assign    query_in_real[6] = 7;
#   // assign    query_in_real[7] = 1;
#   // assign    query_in_real[8] = 1;
#   logic [15:0] k_in;

#   // assign k_in = 16'd4;

def send_data(v):
    time.sleep(1)
    m.lab8_io_core.val4_out.set(0xFFFFFFFF) # set the value val4_out to be val4
    # m.lab8_io_core.val3_out.set(0) # set the value val3_out to be val3
    # a = m.lab8_io_core.val1_in.get() # read in the output from our divider
    # b = m.lab8_io_core.val2_in.get()
    time.sleep(0.5)
    m.lab8_io_core.val4_out.set(v) # set the value val4_out to be val4
    # m.lab8_io_core.val3_out.set(1) # set the value val3_out to be val3
    # a = m.lab8_io_core.val1_in.get() # read in the output from our divider
    # b = m.lab8_io_core.val2_in.get()
    # m.lab8_io_core.val4_out.set(0xFFFFFFFF) # set the value val4_out to be val4
    # m.lab8_io_core.val3_out.set(0) # set the value val3_out to be val3
    # a = m.lab8_io_core.val1_in.get() # read in the output from our divider
    # b = m.lab8_io_core.val2_in.get()
    # time.sleep(0.5)

send_data(5)
send_data(7)
send_data(1)
send_data(1)
send_data(5)
send_data(7)
send_data(1)
send_data(1)

send_data(4)

send_data(1)


time.sleep(0.01) # wait a little amount...though honestly this is isn't needed since Python is slow.
a = m.lab8_io_core.val1_in.get() # read in the output from our divider
b = m.lab8_io_core.val2_in.get() # read in the output from our divider

while count<10:
    x = not x
    m.lab8_io_core.val3_out.set(x) # set the value val3_out to be val3
    # m.lab8_io_core.val4_out.set(y) # set the value val4_out to be val4
    time.sleep(0.01) # wait a little amount...though honestly this is isn't needed since Python is slow.
    #time.sleep(0.5) # wait a little amount...though honestly this is isn't needed since Python is slow.
    a = m.lab8_io_core.val1_in.get() # read in the output from our divider
    b = m.lab8_io_core.val2_in.get() # read in the output from our divider
    #print(f"Values in were {val3} and {val4} with results {val4}//{val3}={val4//val3} and {val4}%{val3}={val4%val3}.")
    
    if a!=0 and a!=prev_a:
        print(f"Actual results were: {a} and {b}!")
        prev_a = a
        
    if a==prev_a:
        count+=1
    y = 0