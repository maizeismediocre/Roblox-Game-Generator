--[[
	ModelKit - builds blocky art out of plain Roblox parts and checks it (the model-qa tools).
	Lives at ServerStorage/ArtTools/ModelKit (installed in Build Phase 1 from studio_tools/ModelKit.luau).
	Edit-time tool: run it from execute_luau (Edit), e.g.
		local M = require(game.ServerStorage.ArtTools.ModelKit)
		M.Build("Lantern").Parent = workspace
	Recipes live in OTHER ModuleScripts next to this one (e.g. ArtTools/CharacterRecipes, ArtTools/PropRecipes)
	that add to M.Recipes:
		return function(M)
			local R, part, rgb, V = M.Recipes, M.part, M.rgb, Vector3.new
			R.Lantern = function(m, B)
				part(m, {name = "Body", size = V(1, 1.4, 1), pos = V(0, 0.7, 0), color = rgb(255, 200, 90)})
			end
		end
	and are loaded with M.Load(module).
	require() caches modules inside a session: after editing a recipe, require a fresh Clone of
	ModelKit + the recipe module (in a temp Folder in ServerStorage), then destroy the folder.

	Every model: front = -Z, bottom at y = 0, pivot at the bottom centre.
	ART RULES: flat SmoothPlastic colours, details sit flush on surfaces, nothing floating (Check),
	no flicker (FixFlicker runs in Build), no spheres/cylinders (part() turns them into blocks).
	NEON washes light colours out to white - give glowing parts a deep, saturated colour
	(e.g. rgb(150, 60, 255), not rgb(206, 150, 255)).
	The biggest part is "Body" (PrimaryPart); every other part is welded to it.

	Checkers (each returns a list; empty = OK):
		M.Check(model)         nothing floating, no flicker, no round parts
		M.FindClipping(model)  two different features (first word of the part name) cutting into each other
		M.FindFlicker(model)   faces in the same plane with different colours (z-fighting); M.FixFlicker fixes them
		M.CheckPieces(model)   repeated pieces (marked with M.asPiece) cutting into each other (model in workspace)
		M.Turnaround(names, folder, z0)  4 copies turned 0/90/180/270 on the review floor, for photos
	For whole areas (thousands of parts) use ArtTools/SceneryScan instead.
]]
local M = {}

local SMOOTH = Enum.Material.SmoothPlastic

local function rgb(r, g, b) return Color3.fromRGB(r, g, b) end
M.rgb = rgb

-- Cubes, never spheres or cylinders. Turns a round Part (Shape Ball or Cylinder) into chunky
-- blocks IN PLACE, keeping the same part (so its lights, welds, attachments and references stay valid):
--   small ball (<= 0.5)        -> one cube (0.8 x) turned 45 degrees
--   bigger ball                -> 3 crossed blocks (d x 0.7d x 0.7d along each axis) = a stepped ball
--   thin cylinder (dia <= 0.4)  -> a square bar (a thin disc: a diamond, turned 45 degrees)
--   bigger cylinder            -> 3 crossed blocks round its axis = a stepped round bar/disc
-- The extra blocks are children of the part, welded to it, with the same look/attributes/tags.
local ROUND_COPY = {"Color", "Material", "MaterialVariant", "Transparency", "Reflectance", "CastShadow", "Anchored",
	"CanCollide", "CanQuery", "CanTouch", "Massless", "CollisionGroup", "Locked"}
