Shader "unityCookie/tut/beginner/6 - Texture Map"{
	Properties{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_Shininess ("Shininess", Float) = 10
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
	}
	SubShader{
		
		Pass{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			#pragma exclude_renderers flash

			//user defined
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float4 _MainTex_ST;
			
			uniform float  _RimPower;
			uniform float  _Shininess;

			uniform sampler2D _MainTex;
			

			//unity defined variables
			uniform float4 _LightColor0;
			
			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;

				return o;
			}
			
			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 lightDirection;
				float atten;

				if ( _WorldSpaceLightPos0.w == 0.0 ){
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float3 distance = length(fragmentToLightSource);
					atten = 1/distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				//lighting
				float3 diffuseDirection = atten * _LightColor0 * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseDirection * _SpecColor.xyz * pow( saturate(dot( reflect(-lightDirection, normalDirection), viewDirection ) ), _Shininess);

				//rim Lighting

				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = atten + _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);

				float3 lightFinal = rimLighting + diffuseDirection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
				

				//texture maps
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				return float4(atten * tex.xyz * lightFinal * _Color.xyz, 1.0);

			}

			ENDCG
		}
		Pass{
			Tags {"LightMode" = "ForwardAdd"}
			Blend One One
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//user defined
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float4 _MainTex_ST;
			
			uniform float  _RimPower;
			uniform float  _Shininess;

			uniform sampler2D _MainTex;
			

			//unity defined variables
			uniform float4 _LightColor0;
			
			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalDir : TEXCOORD2;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.posWorld = mul(unity_ObjectToWorld, v.vertex);
				o.normalDir = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;

				return o;
			}
			
			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz);
				float3 lightDirection;
				float atten;

				if ( _WorldSpaceLightPos0.w == 0.0 ){
					atten = 1.0;
					lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				}
				else{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float3 distance = length(fragmentToLightSource);
					atten = 1/distance;
					lightDirection = normalize(fragmentToLightSource);
				}

				//lighting
				float3 diffuseDirection = atten * _LightColor0 * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseDirection * _SpecColor.xyz * pow( saturate(dot( reflect(-lightDirection, normalDirection), viewDirection ) ), _Shininess);

				//rim Lighting

				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = atten + _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);

				float3 lightFinal = rimLighting + diffuseDirection + specularReflection;
				

				//texture maps
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);

				return float4(atten * lightFinal * _Color.xyz, 1.0);

			}

			ENDCG
		}
	}
	//Fallback "Specular"
}