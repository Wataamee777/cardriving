# Godot 4 Android向け車両カスタマイズ設計

## 想定ノード構成

```text
CarRoot (VehicleBody3D)  [vehicle_customization_controller.gd]
├── CollisionShape3D
├── VisualRoot (Node3D)
│   └── BodyMesh (MeshInstance3D)
├── WheelFL (VehicleWheel3D)
├── WheelFR (VehicleWheel3D)
├── WheelRL (VehicleWheel3D)
└── WheelRR (VehicleWheel3D)
```

`VehicleCustomizationController` は `VehicleBody3D` 直下に置くか、`VehicleBody3D` 自身にアタッチします。`vehicle_body`、4つの `VehicleWheel3D`、`AirSuspensionSettings` ResourceをInspectorで割り当てます。

## スクリプト責務

- `vehicle_customization_controller.gd`: 車高調整、購入済みフラグ、低車高時の底擦り風ダウンフォースを管理します。
- `air_suspension_settings.gd`: 最低・最高車高、ストローク量、低車高時の硬さ、底擦り係数などを車種別Resourceとして保持します。
- 将来追加する `engine_profile.gd`: トルクカーブ、レブリミット、最高速、ギア比を保持します。
- 将来追加する `tire_profile.gd`: タイヤ種別ごとの `wheel_friction_slip` とホイール半径を保持します。

## エアサス車高調の考え方

プレイヤーがエアサスを購入すると `purchase_air_suspension()` を呼び、以後は `set_ride_height(0.0〜1.0)`、`raise_height()`、`lower_height()` で何度でも調整できます。車高変更時のみ `VehicleWheel3D` の `suspension_rest_length`、`suspension_travel`、`suspension_stiffness`、`damping_compression`、`damping_relaxation` を更新するため、毎フレーム4輪にプロパティを書き込む実装よりAndroidで軽量です。

低車高では `low_ratio` を使ってサスペンションを硬くし、さらに `_physics_process()` で小さな下向き力と速度減衰をかけます。これは高コストなフェンダー接触判定や複雑なレイキャストを使わず、シャコタン時の跳ねや底擦り感を安価に表現するための近似です。

## Android最適化方針

- 車高パラメータは入力変更時だけ反映し、`_physics_process()` では底擦りの簡易処理だけ行います。
- 4輪配列は `_ready()` でキャッシュし、毎フレームのノード探索を避けます。
- Resource化した設定を使い、車種変更時も軽いデータ差し替えで済ませます。
- Compatibilityレンダラー前提では車両物理と描画負荷の両方を抑えるため、ホイールの接触エフェクトや火花は速度・距離・品質設定で間引きます。
