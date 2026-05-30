[audioData, fs] = audioread("..\audio\harmonicSine.wav");
x= audioData;

Nw = 10024;

x = x(:).';              % ensure row vector
N = numel(x);
w = linspace(-pi, pi, Nw+1); % include endpoint to get [-pi,pi], drop last
w = w(1:end-1);
n = 0:(N-1);

% Compute exponent matrix: size Nw x N
% Use bsxfun-style implicit expansion (MATLAB R2016b+)
W = exp(-1j * (w.' * n)); % Nw-by-N
X = W * x.';              % Nw-by-1

X = X(:);                 % column vector
% Compute the magnitude and phase of the DTFT
magnitudeX = abs(X);
phaseX = angle(X);
% Plot the magnitude and phase of the DTFT
figure;
subplot(2, 1, 1);
plot(n, x);
title('Original Signal');
xlabel('Sample Index');
ylabel('Amplitude');
xlim([0,100]);
grid on;
subplot(2, 1, 2);
% plot(w, magnitudeX);
%xlabel('Frequency (rad/sample)');
%plot((Fs*w)/(2*pi), magnitudeX);
%xlabel('Continuous-time Frequency (cycles/second)');
 plot((w)/(2*pi), magnitudeX);
 xlabel('Discrete-time Frequency (cycles/sample)');

title('Magnitude of DTFT');
ylabel('|X(w)|');
grid on;