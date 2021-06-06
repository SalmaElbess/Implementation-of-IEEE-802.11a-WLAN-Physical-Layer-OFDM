function [preamble, signal, data] = construct_frame(data, mod_type, CR)
% ARGUMENTS
    % data: 1000 byte of binary data to be put into a frame
    % mod_type: the needed modulation schemce (N-QAM, BPSK, QPSK)
    % CR: code rate for convolutional encoder
% OUTPUTS
    % preamble: two OFDM symbols (without nulls) for preamble
    % signal: one OFDM symbol (52 sample) for control information
    % data: the output data after modulation and channel coding
    
    S = sqrt(13/6)*[0 0 1+1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0];
    L = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];
    gray_scheme_64QAM = [4 5 7 6 2 3 1 0 
                       12 13 15 14 10 11 9 8
                       28 29 31 30 26 27 25 24
                       20 21 23 22 18 19 17 16
                       52 53 55 54 50 51 49 48
                       60 61 63 62 58 59 57 56
                       44 45 47 46 42 43 41 40
                       36 37 39 38 34 35 33 32]; 
    
    % Rate
    if strcmpi(mod_type,'BPSK') && CR == 1/2
        R='1101';
        gray_scheme = -1;
    elseif strcmpi(mod_type,'BPSK') && CR == 3/4
        R='1111';
        gray_scheme = -1;
    elseif strcmpi(mod_type,'QPSK') && CR == 1/2
        R='0101';
        gray_scheme = [1 0 3 2];
    elseif strcmpi(mod_type,'QPSK') && CR == 3/4
        R='0111';
        gray_scheme = [1 0 3 2];
    elseif strcmpi(mod_type,'16QAM') && CR == 1/2
        R='1001';
        gray_scheme = [2 3 1 0 6 7 5 4 14 15 13 12 10 11 9 8];
    elseif strcmpi(mod_type,'16QAM') && CR == 3/4
        R='1011';
        gray_scheme = [2 3 1 0 6 7 5 4 14 15 13 12 10 11 9 8];
    elseif strcmpi(mod_type,'64QAM') && CR == 2/3
        R='0001';
        gray_scheme = gray_scheme_64QAM;
    elseif strcmpi(mod_type,'64QAM') && CR == 3/4
        R='0011'; 
        gray_scheme = gray_scheme_64QAM;
    end

    % Length %%%%%%%%%%%%%%%%%%%%%%%?? before or after conv encoding
    len = dec2bin(length(data)/8,12);

    % Parity
    num_ones = count([len R],'1');
    if rem(num_ones,2)
        parity='1';
    else 
        parity='0';
    end

    % Tail
    tail ='000000';

    % Pad
    pad ='000'; % three zeros to make the length of the signal field equals to 52 channel coding

    % Frame construction
    preamble = [S S L L];
    signal = [str2num(R')' str2num(len')' str2num(parity) str2num(tail')' str2num(pad')'];
    signal = conv_encoder(signal, 1/2);
    signal = modulate(signal, 'binary', 'bpsk');
    data = conv_encoder(data, CR);
    [data,~] = modulate(data, 'binary', mod_type, gray_scheme);
    %frame = [S S L L str2num(R')' str2num(len')' str2num(parity) str2num(tail')' str2num(pad')' data];
end

