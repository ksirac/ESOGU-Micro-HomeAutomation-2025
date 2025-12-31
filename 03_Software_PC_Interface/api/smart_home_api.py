"""
Smart Home Automation System - Communication API Module

University: Eskisehir Osmangazi University
Department: Electrical and Electronics Engineering
Project: Smart Home Automation (Term Project)

Description:
    This module provides the backend communication layer between the GUI
    and the PIC16F877A microcontrollers. It implements a polling-based
    serial protocol for bidirectional data exchange.

Architecture:
    Board 1 (Indoor/AC): Temperature monitoring, fan control, desired temp setting
    Board 2 (Outdoor/Curtain): Light sensor, pressure, curtain position control

Protocol:
    - 9600 baud, 8N1 serial communication
    - Single-byte command codes with optional data bytes
    - 0xAA acknowledgment for successful operations
"""

import serial
import threading
import time
import random


class SmartHomeManager:
    """
    Central manager for smart home device communication.
    Handles concurrent polling of both boards via separate threads.
    """

    def __init__(self):
        self.indoor_ser = None
        self.outdoor_ser = None
        self.running = False
        
        # Thread locks for serial port access
        self.indoor_lock = threading.Lock()
        self.outdoor_lock = threading.Lock()

        # Indoor climate control data store
        self.indoor_data = {
            "temp_int": 0,
            "temp_frac": 0,
            "fan_speed": 0,
            "target": 25,
            "connected": False
        }

        # Outdoor environment and curtain data store
        self.outdoor_data = {
            "temp": 0.0,
            "pressure": 0,
            "lux": 0,
            "curtain": 0,
            "connected": False
        }

    def connect(self, port_indoor, port_outdoor, baud_rate=9600):
        """Establishes serial connections to both boards."""
        self.running = True

        # Board 1 connection (Air Conditioning)
        try:
            if port_indoor != "MOCK":
                self.indoor_ser = serial.Serial(port_indoor, baud_rate, timeout=0.5)
                self.indoor_data["connected"] = True
                threading.Thread(target=self._poll_indoor_board, daemon=True).start()
            else:
                threading.Thread(target=self._mock_indoor_data, daemon=True).start()
        except Exception as e:
            print(f"Board 1 Connection Error: {e}")

        # Board 2 connection (Curtain Control)
        try:
            if port_outdoor != "MOCK":
                self.outdoor_ser = serial.Serial(port_outdoor, baud_rate, timeout=1)
                self.outdoor_data["connected"] = True
                threading.Thread(target=self._poll_outdoor_board, daemon=True).start()
            else:
                threading.Thread(target=self._mock_outdoor_data, daemon=True).start()
        except Exception as e:
            print(f"Board 2 Connection Error: {e}")

    def disconnect(self):
        """Terminates all connections and stops polling threads."""
        self.running = False
        if self.indoor_ser and self.indoor_ser.is_open:
            self.indoor_ser.close()
        if self.outdoor_ser and self.outdoor_ser.is_open:
            self.outdoor_ser.close()
        self.indoor_data["connected"] = False
        self.outdoor_data["connected"] = False

    def _poll_indoor_board(self):
        """Continuously polls Board 1 for sensor data."""
        while self.running:
            try:
                with self.indoor_lock:
                    if not (self.indoor_ser and self.indoor_ser.is_open):
                        time.sleep(0.5)
                        continue
                        
                    self.indoor_ser.reset_input_buffer()

                    # Temperature integer
                    self.indoor_ser.write(b'\x04')
                    time.sleep(0.05)
                    val = self.indoor_ser.read(1)
                    if val:
                        temp_int = int.from_bytes(val, 'big')
                        if 0 <= temp_int <= 50:
                            self.indoor_data["temp_int"] = temp_int

                    self.indoor_ser.reset_input_buffer()

                    # Temperature fraction
                    self.indoor_ser.write(b'\x03')
                    time.sleep(0.05)
                    val = self.indoor_ser.read(1)
                    if val:
                        temp_frac = int.from_bytes(val, 'big')
                        if 0 <= temp_frac <= 9:
                            self.indoor_data["temp_frac"] = temp_frac

                    self.indoor_ser.reset_input_buffer()

                    # Desired temperature
                    self.indoor_ser.write(b'\x06')
                    time.sleep(0.05)
                    val = self.indoor_ser.read(1)
                    if val:
                        target_val = int.from_bytes(val, 'big')
                        if 10 <= target_val <= 50:  # Valid temperature range (°C)
                            self.indoor_data["target"] = target_val

                    self.indoor_ser.reset_input_buffer()

                    # Fan speed
                    self.indoor_ser.write(b'\x05')
                    time.sleep(0.05)
                    val = self.indoor_ser.read(1)
                    if val:
                        fan_val = int.from_bytes(val, 'big')
                        if 0 <= fan_val <= 100:
                            self.indoor_data["fan_speed"] = fan_val

                time.sleep(0.5)
            except Exception as e:
                print(f"Board 1 Read Error: {e}")
                time.sleep(1)

    def _poll_outdoor_board(self):
        """Continuously polls Board 2 for sensor and position data."""
        while self.running:
            try:
                if self.outdoor_ser and self.outdoor_ser.is_open:
                    self.outdoor_ser.reset_input_buffer()

                    # Curtain position
                    self.outdoor_ser.write(b'\x02')
                    time.sleep(0.05)
                    val = self.outdoor_ser.read(1)
                    if val:
                        curtain_val = int.from_bytes(val, 'big')
                        if 0 <= curtain_val <= 100:
                            self.outdoor_data["curtain"] = curtain_val

                    self.outdoor_ser.reset_input_buffer()

                    # Temperature
                    self.outdoor_ser.write(b'\x04')
                    time.sleep(0.05)
                    val = self.outdoor_ser.read(1)
                    if val:
                        temp_val = int.from_bytes(val, 'big')
                        if 0 <= temp_val <= 50:
                            self.outdoor_data["temp"] = float(temp_val)

                    self.outdoor_ser.reset_input_buffer()

                    # Pressure
                    self.outdoor_ser.write(b'\x05')
                    time.sleep(0.05)
                    pres_l = self.outdoor_ser.read(1)

                    self.outdoor_ser.reset_input_buffer()

                    self.outdoor_ser.write(b'\x06')
                    time.sleep(0.05)
                    pres_h = self.outdoor_ser.read(1)

                    if pres_l and pres_h:
                        pressure = int.from_bytes(pres_h, 'big') * 256 + int.from_bytes(pres_l, 'big')
                        self.outdoor_data["pressure"] = pressure if pressure > 0 else 1013

                    self.outdoor_ser.reset_input_buffer()

                    # Light sensor
                    self.outdoor_ser.write(b'\x07')
                    time.sleep(0.05)
                    val = self.outdoor_ser.read(1)
                    if val:
                        self.outdoor_data["lux"] = int.from_bytes(val, 'big')

                time.sleep(0.5)
            except Exception as e:
                print(f"Board 2 Read Error: {e}")
                time.sleep(1)

    def send_curtain_command(self, cmd):
        """Sends curtain control command to Board 2."""
        if self.outdoor_ser and self.outdoor_ser.is_open:
            cmd_map = {"OPEN": b'\x10', "CLOSE": b'\x11', "AUTO": b'\x12'}
            if cmd in cmd_map:
                self.outdoor_ser.write(cmd_map[cmd])
                time.sleep(0.1)
                self.outdoor_ser.read(1)

    def set_curtain_position(self, position):
        """Sets specific curtain position (0-100%)."""
        if self.outdoor_ser and self.outdoor_ser.is_open:
            try:
                position = max(0, min(100, position))
                motor_position = int(position * 2)
                self.outdoor_ser.write(b'\x13')
                time.sleep(0.05)
                self.outdoor_ser.write(bytes([motor_position]))
                time.sleep(0.1)
                response = self.outdoor_ser.read(1)
                return response == b'\xAA'
            except:
                return False
        return False

    def set_desired_temperature(self, temp_value):
        """Sends desired temperature setpoint to Board 1 with retry mechanism."""
        if not (self.indoor_ser and self.indoor_ser.is_open):
            return False
            
        max_retries = 3
        for attempt in range(max_retries):
            try:
                with self.indoor_lock:
                    # Clear buffers for clean communication
                    self.indoor_ser.reset_input_buffer()
                    self.indoor_ser.reset_output_buffer()
                    
                    # Send command byte first
                    self.indoor_ser.write(b'\x20')
                    
                    # Allow firmware to process command and enter receive state
                    time.sleep(0.05)
                    
                    # Now send the temperature value
                    self.indoor_ser.write(bytes([temp_value]))
                    
                    # Allow firmware to validate, store, and respond
                    time.sleep(0.2)
                    
                    response = self.indoor_ser.read(1)
                    if response == b'\xAA':
                        return True
                    elif response == b'\xFF':
                        print(f"Firmware rejected value {temp_value} (out of range)")
                        return False
                        
                # Small delay before retry
                time.sleep(0.1)
            except Exception as e:
                print(f"Set temperature error (attempt {attempt+1}): {e}")
                time.sleep(0.1)
        
        return False

    def _mock_indoor_data(self):
        """Generates simulated indoor sensor data."""
        while self.running:
            self.indoor_data["temp_int"] = 24
            self.indoor_data["temp_frac"] = random.randint(0, 9)
            self.indoor_data["target"] = 25
            self.indoor_data["fan_speed"] = random.randint(30, 100)
            self.indoor_data["connected"] = True
            time.sleep(1)

    def _mock_outdoor_data(self):
        """Generates simulated outdoor sensor data."""
        while self.running:
            self.outdoor_data["temp"] = 28.5
            self.outdoor_data["pressure"] = 1012
            self.outdoor_data["lux"] = random.randint(100, 800)
            self.outdoor_data["curtain"] = random.randint(0, 100)
            self.outdoor_data["connected"] = True
            time.sleep(1)
