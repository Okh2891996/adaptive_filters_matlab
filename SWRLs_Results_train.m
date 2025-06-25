clc; clear; close all;

%% Define Parameters
num_speakers = 30;  % Number of speakers (sp01 to sp30)
snr_levels = {'0dB'};  % Example: {'0dB', '5dB', '10dB', ...}
snr_values = {'0'};  % Remove "dB" for filenames, e.g., {'0', '5', '10'}
filter_lengths = [4, 8, 16, 32, 64];  % Different filter lengths
windowsize = [20, 50, 100, 200, 300];  % Different window sizes

%% Initialize Storage for SNR, MSE, and Execution Time Results
snr_before_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(windowsize));
snr_after_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(windowsize));
mse_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(windowsize));
execution_time_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(windowsize));

%% Open File for Writing Results
fileID = fopen('SWRLS_results_train.txt', 'w');
fprintf(fileID, 'Summary of SNR, MSE, and Execution Time Results Across 30 Speakers\n');
fprintf(fileID, 'Speaker | Noise | Filter Length | Window Size | SNR Before (dB) | SNR After (dB) | MSE | Time (s)\n');
fprintf(fileID, '------------------------------------------------------------------\n');

%% Process Each Speaker
for s = 1:num_speakers
    speaker_id = sprintf('sp%02d', s);  % Format speaker ID (e.g., sp01, sp02, ..., sp30)
    
    % Load Clean Speech
    clean_file = sprintf('NOIZEUS/clean_noizeus/wav/%s.wav', speaker_id);
    [y_clean, Fs] = audioread(clean_file);
    
    % Process Each Noise Level
    for i = 1:length(snr_levels)
        % Load Noisy Speech
        noisy_file = sprintf('NOIZEUS/train_%s/wav/%s_train_sn%s.wav', snr_levels{i}, speaker_id, snr_values{i});
        [y_noisy, ~] = audioread(noisy_file);

        % Loop over each combination of filter length and window size
        for j = 1:length(filter_lengths)
            for k = 1:length(windowsize)
                filter_length = filter_lengths(j);  % Set filter length
                window_size = windowsize(k);        % Set window size

                % Ensure the window size is greater than or equal to filter length
                if window_size < filter_length
                    fprintf('Skipping: Window size %d is smaller than filter length %d\n', window_size, filter_length);
                    continue;  % Skip this combination
                end

                % Start timing the execution
                tic;

                % Apply swrls_filter using the Clean Speech as reference
                y_ref = y_noisy - y_clean;
                [y_filtered, error_signal] = swrls_filter(y_noisy, y_ref, filter_length, window_size);
                y_output = y_noisy - y_filtered;

                % Stop timing the execution
                execution_time = toc;

                % Compute SNR Before and After Filtering
                snr_before = snr(y_clean, y_clean - y_noisy);
                snr_after = snr(y_clean, y_output - y_clean);
                
                % Compute MSE (Mean Squared Error)
                mse_value = mean((y_clean - y_output).^2);

                % Store SNR, MSE, and execution time values
                snr_before_all(s, i, j, k) = snr_before;
                snr_after_all(s, i, j, k) = snr_after;
                mse_all(s, i, j, k) = mse_value;
                execution_time_all(s, i, j, k) = execution_time;
                
                % Write individual results to the file
                fprintf(fileID, '%d | %s | %d | %d | %.2f | %.2f | %.6f | %.4f\n', ...
                    s, snr_levels{i}, filter_length, window_size, snr_before, snr_after, mse_value, execution_time);
            end
        end
    end
end

%% Compute and Display Average SNR, MSE, and Execution Time for Each Parameter
fprintf(fileID, '\nSummary of Average SNR, MSE, and Execution Time Results Across 30 Speakers:\n');
for j = 1:length(filter_lengths)
    for k = 1:length(windowsize)
        avg_snr_before = mean(snr_before_all(:, :, j, k), 'all');
        avg_snr_after = mean(snr_after_all(:, :, j, k), 'all');
        avg_mse = mean(mse_all(:, :, j, k), 'all');
        avg_execution_time = mean(execution_time_all(:, :, j, k), 'all');
        
        fprintf(fileID, 'Filter Length %d, Window Size %d: Average SNR Before = %.2f dB, Average SNR After = %.2f dB, Average MSE = %.6f, Average Time = %.4f s\n', ...
            filter_lengths(j), windowsize(k), avg_snr_before, avg_snr_after, avg_mse, avg_execution_time);
    end
end

%% Close the File
fclose(fileID);

fprintf('Results saved to SWRLS_results_train.txt\n');
