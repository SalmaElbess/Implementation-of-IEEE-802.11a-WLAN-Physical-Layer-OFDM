function equalized_data = equalize_channel(data,channel_gains,equalization_method)
if equalization_method == 'ZF'
    pilots_indecies = [32, 45, 7, 21];
    data_indecies = setdiff((1:52), pilots_indecies);
    data_channel_gains = channel_gains(data_indecies);
    equalized_data = zeros(size(data));
    for i = 1:48:length(data)
        equalized_data(i:i+47) = data(i:i+47).*data_channel_gains;
    end
end
sum(abs(equalized_data - data) )
end