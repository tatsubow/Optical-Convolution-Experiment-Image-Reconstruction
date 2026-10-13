function [t_super_start, t_super_start_idx] = detectSuperPreamble(y_raw, t_raw, Fs_meas, sp_ref, E_sp_r, cfg)
    % DETECTSUPERPREAMBLE - ZNCC相関によるスーパープレアンブルの同期位置検出
    
    fprintf('スーパープレアンブル探索中...\n');
    
    N_sp_ref = length(sp_ref);
    N_y = length(y_raw);
    evalLen = min(N_y, cfg.search.maxBlockSize);
    
    y_eval = y_raw(1:evalLen); y_eval = y_eval(:);
    
    % 累積和による高速エネルギー計算
    cs_y   = [0; cumsum(y_eval)]; 
    cs_y2  = [0; cumsum(y_eval.^2)];
    
    % FFTベースの相関計算
    nFFT_sp  = evalLen + N_sp_ref - 1;
    fft_y_sp = fft(y_eval, nFFT_sp); fft_y_sp = fft_y_sp(:);
    fft_sp   = fft(flipud(sp_ref), nFFT_sp); fft_sp   = fft_sp(:);
    
    conv_sp  = real(ifft(fft_y_sp .* fft_sp)); 
    conv_sp  = conv_sp(N_sp_ref : evalLen);
    
    % ZNCCの算出とピーク検出
    E_y_sp  = max(cs_y2(N_sp_ref + 1 : evalLen + 1) - cs_y2(1 : evalLen - N_sp_ref + 1), 1e-12);
    zncc_sp = conv_sp ./ (sqrt(E_y_sp * E_sp_r) + 1e-12);
    [~, znccPeakIdx] = max(zncc_sp);
    
    % ピーク位置から少し遡って、最初のエッジ（立ち上がり）を精密探索
    searchStartIdx = max(1, znccPeakIdx - round(Fs_meas * cfg.search.spSearchOffset));
    y_search = y_raw(searchStartIdx : znccPeakIdx);
    
    bg_noise = mean(y_raw(max(1, searchStartIdx - round(Fs_meas * cfg.search.spBgNoiseWindow)) : searchStartIdx));
    edgeThresh = bg_noise + 0.25 * (max(y_search) - bg_noise);
    firstEdgeOffset = find(y_search >= edgeThresh, 1, 'first');
    
    if ~isempty(firstEdgeOffset)
        t_super_start_idx = searchStartIdx + firstEdgeOffset - 1;
    else
        t_super_start_idx = znccPeakIdx;
    end
    
    t_super_start = t_raw(t_super_start_idx);
end