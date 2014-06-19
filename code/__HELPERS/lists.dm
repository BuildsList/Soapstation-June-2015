/*
 * Holds procs to help with list operations
 * Contains groups:
 *			Misc
 *			Sorting
 */

/*
 * Misc
 */

//Returns a list in plain english as a string
/proc/english_list(var/list/input, nothing_text = "nothing", and_text = " and ", comma_text = ", ", final_comma_text = "" )
	var/total = input.len
	if (!total)
		return "[nothing_text]"
	else if (total == 1)
		return "[input[1]]"
	else if (total == 2)
		return "[input[1]][and_text][input[2]]"
	else
		var/output = ""
		var/index = 1
		while (index < total)
			if (index == total - 1)
				comma_text = final_comma_text

			output += "[input[index]][comma_text]"
			index++

		return "[output][and_text][input[index]]"

//Returns list element or null. Should prevent "index out of bounds" error.
proc/listgetindex(var/list/list,index)
	if(istype(list) && list.len)
		if(isnum(index))
			if(InRange(index,1,list.len))
				return list[index]
		else if(index in list)
			return list[index]
	return

proc/islist(list/list)
	if(istype(list))
		return 1
	return 0

//Return either pick(list) or null if list is not of type /list or is empty
proc/safepick(list/list)
	if(!islist(list) || !list.len)
		return
	return pick(list)

//Checks if the list is empty
proc/isemptylist(list/list)
	if(!list.len)
		return 1
	return 0

//Checks for specific types in a list
/proc/is_type_in_list(var/atom/A, var/list/L)
	for(var/type in L)
		if(istype(A, type))
			return 1
	return 0

//Empties the list by setting the length to 0. Hopefully the elements get garbage collected
proc/clearlist(list/list)
	if(istype(list))
		list.len = 0
	return

//Removes any null entries from the list
proc/listclearnulls(list/list)
	if(istype(list))
		while(null in list)
			list -= null
	return

/*
 * Returns list containing all the entries from first list that are not present in second.
 * If skiprep = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/difflist(var/list/first, var/list/second, var/skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		for(var/e in first)
			if(!(e in result) && !(e in second))
				result += e
	else
		result = first - second
	return result

/*
 * Returns list containing entries that are in either list but not both.
 * If skipref = 1, repeated elements are treated as one.
 * If either of arguments is not a list, returns null
 */
/proc/uniquemergelist(var/list/first, var/list/second, var/skiprep=0)
	if(!islist(first) || !islist(second))
		return
	var/list/result = new
	if(skiprep)
		result = difflist(first, second, skiprep)+difflist(second, first, skiprep)
	else
		result = first ^ second
	return result

//Pretends to pick an element based on its weight but really just seems to pick a random element.
/proc/pickweight(list/L)
	var/total = 0
	var/item
	for (item in L)
		if (!L[item])
			L[item] = 1
		total += L[item]

	total = rand(1, total)
	for (item in L)
		total -=L [item]
		if (total <= 0)
			return item

	return null

//Pick a random element from the list and remove it from the list.
/proc/pick_n_take(list/listfrom)
	if (listfrom.len > 0)
		var/picked = pick(listfrom)
		listfrom -= picked
		return picked
	return null

//Returns the top(last) element from the list and removes it from the list (typical stack function)
/proc/pop(list/listfrom)
	if (listfrom.len > 0)
		var/picked = listfrom[listfrom.len]
		listfrom.len--
		return picked
	return null

//Returns the next element in parameter list after first appearance of parameter element. If it is the last element of the list or not present in list, returns first element.
/proc/next_in_list(element, list/L)
	for(var/i=1, i<L.len, i++)
		if(L[i] == element)
			return L[i+1]
	return L[1]

/*
 * Sorting
 */

//Reverses the order of items in the list
/proc/reverselist(list/L)
	var/list/output = list()
	if(L)
		for(var/i = L.len; i >= 1; i--)
			output += L[i]
	return output

//Randomize: Return the list in a random order
/proc/shuffle(var/list/shufflelist)
	if(!shufflelist)
		return
	var/list/new_list = list()
	var/list/old_list = shufflelist.Copy()
	while(old_list.len)
		var/item = pick(old_list)
		new_list += item
		old_list -= item
	return new_list

//Return a list with no duplicate entries
/proc/uniquelist(var/list/L)
	var/list/K = list()
	for(var/item in L)
		if(!(item in K))
			K += item
	return K

//Mergesort: divides up the list into halves to begin the sort
/proc/sortKey(var/list/client/L, var/order = 1)
	if(isnull(L) || L.len < 2)
		return L
	var/middle = L.len / 2 + 1
	return mergeKey(sortKey(L.Copy(0,middle)), sortKey(L.Copy(middle)), order)

