local log = include("includes/log.lua")

util.AddNetworkString("ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll_Index")

hook.Add("PlayerSpawn", "ReAgdoll_Patch_PlayerSpawn", function(player, transition)
    if transition then return end
    if not IsValid(player) then return end
    player:SetShouldServerRagdoll(true)
end)

hook.Add("PostPlayerDeath", "ReAgdoll_Patch_PostPlayerDeath", function(ply)
    if not IsValid(ply) then return end

    local ragdoll = ply:GetRagdollEntity()
    if not IsValid(ragdoll) then return end

    ragdoll:Remove()
end)

hook.Add("CreateEntityRagdoll", "ReAgdoll_Patch_CreateEntityRagdoll", function(owner, ragdoll)
    if not IsValid(owner) then return end
    if not IsValid(ragdoll) then return end

    if not owner:IsPlayer() then return end
    local ply = owner
    local plyNick = ply:Nick()
    local ragdollIndex = ragdoll:EntIndex()

    net.Start("ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll_Index")
    net.WriteUInt(ragdollIndex, 16)
    net.Send(ply)
    log.trace(string.format("Sent %d >>>ReAgdoll_Patch_CreateEntityRagdoll_Player_Ragdoll_Index<<< to %s", ragdollIndex,
        plyNick))
end)
