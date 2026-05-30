clc
clear all
close all

% Parameters
fs = 1000;              % sampling frequency (Hz)
T = 1;                  % duration (s)
t = 0:1/fs:T-1/fs;      % time vector
f0 = 5;                 % cosine frequency (Hz)
x = cos(2*pi*f0*t);     % original signal

% True delay (seconds) and corresponding samples
true_delay = 0.123;                     % true delay in seconds
d_true = round(true_delay*fs);          % true delay in samples

% Create delayed version (circularly shift then zero-pad to simulate causal delay)
y_clean = zeros(size(x));
if d_true < length(x)
    y_clean(d_true+1:end) = x(1:end-d_true);
end

% Noise levels to test (SNR in dB)
snr_db = [Inf 10 0 -5];   % Inf corresponds to no noise
n_levels = numel(snr_db);

% Preallocate
estimated_delays_samples = nan(1,n_levels);
estimated_delays_seconds = nan(1,n_levels);
crosscorrs = cell(1,n_levels);

figure('Units','normalized','Position',[0.05 0.1 0.9 0.8])

for k = 1:n_levels
    % Add noise
    if isfinite(snr_db(k))
        y = awgn(y_clean,snr_db(k),'measured');
    else
        y = y_clean;
    end
    
    % Compute cross-correlation (biased normalization to yield interpretable amplitude)
    [c, lags] = xcorr(y, x, 'coeff');  % correlate y with x: peak at +delay
    crosscorrs{k} = struct('c',c,'lags',lags);
    
    % Find lag corresponding to maximum correlation
    [~, idxmax] = max(c);
    lag_est = lags(idxmax);          % positive lag means y delayed relative to x by lag samples
    % Convert lag to delay in samples and seconds
    estimated_delays_samples(k) = lag_est;
    estimated_delays_seconds(k) = lag_est / fs;
    
    % Plot time signals and cross-correlation for this noise level
    subplot(n_levels,2,2*(k-1)+1)
    plot(t, x, 'b', 'LineWidth',1); hold on
    plot(t, y, 'r', 'LineWidth',1);
    legend('x (original)','y (delayed + noise)','Location','best')
    title(sprintf('Signals (SNR = %s dB)', num2str(snr_db(k))))
    xlabel('Time (s)')
    xlim([0 min(0.3, T)]) % show first 300 ms for clarity
    grid on
    hold off
    
    subplot(n_levels,2,2*(k-1)+2)
    stem(lags, c, 'Marker','none')
    hold on
    plot(lag_est, c(idxmax), 'ro', 'MarkerFaceColor','r')
    xlabel('Lag (samples)')
    ylabel('Correlation')
    title(sprintf('Cross-correlation (est delay = %d samples = %.4f s)', lag_est, lag_est/fs))
    xlim([min(lags) max(lags)])
    grid on
    hold off
end

% Summary printed results
fprintf('True delay: %d samples (%.6f s)\n\n', d_true, d_true/fs);
for k = 1:n_levels
    if isfinite(snr_db(k))
        fprintf('SNR = %3.0f dB: Estimated delay = %3d samples (%.6f s)\n', snr_db(k), estimated_delays_samples(k), estimated_delays_seconds(k));
    else
        fprintf('SNR = Inf (no noise): Estimated delay = %3d samples (%.6f s)\n', estimated_delays_samples(k), estimated_delays_seconds(k));
    end
end