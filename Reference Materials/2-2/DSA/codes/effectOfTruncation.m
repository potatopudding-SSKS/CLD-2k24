clc
clear all
close all


% Design parameters
fs= 16000;
fc = 4000;                % desired cutoff (Hz)
Ninf= 10001;
wc = 2*pi*fc/fs;          % digital cutoff (rad/sample)
n = 0:Ninf-1;
m = (Ninf-1)/2;

% Ideal lowpass sinc (normalized)
h_ideal = (sin(wc*(n-m))./(pi*(n-m)));
h_ideal(m+1) = wc/pi;    % handle division by zero


subplot 321
plot([(m-Ninf+1):(Ninf-m-1)], h_ideal,'LineWidth',2);
axis tight

subplot 322
plot(n*fs/Ninf,abs(fft(h_ideal)),'LineWidth',2); axis tight

w_rect = zeros(1,Ninf);
N = 31;                  % filter length (odd for linear phase)
w_rect((m-(N-1)/2+1):(m+(N-1)/2+1))= 1;
h_rect = h_ideal .* w_rect;

subplot 323
plot([(m-Ninf+1):(Ninf-m-1)], h_ideal,'LineWidth',2); axis tight
hold on;
plot([(m-Ninf+1):(Ninf-m-1)], w_rect,'r','LineWidth',2);
xlim([-2*N,2*N])

subplot 324
plot(n*fs/Ninf,abs(fft(w_rect)),'LineWidth',2); axis tight

subplot 325
plot([1:N],h_rect((m-(N-1)/2):(m+(N-1)/2)),'LineWidth',2);  axis tight

subplot 326
plot([0:N-1]*fs/N, abs(fft(h_rect((m-(N-1)/2):(m+(N-1)/2)))),'LineWidth',2); axis tight