function [t_raw, y_raw, Fs_meas] = loadWaveformData(cfg)
    % LOADWAVEFORMDATA - CSVデータの読み込み ＆ 時間単位の自動補正
    %
    % 入力:
    %   cfg - config.getDefaultConfig() で生成された設定構造体
    % 出力:
    %   t_raw   - 時間軸データ (秒 [s] 単位に正規化済み)
    %   y_raw   - 振幅データ
    %   Fs_meas - 計測サンプリングレート [Hz]

    csvPath = cfg.io.csvPathPrimary;

    % 1. ファイルの存在チェックとフォールバック
    if ~isfile(csvPath)
        if isfile(cfg.io.csvPathFallback)
            csvPath = cfg.io.csvPathFallback;
        else
            error('指定されたCSVファイルが見つかりません: %s', csvPath);
        end
    end

    % 2. データの読み込みとNaN除去
    fprintf('データ読み込み中 (%s)...\n', csvPath);
    opts = detectImportOptions(csvPath);
    data = readmatrix(csvPath, opts);
    data = data(~any(isnan(data), 2), :);

    t_raw = data(:, 1);  t_raw = t_raw(:);
    y_raw = data(:, 2);  y_raw = y_raw(:);

    % 3. 時間単位の自動判別（1以上の数値があれば μs と判定して 秒 [s] に正規化）
    if max(abs(t_raw)) > 1.0
        fprintf('  -> 時間軸を [μs] から [s] に自動正規化しました。\n');
        t_raw = t_raw * 1e-6;
    end

    % 4. サンプリングレートの計算
    dt_meas = mean(diff(t_raw));  
    Fs_meas = 1 / dt_meas;
end