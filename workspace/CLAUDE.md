# CLAUDE.md

このファイルは、本リポジトリ(`/home/tora/gsw4`)で作業する Claude Code (claude.ai/code) 向けのガイドです。

## このディレクトリの性質（重要）

`/home/tora/gsw4` は **2つの役割を兼ねている** 点に注意すること。

1. **Python 仮想環境 (venv) のルート** — `pyvenv.cfg` / `bin/` / `lib/` / `lib64/` / `include/` / `share/` / `etc/` は venv 本体（Python 3.12.3）。
2. **複数プロジェクトのワークスペース** — `Genesis/`, `khr_rl_*/`, `Meridian_*/`, `assets/` がそれぞれ独立した git リポジトリとして同居している。

- **このルート自身は git 管理されていない。** git 操作は必ず各サブプロジェクト内で行うこと。
- **`lib/`（および `lib64`, `include/`, `share/`, `bin/` の venv 中身）は触らない。** 特に `lib/` はインストール済みパッケージで非常に大きい。必要なときだけ参照する。
- venv の有効化: `source /home/tora/gsw4/bin/activate`

## プロジェクト全体像

近藤科学の小型二足歩行ロボット **KHR-3HV** を対象に、**Genesis シミュレータ上で強化学習(RL)した歩行ポリシーを、Meridian 経由で実機へ sim2real する** ことを目的としたワークスペース。

| ディレクトリ | 役割 | git origin |
|---|---|---|
| `Genesis/` | 物理シミュレータ本体（`genesis-world` 0.4.6）。**editable インストール済み**（`import genesis` はこの中を指す） | s-kajita/Genesis |
| `khr_rl_sample/` | KHR-3HV の RL サンプル（Taishi Kataoka 由来）。参照・upstream 的位置づけ | s-kajita/khr_rl_sample |
| `khr_rl_tora/` | **ユーザー(Tora)の作業用コピー。主にここで作業する。** `khr_env.py` / `khr_train.py` が sample から派生・改変済み | TYOKORABB/khr_rl_tora |
| `Meridian_consoleS/` | PC 側の制御コンソール（Python）。UDP/Meridim90 で実機と 100Hz 通信。sim2real・ジョイスティック制御・redis 連携を含む | s-kajita/Meridian_consoleS |
| `Meridian_LITE/` | 実機搭載 ESP32 用ファームウェア（C++ / PlatformIO） | s-kajita/Meridian_LITE |
| `assets/khr3hv/` | KHR-3HV の URDF とメッシュ（複数バリアント。RL のデフォルトは `khr3hv_12dof.urdf`） | （khr_rl 側から相対参照） |

## 強化学習パイプライン（`khr_rl_tora` / `khr_rl_sample`）

技術スタック: **Genesis（シミュレーション）＋ rsl-rl-lib ≥5.0（現在 5.4.0, PPO `OnPolicyRunner`）＋ PyTorch 2.12.0 ＋ tensordict**。

主要ファイル:
- `khr_env.py` — `KHREnv` クラス。Genesis シーン構築・観測/報酬・PD 制御・ドメインランダム化を実装。制御周期 `dt=0.02`（50Hz）。`num_actions=12`（脚 12 自由度: 左右の hip yaw/roll/pitch・knee pitch・ankle pitch/roll）。
- `khr_train.py` — 学習スクリプト。GPU バックエンド。設定（PPO/環境/観測/報酬/コマンド）は本ファイル内の `get_train_cfg` / `get_cfgs` にハードコード。
- `khr_eval.py` — 学習済みポリシーをビューア付きで再生（CPU バックエンド）。
- `pd_test.py` — PD 制御の単体テスト・matplotlib プロット用。
- `go2_*.py` — Unitree Go2（四足）版。Genesis locomotion 由来の参考例。

### よく使うコマンド

スクリプトは **必ず該当プロジェクト内（`khr_rl_tora/` 等）から実行する。** URDF 参照が相対パス（`../assets/khr3hv/urdf/khr3hv_12dof.urdf`）のため。

```bash
source /home/tora/gsw4/bin/activate
cd /home/tora/gsw4/khr_rl_tora

# 学習（既定: exp_name=khr-walking, num_envs=4096, max_iterations=101）
python khr_train.py                      # ビューアなし（高速）
python khr_train.py --view               # 学習中の動きを表示
python khr_train.py -e my-exp -B 4096 -I 201

# 評価（チェックポイント再生、ビューア表示）
python khr_eval.py -e khr-walking --ckpt 100

# PD 制御テスト
python pd_test.py

# 学習ログの可視化
tensorboard --logdir logs
```

- 学習成果物は `logs/{exp_name}/`（`cfgs.pkl` と `model_{iter}.pt`）に出力される。
- **注意: `khr_train.py` は同名 `exp_name` の `logs/{exp_name}` を実行開始時に削除して作り直す。** 既存結果を残したい場合は `-e` で別名を指定すること。

## 実機側（Meridian）

- **Meridim90** という 90 要素の配列を中間プロトコルとして、PC ⇔ ESP32 間を UDP で循環させる（受信 22222 / 送信 22224、約 100Hz）。
- PC 側コンソール: `cd Meridian_consoleS && python Meridian_consoleS.py`（要 `numpy`, `dearpygui`, `redis`, `pygame`）。ESP32 の IP は `Meridian_consoleS/board_ip.txt` に保存される。
- `Meridian_consoleS/khr_env_no_gs.py` は実機向けに Genesis 依存を外した RL 環境アダプタ（sim2real 用）。
- ファームウェア `Meridian_LITE/Meridian_LITE_for_ESP32/` は PlatformIO プロジェクト。書き込み前に `src/config.h`（ハード構成・サーボマウント）と `src/keys.h`（WiFi SSID/パスワード・送信先 PC の IP）を編集する。コード規約は LLVM 準拠（`.clang-format`）。

## 作業上の注意

- **既存のプログラム・フォルダ構成を変更しない。** 改変は基本的に `khr_rl_tora/` 内に閉じる。
- `Genesis/` は editable インストールのため、`Genesis/genesis/` を変更するとインストール済みパッケージの挙動が変わる。サードパーティ本体なので原則として手を入れない。
- RL スクリプトは `rsl-rl-lib>=5.0.0` を前提に明示チェックしている（満たさないと `ImportError`）。
- 各サブプロジェクトは独立リポジトリ。コミット/PR は対象プロジェクト内で行い、リモートを取り違えないこと（`khr_rl_tora` のみ origin が `TYOKORABB`、他は `s-kajita`）。
