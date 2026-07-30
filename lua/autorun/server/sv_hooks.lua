local log = include("includes/log.lua")

util.AddNetworkString("Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll")

hook.Add("PlayerSpawn", "ReAgdoll_Patch_PlayerSpawn", function(player, transition)
    if transition then return end
    if not IsValid(player) then return end
    player:SetShouldServerRagdoll(true)

    net.Start("Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll")
    net.WriteEntity(nil)
    net.Send(player)
end)

hook.Add("DoPlayerDeath", "ReAgdoll_Patch-DoPlayerDeath", function(ply, _, _)
    if not IsValid(ply) then return end
    ply:SetShouldServerRagdoll(true)
end)

hook.Add("PostPlayerDeath", "ReAgdoll_Patch-PostPlayerDeath", function(ply)
    if not IsValid(ply) then return end

    local ragdoll = ply:GetRagdollEntity()
    if not IsValid(ragdoll) then return end

    ragdoll:Remove()
end)

hook.Add("CreateEntityRagdoll", "ReAgdoll_Patch-CreateEntityRagdoll", function(owner, ragdoll)
    if not IsValid(owner) then return end
    if not IsValid(ragdoll) then return end
    if not owner:IsPlayer() then return end

    net.Start("Fully_Dynamic_Animated_Blood_Mod_Patch_Player_Ragdoll")
    net.WriteEntity(ragdoll)
    net.Send(owner)
end)
