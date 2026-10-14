# khr-workspace — KHR-3HV 研究の作業場の設計図

近藤科学 KHR-3HV の四脚歩行・起き上がりの強化学習と Sim2Real（[TYOKORABB/khr_rl_tora](https://github.com/TYOKORABB/khr_rl_tora)）を動かす作業場
（作業 PC の `/home/tora/gsw4`）が、**どのリポジトリのどの版でできているか**と、**作り直す手順**をまとめたもの。
作業場そのもの（Python の仮想環境・学習の成果物・動画）は入れていない。

## 作業場の中身と、使っている版

作業場は Python の仮想環境（venv）のフォルダを兼ねていて、その中に次のリポジトリが並んでいる。

| フォルダ | GitHub（自分の） | 使っている版 | 役割 |
|---|---|---|---|
| `khr_rl_tora/` | [TYOKORABB/khr_rl_tora](https://github.com/TYOKORABB/khr_rl_tora)（s-kajita/khr_rl_sample のフォーク） | `main` | **研究の本体**。四脚歩行・起き上がり・実機のコード、実験の記録、開発日誌 |
| `Genesis/` | [TYOKORABB/Genesis](https://github.com/TYOKORABB/Genesis)（s-kajita/Genesis のフォーク） | ブランチ `khr-v0.4.6` = `04cf3b44` | 物理シミュレータ。公式の v0.4.6（`89164364`）に梶田先生の例 `examples/test.py` を 1 本足したもの。**全実験がこの版** |
| `Meridian_LITE/` | [TYOKORABB/Meridian_LITE](https://github.com/TYOKORABB/Meridian_LITE)（s-kajita/Meridian_LITE のフォーク） | 元は `85a62d1`、実機の版はブランチ `khr-getup.4` | ESP32 のファーム。実機に書き込んでいるのは `khr-getup.4`（`85a62d1` + khr_rl_tora の `real/firmware_patches/khr-getup.4.patch`） |
| `Meridian_consoleS/` | [TYOKORABB/Meridian_consoleS](https://github.com/TYOKORABB/Meridian_consoleS)（s-kajita/Meridian_consoleS のフォーク） | ブランチ `khr-quad`（`cbc1284` + 四脚用） | PC 側のコンソール。`khr-quad` に四脚歩行のデプロイヤ（v31 用を含む）。v31 の実機歩行は khr_rl_tora の `real/walk_session.py` で行った |
| `khr_rl_sample/` | 元の [s-kajita/khr_rl_sample](https://github.com/s-kajita/khr_rl_sample)（フォークは khr_rl_tora が兼ねる） | `24d9a47` + `patches/khr_rl_sample/` | 先輩の二足歩行のサンプル。手元の変更（初期姿勢と目標の高さ、8 行）はパッチで残す |
| `assets/khr3hv/` | **入れない**（元の s-kajita/khr3hv は非公開） | `5577f69` | URDF とメッシュ。起き上がり用の派生 URDF は khr_rl_tora の `getup/tools/make_getup_urdf.py` で作る |

この表にないもの: 学習の成果物（`khr_rl_tora/logs/`、約 8 GB）、動画、仮想環境の中身（`bin/`・`lib/` など、約 8 GB）。

## 作り直す手順

1. PC の準備: Ubuntu 24.04、NVIDIA ドライバ（595 系）、Python 3.12。今の PC の詳細は [`system.md`](system.md)。
2. リポジトリを並べる（作業場のフォルダの中に）:
   ```bash
   mkdir -p ~/gsw4 && cd ~/gsw4
   git clone https://github.com/TYOKORABB/khr_rl_tora.git
   git clone -b khr-v0.4.6     https://github.com/TYOKORABB/Genesis.git
   git clone -b khr-getup.4    https://github.com/TYOKORABB/Meridian_LITE.git
   git clone -b khr-quad       https://github.com/TYOKORABB/Meridian_consoleS.git
   git clone https://github.com/s-kajita/khr_rl_sample.git      # 必要なら（二足のサンプル）
   # assets/khr3hv は梶田先生から入手する（非公開）
   ```
3. Python の環境: [`python/README.md`](python/README.md)。
4. ファームの書き込み（実機を使うとき）: PlatformIO の版は [`system.md`](system.md)、手順は khr_rl_tora の `real/firmware_patches/README.md`。
   Wi-Fi の設定 `keys.h` はどのリポジトリにも入っていない。`keys_sample.h` から作る。
5. 作業場の案内（Claude Code 用）: [`workspace/CLAUDE.md`](workspace/CLAUDE.md) を `~/gsw4/CLAUDE.md` に置く。

## 運用の決まり

- **push するのは TYOKORABB のリポジトリだけ。** 梶田先生（s-kajita）のリポジトリには push しない。
  作業 PC のクローンでは、`origin`（s-kajita）の push 先を無効にし、自分のフォークを `tora` という名前で足してある
  （`git push tora <ブランチ>`）。元の更新は `git fetch origin` で取れる。
- 秘密の情報（Wi-Fi の `keys.h`、`board_ip.txt`、API キーの `.env`、ファームのバックアップ）と動画は、どのリポジトリにも入れない。
- フォークは公開（GitHub では公開リポジトリのフォークは非公開にできない）。このリポジトリは新規作成なので、設定でいつでも非公開にできる。
