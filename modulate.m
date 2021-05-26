function [mapped_stream, additional] = modulate(input_stream, input_type, mod_type, coding_scheme_vec)
%% modulate: This function perform modulation for input data (binary or symbols) with multiple modulation schemes
% Parameters: 
    % input_stream: a row vector of the input data
    % input_type: the type of input_stream 'binary' or 'symbols'
    % mod_type: the needed modulation schemce (N-QAM, PSK, QPSK)
% Returns:
    % mapped_stream: the output modulated complex symbols
    % additional: additional information depending on mod_type. In case of
                 % QAM, it's the needed reference vector for demodulation
%% ---------------------------------------------------------------- %%
 % Get the number of symbols for mod_type
 if strcmpi(mod_type, 'BPSK')
    N = 2;
 elseif strcmpi(mod_type,'QPSK')
    N = 4;
 elseif strcmpi(mod_type,'16QAM')
    N = 16;
 elseif strcmpi(mod_type,'64QAM')
    N = 64;
 end

 % Binary data conversion 
if strcmpi(input_type,'binary')
    % --- Zero Padding for correct dimensions
    if rem(length(input_stream), log2(N)) ~= 0
        input_stream =  padarray(input_stream, [0, log2(N)-ceil(rem(length(input_stream),log2(N)))], 0, 'post');
    end
    binary_data = reshape(input_stream, log2(N), [])';
    stream = bi2de(binary_data, 'left-msb')';
else
    stream = input_stream;
end

%  Modulation
additional = 0; Kmod = 1; %initialization
 %-- check if coding scheme is passed
if nargin < 4
   coding_scheme_vec = -1; %default value in case of no specific coding scheme 
end

   if strcmpi(mod_type, '16QAM') || strcmpi(mod_type, '64QAM') || strcmpi(mod_type, 'QPSK')
      Kmod = 1/sqrt(10); %IEEE-11.802a standard
      [mapped_stream, additional] = modulate_QAM(N, stream, Kmod, coding_scheme_vec);
   elseif strcmpi(mod_type, 'BPSK')
      mapped_stream = stream; 
      mapped_stream(mapped_stream == 0) = -1;
   else
       disp('Invalid modulation type');
       return
   end
   additional = additional * Kmod;
end