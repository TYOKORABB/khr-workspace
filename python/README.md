# Python の環境の作り方

作業 PC では `/home/tora/gsw4` そのものが仮想環境（venv）で、その中にリポジトリが並んでいる（`python3 -m venv /home/tora/gsw4` で作った）。
同じ形で作り直す手順。

```bash
# 1. 仮想環境（Ubuntu 24.04 の python3.12 = 3.12.3）
python3.12 -m venv ~/gsw4
source ~/gsw4/bin/activate
pip install --upgrade pip

# 2. パッケージ（版を固定した一覧。PyPI から。torch は CUDA 13.0 版が入る）
pip install -r requirements.txt

# 3. Genesis を編集可能モードで（使った版 = ブランチ khr-v0.4.6）。依存は 2 で入れたので --no-deps
cd ~/gsw4
git clone -b khr-v0.4.6 https://github.com/TYOKORABB/Genesis.git
pip install --no-deps -e ./Genesis

# 4. 確認
python -c "import torch, genesis, rsl_rl; print(torch.__version__, torch.cuda.is_available(), genesis.__version__)"
#   → 2.12.0+cu130 True 0.4.6
cd ~/gsw4/khr_rl_tora && python quad/khr_train_quad31.py -h
```

## `requirements.txt` について

- 作業 PC（2026-10-14）の仮想環境から、**研究のコード（khr_rl_tora・Meridian_consoleS・khr_rl_sample）が import するパッケージ**と、
  その依存を全部たどって、実際に入っている版で固定した（125 個、`pip check` で矛盾なし）。
- 作業 PC の仮想環境には別の用途のパッケージも入っているが、それは含めていない。
- `genesis-world` は含めない（手順 3）。作業 PC の `pip freeze` では Genesis が `s-kajita/Genesis@04cf3b44` と出るが、
  このコミットは梶田先生のフォークからは消えているので、自分のフォークのブランチ `khr-v0.4.6`（同じコミット）から入れる。
- 主な版: torch 2.12.0（CUDA 13.0）、torchvision 0.27.0、rsl-rl-lib 5.4.0、tensordict 0.12.4、numpy 2.4.6、quadrants 0.6.2、
  mujoco 3.6.0、coacd 1.0.11、trimesh 4.12.2、tensorboard 2.20.0。実機のコンソールは pygame・dearpygui・redis も使う。
- ROS（`rospy`）は Meridian_consoleS の一部の機能だけが使う。作業 PC には入っていない。
