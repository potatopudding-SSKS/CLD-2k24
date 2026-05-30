% Parameters
fs_true = 80000;        % "Continuous" signal sampling rate for high-res reference (Hz)
t_end = 0.1;           % seconds
f_sig = 250;           % signal frequency (Hz)
A = 1;                  % amplitude
phi = pi/2;                % phase
nPeriod= 8;
% fs_all= [5000];
fs_all= [5000:-100:500, 500:-10:140];

% High-resolution continuous-time-like signal
t = 0:1/fs_true:t_end;
x_cont = A * sin(2*pi*f_sig*t + phi);

subplot(2,1,1);
plot(t*1e3, x_cont, 'k');
title(sprintf('High-res signal: f=%.1f Hz, fs_{ref}=%.0f Hz', f_sig, fs_true));
xlabel('Time (ms)'); ylabel('Amplitude');
ylim([-1,1]);
xlim([0, nPeriod/f_sig*1e3]); % show two periods

% Time domain sampled signal
for i=1:length(fs_all)
    fs = fs_all(i);
    ts = 0:1/fs:t_end;
    x_s = A * sin(2*pi*f_sig*ts + phi);

    % Interpolation from samples: reconstruct using sinc interpolation and plot
    t_rec = t;
    % Sinc interpolation: x_rec(t) = sum_n x[n] * sinc((t - nT)/T)
    T = 1/fs;
    n = 0:length(ts)-1;
    tau = (t_rec.' - n*T)/T;         % size length(t_rec) x length(n)
    sinc_mat = ones(size(tau));
    nz = tau~=0;
    sinc_mat(nz) = sin(pi*tau(nz))./(pi*tau(nz));
    x_rec = sinc_mat * x_s.';
    f_alias = mod(f_sig + fs/2, fs) - fs/2;

    % Plot reconstruction overlaid on continuous and samples in second figure
    subplot(2,1,2);
    plot(t*1e3, x_cont, 'k', 'DisplayName','High-res continuous'); hold on;
    plot(t_rec*1e3, x_rec, 'b--', 'LineWidth',1.2, 'DisplayName','Sinc reconstructed');
    stem(ts*1e3, x_s, 'filled','r', 'DisplayName','Samples');
    hold off;
    ylim([-1,1]);
    xlim([0, nPeriod/f_sig*1e3]);
    xlabel('Time (ms)'); ylabel('Amplitude');
    title(sprintf('fs=%.0f Hz -> aliased frequency = %.1f Hz\n', fs, f_alias));
    pause
end
