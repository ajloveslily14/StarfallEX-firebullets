SF.Permissions.registerPrivilege("entities.fireBullets","Fire bullets","Allows the user to fire bullets from the entity", { entities = {} })

local function main(instance)

	local ents_methods = instance.Types.Entity.Methods
	local checkluatype = SF.CheckLuaType
	local checktype = instance.CheckType
	local checkpermission = instance.player ~= NULL and SF.Permissions.check or function() end


	
	local vunwrap = instance.Types.Vector.Unwrap
	local entunwrap = instance.Types.Entity.Unwrap
	


	local bulletCheckTypes = {
		Damage = TYPE_NUMBER,
		Force = TYPE_NUMBER,
		Distance = TYPE_NUMBER,
		HullSize = TYPE_NUMBER,
		Num = TYPE_NUMBER,
		AmmoType = TYPE_STRING,
		TracerName = TYPE_STRING
	}

	local bulletCheckTypesIgnore = {Dir = true,Src = true,Callback = true,IgnoreEntity=true,Spread=true}

	--- Fires a bullet from an entity
	-- @server
	-- @param table BulletInfo
	function ents_methods:fireBullets(bulletInfo)
		local ent = entunwrap(self)
		checkpermission(instance,ent,"entities.fireBullets")
		checkluatype(bulletInfo,TYPE_TABLE)

		local newtbl = {}

		if bulletInfo.Dir ~= nil then local dir = bulletInfo.Dir checktype(dir,instance.Types.Vector.Metatable) newtbl.Dir = vunwrap(dir) end
		if bulletInfo.Src ~= nil then local src = bulletInfo.Src checktype(src,instance.Types.Vector.Metatable) newtbl.Src = vunwrap(src) end
		if bulletInfo.Spread ~= nil then local spread = bulletInfo.Spread checktype(spread,instance.Types.Vector.Metatable) newtbl.Spread = vunwrap(spread) end
		--if bulletInfo.Callback ~= nil then local callback = bulletInfo.Callback checkluatype(callback,TYPE_FUNCTION) newtbl.Callback = bulletInfo.Callback end this allows for RCE, and I don't want to bother sandboxing it.
		if bulletInfo.IgnoreEntity ~= nil then local ignore = bulletInfo.IgnoreEntity checktype(ignore,instance.Types.Entity) newtbl.IgnoreEntity = entunwrap(bulletInfo.IgnoreEntity) end

		for k,v in pairs(bulletInfo) do
			local check = bulletCheckTypes[k]
			if check then
				checkluatype(v,check)
				newtbl[k] = v
			elseif not bulletCheckTypesIgnore[k] then
				SF.Throw("Invalid key found in bulletInfo: " .. k, 2)
			end
		end

		newtbl.Attacker = instance.player -- Always make the attacker the owner of the chip
		if newtbl.Num then
			newtbl.Num = math.Clamp(newtbl.Damage,1,20) -- maybe this isn't even needed?
		end

		ent:FireBullets(newtbl)
	end
end

return main
