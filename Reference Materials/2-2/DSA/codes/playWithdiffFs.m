clc
clear all
close all

% Read audio
[audioData, fs] = audioread("..\audio\audio.wav");
fs


% Create player and play (blocking)
audiowrite("..\audio\audio_16k.wav", audioData, fs);
audiowrite("..\audio\audio_8k.wav", audioData, 8000);
audiowrite("..\audio\audio_22k.wav", audioData, 22000);
audiowrite("..\audio\audio_12k.wav", audioData, 12000);

