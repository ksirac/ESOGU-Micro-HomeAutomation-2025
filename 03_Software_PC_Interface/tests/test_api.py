"""
Smart Home Automation System - API Test Suite

Description:
    Standalone test functions for verifying API communication
    with Board 1 (HVAC) and Board 2 (Curtain) microcontrollers.
"""

import sys
import time
sys.path.insert(0, '..')
from api.smart_home_api import SmartHomeManager


def test_board1_api(port="COM21"):
    """Tests all Board 1 (HVAC) API methods."""
    print("=" * 50)
    print("BOARD 1 (HVAC) API TEST")
    print("=" * 50)

    manager = SmartHomeManager()
    manager.connect(port, "MOCK")

    time.sleep(2)

    print(f"\nTemperature: {manager.indoor_data['temp_int']}.{manager.indoor_data['temp_frac']}°C")
    print(f"Target: {manager.indoor_data['target']}°C")
    print(f"Fan Speed: {manager.indoor_data['fan_speed']} RPS")

    print("\nSetting temperature to 28°C...")
    result = manager.set_desired_temperature(28)
    print(f"Result: {'Success' if result else 'Failed'}")

    manager.disconnect()
    print("\nTest completed.")


def test_board2_api(port="COM23"):
    """Tests all Board 2 (Curtain) API methods."""
    print("=" * 50)
    print("BOARD 2 (CURTAIN) API TEST")
    print("=" * 50)

    manager = SmartHomeManager()
    manager.connect("MOCK", port)

    time.sleep(2)

    print(f"\nOutdoor Temp: {manager.outdoor_data['temp']}°C")
    print(f"Pressure: {manager.outdoor_data['pressure']} hPa")
    print(f"Light: {manager.outdoor_data['lux']} Lux")
    print(f"Curtain: {manager.outdoor_data['curtain']}%")

    print("\nOpening curtain...")
    manager.send_curtain_command("OPEN")
    time.sleep(1)

    print("Setting position to 50%...")
    result = manager.set_curtain_position(50)
    print(f"Result: {'Success' if result else 'Failed'}")

    manager.disconnect()
    print("\nTest completed.")


if __name__ == "__main__":
    print("Smart Home API Test Suite")
    print("-" * 30)
    print("1. Test Board 1 (HVAC)")
    print("2. Test Board 2 (Curtain)")
    print("3. Test Both (MOCK mode)")

    choice = input("\nSelect option: ")

    if choice == "1":
        port = input("Enter Board 1 port (default COM21): ") or "COM21"
        test_board1_api(port)
    elif choice == "2":
        port = input("Enter Board 2 port (default COM23): ") or "COM23"
        test_board2_api(port)
    elif choice == "3":
        test_board1_api("MOCK")
        test_board2_api("MOCK")
    else:
        print("Invalid option.")
