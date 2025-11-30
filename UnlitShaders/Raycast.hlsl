#ifndef RAYCAST_INCLUDE_SAFE
#define RAYCAST_INCLUDE_SAFE

// 0. Don't worry about errors for missing dependencies, since unity will handle that for us

// 1. Raycast (Unchanged)
void Raycast_float(float3 RayOrigin, float3 RayDirection, float3 SphereOrigin, float SphereSize, 
                    out float Hit, out float3 HitPosition, out float3 HitNormal)
{
    // 1. Initialize Default Values (Safe State)
    Hit = float(0.0f);
    HitPosition = float3(0.0, 0.0, 0.0);
    HitNormal = float3(0.0, 0.0, 0.0);

    // 2. Perform Calculations
    float3 L = SphereOrigin - RayOrigin;
    float tca = dot(L, -RayDirection);

    // 3. Logic Flow (No "returns")
    // Only proceed if tca >= 0
    if (tca >= 0.0f) 
    {
        float d2 = dot(L, L) - tca * tca;
        float radius2 = SphereSize * SphereSize;

        // Only proceed if we are within the radius
        if (d2 <= radius2) 
        {
            float thc = sqrt(radius2 - d2);
            float t = tca - thc;

            // Success! Overwrite the default values.
            Hit = 1.0f;
            HitPosition = RayOrigin - RayDirection * t;
            HitNormal = normalize(HitPosition - SphereOrigin);
        }
    }
    // Function ends naturally here, ensuring all 'out' variables are set.
}

// 2. GetScreenPosition ( rewritten to avoid ComputeScreenPos dependency)
void GetScreenPosition_float(float3 Position, out float2 ScreenPosition, out float2 ScreenPositionAspectRatio)
{
    // MANUAL World To Clip Space (Standard Matrix Math)
    // We use the view and projection matrices directly, which are globally available
    float4 posCS = mul(UNITY_MATRIX_VP, float4(Position, 1.0));
    
    // MANUAL Screen Position Math
    float4 screenPos = posCS * 0.5f;
    screenPos.xy = float2(screenPos.x, screenPos.y * _ProjectionParams.x) + screenPos.w;
    screenPos.zw = posCS.zw;
    
    ScreenPosition = screenPos.xy / abs(screenPos.w);

    float aspectRatio = _ScreenParams.y / _ScreenParams.x;
    ScreenPositionAspectRatio = float2(ScreenPosition.x, ScreenPosition.y * aspectRatio);
}

// 3. GetCameraRight (Rewritten to avoid Library dependency)
void GetCameraRightWS_float(out float3 CameraRightWS)
{
    // Access the view matrix directly from global variables
    CameraRightWS = float3(UNITY_MATRIX_V[0].x, UNITY_MATRIX_V[1].x, UNITY_MATRIX_V[2].x);
}

// 4. MirrorUV (Unchanged)
void MirrorUVCoordinates_float(float2 UVs, out float2 NewUVs)
{
    if (UVs.x < 0.0 || UVs.x > 1.0)
        NewUVs.x = 1.0 - abs((UVs.x - 2.0 * floor(UVs.x / 2.0)) - 1.0);
    else
        NewUVs.x = UVs.x;

    if (UVs.y < 0.0 || UVs.y > 1.0)
        NewUVs.y = 1.0 - abs((UVs.y - 2.0 * floor(UVs.y / 2.0)) - 1.0);
    else
        NewUVs.y = UVs.y;
}

#endif