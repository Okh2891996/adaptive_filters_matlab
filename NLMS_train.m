clc; clear; close all;

%% Define Parameters
num_speakers = 30;  % Number of speakers (sp01 to sp30)
snr_levels = {'0dB'};
snr_values = {'0'};  % Remove "dB" for filenames
filter_lengths = [4, 8, 16, 32, 64];  % Different filter lengths
mus = [0.01, 0.05, 0.1];  % Different step sizes for NLMS

%% Initialize Storage for Results
snr_before_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(mus));
snr_after_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(mus));
mse_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(mus));
time_all = zeros(num_speakers, length(snr_levels), length(filter_lengths), length(mus));

%% Open File for Writing Results
fileID = fopen('NLMS_train_results.txt', 'w');

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

        % Loop over each combination of filter length and step size (mu)
        for j = 1:length(filter_lengths)
            for k = 1:length(mus)
                filter_length = filter_lengths(j);  % Set filter length
                mu = mus(k);                        % Set step size
                
                % Measure Execution Time
                tic;
                
                % Apply NLMS Filter using the Clean Speech as reference
                y_ref = y_noisy - y_clean;
                [y_filtered, error_signal] = NLMS_filter(y_noisy, y_ref, mu, filter_length);
                y_output = y_noisy - y_filtered;
                
                % Compute Execution Time
                elapsed_time = toc;
                
                % Compute SNR Before and After Filtering
                snr_before = snr(y_clean, y_clean - y_noisy);
                snr_after = snr(y_clean, y_output - y_clean);
                
                % Compute Mean Squared Error (MSE)
                mse_value = mean((y_clean - y_output).^2);
                
                % Store Results
                snr_before_all(s, i, j, k) = snr_before;
                snr_after_all(s, i, j, k) = snr_after;
                mse_all(s, i, j, k) = mse_value;
                time_all(s, i, j, k) = elapsed_time;
                
                % Write to File
                fprintf(fileID, 'Speaker %d | Noise (%s) | Filter Length %d | Mu %.3f: Before = %.2f dB, After = %.2f dB, MSE = %.6f, Time = %.4f sec\n', ...
                    s, snr_levels{i}, filter_length, mu, snr_before, snr_after, mse_value, elapsed_time);
                
                % Display Results
                fprintf('Speaker %d | Noise (%s) | Filter Length %d | Mu %.3f: Before = %.2f dB, After = %.2f dB, MSE = %.6f, Time = %.4f sec\n', ...
                    s, snr_levels{i}, filter_length, mu, snr_before, snr_after, mse_value, elapsed_time);
            end
        end
    end
end

%% Compute and Display Average Results
fprintf('\nSummary of Average Results Across 30 Speakers:\n');
fprintf(fileID, '\nSummary of Average Results Across 30 Speakers:\n');
for j = 1:length(filter_lengths)
    for k = 1:length(mus)
        avg_snr_before = mean(snr_before_all(:, :, j, k), 'all');
        avg_snr_after = mean(snr_after_all(:, :, j, k), 'all');
        avg_mse = mean(mse_all(:, :, j, k), 'all');
        avg_time = mean(time_all(:, :, j, k), 'all');
        
        fprintf('Filter Length %d, Mu %.3f: Avg SNR Before = %.2f dB, Avg SNR After = %.2f dB, Avg MSE = %.6f, Avg Time = %.4f sec\n', ...
            filter_lengths(j), mus(k), avg_snr_before, avg_snr_after, avg_mse, avg_time);
        fprintf(fileID, 'Filter Length %d, Mu %.3f: Avg SNR Before = %.2f dB, Avg SNR After = %.2f dB, Avg MSE = %.6f, Avg Time = %.4f sec\n', ...
            filter_lengths(j), mus(k), avg_snr_before, avg_snr_after, avg_mse, avg_time);
    end
end

%% Close the Results File
fclose(fileID);

fprintf('Results saved to results.txt\n');
