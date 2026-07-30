local Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll = nil

local ORIGIN_OFFSET = 64
local ANTI_CLIP_OFFSET = 4

net.Receive("Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll", function()
    local ragdoll = net.ReadEntity()
    Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll = ragdoll
end)

hook.Add("CalcView", "ReAgdoll_Patch_CalcView", function(ply, origin, angles, fov, znear, zfar)
    local ragdoll = Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll
    if not IsValid(ragdoll) then return end
    if not IsValid(ply) then return end
    if ply:Alive() then return end

    local ragdollEye = ragdoll:EyePos()
    local dir = -angles:Forward()
    local tr = util.TraceLine({
        start = ragdollEye,
        endpos = ragdollEye + dir * ORIGIN_OFFSET,
        filter = { ply, ragdoll },
    })

    local newOrigin
    if tr.Hit then
        local hitPos = tr.HitPos
        local distToEye = hitPos:Distance(ragdollEye)

        -- 只在碰撞点比理想球面更近时考虑限制（说明有物体遮挡，可能是地面）
        if distToEye < ORIGIN_OFFSET then
            -- 假设地面是水平的，取碰撞点的Z作为地面高度
            local groundZ = hitPos.z
            local d = ragdollEye.z - groundZ

            if d > 0 and d < ORIGIN_OFFSET then
                local r_circle = math.sqrt(ORIGIN_OFFSET ^ 2 - d ^ 2)
                local center = Vector(ragdollEye.x, ragdollEye.y, groundZ)

                -- 水平方向：相机在眼睛背后，所以用 -Forward 的水平投影
                local horizDir = Vector(dir.x, dir.y, 0)
                if horizDir:Length() < 0.001 then
                    -- 垂直向下看时，水平方向无定义，不做圆限制，沿用原逻辑
                    newOrigin = hitPos - dir * ANTI_CLIP_OFFSET
                else
                    horizDir:Normalize()
                    local distToCenter = (hitPos - center):Length2D()
                    if distToCenter < r_circle then
                        -- 碰撞点在圆内，推到圆边缘
                        local pointOnCircle = center + horizDir * r_circle
                        newOrigin = pointOnCircle - dir * ANTI_CLIP_OFFSET
                    else
                        -- 不在圆内，保持原样
                        newOrigin = hitPos - dir * ANTI_CLIP_OFFSET
                    end
                end
            else
                -- 平面不相交，或眼睛在地面以下，保持原逻辑
                newOrigin = hitPos - dir * ANTI_CLIP_OFFSET
            end
        else
            -- 碰撞点刚好在球面上或外面，直接使用
            newOrigin = hitPos - dir * ANTI_CLIP_OFFSET
        end
    else
        -- 无碰撞，理想球面位置
        newOrigin = ragdollEye + dir * ORIGIN_OFFSET
    end

    return {
        origin = newOrigin,
        angles = angles,
        fov = fov,
        znear = znear,
        zfar = zfar,
        drawviewer = false,
    }
end)