function M.Blockify(p)
	if not p:IsA("Part") then return false end
	local shape = p.Shape
	if shape ~= Enum.PartType.Ball and shape ~= Enum.PartType.Cylinder then return false end
	local cf, s = p.CFrame, p.Size
	local sizes
	if shape == Enum.PartType.Ball then
		local d = math.min(s.X, s.Y, s.Z)
		if d <= 0.5 then
			sizes = {Vector3.one * d * 0.8}
			cf = cf * CFrame.Angles(0, math.rad(45), 0)
		else
			local k = d * 0.7
			sizes = {Vector3.new(d, k, k), Vector3.new(k, d, k), Vector3.new(k, k, d)}
		end
	else
		local L, d = s.X, math.min(s.Y, s.Z)
		if d <= 0.4 then
			if L < d * 0.35 then
				sizes = {Vector3.new(L, d * 0.75, d * 0.75)}
				cf = cf * CFrame.Angles(math.rad(45), 0, 0)
			else
				sizes = {Vector3.new(L, d * 0.86, d * 0.86)}
			end
		else
			sizes = {Vector3.new(L, d, d * 0.6), Vector3.new(L, d * 0.6, d), Vector3.new(L, d * 0.72, d * 0.72)}
		end
	end
	p.Shape = Enum.PartType.Block
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Size = sizes[1]
	p.CFrame = cf
	for i = 2, #sizes do
		local e = Instance.new("Part")
		e.Name = p.Name
		for _, prop in ROUND_COPY do e[prop] = p[prop] end
		e.TopSurface = Enum.SurfaceType.Smooth
		e.BottomSurface = Enum.SurfaceType.Smooth
		e.Size = sizes[i]
		e.CFrame = cf
		for k, v in p:GetAttributes() do e:SetAttribute(k, v) end
		for _, t in p:GetTags() do e:AddTag(t) end
		e:SetAttribute("RoundBlock", true)
		local w = Instance.new("WeldConstraint"); w.Part0 = p; w.Part1 = e; w.Parent = e
		e.Parent = p
		-- later changes to the main part (textures, Piece/anim attributes) follow onto the extra block
		p:GetPropertyChangedSignal("Material"):Connect(function() e.Material = p.Material end)
		p:GetPropertyChangedSignal("Color"):Connect(function() e.Color = p.Color end)
		p:GetPropertyChangedSignal("Transparency"):Connect(function() e.Transparency = p.Transparency end)
		p.AttributeChanged:Connect(function(k) if k ~= "RoundBlock" then e:SetAttribute(k, p:GetAttribute(k)) end end)
	end
	return true
end

-- one part: {size, pos, color, [material], [shape], [rot (degrees vector)], [cframe], [name], [transparency], [shadow], [anim], [flap]}
-- shape "Round" = a stepped round block, "RoundBar" = a stepped round bar along X (see M.Blockify),
-- "Wedge", "Corner". Real spheres/cylinders are never made.
local function part(model, spec)
	local p = Instance.new("Part")
	p.Name = spec.name or "Block"
	p.Size = spec.size
	p.Color = spec.color
	p.Material = spec.material or SMOOTH
	local round = nil
	if spec.shape == "Ball" or spec.shape == "Round" then round = Enum.PartType.Ball
	elseif spec.shape == "Cylinder" or spec.shape == "RoundBar" then round = Enum.PartType.Cylinder
	elseif spec.shape == "Wedge" then p:Destroy(); p = Instance.new("WedgePart"); p.Name = spec.name or "Wedge"; p.Size = spec.size; p.Color = spec.color; p.Material = spec.material or SMOOTH
	elseif spec.shape == "Corner" then p:Destroy(); p = Instance.new("CornerWedgePart"); p.Name = spec.name or "Corner"; p.Size = spec.size; p.Color = spec.color; p.Material = spec.material or SMOOTH
	end
	p.Transparency = spec.transparency or 0
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Anchored = true
	p.CanCollide = false
	p.CastShadow = spec.shadow ~= false
	local r = spec.rot or Vector3.zero
	p.CFrame = spec.cframe or (CFrame.new(spec.pos) * CFrame.Angles(math.rad(r.X), math.rad(r.Y), math.rad(r.Z)))
	if round then p.Shape = round; M.Blockify(p) end
	if spec.flap then
		-- a wing piece: a client animator can flap it around this hinge (model space here;
		-- Build turns it into Body space). side = +1 right wing, -1 left wing.
		p:SetAttribute("FlapSide", spec.flap.side)
		p:SetAttribute("FlapHinge", spec.flap.hinge)
	end
	if spec.anim then
		-- a part that moves on its own (tail wag, lantern swing...): group = the animation config's
		-- group name; hinge = pivot point (model space here; Build turns it into Body space);
		-- axis = turn axis; phase = 0..1 offset in the cycle.
		p:SetAttribute("AnimGroup", spec.anim.group)
		if spec.anim.hinge then p:SetAttribute("AnimHinge", spec.anim.hinge) end
		if spec.anim.axis then p:SetAttribute("AnimAxis", spec.anim.axis) end
		if spec.anim.phase then p:SetAttribute("AnimPhase", spec.anim.phase) end
	end
	p.Parent = model
	return p
