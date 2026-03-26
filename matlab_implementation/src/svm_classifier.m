% --- MATLAB SVM (SUPPORT VECTOR MACHINE) SINIFLANDIRICI ---
% Bu script, çıkarılan özellikleri kullanarak Çok Sınıflı SVM modelini eğitir.

clear; clc;

% 1. Özellik Tablosunu (Feature Table) Yükle
kayitNoktasi = '../models/extracted_features.mat';
if ~isfile(kayitNoktasi)
    error('Özellik dosyası bulunamadı! Önce feature_extraction.m dosyasını çalıştırın.');
end

disp('Özellik tablosu yükleniyor...');
load(kayitNoktasi, 'featureTable');

% 2. Veriyi X (Matematik) ve Y (Etiket) Olarak Ayır
% Tablonun son sütunu etiketler (Label), geri kalanı özelliklerdir (Features)
X = featureTable{:, 1:end-1}; 
Y = featureTable.Label;

% 3. Veri Setini Eğitim (%80) ve Test (%20) Olarak Böl
% Modelin ezberlemesini (overfitting) önlemek için daha önce hiç görmediği
% verilerle test etmemiz gerekiyor.
disp('Veri %80 Eğitim ve %20 Test olarak bölünüyor...');
cv = cvpartition(Y, 'HoldOut', 0.2);

X_train = X(training(cv), :);
Y_train = Y(training(cv), :);

X_test = X(test(cv), :);
Y_test = Y(test(cv), :);

% 4. SVM MODELİNİ EĞİT
% 'fitcecoc' çok sınıflı (multi-class) SVM algoritmasıdır.
% 'Standardize', true ile farklı ölçeklerdeki MFCC ve Chroma değerlerini eşitleriz.
disp('SVM Modeli Eğitiliyor, lütfen bekleyin...');
t = templateSVM('Standardize', true, 'KernelFunction', 'polynomial'); 
svmModel = fitcecoc(X_train, Y_train, 'Learners', t);

disp('Eğitim Tamamlandı! Şimdi test verisi üzerinde deneniyor...');

% 5. TEST VE DOĞRULUK (ACCURACY) HESAPLAMA
Y_pred = predict(svmModel, X_test); % Modelin tahminleri
dogruSayisi = sum(Y_pred == Y_test);
toplamTest = length(Y_test);
accuracy = (dogruSayisi / toplamTest) * 100;

fprintf('\n========================================\n');
fprintf('MODEL DOĞRULUĞU (ACCURACY): %.2f%%\n', accuracy);
fprintf('========================================\n\n');

% 6. SUNUM İÇİN ŞOV KISMI: KARMAŞIKLIK MATRİSİ (CONFUSION MATRIX)
figure('Name', 'SVM Sınıflandırma Performansı', 'Color', 'w');
cm = confusionchart(Y_test, Y_pred);
cm.Title = sprintf('SVM Karmaşıklık Matrisi (Doğruluk: %.2f%%)', accuracy);
cm.RowSummary = 'row-normalized'; % Yüzdelik başarıları göster
cm.ColumnSummary = 'column-normalized';