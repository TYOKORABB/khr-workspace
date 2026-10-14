#!/bin/bash
# 作業 PC にしかない研究データを Google Drive へバックアップする（rclone、remote 名 GoogleDrive）。
#
#   backup/backup_to_drive.sh            # 実行
#   backup/backup_to_drive.sh --dry-run  # 何を送るかだけ表示
#
# - `rclone copy` なので Drive 側のファイルは消さない（手元で消したものも Drive には残る）。何度実行してもよく、変わった分だけ送る。
# - 送り先: GoogleDrive:研究/khr_backup/（Drive の「研究/gsw4」は 2026-06-12 の別のコピーで、ここでは触らない）
# - 送らないもの: assets（梶田先生の非公開の URDF・メッシュ）、ファームの書き込み前のバックアップ（Wi-Fi の情報を含む）、
#   Python の仮想環境（作り直せる。python/README.md）、git で管理しているもの（GitHub にある）。
set -u
WS=/home/tora/gsw4
DST="GoogleDrive:研究/khr_backup"
LOG="$WS/khr-workspace/backup/last_backup.log"
OPT=(--transfers 8 --checkers 16 --exclude "__pycache__/**" --log-file "$LOG" --log-level INFO --stats 60s "$@")
: > "$LOG"
echo "[$(date '+%F %T')] backup → $DST"
rclone copy "$WS/khr_rl_tora/logs"          "$DST/khr_rl_tora_logs"   "${OPT[@]}"   # 学習済みのモデル・設定・TensorBoard（約 8.5 GB）
rclone copy "$WS/khr_rl_tora/real/data/raw" "$DST/real_data_raw"      "${OPT[@]}"   # 実機の生データ（取り直せない）
rclone copy "$WS/khr_rl_tora/media"         "$DST/media"              "${OPT[@]}" --include "*.mp4"   # 歩行の動画・記録mp4
rclone copy "$WS"                           "$DST/media/workspace_videos" "${OPT[@]}" --max-depth 1 --include "*.mp4"   # gsw4 直下の動画
echo "[$(date '+%F %T')] done（詳細は $LOG）"