end
M.part = part

-- A standard friendly face on the front (-Z) face at height y, face plane z.
-- opts: eye (width, default 0.34), eyeTall, gap (half the distance between eyes), sleepy,
-- blush (false = none), blushColor, mouth (false = none, e.g. when a snout/beak is the mouth).
-- Eyes are named "Eye" (taller than wide) so an animator can blink them; "Shine" hides during a blink.
function M.face(model, y, z, opts)
	opts = opts or {}
	local gap = opts.gap or 0.32
	local s = opts.eye or 0.34
	local tall = opts.eyeTall or s * 1.25
	local black = rgb(30, 25, 35)
	-- keep the blush on the face: pull it in if it would hang off the side of the block behind it
	local blushX, blushY = gap + s * 0.9, y - tall * 0.62
	local front
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") and math.abs(p.CFrame.RightVector.X) > 0.999 and math.abs(p.CFrame.UpVector.Y) > 0.999 then
			local c, h = p.Position, p.Size / 2
			if math.abs(c.X) < 0.01 and math.abs(blushY - c.Y) < h.Y and z + 0.05 > c.Z - h.Z and z + 0.05 < c.Z + h.Z then
				if not front or math.abs(c.Z - h.Z - z) < front[1] then front = {math.abs(c.Z - h.Z - z), h.X} end
			end
		end
	end
	if front then blushX = math.min(blushX, front[2] - 0.01 - s * 0.35) end
	for _, sx in ipairs({-1, 1}) do
		if opts.sleepy then
			part(model, {name = "SleepyEye", size = Vector3.new(s, 0.08, 0.06), pos = Vector3.new(sx * gap, y, z - 0.03), color = black})
			-- hidden wide-open eyes: an animator can show them (and hide the sleepy ones) when it wakes up
			local eye = part(model, {name = "Eye", size = Vector3.new(s, tall, 0.06), pos = Vector3.new(sx * gap, y, z - 0.03), color = black, transparency = 1})
			local shine = part(model, {name = "Shine", size = Vector3.new(s * 0.35, s * 0.35, 0.04), pos = Vector3.new(sx * gap - s * 0.18, y + tall * 0.22, z - 0.07), color = rgb(255, 255, 255), transparency = 1})
			eye:SetAttribute("WakeEye", true)
			shine:SetAttribute("WakeEye", true)
		else
			part(model, {name = "Eye", size = Vector3.new(s, tall, 0.06), pos = Vector3.new(sx * gap, y, z - 0.03), color = black})
			part(model, {name = "Shine", size = Vector3.new(s * 0.35, s * 0.35, 0.04), pos = Vector3.new(sx * gap - s * 0.18, y + tall * 0.22, z - 0.07), color = rgb(255, 255, 255)}) -- plain white, not neon (glowing eyes look off-putting)
		end
		if opts.blush ~= false then
			part(model, {name = "Blush", size = Vector3.new(s * 0.7, s * 0.3, 0.04), pos = Vector3.new(sx * blushX, blushY, z - 0.02), color = opts.blushColor or rgb(255, 150, 170)})
		end
	end
	if opts.mouth ~= false then
		part(model, {name = "Mouth", size = Vector3.new(s * 0.55, 0.07, 0.05), pos = Vector3.new(0, y - tall * 0.7, z - 0.03), color = black})
	end
end

-- A flat 5-pointed star facing front (XY plane) at c, s = tip distance from the middle: each point
-- is two mirrored wedges round a stepped middle (stars always have 5 points - never 4, 6 or 8)
function M.star5(model, name, c, s, color, extra)
	local function spec(t) for k, v in pairs(extra or {}) do t[k] = v end return t end
	local th = s * 0.25
	part(model, spec({name = name, size = Vector3.new(s * 0.62, s * 0.4, th), pos = c, color = color}))
	part(model, spec({name = name, size = Vector3.new(s * 0.4, s * 0.62, th), pos = c, color = color}))
	for k = 0, 4 do
		local arm = CFrame.new(c) * CFrame.Angles(0, 0, math.rad(k * 72)) * CFrame.new(0, s * 0.62, 0)
		for _, side in ipairs({-1, 1}) do
			part(model, spec({name = name, size = Vector3.new(th, s * 0.8, s * 0.3), cframe = arm * CFrame.new(side * s * 0.15, 0, 0) * CFrame.Angles(0, math.rad(side * -90), 0), color = color, shape = "Wedge"}))
		end
	end
