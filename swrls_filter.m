function [y, error, weights] = swrls_filter(x, d, filter_length, window_size)
    % Create a dsp.RLSFilter object with sliding-window RLS method
    swlr = dsp.RLSFilter('Method', 'Sliding-window RLS', ...
                          'Length', filter_length, ...
                          'SlidingWindowBlockLength', window_size);
    
    % Apply the filter
    [y, error] = swlr(x, d);
    
    % Extract the filter coefficients (weights)
    weights = swlr.Coefficients;
    
end