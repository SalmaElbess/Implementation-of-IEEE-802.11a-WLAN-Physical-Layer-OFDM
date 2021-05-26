clear; clc; close all;

%% Main Scenario script
Nc = 64; guard_len = 16; % OFDM parameters
rate= 1/2; mod_type = '16qam';

input_length = 1000;
bin_data = randi([0,1], [1,input_length]);

%% Transmitter
tx_frame = WiFi_transmitter(bin_data, mod_type, rate, Nc, guard_len);

%% Channel
 % --
 
%% Receiver
out_decoded = WiFi_receiver(tx_frame, Nc, guard_len);

%% Check
BER = sum(out_decoded ~= bin_data)/length(out_decoded)