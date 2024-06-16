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


