clc
clear all
close all

w= [0:0.01:2*pi];
cosineDTFT= 6*cos(w);
cosine2DTFT= 4*cos(2*w);

subplot 321; plot(w, cosineDTFT,'linewidth',3)
axis tight
title('6Cos(w)')
set(gca,'fontsize',15,'fontweight','bold')

subplot 323; plot(w, cosine2DTFT,'linewidth',3)
axis tight
title('4Cos(2w)')
set(gca,'fontsize',15,'fontweight','bold')

subplot 325; plot(w, cosineDTFT+cosine2DTFT,'linewidth',3); 
axis tight
title('6Cos(w)+4Cos(2w)')
set(gca,'fontsize',15,'fontweight','bold')

subplot 322; plot(w, 2+cosineDTFT+cosine2DTFT,'linewidth',3); 
axis tight
title('6Cos(w)+4Cos(2w)+2')
set(gca,'fontsize',15,'fontweight','bold')

subplot 324; plot(w, abs(2+cosineDTFT+cosine2DTFT),'linewidth',3); 
axis tight
title('amplitude of 6Cos(w)+4Cos(2w)+2')
set(gca,'fontsize',15,'fontweight','bold')

subplot 326; plot(w, angle(2+cosineDTFT+cosine2DTFT),'linewidth',3); 
axis tight
title('amplitude of 6Cos(w)+4Cos(2w)+2')
set(gca,'fontsize',15,'fontweight','bold')

