% Preamble
S = sqrt(13/6)*[0 0 1+1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 0 0 0 -1-1i 0 0 0 -1-1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0 0 1+1i 0 0];
L = [1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 1 1 1 1 -1 -1 1 1 -1 1 -1 1 -1 -1 -1 -1 -1 1 1 -1 -1 1 -1 1 -1 1 1 1 1];

data=conv_encoder(data, CR);
% Rate
if strcmp(modulatation,'BPSK') && CR == 1/2
    R='1101';
elseif strcmp(modulatation,'BPSK') && CR == 3/4
    R='1111';
elseif strcmp(modulatation,'QPSK') && CR == 1/2
    R='0101';
elseif strcmp(modulatation,'QPSK') && CR == 3/4
    R='0111';
elseif strcmp(modulatation,'16QAM') && CR == 1/2
    R='1001';
elseif strcmp(modulatation,'16QAM') && CR == 3/4
    R='1011';
elseif strcmp(modulatation,'64QAM') && CR == 2/3
    R='0001';
elseif strcmp(modulatation,'64QAM') && CR == 3/4
    R='0011';    
end

% Length
len = dec2bin(1000,12);

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
pad ='000';

% Frame construction
preamble = [S S L L];
signal = [str2num(R')' str2num(len')' str2num(parity) str2num(tail')' str2num(pad')'];
signal = conv_encoder(signal, 1/2);
signal = modulate(signal, 'binary', 'bpsk');

%frame = [S S L L str2num(R')' str2num(len')' str2num(parity) str2num(tail')' str2num(pad')' data];
