import serial
import time

# ------------------------------------------------------------------
# ANA SINIF (BASE CLASS)
# ------------------------------------------------------------------
class HomeAutomationSystemConnection:
    """
    Tum sistemler icin ortak olan baglanti yonetim sinifi.
    R2.3-1 gereksinimine uygun olarak tasarlanmistir.
    """
    def __init__(self):
        self.comPort = "COM1"  # Varsayilan
        self.baudRate = 9600
        self.serial_conn = None

    def setComPort(self, port):
        self.comPort = port

    def setBaudRate(self, rate):
        self.baudRate = rate

    def open(self):
        try:
            self.serial_conn = serial.Serial(self.comPort, self.baudRate, timeout=1)
            # Baglanti kuruldugunda PIC resetlenmemesi icin DTR ayari gerekebilir
            self.serial_conn.dtr = False 
            time.sleep(1) # Baglantinin oturmasi icin bekleme
            return True
        except Exception as e:
            print(f"Baglanti Hatasi ({self.comPort}): {e}")
            return False

    def close(self):
        if self.serial_conn and self.serial_conn.is_open:
            self.serial_conn.close()
            return True
        return False

    def update(self):
        pass  # Alt siniflarda doldurulacak bolum

# ------------------------------------------------------------------
# BOARD #1: KLIMA SISTEMI SINIFI
# ------------------------------------------------------------------
class AirConditionerSystemConnection(HomeAutomationSystemConnection):
    """
    Board #1 (Klima) ile haberlesen sinif.
    R2.1.4 Tablosundaki protokolu uygular.
    """
    def __init__(self):
        super().__init__()
        self.desiredTemperature = 0.0
        self.ambientTemperature = 0.0
        self.fanSpeed = 0

    def update(self):
        if not self.serial_conn or not self.serial_conn.is_open:
            return

        try:
            # 1. Ortam Sicakligi (Tam + Ondalik) 
            self.serial_conn.write(bytes([4])) # High Byte Iste
            amb_int = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            
            self.serial_conn.write(bytes([3])) # Low Byte Iste
            amb_frac = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            
            self.ambientTemperature = amb_int + (amb_frac / 10.0)

            # 2. Istenen Sicaklik (Tam + Ondalik) 
            self.serial_conn.write(bytes([2])) 
            des_int = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            
            self.serial_conn.write(bytes([1])) 
            des_frac = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            
            self.desiredTemperature = des_int + (des_frac / 10.0)

            # 3. Fan Hizi 
            self.serial_conn.write(bytes([5]))
            self.fanSpeed = int.from_bytes(self.serial_conn.read(1), byteorder='big')

        except Exception as e:
            print(f"Klima Veri Okuma Hatasi: {e}")

    def setDesiredTemp(self, temp):
        """Klima sicakligini ayarlar. Protokol: 11xxxxxx (Tam), 10xxxxxx (Ondalik)"""
        if not self.serial_conn or not self.serial_conn.is_open:
            return False
        
        try:
            temp_int = int(temp)
            temp_frac = int(round((temp - temp_int) * 10))

            # High Byte Gonder (11xxxxxx)
            cmd_high = 0xC0 | (temp_int & 0x3F)
            self.serial_conn.write(bytes([cmd_high]))
            time.sleep(0.05)

            # Low Byte Gonder (10xxxxxx)
            cmd_low = 0x80 | (temp_frac & 0x3F)
            self.serial_conn.write(bytes([cmd_low]))
            return True
        except Exception as e:
            print(f"Sicaklik Ayarlama Hatasi: {e}")
            return False

    # Getter Metotlari
    def getAmbientTemp(self): return self.ambientTemperature
    def getFanSpeed(self): return self.fanSpeed
    def getDesiredTemp(self): return self.desiredTemperature

# ------------------------------------------------------------------
# BOARD #2: PERDE KONTROL SISTEMI SINIFI
# ------------------------------------------------------------------
class CurtainControlSystemConnection(HomeAutomationSystemConnection):
    """
    Board #2 (Perde) ile haberlesen sinif.
    R2.2.6-1 Tablosundaki protokolu uygular.
    """
    def __init__(self):
        super().__init__()
        self.curtainStatus = 0.0
        self.outdoorTemperature = 0.0
        self.outdoorPressure = 0.0
        self.lightIntensity = 0.0

    def update(self):
        if not self.serial_conn or not self.serial_conn.is_open:
            return

        try:
            # 1. Perde Durumu (Istenen) 
            self.serial_conn.write(bytes([2]))
            curt_int = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.serial_conn.write(bytes([1]))
            curt_frac = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.curtainStatus = curt_int + (curt_frac / 10.0)

            # 2. Dis Sicaklik 
            self.serial_conn.write(bytes([4]))
            out_temp_int = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.serial_conn.write(bytes([3]))
            out_temp_frac = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.outdoorTemperature = out_temp_int + (out_temp_frac / 10.0)

            # 3. Dis Basinc 
            self.serial_conn.write(bytes([6]))
            press_int = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.serial_conn.write(bytes([5]))
            press_frac = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.outdoorPressure = press_int + (press_frac / 10.0)

            # 4. Isik Siddeti 
            self.serial_conn.write(bytes([8]))
            light_int = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.serial_conn.write(bytes([7]))
            light_frac = int.from_bytes(self.serial_conn.read(1), byteorder='big')
            self.lightIntensity = light_int + (light_frac / 10.0)

        except Exception as e:
            print(f"Perde Sistemi Veri Okuma Hatasi: {e}")

    def setCurtainStatus(self, status):
        """Perde acikligini ayarlar. Protokol: 11xxxxxx (Tam), 10xxxxxx (Ondalik)"""
        if not self.serial_conn or not self.serial_conn.is_open:
            return False
        
        try:
            status_int = int(status)
            status_frac = int(round((status - status_int) * 10))

            # High Byte (11xxxxxx)
            cmd_high = 0xC0 | (status_int & 0x3F)
            self.serial_conn.write(bytes([cmd_high]))
            time.sleep(0.05)

            # Low Byte (10xxxxxx)
            cmd_low = 0x80 | (status_frac & 0x3F)
            self.serial_conn.write(bytes([cmd_low]))
            return True
        except Exception as e:
            print(f"Perde Ayarlama Hatasi: {e}")
            return False

    # Getter Metotlari
    def getOutdoorTemp(self): return self.outdoorTemperature
    def getOutdoorPress(self): return self.outdoorPressure
    def getLightIntensity(self): return self.lightIntensity