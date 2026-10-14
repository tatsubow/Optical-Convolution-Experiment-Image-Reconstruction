# Optical-Convolution-Experiment-Image-Reconstruction
General Image Reconstruction Program

光畳み込み実験によって得られたアナログ波形データから、画像を自動再構成および定量評価（MSE, PSNR, SSIM）するためのMATLABパッケージです。

---

## 概要
本プログラムは、1000フレームを超える大規模な実験データに対しても安定かつ高速に動作するよう、パッケージ型アーキテクチャ（`+config`, `+io`, `+signal`, `+reconstruct`, `+vis`, `+evaluate`）としてモジュール化されています。

---

## ディレクトリ構造
```text
conv_reconstruct/
├── +config/          # 設定パラメータ管理 (getDefaultConfig.m)
├── +io/              # CSVデータ読み込み (loadCSV.m)
├── +signal/          # スーパープレアンブル探索・フレーム同期
├── +reconstruct/     # 波形データからの画像切り出し・再構成
├── +vis/             # 可視化処理（フリーズ防止表示制限機能付き）
├── +evaluate/        # 評価指標算出 (calculateMetrics.m)
├── data/             # 大容量データ・キャッシュ格納用 (.gitignore対象)
│   ├── 1bit_reconstruct/
│   │   ├── conv1bit.csv
│   │   ├── conv1bit_sim.csv
│   │   └── ideal_images.mat
│   ├── 2bit_reconstruct/
│   │   └── ...
│   └── ... (8bit_reconstruct まで)
├── main.m            # メイン実行スクリプト
├── .gitignore        # 大容量データ除外設定
└── README.md         # 本ドキュメント
```

---

## セットアップ手順

### 1. `data` ディレクトリ構造の準備
プロジェクトルート直下に `data/` フォルダを作成し、対象ビット数に応じたサブフォルダ（`1bit_reconstruct` ～ `8bit_reconstruct`）を配置します。

```bash
mkdir -p data/1bit_reconstruct
# 必要に応じて 2bit～8bit のフォルダも作成
```

各サブフォルダ内に必要なデータファイルを配置します（例: `data/1bit_reconstruct/` 内）：
* `conv1bit.csv` （実験測定データ）
* `conv1bit_sim.csv` （シミュレーションデータ）
* `ideal_images.mat` （デジタル理想波形データ）

※ `data/` ディレクトリ配下のすべてのファイルおよびサブフォルダは `.gitignore` 設定によりGitの管理対象外となります。

---

### 2. 正解データ（`ideal_images.mat`）の初回生成
実験データの評価指標（MSE / PSNR / SSIM）を自動算出するために、比較基準となる正解画像データ（`ideal_images.mat`）を各ビット数のフォルダ配下に生成・保存します。

1. `+config/getDefaultConfig.m` を開き、対象フォルダ配下の理想波形データパス（例: `1bit_reconstruct/conv1bit_sim.csv`）を指定し、処理フレーム数を設定します。
   ```matlab
   cfg.io.csvPathPrimary = fullfile('data', '1bit_reconstruct', 'conv1bit_sim.csv');
   cfg.frame.numImages   = 1000; % 評価対象とするフレーム数
   ```

2. MATLAB上で `main.m` を実行します。

3. 実行完了後、コマンドウィンドウで以下を実行して該当のビット数フォルダ配下に正解画像を保存します。
   ```matlab
   idealImages = recoveredImages;
   save(fullfile('data', '1bit_reconstruct', 'ideal_images.mat'), 'idealImages');
   ```

4. `+config/getDefaultConfig.m` の入力パスを評価したい実験データ（例: `1bit_reconstruct/conv1bit.csv`）に戻します。
   ```matlab
   cfg.io.csvPathPrimary = fullfile('data', '1bit_reconstruct', 'conv1bit.csv');
   ```

---

## 実行方法

### MATLAB GUI から実行
`+config/getDefaultConfig.m` で読み込みたいデータパス（例: `fullfile('data', '1bit_reconstruct', 'conv1bit.csv')` など）を設定後、`main.m` を実行します。
```matlab
main
```

### WSL / コマンドライン（CLI）から実行
WSLやターミナルからバッチモードで実行する場合：
```bash
matlab -batch "cd('プロジェクトの絶対パス'); main"
```

---

## 評価指標について

実行後、再構成画像と正解画像の比較結果がコンソールに自動出力されます。

* **MSE (Mean Squared Error):** 平均二乗誤差。数値が小さいほど高精度。
* **PSNR (Peak Signal-to-Noise Ratio):** ピーク信号対雑音比 (dB)。数値が大きいほど高画質。
* **SSIM (Structural Similarity):** 構造的類似度 (0.0〜1.0)。画像の輪郭や形状の一致度を表し、1.0に近いほど高精度。

**出力例:**
```text
評価指標 (MSE / PSNR / SSIM) を計算中...
【評価結果平均】 MSE: 0.0123 | PSNR: 19.82 dB | SSIM: 0.3788
```
