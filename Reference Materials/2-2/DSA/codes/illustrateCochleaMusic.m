clc
clear all
close all

[audioData, fs] = audioread("..\audio\CochleaMusic.m4a");
audioData= audioData(:,1);
targetFs = 8000;
[p,q] = rat(targetFs/fs, 1e-8);
audioData = resample(audioData, p, q);
fs = targetFs;
audioData = audioData / max(abs(audioData));

fps= 60;
w= [0:0.01:2*pi];
chunkSamples = round(fs/fps); % samples per chunk

numChunks = ceil(length(audioData) / chunkSamples);
chunks = cell(numChunks,1);
for k = 1:numChunks
    idxStart = (k-1)*chunkSamples + 1;
    idxEnd = min(k*chunkSamples, length(audioData));
    chunks{k} = audioData(idxStart:idxEnd);
end

for i=1:length(chunks)
    x= chunks{i};
    L= length(x);
    N= 200;
    [X, x_rec] = dft_idft(x, N, L);
    X= abs(X);
    if sum(x.^2)>0.1
        X= X/max(X);
    end
    subplot 311, stem(2*pi/N*[0:N-1],X);
    axis tight
    title(num2str(i))
    ylim([0,1]);
    xlim([0,pi]);
    set(gca,'fontsize',15,'fontweight','bold')
    %pause
    pause(1/60)
end