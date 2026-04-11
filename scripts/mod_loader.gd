## This script handle any modding functionalty.
extends Node

## Is the path to the game's mod folder, if it doesn't exist, well it will add it.
const mod_path = "./mods"
##@deprecated
## Was used to get a path to any music, unneeded as it will be stored in the xml file istead now.
const music_path = "/audio"
##@experimental
## This is what every mod must have to oprate.
const md_xml_filename = "dat.xml"

# XML Parts:
## Contains all the info of how the xml's nodes should be formated
const md_xml_format = {
	"mod":{
		"name":{},
		"author":{},
		"md":{
			# Will work regardless of effect_type.[br][br]
			# In multiplayer, this only efects the client.
			"min":{
				"mus":["main","gameplay"]
				},
			
			# Will work if effect_type is 1 or higher.[br][br]
			# In multiplayer, effects the gameplay slightly.
			"mid":{
				
				},
			
			# Will work if effect_type is 2.[br][br]
			# Multiplayer disabled.
			"max":{
				
				}
		}
	}
}

#Xml should just have a list of xml files instead of files.
var mod_paths_list = []
var mod_folder : DirAccess

#func _ready():
	#get_mods_paths()

#Xml modding update plan:
	#Xml Files in mod files must be called dat.xml
	#Xml The root must be <mod version="{Insert Current Version}" active="{0 mean disabled, 1 means active}" priority="{The higher number, the higher priorty}">
	#Xml Should have (<name> The mod name.), (<author> The author),
	#Xml and (<md effect_type="{The level of changes it makes, 0 means it changes only visual and audio, 1 means it also ajusts gameplay, and 2 means it can add stuff and means no mp}"> )

func get_mods_paths(path=mod_path):
	var file_name
	mod_paths_list = []
	if mod_folder:
		mod_folder.change_dir(path)
	else:
		mod_folder = DirAccess.open(path)
	
	if mod_folder:
		# Replaced the old system, that which no longer save a md files, but its xml.
		var colection = (mod_folder.get_directories() + mod_folder.get_files())
		for i in colection:
			file_name = i
			if file_name in mod_folder.get_directories():
				print("Found directory: " + file_name)
				get_mods_paths(mod_folder.get_current_dir()+"/"+file_name)
				mod_folder.change_dir(path)
			else:
				if file_name == md_xml_filename:
					print("Found file: " + mod_folder.get_current_dir()+"/"+file_name)
					mod_paths_list.append(mod_folder.get_current_dir()+"/"+file_name)
				else:
					print("Found file (Wasn't dat.xml): " + file_name)
		
		#mod_folder.list_dir_begin()
		#file_name = mod_folder.get_next()
		#while file_name != "":
			#if mod_folder.current_is_dir():
				#print("Found directory: " + file_name)
				#get_mods_paths(mod_folder.get_current_dir()+"/"+file_name)
				#mod_folder.change_dir(path)
			#else:
				#print("Found file: " + file_name)
				#mod_paths_list.append(mod_folder.get_current_dir()+"/"+file_name)
				#
			#file_name = mod_folder.get_next()
			#print(file_name)
	
	else:
		print("An error occurred when trying to access the path.")
		DirAccess.make_dir_absolute(mod_path)
	
	get_mod_effect()

##@deprecated
## If a path contains any of these extra points, the file is ignored.[br][br]
## Why this is deprcated, because the xml file handle this now.
const disable_list = [".disabled",".break",".remove",".no",".none"]

#Xml I want to parce though the mod info first
#Xml then instead of asking for what want is, have a list of each name of node, like 
#Xml get_mod_efect("mus","main") and returns the song path.
#Xml or get_mod_efect("map","entrys") where it returns a colection of maps to add to the list of pickable maps.

func get_mod_effect(...req):
	var mod_xmls = {}
	for i in mod_paths_list:
		mod_xmls.merge(xml_parse_method(i))
	
	for i in mod_xmls.keys():
		if mod_xmls[i]["attributes"]["active"] != "0":
			print(mod_xmls[i])
	
	return

func xml_parse_method(path):
	var parser = XMLParser.new()
	var xml_dict = {}
	var temp_dicts = {}
	var entry_path = []
	parser.open(path)
	var md_name = ""
	var node_name = ""
	var attributes_dict = {}
	var node_data = ""
	while parser.read() != ERR_FILE_EOF:
		
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			node_name = parser.get_node_name()
			attributes_dict = {}
			for idx in range(parser.get_attribute_count()):
				attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
			if parser.get_attribute_count() == 0:
				attributes_dict.clear()
			print("The ", node_name, " element has the following attributes: ", attributes_dict)
			
			if entry_path.size() > 0:
				if not temp_dicts[entry_path.back()].keys().has(node_name):
					temp_dicts[entry_path.back()][node_name] = {}
			
			entry_path.append(node_name)
			#contained_text = true
		
		elif parser.get_node_type() == XMLParser.NODE_TEXT:
			node_data = parser.get_node_data()
			print("and contains this data: ",node_data)
			temp_dicts[node_name]["data"] = node_data
			if node_name == "name":
				md_name = node_data
		
		elif parser.get_node_type() == XMLParser.NODE_ELEMENT_END:
			node_name = parser.get_node_name()
			entry_path.erase(node_name)
			if entry_path.size() > 0:
				temp_dicts[entry_path.back()][node_name] = temp_dicts[node_name]
		
		if entry_path.size() > 0:
			if not temp_dicts.keys().has(entry_path.back()):
				temp_dicts[entry_path.back()] = {}
			
			if entry_path.back() == node_name:
				temp_dicts[entry_path.back()]["attributes"] = attributes_dict
			
			elif not temp_dicts[entry_path.back()].keys().has(node_name):
				temp_dicts[entry_path.back()][node_name] = {}
	
	xml_dict[md_name] = temp_dicts[temp_dicts.keys()[0]]
	
	return xml_dict


##@deprecated
## I plan to do this with xml in mind.
func get_mods_list(wants:int):
	for path in mod_paths_list:
		var result = false
		for i in disable_list:
			if path.contains(i):
				result = true
		
		if not result:
			if path.contains("/audio") and wants in [0,1]:
				if path.contains("main.ogg") and wants == 0:
					return path
	return ""
