#!/bin/bash
# 作業場（/home/tora/gsw4）の完全なバックアップを Google Drive へ（rclone の remote 名 GoogleDrive）。月に 1 回 cron で動かす。
#
#   backup/backup_to_drive.sh            # 実行（初回は数時間、2 回目からは変わった分だけ）
#   backup/backup_to_drive.sh --dry-run  # 何を送るかだけ表示
#
# Drive の 研究/khr_backup/ の中:
#   gsw4/                 作業場の写し。各リポジトリ（.git を含む）・学習の成果物 logs/・実験の記録・動画（mp4）など全部。
#                         外すのは filter.txt のもの（Python の仮想環境・非公開の assets・秘密の情報・キャッシュ）だけ。
#   gsw4_changed/<日付>/  その回に、手元で消えた・変わったために gsw4/ から外れたファイル（sync でも Drive からは失われない）
#   secrets/secrets_<日付>.tar.gz.gpg
#                         秘密の情報を gpg（AES-256）で暗号化したもの: ファームの書き込み前のバックアップ（実機の元のファーム・
#                         サーボの向きと 0 点・Wi-Fi の設定を含む）、keys.h、board_ip.txt、khr_rl_tora/.env。
#                         パスフレーズは ~/.config/khr_backup/passphrase（この PC だけ。パスワード管理にも控えておく）。
#                         戻し方: gpg -d secrets_<日付>.tar.gz.gpg | tar xz
#   README.md             この説明（backup/DRIVE_README.md）
set -u
WS=/home/tora/gsw4
HERE="$WS/khr-workspace/backup"
RCLONE="${RCLONE:-/home/tora/.local/bin/rclone}"
DST="GoogleDrive:研究/khr_backup"
LOG="$HERE/last_backup.log"
PASS="$HOME/.config/khr_backup/passphrase"
DATE="$(date +%F)"
DRY=(); [ "${1:-}" = "--dry-run" ] && DRY=(--dry-run)
OPT=(--transfers 8 --checkers 16 --skip-links --log-file "$LOG" --log-level INFO --stats 120s "${DRY[@]}")
: > "$LOG"
echo "[$(date '+%F %T')] backup → $DST ${DRY[*]}"

# 1. 作業場の写し。--max-delete は、手元のディスクが壊れて空に見えたときに Drive 側を大量に外さないための安全弁
"$RCLONE" sync "$WS" "$DST/gsw4" --filter-from "$HERE/filter.txt" --backup-dir "$DST/gsw4_changed/$DATE" \
  --max-delete 1000 "${OPT[@]}"
st=$?

# 2. 秘密の情報（暗号化してから送る）
if [ -f "$PASS" ]; then
  tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
  files=()
  for f in khr_rl_tora/real/firmware_patches/_work/backup Meridian_LITE/Meridian_LITE_for_ESP32/src/keys.h \
           Meridian_consoleS/board_ip.txt khr_rl_tora/.env; do
    [ -e "$WS/$f" ] && files+=("$f")
  done
  tar czf "$tmp/secrets.tar.gz" -C "$WS" "${files[@]}" \
    && gpg --batch --yes --pinentry-mode loopback --passphrase-file "$PASS" --symmetric --cipher-algo AES256 \
           -o "$tmp/secrets.tar.gz.gpg" "$tmp/secrets.tar.gz" \
    && "$RCLONE" copyto "$tmp/secrets.tar.gz.gpg" "$DST/secrets/secrets_$DATE.tar.gz.gpg" "${OPT[@]}" \
    || { echo "[warn] 秘密の情報の暗号化・送信に失敗"; st=1; }
else
  echo "[warn] パスフレーズ $PASS が無いので、秘密の情報は送らない"
fi

# 3. Drive 側の説明
"$RCLONE" copyto "$HERE/DRIVE_README.md" "$DST/README.md" "${OPT[@]}"
echo "[$(date '+%F %T')] done status=$st（詳細は $LOG）"
exit $st
