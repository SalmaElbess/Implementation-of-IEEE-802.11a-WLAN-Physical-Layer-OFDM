clear; clc; close all;

%% Main Scenario script
Nc = 64; guard_len = 16; % OFDM parameters
rate= 2/3; mod_type = '64QAM';
h = [0.8208 + 0.2052*1i, 0.4104 + 0.1026*1i, 0.2052 + 0.2052*1i, 0.1026 + 0.1026*1i]; %channel

FileID=fopen('test_file_1.txt','r');                       %open the file in read mode                                                                  
%Reading the file
data=[];
while ~feof(FileID)
    data=[data fscanf(FileID,'%c')];                      %read the text file char by char
end
fclose(FileID);
data = reshape(dec2bin(data, 8).'-'0',1,[]);

%% Without AWGN
out_decoded=[];
step = 1032*8;
for i=1:step:length(data)
    frame = data(i:min(length(data),i+step-1)); 
    % Tansmitter
    tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
    % Channel
    Rx_frame = conv(tx_frame,conj(h));
    Rx_frame = Rx_frame(1:end-length(h)+1);
    % Receiver
    decoded = WiFi_receiver(Rx_frame, Nc, guard_len);
    out_decoded = [out_decoded decoded(1:length(frame))];
end
% Check
BER = sum(out_decoded ~= data)/length(out_decoded)
% Write in file
FileID=fopen('rec_test_file_1.txt','w');
fprintf(FileID,'%c',char(bin2dec(reshape(char(out_decoded+'0'), 8,[]).'))');
fclose(FileID);

%% Comparison between the BER performance of the ZF equalizer, and the Weiner equalizer with AWGN Channel
step = 1032*8;
snr_dbs = (0:0.1:10);
rate= 3/4; mod_type = '64QAM';
BERs = [];
for snr_db = snr_dbs
    out_decoded=[];
    for i=1:step:length(data)
        frame = data(i:min(length(data),i+step-1)); 
        % Tansmitter
        tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
        % Channel
        EbN0 = 10^(snr_db/10);
        EavN0 = log2(16)*EbN0;
        Ps = sum(abs(tx_frame).^2)/length(tx_frame);
        var = Ps/EavN0;
        noiseq = randn(1,length(tx_frame)) + 1j*randn(1,length(tx_frame));
        awg_noise = sqrt(var/2)*noiseq;
        tx_frame = tx_frame + awg_noise;
        Rx_frame = conv(tx_frame,conj(h));
        Rx_frame = Rx_frame(1:end-length(h)+1);
        % Receiver
        decoded = WiFi_receiver(Rx_frame, Nc, guard_len);
        out_decoded = [out_decoded decoded(1:length(frame))];
    end
    % Check
    BER = sum(out_decoded ~= data)/length(out_decoded);
    BERs = cat(2, BERs, BER);
end

semilogy(snr_dbs, BERs);
title('BER vs SNR');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');