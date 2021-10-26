# Implementation-of-IEEE-802.11a-WLAN-Physical-Layer-OFDM

Functions Help! 
 
 * The main.m script does the job needed for the project. (Impmented by the whole team members
 
The following functions are implemented by Elsayed Mostafa (s-ayedmmostafa@zewailcity.edu.eg)
 - WiFi_receiver: This function performs all required steps to receive complex symbols and convert them to binary data using WiFi
 - WiFi_transmitter: This function performs all required steps to transmit binary data using WiFi 
 - modulate: This function perform modulation for input data (binary or symbols) with multiple modulation schemes 
 - demodulate: This function perform demodulation for input complex symbols with multiple modulation schemes
 - modulate_QAM: This function construct the modulated symbols for N-QAM modulation 
 - QAM_mapping_reference: This function computes the reference complex symbols used for QAM modulation and demodulation

The following functions are implemented by Salma Elbess (s-salmahasanelemam@zewailcity.edu.eg)
 - equalize_channel: The function equalizes the channel effect on the data given the channel gains. The function removes the pilots subcarriers and returns the equalized data.
 - estimate_channel: The function estimates the channel effects using recieved preamble long symbols and the ture long preamble values and returns the estimated gains. 

The following functions are implemented by Shaimaa Hassanen (s-shaimaa_said@zewailcity.edu.eg )
 - conv_encoder: apply the convolutional encoding
 - viterbi_decoder: apply the viterbi decoding algorithm

The following functions are implemented by Mohammed Younis (s-mohammedyounis@zewailcity.edu.eg )
 - construct_frame: To construct the frame to be sent (before OFDM)
