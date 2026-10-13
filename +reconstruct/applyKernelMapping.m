function img = applyKernelMapping(sym_samples, cfg)
    % APPLYKERNELMAPPING - 1Dのシンボル列を任意サイズの2Dカーネルで画像空間にマッピング
    
    h  = cfg.recon.imageHeight;
    w  = cfg.recon.imageWidth;
    kh = cfg.recon.kernelHeight;
    kw = cfg.recon.kernelWidth;
    
    img = zeros(h, w);
    count = zeros(h, w);
    writeIdx = 1;
    
    % コンボリューションの逆マッピング（Stride = 1）
    % 例: 28x28画像, 2x1カーネルの場合、rは1〜27、cは1〜28となる
    for r = 1 : (h - kh + 1)
        for c = 1 : (w - kw + 1)
            % カーネル内の各要素を走査
            for kr = 1 : kh
                for kc = 1 : kw
                    if writeIdx > length(sym_samples)
                        break;
                    end
                    val = sym_samples(writeIdx);
                    writeIdx = writeIdx + 1;
                    
                    target_r = r + kr - 1;
                    target_c = c + kc - 1;
                    
                    img(target_r, target_c)   = img(target_r, target_c) + val;
                    count(target_r, target_c) = count(target_r, target_c) + 1;
                end
            end
        end
    end
    
    % 重複加算されたピクセルの平均化と正規化
    img = img ./ max(count, 1); % 0割り算防止
    img = (img - min(img(:))) / (max(img(:)) - min(img(:)) + 1e-12);
end