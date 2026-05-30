clc
clear all
close all

% define discrete-time signals
n1 = -10:10;
n2 = -10:10;
% example signals: x[n] a rectangular pulse, h[n] a decaying exponential
x = double(abs(n1) <= 3);            % rectangular pulse length 7
h = (0.8).^(max(0,n2)).*(n2>=0);     % causal exponential

% convolution
y = conv(x,h);
ny = (n1(1)+n2(1)):(n1(end)+n2(end));

% prepare figure
figure('color','w','Position',[200 200 900 500]);
ax1 = subplot(3,1,1);
stem(n1,x,'filled','MarkerSize',4);
title('x[n]');
xlabel('n'); ylabel('x[n]');
axis tight; grid on;

ax2 = subplot(3,1,2);
stem(n2,h,'filled','MarkerSize',4);
title('h[n]');
xlabel('n'); ylabel('h[n]');
axis tight; grid on;

ax3 = subplot(3,1,3);
hStem = stem(ny,zeros(size(y)),'filled','MarkerSize',4);
title('y[n] = x[n] * h[n] (convolution)');
xlabel('n'); ylabel('y[n]');
axis tight; grid on;
ylim([min(0,min(y)) max(y)*1.1]);

% animation: sliding-and-accumulate visualization
% We'll flip h for convolution and slide across x
h_flipped = fliplr(h);
shiftRange = ny; % output indices
pauseTime = 1;

for k = 1:length(shiftRange)
    n_shift = shiftRange(k);
    % compute overlapping indices between x and shifted h_flipped
    % position of h_flipped relative to x: index in x where h_flipped(1) aligns
    align_idx = n_shift - n1(1) - (n2(end)); % derived so that conv index matches
    % build an array same length as n1 to show product
    prod_visual = zeros(size(x));
    for i = 1:length(x)
        h_idx = i - align_idx;
        if h_idx >=1 && h_idx <= length(h_flipped)
            prod_visual(i) = x(i)*h_flipped(h_idx);
        end
    end
    
    % update top subplot with product bars overlay
    subplot(ax1);
    cla(ax1);
    hold on;
    stem(n1,x,'filled','MarkerSize',4,'Color',[0 0.4470 0.7410]);
    stem(n1,prod_visual,'filled','MarkerSize',4,'Color',[0.8500 0.3250 0.0980]);
    legend('x[n]','x[n]\cdot h[n-k]','Location','northeastoutside');
    title(sprintf('x[n] and overlapping product at output n = %d', n_shift));
    axis tight; grid on;
    hold off;
    
    % update middle subplot to show shifted h (unflipped for visual)
    subplot(ax2);
    cla(ax2);
    % position h (not flipped) at shift n_shift: its indices are n2 + (n_shift - n2(1) - n1(1))
    h_pos = n2 + (n_shift - n2(end) - n1(1) + n1(1)); % simpler: shift so conv aligns
    % instead directly compute positions: place h at indices corresponding to overlap
    stem(n2 + (n_shift - ny(k)), h,'filled','MarkerSize',4,'Color',[0 0.4470 0.7410]);
    title('h[n] shifted for convolution (h[n-k])');
    xlabel('n'); ylabel('h[n-k]');
    axis tight; grid on;
    
    % update output subplot progressively accumulating sum
    subplot(ax3);
    y_partial = y;
    y_partial(1:length(y)) = 0;
    y_partial(k) = sum(prod_visual); % current sample
    % show accumulated up to current k
    y_accum = zeros(size(y));
    y_accum(1:k) = y(1:k);
    cla(ax3);
    hold on;
    stem(ny,y_accum,'filled','MarkerSize',4,'Color',[0.4660 0.6740 0.1880]);
    stem(ny(k),y(k),'filled','MarkerSize',6,'Color',[0.6350 0.0780 0.1840]);
    title('Accumulated output y[n]');
    xlabel('n'); ylabel('y[n]');
    axis tight; grid on;
    hold off;
    
    drawnow;
    pause(pauseTime);
end

% final display: full convolution
subplot(ax1);
cla(ax1);
stem(n1,x,'filled','MarkerSize',4,'Color',[0 0.4470 0.7410]);
title('x[n]');
axis tight; grid on;

subplot(ax2);
cla(ax2);
stem(n2,h,'filled','MarkerSize',4,'Color',[0 0.4470 0.7410]);
title('h[n]');
axis tight; grid on;

subplot(ax3);
cla(ax3);
stem(ny,y,'filled','MarkerSize',4,'Color',[0.4660 0.6740 0.1880]);
title('Final y[n] = x[n] * h[n]');
axis tight; grid on;

% save the animation as a GIF
gif_filename = 'convolution_animation.gif';
frame_delay = pauseTime; % seconds per frame

% capture frames from the figure during the same looped animation
% reproduce the loop but only capturing frames (fast replay to collect frames)
drawnow;
frames = []; % preallocate dynamic array
for k = 1:length(shiftRange)
    % update plots to the same state as in the animation loop (without pausing)
    n_shift = shiftRange(k);
    align_idx = n_shift - n1(1) - (n2(end));
    prod_visual = zeros(size(x));
    for i = 1:length(x)
        h_idx = i - align_idx;
        if h_idx >=1 && h_idx <= length(h_flipped)
            prod_visual(i) = x(i)*h_flipped(h_idx);
        end
    end

    % top subplot
    subplot(ax1);
    cla(ax1);
    hold on;
    stem(n1,x,'filled','MarkerSize',4,'Color',[0 0.4470 0.7410]);
    stem(n1,prod_visual,'filled','MarkerSize',4,'Color',[0.8500 0.3250 0.0980]);
    legend('x[n]','x[n]\cdot h[n-k]','Location','northeastoutside');
    title(sprintf('x[n] and overlapping product at output n = %d', n_shift));
    axis tight; grid on;
    hold off;

    % middle subplot
    subplot(ax2);
    cla(ax2);
    stem(n2 + (n_shift - ny(k)), h,'filled','MarkerSize',4,'Color',[0 0.4470 0.7410]);
    title('h[n] shifted for convolution (h[n-k])');
    xlabel('n'); ylabel('h[n-k]');
    axis tight; grid on;

    % output subplot
    subplot(ax3);
    cla(ax3);
    y_accum = zeros(size(y));
    y_accum(1:k) = y(1:k);
    hold on;
    stem(ny,y_accum,'filled','MarkerSize',4,'Color',[0.4660 0.6740 0.1880]);
    stem(ny(k),y(k),'filled','MarkerSize',6,'Color',[0.6350 0.0780 0.1840]);
    title('Accumulated output y[n]');
    xlabel('n'); ylabel('y[n]');
    axis tight; grid on;
    hold off;

    drawnow;
    % capture frame
    frame = getframe(gcf);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if k == 1
        imwrite(imind,cm,gif_filename,'gif','Loopcount',inf,'DelayTime',frame_delay);
    else
        imwrite(imind,cm,gif_filename,'gif','WriteMode','append','DelayTime',frame_delay);
    end
end

% also append final full-convolution frame
drawnow;
frame = getframe(gcf);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imwrite(imind,cm,gif_filename,'gif','WriteMode','append','DelayTime',1.5);