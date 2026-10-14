function cfg = getDefaultConfig()
    % GETDEFAULTCONFIG - 信号復元処理のための全パラメータを一元管理
    cfg = struct();
    
    % --- 1. 入出力・ファイル設定 (IO) ---
    cfg.io.csvPathPrimary  = fullfile('data/1bit_reconstruct', 'conv1bit.csv');
    cfg.io.csvPathFallback = fullfile('data/1bit_reconstruct', 'conv1bit_sim.csv');
    
    % --- 2. ハードウェア・サンプリング設定 (Hardware) ---
    cfg.hw.currAwgRate         = 16.0e9;             % 実効 16.0 GSa/s
    cfg.hw.effectiveSymbolRate = 2.0e9;              % 2 Gbaud
    cfg.hw.T_sym               = 1 / cfg.hw.effectiveSymbolRate;
    
    % --- 3. プレアンブル設定 (Preamble) ---
    % スーパープレアンブル (Order 13)
    cfg.preamble.super.order = 13;
    cfg.preamble.super.taps  = [13 12 11 8];
    cfg.preamble.super.N_sym = 8191;  % 2^13 - 1
    cfg.preamble.super.sps   = 8;     % samples per symbol
    
    % フレームプレアンブル (Order 8)
    cfg.preamble.frame.order = 8;
    cfg.preamble.frame.taps  = [8 6 5 4];
    cfg.preamble.frame.N_sym = 256;   % 2^8 - 1 + 1 (dummy)
    cfg.preamble.frame.sps   = 8;
    
    % --- 4. フレーム構成設定 (Frame Structure) ---
    cfg.frame.N_pay_sym = 1512; % 1フレームあたりのペイロードシンボル数
    cfg.frame.numImages = 4;    % 処理する総フレーム（画像）数
    
    % --- 5. 可視化設定 (Visualization) ---
    cfg.vis.numFramesToPlot = 4; % 波形グラフに描画するフレーム数
    cfg.vis.numImagesToShow = 4; % 画像として表示するフレーム数

    % --- 6. 画像復元・カーネル設定 (Reconstruction) ---
    % 既存コードの 2x1 マッピングロジックと互換性を保つための設定
    cfg.recon.imageHeight  = 28;
    cfg.recon.imageWidth   = 28;
    cfg.recon.kernelHeight = 2;
    cfg.recon.kernelWidth  = 1;
    
    % --- 7. ZNCC相関・探索設定 (Search Algorithm) ---
    cfg.search.maxBlockSize      = 2000000;
    cfg.search.spSearchOffset    = 400e-9; % SPピークからのエッジ探索開始幅
    cfg.search.spBgNoiseWindow   = 1e-6;   % SPエッジ閾値用の背景ノイズ計算幅
    cfg.search.fpWindowMargin    = 100e-9; % 各フレームのローカル探索ウィンドウ幅
end