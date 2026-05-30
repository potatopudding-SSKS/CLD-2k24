clc
clear all
close all

w= [0:0.01:2*pi];
cosineDTFT= 6*cos(w);
cosine2DTFT= 4*cos(2*w);

x=[2,3,2,3,2];
%f= 1/7;
%x= cos(2*pi*f*[0:(1/f)-1]);
L= length(x);
N= L-2;
[X, x_rec] = dft_idft(x, N, L);
combinedDTFT = abs(2 + cosineDTFT + cosine2DTFT);

subplot 221; plot(w, combinedDTFT,'linewidth',3); hold on; stem(2*pi/N*[0:N-1],abs(X)); hold off;
axis tight
title('DTFT and DFT')
set(gca,'fontsize',15,'fontweight','bold')

subplot 222; stem([0:L-1], x,'linewidth',3)
axis tight
title('Original')
set(gca,'fontsize',15,'fontweight','bold')

subplot 223; stem(0:N-1, real(x_rec),'linewidth',3); 
axis tight
title('Real part of reconstructed')
set(gca,'fontsize',15,'fontweight','bold')

subplot 224; stem(0:N-1, abs(x_rec),'linewidth',3); 
axis tight
title('Absolute of reconstructed')
set(gca,'fontsize',15,'fontweight','bold')