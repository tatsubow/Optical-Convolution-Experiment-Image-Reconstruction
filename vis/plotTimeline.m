function plotTimeline(t_raw, y_raw, t_super_start, frameBoundaries, cfg)
    % PLOTTIMELINE - 波形全体と検出したフレーム境界線の可視化
    
    t_us = t_raw * 1e6;
    numImages = cfg.frame.numImages;
    t_super_end = t_super_start + cfg.preamble.super.N_sym * cfg.hw.T_sym;
    
    figure('Name', 'Universal Alignment Plot Final', 'Color', [0.1 0.1 0.1]);
    
    dispStart = t_super_start - 0.2e-6;
    dispEnd   = frameBoundaries(numImages).pay_end + 0.3e-6;
    dispIdx   = find(t_raw >= dispStart & t_raw <= dispEnd);
    
    plot(t_us(dispIdx), y_raw(dispIdx), 'Color', [0.8 0.8 0.8], 'LineWidth', 0.8); hold on;
    
    xline(t_super_start * 1e6, 'r--', 'LineWidth', 2, 'Label', 'Super Start');
    xline(t_super_end * 1e6, 'r:', 'LineWidth', 2, 'Label', 'Super End (F1 Prem Start)');
    
    colors = [0.2 0.8 1.0; 0.2 1.0 0.4; 1.0 0.8 0.2; 1.0 0.4 0.8];
    
    for k = 1:numImages
        fp_st  = frameBoundaries(k).fp_start * 1e6;
        pay_st = frameBoundaries(k).pay_start * 1e6;
        pay_ed = frameBoundaries(k).pay_end * 1e6;
        
        if k > 1
            xline(fp_st, '-', 'Color', colors(k,:), 'LineWidth', 1.5, 'Label', sprintf('F%d Prem Start', k));
        end
        xline(pay_st, '--', 'Color', colors(k,:), 'LineWidth', 1.5, 'Label', sprintf('F%d Pay Start', k));
        xline(pay_ed, ':', 'Color', colors(k,:), 'LineWidth', 1.5, 'Label', sprintf('F%d Pay End', k));
    end
    
    hold off;
    title('確定境界線（時間単位自動調整対応）', 'Color', 'w');
    xlabel('Time [\mus]', 'Color', 'w'); ylabel('Amplitude', 'Color', 'w');
    grid on; ax = gca; ax.Color = [0 0 0]; ax.XColor = 'w'; ax.YColor = 'w'; ax.GridColor = [0.4 0.4 0.4];
end