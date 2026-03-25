# Musical Scale Classification: A Comparative Study
This project benchmarks two distinct approaches for classifying musical scales from short (3-5s) audio clips.

## 🚀 Overview
We compare:
1. **Traditional Machine Learning (MATLAB):** Feature extraction using **MFCC** and **Chromagrams**, followed by **SVM** classification.
2. **Deep Learning (Python):** Signal conversion to **Mel-spectrogram** images, followed by training a **Convolutional Neural Network (CNN)**.

## 🛠 Methodology

### Feature Extraction (MATLAB)
Mathematical audio features are extracted to represent the tonal and spectral content:
- **MFCCs:** To capture the power spectrum of the sound.
- **Chromagrams:** To represent the energy distribution across the 12 semitones.

### Image-Based Classification (Python)
Audio files are converted into visual representations:
$$S(f, t) = |STFT(x(t))|^2$$
These Mel-spectrograms are then fed into a CNN architecture to learn spatial patterns in frequency and time.

## 📊 Evaluation Criteria
- Classification Accuracy
- Computational Efficiency (Inference Time)
- Feature robustness across different instruments
