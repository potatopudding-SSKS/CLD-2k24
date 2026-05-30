function [X, x_rec] = dft_idft(x, N, L)
% Ensure column vector for computation
wasRow = isrow(x);
x = x(:);

% DFT matrix
n = (0:L-1);
k = (0:N-1).';
W = exp(-1j*2*pi*(k*n)/N);  % N-by-L

% Compute DFT
X_col = W * x;

% IDFT matrix and reconstruction
n = (0:N-1).';
k = 0:N-1;
W_inv = exp(1j*2*pi*(n*k)/N); % L-by-N
x_rec_col = (1/N) * (W_inv * X_col);

% Preserve input orientation
if wasRow
    X = X_col.';
    x_rec = x_rec_col.';
else
    X = X_col;
    x_rec = x_rec_col;
end
end