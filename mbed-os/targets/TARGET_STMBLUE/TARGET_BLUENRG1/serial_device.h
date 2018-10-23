/*
 * serial_device.h
 *
 *  Created on: 26 gen 2018
 *      Author: Gianluca
 */

#ifndef MBED_OS_TARGETS_TARGET_STMBLUE_TARGET_BLUENRG1_SERIAL_DEVICE_H_
#define MBED_OS_TARGETS_TARGET_STMBLUE_TARGET_BLUENRG1_SERIAL_DEVICE_H_


#include "../Periph_Driver/inc/BlueNRG1_sysCtrl.h"
#include "../Periph_Driver/inc/BlueNRG1_uart.h"

#define DEFAULT_BAUD 115200;

#ifndef BAUDRATE
#define BAUDRATE DEFAULT_BAUD
#endif


#endif /* MBED_OS_TARGETS_TARGET_STMBLUE_TARGET_BLUENRG1_SERIAL_DEVICE_H_ */
