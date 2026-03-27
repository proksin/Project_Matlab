import tensorflow as tf
import keras
from keras import layers, models

# Parametreler
IMG_HEIGHT = 128
IMG_WIDTH = 128
BATCH_SIZE = 32
DATA_DIR = "../../data/spectrogram_images"

# 1. Veri Setini Yükle (Resimleri etiketleriyle beraber otomatik çeker)
train_ds = tf.keras.utils.image_dataset_from_directory(
    DATA_DIR,
    validation_split=0.2,
    subset="training",
    seed=123,
    image_size=(IMG_HEIGHT, IMG_WIDTH),
    batch_size=BATCH_SIZE)

val_ds = tf.keras.utils.image_dataset_from_directory(
    DATA_DIR,
    validation_split=0.2,
    subset="validation",
    seed=123,
    image_size=(IMG_HEIGHT, IMG_WIDTH),
    batch_size=BATCH_SIZE)

AUTOTUNE = tf.data.AUTOTUNE
train_ds = train_ds.cache().prefetch(buffer_size=AUTOTUNE)
val_ds = val_ds.cache().prefetch(buffer_size=AUTOTUNE)

# 2. CNN MİMARİSİ (Projenin Beyni)
model = models.Sequential([
    layers.Rescaling(1./255, input_shape=(IMG_HEIGHT, IMG_WIDTH, 3)),
    
    # 1. Katman: Resimdeki basit çizgileri öğrenir
    layers.Conv2D(32, (3, 3), activation='relu'),
    layers.MaxPooling2D(),
    
    # 2. Katman: Daha karmaşık dokuları öğrenir
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D(),
    
    # 3. Katman: Artık modların imza notalarını (frekans tepe noktalarını) anlar
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.Flatten(),
    
    # Karar Katmanı
    layers.Dense(64, activation='relu'),
    layers.Dense(4, activation='softmax') # 4 Modumuz olduğu için
])

# 3. Derleme ve Eğitim
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

print("CNN Eğitimi Başlıyor...")
history = model.fit(train_ds, validation_data=val_ds, epochs=10)

# 4. Modeli Kaydet
model.save('../models/scale_cnn_model.keras')
print("Model 'models' klasörüne kaydedildi.")