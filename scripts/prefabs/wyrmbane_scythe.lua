local assets=
{ 
    Asset("ANIM", "anim/scythe_wrymbane.zip"),
    Asset("ANIM", "anim/swap_scythe_wrymbane.zip"), 

    Asset("ATLAS", "images/inventoryimages/scythe_wrymbane.xml"),
    Asset("IMAGE", "images/inventoryimages/scythe_wrymbane.tex"),
}

local prefabs = 
{
}

local function fn(colour)

    local function OnEquip(inst, owner) 
        owner.AnimState:OverrideSymbol("swap_object", "swap_scythe_wrymbane", "wyrmbane_book")
        owner.AnimState:Show("ARM_carry") 
        owner.AnimState:Hide("ARM_normal") 
        owner.AnimState:SetSortOrder(1)
    end

    local function OnUnequip(inst, owner) 
        owner.AnimState:Hide("ARM_carry") 
        owner.AnimState:Show("ARM_normal") 
    end

    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("scythe_wrymbane")
    anim:SetBuild("scythe_wrymbane")
    anim:PlayAnimation("idle")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "scythe_wrymbane"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/scythe_wrymbane.xml"
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( OnEquip )
    inst.components.equippable:SetOnUnequip( OnUnequip )

    return inst
end

return  Prefab("common/inventory/scythe_wrymbane", fn, assets, prefabs)