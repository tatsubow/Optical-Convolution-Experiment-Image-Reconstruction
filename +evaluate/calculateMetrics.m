function metrics = calculateMetrics(recoveredImages, idealImages)
    % CALCULATEMETRICS - 復元画像と正解画像の評価指標(MSE, PSNR, SSIM)を計算
    
    if length(recoveredImages) ~= length(idealImages)
        warning('評価警告: 復元画像（%d枚）と正解画像（%d枚）の数が異なります。少ない方に合わせて評価します。', ...
            length(recoveredImages), length(idealImages));
    end
    
    numImages = min(length(recoveredImages), length(idealImages));
    numImages = min(length(recoveredImages), length(idealImages));
    
    % 結果を格納する構造体の初期化
    metrics.mse  = zeros(numImages, 1);
    metrics.psnr = zeros(numImages, 1);
    metrics.ssim = zeros(numImages, 1);
    
    fprintf('\n評価指標 (MSE / PSNR / SSIM) を計算中...\n');
    
    for k = 1:numImages
        img_rec   = double(recoveredImages{k});
        img_ideal = double(idealImages{k});
        
        % サイズが一致しない場合の安全対策
        if any(size(img_rec) ~= size(img_ideal))
            error('評価エラー: 復元画像と正解画像のサイズが一致しません (Frame %d)', k);
        end
        
        % 1. MSE (平均二乗誤差)
        metrics.mse(k) = mean((img_rec(:) - img_ideal(:)).^2);
        
        % 2. PSNR & SSIM (Image Processing Toolboxが必要)
        try
            % ピクセル値が0〜1の範囲に正規化されている前提で Peakval = 1.0 に設定
            metrics.psnr(k) = psnr(img_rec, img_ideal, 1.0);
            metrics.ssim(k) = ssim(img_rec, img_ideal);
        catch
            % ツールボックスがない場合は NaN を返す
            metrics.psnr(k) = NaN;
            metrics.ssim(k) = NaN;
        end
    end
    
    % 全体の平均値を計算
    metrics.mean_mse  = mean(metrics.mse);
    metrics.mean_psnr = mean(metrics.psnr, 'omitnan');
    metrics.mean_ssim = mean(metrics.ssim, 'omitnan');
    
    fprintf('【評価結果平均】 MSE: %.4f | PSNR: %.2f dB | SSIM: %.4f\n', ...
        metrics.mean_mse, metrics.mean_psnr, metrics.mean_ssim);
end