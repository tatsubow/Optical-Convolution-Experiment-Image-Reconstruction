function [recoveredImages, frameBoundaries] = extractFrames(t_raw, y_raw, t_super_start, fp_ref, E_fp_r, cfg)
    % EXTRACTFRAMES - 各フレームの同期検出と画像データの切り出し・再構成
    
    fprintf('各フレーム同期・画像データ切り出し中...\n');
    
    numImages = cfg.frame.numImages;
    N_super_sym = cfg.preamble.super.N_sym;
    N_fp_sym    = cfg.preamble.frame.N_sym;
    N_pay_sym   = cfg.frame.N_pay_sym;
    T_sym       = cfg.hw.T_sym;
    N_fp_ref    = length(fp_ref);
    
    frameBoundaries = struct();
    recoveredImages = cell(numImages, 1);
    
    t_super_end = t_super_start + N_super_sym * T_sym;
    
    for k = 1:numImages
        if k == 1
            fp_actual_start_t = t_super_end;
        else
            expected_fp_start_t = frameBoundaries(k-1).pay_end;
            win_start_t = expected_fp_start_t - cfg.search.fpWindowMargin;
            win_end_t   = expected_fp_start_t + (N_fp_sym * T_sym) + cfg.search.fpWindowMargin;
            
            sub_idx = find(t_raw >= win_start_t & t_raw <= win_end_t);
            
            if isempty(sub_idx)
                % フォールバック処理
                fp_actual_start_t = expected_fp_start_t;
            else
                y_sub   = y_raw(sub_idx); y_sub = y_sub(:);
                N_sub   = length(y_sub);
                
                cs_sub2 = [0; cumsum(y_sub.^2)];
                
                nFFT_sub = N_sub + N_fp_ref - 1;
                fft_sub  = fft(y_sub, nFFT_sub); fft_sub = fft_sub(:);
                fft_fp   = fft(flipud(fp_ref), nFFT_sub); fft_fp  = fft_fp(:);
                conv_sub = real(ifft(fft_sub .* fft_fp));
                conv_sub = conv_sub(N_fp_ref : N_sub);
                
                E_y_sub  = max(cs_sub2(N_fp_ref + 1 : N_sub + 1) - cs_sub2(1 : N_sub - N_fp_ref + 1), 1e-12);
                zncc_fp  = conv_sub ./ (sqrt(E_y_sub * E_fp_r) + 1e-12);
                
                [~, best_local_idx] = max(zncc_fp);
                fp_actual_start_idx = sub_idx(best_local_idx(1));
                fp_actual_start_t   = t_raw(fp_actual_start_idx);
            end
        end
        
        fp_actual_end_t    = fp_actual_start_t + N_fp_sym * T_sym;
        pay_actual_start_t = fp_actual_end_t;
        pay_actual_end_t   = pay_actual_start_t + N_pay_sym * T_sym;
        
        frameBoundaries(k).fp_start  = fp_actual_start_t;
        frameBoundaries(k).fp_end    = fp_actual_end_t;
        frameBoundaries(k).pay_start = pay_actual_start_t;
        frameBoundaries(k).pay_end   = pay_actual_end_t;
        
        % ペイロードシンボルの中心点を抽出
        sym_centers_t = pay_actual_start_t(1) + ((1:N_pay_sym) - 0.5) * T_sym;
        sym_samples   = interp1(t_raw, y_raw, sym_centers_t, 'linear', 'extrap');
        
        % ★ 汎用カーネルマッピング関数への委譲
        recoveredImages{k} = reconstruct.applyKernelMapping(sym_samples, cfg);
    end
end