clc
clear all
close all

% generate a signal: two sinusoids plus noise
fs = 1000;            % sampling frequency (Hz)
t = 0:1/fs:1-1/fs;    % 1 second
f1 = 50; f2 = 120;
x = sin(2*pi*f1*t) + 0.6*sin(2*pi*f2*t);
x1=x;
rng(0)
x = x + 1.2*randn(size(x));   % additive white noise

% design a lowpass FIR filter (cutoff between f1 and f2) using window method
fc = 140;                        % cutoff Hz
N = 61;                         % filter length (odd for linear phase)
wc = 2*pi*fc/fs;                % digital radian cutoff

% ideal sinc lowpass (centered)
n = 0:N-1;
m = (N-1)/2;
h_ideal = (wc/pi) * sinc((wc/pi)*(n-m));  % sinc(x) = sin(pi x)/(pi x) in MATLAB but want normalized
% Note: MATLAB's sinc uses pi factor: sinc(x) = sin(pi*x)/(pi*x)
% To get sin(wc*(n-m))/ (pi*(n-m)) scaled appropriately, use above expression.

% apply rectangular window (i.e., truncated ideal) and Hamming window
w_rect = ones(1,N);
w_hamm = hamming(N).';
h_rect = h_ideal .* w_rect;
h_hamm = h_ideal .* w_hamm;

% filter the signal (use filtfilt to avoid phase distortion for comparison)
y_rect = filtfilt(h_rect,1,x);
y_hamm = filtfilt(h_hamm,1,x);

% time-domain plots to illustrate effect
figure('Name','Time Domain Filtering: Rectangular vs Hamming','Color','w');
subplot(3,1,1)
plot(t,x,'Color',[0.6 0.6 0.6])
title('Noisy input signal')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([0 0.2])

subplot(3,1,2)
plot(t,y_rect,'r')
title('Filtered with Rectangular window FIR')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([0 0.2])

subplot(3,1,3)
plot(t,x1,'k');
hold on;
plot(t,y_rect,'r')
plot(t,y_hamm,'b')
title('Filtered with Hamming window FIR')
xlabel('Time (s)')
ylabel('Amplitude')
xlim([0 0.2])
hold off

% also show impulse responses and frequency responses
figure('Name','Filter Responses','Color','w','Position',[100 100 900 500]);
subplot(2,2,1)
stem(n-m,h_rect,'r','Marker','none')
title('Rectangular-window impulse response')
xlabel('n - (N-1)/2')

subplot(2,2,2)
stem(n-m,h_hamm,'b','Marker','none')
title('Hamming-window impulse response')
xlabel('n - (N-1)/2')

% frequency responses
[H_rect,f] = freqz(h_rect,1,1024,fs);
[H_hamm,~] = freqz(h_hamm,1,1024,fs);

subplot(2,2,3)
plot(f,20*log10(abs(H_rect)+eps),'r')
hold on
plot(f,20*log10(abs(H_hamm)+eps),'b')
grid on
legend('Rectangular','Hamming')
title('Magnitude Response (dB)')
xlabel('Frequency (Hz)')
ylabel('Magnitude (dB)')
xlim([0 fs/2])

% show zoom around passband/stopband transition
subplot(2,2,4)
plot(f,20*log10(abs(H_rect)+eps),'r')
hold on
plot(f,20*log10(abs(H_hamm)+eps),'b')
yline(-60,'k--','Alpha',0.5)
xlim([0 200])
ylim([-80 5])
grid on
title('Zoomed magnitude (0-200 Hz)')
xlabel('Frequency (Hz)')

% compute and display ripple/stopband metrics
% passband ripple: max deviation in 0:fc region
pb_idx = f<=fc;
pr_rect = max(abs(20*log10(abs(H_rect(pb_idx))+eps) - mean(20*log10(abs(H_rect(pb_idx))+eps))));
pr_hamm = max(abs(20*log10(abs(H_hamm(pb_idx))+eps) - mean(20*log10(abs(H_hamm(pb_idx))+eps))));
% stopband attenuation: max in f>fc+10Hz
sb_idx = f> (fc+10);
sa_rect = max(20*log10(abs(H_rect(sb_idx))+eps));
sa_hamm = max(20*log10(abs(H_hamm(sb_idx))+eps));

fprintf('Passband ripple (dB): Rectangular = %.3f, Hamming = %.3f\n',pr_rect,pr_hamm);
fprintf('Stopband max (dB, closer to -inf is better): Rectangular = %.3f, Hamming = %.3f\n',sa_rect,sa_hamm);