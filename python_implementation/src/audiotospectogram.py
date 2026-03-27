import os
import librosa
import librosa.display
import matplotlib.pyplot as plt
import numpy as np

# Klasör yolları (Senin repo yapına göre ayarlı)
INPUT_DIR = "Desktop/SonicID_Matlab/data/processed" # MATLAB'in doğradığı wav'lar
OUTPUT_DIR = "Desktop/SonicID_Matlab/data/spectrogram_images"

def save_spectrogram(audio_path, save_path):
    y, sr = librosa.load(audio_path, sr=None)
    
    # Mel-Spektrogram hesapla
    # Bu aslında sesin frekans-zaman grafiğidir
    S = librosa.feature.melspectrogram(y=y, sr=sr, n_mels=128)
    S_dB = librosa.power_to_db(S, ref=np.max)
    
    # Görsel olarak kaydet (Eksenler ve beyaz boşluklar olmadan)
    plt.figure(figsize=(3, 3))
    librosa.display.specshow(S_dB, sr=sr)
    plt.axis('off')
    plt.savefig(save_path, bbox_inches='tight', pad_inches=0)
    plt.close()

# Klasörleri tara ve resimleri oluştur
if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)

for mod in ['Phrygian', 'Lydian', 'Mixolydian', 'Dorian']:
    mod_path = os.path.join(INPUT_DIR, mod)
    save_mod_path = os.path.join(OUTPUT_DIR, mod)
    os.makedirs(save_mod_path, exist_ok=True)
    
    print(f"{mod} spektrogramları oluşturuluyor...")
    for file in os.listdir(mod_path):
        if file.endswith('.wav'):
            input_file = os.path.join(mod_path, file)
            output_file = os.path.join(save_mod_path, file.replace('.wav', '.png'))
            save_spectrogram(input_file, output_file)

print("İşlem tamam! Tüm sesler resme dönüştürüldü.")