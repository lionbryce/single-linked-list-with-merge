local function newSLL(last_inserted_id,value)
	return {lowest_inserted_id = last_inserted_id, last_inserted_id = last_inserted_id, [last_inserted_id] = {false,value}}
end

local function insert(data,id,value)
	data[id] = {data.last_inserted_id,value}
	data.last_inserted_id = id
end

local function populateRandom(data,len,r)
	r = r or 1
	for i=1,len do
		insert(data,data.last_inserted_id+math.random(1,r),math.random(1,100))
	end
end

local function toarray(data,d)
	local arr = {}
	local arr_i = 1

	local limit = table.Count(data) - 1 -- -2 because of lowest_inserted_id and last_inserted_id

	local id = data.last_inserted_id
	while id and arr_i <= limit do
		if d then
			print(id,arr_i)
		end

		local v = data[id]
		arr[arr_i] = {id,v[2]}
		id = v[1]

		arr_i = arr_i + 1
	end

	if arr_i > limit then
		print("arr_i > limit")
		debug.Trace()
	end

	return arr
end

local function merge(a,b)
	-- need to find where the two lists merge and then return 1 list

	local new

	if a.lowest_inserted_id < b.lowest_inserted_id then
		new = newSLL(a.lowest_inserted_id,a[a.lowest_inserted_id][1])
	else
		new = newSLL(b.lowest_inserted_id,b[b.lowest_inserted_id][1])
	end

	local arr_a = toarray(a) -- this is the slow part
	local arr_b = toarray(b)

	local arr_a_i = #arr_a
	local arr_b_i = #arr_b

	local looplim = arr_a_i + arr_b_i + 1

	while arr_a_i > 0 and arr_b_i > 0 and looplim > 0 do
		looplim = looplim - 1

		local arr_a_arr_a_i = arr_a[arr_a_i]
		local arr_b_arr_b_i = arr_b[arr_b_i]
		
		local id_a = arr_a_arr_a_i[1]
		local id_b = arr_b_arr_b_i[1]
		
		if id_a < id_b then
			arr_a_i = arr_a_i - 1

			if new[id_a] then
				continue
			end

			insert(new,id_a,arr_a_arr_a_i[2])
		elseif id_a > id_b then
			arr_b_i = arr_b_i - 1

			if new[id_b] then
				continue
			end

			insert(new,id_b,arr_b_arr_b_i[2])
		else -- id_a == id_b
			arr_a_i = arr_a_i - 1
			arr_b_i = arr_b_i - 1

			if new[id_a] then -- this shouldn't happen in this case
				continue
			end

			insert(new,id_a,arr_a_arr_a_i[2])
		end
	end

	while arr_a_i > 0 and looplim > 0 do
		looplim = looplim - 1
		local arr_a_arr_a_i = arr_a[arr_a_i]
		arr_a_i = arr_a_i - 1
		insert(new,arr_a_arr_a_i[1],arr_a_arr_a_i[2])
	end

	while arr_b_i > 0 and looplim > 0 do
		looplim = looplim - 1
		local arr_b_arr_b_i = arr_b[arr_b_i]
		arr_b_i = arr_b_i - 1
		insert(new,arr_b_arr_b_i[1],arr_b_arr_b_i[2])
	end
	
	return looplim > 1 and new
end


-- some test cases
local s1 = newSLL(0,1)
local s2 = newSLL(0,1)

populateRandom(s1,1000,5)
populateRandom(s2,1000,5)

local s3 = merge(s1,s2)

local arr_s3 = toarray(s3)

print(#toarray(s1))
print(#toarray(s2))
-- print(#toarray(s3))
-- print(#toarray(s4))

local failed = false

for k,v in ipairs(arr_s3) do
	if !s3[v[1]] then
		print("missing",v[1],v[2])
		failed = true
	end
end

print(failed)