end

-- Marks every part fn() adds to m as one PIECE (attribute Piece = id), so CheckPieces can find
-- two different pieces cutting into each other (FindClipping can't: they share part names).
-- Use it whenever a recipe repeats a thing (crystals, mushrooms, clouds, flowers...).
-- The first part is the piece's Root (allowed to rest inside the main structure); allRoot = every part may.
function M.asPiece(m, id, fn, allRoot)
	local before = {}
	for _, c in m:GetChildren() do before[c] = true end
	fn()
	local first = true
	for _, c in m:GetChildren() do
		if not before[c] then
			c:SetAttribute("Piece", id)
			if first or allRoot then c:SetAttribute("Root", true) end
			first = false
		end
	end
end

-- World box of a part (handles rotation).
local function worldBox(p)
	local cf, s = p.CFrame, p.Size / 2
	local ext = Vector3.new(
		math.abs(cf.RightVector.X) * s.X + math.abs(cf.UpVector.X) * s.Y + math.abs(cf.LookVector.X) * s.Z,
		math.abs(cf.RightVector.Y) * s.X + math.abs(cf.UpVector.Y) * s.Y + math.abs(cf.LookVector.Y) * s.Z,
		math.abs(cf.RightVector.Z) * s.X + math.abs(cf.UpVector.Z) * s.Y + math.abs(cf.LookVector.Z) * s.Z)
	return cf.Position - ext, cf.Position + ext
end

local function isAligned(p)
	local function axis(v) return math.abs(v.X) > 0.999 or math.abs(v.Y) > 0.999 or math.abs(v.Z) > 0.999 end
	return axis(p.CFrame.RightVector) and axis(p.CFrame.UpVector)
end

-- Finds pairs of parts whose faces sit in exactly the same plane, facing the same way, overlapping,
-- with different colours, where that face is actually VISIBLE (not buried inside another part).
-- Those flicker (z-fighting).
function M.FindFlicker(model)
	local parts = {}
	for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") and p.Transparency < 1 then table.insert(parts, p) end end
	local boxes = {}
	for _, p in ipairs(parts) do local lo, hi = worldBox(p); boxes[p] = {lo, hi} end
	local function insideAny(point, exclude1, exclude2)
		for _, p in ipairs(parts) do
			if p ~= exclude1 and p ~= exclude2 then
				local lo, hi = boxes[p][1], boxes[p][2]
				if point.X > lo.X and point.X < hi.X and point.Y > lo.Y and point.Y < hi.Y and point.Z > lo.Z and point.Z < hi.Z then return true end
			end
		end
		return false
	end
	local found = {}
	local eps = 0.003
	for i = 1, #parts do
		for j = i + 1, #parts do
			local p, q = parts[i], parts[j]
			if isAligned(p) and isAligned(q) and (p.Color ~= q.Color or p.Material ~= q.Material) then
				local pmin, pmax = boxes[p][1], boxes[p][2]
				local qmin, qmax = boxes[q][1], boxes[q][2]
				for _, ax in ipairs({"X", "Y", "Z"}) do
					local o1, o2 = (ax == "X" and "Y" or "X"), (ax == "Z" and "Y" or "Z")
					local lo1, hi1 = math.max(pmin[o1], qmin[o1]), math.min(pmax[o1], qmax[o1])
					local lo2, hi2 = math.max(pmin[o2], qmin[o2]), math.min(pmax[o2], qmax[o2])
					if hi1 - lo1 > 0.01 and hi2 - lo2 > 0.01 then
						for _, side in ipairs({1, -1}) do
							local pv = side == 1 and pmax[ax] or pmin[ax]
							local qv = side == 1 and qmax[ax] or qmin[ax]
							if math.abs(pv - qv) < eps then
								-- sample the shared patch just outside the face; visible if any sample is in open air
								local visible = false
								for _, u in ipairs({0.25, 0.5, 0.75}) do
									for _, v in ipairs({0.25, 0.5, 0.75}) do
										local pt = {}
										pt[ax] = pv + side * 0.01
										pt[o1] = lo1 + (hi1 - lo1) * u
										pt[o2] = lo2 + (hi2 - lo2) * v
										if not insideAny(Vector3.new(pt.X, pt.Y, pt.Z), p, q) then visible = true end
									end
								end
								if visible then table.insert(found, {p = p, q = q, axis = ax}) end
							end
						end
					end
				end
			end
		end
	end
	return found
end

-- Fixes flicker: the smaller part of each pair is shrunk a hair (0.008 studs) on that axis, so the
-- two faces no longer sit in the same plane. Invisible to the eye, kills the flicker.
function M.FixFlicker(model)
	for _ = 1, 3 do
		local found = M.FindFlicker(model)
		if #found == 0 then return end
		for _, f in ipairs(found) do
			local p, q = f.p, f.q
			local small = (p.Size.X * p.Size.Y * p.Size.Z <= q.Size.X * q.Size.Y * q.Size.Z) and p or q
			-- shrink along the WORLD axis = the matching local axis of an aligned part
			local worldAxis = f.axis == "X" and Vector3.xAxis or f.axis == "Y" and Vector3.yAxis or Vector3.zAxis
			local localAxis = small.CFrame:VectorToObjectSpace(worldAxis)
			local shrink = Vector3.new(math.abs(localAxis.X), math.abs(localAxis.Y), math.abs(localAxis.Z)) * 0.008
			local cf = small.CFrame
			small.Size -= shrink
			small.CFrame = cf
		end
	end
end

-- Clipping check: two parts from DIFFERENT features (e.g. "Wing" vs "Crown") cutting into each other
-- where you can see it. A part's feature = the first word of its name (WingSpot -> Wing).
-- Overlaps hidden inside a third part (e.g. both buried in the Body) are ignored.
function M.FindClipping(model)
	local parts = {}
	for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts, p) end end
	local function feature(name) return name:match("^%u%l*") or name end
	local boxes = {}
	for _, p in ipairs(parts) do local lo, hi = worldBox(p); boxes[p] = {lo, hi} end
	local function inside(pt, a, b)
		for _, p in ipairs(parts) do
			if p ~= a and p ~= b then
				local lo, hi = boxes[p][1], boxes[p][2]
				if pt.X > lo.X and pt.X < hi.X and pt.Y > lo.Y and pt.Y < hi.Y and pt.Z > lo.Z and pt.Z < hi.Z then return true end
			end
		end
		return false
	end
	local found = {}
	for i = 1, #parts do
		for j = i + 1, #parts do
			local p, q = parts[i], parts[j]
			if p ~= model.PrimaryPart and q ~= model.PrimaryPart and feature(p.Name) ~= feature(q.Name) then
				local lo = Vector3.new(math.max(boxes[p][1].X, boxes[q][1].X), math.max(boxes[p][1].Y, boxes[q][1].Y), math.max(boxes[p][1].Z, boxes[q][1].Z))
				local hi = Vector3.new(math.min(boxes[p][2].X, boxes[q][2].X), math.min(boxes[p][2].Y, boxes[q][2].Y), math.min(boxes[p][2].Z, boxes[q][2].Z))
				local d = hi - lo
				if d.X > 0.03 and d.Y > 0.03 and d.Z > 0.03 then
					-- visible if the overlap's centre isn't buried in some other part
					if not inside((lo + hi) / 2, p, q) then
						table.insert(found, string.format("%s x %s (overlap %.2f x %.2f x %.2f)", p.Name, q.Name, d.X, d.Y, d.Z))
					end
				end
			end
		end
	end
	return found
