/*
 * serial_device.h
 *
 *  Created on: 30 ott 2018
 *      Author: Antonio O.
 */
#ifdef DEVICE_SERIAL

#include "serial_api.h"
#include "serial_device.h"
#include "pin_device.h"
#include "objects.h"


int stdio_uart_inited = 0;// used in platform/mbed_board.c and platform/mbed_retarget.cpp
serial_t stdio_uart;

static uart_irq_handler irq_handler;
static uint32_t serial_irq_ids = 0;

void serial_init(serial_t *obj, PinName tx, PinName rx){

	//GPIO and UART Peripherals clock enable
	SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_UART | CLOCK_PERIPH_GPIO, ENABLE);

	//This statement is valid for both BlueNRG1-2, developed under DK 3.0.0
	//GPIO TX config
	switch(tx){
		case USBTX:
			GPIO_InitUartTxPin8();
			break;
		case IO_5:
			GPIO_InitUartTxPin5();
			break;
		default:
			error("The selected is not UART_TX capable. Choose the correct pin.");
			break;
	}
	//GPIO RX config
	switch(rx){
		case USBRX:
			GPIO_InitUartRxPin11();
			break;
		case IO_4:
			GPIO_InitUartRxPin4();
			break;
		default:
			error("The selected is not UART_RX capable. Choose the correct pin.");
			break;
		}
	/*
	  ------------ USART configuration -------------------
	  - BaudRate = 115200 baud
	  - Word Length = 8 Bits
	  - One Stop Bit
	  - No parity
	  - Hardware flow control disabled (RTS and CTS signals)
	  - Receive and transmit enabled
	 */
	UART_StructInit(&obj->init);
	UART_Init(&obj->init);

	obj->uart = UART_1;

	//obj->init = &UART_InitStructure;
	obj->pin_tx = tx;
	obj->pin_rx = rx;

	/* Interrupt as soon as data is received. */
	UART_RxFifoIrqLevelConfig(FIFO_LEV_1_64);

	/* Enable UART */
	UART_Cmd(ENABLE);

	stdio_uart_inited = 1;
}

void serial_free(serial_t *obj){
	UART_DeInit();
	UART_Cmd(DISABLE);
	SysCtrl_PeripheralClockCmd(CLOCK_PERIPH_UART, DISABLE);
	obj->index_irq = 0;
	obj->init.UART_BaudRate = 0;
	/**
	 * One has to release also the GPIO assigned to the UART. In this case the
	 * GPIO release is not performed since it has been initialized with pull and
	 * high power mode disable.
	 */
}

void serial_baud(serial_t *obj, int baudrate){
	obj->init.UART_BaudRate = baudrate;
	UART_Init(&obj->init);
}

void serial_format(serial_t *obj, int data_bits, SerialParity parity, int stop_bits){
	obj->init.UART_WordLengthTransmit = (uint8_t)data_bits;
	obj->init.UART_WordLengthReceive = (uint8_t)data_bits;
	obj->init.UART_Parity = (uint8_t)parity;
	obj->init.UART_StopBits= (uint8_t)stop_bits;
	UART_Init(&obj->init);
}

void serial_irq_handler(serial_t *obj, uart_irq_handler handler, uint32_t id){
    irq_handler = handler;
    serial_irq_ids = id;
    //obj->index_irq = id;
}

void serial_irq_set(serial_t *obj, SerialIrq irq, uint32_t enable){
	/* NVIC configuration */
	NVIC_InitType NVIC_InitStructure;
	/* Enable the UART Interrupt */
	NVIC_InitStructure.NVIC_IRQChannel = UART_IRQn;
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = LOW_PRIORITY;
	NVIC_InitStructure.NVIC_IRQChannelCmd = enable;
	NVIC_Init(&NVIC_InitStructure);
	//UART_ITConfig(UART_IT_RX, enable);
	if (irq == RxIrq)
		UART_ITConfig(UART_IT_RX, enable);
	else// TxIrq
		UART_ITConfig(UART_IT_TX, enable);
}

int serial_getc(serial_t *obj){
	/* Loop until the UART Receive Data Register is not empty */
	while (UART_GetFlagStatus(UART_FLAG_RXFE) == SET);
	/* Store the received byte in RxBuffer */
	return (int) UART_ReceiveData();
}

void serial_putc(serial_t *obj, int c){
	  /* Wait if TX fifo is full. */
	  while (UART_GetFlagStatus(UART_FLAG_TXFF) == SET);
	  /* send the data */
	  UART_SendData((uint16_t)c);
}

#endif //DEVICE_SERIAL
