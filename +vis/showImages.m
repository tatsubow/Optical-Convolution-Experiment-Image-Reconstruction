function showImages(recoveredImages, cfg)
    % SHOWIMAGES - 復元された画像データ（セル配列）を並べて表示
    
    % 設定値と実際の画像数のうち、小さい方を採用して制限をかける
    displayImages = min(cfg.frame.numImages, cfg.vis.numImagesToShow);
    
    figure('Name', 'Universal Recovered MNIST Images Final', 'Color', [0.1 0.1 0.1]);
    
    for k = 1:displayImages
        subplot(1, displayImages, k);
        imshow(recoveredImages{k}, []);
        title(sprintf('Frame %d', k), 'Color', 'w', 'FontSize', 12);
    end
end