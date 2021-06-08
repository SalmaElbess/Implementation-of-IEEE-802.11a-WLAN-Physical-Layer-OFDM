function equalized_data = equalize_channel(data,channel_gains,equalization_method, Pz, Px)
%The function equalize the channel effect on the data given the channel 
%gains. The function removes the pilots subcarriers and returns the
%equalized data.
%
%inputs:
%       data: array of transimmitted data without pilots or nulls
%             subcarriers. Each OFDM symbol of the data is 48 subcarrier.
%       channel_gains: array of shape 1*52 of the channel estimated gains.
%       it includes the pilots channel gains. 
%       equalization_method:
%output:
%       equalized_data: array of equalized data. Each OFDM symbol isnside
%       this array is 48 subcarrier long.

pilots_indecies = [32, 45, 7, 21];
data_indecies = setdiff((1:52), pilots_indecies);
if strcmpi(equalization_method,'ZF')
    %remove pilots channel gains

    data_channel_gains = channel_gains(data_indecies);
    for i = 1:48:length(data)
        equalized_data(i:i+47) = data(i:i+47)./data_channel_gains;
    end
else
    data_channel_gains = channel_gains(data_indecies);
    W = conj(data_channel_gains)./((abs(data_channel_gains)).^2+(Pz/Px));
    for i = 1:48:length(data)
        equalized_data(i:i+47) = data(i:i+47).*W;
    end
end
end