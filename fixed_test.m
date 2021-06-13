clear; clc; close all;
global noise_power
global data_power
global M
gray_scheme_64QAM = [4 5 7 6 2 3 1 0 
                       12 13 15 14 10 11 9 8
                       28 29 31 30 26 27 25 24
                       20 21 23 22 18 19 17 16
                       52 53 55 54 50 51 49 48
                       60 61 63 62 58 59 57 56
                       44 45 47 46 42 43 41 40
                       36 37 39 38 34 35 33 32];
%% Main Scenario script
Nc = 64; guard_len = 16; %OFDM parameters
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
data_power = 1;
out_decoded=[];
step = 1032*8;
rate= 3/4; mod_type = '16QAM'; estimation_method = 'WE'; M = 16;
for i=1:step:length(data)
    frame = data(i:min(length(data),i+step-1)); 
    % Tansmitter
    tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len,'Fixed');
    % Channel
    Rx_frame = conv(tx_frame,conj(h));
    Rx_frame = Rx_frame(1:end-length(h)+1);
    noise_power = 0;
    % Receiver
    [decoded, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, estimation_method,'Fixed');
    out_decoded = cat(2, out_decoded, decoded(1:length(frame)));
end
% Check
BER = sum(out_decoded ~= data)/length(out_decoded)
% Write in file
FileID=fopen('rec_test_file_1.txt','w');
fprintf(FileID,'%c',char(bin2dec(reshape(char(out_decoded+'0'), 8,[]).'))');
fclose(FileID);

%% 4.b) Comaprison of BER perfomance with ZF equalizer and Weiner equalizer

step = 1032*8;
snr_dbs = 5; snrs = 10.^(snr_dbs/10);
rate= 3/4; mod_type = '64QAM'; M = 64;
BERs_WE = []; BERs_ZF = []; 

for snr = snrs
out_decoded_WE=[]; out_decoded_ZF=[];
    for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len,'Fixed');
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            
            % AWGN Channel
            preamble_part = Rx_frame(1:4*(Nc+guard_len));
            signal_part = Rx_frame(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            data_part = Rx_frame(5*(Nc+guard_len)+1:end);
             
            Ps_preamble = sum(abs(preamble_part).^2)/length(preamble_part);
            Ps_signal = sum(abs(signal_part).^2)/length(signal_part);
            Ps_data = sum(abs(data_part).^2)/(log2(64)*length(data_part));
             
            No_preamble = Ps_preamble/(log2(2)*snr);
            No_signal = Ps_signal/(log2(2)*snr);
            No_data = Ps_data/(6*snr);
             
            var_preamble = No_preamble/2;
            var_signal = No_signal/2;
            var_data = No_data/2;
            noise_power = No_data;
            data_power = Ps_data; 
            
            noiseq = randn(1,length(Rx_frame)) + 1j*randn(1,length(Rx_frame));
            awg_noise_preamble = sqrt(var_preamble)*noiseq(1:4*(Nc+guard_len));
            awg_noise_signal = sqrt(var_signal)*noiseq(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            awg_noise_data = sqrt(var_data)*noiseq(5*(Nc+guard_len)+1:end);
            
            preamble_part = preamble_part + awg_noise_preamble;
            data_part = data_part + awg_noise_data;
            Rx_frame = [preamble_part, signal_part, data_part];
           
            % Receiver 
            [decoded_WE, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE','Fixed');
            [decoded_ZF, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF','Fixed');
            out_decoded_WE = cat(2, out_decoded_WE, decoded_WE(1:length(frame)));
            out_decoded_ZF = cat(2, out_decoded_ZF, decoded_ZF(1:length(frame)));
    end
   BER_WE = sum(out_decoded_WE ~= data)/length(out_decoded_WE);
   BER_ZF = sum(out_decoded_ZF ~= data)/length(out_decoded_ZF);
   BERs_ZF_fixed = cat(2, BERs_ZF, BER_ZF)
   BERs_WE_fixed = cat(2, BERs_WE, BER_WE)
end
   %semilogy(snr_dbs, BERs_ZF,'b-*', snr_dbs, BERs_WE,'r-*');
   %title('BER performance using ZF equalizer VS LMMSE equalizer with 64QAM & code rate = 3/4');
   %xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate');
   %legend('ZF_fixed', 'LMMSE_fixed ');
   %hold on;
%%%%4.b) Comaprison of BER perfomance with ZF equalizer and Weiner equalizer

step = 1032*8;
%snr_dbs = 5; snrs = 10.^(snr_dbs/10);
rate= 3/4; mod_type = '64QAM'; M = 64;
BERs_WE = []; BERs_ZF = []; 

for snr = snrs
out_decoded_WE=[]; out_decoded_ZF=[];
    for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            tx_frame= WiFi_transmitter(frame, mod_type, rate, Nc, guard_len,'Float');
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            
            % AWGN Channel
            preamble_part = Rx_frame(1:4*(Nc+guard_len));
            signal_part = Rx_frame(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            data_part = Rx_frame(5*(Nc+guard_len)+1:end);
             
            Ps_preamble = sum(abs(preamble_part).^2)/length(preamble_part);
            Ps_signal = sum(abs(signal_part).^2)/length(signal_part);
            Ps_data = sum(abs(data_part).^2)/(log2(64)*length(data_part));
             
            No_preamble = Ps_preamble/(log2(2)*snr);
            No_signal = Ps_signal/(log2(2)*snr);
            No_data = Ps_data/(6*snr);
             
            var_preamble = No_preamble/2;
            var_signal = No_signal/2;
            var_data = No_data/2;
            noise_power = No_data;
            data_power = Ps_data; 
            
            noiseq = randn(1,length(Rx_frame)) + 1j*randn(1,length(Rx_frame));
            awg_noise_preamble = sqrt(var_preamble)*noiseq(1:4*(Nc+guard_len));
            awg_noise_signal = sqrt(var_signal)*noiseq(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            awg_noise_data = sqrt(var_data)*noiseq(5*(Nc+guard_len)+1:end);
            
            preamble_part = preamble_part + awg_noise_preamble;
            data_part = data_part + awg_noise_data;
            Rx_frame = [preamble_part, signal_part, data_part];
           
            % Receiver 
            [decoded_WE, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE','Float');
            [decoded_ZF, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF','Float');
            out_decoded_WE = cat(2, out_decoded_WE, decoded_WE(1:length(frame)));
            out_decoded_ZF = cat(2, out_decoded_ZF, decoded_ZF(1:length(frame)));
    end
   BER_WE = sum(out_decoded_WE ~= data)/length(out_decoded_WE);
   BER_ZF = sum(out_decoded_ZF ~= data)/length(out_decoded_ZF);
   BERs_ZF = cat(2, BERs_ZF, BER_ZF)
   BERs_WE = cat(2, BERs_WE, BER_WE)
end
   %semilogy(snr_dbs, BERs_ZF,'b-*', snr_dbs, BERs_WE,'r-*');
   %title('BER performance using ZF equalizer VS LMMSE equalizer with 64QAM & code rate = 3/4');
   %xlabel('E_b/N_0 (dB)'); ylabel('Bit error rate');
   %legend('ZF', 'LMMSE ');
   %grid on;
   %% 4.c) Constellation diagram of the received symbols after equalization using the ZF equalizer and weiner equalizer

step = 1032*8;
snr_db = 20; snr = 10.^(snr_db/10);
rate= 3/4; mod_type = '64QAM'; M = 64;

symbols_WE=[]; symbols_ZF=[]; symbols_recv=[];
    for i=1:step:0.01*length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            [tx_frame, data_freq] = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            
            
            % AWGN Channel
            preamble_part = Rx_frame(1:4*(Nc+guard_len));
            signal_part = Rx_frame(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            data_part = Rx_frame(5*(Nc+guard_len)+1:end);
             
            Ps_preamble = sum(abs(preamble_part).^2)/length(preamble_part);
            Ps_signal = sum(abs(signal_part).^2)/length(signal_part);
            Ps_data = sum(abs(data_part).^2)/(log2(64)*length(data_part));
             
            No_preamble = Ps_preamble/(log2(2)*snr);
            No_signal = Ps_signal/(log2(2)*snr);
            No_data = Ps_data/(6*snr);
             
            var_preamble = No_preamble/2;
            var_signal = No_signal/2;
            var_data = No_data/2;
            noise_power = No_data;
            data_power = Ps_data; 
            
            noiseq = randn(1,length(Rx_frame)) + 1j*randn(1,length(Rx_frame));
            awg_noise_preamble = sqrt(var_preamble)*noiseq(1:4*(Nc+guard_len));
            awg_noise_signal = sqrt(var_signal)*noiseq(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            awg_noise_data = sqrt(var_data)*noiseq(5*(Nc+guard_len)+1:end);
            
            preamble_part = preamble_part + awg_noise_preamble;
            data_part = data_part + awg_noise_data;
            Rx_frame = [preamble_part, signal_part, data_part];
           
            % Receiver 
            [~,rx_syms, rx_syms_WE] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE');
            [decoded_ZF, rx_syms, rx_syms_ZF] = WiFi_receiver(Rx_frame, Nc, guard_len, 'ZF');
            symbols_WE = cat(2, symbols_WE, rx_syms_WE);
            symbols_ZF = cat(2, symbols_ZF, rx_syms_ZF);
            symbols_recv = cat(2, symbols_recv, rx_syms);
    end
cmx_vec = QAM_mapping_reference(64, gray_scheme_64QAM, 1/sqrt(42));
figure 
scatter(real(symbols_WE), imag(symbols_WE),[],'g*')
hold on
scatter(real(cmx_vec), imag(cmx_vec),[],'r+')
grid on
legend('LMMSE equalizer', 'reference symbols');
title('LMMSE equalizer');

figure 
scatter(real(symbols_ZF), imag(symbols_ZF),[],'g*')
hold on
scatter(real(cmx_vec), imag(cmx_vec),[],'r+')
grid on
legend('ZF equalizer', 'reference symbols');
title('ZF equalizer');

%% 4.e) Comparison between the BER performance of all supported rates using the floating-point implementation.

snr_dbs = (1:1:10); snrs = 10.^(snr_dbs/10);
rates= [1/2, 3/4, 1/2, 3/4, 1/2, 3/4, 2/3, 3/4];
mod_types = ["BPSK","BPSK","QPSK", "QPSK", "16QAM", "16QAM", "64QAM", "64QAM"];
Ms = [2, 2, 4, 4, 16, 16, 64, 64];
colors = ["#964B00",'b','g','r','y','k','m','c']; % fol plotting

for j=1:length(rates)
 rate = rates(j); mod_type=mod_types(j); M = Ms(j);
 BERs_WE = [];
 for snr = snrs
    out_decoded_WE=[];
    for i=1:step:length(data)
            frame = data(i:min(length(data),i+step-1)); 
            % Tansmitter
            [tx_frame, ~] = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);
            Rx_frame = conv(tx_frame,conj(h));
            Rx_frame = Rx_frame(1:end-length(h)+1);
            
            % AWGN Channel
            preamble_part = Rx_frame(1:4*(Nc+guard_len));
            signal_part = Rx_frame(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            data_part = Rx_frame(5*(Nc+guard_len)+1:end);
             
            Ps_preamble = sum(abs(preamble_part).^2)/length(preamble_part);
            Ps_signal = sum(abs(signal_part).^2)/length(signal_part);
            Ps_data = sum(abs(data_part).^2)/(log2(64)*length(data_part));
             
            No_preamble = Ps_preamble/(log2(2)*snr);
            No_signal = Ps_signal/(log2(2)*snr);
            No_data = Ps_data/(log2(M)*snr);
             
            var_preamble = No_preamble/2;
            var_signal = No_signal/2;
            var_data = No_data/2;
            noise_power = No_data;
            data_power = Ps_data; 
            
            noiseq = randn(1,length(Rx_frame)) + 1j*randn(1,length(Rx_frame));
            awg_noise_preamble = sqrt(var_preamble)*noiseq(1:4*(Nc+guard_len));
            awg_noise_signal = sqrt(var_signal)*noiseq(4*(Nc+guard_len)+1:5*(Nc+guard_len));
            awg_noise_data = sqrt(var_data)*noiseq(5*(Nc+guard_len)+1:end);
            
            preamble_part = preamble_part + awg_noise_preamble;
            data_part = data_part + awg_noise_data;
            Rx_frame = [preamble_part, signal_part, data_part];
           
            % Receiver 
            [decoded_WE, ~] = WiFi_receiver(Rx_frame, Nc, guard_len, 'WE');
            out_decoded_WE = cat(2, out_decoded_WE, decoded_WE(1:length(frame)));
    end
   BER_WE = sum(out_decoded_WE ~= data)/length(out_decoded_WE);
   BERs_WE = cat(2, BERs_WE, BER_WE);
end
    semilogy(snr_dbs, BERs_WE, 'color',colors(j));
    hold on;
end

hold off;
title('BER vs SNR for different modulation types and code rates');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
legend('BPSK 1/2','BPSK 3/4','QPSK 1/2','QPSK 3/4','16QAM 1/2','16QAM 3/4','64QAM 2/3','64QAM 3/4');
hold off;
grid on;

  


