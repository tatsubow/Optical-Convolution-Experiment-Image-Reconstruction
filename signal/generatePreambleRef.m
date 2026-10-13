function [ref_ac, E_ref, N_ref] = generatePreambleRef(order, taps, addDummy, Fs_meas, cfg)
    % GENERATEPREAMBLEREF - LFSRによるプレアンブル参照波形の生成
    
    seqLen = 2^order - 1;
    reg = ones(1, order);
    bits = zeros(seqLen, 1, 'uint8');
    
    for i = 1:seqLen
        bits(i) = uint8(reg(end));
        fb = 0;
        for k = 1:length(taps)
            fb = xor(fb, reg(order - taps(k) + 1));
        end
        reg = [fb, reg(1:end-1)];
    end
    
    % フレームプレアンブル(Order 8)用のダミービット追加
    if addDummy
        bits = [bits; 0];
    end
    
    symbols = (double(bits) * 2) - 1;
    
    % サンプリングと遅延加算（1bitコンパレータ特性の模擬）
    samples = repelem(symbols, 8);
    del     = [repmat(-1, 8, 1); samples(1:end-8)];
    conv_sig = samples + del;
    
    % AWGのレートからオシロスコープのレートへ補間
    t_awg = (0 : length(conv_sig)-1)' / cfg.hw.currAwgRate;
    t_rx  = (0 : (1/Fs_meas) : t_awg(end))';
    rx    = interp1(t_awg, conv_sig, t_rx, 'linear', 'extrap');
    
    % AC結合（平均値除去）して出力
    ref_ac = rx - mean(rx); 
    ref_ac = ref_ac(:);
    
    N_ref = length(ref_ac);
    E_ref = sum(ref_ac.^2);
end