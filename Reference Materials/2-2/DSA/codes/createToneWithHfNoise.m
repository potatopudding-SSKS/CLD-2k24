% Generate a single-tone signal with high-frequency noise
fs = 16000;        % sampling frequency (Hz)
t = 0:1/fs:2-1/fs; % 1 second duration
f_tone = 3000;     % tone frequency (Hz)

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
noise_level = 20.99; % relative amplitude of noise
signal = tone + noise_level * hf_noise;

% Normalize final signal to avoid clipping
signal = signal / max(abs(signal));
L= length(signal);
N= L;
%[X, x_rec] = dft_idft(signal, N, L);
% Compute the DFT of the signal
X = fft(signal);

% Optional: play and plot (comment/uncomment as desired)
sound(signal, fs);
audiowrite('../audio/toneWithHfNoise.wav',signal,fs)
figure; subplot(2,1,1); plot(t(1:1000), signal(1:1000)); title('Time domain (first 1000 samples)');
axis tight
subplot(2,1,2); plot([0:2*pi/length(X):(2*pi-(1/length(X)))],abs(X)/max(abs(X))); axis tight; title('DFT');