画像を使ったカメラクリアー

このリポジトリにあるシェーダを使うことでカメラクリアーのときに好きな画像で行えるようになります。

設定手順

1.ImagePlaneSkyBox.shaderを使用したマテリアルを新しく作る

2.Window -> Rendering -> Lighting Settingをクリック

3.SceneタブのEnviromentにあるSkybox Materialに1.で作ったマテリアルを設定する

以上

問題点と備考

スカイボックスとして無理やり指定しているので、Skyboxを利用した環境光や反射計算がおかしい感じになってしまう。

修正方法

3.で指定したものの近くにEnvironment LightingとEnviroment Reflectionsの各SourceをSkybox以外しておけばOK。

License

MIT License

