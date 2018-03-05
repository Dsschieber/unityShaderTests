// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "unityCookie/tut/beginner/9 - Optimized"{
	Properties{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_MainTex ("Diffuse Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_EmitMap ("Emission Texture", 2D) = "black" {}
		_BumpDepth ("Bump Depth", Range(0.0, 1.0)) = 1.0
		_Shininess ("Shininess", Float) = 10
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimColor ("Rim Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ("Rim Power", Range(0.1, 10.0)) = 3.0
		_EmitStrength ("Emission Strength", Range(0.0, 3.0)) = 0
	}
	SubShader{
		
		Pass{
			Tags {"LightMode" = "ForwardBase"}
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			//user defined
			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed4 _RimColor;
			uniform half4 _MainTex_ST;
			uniform half4 _BumpMap_ST;
			uniform half4 _EmitMap_ST;
			
			uniform half  _RimPower;
			uniform half  _Shininess;
			uniform fixed  _BumpDepth;
			uniform fixed  _EmitStrength;

			uniform sampler2D _MainTex;
			uniform sampler2D _BumpMap;
			uniform sampler2D _EmitMap;
			

			//unity defined variables
			uniform half4 _LightColor0;
			
			struct vertexInput{
				half4 vertex   : POSITION;
				half3 normal   : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 tangent  : TANGENT;
			};
			struct vertexOutput{
				half4 pos            : SV_POSITION;
				half4 tex            : TEXCOORD0;
				half4 lightDirection : TEXCOORD1;
				half3 viewDirection  : TEXCOORD2;
				fixed3 normalWorld    : TEXCOORD3;
				fixed3 tangentWorld   : TEXCOORD4;
				fixed3 binormalWorld  : TEXCOORD5;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject; 

				o.normalWorld   = normalize(mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
				o.tangentWorld  = normalize(mul(modelMatrix, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);


				half4 posWorld = mul(modelMatrix, v.vertex);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;
								
				o.viewDirection = normalize( _WorldSpaceCameraPos.xyz - posWorld.xyz);
				
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
				half3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w));
				half atten = lerp( 1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w );

				o.lightDirection =  float4(lightDirection, atten);

				return o;
			}
			
			//fragment function
			fixed4 frag(vertexOutput i) : COLOR{

				//texture maps
				fixed4 tex  = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw); //tex2D(_BumpMap, _BumpMap_ST.xy * input.tex.xy + _BumpMap_ST.zw);
				fixed4 texE = tex2D(_EmitMap, i.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw);

				//unpack Normal function
				fixed3 localCoords = float3(2.0 * texN.a - 1.0, 2.0 * texN.g - 1.0, 0.0);
				localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

				//normal transpose matrix
				half3x3 local2WorldTranspose = half3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);

				//calculate normal direction
				fixed3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));
				fixed nDotL = saturate(dot(normalDirection, i.lightDirection.xyz));

				//lighting
				fixed3 diffuseDirection = i.lightDirection.w * _LightColor0.rgb * nDotL;
				fixed3 specularReflection = diffuseDirection * _SpecColor.xyz * pow( saturate(dot( reflect(-i.lightDirection.xyz, normalDirection), i.viewDirection ) ), _Shininess);

				//rim Lighting
				fixed rim = 1 - saturate(dot(i.viewDirection, normalDirection));
				fixed3 rimLighting = nDotL * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower);

				fixed3 indirectDiffuse = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				fixed3 lightFinal = rimLighting + (texE.xyz + _EmitStrength) + diffuseDirection + (specularReflection * tex.a ) + indirectDiffuse;
				return fixed4(i.lightDirection.w * tex.xyz * lightFinal * _Color.xyz, 1.0);
				//return fixed4(lightFinal , 1.0);

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
			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed4 _RimColor;
			uniform half4 _MainTex_ST;
			uniform half4 _BumpMap_ST;
			uniform half4 _EmitMap_ST;
			
			uniform half  _RimPower;
			uniform half  _Shininess;
			uniform fixed  _BumpDepth;
			uniform fixed  _EmitStrength;

			uniform sampler2D _MainTex;
			uniform sampler2D _BumpMap;
			uniform sampler2D _EmitMap;
			

			//unity defined variables
			uniform half4 _LightColor0;
			
			struct vertexInput{
				half4 vertex   : POSITION;
				half3 normal   : NORMAL;
				half4 texcoord : TEXCOORD0;
				half4 tangent  : TANGENT;
			};
			struct vertexOutput{
				half4 pos            : SV_POSITION;
				half4 tex            : TEXCOORD0;
				half4 lightDirection : TEXCOORD1;
				half3 viewDirection  : TEXCOORD2;
				fixed3 normalWorld    : TEXCOORD3;
				fixed3 tangentWorld   : TEXCOORD4;
				fixed3 binormalWorld  : TEXCOORD5;
			};

			//vertex function
			vertexOutput vert(vertexInput v){
				vertexOutput o;

				float4x4 modelMatrix = unity_ObjectToWorld;
				float4x4 modelMatrixInverse = unity_WorldToObject; 

				o.normalWorld   = normalize(mul(float4(v.normal, 0.0), modelMatrixInverse).xyz);
				o.tangentWorld  = normalize(mul(modelMatrix, float4(v.tangent.xyz, 0.0)).xyz);
				o.binormalWorld = normalize(cross(o.normalWorld, o.tangentWorld) * v.tangent.w);


				half4 posWorld = mul(modelMatrix, v.vertex);

				o.pos = UnityObjectToClipPos(v.vertex);
				o.tex = v.texcoord;
								
				o.viewDirection = normalize( _WorldSpaceCameraPos.xyz - posWorld.xyz);
				
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - posWorld.xyz;
				half3 lightDirection = normalize(lerp(_WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w));
				half atten = lerp( 1.0, 1.0/length(fragmentToLightSource), _WorldSpaceLightPos0.w );

				o.lightDirection =  float4(lightDirection, atten);

				return o;
			}
			
			//fragment function
			fixed4 frag(vertexOutput i) : COLOR{

				//texture maps
				fixed4 tex  = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 texN = tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw); //tex2D(_BumpMap, _BumpMap_ST.xy * input.tex.xy + _BumpMap_ST.zw);
				fixed4 texE = tex2D(_EmitMap, i.tex.xy * _EmitMap_ST.xy + _EmitMap_ST.zw);

				//unpack Normal function
				fixed3 localCoords = float3(2.0 * texN.a - 1.0, 2.0 * texN.g - 1.0, 0.0);
				localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));

				//normal transpose matrix
				half3x3 local2WorldTranspose = half3x3(
					i.tangentWorld,
					i.binormalWorld,
					i.normalWorld
				);

				//calculate normal direction
				fixed3 normalDirection = normalize(mul(localCoords, local2WorldTranspose));
				fixed nDotL = saturate(dot(normalDirection, i.lightDirection.xyz));

				//lighting
				fixed3 diffuseDirection = i.lightDirection.w * _LightColor0.rgb * nDotL;
				fixed3 specularReflection = diffuseDirection * _SpecColor.xyz * pow( saturate(dot( reflect(-i.lightDirection.xyz, normalDirection), i.viewDirection ) ), _Shininess);

				//rim Lighting
				fixed rim = 1 - saturate(dot(i.viewDirection, normalDirection));
				fixed3 rimLighting = nDotL * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower);

				fixed3 indirectDiffuse = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				
				fixed3 lightFinal = rimLighting + (texE.xyz + _EmitStrength) + diffuseDirection + (specularReflection * tex.a ) + indirectDiffuse;
				return fixed4(i.lightDirection.w * tex.xyz * lightFinal * _Color.xyz, 1.0);
				//return fixed4(lightFinal , 1.0);

			}

			ENDCG
		}
	}
	//Fallback "Specular"
}