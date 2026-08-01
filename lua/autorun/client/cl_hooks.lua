local Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll = nil

local ORIGIN_OFFSET = 64
local ORIGIN_OFFSET_SQR = ORIGIN_OFFSET * ORIGIN_OFFSET
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
        local d = ragdollEye.z - hitPos.z

        if d > 0 then
            local center = Vector(ragdollEye.x, ragdollEye.y, hitPos.z)
            local horizDir = Vector(dir.x, dir.y, 0)

            -- 水平方向几乎为零，无法确定圆上的位置，交给引擎默认视角
            if horizDir:LengthSqr() < 0.0001 then
                return
            end

            horizDir:Normalize()
            local rCircleSqr = ORIGIN_OFFSET_SQR - d * d
            if hitPos:Distance2DSqr(center) < rCircleSqr then
                local r_circle = math.sqrt(rCircleSqr)
                local pointOnCircle = center + horizDir * r_circle
                newOrigin = pointOnCircle - dir * ANTI_CLIP_OFFSET
            else
                newOrigin = hitPos - dir * ANTI_CLIP_OFFSET
            end
        else
            -- 眼睛在地面下或碰撞点高于眼睛，不做圆限制
            newOrigin = hitPos - dir * ANTI_CLIP_OFFSET
        end
    else
        -- 无遮挡，使用理想球面位置
        newOrigin = ragdollEye + dir * ORIGIN_OFFSET
    end

    -- 强制视线指向眼睛
    local viewAngles = (ragdollEye - newOrigin):Angle()

    return {
        origin = newOrigin,
        angles = viewAngles,
        fov = fov,
        znear = znear,
        zfar = zfar,
        drawviewer = false,
    }
end)
