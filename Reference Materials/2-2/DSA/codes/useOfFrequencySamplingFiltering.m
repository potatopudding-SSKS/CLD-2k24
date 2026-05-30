clc
clear all
close all

% Generate a single-tone signal with high-frequency noise
fs = 16000;        % sampling frequency (Hz)
t = 0:1/fs:2-1/fs; % 1 second duration
f_tone = 1000;     % tone frequency (Hz)

% Pure tone
tone = sin(2*pi*f_tone*t);

% High-frequency noise (band-limited white noise around high frequencies)
hf_center = 8000;          % center of high-frequency noise (Hz)
hf_bw = 6000;               % bandwidth (Hz)
n = length(t);
% Generate white noise and apply bandpass via FFT
noise = randn(1,n);
N = fft(noise);
f = (0:n-1)*(fs/n);
% Construct bandpass mask (two-sided)
mask = zeros(1,n);
% positive freqs
pos_idx = f >= (hf_center - hf_bw/2) & f <= (hf_center + hf_bw/2);
% corresponding negative freqs (wrap)
neg_idx = (f >= fs-(hf_center + hf_bw/2)) & (f <= fs-(hf_center - hf_bw/2));
mask(pos_idx | neg_idx) = 1;
N_filtered = N .* mask;
hf_noise = real(ifft(N_filtered));
% Normalize noise amplitude
hf_noise = hf_noise / std(hf_noise);

% Mix tone and high-frequency noise
noise_level = 30.99; % relative amplitude of noise
signal = tone + noise_level * hf_noise;

% Normalize final signal to avoid clipping
sig = signal / max(abs(signal));
%sound(sig, fs);

Nf = 61;                 % frequency samples (use same length as signal for circular conv)
%Nf= 61;
fc = 3000;              % cutoff frequency (Hz) - keep below HF noise
f = (0:Nf-1)*(fs/Nf);   % frequency vector

% Ideal frequency response (two-sided) - lowpass
H = zeros(1,Nf);
pos_idx = f <= fc;
neg_idx = f >= fs - fc;
H(pos_idx | neg_idx) = 1;

%H= fftshift(H);
nIFFT= Nf;
h_time = real(ifft(H));
h_time = fftshift(h_time);
h_fir= h_time;

% Apply filter via convolution (linear) to avoid circular effects
sig_filt = conv(sig, h_fir);
sig_filt = sig_filt(Nf:end);

% Normalize filtered signal
sig_filt = sig_filt / max(abs(sig_filt));

% Plots for illustration
figure('Name','Frequency Sampling Filter Design','NumberTitle','off','Position',[100 100 1000 700]);

subplot(2,2,1)
plot(t, sig);
title('Original Signal (time domain)')
xlabel('Time (s)'); ylabel('Amplitude');
xlim([0 0.01])

subplot(2,2,2)
plot(t, sig_filt);
title('Filtered Signal (time domain)')
xlabel('Time (s)'); ylabel('Amplitude');
xlim([0 0.01])

% Frequency domain plots
SIG = fft(sig);
SIGF = fft(sig_filt);
freq_axis = (0:n-1)*(fs/n);

subplot(2,2,3)
plot(freq_axis, abs(SIG)/max(abs(SIG)));
xlim([0 fs/2]); ylim([-0.1 1.1])
title('Original Signal Spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)')

subplot(2,2,4)
plot(freq_axis, abs(SIGF)/max(abs(SIGF)));
xlim([0 fs/2]); ylim([-0.1 1.1])
title('Filtered Signal Spectrum'); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)')

% Optionally play filtered audio
% sound(sig_filt, fs);