end

-- Quality check: every part must touch or overlap another part (nothing floating), the whole
-- model must be one connected piece, nothing flickers and nothing is round. Returns a list of
-- problems (empty = OK).
function M.Check(model)
	local parts = {}
	for _, p in ipairs(model:GetDescendants()) do if p:IsA("BasePart") then table.insert(parts, p) end end
	local tol = 0.01
	local function touching(a, b)
		local amin, amax = worldBox(a); local bmin, bmax = worldBox(b)
		return amin.X <= bmax.X + tol and bmin.X <= amax.X + tol
			and amin.Y <= bmax.Y + tol and bmin.Y <= amax.Y + tol
			and amin.Z <= bmax.Z + tol and bmin.Z <= amax.Z + tol
	end
	local problems = {}
	-- connected groups (flood fill from Body)
	local body = model.PrimaryPart or parts[1]
	local seen, queue = {[body] = true}, {body}
	while #queue > 0 do
		local p = table.remove(queue)
		for _, q in ipairs(parts) do
			if not seen[q] and touching(p, q) then seen[q] = true; table.insert(queue, q) end
		end
	end
	for _, p in ipairs(parts) do
		if not seen[p] then
			local pos = model:GetPivot():PointToObjectSpace(p.Position)
			table.insert(problems, string.format("%s at (%.2f, %.2f, %.2f) is not connected", p.Name, pos.X, pos.Y, pos.Z))
		end
	end
	for _, f in ipairs(M.FindFlicker(model)) do
		table.insert(problems, string.format("FLICKER: %s and %s share a visible %s face", f.p.Name, f.q.Name, f.axis))
	end
	local round = 0
	for _, p in ipairs(parts) do if p:IsA("Part") and p.Shape ~= Enum.PartType.Block then round += 1 end end
	if round > 0 then table.insert(problems, round .. " round part(s) (Ball/Cylinder): use blocks (M.Blockify)") end
	return problems
