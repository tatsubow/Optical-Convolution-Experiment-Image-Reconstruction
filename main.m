% ===================================================
% モジュール化: フレーム同期画像復元
% ===================================================
clear; clc;

% --- 1. 設定の読み込み ---
cfg = config.getDefaultConfig();

% --- 2. データの読み込み ＆ 時間単位の自動補正 ---
[t_raw, y_raw, Fs_meas] = io.loadWaveformData(cfg);

% --- 3. 参照波形の構築 ---
% スーパープレアンブル (Order 13)
[sp_ref, E_sp_r] = signal.generatePreambleRef(...
    cfg.preamble.super.order, cfg.preamble.super.taps, false, Fs_meas, cfg);

% フレームプレアンブル (Order 8, ダミービットあり)
[fp_ref, E_fp_r] = signal.generatePreambleRef(...
    cfg.preamble.frame.order, cfg.preamble.frame.taps, true, Fs_meas, cfg);

% --- 4. スーパープレアンブル探索 (ZNCC) ---
t_super_start = signal.detectSuperPreamble(y_raw, t_raw, Fs_meas, sp_ref, E_sp_r, cfg);

% --- 5. フレーム同期・画像データ切り出し ＆ 再構成 ---
[recoveredImages, frameBoundaries] = reconstruct.extractFrames(...
    t_raw, y_raw, t_super_start, fp_ref, E_fp_r, cfg);

% --- 5.5 評価指標の計算 (Evaluation) ---
% 事前に waveform_10GSas.csv から生成して保存した正解画像をロード
if isfile('ideal_images.mat')
    load('ideal_images.mat', 'idealImages');
    metrics = evaluate.calculateMetrics(recoveredImages, idealImages);
else
    warning('ideal_images.mat が見つかりません。評価をスキップします。');
end

% --- 6. プロット表示 ---
vis.plotTimeline(t_raw, y_raw, t_super_start, frameBoundaries, cfg);
vis.showImages(recoveredImages, cfg);

fprintf('\n========================================\n');
fprintf('【処理完了】モジュール化された処理が正常完了しました。\n');
fprintf('========================================\n');