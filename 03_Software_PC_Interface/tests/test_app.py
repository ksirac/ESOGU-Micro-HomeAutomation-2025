# Dosya adin APImicro.py ise import kismini ona gore duzelt:
# from APImicro import AirConditionerSystemConnection, CurtainControlSystemConnection
from APImicro import AirConditionerSystemConnection, CurtainControlSystemConnection
import time
import os

def ekran_temizle():
    os.system('cls' if os.name == 'nt' else 'clear')

def main():
    # --- AYARLAR ---
    # NOT: com0com gibi bir programla sanal port cifti olusturmalisin (Orn: COM1 <-> COM2)
    # PICSimLab COM1'i kullaniyorsa, buraya COM2 yazmalisin.
    KLIMA_PORT = input("Klima Sistemi Portu (orn: COM2): ")
    PERDE_PORT = input("Perde Sistemi Portu (orn: COM4): ")
    
    # --- NESNELERI OLUSTUR ---
    klima = AirConditionerSystemConnection()
    klima.setComPort(KLIMA_PORT)
    
    perde = CurtainControlSystemConnection()
    perde.setComPort(PERDE_PORT)

    # --- BAGLANTILARI AC ---
    print("\nBaglantilar aciliyor...")
    klima_aktif = klima.open()
    perde_aktif = perde.open()

    if not klima_aktif and not perde_aktif:
        print("Hicbir porta baglanilamadi! Program sonlandiriliyor.")
        return

    while True:
        ekran_temizle()
        print("=== EV OTOMASYON SISTEMI KONTROL PANELI ===")
        
        # --- VERILERI GUNCELLE ---
        if klima_aktif:
            klima.update()
            print(f"\n[KLIMA SISTEMI ({KLIMA_PORT})]")
            print(f"  Ortam Sicakligi : {klima.getAmbientTemp()} C")
            print(f"  Istenen Sicaklik: {klima.getDesiredTemp()} C")
            print(f"  Fan Hizi        : {klima.getFanSpeed()} rps")
        else:
            print("\n[KLIMA SISTEMI] - BAGLI DEGIL")

        if perde_aktif:
            perde.update()
            print(f"\n[PERDE SISTEMI ({PERDE_PORT})]")
            print(f"  Perde Durumu    : %{perde.curtainStatus}")
            print(f"  Dis Sicaklik    : {perde.getOutdoorTemp()} C")
            print(f"  Dis Basinc      : {perde.getOutdoorPress()} hPa")
            print(f"  Isik Siddeti    : {perde.getLightIntensity()} Lux")
        else:
            print("\n[PERDE SISTEMI] - BAGLI DEGIL")

        print("\n-------------------------------------------")
        print("1. Klima Sicakligini Ayarla")
        print("2. Perde Acikligini Ayarla")
        print("3. Verileri Yenile")
        print("4. Cikis")
        
        secim = input("\nSeciminiz: ")

        if secim == '1' and klima_aktif:
            try:
                val = float(input("Yeni Sicaklik Girin (Orn: 24.5): "))
                if klima.setDesiredTemp(val):
                    print("Komut gonderildi!")
                else:
                    print("Hata olustu.")
            except ValueError:
                print("Lutfen gecerli bir sayi girin.")
            time.sleep(1)

        elif secim == '2' and perde_aktif:
            try:
                val = float(input("Yeni Perde Acikligi Girin % (Orn: 50.0): "))
                if perde.setCurtainStatus(val):
                    print("Komut gonderildi!")
                else:
                    print("Hata olustu.")
            except ValueError:
                print("Lutfen gecerli bir sayi girin.")
            time.sleep(1)

        elif secim == '3':
            print("Veriler yenileniyor...")
            time.sleep(0.5)
            
        elif secim == '4':
            print("Cikis yapiliyor...")
            klima.close()
            perde.close()
            break
        
        else:
            print("Gecersiz secim veya bagli olmayan cihaz.")
            time.sleep(1)

if __name__ == "__main__":
    main()