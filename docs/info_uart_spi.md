<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works
- This is a combined module with working UART and SPI protocols.
- Here both the cores are loopedback. Just for testing purpose of different communication speeds.
- The loopback: received data is stored into a register inside and the same register is read back during transmission.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

- UART:
- UART is 8-bit with one start and one stop bit.
- The pins used for UART:
clk,
reset,  (ACTIVE LOW)
freq_control,
uart_rx_d_in,
uart_tx_start,
uart_tx_d_out,
uart_rx_valid,
uart_tx_ready

- The clk and reset signals are derived from the chip clk and reset source pins.
- The main feature is the frequency control pin freq_control. This has two pins which can be selected in 00, 01, 10, 11 combination. To control
the Baud rate of the UART communication. 00 -> 9600 baud, 01 -> 115200 baud, 10 -> 1,000,000 (1M) baud,  11 -> 4,000,000 (4M) baud
- The uart_rx_d_in pin is for receiving the uart data into the chip. This line is held high when there is no
data transfer. If there is data the start bit pulls it down there by starting the receiving. Hence there is 
no explicit uart_rx_start pin used.
- uart_rx_valid is to indicate that the received rx data is complete.
- uart_tx_start is an user input to make the chip transmit the data inside.
- uart_tx_ready is a signal to indicate that the uart module is ready for the next data to be transmitted.

++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

- SPI:
- SPI is the usual synchronous transfer protocol.
- Here the SPI tranfer is for 16-bit.

The pins used for SPI:
clk,
reset,	(ACTIVE LOW)
sclk,
mosi,
miso,
cs_bar, (ACTIVE HIGH)
spi_start,
spi_rx_valid,
spi_tx_done

- It has 4 initeracting pins, SCLK, MISO, MOSI and CS_BAR. The usual from the SPI standard.
- The SCLK is an user input which will decide the communication speed of the protocol.
- spi_start is to be used for initiating the SPI communication.
- spi_rx_valid is a flag which gives an output either 1/0 based on if the data was received or not.
- Similarly there is spi_tx_done which indicated if the transmission from the module was done.

- The clk and reset signals are derived from the chip clk and reset source pins.

## How to test

- UART Test:
- Apply the clk and reset (ACTIVE LOW) from the board.
- Give the serial data to the uart pin based on the frequency selection pins (00, 01, 10, 11).
- For transmitting the data back from the chip enable the uart_tx_start.
- Can monitor the signals uart_rx_valid and uart_tx_done to see if the operations are completed successfully.

- SPI Test:
- Apply the clk and reset (ACTIVE HIGH) from the board.
- cs_bar is an active high signal. Once this is pulled HIGH the chip is selected for transmission.
- Apply spi_start signal to begin the transmit and receive. As its synchronous both data is received and transmitted at the same time. The transmitted
data would be from the previous data stored in the register. The new data will only be sent in the next clock cycle.
- Based on the sclk frequency the SPI communication speed is determined. This can be 1MHz, 5MHz, 10MHz, 25MHz, 40MHz and max 50MHz. The clk on
board has maximum clock frequency of 66MHz (As of Efabless board Mar'12'25).
- spi_rx_valid and spi_tx_done indicate the communication success signals.


## External hardware

- USB-UART bridge to interface to computer and control with a C++/Python program. (for 1M and 4M buad rates, special bridges have to be chosen)
- USB-SPI bridge.
- Any other uC, uP or FPGA with UART and SPI communication protocols that can interact with this module.  (for 1M and 4M buad rates, special 
bridges have to be chosen, or IP should be used).
