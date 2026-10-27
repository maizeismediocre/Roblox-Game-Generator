--[[
	SceneryScan - whole-area scenery scanner (edit-time tool, the model-qa skill section 1.4).
	Lives at ServerStorage/ArtTools/SceneryScan (installed in Build Phase 1 from studio_tools/SceneryScan.luau).

	local SC = require(game.ServerStorage.ArtTools.SceneryScan)
	local r = SC.Scan({workspace.Hub, ...}, {support = {workspace.Baseplate}, eps = 0.02})
	print(r.summary)  -- r.flicker / r.floating / r.dupes / r.hidden hold the details

	The same checks as ModelKit.Check / FindFlicker, but with a grid so it can run over whole
	zones and areas (thousands of parts) without freezing Studio:
	- flicker: two blocks with a different colour/material whose faces lie in the same plane (gap
	  under 0.005, or under eps = 0.02 on a patch of 1+ square studs: z-fighting seen from far away) on a patch you can see
	- floating: groups of touching parts that touch no support part and no terrain
	  (Terrain: a ray down from the group's lowest points, or terrain voxels at their feet)
	- dupes: two parts with the same size + place (one is wasted, or they flicker)
	- hidden: parts completely inside another part (wasted, count only)
	Parts with Transparency 1 are ignored. Wedges/unions take part in floating, not in flicker.
	Scan in PLAY (on the server) when the game builds or dresses things at runtime.
]]

local SC = {}
local CELL = 8
local OFF = 4096

local function axes(cf)
	return {cf.RightVector, cf.UpVector, cf.LookVector}
end

local function aabb(p)
	local cf, s = p.CFrame, p.Size / 2
	local r, u, l = cf.RightVector, cf.UpVector, cf.LookVector
	local e = Vector3.new(
		math.abs(r.X) * s.X + math.abs(u.X) * s.Y + math.abs(l.X) * s.Z,
		math.abs(r.Y) * s.X + math.abs(u.Y) * s.Y + math.abs(l.Y) * s.Z,
		math.abs(r.Z) * s.X + math.abs(u.Z) * s.Y + math.abs(l.Z) * s.Z)
	return cf.Position - e, cf.Position + e
end

local function isBlock(p)
	return p:IsA("Part") and p.Shape == Enum.PartType.Block
end

local function isAligned(p)
	if not isBlock(p) then return false end
	for _, v in axes(p.CFrame) do
		if math.max(math.abs(v.X), math.abs(v.Y), math.abs(v.Z)) < 0.9999 then return false end
	end
	return true
end

local function insidePart(p, pt)
	local lp = p.CFrame:PointToObjectSpace(pt)
	local h = p.Size / 2
	return math.abs(lp.X) < h.X and math.abs(lp.Y) < h.Y and math.abs(lp.Z) < h.Z
end

-- two (rotated) boxes touch or overlap within tol (separating-axis test, 15 axes)
local function touching(a, b, tol)
	local ca, cb = a.CFrame, b.CFrame
	local A, B = axes(ca), axes(cb)
	local ha, hb = a.Size / 2, b.Size / 2
	local d = cb.Position - ca.Position
	local list = {A[1], A[2], A[3], B[1], B[2], B[3]}
	for i = 1, 3 do
		for j = 1, 3 do
			local c = A[i]:Cross(B[j])
			if c.Magnitude > 1e-4 then table.insert(list, c.Unit) end
		end
	end
	for _, ax in list do
		local ra = ha.X * math.abs(A[1]:Dot(ax)) + ha.Y * math.abs(A[2]:Dot(ax)) + ha.Z * math.abs(A[3]:Dot(ax))
		local rb = hb.X * math.abs(B[1]:Dot(ax)) + hb.Y * math.abs(B[2]:Dot(ax)) + hb.Z * math.abs(B[3]:Dot(ax))
		if math.abs(d:Dot(ax)) > ra + rb + tol then return false end
	end
	return true
end

local function short(inst, root)
	local names = {}
	local x = inst
	while x and x ~= root and x.Parent and #names < 4 do
		table.insert(names, 1, x.Name)
		x = x.Parent
	end
	return table.concat(names, ".")
end

local function cellKey(x, y, z)
	return ((x + OFF) * 8192 + (y + OFF)) * 8192 + (z + OFF)
end

local function terrainAt(pt)
	local reg = Region3.new(pt - Vector3.new(0.5, 0.5, 0.5), pt + Vector3.new(0.5, 0.5, 0.5)):ExpandToGrid(4)
	local _, occ = workspace.Terrain:ReadVoxels(reg, 4)
	local o = occ[1] and occ[1][1] and occ[1][1][1]
	return o or 0
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Include
rayParams.FilterDescendantsInstances = {workspace.Terrain}

-- is this part resting on / sunk into terrain? (gap below its lowest points under 0.15)
local function onTerrain(p, lo, hi)
	local pts = {
		Vector3.new((lo.X + hi.X) / 2, lo.Y, (lo.Z + hi.Z) / 2),
		Vector3.new(lo.X + 0.05, lo.Y, lo.Z + 0.05), Vector3.new(hi.X - 0.05, lo.Y, lo.Z + 0.05),
		Vector3.new(lo.X + 0.05, lo.Y, hi.Z - 0.05), Vector3.new(hi.X - 0.05, lo.Y, hi.Z - 0.05),
	}
	for _, pt in pts do
		local hit = workspace:Raycast(pt + Vector3.new(0, 1, 0), Vector3.new(0, -2.5, 0), rayParams)
		if hit and pt.Y - hit.Position.Y < 0.15 then return true end
		if terrainAt(pt + Vector3.new(0, 0.3, 0)) > 0.4 then return true end
	end
	return false
end

function SC.Scan(roots, opts)
	opts = opts or {}
	local eps = opts.eps or 0.02
	local tol = opts.tol or 0.05
	local parts, isSupport, rootOf = {}, {}, {}
	local function add(r, support)
		local list = r:IsA("BasePart") and {r} or r:GetDescendants()
		for _, p in list do
			if p:IsA("BasePart") and p.Transparency < 1 then
				table.insert(parts, p)
				isSupport[#parts] = support
				rootOf[#parts] = r
			end
		end
	end
	for _, r in roots do add(r, false) end
	for _, r in opts.support or {} do add(r, true) end
	local n = #parts
	local lo, hi, aligned = table.create(n), table.create(n), table.create(n)
	local grid, big = {}, {}
	for i, p in parts do
		lo[i], hi[i] = aabb(p)
		aligned[i] = isAligned(p)
		-- (padded by tol: parts touching right on a cell border must still meet in one cell)
		local x0, x1 = math.floor((lo[i].X - tol) / CELL), math.floor((hi[i].X + tol) / CELL)
		local y0, y1 = math.floor((lo[i].Y - tol) / CELL), math.floor((hi[i].Y + tol) / CELL)
		local z0, z1 = math.floor((lo[i].Z - tol) / CELL), math.floor((hi[i].Z + tol) / CELL)
		if (x1 - x0 + 1) * (y1 - y0 + 1) * (z1 - z0 + 1) > 30000 then
			table.insert(big, i)
		else
			for x = x0, x1 do
				for y = y0, y1 do
					for z = z0, z1 do
						local k = cellKey(x, y, z)
						local c = grid[k]
						if not c then c = {}; grid[k] = c end
						table.insert(c, i)
					end
				end
			end
		end
		if i % 3000 == 0 then task.wait() end
	end

	local function near(pt)
		local c = grid[cellKey(math.floor(pt.X / CELL), math.floor(pt.Y / CELL), math.floor(pt.Z / CELL))]
		return c or {}
	end
	local function covered(pt, a, b)
		for _, k in near(pt) do
			if k ~= a and k ~= b and insidePart(parts[k], pt) then return true end
		end
		for _, k in big do
			if k ~= a and k ~= b and insidePart(parts[k], pt) then return true end
		end
		if opts.terrain ~= false and terrainAt(pt) > 0.6 then return true end
		return false
	end

	-- union-find for the floating check
	local up = table.create(n)
	for i = 1, n do up[i] = i end
	local function find(i)
		while up[i] ~= i do up[i] = up[up[i]]; i = up[i] end
		return i
	end
	local function union(a, b)
		a, b = find(a), find(b)
		if a ~= b then up[a] = b end
	end

	local flicker, dupes, hidden = {}, {}, {}
	local seenPair = {}
	local tests = 0
	local function pair(i, j)
		local a, b = parts[i], parts[j]
		local li, hi_, lj, hj = lo[i], hi[i], lo[j], hi[j]
		if li.X > hj.X + tol or lj.X > hi_.X + tol or li.Y > hj.Y + tol or lj.Y > hi_.Y + tol
			or li.Z > hj.Z + tol or lj.Z > hi_.Z + tol then
			return
		end
		if find(i) ~= find(j) and touching(a, b, tol) then union(i, j) end
		if isSupport[i] and isSupport[j] then return end
		if (a.Position - b.Position).Magnitude < 0.002 and (a.Size - b.Size).Magnitude < 0.002 then
			table.insert(dupes, {a, b})
			return
		end
		if aligned[i] and aligned[j] and (a.Color ~= b.Color or a.Material ~= b.Material) then
			for _, ax in {"X", "Y", "Z"} do
				local o1, o2 = (ax == "X" and "Y" or "X"), (ax == "Z" and "Y" or "Z")
				local a1, b1 = math.max(li[o1], lj[o1]), math.min(hi_[o1], hj[o1])
				local a2, b2 = math.max(li[o2], lj[o2]), math.min(hi_[o2], hj[o2])
				if b1 - a1 > 0.01 and b2 - a2 > 0.01 then
					for _, side in {1, -1} do
						local pv = side == 1 and hi_[ax] or li[ax]
						local qv = side == 1 and hj[ax] or lj[ax]
						local gap = math.abs(pv - qv)
						-- exactly flush (any patch), or nearly flush on a big face (z-fights from far away)
						if gap < 0.005 or (gap < eps and (b1 - a1) * (b2 - a2) >= (opts.minArea or 1)) then
							local outer = side == 1 and math.max(pv, qv) or math.min(pv, qv)
							local visible = false
							for _, u in {0.2, 0.5, 0.8} do
								for _, v in {0.2, 0.5, 0.8} do
									local pt = {}
									pt[ax] = outer + side * 0.03
									pt[o1] = a1 + (b1 - a1) * u
									pt[o2] = a2 + (b2 - a2) * v
									if not covered(Vector3.new(pt.X, pt.Y, pt.Z), i, j) then
										visible = true
										break
									end
								end
								if visible then break end
							end
							if visible then
								table.insert(flicker, {a = a, b = b, axis = ax, gap = gap, area = (b1 - a1) * (b2 - a2),
									at = Vector3.new((li.X + hi_.X) / 2, (li.Y + hi_.Y) / 2, (li.Z + hi_.Z) / 2)})
							end
						end
					end
				end
			end
		end
	end

	for _, c in grid do
		for x = 1, #c do
			local i = c[x]
			for y = x + 1, #c do
				local j = c[y]
				local a, b = math.min(i, j), math.max(i, j)
				local k = a * 1048576 + b
				if not seenPair[k] then
					seenPair[k] = true
					pair(a, b)
					tests += 1
					if tests % 20000 == 0 then task.wait() end
				end
			end
		end
	end
	for _, i in big do
		for j = 1, n do
			if j ~= i then
				local a, b = math.min(i, j), math.max(i, j)
				local k = a * 1048576 + b
				if not seenPair[k] then
					seenPair[k] = true
					pair(a, b)
					tests += 1
					if tests % 20000 == 0 then task.wait() end
				end
			end
		end
	end
	seenPair = nil

	-- hidden: completely inside one other part (all 8 corners)
	if opts.hidden ~= false then
		for i, p in parts do
			local cf, h = p.CFrame, p.Size / 2
			local corners = {}
			for _, sx in {-1, 1} do
				for _, sy in {-1, 1} do
					for _, sz in {-1, 1} do
						table.insert(corners, cf * Vector3.new(sx * h.X * 0.999, sy * h.Y * 0.999, sz * h.Z * 0.999))
					end
				end
			end
			for _, k in near(p.Position) do
				if k ~= i and parts[k].Size.Magnitude > p.Size.Magnitude then
					local all = true
					for _, c in corners do
						if not insidePart(parts[k], c) then all = false; break end
					end
					if all then table.insert(hidden, {p, parts[k]}); break end
				end
			end
			if i % 2000 == 0 then task.wait() end
		end
	end

	-- floating groups
	local groups = {}
	for i = 1, n do
		local r = find(i)
		local g = groups[r]
		if not g then g = {}; groups[r] = g end
		table.insert(g, i)
	end
	local floating = {}
	local checked = 0
	for _, g in groups do
		local grounded = false
		for _, i in g do
			if isSupport[i] then grounded = true; break end
		end
		if not grounded then
			table.sort(g, function(a, b) return lo[a].Y < lo[b].Y end)
			for x = 1, math.min(#g, 40) do
				local i = g[x]
				checked += 1
				if onTerrain(parts[i], lo[i], hi[i]) then grounded = true; break end
			end
			if checked > 400 then task.wait(); checked = 0 end
		end
		if not grounded then
			local glo, ghi = lo[g[1]], hi[g[1]]
			for _, i in g do glo = glo:Min(lo[i]); ghi = ghi:Max(hi[i]) end
			table.insert(floating, {parts = g, first = parts[g[1]], root = rootOf[g[1]], lo = glo, hi = ghi})
		end
	end
	table.sort(floating, function(a, b) return #a.parts > #b.parts end)

	local lines = {string.format("%d parts, %d pair tests | flicker %d | floating groups %d | dupes %d | hidden %d",
		n, tests, #flicker, #floating, #dupes, #hidden)}
	local maxLines = opts.maxLines or 25
	for x, f in flicker do
		if x > maxLines then table.insert(lines, "  ... " .. (#flicker - maxLines) .. " more flicker"); break end
		table.insert(lines, string.format("  FLICKER %s | %s  %s gap %.3f area %.2f @ %.0f,%.0f,%.0f",
			short(f.a, workspace), short(f.b, workspace), f.axis, f.gap, f.area, f.at.X, f.at.Y, f.at.Z))
	end
	for x, f in floating do
		if x > maxLines then table.insert(lines, "  ... " .. (#floating - maxLines) .. " more floating"); break end
		local c = (f.lo + f.hi) / 2
		local hit = workspace:Raycast(Vector3.new(c.X, f.lo.Y, c.Z), Vector3.new(0, -200, 0))
		local below = hit and string.format("%.1f above %s", f.lo.Y - hit.Position.Y, hit.Instance.Name) or "nothing below"
		table.insert(lines, string.format("  FLOAT %d parts %s @ %.0f,%.0f,%.0f size %.1fx%.1fx%.1f (%s)",
			#f.parts, short(f.first, workspace), c.X, c.Y, c.Z, f.hi.X - f.lo.X, f.hi.Y - f.lo.Y, f.hi.Z - f.lo.Z, below))
	end
	for x, d in dupes do
		if x > 10 then table.insert(lines, "  ... " .. (#dupes - 10) .. " more dupes"); break end
		table.insert(lines, "  DUPE " .. short(d[1], workspace) .. " = " .. short(d[2], workspace))
	end
	return {summary = table.concat(lines, "\n"), flicker = flicker, floating = floating, dupes = dupes, hidden = hidden, parts = parts}
end

return SC
