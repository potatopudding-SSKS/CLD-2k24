clc
clear all
close all

% Parameters
n = -10:10;                    % time index
x = exp(-0.2*(n-0)).*(n>=0);   % example signal x[n]
h = [1 0.8 0.6 0.4 0.2 zeros(1,5)]; % impulse-like signal h[n]
m = -10:10;                    % shift range for correlation
shifts = -10:14;               % shifts for animation

% Prepare figure
fig = figure('Color','w','Position',[100 100 800 600]);
tiledlayout(3,1,'TileSpacing','compact');

% Precompute correlation via xcorr for reference
[r_full, lags] = xcorr(x, h);
[~, idx0] = max(lags==0);

% GIF setup
gif_filename = 'correlation_animation.gif';
delay_time = 0.5;

% Animation loop over shifts
for k = 1:length(shifts)
    s = shifts(k);
    
    % Shifted version of h for visualization (discrete shift)
    h_shifted = zeros(size(n));
    for i = 1:length(h)
        idx = find(n == (i-1 + s)); % map h sample to n index
        if ~isempty(idx)
            h_shifted(idx) = h(i);
        end
    end
    
    r_at_s = sum(x .* conj(h_shifted));
    
    % Plot x[n]
    nexttile(1);
    stem(n, x, 'filled', 'LineWidth',1.2); hold on;
    stem([0:length(h)-1], h, 'r', 'filled', 'LineWidth',1.2); hold off;
    ylim([1.1*min([x h]) 1.1*max([x h])]);
    title('Signal x[n]');
    xlabel('n'); grid on;
    
    % Plot shifted h[n-s]
    nexttile(2);
    stem(n, h_shifted, 'r', 'filled', 'LineWidth',1.2);
    ylim([1.1*min([x h]) 1.1*max([x h])]);
    title(sprintf('Shifted h[n - s], s = %d', s));
    xlabel('n'); grid on;
    
    % Plot overlap and running correlation vs shift
    nexttile(3);
    % compute entire correlation for display up to current shift
    curr_shifts = shifts(1:k);
    r_vals = zeros(size(curr_shifts));

    for jj = 1:length(curr_shifts)
        ss = curr_shifts(jj);
        hs_tmp = zeros(size(n));
        for ii = 1:length(h)
            % ns = n(ii)-ss;
            idxh = find(n == (ii-1 + ss)); % map h sample to n index
            % idxh = find((0:length(h)-1) == (ns - min(n)));
            if ~isempty(idxh)
                hs_tmp(idxh) = h(ii);
            end
        end
        r_vals(jj) = sum(x .* conj(hs_tmp));
    end
    plot(curr_shifts, real(r_vals), '-o','LineWidth',1.2);
    hold on;
    plot(s, real(r_at_s), 'ks','MarkerFaceColor','y','MarkerSize',8);
    hold off;
    xlabel('shift s'); ylabel('Re\{r[s]\}'); grid on;
    title('Running correlation vs shift');
    xlim([min(shifts)-1 max(shifts)-1]);
    ylim([-1,3])
    
    drawnow;
    
    % Capture frame
    frame = getframe(fig);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im,256);
    if k == 1
        imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', delay_time);
    else
        imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', delay_time);
    end
    pause(0.5)
end

% Close figure after saving
close(fig);