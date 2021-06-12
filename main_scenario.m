clear; clc; close all;

%% Main Scenario script
Nc = 64; guard_len = 16; % OFDM parameters
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
Pz=0; Pxx = 1;
out_decoded=[];
step = 1032*8;
rate= 3/4; mod_type = '64QAM'; estimation_method = 'WE';
for i=1:step:length(data)
    frame = data(i:min(length(data),i+step-1)); 
    % Tansmitter
    tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len, 0);
    % Channel
    Rx_frame = conv(tx_frame,conj(h));
    Rx_frame = Rx_frame(1:end-length(h)+1);
    % Receiver
    [decoded, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, estimation_method, Pz, Pxx);
    out_decoded = [out_decoded decoded(1:length(frame))];
end
% Check
BER = sum(out_decoded ~= data)/length(out_decoded)
% Write in file
FileID=fopen('rec_test_file_1.txt','w');
fprintf(FileID,'%c',char(bin2dec(reshape(char(out_decoded+'0'), 8,[]).'))');
fclose(FileID);

%% 4.c) Constellation diagram of the received symbols after equalization using the ZF equalizer and weiner equalizer
snr = 12; % in dB
rate= 3/4; mod_type = '64QAM';
out_decoded_WE=[]; out_decoded_ZF=[];
    for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len, 0);
             % Channel
             preamble_part = tx_frame(1:4*(Nc+guard_len));
             signal_part = tx_frame(4*(Nc+guard_len)+1:5*(Nc+guard_len));
             data_part = tx_frame(5*(Nc+guard_len)+1:end);
             
             Ps_preamble = sum(abs(preamble_part).^2)/length(preamble_part);
             Ps_signal = sum(abs(signal_part).^2)/length(signal_part);
             Ps_data = sum(abs(data_part).^2)/length(data_part);
             
             No_preamble = Ps_preamble/(log2(2)*snr);
             No_signal = Ps_signal/(log2(2)*snr);
             No_data = Ps_data/(log2(64)*snr);
             
            var_preamble = No_preamble/2;
            var_signal = No_signal/2;
            var_data = No_data/2;
            
            noiseq = randn(1,length(tx_frame)) + 1j*randn(1,length(tx_frame));
            
            awg_noise_preamble = sqrt(var_preamble)*noiseq(1:4*(Nc+guard_len));
            awg_noise_signal = sqrt(var_signal)*noiseq(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            awg_noise_data = sqrt(var_data)*noiseq(5*(Nc+guard_len)+1:end);
            
            awg_noise = [awg_noise_preamble, awg_noise_signal, awg_noise_data];
            Pz = No_data;
            
            tx_frame = tx_frame + awg_noise;
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            % Receiver
            [~, rx_syms_WE] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE', Pz, Ps_data/log2(64));
            [~, rx_syms_ZF] = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF', Pz, Ps_data/log2(64));
    end
   scatterplot(rx_syms_WE,[],[], 'g.');
   scatterplot(rx_syms_ZF,[],[], 'g.');
