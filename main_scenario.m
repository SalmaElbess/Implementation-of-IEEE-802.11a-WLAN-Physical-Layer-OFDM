clear; clc; close all;

Nc = 64; guard_len = 16; % OFDM parameters
rate= 1/2; mod_type = '16qam';

input_length = 1000;
bin_data = randi([0,1], [1,input_length]);

tx_frame = WiFi_transmitter(bin_data, mod_type, rate, Nc, guard_len);