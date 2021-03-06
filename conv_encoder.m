function [codedData] = conv_encoder(data,rate)
% ARGUMENTS
    % data: data to be encoded
    % rate: code rate for channel encoding
% OUTPUTS
    % codedData: the resulting data after convolutional coding

%g0=[1 0 1 1 0 1 1];
%g1=[1 1 1 1 0 0 1];
trellis = poly2trellis(7,[133 171]);
switch rate
    case 1/2
        codedData = convenc(data,trellis);
    case 3/4
        punctpat = [1 1 1 0 0 1];
        if rem(length(data)*2,length(punctpat))
            padding = length(punctpat)-rem(length(data)*2,length(punctpat));
            data = [data zeros(1,padding/2)];
        end
        codedData = convenc(data,trellis,punctpat);
        %truncate = length(data)/rate;
        %codedData = codedData(1:truncate);
    case 2/3
        punctpat = [1 1 1 0];
        if rem(length(data)*2,length(punctpat))
            padding = length(punctpat)-rem(length(data)*2,length(punctpat));
            data = [data zeros(1,padding/2)];
        end
        codedData = convenc(data,trellis,punctpat);
end
