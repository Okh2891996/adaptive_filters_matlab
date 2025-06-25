function [y, e, w] = LMS_filter(x, d, mu, M)
    % Ensure input and desired signals are column vectors
    x = x(:);  
    d = d(:);

    % Ensure both signals have the same length
    min_length = min(length(x), length(d));
    x = x(1:min_length);
    d = d(1:min_length);

    % Create LMS adaptive filter object
    lms = dsp.LMSFilter(M, 'StepSize', mu);

    % Apply LMS filtering
    [y, e, w] = lms(x, d);

end
