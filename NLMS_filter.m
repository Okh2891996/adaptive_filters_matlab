function [y, e, w] = NLMS_filter(x, d, mu, M)
    % Ensure input and desired signals are column vectors
    x = x(:);
    d = d(:);
    
    % Ensure both signals have the same length
    min_length = min(length(x), length(d));
    x = x(1:min_length);
    d = d(1:min_length);

    % Create NLMS filter object
    nlms = dsp.LMSFilter(M, 'Method', 'Normalized LMS', 'StepSize', mu);

    % Apply the filter
    [y, e, w] = nlms(x, d);
end
