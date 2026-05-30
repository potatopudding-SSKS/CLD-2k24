clc
clear all
close all

% Generate a single-tone signal with high-frequency noise
fs = 32000;        % sampling frequency (Hz)
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
noise_level = 0.99; % relative amplitude of noise
signal = tone + noise_level * hf_noise;

% Normalize final signal to avoid clipping
sig = signal / max(abs(signal));
%sound(sig, fs);

% Design parameters
fc = 4000;                % desired cutoff (Hz)
N = 101;                  % filter length (odd for linear phase)
wc = 2*pi*fc/fs;          % digital cutoff (rad/sample)
n = 0:N-1;
m = (N-1)/2;

% Ideal lowpass sinc (normalized)
h_ideal = (sin(wc*(n-m))./(pi*(n-m)));
h_ideal(m+1) = wc/pi;    % handle division by zero

% Window functions
w_rect = ones(1,N);

% Windowed filters
h_rect = h_ideal .* w_rect;

% Filter the signal
y_rect = filtfilt(h_rect,1,sig);      % zero-phase filtering

% Time vectors
t = (0:length(sig)-1)/fs;


% Compare original and filtered signals (zoomed)
figure('Name','Signal Comparison','NumberTitle','off','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
tplot = t(1:min(end,round(0.005*fs))); % first 50 ms
plot(tplot, tone(1:length(tplot)),'k')
hold on
plot(tplot, y_rect(1:length(tplot))/max(y_rect),'r')
xlabel('Time (s)'); ylabel('Amplitude'); title('Original vs Filtered (first 50 ms)')
grid on