 clear; clc;
 mod_type = '16qam';
 
 gray_scheme = [2 3 1 0 6 7 5 4 14 15 13 12 10 11 9 8];
 %% Symbols Trial   
 tx_data = randi([0,15], [1, 122]);
   % Modulation
 [mapped_stream,~] = modulate(tx_data, 'symbols', mod_type, gray_scheme);
  % Demodulation
 rx_stream = demodulate(mapped_stream, mod_type,'symbols', gray_scheme);
  % Check
 sum(rx_stream(1:length(tx_data)) ~= tx_data)
 %% Binary Trial

 tx_data = randi([0,1],[1,211]);
 % Modulation
 [mapped_stream,ref_demoulator] = modulate(tx_data, 'binary', mod_type, gray_scheme);
  % Demodulation
 rx_stream = demodulate(mapped_stream, mod_type, 'binary', gray_scheme);
 
 scatterplot(mapped_stream,[],[],'y*');
 
sum(rx_stream(1:length(tx_data)) ~= tx_data)
