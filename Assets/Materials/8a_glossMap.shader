// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "unityCookie/tut/beginner/8a - Gloss Map"{
	Properties{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture Gloss(A)", 2D) = "bump" {}
		_BumpDepth ("Bump Depth", Range(-2.0, 2.0)) = 1.0
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
			uniform float4 _BumpMap_ST;
			
			uniform float  _RimPower;
			uniform float  _Shininess;
			uniform float  _BumpDepth;

			uniform sampler2D _MainTex;
			uniform sampler2D _BumpMap;
			

			//unity defined variables
			uniform float4 _LightColor0;
			
			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.normalWorld = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangentWorld = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);


				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;

				return o;
			}
			
			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				
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
				//texture maps
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				float4 texN= tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

				//unpack Normal function
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _BumpDepth;

				//normal transpose matrix
				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);

				//calculate normal direction
				float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));

				//lighting
				float3 diffuseDirection = atten * _LightColor0 * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseDirection * _SpecColor.xyz * pow( saturate(dot( reflect(-lightDirection, normalDirection), viewDirection ) ), _Shininess);

				//rim Lighting
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = atten + _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
				
				float3 lightFinal = rimLighting + diffuseDirection + (specularReflection * tex.a ) + UNITY_LIGHTMODEL_AMBIENT.rgb;
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
			#pragma exclude_renderers flash

			//user defined
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float4 _MainTex_ST;
			uniform float4 _BumpMap_ST;
			
			uniform float  _RimPower;
			uniform float  _Shininess;
			uniform float  _BumpDepth;

			uniform sampler2D _MainTex;
			uniform sampler2D _BumpMap;
			

			//unity defined variables
			uniform float4 _LightColor0;
			
			struct vertexInput{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;
			};
			struct vertexOutput{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 binormalWorld : TEXCOORD4;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				o.normalWorld = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				o.tangentWorld = normalize(mul(unity_ObjectToWorld, v.tangent).xyz);
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);


				o.posWorld = mul(unity_ObjectToWorld, v.vertex);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;

				return o;
			}
			
			//fragment function
			float4 frag(vertexOutput i) : COLOR{
				
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
				//texture maps
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				float4 texN= tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

				//unpack Normal function
				float3 localCoords = float3(2.0 * texN.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _BumpDepth;

				//normal transpose matrix
				float3x3 local2WorldTranspose = float3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);

				//calculate normal direction
				float3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));

				//lighting
				float3 diffuseDirection = atten * _LightColor0 * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseDirection * _SpecColor.xyz * pow( saturate(dot( reflect(-lightDirection, normalDirection), viewDirection ) ), _Shininess);

				//rim Lighting
				float rim = 1 - saturate(dot(viewDirection, normalDirection));
				float3 rimLighting = atten + _LightColor0.xyz * _RimColor * saturate(dot(normalDirection, lightDirection)) * pow(rim, _RimPower);
				
				float3 lightFinal = rimLighting + diffuseDirection + (specularReflection * tex.a );
				return float4(atten * lightFinal * _Color.xyz, 1.0);

			}

			ENDCG
		}
	}
	//Fallback "Specular"
}