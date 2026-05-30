clc
clear all
close all

F1= 200;
F2= 800;
Fs= 8000;
A= 0.99;
t= [0:0.1/Fs:10/F2];
t1= [0:1/Fs:2];
sineSig1= A*cos(2*pi*F1*t);
sineSig4audio1= A*cos(2*pi*F1*t1);

sineSig2= A*cos(2*pi*F2*t);
sineSig4audio2= A*cos(2*pi*F2*t1);

sineSig3= sineSig1+sineSig2;
sineSig4audio3= sineSig4audio1+4*sineSig4audio2;
sineSig4audio3= sineSig4audio3/max(abs(sineSig4audio3));

subplot 321; plot(t*1000/4,sineSig1,'linewidth',3)
axis tight
set(gca,'ytick',[],'fontsize',15,'fontweight','bold')

subplot 323; plot(t*1000/4,sineSig2,'linewidth',3)
axis tight
set(gca,'ytick',[],'fontsize',15,'fontweight','bold')

subplot 325; plot(t*1000/4,1+4*sineSig1,'linewidth',3); hold on;  plot(t*1000/4,1+2*sineSig3,'linewidth',3); hold off;
axis tight
set(gca,'ytick',[],'fontsize',15,'fontweight','bold')

%%%%%%%%%%%%%%%%%
subplot 322; plot(sineSig4audio1,'linewidth',3)
axis tight
xlim([0,200])
set(gca,'ytick',[],'fontsize',15,'fontweight','bold')

subplot 324; plot(sineSig4audio2,'linewidth',3)
axis tight
xlim([0,200])
set(gca,'ytick',[],'fontsize',15,'fontweight','bold')

subplot 326; plot(sineSig4audio3,'linewidth',3);
axis tight
xlim([0,200])
% set(gca,'ytick',[],'fontsize',15,'fontweight','bold')

% sound(sineSig4audio1); pause;
% sound(sineSig4audio2); pause;
sound(sineSig4audio3)
% audiowrite('sine1.wav',sineSig4audio1,Fs)
% audiowrite('sine2.wav',sineSig4audio2,Fs)
audiowrite('../audio/harmonicSine.wav',sineSig4audio3,Fs)