end

-- CheckPieces(model): for recipes that mark pieces with asPiece. Returns a list of problems: two
-- DIFFERENT pieces cutting into each other, or a non-root part of a piece cutting into the main
-- structure. Overlaps of less than 0.03 studs (touching) are ignored. The model must be in the workspace.
function M.CheckPieces(model: Model): { string }
	local problems, seen = {}, {}
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Include
	params.FilterDescendantsInstances = {model}
	local probe = Instance.new("Part")
	probe.Anchored, probe.CanCollide, probe.Transparency = true, false, 1
	for _, p in model:GetDescendants() do
		local id = p:IsA("BasePart") and p:GetAttribute("Piece")
		if id then
			probe.Size = p.Size - Vector3.new(0.06, 0.06, 0.06)
			probe.CFrame = p.CFrame
			probe.Parent = workspace
			for _, q in workspace:GetPartsInPart(probe, params) do
				if q ~= p then
					local qid = q:GetAttribute("Piece")
					local bad = (qid and qid ~= id) or (not qid and not p:GetAttribute("Root"))
					local key = if qid then table.concat({id, qid}, "|") else id .. "|" .. q.Name
					if bad and not seen[key] then
						seen[key] = true
						if not (qid and seen[qid .. "|" .. id]) then
							table.insert(problems, ("%s (%s) cuts into %s (%s)"):format(id, p.Name, qid or "structure", q.Name))
						end
					end
				end
			end
		end
	end
	probe:Destroy()
	return problems
end

-- Review rows live on Workspace.ArtReview.ReviewFloor, 3000 studs along X (off the main map).
M.REVIEW_X = 3000

