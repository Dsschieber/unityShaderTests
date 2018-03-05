// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "unityCookie/tut/beginner/3b - specularPixel"{
	Properties{
		_Color ("Main Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess("Shininess", Float) = 1.0
	}
	SubShader{
		
		Pass{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//user defined
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;

			//unity defined variables
			uniform float4 _LightColor0;


			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}
			
			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				//vectors
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize(float3(_WorldSpaceCameraPos.xyz - i.posWorld.xyz));
				float3 lightDirection;
				float atten = 1.0;

				//lighting
				lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				float3 diffuseReflection = atten * _LightColor0.xyz * max(0.0, dot( normalDirection, lightDirection));
				float3 specularReflection = atten * _LightColor0.xyz * _SpecColor.rgb * max(0.0, dot(normalDirection, lightDirection)) * pow(max(0.0, dot(reflect(-lightDirection, normalDirection), viewDirection)), _Shininess); 
				float3 lightFinal = diffuseReflection + specularReflection + unity_AmbientSky.rgb; 
				return float4(lightFinal + _Color.rgb, 1.0);
			}


			ENDCG

		}
	}
	Fallback "Specular"

}