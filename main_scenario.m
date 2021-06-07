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
out_decoded=[];
step = 1032*8;
rate= 1/2; mod_type = 'QPSK'; estimation_method = 'WE';
for i=1:step:length(data)
    frame = data(i:min(length(data),i+step-1)); 
    % Tansmitter
    tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
    % Channel
    Rx_frame = conv(tx_frame,conj(h));
    Rx_frame = Rx_frame(1:end-length(h)+1);
    % Receiver
    [decoded, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, estimation_method);
    out_decoded = [out_decoded decoded(1:length(frame))];
end
% Check
BER = sum(out_decoded ~= data)/length(out_decoded)
% Write in file
FileID=fopen('rec_test_file_1.txt','w');
fprintf(FileID,'%c',char(bin2dec(reshape(char(out_decoded+'0'), 8,[]).'))');
fclose(FileID);
%% 4.b) Comparison between the BER performance of the ZF equalizer, and the Weiner equalizer (Floating Point)
step = 1032*8;
snr_dbs = (0:0.5:10);
rate= 3/4; mod_type = '64QAM';
BERs_WE = [];
BERs_ZF = [];
for snr_db = snr_dbs
    out_decoded_WE=[]; out_decoded_ZF=[];
        for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
            % Channel
            %EbN0 = 10^(snr_db/10);
            Ps = sum(abs(tx_frame).^2)/length(tx_frame);
            bps = (4*64*2 + 64*2 + length(frame)*log2(64))/length(tx_frame); %bits per symbol
            No = Ps/(bps*10^(snr_db/10));
            var = No/2;
            noiseq = randn(1,length(tx_frame)) + 1j*randn(1,length(tx_frame));
            awg_noise = sqrt(var)*noiseq;
            tx_frame = tx_frame + awg_noise;
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            % Receiver
            [decoded_WE, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE');
            [decoded_ZF, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF');
            
            out_decoded_WE = [out_decoded_WE decoded_WE(1:length(frame))];
            out_decoded_ZF = [out_decoded_ZF decoded_ZF(1:length(frame))];
        end
        % Check
        BER_ZF = sum(out_decoded_ZF ~= data)/length(out_decoded_ZF);
        BER_WE = sum(out_decoded_WE ~= data)/length(out_decoded_WE);
    BERs_ZF = cat(2, BERs_ZF, BER_ZF);
    BERs_WE = cat(2, BERs_WE, BER_WE);
end
semilogy(BERs_ZF);
hold on;
semilogy(BERs_WE);
hold off;
title('BER for ZF equalizer VS Weiner equalizer with 64QAM modulation with code rate = 3/4');
xlabel('snr (dB)'); ylabel('Bit error rate');
legend('ZF equalizer', 'Weiner equalizer');
%% 4.c) Constellation diagram of the received symbols after equalization using the ZF equalizer
snr = 8; % in dB
out_decoded_WE=[]; out_decoded_ZF=[];
    for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
            % Channel
            Ps = sum(abs(tx_frame).^2)/length(tx_frame);
            bps = (4*64*2 + 64*2 + length(frame)*log2(64))/length(tx_frame); %bits per symbol
            No = Ps/(bps*10^(snr/10));
            var = No/2;
            noiseq = randn(1,length(tx_frame)) + 1j*randn(1,length(tx_frame));
            awg_noise = sqrt(var)*noiseq;
            tx_frame = tx_frame + awg_noise;
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            % Receiver
            [~, rx_data_WE] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE');
            [~, rx_data_ZF] = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF');
    end
   scatterplot(rx_data_WE,[],[], 'g.');
   scatterplot(rx_data_ZF,[],[], 'g.');
%% 4.e) Comparison between the BER performance of all supported rates using the floating-point implementation.
snr_dbs = (0:0.5:8);
n_experiments = 1;
rates= [1/2, 3/4, 1/2, 3/4, 1/2, 3/4, 2/3, 3/4];
Ms = [2, 2, 4, 4, 16, 16, 64, 64];
mod_types = ["BPSK","BPSK","QPSK", "QPSK", "16QAM", "16QAM", "64QAM", "64QAM"];
bpsyms = [1,1,2,2,4,4,6,6];
for j=1:length(rates)
 rate = rates(j); mod_type=mod_types(j); bps = Ms(j); 
 BERs = [];
 for snr_db = snr_dbs
    BER = 0;
    for exp_index=1:n_experiments
        out_decoded=[];
        for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
            % Channel
            Ps = sum(abs(tx_frame).^2)/length(tx_frame);
            bps = (4*64*2 + 64*2 + length(frame)*log2(64))/length(tx_frame); %bits per symbol
            No = Ps/(bps*10^(snr/10));
            var = No/2;
            noiseq = randn(1,length(tx_frame)) + 1j*randn(1,length(tx_frame));
            awg_noise = sqrt(var)*noiseq;
            tx_frame = tx_frame + awg_noise;
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            % Receiver
            decoded = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF');
            out_decoded = [out_decoded decoded(1:length(frame))];
        end
        % Check
        BER = BER + sum(out_decoded ~= data)/length(out_decoded);
    end
    BERs = cat(2, BERs, BER/n_experiments);
 end
    semilogy(snr_dbs, BERs);
    hold on;
end

hold off;
title('BER vs SNR for different modulation types and code rates');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
legend('BPSK 1/2','BPSK 3/4','QPSK 1/2','QPSK 3/4','16QAM 1/2','16QAM 3/4','64QAM 2/3','64QAM 3/4');
hold off;