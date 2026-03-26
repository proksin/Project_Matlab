clc;
clf;

% --- MATLAB OTOMATİK VERİ DOĞRAMA VE ÇOĞALTMA KODU ---

% 1. Klasör Yolları (Bu klasörleri scripti çalıştırdığın yere açmalısın)
girdiKlasoru = 'AudioDataset'; 
cikisKlasoru = 'ProcessedAudio'; 

% Üzerinde çalışacağımız 4 mod (Klasör isimleri tam böyle olmalı)
modlar = {'Phrygian', 'Lydian', 'Mixolydian', 'Dorian'};

chunkSuresi = 3.0; % 3'er saniyelik parçalar

disp('Veriler doğranıyor ve çoğaltılıyor, lütfen bekleyin...');

% 2. Her bir mod klasörüne tek tek gir
for m = 1:length(modlar)
    modAdi = modlar{m};
    modGirdiYolu = fullfile(girdiKlasoru, modAdi);
    modCikisYolu = fullfile(cikisKlasoru, modAdi);
    
    % İşlenmiş sesler için çıkış klasörü yoksa oluştur
    if ~exist(modCikisYolu, 'dir')
        mkdir(modCikisYolu);
    end
    
    % Klasördeki tüm .wav dosyalarını bul
    sesDosyalari = dir(fullfile(modGirdiYolu, '*.wav'));
    
    for d = 1:length(sesDosyalari)
        dosyaAdi = sesDosyalari(d).name;
        [y, fs] = audioread(fullfile(modGirdiYolu, dosyaAdi));
        
        % Matris boyutları uyuşsun diye stereoyu monoya indirge
        if size(y, 2) > 1
            y = mean(y, 2);
        end
        
        % 3 saniyenin kaç 'örnek' (sample) ettiğini bul (Örn: 3 x 44100)
        ornekSayisi = round(chunkSuresi * fs);
        toplamChunk = floor(length(y) / ornekSayisi);
        
        % Sesi 3 saniyelik pencerelere böl (Sliding Window)
        for i = 1:toplamChunk
            baslangic = (i-1) * ornekSayisi + 1;
            bitis = i * ornekSayisi;
            chunk = y(baslangic:bitis); % Vektörü/Matrisi kes
            
            % İsimlendirme şablonunu ayarla
            [~, hamIsim, ~] = fileparts(dosyaAdi);
            yeniIsim = sprintf('%s_chunk%d', hamIsim, i);
            
            % --- 1. ORİJİNAL PARÇA (Temiz Kayıt) ---
            audiowrite(fullfile(modCikisYolu, [yeniIsim, '_orj.wav']), chunk, fs);
            
            % --- 2. KİRLETME 1: BEYAZ GÜRÜLTÜ (White Noise) ---
            % Orijinal sinyalin gücünün çok ufak bir yüzdesi kadar rastgele gürültü ekle
            gurultu = 0.005 * randn(size(chunk));
            chunk_noise = chunk + gurultu;
            audiowrite(fullfile(modCikisYolu, [yeniIsim, '_noise.wav']), chunk_noise, fs);
            
            % --- 3. KİRLETME 2: HIZLANDIRMA (Time Stretching) ---
            % Pitch'i (notaları) bozmadan sadece tempoyu %15 hızlandırır
            chunk_fast = stretchAudio(chunk, 1.15);
            audiowrite(fullfile(modCikisYolu, [yeniIsim, '_fast.wav']), chunk_fast, fs);
            
            % --- 4. KİRLETME 3: YAVAŞLATMA ---
            % Pitch'i bozmadan tempoyu %15 yavaşlatır
            chunk_slow = stretchAudio(chunk, 0.85);
            audiowrite(fullfile(modCikisYolu, [yeniIsim, '_slow.wav']), chunk_slow, fs);
        end
    end
    fprintf('%s klasörü tamamlandı!\n', modAdi);
end

disp('İşlem bitti! 1 ham veri, 4 farklı veriye dönüştürüldü.');