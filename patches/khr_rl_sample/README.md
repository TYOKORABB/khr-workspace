# khr_rl_sample の手元の変更

作業 PC の `khr_rl_sample/`（s-kajita/khr_rl_sample の `24d9a47`）にだけある変更。s-kajita には push しないので、パッチで残す。
内容: `khr_train.py` の初期姿勢（股関節 −0.2 → −0.5、膝 0.4 → 1.0、足首 −0.2 → −0.5 rad）と、胴体の目標の高さ（0.254 → 0.2395 m）、前進の指令の範囲（±0.2 → ±0.4 m/s）の 8 行。

当て方: `cd khr_rl_sample && git checkout 24d9a47 && git apply ../khr-workspace/patches/khr_rl_sample/khr_train.py.patch`
