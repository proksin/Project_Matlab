clc;
clf;
% 1. SES DOSYASINI OKU VE HAZIRLA
dosyaYolu = 'ses.wav'; % Klasördeki test sesinin adı
[audioIn, fs] = audioread(dosyaYolu);

if size(audioIn, 2) > 1
    audioIn = mean(audioIn, 2); % Stereo ise mono yap
end

% 2. SPEKTROGRAM (STFT - Kısa Zamanlı Fourier Dönüşümü)
% Sesi frekanslarına parçalıyoruz. Çözünürlük için büyük pencere seçtik.
pencere = 4096; 
cakisma = 2048;
[S, f, t] = spectrogram(audioIn, pencere, cakisma, pencere, fs);
guc_spektrumu = abs(S); % Karmaşık sayılardan genliğe (enerjiye) geçiş

% 3. MANUEL CHROMAGRAM ALGORİTMASI (Projenin Kalbi)
% Zaman x 12 Notalık boş bir matris oluşturuyoruz
chroma_matrisi = zeros(12, length(t));

% Her bir frekansın üzerinden geçiyoruz (0 Hz'i atlayarak)
for i = 2:length(f) 
    frekans = f(i);
    
    % MATEMATİKSEL İŞLEM 1: Frekansı MIDI notasına çevir (Logaritmik Dönüşüm)
    % A4 = 440 Hz referans alınarak frekanslar notalara (69 = A) dönüştürülür.
    midi_nota = round(12 * log2(frekans / 440) + 69);
    
    % Sadece mantıklı müzikal frekans aralığını (Örn: MIDI 20 ile 100) al
    if midi_nota >= 20 && midi_nota <= 100
        
        % MATEMATİKSEL İŞLEM 2: Oktavları yok say ve 12 Temel Notaya indirge
        % Modülüs (mod 12) işlemi ile C=1, C#=2... B=12 olacak şekilde sınırla.
        chroma_sinifi = mod(midi_nota, 12) + 1; 
        
        % O frekanstaki enerjiyi, ilgili notanın satırına ekle
        chroma_matrisi(chroma_sinifi, :) = chroma_matrisi(chroma_sinifi, :) + guc_spektrumu(i, :);
    end
end

% Görselliği netleştirmek için matristeki değerleri 0-1 arasına normalize et
chroma_matrisi = chroma_matrisi ./ max(chroma_matrisi(:));

% 4. ISI HARİTASINI ÇİZDİR (Şov Kısmı)
figure('Name', 'Manuel Chromagram Çizimi', 'Color', 'w');
imagesc(t, 1:12, chroma_matrisi);
axis xy;
colormap('jet');
colorbar;

% Eksenleri Müzikal Formata Getir
title('Matematiksel Müzik Gamı Isı Haritası', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('Zaman (Saniye)', 'FontSize', 12);
ylabel('Notalar (C = 1, B = 12)', 'FontSize', 12);
yticks(1:12);
yticklabels({'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'});