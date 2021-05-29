clear; clc; close all;

%% Main Scenario script
Nc = 64; guard_len = 16; % OFDM parameters
rate= 1/2; mod_type = '16qam';

FileID=fopen('test_file_1.txt','r');                       %open the file in read mode                                                                  
%Reading the file
data=[];
while ~feof(FileID)
    data=[data fscanf(FileID,'%c')];                      %read the text file char by char
end
fclose(FileID);
data = reshape(dec2bin(data, 8).'-'0',1,[]);

%% Transmitter
out_decoded=[];
for i=1:8000:length(data)
    frame = data(i:min(length(data),i+7999)); 
    tx_frame = WiFi_transmitter(frame, mod_type, rate, Nc, guard_len);


    % Channel
    h = [0.8208 + 0.2052*1i, 0.4104 + 0.1026*1i, 0.2052 + 0.2052*1i, 0.1026 + 0.1026*1i];
    Rx_frame = conv(tx_frame,conj(h));
    Rx_frame = Rx_frame(1:end-length(h)+1);
    % Receiver
    out_decoded = [out_decoded WiFi_receiver(Rx_frame, Nc, guard_len)];
end
%% Check
BER = sum(out_decoded ~= data)/length(out_decoded);
disp(BER);
FileID=fopen('rec_test_file_1.txt','w');
fprintf(FileID,'%c',char(bin2dec(reshape(char(out_decoded+'0'), 8,[]).'))');
fclose(FileID)

