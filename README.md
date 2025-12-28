# ESOGU Microcomputer Term Project

## 🏠 Project Context: Home Automation System
This repository contains the source code and documentation for the Home Automation System project, which consists of two PIC16F877A based boards and a PC interface.

### 🎯 Scope & Responsibilities
*   **Board #1 (Air Conditioner):** Management of AC logic, Timer, Keypad, UART.
*   **Board #2 (Curtain Control):** Management of Curtain Step Motor, LDR, BMP180, UART.
*   **PC Interface:** Central control and monitoring via UART.

## 🛠 Hardware Specifications
| Component | Type | Function |
|-----------|------|----------|
| **MCU** | PIC16F877A | Main Controller (x2) |
| **Sensor (Board 1)** | LM35 | Temperature Sensor |
| **Sensor (Board 2)** | LDR, BMP180 | Light & Pressure Sensors |
| **Actuator** | Heater, Cooler, Step Motor | Output Devices |
| **Input** | Keypad, Potentiometer | User Commands |

## 💻 Software Stack
*   **Firmware:** Assembly Language (MPLAB X IDE v6.25)
*   **PC Interface:** C++ / Python
*   **Simulation:** PICSimLab

## 📂 Directory Structure
*   `01_Firmware_Board1_AC`: Firmware for Air Conditioner Control (Board #1).
*   `02_Firmware_Board2_Curtain`: Firmware for Curtain Control (Board #2).
*   `03_Software_PC_Interface`: PC API and Application code.
*   `04_Simulation`: PICSimLab workspace.
*   `99_Docs`: Datasheets, Diagrams, and Reports.

---
*Created for ESOGU Microcomputer Term Project.*