-- Builds a turnaround row per model (4 copies turned 0/90/180/270) for reviewing every side.
function M.Turnaround(names, folder, z0, spacing)
	spacing = spacing or 10
	local results = {}
	for row, name in ipairs(names) do
		local z = z0 - (row - 1) * spacing
		local step = 4
		for i, yaw in ipairs({0, 90, 180, 270}) do
			local old = folder:FindFirstChild(name .. "_" .. yaw); if old then old:Destroy() end
			local m = M.Build(name); m.Name = name .. "_" .. yaw; m.Parent = folder
			if i == 1 then local e = m:GetExtentsSize(); step = math.max(4, math.max(e.X, e.Z) + 1.5) end
			m:PivotTo(CFrame.new(M.REVIEW_X - 6 + (i - 1) * step, 0.05, z) * CFrame.Angles(0, math.rad(yaw), 0))
			if yaw == 0 then
				local p = M.Check(m)
				table.insert(results, name .. ": " .. (#p == 0 and "all connected" or table.concat(p, "; ")))
			end
		end
	end
	return table.concat(results, "\n")
end

M.Recipes = {}

-- Materials per recipe: M.Textures[recipe] = {PartName = Enum.Material, ...}. Build gives every
-- plain (SmoothPlastic) part with that name the material. Parts that already have a material keep it.
M.Textures = {}

-- Models that MOVE (characters, creatures, pets, vehicles...): M.Moving[recipe] = true.
-- Roblox lays material patterns in WORLD space, so fabric/stone/grass/wood patterns slide across a
-- model that walks, bobs or is carried. Build keeps only these materials on moving models.
M.Moving = {}
M.MovingMaterials = {[Enum.Material.SmoothPlastic] = true, [Enum.Material.Neon] = true, [Enum.Material.Glass] = true, [Enum.Material.Metal] = true}

-- Loads a recipe module (a ModuleScript that returns function(M) ... end).
function M.Load(module)
	require(module)(M)
	return M
end

-- Pivot of a built model = the bottom centre of its world-axis box, facing -Z (body = PrimaryPart).
-- (Measured in WORLD axes: GetBoundingBox() measures in the PrimaryPart's axes, so a Body turned on
-- its side gives a wrong "bottom" and placed copies hover.)
function M.SetBottomPivot(model)
	local lo, hi = Vector3.one * math.huge, -Vector3.one * math.huge
	for _, p in ipairs(model:GetDescendants()) do
		if p:IsA("BasePart") then
			local h = p.Size / 2
			for _, sx in ipairs({-1, 1}) do
				for _, sy in ipairs({-1, 1}) do
					for _, sz in ipairs({-1, 1}) do
						local c = p.CFrame * Vector3.new(sx * h.X, sy * h.Y, sz * h.Z)
						lo, hi = lo:Min(c), hi:Max(c)
					end
				end
			end
		end
	end
	local body = model.PrimaryPart
	body.PivotOffset = body.CFrame:ToObjectSpace(CFrame.new((lo.X + hi.X) / 2, lo.Y, (lo.Z + hi.Z) / 2))
end

function M.Build(name)
	local recipe = M.Recipes[name]
	assert(recipe, "No block recipe called " .. tostring(name))
	local model = Instance.new("Model")
	model.Name = name
	recipe(model, M)
	local textures = M.Textures[name]
	if textures then
		for _, p in ipairs(model:GetChildren()) do
			if p:IsA("BasePart") and p.Material == SMOOTH and textures[p.Name] then
				p.Material = textures[p.Name]
			end
		end
	end
	if M.Moving[name] then
		for _, p in ipairs(model:GetDescendants()) do
			if p:IsA("BasePart") and not M.MovingMaterials[p.Material] then
				p.Material = SMOOTH
			end
		end
	end
	M.FixFlicker(model)
	-- Body = the part called "Body", else the biggest part
	local body, best = nil, -1
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") and p.Name == "Body" then body = p break end
		if p:IsA("BasePart") then
			local v = p.Size.X * p.Size.Y * p.Size.Z
			if v > best then best, body = v, p end
		end
	end
	body.Name = "Body"
	model.PrimaryPart = body
	for _, p in ipairs(model:GetChildren()) do
		local hinge = p:GetAttribute("FlapHinge")
		if typeof(hinge) == "Vector3" then p:SetAttribute("FlapHinge", body.CFrame:PointToObjectSpace(hinge)) end
		local animHinge = p:GetAttribute("AnimHinge")
		if typeof(animHinge) == "Vector3" then p:SetAttribute("AnimHinge", body.CFrame:PointToObjectSpace(animHinge)) end
		local animAxis = p:GetAttribute("AnimAxis")
		if typeof(animAxis) == "Vector3" then p:SetAttribute("AnimAxis", body.CFrame:VectorToObjectSpace(animAxis)) end
	end
	for _, p in ipairs(model:GetChildren()) do
		if p:IsA("BasePart") and p ~= body then
			local w = Instance.new("WeldConstraint"); w.Part0 = body; w.Part1 = p; w.Parent = p
		end
	end
	M.SetBottomPivot(model)
	model:SetAttribute("BlockBuilt", true)
	return model
end

return M
