# 研究/khr_backup — KHR-3HV 研究の作業場の完全なバックアップ

作業 PC の `/home/tora/gsw4` を、毎月 1 日に自動で写している（`khr-workspace/backup/backup_to_drive.sh`、rclone）。
コードと記録の正本は GitHub（TYOKORABB/khr_rl_tora・khr-workspace・Genesis・Meridian_LITE・Meridian_consoleS）。
ここは、GitHub に無いもの（学習済みのモデル `logs/`、動画、実機の生データ、手元だけのブランチ）も含めて丸ごと戻すためのもの。

| フォルダ | 中身 |
|---|---|
| `gsw4/` | 作業場の写し（各リポジトリの .git を含む）。Python の仮想環境・非公開の assets・秘密の情報・キャッシュは入れていない |
| `gsw4_changed/<日付>/` | その月に手元で消えた・変わったファイルの、それまでの版（写しから外れても失われない） |
| `secrets/secrets_<日付>.tar.gz.gpg` | 秘密の情報（ファームの書き込み前のバックアップ・keys.h・board_ip.txt・.env）を gpg で暗号化したもの |

戻し方:

1. `gsw4/` を丸ごとダウンロードして `~/gsw4` に置く（`rclone copy GoogleDrive:研究/khr_backup/gsw4 ~/gsw4`）。
2. Python の環境を作る（`khr-workspace/python/README.md`）。assets は梶田先生から入手する。
3. 秘密の情報: `gpg -d secrets_<日付>.tar.gz.gpg | tar xz -C ~/gsw4`（パスフレーズはパスワード管理に控えてあるもの）。

同じ「研究」フォルダの `gsw4/`（2026-06-12）は、これとは別に手で取った古いコピー。
