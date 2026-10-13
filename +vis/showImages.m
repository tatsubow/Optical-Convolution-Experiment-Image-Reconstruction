function showImages(recoveredImages, cfg)
    % SHOWIMAGES - 復元された画像データ（セル配列）を並べて表示
    
    numImages = cfg.frame.numImages;
    figure('Name', 'Universal Recovered MNIST Images Final', 'Color', [0.1 0.1 0.1]);
    
    for k = 1:numImages
        subplot(1, numImages, k);
        imshow(recoveredImages{k}, []);
        title(sprintf('Frame %d', k), 'Color', 'w', 'FontSize', 12);
    end
end