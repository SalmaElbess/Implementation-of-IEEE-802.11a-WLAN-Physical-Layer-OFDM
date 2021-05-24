 clear; clc;
 mod_type = '16qam';
 
 %% Symbols Trial   
 tx_data = randi([0,15], [1, 122]);
   % Modulation
 [mapped_stream,ref_demoulator] = modulate(tx_data, 'symbols', mod_type);
  % Demodulation
 rx_stream = demodulate(mapped_stream, mod_type, ref_demoulator, 'symbols');
  % Check
 sum(rx_stream(1:length(tx_data)) ~= tx_data)
 %% Binary Trial

 tx_data = randi([0,1],[1,211]);
 % Modulation
 [mapped_stream,ref_demoulator] = modulate(tx_data, 'binary', mod_type);
  % Demodulation
 rx_stream = demodulate(mapped_stream, mod_type, ref_demoulator, 'binary');
 
 scatterplot(mapped_stream,[],[],'y*');
 
sum(rx_stream(1:length(tx_data)) ~= tx_data)
