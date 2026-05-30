clc
clear all
close all

% Parameters
fs = 1000;              % sampling frequency (Hz)
T  = 1;                 % signal duration (s)
t  = 0:1/fs:T-1/fs;     % time vector
f0 = 50;                % fundamental cosine frequency (Hz)
A  = 1;                 % amplitude

% Noise levels to test (standard deviations)
noise_levels = [0, 0.5, 1.0, 1.5, 2.0];

% Prepare figure
nLevels = numel(noise_levels);
figure('Color','w','Units','normalized','Position',[0.05 0.05 0.9 0.8]);

for k = 1:nLevels
    sigma = noise_levels(k);
    
    % Generate noisy cosine
    x = A*cos(2*pi*f0*t);
    x(f0:end)= 0;
    x = x + sigma*randn(size(t));
    
    % Compute DFT using FFT
    N = length(x);
    X = fft(x);
    f = (0:N-1)*(fs/N);
    mag = abs(X)/N;
    mag(2:floor(N/2)) = 2*mag(2:floor(N/2)); % single-sided magnitude
    
    % Find peak frequency in single-sided spectrum
    halfN = 1:floor(N/2);
    [~, idx] = max(mag(halfN));
    peakFreq = f(idx);
    
    % Time-domain subplot
    subplot(nLevels,2,2*(k-1)+1)
    plot(t, x, 'b')
    xlabel('Time (s)')
    ylabel('Amplitude')
    title(sprintf('Noisy cosine, \\sigma = %.2f (time domain)', sigma))
    xlim([0 0.1])
    grid on
    
    % Frequency-domain subplot
    subplot(nLevels,2,2*(k-1)+2)
    plot(f(halfN), mag(halfN), 'r')
    hold on
    stem(peakFreq, mag(idx), 'k','filled')
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Magnitude')
    title(sprintf('DFT magnitude, detected peak = %.2f Hz', peakFreq))
    xlim([0 fs/2])
    grid on
end

% Summary output
fprintf('True frequency: %.2f Hz\n', f0);
for k = 1:nLevels
    sigma = noise_levels(k);
    x = A*cos(2*pi*f0*t) + sigma*randn(size(t));
    X = fft(x);
    N = length(x);
    mag = abs(X)/N;
    mag(2:floor(N/2)) = 2*mag(2:floor(N/2));
    f = (0:N-1)*(fs/N);
    [~, idx] = max(mag(1:floor(N/2)));
    fprintf('Noise sigma = %.2f -> detected peak = %.2f Hz\n', sigma, f(idx));
end