# ESOGU Microcomputer Term Project: Home Automation System

## 📖 Introduction
This project was conducted as part of the **Introduction to Microcomputers (ESOGU)** course. It aims to design and simulate a comprehensive Home Automation System using **PIC16F877A** microcontrollers, Assembly language, and a high-level PC interface.

The system is designed as a distributed network consisting of two independent control units (Climate & Curtain) and a central PC monitoring dashboard, communicating via UART.

### 👥 Project Team
* **Onur Kapancı** (Electrical Electronics Engineering) - Board2 & Documentation
* **Cengizhan Gişi** (Electrical Electronics Engineering) - Board2 & Documentation
* **Ahmet Buğra Dalay** (Computer Engineering) - Board1 & API
* **Kemal Siraç Emiroğlu** (Computer Engineering) - Board1, GUI, GitHub Setup
* **Berat Kuş** (Computer Engineering) - Board1, API Test, System Integration

---

## 🏗 System Architecture

### 1. Board #1: Climate Control System
This board operates as a closed-loop control system for ambient temperature management.
* **Control Logic:** Implements a Finite State Machine (IDLE, HEATING, COOLING).
* **Algorithm:** Uses an **Asymmetric Hysteresis Algorithm** with a 2°C dead band to prevent actuator jittering.
* **User Interface:** Displays data via **7-Segment Displays** (using Time Division Multiplexing - TDM) and accepts input via a 4x4 Matrix Keypad (with Anti-Bounce logic).
* **Sensors:** LM35 (Temperature), Digital Tachometer (Fan Speed via Timer0).

### 2. Board #2: Curtain Control & Environment Monitor
This board manages curtain automation and outdoor environmental monitoring.
* **Control Logic:** Command-response basis via UART.
* **Safety Feature:** **"Night Mode"** automatically closes the curtain when the LDR sensor detects light intensity below 97 Lux.
* **Actuator:** Stepper Motor control with calculated step sequences and speed regulation.
* **Sensors:** LDR (Light), BMP180 (Pressure/Temp - *Simulated fixed values*).
* **Display:** 16x2 LCD Screen.

### 3. PC Interface (API & GUI)
A central control application developed in **Python** using `pyserial` and **PyQt5**.
* **API:** Multithreaded polling mechanism (`SmartHomeManager` class) to handle concurrent communication.
* **GUI:** Tab-based interface for monitoring sensors and controlling targets.
* **Protocol:** Custom Hexadecimal Command Set (e.g., `0x04` for Temp, `0x10` for Open Curtain).

---

## 🛠 Hardware & Software Specifications

| Component | Type | Function |
|-----------|------|----------|
| **MCU** | PIC16F877A | Main Controller (x2) |
| **Sensors** | LM35, LDR, BMP180 | Temperature, Light, Pressure |
| **Actuators** | DC Fan, Heater, Stepper Motor | Climate & Curtain movement |
| **Display** | 7-Segment (x4), LCD 16x2 | User Feedback |
| **Communication** | UART (RS-232) | 9600 Baud Rate, 8N1 |

* **Firmware:** Assembly Language (MPLAB X IDE v6.25)
* **PC App:** Python 3.x, PyQt5, PySerial
* **Simulation:** PICSimLab (Spare Parts: gpboard)

---

## 📂 Firmware Modules Structure

### Board 1 (Climate) - `01_Firmware_Board1_AC`
* `Main.asm`: Core FSM and Hysteresis control logic.
* `Adc.asm`: LM35 sensor driver and fractional data processing.
* `Ui.asm`: 7-Segment Multiplexing (TDM) and Keypad scanning.
* `Uart.asm`: Command parser (Hex header detection).
* `Config.inc`: Hardware Abstraction Layer (Pin definitions).

### Board 2 (Curtain) - `02_Firmware_Board2_Curtain`
* `Main.asm`: System initialization and infinite timer loop.
* `Motor.asm`: Stepper motor step generation and dead-zone logic.
* `Sensors.asm`: ADC (LDR) and I2C bit-banging (BMP180).
* `LCD.asm`: 4-bit mode driver for 16x2 display.
* `Utils.asm`: Accurate delay subroutines.

---

## 💻 PC Interface Commands
The system uses a custom byte-protocol. Below are key examples:

| Target | Command | Hex Code | Description |
|--------|---------|----------|-------------|
| **Board 1** | GET TEMP INT | `0x04` | Request Integer Temp |
| **Board 1** | SET TEMP | `0x20` | Set Target Temp (2-byte) |
| **Board 2** | GET LIGHT | `0x07` | Request LDR Lux Value |
| **Board 2** | CMD AUTO | `0x12` | Enable Auto Mode |
| **Board 2** | CMD CLOSE | `0x11` | Force Close Curtain |

---

## ⚠️ Known Limitations
* **Simulation Integration:** Due to library limitations in PICSimLab, the BMP180 sensor on Board 2 returns fixed reference values (25°C, 1026 hPa) instead of dynamic I2C readings.
* **Arithmetic:** Board 1 uses integer resolution for Target Setpoint and Fan Speed calculations to optimize processing, although the sensor reading supports decimal precision.

---

*Created for ESOGU Electrical-Electronics & Computer Engineering Departments.*
