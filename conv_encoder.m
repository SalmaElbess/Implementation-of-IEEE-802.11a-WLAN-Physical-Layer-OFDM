function [codedData] = conv_encoder(data,rate)
% ARGUMENTS
    % data: data to be encoded
    % rate: code rate for channel encoding
% OUTPUTS
    % codedData: the resulting data after convolutional coding

%g0=[1 0 1 1 0 1 1];
%g1=[1 1 1 1 0 0 1];
trellis = poly2trellis(7,[133 171]);
codedData = convenc(data,trellis);
end