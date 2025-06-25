    function [y, error, weights] = rls_filter(x, d, len, lambda)
    
        rls = dsp.RLSFilter(len, "ForgettingFactor", lambda);
        [y, error] = rls(x,d);
        weights = rls.Coefficients;
    
    end 