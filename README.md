# Serial peripheral interface (SPI)
SPI is a synchronus serial communication protocol similar to I2C but different in that its full duplex and unlike the UART its synchronus , and this is just my attempt at creating my own version of SPI on the Arty S7 board 
## Conceptual diagram 
![SPI](https://github.com/mahmoudyousry32/SPI/assets/123260720/4265fa6e-8c84-4b12-821a-b4f17ebdad90)
## Signals
### Inputs
**Start** : control signal that initiates transmission.

**dvsr** : this specifes the period of the sclk signal , dvsr is set by default to 16 bits which are used to determine how many clock cycles of the system clock are in half a period sclk the number of clock cycles in half a period of sclk is equal to dvsr + 1 so if dvsr is equal to 2 that means that a half period of sclk will be 3 clock cycles long and a full period will be 6 clock cycles.

**din** : this is the data bits that will be transmitted.

**miso** : master in slave out signal.

**cpha , cpol** : determine the current mode of SPI.

### Outputs
**mosi** : Master out slave in signal.

**sclk** : synchronization clock to synchronize the transmission between the master and the slave its controlled by the master .

**ready** : ready flag to indicate that the master is ready for another transaction.

**done** : done flag which is asserted for one clock cycle after a transactions is completed .

**dout** : the output data receieved by the master from the slave .

## How it works ?
The design mainly consists of FSM and a couple of registers some of them are used for control and others are used for data transactions between the master and slave
1) the start signal is asserted for one clock cycle .
2) on the next clock cycle the FSM transitions and the input data is loaded in the TX_reg and all counters are resetted
3) when observing SPI waveform diagram below we can see that whatever the mode is the data is always transmitted or shifted out on the first half period of the clock and always sampled on the next half period so the WAIT_1 state essentially represents the first half period of the spi clock and at its end the RX_reg samples whatever on the miso line and we transition the WAIT_2 state which represents the 2nd half of the spi clock the amount of time that FSM spends on each state of WAIT_1 and WAIT_2 depends on the dvsr input which dectates the sclk period
4) in the WAIT_2 state after a time equal to (the dvsr input + 1) is spent another data bit is shifted out and the bit_counter is incremented by 1 to indicate that we are done with the sampling or transmission of a bit after that the FSM jumps back to the WAIT_1 state
5) steps 3, 4 are repeated until all 8 bits are transmitted or sampled after that the done flag is asserted for a single clock cycle and the FSM jumps back to the IDLE state 

 ![SPI-bus-timing](https://github.com/mahmoudyousry32/SPI/assets/123260720/e1904134-1077-4564-9792-58a752afbfc7)


### Control registers and flags
we have two flags the **done** and the **ready**.the **done** flag is asserted for one clock cycle after the completion of a transaction whether it was sending of a byte or receiving of a byte while the **ready** flag is asserted in the **IDLE** state only these flags can be used to communicate with a processor they indicate the current status of the SPI controller

for control registers we have the **dvsr_reg** and the **bit_counter** registers . the **bit_counter** register holds the count for the number of bits transmitted or received during a transaction 
**dvsr_reg** is a timer that is used to generate the proper sclk width depending on the dvsr input , if the dvsr input for example is equal to 5 that means that half the period of sclk is equal to 6 clock cycles (5 + 1) and the total period is 12 clock cycles long the **dvsr_reg** keeps count of the number of clock cycles passed 



