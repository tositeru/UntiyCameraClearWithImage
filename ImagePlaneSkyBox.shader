//  Copyright 2018 tositeru
//
//  Permission is hereby granted, free of charge,
//  to any person obtaining a copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation the rights to use, copy,
//  modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
//  INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


Shader "Skybox/Image Plane" {
    Properties{
        _Color("Color", Color) = (.5, .5, .5, .5)
        _BorderColor("BorderColor", Color) = (.5, .5, .5, .5)
        _Offset("Offset", Vector) = (0, 0, 0, 0) //zwは使っていない
        _ScaleX("Scale X", Float) = 1
        _ScaleY("Scale Y", Float) = 1
        _Rotation("Rotation", Range(0, 360)) = 0
        _ImageTex("Image", 2D) = "grey" {}
    }

        SubShader{
            Tags { "Queue" = "Background" "RenderType" = "Background" "PreviewType" = "Skybox" }
            Cull Off ZWrite Off

            CGINCLUDE
            #include "UnityCG.cginc"

            sampler2D _ImageTex;
            float4 _ImageTex_ST;
            half4 _Color;
            half4 _BorderColor;
            float4 _Offset;
            float _ScaleX;
            float _ScaleY;
            float _Rotation;

            struct appdata_t {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            struct v2f {
                float4 vertex : SV_POSITION;
                UNITY_VERTEX_OUTPUT_STEREO
            };
            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float2 TransformInDegrees(float2 vertex)
            {
                float alpha = _Rotation * UNITY_PI / 180.0;
                float sina, cosa;
                sincos(alpha, sina, cosa);
                float2x2 m = float2x2(cosa, -sina, sina, cosa);
                return mul(m, vertex / float2(_ScaleX, _ScaleY));
            }

            half4 skybox_frag(v2f i)
            {
                float2 texcoord = i.vertex.xy / _ScreenParams.xy;
                texcoord = TRANSFORM_TEX(texcoord, _ImageTex) + _Offset;

                float2 imageCenter = _ImageTex_ST.xy * 0.5f + _ImageTex_ST.zw;
                texcoord = TransformInDegrees(texcoord - imageCenter) + imageCenter;
                half4 tex = tex2D(_ImageTex, texcoord) * _Color;

                bool isOverBorder = any(texcoord.xy > _ImageTex_ST.xy+_ImageTex_ST.zw || texcoord.xy < _ImageTex_ST.zw);
                return lerp(tex, _BorderColor, isOverBorder);
            }

            ENDCG

            Pass {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #pragma target 2.0
                half4 frag(v2f i) : SV_Target { return skybox_frag(i); }
                ENDCG
            }
    }
}
