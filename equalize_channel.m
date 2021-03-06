function equalized_data = equalize_channel(data,channel_gains,equalization_method,imp_type)
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
global data_power
global noise_power
global M
data_power = data_power;

pilots_indecies = [32, 45, 7, 21];
data_indecies = setdiff((1:52), pilots_indecies);
if strcmpi(equalization_method,'ZF')
    %remove pilots channel gains
    data_channel_gains = channel_gains(data_indecies);
    if strcmpi(imp_type,'Fixed')
        for i = 1:48:length(data)
        equalized_data(i:i+47) = divide(numerictype(data_channel_gains),data(i:i+47),data_channel_gains);
        end
    else
        for i = 1:48:length(data)
            equalized_data(i:i+47) = data(i:i+47)./data_channel_gains;
        end
    end
else
    data_channel_gains = channel_gains(data_indecies);
    if strcmpi(imp_type,'Fixed')
        W = divide(numerictype(data_channel_gains),conj(data_channel_gains),((abs(data_channel_gains)).^2+(noise_power.data/(data_power.data/log2(M)))));
        for i = 1:48:length(data)
        equalized_data(i:i+47) = data(i:i+47).*W;
        end
    else
        W = conj(data_channel_gains)./((abs(data_channel_gains)).^2+(noise_power/(data_power/log2(M))));
        for i = 1:48:length(data)
            equalized_data(i:i+47) = data(i:i+47).*W;
        end
    end
    
   
end
end
