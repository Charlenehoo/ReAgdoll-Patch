local ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll = NULL

local ORIGIN_OFFSET = 64
local ANTI_CLIP_OFFSET = 4

net.Receive("ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll_Index", function()
    local index = net.ReadUInt(16)
    local ragdoll = Entity(index)

    if not IsValid(ragdoll) then return end

    ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll = ragdoll
end)

hook.Add("CalcView", "ReAgdoll_Patch_CalcView", function(ply, origin, angles, fov, znear, zfar)
    local ragdoll = ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll
    if not IsValid(ragdoll) then return end
    if not IsValid(ply) then return end
    if ply:Alive() then return end

    local ragdollEye = ragdoll:EyePos()
    local dir = -angles:Forward()
    local tr = util.TraceLine(
        {
            start = ragdollEye,
            endpos = ragdollEye + dir * ORIGIN_OFFSET,
            filter = { ply, ragdoll },
        }
    )

    local newOrigin = tr.Hit and tr.HitPos - dir * ANTI_CLIP_OFFSET or tr.HitPos

    return {
        origin = newOrigin,
        angles = angles,
        fov = fov,
        znear = znear,
        zfar = zfar,
        drawviewer = false,
        ortho = nil,
    }
end)

hook.Add("PlayerSpawn", "ReAgdoll_Patch_PlayerSpawn", function(player, transition)
    if transition then return end
    if not IsValid(player) then return end
    ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll = NULL
end)