//Mergsort: does the actual sorting and returns the results back to sortAtom
/proc/mergeKey(var/list/client/L, var/list/client/R, var/order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		var/client/rL = L[Li]
		var/client/rR = R[Ri]
		if(sorttext(rL.ckey, rR.ckey) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

//Mergesort: divides up the list into halves to begin the sort
/proc/sortAtom(var/list/atom/L, var/order = 1)
	if(isnull(L) || L.len < 2)
		return L
	var/middle = L.len / 2 + 1
	return mergeAtoms(sortAtom(L.Copy(0,middle)), sortAtom(L.Copy(middle)), order)

//Mergsort: does the actual sorting and returns the results back to sortAtom
/proc/mergeAtoms(var/list/atom/L, var/list/atom/R, var/order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		var/atom/rL = L[Li]
		var/atom/rR = R[Ri]
		if(sorttext(rL.name, rR.name) == order)
			result += L[Li++]
		else
			result += R[Ri++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))




//Mergesort: Specifically for record datums in a list.
/proc/sortRecord(var/list/datum/data/record/L, var/field = "name", var/order = 1)
	if(isnull(L))
		return list()
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1
	return mergeRecordLists(sortRecord(L.Copy(0, middle), field, order), sortRecord(L.Copy(middle), field, order), field, order)

//Mergsort: does the actual sorting and returns the results back to sortRecord
/proc/mergeRecordLists(var/list/datum/data/record/L, var/list/datum/data/record/R, var/field = "name", var/order = 1)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	if(!isnull(L) && !isnull(R))
		while(Li <= L.len && Ri <= R.len)
			var/datum/data/record/rL = L[Li]
			if(isnull(rL))
				L -= rL
				continue
			var/datum/data/record/rR = R[Ri]
			if(isnull(rR))
				R -= rR
				continue
			if(sorttext(rL.fields[field], rR.fields[field]) == order)
				result += L[Li++]
			else
				result += R[Ri++]

		if(Li <= L.len)
			return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))




//Mergesort: any value in a list
/proc/sortList(var/list/L)
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1 // Copy is first,second-1
	return mergeLists(sortList(L.Copy(0,middle)), sortList(L.Copy(middle))) //second parameter null = to end of list

//Mergsorge: uses sortList() but uses the var's name specifically. This should probably be using mergeAtom() instead
/proc/sortNames(var/list/L)
	var/list/Q = new()
	for(var/atom/x in L)
		Q[x.name] = x
	return sortList(Q)

/proc/mergeLists(var/list/L, var/list/R)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R[Ri++]
		else
			result += L[Li++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))


// List of lists, sorts by element[key] - for things like crew monitoring computer sorting records by name.
/proc/sortByKey(var/list/L, var/key)
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1
	return mergeKeyedLists(sortByKey(L.Copy(0, middle), key), sortByKey(L.Copy(middle), key), key)

/proc/mergeKeyedLists(var/list/L, var/list/R, var/key)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		if(sorttext(L[Li][key], R[Ri][key]) < 1)
			// Works around list += list2 merging lists; it's not pretty but it works
			result += "temp item"
			result[result.len] = R[Ri++]
		else
			result += "temp item"
			result[result.len] = L[Li++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))


//Mergesort: any value in a list, preserves key=value structure
/proc/sortAssoc(var/list/L)
	if(L.len < 2)
		return L
	var/middle = L.len / 2 + 1 // Copy is first,second-1
	return mergeAssoc(sortAssoc(L.Copy(0,middle)), sortAssoc(L.Copy(middle))) //second parameter null = to end of list

/proc/mergeAssoc(var/list/L, var/list/R)
	var/Li=1
	var/Ri=1
	var/list/result = new()
	while(Li <= L.len && Ri <= R.len)
		if(sorttext(L[Li], R[Ri]) < 1)
			result += R&R[Ri++]
		else
			result += L&L[Li++]

	if(Li <= L.len)
		return (result + L.Copy(Li, 0))
	return (result + R.Copy(Ri, 0))

//Converts a bitfield to a list of numbers (or words if a wordlist is provided)
/proc/bitfield2list(bitfield = 0, list/wordlist)
	var/list/r = list()
	if(istype(wordlist,/list))
		var/max = min(wordlist.len,16)
		var/bit = 1
		for(var/i=1, i<=max, i++)
			if(bitfield & bit)
				r += wordlist[i]
			bit = bit << 1
	else
		for(var/bit=1, bit<=65535, bit = bit << 1)
			if(bitfield & bit)
				r += bit

	return r

// Returns the key based on the index
/proc/get_key_by_index(var/list/L, var/index)
	var/i = 1
	for(var/key in L)
		if(index == i)
			return key
		i++
	return null

/proc/count_by_type(var/list/L, type)
	var/i = 0
	for(var/T in L)
		if(istype(T, type))
			i++
	return i

//Don't use this on lists larger than half a dozen or so
/proc/insertion_sort_numeric_list_ascending(var/list/L)
	//world.log << "ascending len input: [L.len]"
	var/list/out = list(pop(L))
	for(var/entry in L)
		if(isnum(entry))
			var/success = 0
			for(var/i=1, i<=out.len, i++)
				if(entry <= out[i])
					success = 1
					out.Insert(i, entry)
					break
			if(!success)
				out.Add(entry)

	//world.log << "	output: [out.len]"
	return out

/proc/insertion_sort_numeric_list_descending(var/list/L)
	//world.log << "descending len input: [L.len]"
	var/list/out = insertion_sort_numeric_list_ascending(L)
	//world.log << "	output: [out.len]"
	return reverselist(out)
