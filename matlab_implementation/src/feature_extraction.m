clear;
clc;
clf;

% --- MATLAB ÖZNİTELİK ÇIKARIMI (FEATURE EXTRACTION) ---
% Bu script 'src' klasöründe çalıştığı için, iki üst klasöre çıkıp 
% 'data/processed' içindeki çoğaltılmış verileri okuyacak.

clear; clc;

% 1. Veri Yollarını Ayarla
veriKlasoru = '../../data/processed'; 
kayitNoktasi = '../models/extracted_features.mat'; % Çıkan matrisi buraya kaydedeceğiz

disp('Ses dosyaları taranıyor...');

% 2. Klasörleri Otomatik Etiketle (audioDatastore)
% Alt klasör isimlerini (Phrygian, Lydian vb.) doğrudan etiket (Label) yapar.
ads = audioDatastore(veriKlasoru, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

% 3. Boş Matrisleri Başlat
features = [];
labels = [];

disp('Matrisler hesaplanıyor, bu işlem veri sayısına göre birkaç dakika sürebilir...');

% 4. Tüm Seslerin Üzerinden Geç (Döngü)
while hasdata(ads)
    [audioIn, info] = read(ads);
    fs = info.SampleRate; 
    
    % Sesi mono yap
    if size(audioIn, 2) > 1
        audioIn = mean(audioIn, 2);
    end
    
    % --- FEATURE 1: MFCC (Sesin Rengi/Tınısı) ---
    % 13 katsayılık tını özeti çıkarır.
    [coeffs, ~] = mfcc(audioIn, fs);
    mfccFeature = mean(coeffs, 1); % Zaman eksenini çökertip ortalamayı al
    
    % --- FEATURE 2: CHROMAGRAM (12 Notalık Gam Enerjisi) ---
    % Hangi notaların basıldığının harmonik haritası.
    [chroma, ~] = chromagram(audioIn, fs);
    chromaFeature = mean(chroma, 2)'; % Zamanı çökert, satır vektörüne çevir (Transpose)
    
    % İki özelliği birleştirip devasa tek bir satır (row vector) yap
    combinedFeature = [mfccFeature, chromaFeature];
    
    % Ana matrise ve etiket listesine ekle
    features = [features; combinedFeature];
    labels = [labels; info.Label];
end

% 5. Modeli Besleyeceğimiz Tabloyu Oluştur
featureTable = array2table(features);
featureTable.Label = labels;

% 6. Modeller Klasörüne Kaydet
% Eğer 'models' klasörü yoksa oluştur
if ~exist('../models', 'dir')
    mkdir('../models');
end

save(kayitNoktasi, 'featureTable');
disp(['İşlem Tamam! Özellik tablosu başarıyla kaydedildi: ', kayitNoktasi]);