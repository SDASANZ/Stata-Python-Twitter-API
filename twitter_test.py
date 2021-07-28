from sys import argv
import json
import csv
import sfi


data = []
sub_user = []
index = -1
obs = 0
data_keys = []
user_keys = []
filename = argv[1]

with open(filename, 'r', encoding='utf-8') as y:
	for line in y:
		obs = obs + 1

sfi.Data.addObs(obs)

with open(filename, 'r', encoding='utf-8') as f:
	for line in f:
		index = index + 1
		print(index)
		keys = []
		items = []
		appending = json.loads(line.rstrip('\n|\r'))
		for key in appending.keys():
			if str(key) not in data_keys:
				sfi.Data.addVarStrL(str(key))
			data_keys.append(str(key))
			keys.append(str(key))
		for key in keys:
			item = appending.get(key)
			items.append(str(item))
		sfi.Data.store(keys,index,items)
		
		keys = []
		items = []
		orig_keys = []
		user = appending["user"]
		for key in user.keys():
			newkey = "user_" + key
			if len(newkey) > 25:
				s = newkey.split("_")
				newkey = ""
				for x in s:
					newkey = newkey + x[:4] + "_"
				newkey = newkey[:-1]
			if key not in user_keys:
				sfi.Data.addVarStrL(newkey)
				user_keys.append(key)
			keys.append(newkey)
			orig_keys.append(key)
		for key in orig_keys:
			item = user.get(key)
			items.append(str(item))
		sfi.Data.store(keys,index,items)