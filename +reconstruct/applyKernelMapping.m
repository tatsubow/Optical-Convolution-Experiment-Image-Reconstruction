function img = applyKernelMapping(sym_samples, cfg)
    % APPLYKERNELMAPPING - 1Dシンボル列を 28x27 の畳み込み画像へ正しく再構成
    
    h  = cfg.recon.imageHeight;   % 28
    w  = cfg.recon.imageWidth;    % 28
    kh = cfg.recon.kernelHeight;  % 1
    kw = cfg.recon.kernelWidth;   % 2
    
    out_h = h - kh + 1; % 28 (高さ)
    out_w = w - kw + 1; % 27 (幅)
    total_patches = out_h * out_w; % 756
    kernel_size   = kh * kw;       % 2
    
    % サンプル位相の設定 (1 または 2)
    % 1パッチ内の2サンプルのうち、どちらを抽出するかでエッジの抽出特性が変わります
    sample_phase = 2; 
    
    if length(sym_samples) >= total_patches * kernel_size
        raw_vals = sym_samples(sample_phase : kernel_size : total_patches * kernel_size);
    else
        raw_vals = sym_samples(1 : total_patches);
    end
    
    % 1行27ピクセルのデータを正しく 28x27 (高さ28, 幅27) に再構成
    % [out_w, out_h]' とすることで、1Dデータの27要素ごとに行として転置展開されます
    img = reshape(raw_vals(1:total_patches), [out_w, out_h])';
    
    % レンジ正規化（0.0 ～ 1.0）
    minVal = min(img(:));
    maxVal = max(img(:));
    if maxVal > minVal
        img = (img - minVal) / (maxVal - minVal);
    end
end