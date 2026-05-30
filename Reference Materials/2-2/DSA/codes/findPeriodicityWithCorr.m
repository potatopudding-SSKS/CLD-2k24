clc
clear all
close all

% Parameters
fs = 1000;            % sampling frequency (Hz)
T = 1;                % duration (s)
t = 0:1/fs:T-1/fs;    % time vector
f0 = 50;               % base cosine frequency (Hz)
A = 1;                % amplitude

% Clean cosine signal
x_clean = A*cos(2*pi*f0*t);
x_clean(f0:end)= 0;

% Noise levels to test (standard deviations)
noise_levels = [0, 0.5, 1.0, 1.5, 2.0];

% Preallocate
num_levels = numel(noise_levels);
est_periods = nan(1,num_levels);
est_freqs = nan(1,num_levels);
xcorr_maxlags = round(fs); % up to 1 second lag

figure('Color','w','Units','normalized','Position',[0.05 0.05 0.9 0.85]);

for k = 1:num_levels
    sigma = noise_levels(k);
    noise = sigma*randn(size(t));
    x = x_clean + noise;
    
    % Autocorrelation (biased) computed via xcorr
    [r, lags] = xcorr(x - mean(x), x - mean(x), xcorr_maxlags, 'coeff');
    
    % Find peaks in autocorrelation excluding zero lag
    lag_sec = lags/fs;
    r_zero_idx = find(lags==0);
    
    % Consider only positive lags
    pos_idx = lags>0;
    r_pos = r(pos_idx);
    lags_pos = lags(pos_idx);
    lag_sec_pos = lag_sec(pos_idx);
    
    % Find peaks
    [pks, locs] = findpeaks(r_pos, 'MinPeakProminence', 0.1, 'MinPeakDistance', round(fs/f0/2));
    
    if ~isempty(locs)
        first_peak_lag = lags_pos(locs(1));
        est_period = first_peak_lag / fs; % seconds
        est_freq = 1/est_period;
    else
        est_period = NaN;
        est_freq = NaN;
    end
    est_periods(k) = est_period;
    est_freqs(k) = est_freq;
    
    % Plot time-domain signal
    subplot(num_levels,2,2*(k-1)+1);
    plot(t, x, 'k'); hold on;
    plot(t, x_clean, 'b--', 'LineWidth', 1);
    xlabel('Time (s)'); ylabel('Amplitude');
    title(sprintf('Noisy signal (\\sigma=%.2g)', sigma));
    xlim([0 0.1]);
    legend('Noisy','Clean','Location','northeast');
    
    % Plot autocorrelation
    subplot(num_levels,2,2*(k-1)+2);
    plot(lag_sec, r, 'k'); hold on;
    % mark detected peak
    if ~isnan(est_period)
        stem(est_period, r(lags==first_peak_lag), 'r', 'filled');
        txt = sprintf('Estimated period = %.3f s (f=%.2f Hz)', est_period, est_freq);
    else
        txt = 'No clear peak detected';
    end
    xlabel('Lag (s)'); ylabel('Autocorrelation (normalized)');
    title(['Autocorrelation (\sigma=' num2str(sigma) ')']);
    xlim([0 0.5]);
    ylim([-0.2 1]);
    text(0.02, 0.9, txt, 'Units','normalized', 'FontSize',9, 'BackgroundColor','w');
end

% Summary printed
fprintf('True frequency: %.2f Hz (period %.3f s)\n', f0, 1/f0);
for k = 1:num_levels
    fprintf('Noise sigma=%.2g: Estimated period = %.4f s, Estimated freq = %.3f Hz\n', ...
        noise_levels(k), est_periods(k), est_freqs(k));
end