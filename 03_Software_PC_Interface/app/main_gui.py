#!/usr/bin/env python3
"""
Smart Home Automation System - Graphical User Interface

University: Eskisehir Osmangazi University
Department: Electrical and Electronics Engineering
Project: Smart Home Automation (Term Project)

Description:
    PyQt5-based graphical user interface for the Smart Home Automation System.
    Provides real-time monitoring and control of indoor climate and curtain system.

UI Framework: PyQt5 with Fusion dark theme
"""

import sys
from datetime import datetime
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QTabWidget, QGroupBox, QLabel, QLineEdit, QPushButton,
    QComboBox, QTextEdit, QGridLayout, QMessageBox, QSlider
)
from PyQt5.QtCore import Qt, QTimer

# Import API
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
try:
    from api.smart_home_api import SmartHomeManager
    import serial.tools.list_ports
except ImportError as e:
    print(f"[ERROR] Required modules not found: {e}")
    sys.exit(1)


class HomeAutomationGUI(QMainWindow):
    """Main application window for Smart Home Automation System."""

    def __init__(self):
        super().__init__()
        self.setWindowTitle("ESOGU Smart Home System")
        self.setMinimumSize(800, 650)
        self.setStyleSheet(self._get_stylesheet())

        self.backend = SmartHomeManager()
        self.is_connected = False

        self._setup_ui()
        self._refresh_ports()

        self.refresh_timer = QTimer()
        self.refresh_timer.timeout.connect(self._auto_refresh_ui)
        self.refresh_timer.start(3000)

    def _get_stylesheet(self):
        return """
            QMainWindow { background-color: #2b2b2b; }
            QGroupBox {
                font-weight: bold; border: 2px solid #555; border-radius: 8px;
                margin-top: 10px; padding: 10px; background-color: #3c3c3c; color: #ffffff;
            }
            QGroupBox::title { subcontrol-origin: margin; left: 10px; padding: 0 5px; }
            QLabel { color: #ffffff; font-size: 12px; }
            QLineEdit {
                background-color: #4a4a4a; color: #ffffff; border: 1px solid #666;
                border-radius: 4px; padding: 5px; font-size: 14px; font-weight:bold;
            }
            QPushButton {
                background-color: #0078d4; color: white; border: none; border-radius: 4px;
                padding: 8px 16px; font-weight: bold;
            }
            QPushButton:hover { background-color: #1084d8; }
            QComboBox {
                background-color: #4a4a4a; color: #ffffff; border: 1px solid #666;
                border-radius: 4px; padding: 5px;
            }
            QTextEdit {
                background-color: #1e1e1e; color: #00ff00; font-family: Consolas;
                font-size: 11px; border: 1px solid #555; border-radius: 4px;
            }
            QTabWidget::pane { border: 1px solid #555; background-color: #3c3c3c; }
            QTabBar::tab {
                background-color: #4a4a4a; color: #ffffff; padding: 10px 20px;
                border-top-left-radius: 4px; border-top-right-radius: 4px;
            }
            QTabBar::tab:selected { background-color: #0078d4; }
        """

    def _setup_ui(self):
        central = QWidget()
        self.setCentralWidget(central)
        layout = QVBoxLayout(central)

        # Connection Settings
        settings_group = QGroupBox("CONNECTION SETTINGS")
        settings_layout = QHBoxLayout(settings_group)

        settings_layout.addWidget(QLabel("Board 1 (HVAC):"))
        self.port_b1 = QComboBox()
        self.port_b1.setMinimumWidth(100)
        settings_layout.addWidget(self.port_b1)

        settings_layout.addWidget(QLabel("Board 2 (Curtain):"))
        self.port_b2 = QComboBox()
        self.port_b2.setMinimumWidth(100)
        settings_layout.addWidget(self.port_b2)

        settings_layout.addWidget(QLabel("Baud:"))
        self.baud_combo = QComboBox()
        self.baud_combo.addItems(["9600", "19200", "38400", "115200"])
        settings_layout.addWidget(self.baud_combo)

        self.connect_btn = QPushButton("CONNECT")
        self.connect_btn.clicked.connect(self._toggle_connection)
        settings_layout.addWidget(self.connect_btn)

        refresh_btn = QPushButton("Refresh")
        refresh_btn.clicked.connect(self._refresh_ports)
        settings_layout.addWidget(refresh_btn)

        layout.addWidget(settings_group)

        # Tabs
        self.tabs = QTabWidget()
        self.tabs.addTab(self._create_ac_tab(), "INDOOR (BOARD 1)")
        self.tabs.addTab(self._create_curtain_tab(), "OUTDOOR (BOARD 2)")
        layout.addWidget(self.tabs)

        # Log Panel
        log_group = QGroupBox("SYSTEM LOGS")
        log_layout = QVBoxLayout(log_group)
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        self.log_text.setMaximumHeight(100)
        log_layout.addWidget(self.log_text)
        layout.addWidget(log_group)

    def _create_ac_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)

        data_group = QGroupBox("HVAC STATUS")
        grid = QGridLayout(data_group)

        grid.addWidget(QLabel("Room Temperature:"), 0, 0)
        self.ac_ambient = QLineEdit("--.- °C")
        self.ac_ambient.setReadOnly(True)
        self.ac_ambient.setStyleSheet("color: #00ff00;")
        grid.addWidget(self.ac_ambient, 0, 1)

        grid.addWidget(QLabel("Target Temperature:"), 1, 0)
        self.ac_desired = QLineEdit("--.- °C")
        self.ac_desired.setReadOnly(True)
        self.ac_desired.setStyleSheet("color: #00aaff;")
        grid.addWidget(self.ac_desired, 1, 1)

        grid.addWidget(QLabel("Fan Speed:"), 2, 0)
        self.ac_fan_speed = QLineEdit("-- RPS")
        self.ac_fan_speed.setReadOnly(True)
        self.ac_fan_speed.setStyleSheet("color: #ffaa00;")
        grid.addWidget(self.ac_fan_speed, 2, 1)

        self.ac_status_lbl = QLabel("STATUS: STANDBY")
        self.ac_status_lbl.setStyleSheet("font-size: 16px; font-weight: bold; color: gray;")
        grid.addWidget(self.ac_status_lbl, 3, 0, 1, 2, alignment=Qt.AlignCenter)

        layout.addWidget(data_group)

        ctrl_group = QGroupBox("TEMPERATURE CONTROL")
        ctrl_layout = QHBoxLayout(ctrl_group)

        ctrl_layout.addWidget(QLabel("Target (10-50°C):"))
        self.temp_input = QLineEdit()
        self.temp_input.setPlaceholderText("25")
        self.temp_input.setMaximumWidth(60)
        ctrl_layout.addWidget(self.temp_input)

        btn_set_temp = QPushButton("SET")
        btn_set_temp.clicked.connect(self._set_desired_temp)
        ctrl_layout.addWidget(btn_set_temp)
        ctrl_layout.addStretch()

        layout.addWidget(ctrl_group)
        layout.addStretch()
        return tab

    def _create_curtain_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)

        data_group = QGroupBox("WEATHER & CURTAIN")
        grid = QGridLayout(data_group)

        grid.addWidget(QLabel("Outdoor Temp:"), 0, 0)
        self.curt_temp = QLineEdit("--.- °C")
        self.curt_temp.setReadOnly(True)
        grid.addWidget(self.curt_temp, 0, 1)

        grid.addWidget(QLabel("Pressure:"), 1, 0)
        self.curt_press = QLineEdit("---- hPa")
        self.curt_press.setReadOnly(True)
        grid.addWidget(self.curt_press, 1, 1)

        grid.addWidget(QLabel("Light (LDR):"), 2, 0)
        self.curt_lux = QLineEdit("--- Lux")
        self.curt_lux.setReadOnly(True)
        grid.addWidget(self.curt_lux, 2, 1)

        grid.addWidget(QLabel("Curtain Position:"), 3, 0)
        self.curt_status = QLineEdit("-- %")
        self.curt_status.setReadOnly(True)
        self.curt_status.setStyleSheet("color: #ffaa00;")
        grid.addWidget(self.curt_status, 3, 1)

        layout.addWidget(data_group)

        ctrl_group = QGroupBox("CURTAIN CONTROL")
        btn_layout = QHBoxLayout(ctrl_group)

        btn_open = QPushButton("OPEN")
        btn_open.clicked.connect(lambda: self._send_cmd("OPEN"))
        btn_layout.addWidget(btn_open)

        btn_close = QPushButton("CLOSE")
        btn_close.clicked.connect(lambda: self._send_cmd("CLOSE"))
        btn_layout.addWidget(btn_close)

        btn_auto = QPushButton("AUTO")
        btn_auto.clicked.connect(lambda: self._send_cmd("AUTO"))
        btn_layout.addWidget(btn_auto)

        layout.addWidget(ctrl_group)

        pos_group = QGroupBox("MANUAL POSITION")
        pos_layout = QVBoxLayout(pos_group)

        slider_layout = QHBoxLayout()
        slider_layout.addWidget(QLabel("0%"))
        self.curtain_slider = QSlider(Qt.Horizontal)
        self.curtain_slider.setMinimum(0)
        self.curtain_slider.setMaximum(100)
        self.curtain_slider.setValue(50)
        self.curtain_slider.valueChanged.connect(self._update_slider_label)
        slider_layout.addWidget(self.curtain_slider)
        slider_layout.addWidget(QLabel("100%"))
        pos_layout.addLayout(slider_layout)

        btn_pos_layout = QHBoxLayout()
        self.curtain_pos_label = QLabel("Selected: 50%")
        self.curtain_pos_label.setStyleSheet("font-weight: bold; color: #ffaa00;")
        btn_pos_layout.addWidget(self.curtain_pos_label)
        btn_pos_layout.addStretch()
        btn_set_pos = QPushButton("SET POSITION")
        btn_set_pos.clicked.connect(self._set_curtain_position)
        btn_pos_layout.addWidget(btn_set_pos)
        pos_layout.addLayout(btn_pos_layout)

        layout.addWidget(pos_group)
        layout.addStretch()
        return tab

    def _refresh_ports(self):
        detected = [p.device for p in serial.tools.list_ports.comports()]
        virtual = [f"COM{i}" for i in range(0, 31)]
        all_ports = list(dict.fromkeys(virtual + detected))
        all_ports.append("MOCK")

        self.port_b1.setEditable(True)
        self.port_b2.setEditable(True)
        self.port_b1.clear()
        self.port_b1.addItems(all_ports)
        self.port_b2.clear()
        self.port_b2.addItems(all_ports)

        try:
            self.port_b1.setCurrentText("COM21")
            self.port_b2.setCurrentText("COM23")
        except:
            pass

    def _toggle_connection(self):
        if not self.is_connected:
            p1 = self.port_b1.currentText()
            p2 = self.port_b2.currentText()
            if not p1 or not p2:
                QMessageBox.warning(self, "Error", "Select both ports!")
                return
            baud = int(self.baud_combo.currentText())
            self._log(f"Connecting... B1:{p1}, B2:{p2}, Baud:{baud}")
            self.backend.connect(p1, p2, baud)
            self.is_connected = True
            self.connect_btn.setText("DISCONNECT")
            self.connect_btn.setStyleSheet("background-color: #d32f2f;")
        else:
            self.backend.disconnect()
            self.is_connected = False
            self.connect_btn.setText("CONNECT")
            self.connect_btn.setStyleSheet("background-color: #0078d4;")
            self._log("Disconnected.")

    def _send_cmd(self, cmd):
        if self.is_connected:
            self.backend.send_curtain_command(cmd)
            self._log(f"Command: {cmd}")
        else:
            QMessageBox.warning(self, "Error", "Connect first!")

    def _update_slider_label(self, value):
        self.curtain_pos_label.setText(f"Selected: {value}%")

    def _set_curtain_position(self):
        if not self.is_connected:
            QMessageBox.warning(self, "Error", "Connect first!")
            return
        position = self.curtain_slider.value()
        if self.backend.set_curtain_position(position):
            self._log(f"Position set: {position}%")
        else:
            self._log("Position set failed!")

    def _set_desired_temp(self):
        if not self.is_connected:
            QMessageBox.warning(self, "Error", "Connect first!")
            return
        try:
            temp_val = int(self.temp_input.text())
            if 10 <= temp_val <= 50:
                if self.backend.set_desired_temperature(temp_val):
                    self._log(f"Temperature set: {temp_val}°C")
                    self.temp_input.clear()
                else:
                    self._log("Temperature set failed!")
            else:
                QMessageBox.warning(self, "Error", "Temperature 10-50°C!")
        except ValueError:
            QMessageBox.warning(self, "Error", "Enter valid number!")

    def _auto_refresh_ui(self):
        if not self.is_connected:
            return

        d1 = self.backend.indoor_data
        if d1["connected"]:
            self.ac_ambient.setText(f"{d1['temp_int']}.{d1['temp_frac']} °C")
            self.ac_desired.setText(f"{d1['target']} °C")
            self.ac_fan_speed.setText(f"{d1['fan_speed']} RPS")

            curr = d1['temp_int'] + (d1['temp_frac'] / 10.0)
            target = d1['target']

            if curr < target - 2:
                self.ac_status_lbl.setText("HEATING ACTIVE")
                self.ac_status_lbl.setStyleSheet("color: #ff4444; font-weight: bold;")
            elif curr > target + 2:
                self.ac_status_lbl.setText("COOLING ACTIVE")
                self.ac_status_lbl.setStyleSheet("color: #4444ff; font-weight: bold;")
            else:
                self.ac_status_lbl.setText("TEMPERATURE OPTIMAL")
                self.ac_status_lbl.setStyleSheet("color: #44ff44; font-weight: bold;")

        d2 = self.backend.outdoor_data
        if d2["connected"]:
            self.curt_temp.setText(f"{d2['temp']} °C")
            self.curt_press.setText(f"{d2['pressure']} hPa")
            self.curt_lux.setText(f"{d2['lux']} Lux")
            self.curt_status.setText(f"{d2['curtain']} %")

    def _log(self, msg):
        t = datetime.now().strftime("%H:%M:%S")
        self.log_text.append(f"[{t}] {msg}")


if __name__ == "__main__":
    app = QApplication(sys.argv)
    app.setStyle('Fusion')
    window = HomeAutomationGUI()
    window.show()
    sys.exit(app.exec_())
