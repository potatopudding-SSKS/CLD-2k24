clc
clear all
close all

% Parameters
fs = 1000;             % sampling frequency (Hz)
T = 1;                 % signal duration (s)
t = 0:1/fs:T-1/fs;     % time vector
f0 = 50;               % cosine frequency (Hz)
N = length(t);

% Clean cosine signal
x_clean = cos(2*pi*f0*t);
%x_clean(f0:end)= 0;

% Noise levels (standard deviations)
noise_levels = [0, 0.5, 1.0, 1.5];
num_levels = numel(noise_levels);

% Preallocate results
est_period_corr = nan(1,num_levels);
est_period_dft = nan(1,num_levels);
x_noisy_all = zeros(num_levels, N);
acf_all = cell(1,num_levels);
Pxx_all = cell(1,num_levels);
freq = (0:N-1)*(fs/N);

for k = 1:num_levels
    sigma = noise_levels(k);
    noise = sigma*randn(size(t));
    x_noisy = x_clean + noise;
    x_noisy_all(k,:) = x_noisy;
    
    % --- Period estimation via autocorrelation (find peak lag) ---
    % Use unbiased autocorrelation via xcorr
    [r, lags] = xcorr(x_noisy - mean(x_noisy), 'coeff');
    %[r, lags] = xcorr(x_noisy, 'coeff');
    acf_all{k} = struct('r', r, 'lags', lags);
    % consider only positive lags
    pos_idx = lags > 0;
    r_pos = r(pos_idx);
    lags_pos = lags(pos_idx);
    % find first prominent peak (exclude lag=0)
    % smooth correlation to reduce noise
    r_smooth = movmean(r_pos, round(0.002*fs)+1);
    % find peaks
    [pks, locs] = findpeaks(r_pos, 'MinPeakProminence', 0.1);
    if ~isempty(locs)
        lag_samples = lags_pos(locs(1));
        est_period_corr(k) = lag_samples / fs; % seconds
    else
        % fallback: take lag of maximum correlation in positive lags
        [~, idxmax] = max(r_pos);
        est_period_corr(k) = lags_pos(idxmax) / fs;
    end
    
    % --- Period estimation via DFT (peak in magnitude spectrum) ---
    X = fft(x_noisy);
    P = abs(X);
    Pxx_all{k} = P;
    % ignore DC component
    P(1) = 0;
    % find bin of maximum magnitude
    [~, idx] = max(P(1:floor(N/2))); % consider up to Nyquist
    f_est = freq(idx);
    if f_est == 0
        est_period_dft(k) = NaN;
    else
        est_period_dft(k) = 1 / f_est;
    end
end

% Display results
fprintf('Noise sigma\tPeriod (corr) [s]\tPeriod (DFT) [s]\n');
for k = 1:num_levels
    fprintf('%8.3f\t\t%8.5f\t\t%8.5f\n', noise_levels(k), est_period_corr(k), est_period_dft(k));
end

% Plots
figure('Name','Cosine with Noise Levels');
for k = 1:num_levels
    subplot(num_levels,3,(k-1)*3+1)
    plot(t, x_noisy_all(k,:),'LineWidth',3);
    title(sprintf('Noisy signal (\\sigma=%.2f)', noise_levels(k)));
    xlabel('Time (s)'); ylabel('Amplitude');
    xlim([0 0.1]); % zoom first 100 ms for clarity
    
    subplot(num_levels,3,(k-1)*3+2)
    ac = acf_all{k};
    plot(ac.lags/fs, ac.r);
    hold on
    if ~isnan(est_period_corr(k))
        stem(est_period_corr(k), 1, 'LineWidth',3); hold on;
        xline(est_period_corr(k), '--r', sprintf('T_{corr}=%.4fs', est_period_corr(k)),'FontSize',15,'FontWeight','bold');
        hold off;
    end
    hold off
    title('Autocorrelation');
    xlabel('Lag (s)'); ylabel('Autocorr (norm)');
    xlim([0 0.05]);
    
    subplot(num_levels,3,(k-1)*3+3)
    P = Pxx_all{k};
    plot(freq(1:floor(N/2)), P(1:floor(N/2)),'LineWidth',3);
    hold on
    if ~isnan(est_period_dft(k))
        stem(1/est_period_dft(k), max(P)/2, 'ro','LineWidth',3);
        text(1/est_period_dft(k), max(P)/2, sprintf(' f=%.2f Hz', 1/est_period_dft(k)), 'VerticalAlignment','bottom','FontSize',15,'FontWeight','bold','Color','r');
    end
    hold off
    title('Magnitude Spectrum');
    xlabel('Frequency (Hz)'); ylabel('|X(f)|');
    xlim([0 200]);
end

sgtitle('Periodicity estimation: autocorrelation vs DFT');