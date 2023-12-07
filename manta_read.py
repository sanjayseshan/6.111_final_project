import time
from manta import Manta
m = Manta('base/manta.yaml') # create manta python instance using yaml

# val3 = 11
# val4 = 9101
#for val3, val4 in [(11,9101), (5,10), (2,100),(25,100),(25,1000),(110,91010), (50,100), (20,1000),(250,1000),(250,10000)]:
while True:
    m.lab8_io_core.val3_out.set(0) # set the value val3_out to be val3
    m.lab8_io_core.val4_out.set(0) # set the value val4_out to be val4
    # time.sleep(0.01) # wait a little amount...though honestly this is isn't needed since Python is slow.
    # time.sleep(0.5) # wait a little amount...though honestly this is isn't needed since Python is slow.
    a = m.lab8_io_core.val1_in.get() # read in the output from our divider
    b = m.lab8_io_core.val2_in.get() # read in the output from our divider
    #print(f"Values in were {val3} and {val4} with results {val4}//{val3}={val4//val3} and {val4}%{val3}={val4%val3}.")
    print(f"Actual results were: {a} and {b}!")
