# 作業 PC の構成（2026-10-14 時点）

## 本体と OS

| 項目 | 内容 |
|---|---|
| CPU | AMD Ryzen 7 5700X（8 コア） |
| メモリ | 32 GB |
| GPU | NVIDIA GeForce RTX 5050 |
| OS | Ubuntu 24.04.5 LTS、カーネル 7.0.0-31-generic |
| NVIDIA ドライバ | `nvidia-driver-595-open`。2026-10-10 に自動更新で 595.99.02 になったが、再起動していないので動いているカーネル側は 595.84（そのため `nvidia-smi` が「Driver/library version mismatch」で動かない。学習は動く。再起動で直る） |
| CUDA | torch に同梱の CUDA 13.0（システムに CUDA Toolkit は入れていない） |
| Python | 3.12.3（Ubuntu の `/usr/bin/python3.12`） |

## ファームの書き込み（PlatformIO）

| 項目 | 版 |
|---|---|
| PlatformIO Core | 6.2.0（`~/.platformio/penv`） |
| platform espressif32 | 3.5.0 |
| framework-arduinoespressif32 | 3.10006.210326 |
| toolchain-xtensa32 | 2.50200.97 |
| tool-esptoolpy | 1.30100.210531 |
| board | esp32dev（`board_build.partitions = no_ota.csv`） |

`platformio.ini` のライブラリは「この版以上」の指定なので、実際に入っていた版を記録する:
ninagawa123/Meridian 0.1.0、Adafruit BNO055 1.6.4、Adafruit BusIO 1.17.4、Adafruit Unified Sensor 1.1.15、electroniccats/MPU6050 0.5.0。

この機体の ESP32 は、BOOT ボタンを押さないと書き込みモードに入らない。
