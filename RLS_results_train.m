clc; clear; close all;

%% Define Parameters
num_speakers = 30;  % Number of speakers (sp01 to sp30)
snr_levels = {'0dB'};
snr_values = {'0'};  % Remove "dB" for filenames
filter_lengths = [4, 8, 16, 32, 64];  % Different filter lengths
lambdas = [0.9 ,0.95, 0.98, 1];      % Different forgetting factors

%% Initialize Storage for SNR, MSE, and Execution Time Results
snr_before_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(lambdas));
snr_after_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(lambdas));
mse_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(lambdas));
execution_time_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(lambdas));

%% Open File to Save Results
fileID = fopen('RLS_train_results.txt', 'w');

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
        
        % Loop over each combination of filter length and forgetting factor
        for j = 1:length(filter_lengths)
            for k = 1:length(lambdas)
                filter_length = filter_lengths(j);  % Set filter length
                lambda = lambdas(k);                % Set forgetting factor
                
                % Start timing the execution
                tic;

                % Apply RLS Filter using the Clean Speech as reference
                y_ref = y_noisy - y_clean;
                [y_filtered, error_signal, ~] = rls_filter(y_noisy, y_ref, filter_length, lambda);
                y_output = y_noisy - y_filtered;

                % Stop timing the execution
                execution_time = toc;

                % Compute SNR Before and After Filtering
                snr_before = snr(y_clean, y_clean - y_noisy);
                snr_after = snr(y_clean, y_output - y_clean);
                
                % Compute MSE (Mean Squared Error)
                mse = mean((y_output - y_clean).^2);

                % Store SNR, MSE, and execution time values
                snr_before_all(s, i, j, k) = snr_before;
                snr_after_all(s, i, j, k) = snr_after;
                mse_all(s, i, j, k) = mse;
                execution_time_all(s, i, j, k) = execution_time;

                % Display SNR Improvement
                fprintf('Speaker %d | Noise (%s) | Filter Length %d | Lambda %.2f: Before = %.2f dB, After = %.2f dB, MSE = %.5f, Time = %.4f s\n', ...
                    s, snr_levels{i}, filter_length, lambda, snr_before, snr_after, mse, execution_time);

                % Save the results to the file
                fprintf(fileID, 'Speaker %d | Noise (%s) | Filter Length %d | Lambda %.2f: Before = %.2f dB, After = %.2f dB, MSE = %.5f, Time = %.4f s\n', ...
                    s, snr_levels{i}, filter_length, lambda, snr_before, snr_after, mse, execution_time);
            end
        end
    end
end

%% Compute and Display Average SNR, MSE, and Execution Time for Each Parameter
fprintf('\nSummary of Average SNR, MSE, and Execution Time Results Across 30 Speakers:\n');
for j = 1:length(filter_lengths)
    for k = 1:length(lambdas)
        avg_snr_before = mean(snr_before_all(:, :, j, k), 'all');
        avg_snr_after = mean(snr_after_all(:, :, j, k), 'all');
        avg_mse = mean(mse_all(:, :, j, k), 'all');
        avg_execution_time = mean(execution_time_all(:, :, j, k), 'all');
        
        fprintf('Filter Length %d, Lambda %.2f: Average SNR Before = %.2f dB, Average SNR After = %.2f dB, Average MSE = %.5f, Average Time = %.4f s\n', ...
            filter_lengths(j), lambdas(k), avg_snr_before, avg_snr_after, avg_mse, avg_execution_time);
        
        % Save the summary results to the file
        fprintf(fileID, 'Filter Length %d, Lambda %.2f: Average SNR Before = %.2f dB, Average SNR After = %.2f dB, Average MSE = %.5f, Average Time = %.4f s\n', ...
            filter_lengths(j), lambdas(k), avg_snr_before, avg_snr_after, avg_mse, avg_execution_time);
    end
end

% Close the results file
fclose(fileID);
