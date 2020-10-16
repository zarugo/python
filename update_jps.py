import jps
import sys
import os
import time
import tarfile
import json
import ipaddress
import paramiko
from jsonmerge import merge, Merger

#Clean garbage from old updates
jps.pre_clean()

#Ask the user for the import ip
while True:
    try:
        ip = str(ipaddress.ip_address(input("Type the IP of the device: ")))
        break
    except ValueError:
        print("The IP is invalid, please check that it's correct")

#Get all the info we need on the device (hardware type and configuration)
print("Getting the device informations about hardware and JPSApplication...")
device = jps.JpsDevice(ip)
if os.path.exists("JPSApps_" + device.info["hw"]):
    pass
else:
    sys.exit("The installation package JPSApps_" + device.info["hw"] + " does not exist in this folder, the update has failed!")
print("The hardware is " + device.info["hw"] + " and the application is " + device.info["type"] + ".")
time.sleep(2)


print("Saving current config file...")
jps.get_config(device.info["hw"], ip, device.info["login"], device.info["appfld"], device.info["webfld"], device.info["script"], device.info["workdir"])

#######################################
#MERGE JSON FILE
#######################################
print("Merging the configuration files...")
schema = {
	"properties": {
		"application": {
			"type": "object",
            "mergeStrategy":"objectMerge"
			"properties":{
				"spectype" : {"mergeStrategy":"overwrite"},
				"sitecode" : {"mergeStrategy":"overwrite"},
				"periphid" : {"mergeStrategy":"overwrite"},
				"runmode"  : {"mergeStrategy":"overwrite"},
				"dbgsegflt": {"mergeStrategy":"overwrite"},
				"logmaxage": {"mergeStrategy":"overwrite"},
				"loglevel" : {"mergeStrategy":"overwrite"},
				"dbglevel" : {"mergeStrategy":"overwrite"},
				"tmpscrntm": {"mergeStrategy":"overwrite"},
				"fraudalrmtm":{"mergeStrategy":"overwrite"},
				"backtoidletm":{"mergeStrategy":"overwrite"},
				"currency" : {"mergeStrategy":"overwrite"},
				"amoprecis" : {"mergeStrategy":"overwrite"},
				"locvalen": {"mergeStrategy":"overwrite"},
				"refunden": {"mergeStrategy":"overwrite"},
				"iponopen": {"mergeStrategy":"overwrite"},
				"opcdloginmd": {"mergeStrategy":"overwrite"},
				"taxpctge" : {"mergeStrategy":"overwrite"},
				"prntrcptmode": {"mergeStrategy":"overwrite"},
				"freetime"  : {"mergeStrategy":"overwrite"},
				"exittime"  : {"mergeStrategy":"overwrite"},
				"costtime"  : {"mergeStrategy":"overwrite"},
				"lostmode"  : {"mergeStrategy":"overwrite"},
				"loststrttm": {"mergeStrategy":"overwrite"},
				"lostcosttm": {"mergeStrategy":"overwrite"},
				"prntsnapmode": {"mergeStrategy":"overwrite"},
				"showextm" : {"mergeStrategy":"overwrite"},
				"showposmsg" : {"mergeStrategy":"overwrite"},
				"showmaxcng": {"mergeStrategy":"overwrite"},
				"discntmode" : {"mergeStrategy":"overwrite"},
				"paytktgrace" : {"mergeStrategy":"overwrite"},
				"confirmtktgrace" : {"mergeStrategy":"overwrite"},
				"acceptpaidtkt" : {"mergeStrategy":"overwrite"},
				"zerorcp" : {"mergeStrategy":"overwrite"},
				"fiscalPolicy" : {"mergeStrategy":"overwrite"}
				"tcktlssmedialst": {
                    "type": "array",
                    "mergeStrategy":"arrayMergeByIndex",
					"items": {
                        "mergeStrategy":"overwrite",
						"type": "object"
                    }
				},
				"ticketdesc": {
					"mergeStrategy":"arrayMergeByIndex",
					"type": "array",
					"items": {
						"type": "object",
                        "mergeStrategy":"overwrite"
					}

				},
				"receiptdesc": {
                    "mergeStrategy":"arrayMergeByIndex",
					"type": "array",
					"items": {
						"type": "object",
                        "mergeStrategy":"overwrite"
						}
					}
				},
				"vendingmngmt": {
                    "mergeStrategy":"objectMerge",
					"type": "object",
					"properties": {
						"mode": 	 {"mergeStrategy":"overwrite"},
						"maxparktm": {"mergeStrategy":"overwrite"}
					}
				},
				"pymtopts":{"mergeStrategy":"overwrite"},
				"persistentdata": {
                    "mergeStrategy":"objectMerge",
					"type": "object",
					"properties": {
						"dbfilename":	{"mergeStrategy":"overwrite"},
						"dbfilesizekb": {"mergeStrategy":"overwrite"},
						"dbtables": {
							"mergeStrategy":"arrayMergeByIndex",
							"type": "array",
							"items": {
								"type": "object",
								"properties": {
									"_idx_":     {"mergeStrategy":"overwrite"},
									"tablename": {"mergeStrategy":"overwrite"},
									"tableid":   {"mergeStrategy":"overwrite"},
									"recsz": 	 {"mergeStrategy":"overwrite"},
									"recsno": 	 {"mergeStrategy":"overwrite"}
								}
							}
						}
					}
				},
				"devices": {
                    "mergeStrategy":"objectMerge",
					"type": "object",
					"properties": {
						"gpioctrl": {"mergeStrategy":"overwrite"},
						"display": {
                            "mergeStrategy":"objectMerge",
							"type": "object",
							"properties": {
								"spectype":     {"mergeStrategy":"overwrite"},
								"periphmode":   {"mergeStrategy":"overwrite"},
								"dateformat":   {"mergeStrategy":"overwrite"},
								"multilanguage":{"mergeStrategy":"overwrite"},
								"offlinescrst": {"mergeStrategy":"overwrite"},
								"langsfile":  	{"mergeStrategy":"overwrite"},
								"langslist": {
									"mergeStrategy":"objectMerge",
									"type": "array",
									"items": {
                                        "mergeStrategy":"objectMerge",
										"type": "object",
										"properties": {
											"_idx_":  {"mergeStrategy":"overwrite"},
											"lang":   {"mergeStrategy":"overwrite"}
										}
									}
								},
								"runmodests": {
                                    "mergeStrategy":"objectMerge",
									"type": "array",
									"items": {
                                        "mergeStrategy":"objectMerge",
										"type": "object",
										"properties": {
											"_idx_":  {"mergeStrategy":"overwrite"},
											"runmode":{"mergeStrategy":"overwrite"},
											"status":{"mergeStrategy":"overwrite"}
										}
									}
								},
								"xtracfgparams": {
									"mergeStrategy":"objectMerge",
									"type": "array",
									"items": {
                                        "mergeStrategy":"objectMerge",
										"type": "object",
										"properties": {
											"_idx_":  {"mergeStrategy":"overwrite"},
											"key":    {"mergeStrategy":"overwrite"},
											"value":  {"mergeStrategy":"overwrite"}
										}
									}
								},
								"communication": {"mergeStrategy":"overwrite"},
								"gpioctrl": {"mergeStrategy":"overwrite"},
								"ctrlpins": {
                                    "mergeStrategy":"objectMerge",
									"type": "array",
									"items": {
                                        "mergeStrategy":"objectMerge",
										"type": "object",
										"properties": {
											"_idx_":        {"mergeStrategy":"overwrite"},
											"funct":		{"mergeStrategy":"overwrite"},
											"id":			{"mergeStrategy":"overwrite"},
											"activest":		{"mergeStrategy":"overwrite"},
											"lowperiodms":	{"mergeStrategy":"overwrite"},
											"highperiodms":	{"mergeStrategy":"overwrite"},
											"pulseno":		{"mergeStrategy":"overwrite"},
											"vloggtnet":	{"mergeStrategy":"overwrite"}
										}
									}
                                }
							}
						},
						"statpins": {
							"title": "Status I/O",
							"type": "array",
							"description":"Here you can map application related logic status functions to physical gpios",
							"options": {"collapsed": true}, "format": "table",
							"items": {
								"type": "object",
								"properties": {
									"_idx_":    { "type":"integer", "readonly": true},
									"funct":	{"title":"Function",		 "type":"string",  "enum":["DoorOpened","DoorUnlocked"], "readonly": false},
									"id":		{"title":"Pin ID",			 "type":"integer", "minimum":0,"maximum":255},
									"activest": {"title":"ActiveState",		 "type":"integer", "minimum":0,"maximum":1},
									"risedlyms":{"title":"Rise filter (ms)", "type":"integer", "minimum":0,"maximum":5000},
									"falldlyms":{"title":"Fall filter (ms)", "type":"integer", "minimum":0,"maximum":5000}
								}
							},
							"minItems": 0,
							"maxItems": 20
						},
						"ctrlpins": {
							"title": "Ctrl I/O",
							"type": "array",
							"description":"Here you can map application related logic control functions to physical gpios",
							"options": {"collapsed": true}, "format": "table",
							"items": {
								"type": "object",
								"properties": {
									"_idx_":    { "type":"integer", "readonly": true},
									"funct":		{"title":"Function",				  "type":"string",  "enum":["DoorUnlock","EnabUPMedia","DisabUPMedia","UPass1GuidanceOn","UPass1GuidanceOff","UPass2GuidanceOn","UPass2GuidanceOff","PosGuidanceOn","PosGuidanceOff","CashGuidanceOn","CashGuidanceOff","CngBoxLampOn","CngBoxLampOff","VldtSuccOn","VldtSuccOff","VldtFailOn","VldtFailOff","AlrmBellOn","AlrmBellOff"], "readonly": false},
									"id":			{"title":"Pin ID",					  "type":"integer","minimum":0,"maximum":255},
									"activest":		{"title":"StartMode",				  "type":"integer","minimum":0,"maximum":1},
									"lowperiodms":	{"title":"Low Period Duration (ms)",  "type":"integer","minimum":0,"maximum":1000000},
									"highperiodms":	{"title":"High Period Duration (ms)", "type":"integer","minimum":0,"maximum":1000000},
									"pulseno":		{"title":"Number of pulses",		  "type":"integer","minimum":0,"maximum":1000000},
									"vloggtnet":	{"title":"Virtual Logic Gates Net",	  "type":"string"}
								}
							},
							"minItems": 0,
							"maxItems": 20
						},
						"floorcnt": {
							"title": "Floor Counter Sensors",
							"type": "object",
							"description":"Here you can configure the floor counter gpios",
							"format": "grid",
							"properties": {
								"cntrinputs": {
									"title": "Counter Input Sensors",
									"type": "array",
									"options": {"collapsed": true}, "format": "table",
									"items": {
										"title": "Input ID",
										"type": "integer",
										"minimum": 16,
										"maximum": 28
									},
									"minItems": 0,
									"maxItems": 12
								},
								"cntroutputs": {
									"title": "Counter Output Sensors",
									"type": "array",
									"options": {"collapsed": true}, "format": "table",
									"items": {
										"title": "Output ID",
										"type": "integer",
										"minimum": 0,
										"maximum": 15
									},
									"minItems": 0,
									"maxItems": 12
								}
							}
						}
					}
				},
				"services": {
					"title": "Services",
					"type": "object",
					"description":"Configurable services",
					"properties": {
						"localdbservice": {
							"title": "Local DB Service",
							"type": "object",
							"format":"grid",
							"description":"Here you can configure the LocalDB service",
							"properties": {
								"spectype":	{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
								"dburls":{
									"title": "Data Base URLs",
									"type": "array",
									"options": {"collapsed": true}, "format": "table",
									"items": {
										"type": "object",
										"properties": {
											"_idx_":    { "type":"integer", "readonly": true},
											"dbdriver" :	{"title":"Database Driver","type":"string"},
											"dbname":		{"title":"Database Name","type":"string"},
											"dburl":		{"title":"Database URL","type":"string"}
										}
									}
								},
								"rawudpservice": {"title": "Shared LocalDB over RawUdp Configuration", "$ref": "#/definitions/rawudpservice"}
							}
						},
						"jpsadminservice": {
							"title": "JPSAdmin Service",
							"type": "object",
							"format":"grid",
							"description":"Here you can configure the JPSAdmin service",
							"properties": {
								"spectype":	{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
								"loginon" :	{"title":"Login Enabled","type":"boolean", "options": { "infoText": "Enables/Disables JPSAdmin login page"}},
								"httpserver":   {"title": "HttpServer Configurations", "$ref": "#/definitions/httpserver"}
							}
						},
						"jblservice": {
							"title": "JBL Service",
							"type": "object",
							"description":"Here you can configure the JBL service",
							"format":"grid",
							"properties": {
								"spectype":		{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "readonly": false , "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present", "grid_columns": 3}},
								"localip":		{"title":"Node Local IP","type":"string", "options": { "infoText": "The main network interface IP", "grid_columns": 3}},
								"cloudmodestupdms": 	{"title":"Cloud Update (ms)","type":"integer","minimum":0,"maximum":600000, "options": { "infoText": "Options:\n'0ms': 'Cloud Mode is not enabled'\n'>0ms': 'Cloud Mode is enabled and the cloud server polled each x ms'", "grid_columns": 3}},
								"forceauth":		{"title":"Force Authentication Request","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0': 'No authentication request is triggered if a valid token is present'\n'1': 'The authentication request is triggered even if a valid token is present'", "grid_columns": 3}},
								"persistentdata": {
									"title": "Persistent Data Configurations",
									"type": "object",
									"options": {"hidden": true},
									"properties": {
										"dbfilename":	{"title":"DB FileName",			  "type":"string"},
										"dbfilesizekb": {"title":"DB File Size (KB)", "type":"integer","minimum":1,"maximum":1024},
										"dbtables": {
											"title": "DB Tables",
											"type": "array",
											"options": {"collapsed": true}, "format": "table",
											"items": {
												"type": "object",
												"properties": {
													"_idx_":    { "type":"integer", "readonly": true},
													"tablename": { "title": "Table Name", 		   "type": "string" , "readonly": false},
													"tableid":   { "title": "Table Id",   		   "type": "integer", "readonly": false },
													"recsz": 	 { "title": "Table Record Size",   "type": "integer", "readonly": false },
													"recsno": 	 { "title": "Table Record Number", "type": "integer", "readonly": false},
													"queuesize": { "title": "Msg Queue Size",  "type": "integer" }
												}
											},
											"minItems": 0,
											"maxItems": 50
										}
									}
								},
								"httpserver": 	{"title": "HttpServer Configurations", "$ref": "#/definitions/httpserver"},
								"httpclient": 	{"title": "HttpClient Configurations", "$ref": "#/definitions/httpclient"}
							}
						},
						"paymentservice": {
							"title": "Payment Service",
							"type": "object",
							"format":"grid",
							"description":"Here you can configure the Payment service",
							"properties": {
								"spectype": {"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
								"pymtmode": {"title":"Payment Mode","type":"integer","minimum":0, "maximum":6, "options": { "infoText": "Options:\n'0' = Cash,\n'1' = Pos,\n'2' = Cash&Pos,\n'3' = Provs,\n'4' = Cash&Provs,\n'5' = Pos&Provs,\n'6' = Cash&Pos&Provs"}},
								"cngalgo":  {"title":"Change Algorithm","type":"integer","minimum":0, "maximum":2, "options": { "infoText": "Options:\n'0' = Minimize Pieces,\n'1' = Balanced Pieces"}},
								"maxchange": {"title":"Max Change Amount","type":"integer","minimum":0, "maximum":1000000, "options": { "infoText": "Change amount upper limit"}},
								"maxpieces": {"title":"Max Number of Pieces","type":"integer","minimum":0, "maximum":1000, "options": { "infoText": "Change pieces upper limit"}},
								"maxcngrtry": {"title":"Max Change Retry","type":"integer","minimum":0, "maximum":2, "options": { "infoText": "Change attempts max number"}},
								"cngonabrt": {"title":"Give Change On Abort","type":"integer","minimum":0, "maximum":1, "options": { "infoText": "Options:\n'0' = No Change On Abort,\n'1' = Give Change On Abort"}},
								"armedtmts": {"title":"Armed Payment Abort Timeout","type":"integer","minimum":0, "maximum":900000, "options": { "infoText": "Time (in secs) before to quit an armed payment"}},
								"runngtmts": {"title":"Running Payment Abort Timeout","type":"integer","minimum":0, "maximum":900000, "options": { "infoText": "Time (in secs) before to quit a running payment"}},
								"carddeten": {"title":"Card Detect Enable","type":"integer","minimum":0, "maximum":1, "options": { "infoText": "Options:\n'0' = Card Detect Disabled,\n'1' = Card Detect Enabled"}},
								"dspuflwen": {"title":"Dispense Underflow Enable","type":"integer","minimum":0, "maximum":1, "options": { "infoText": "Options:\n'0' = Dispense Underflow Disabled,\n'1' = Dispense Underflow Enabled"}},
								"cashiermd": {"title":"Cashier Mode","type":"integer","minimum":0, "maximum":2, "options": { "infoText": "Options:\n'0' = 'Web Interface',\n'1' = 'Simplified',\n'2' = 'Both Web and Simplified'"}},
								"devices": {
									"title": "Devices",
									"type": "object",
									"properties": {
										"payprovsmngr":{"$ref": "#/definitions/payprovsmngr"},
										"cpgw":{
											"title": "Chip And Pin Gateway",
											"type": "object",
											"format":"grid",
											"properties": {
												"spectype": {"title":"Specific Type",	  "type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present", "grid_columns": 3}},
												"src":      {"title":"CPGW-Id", 		  "type":"string","options": { "infoText": "The user friendly name of the CPGW server", "grid_columns": 3}},
												"dst":      {"title":"Teminal-Id", "type":"string", "options": { "infoText": "The user friendly name of the target treminal", "grid_columns": 3}},
												"encoding": {"title":"Protocol Encoding", "type":"string", "enum":["ASCII","UTF-8"], "options": { "infoText": "Communication protocol Type", "grid_columns": 3}},
												"communication": { "$ref": "#/definitions/communication" }
											}
										},
										"sgp": {
											"title": "Cash Manager",
											"type": "object",
											"properties": {
												"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
												"core": {
													"title": "Core I/O",
													"type": "object",
													"description":"Core I/O Functions Configuration",
													"properties": {
														"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":1},
														"gpioctrl": {"title": "GpioCtrl", "$ref": "#/definitions/gpioctrl"},
														"statpins": {"title": "Status I/O", "type": "array", "options": {"collapsed": true}, "format": "table",
															"items": {"type": "object",
																 "properties": {
																	"_idx_":    {"type":"integer", "readonly": true},
																	"funct":	{"title":"Function",		 "type":"string",  "enum":["HoppsPres","HoppsUnlocked","CoinCashPres","CoinCashUnlocked","BillCashPres"], "readonly": false},
																	"id":		{"title":"Pin ID",			 "type":"integer", "minimum":0,"maximum":255},
																	"activest": {"title":"ActiveState",		 "type":"integer", "minimum":0,"maximum":1},
																	"risedlyms":{"title":"Rise filter (ms)", "type":"integer", "minimum":0,"maximum":5000},
																	"falldlyms":{"title":"Fall filter (ms)", "type":"integer", "minimum":0,"maximum":5000}
																}
															},
															"minItems": 0,
															"maxItems": 50
														},
														"ctrlpins": {"title": "Ctrl I/O","type": "array","options": {"collapsed": true}, "format": "table",
															"items":{"type": "object",
																 "properties": {
																	"_idx_":        {"type":"integer", "readonly": true},
																	"funct":	    { "title": "Function", 	   "type": "string",  "enum": ["OpenShutter", "CloseShutter", "CngBoxLampOn", "CngBoxLampOff", "AntiJam"], "readonly": false},
																	"id":		    { "title": "Pin ID",   	   "type": "integer", "minimum": 0, "maximum": 255 },
																	"activest":     { "title": "StartMode",  "type": "integer", "minimum": 0, "maximum": 1},
																	"lowperiodms":  { "title": "LowTime(ms)",  "type": "integer", "minimum": 0, "maximum": 10000},
																	"highperiodms": { "title": "HighTime(ms)", "type": "integer", "minimum": 0, "maximum": 10000},
																	"pulseno": 		{ "title": "PulsesNo",     "type": "integer", "minimum": 0, "maximum": 10000},
																	"vloggtnet":	{"title":"Virtual Logic Gates Net",	  "type":"string"}
																}
															},
															"minItems": 0,
															"maxItems": 50
														}
													}
												},
												"acoin": {
													"title": "Coins Acceptor",
													"type": "object",
													"description":"Coins Acceptor Configuration",
													"properties": {
														"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":3, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Mei(Plus Matic Cfg),\n'2' = EagleV2(Plus Matic Cfg),\n'3' = EagleV2(EBB Cfg)"}},
														"denominations": {
															"title": "List Of Denominations Configurations",
															"type": "array",
															"options": {"collapsed": true,"disable_array_add":true,"disable_array_delete":true,"disable_array_reorder":true}, "format": "table",
															"items": {
																"type": "object",
																"properties": {
																	"_idx_":    {"type":"integer", "readonly": true},
																	"id":  		 {"title":"Denomination Id","type":"integer","minimum":0,"maximum":15},
																	"enabled":	 {"title":"Enabled/Disabled","type":"boolean", "format": "checkbox"},
																	"currency":  {"title":"Denom. Currency", "$ref": "#/definitions/currency" },
																	"value":  	 {"title":"Value","type":"number","minimum":0,"maximum":100000},
																	"moneycode": {"title":"Denom. Money Code","type":"string","enum":["EU001A","EU002A","EU005A","EU010A","EU020A","EU050A","EU100A","EU200A","GB005D","GB010D","GB010B","GB020A","GB050B","GB100B","GB200A","CH005A","CH010A","CH020A","CH050A","CH100A","CH200A","CH500A","ZA500B","ZA500C","ZA200A","ZA100C","ZA050B","ZA020A","ZA010B","ZA005A","BG200B","BG100B","BG050B","BG020B","BG010B","AE025B","AE050A","AE050B","AE050C","AE100B","AE100C","RO010B","RO050B","PL002A","PL002B","PL005A","PL005B","PL010A","PL020A","PL050A","PL100A","PL200C","PL200A","PL500A","US001A","US001B","US005A","US010A","US025A","US050A","US100A","CA001A","CA001B","CA005A","CA005B","CA005C","CA010A","CA010B","CA025B","CA025C","CA050B","CA100A","CA100B","CA200A","CA200B","DZ100A","DZ100B","DZ200B","DZ500A","DZ500B","DZ1K0A","DZ1K0B","DZ2K0A","DZ5K0A","DZ10KA","DZ20KA"]}
																}
															},
															"minItems": 1,
															"maxItems": 16
														},
														"communication": { "$ref": "#/definitions/communication" }
													}
												},
												"abill": {
													"title": "Bills Acceptor",
													"type": "object",
													"description":"Bills Acceptor Configuration",
													"properties": {
														"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":3, "options": { "infoText": "Options:\n'0' = Not Present,\n'2' = Mei SC83,\n'3' = CashCode Bill to Bill"}},
														"denominations": {
															"title": "List Of Denominations Configurations",
															"type": "array",
															"options": {"collapsed": true,"disable_array_add":true,"disable_array_delete":true,"disable_array_reorder":true}, "format": "table",
															"items": {
																"type": "object",
																"properties": {
																	"_idx_":    {"type":"integer", "readonly": true},
																	"id":  		 {"title":"Denomination Id","type":"integer","minimum":0,"maximum":15},
																	"enabled":	 {"title":"Enabled/Disabled","type":"boolean", "format": "checkbox"},
																	"currency":  {"title":"Denom. Currency", "$ref": "#/definitions/currency" },
																	"value":  	 {"title":"Value","type":"number","minimum":0,"maximum":100000},
																	"moneycode": {"title":"Denom. Money Code","type":"string","enum":["1","2","3","4","5","6","7","8"]}
																}
															},
															"minItems": 1,
															"maxItems": 16
														},
														"communication": { "$ref": "#/definitions/communication" }
													}
												},
												"dcoin": {
													"title": "Coins Dispenser",
													"description":"Coins Dispenser Configuration",
													"type": "object",
													"properties": {
														"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":2, "options": { "infoText":"Options:\n'0' = Not Present,\n'1' = Old (Plus Matic Cfg),\n'2' = Microard X5 (EBB Cfg)"}},
														"denominations": {
															"title": "List Of Denominations Configurations",
															"type": "array",
															"options": {"collapsed": true,"disable_array_add":true,"disable_array_delete":true,"disable_array_reorder":true}, "format": "table",
															"items": {
																"type": "object",
																"properties": {
																	"_idx_":    {"type":"integer", "readonly": true},
																	"id":  		 {"title":"Denomination Id","type":"integer","minimum":0,"maximum":6},
																	"enabled":	 {"title":"Enabled/Disabled","type":"boolean", "format": "checkbox"},
																	"currency":  {"title":"Denom. Currency", "$ref": "#/definitions/currency" },
																	"value":  	 {"title":"Value","type":"number","minimum":0,"maximum":100000},
																	"capacity":  {"title":"Capacity","type":"integer","minimum":0,"maximum":2000},
																	"reserve": 	 {"title":"Reserve","type":"integer","minimum":0,"maximum":2000},
																	"timeouts":  {"title":"Timeout","type":"integer","minimum":0,"maximum":60},
																	"maxcngpcs": {"title":"Max Change No.","type":"integer","minimum":0,"maximum":500},
																	"nomqtty":   {"title":"Nominal Quantity","type":"integer","minimum":0,"maximum":2000}
																}
															},
															"minItems": 1,
															"maxItems": 7
														},
														"communication": { "$ref": "#/definitions/communication" }
													}
												},
												"dbill": {
													"title": "Bills Dispenser",
													"type": "object",
													"description":"Bills Dispenser Configuration",
													"properties": {
														"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":3, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = F53 (EBB Cfg),\n'3' = CashCode Bill to Bill"}},
														"denominations": {
															"title": "List Of Configurable Denominations",
															"type": "array",
															"options": {"collapsed": true,"disable_array_add":true,"disable_array_delete":true,"disable_array_reorder":true}, "format": "table",
															"items": {
																"type": "object",
																"properties": {
																	"_idx_":     {"type":"integer", "readonly": true},
																	"id":  		 {"title":"Denomination Id","type":"integer","minimum":0,"maximum":7},
																	"enabled":	 {"title":"Enabled/Disabled","type":"boolean", "format": "checkbox"},
																	"currency":  {"title":"Denom. Currency", "$ref": "#/definitions/currency" },
																	"value":  	 {"title":"Value","type":"number","minimum":0,"maximum":100000},
																	"capacity":  {"title":"Capacity","type":"integer","minimum":0,"maximum":1000},
																	"reserve": 	 {"title":"Reserve","type":"integer","minimum":0,"maximum":500},
																	"timeouts":  {"title":"Timeout","type":"integer","minimum":0,"maximum":60},
																	"maxcngpcs": {"title":"Max Change No.","type":"integer","minimum":0,"maximum":500},
																	"nomqtty":   {"title":"Nominal Quantity","type":"integer","minimum":0,"maximum":1000},
																	"ispolymer": {"title":"Is Polymer","type":"boolean", "format": "checkbox"},
																	"length":    {"title":"Length","type":"number"},
																	"thick":     {"title":"Tickness","type":"number"},
																	"stoponerr": {"title":"Stop On Error","type":"boolean", "format": "checkbox"},
																	"unldlevel": {"title":"Unload Level","type":"number","minimum":0,"maximum":100}
																}
															},
															"minItems": 1,
															"maxItems": 8
														},
														"communication": { "$ref": "#/definitions/communication" }
													}
												},
												"bill2bill": {
													"title": "Bill2Bill Options",
													"type": "object",
													"properties": {
														"inuse": {"title":"Enable/Disable the Bill2Bill device","type":"boolean", "format": "checkbox"},
														"oosenabled": {"title":"Enable/Disable OOS if Bill2Bill not operational","type":"boolean", "format": "checkbox"},
														"unldenabled": {"title":"Enable/Disable the 'Unload' Bill2Bill action","type":"boolean", "format": "checkbox"},
														"unldtm": {"title":"Timeout of the 'Unload' Bill2Bill action (min)","type":"integer","minimum":0,"maximum":60}
													}
												},
												"cashmngr": {
													"title": "Paths Manager",
													"type": "object",
													"description":"Cash Paths Manager Configuration",
													"properties": {
														"persistentdata": {
															"title": "Persistent Data Configurations",
															"type": "object",
															"options": {"hidden": true},
															"properties": {
																"dbfilename":	{"title":"DB FileName",		  "type":"string"},
																"dbfilesizekb": {"title":"DB File Size (KB)", "type":"integer","minimum":1,"maximum":1024},
																"dbtables": {
																	"title": "DB Tables",
																	"type": "array",
																	"options": {"collapsed": true}, "format": "table",
																	"items": {
																		"type": "object",
																		"properties": {
																			"_idx_":    {"type":"integer", "readonly": true},
																			"tablename": { "title": "Table Name", 		   "type": "string" , "readonly": false},
																			"tableid":   { "title": "Table Id",   		   "type": "integer", "readonly": false },
																			"recsz": 	 { "title": "Table Record Size",   "type": "integer", "readonly": false },
																			"recsno": 	 { "title": "Table Record Number", "type": "integer", "readonly": false}
																		}
																	},
																	"minItems": 2,
																	"maxItems": 2
																}
															}
														},
														"coins": {
															"title": "Paths from a-coin to d-coin for each denomination",
															"type": "array",
															"options": {"collapsed": true,"disable_array_add":false,"disable_array_delete":false,"disable_array_reorder":false}, "format": "table",
															"items": {
																"type": "object",
																"properties": {
																	"_idx_":    {"type":"integer", "readonly": true},
																	"path":     {"title":"Coin Main Path","$ref": "#/definitions/paths"},
																	"dst":	    {"title":"DCoin denom. id as destination","type":"integer","minimum":0,"maximum":6},
																	"fbpath":   {"title":"Fall Back Path","$ref": "#/definitions/paths"},
																	"enabled":  {"title":"Enabled/Disabled","type":"boolean", "format": "checkbox"},
																	"ismxdcash":{"title":"The path leads to a mixed cash?","type":"boolean", "format": "checkbox"},
																	"srcs":		{"title":"ACoin denom. ids as sources", "type": "array", "options": {"collapsed": true}, "format": "table", "items": {"type": "integer","minimum":0,"maximum":15}}
																}
															},
															"minItems": 1,
															"maxItems": 10
														},
														"bills": {
															"title": "Paths from a-bill to d-bill for each denomination",
															"type": "array",
															"options": {"collapsed": true,"disable_array_add":false,"disable_array_delete":false,"disable_array_reorder":false}, "format": "table",
															"items": {
																"type": "object",
																"properties": {
																	"_idx_":    {"type":"integer", "readonly": true},
																	"path":     {"title":"Banknote Main Path","$ref": "#/definitions/paths"},
																	"dst":	    {"title":"DBill denom. id as dest","type":"integer","minimum":0,"maximum":6},
																	"fbpath":   {"title":"Fall Back Path","$ref": "#/definitions/paths"},
																	"enabled":  {"title":"Enabled/Disabled","type":"boolean", "format": "checkbox"},
																	"ismxdcash":{"title":"The path leads to a mixed cash?","type":"boolean", "format": "checkbox"},
																	"srcs":		{"title":"ABill denom. ids as sources", "type": "array", "options": {"collapsed": true}, "format": "table", "items": {"type": "integer","minimum":0,"maximum":15}}
																}
															},
															"minItems": 1,
															"maxItems": 10
														}
													}
												}
											}
										}
									}
								}
							}
						},
						"tariffsservice": {
							"title": "Tariffs Service",
							"type": "object",
							"format":"grid",
							"description":"Here you can configure the Tariffs service",
							"properties": {
								"spectype":	{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": {"infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
								"sitecode" :	{"title":"Site Code",	 "type":"integer",	"minimum":1,"maximum":999999,"required":true, "id": "#sc", "options": { "hidden": true }},
								"dbconfigfile":	{"title": "Tariffs DB Config File", "type": "string", "readonly": false, "options": {"infoText": "The path to the tariffs xml file"}},
								"httpserver": 	{"title": "HttpServer Configurations", "$ref": "#/definitions/httpserver"}
							}
						},
						"usrpassservice": {
							"title": "UsrPass Service",
							"type": "object",
							"format":"grid",
							"description":"Here you can configure the UsrPass service",
							"properties": {
								"spectype":			{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
								"rcprightalign":{"title":"Receipt Right Align","type": "boolean", "options": { "infoText": "Enables/Disables receipt text right alignment"}},
								"faccodes": {
									"title": "Facility Codes",
									"type": "object",
									"format":"grid",
									"description":"Here you can configure accepted facility codes",
									"properties": {
										"chfaccodes":	{"title":"Enable Facility Code Checking","type":"boolean", "options": { "infoText": "Enables/Disables Facility Codes checking"}},
										"validfaccodes": {
											"title": "Facility Code List",
											"type": "array",
											"options": {"collapsed": true}, "format": "table",
											"items": {
												"type": "object",
												"properties": {
													"_idx_":    {"type":"integer", "options": { "infoText": "Index, starting from 0"}},
													"faccode":  {"title":"Facility Code","type":"integer","minimum":0, "options": { "infoText": "Facility Code"}},
													"desc":  	{"title":"Description","type":"string", "options": { "infoText": "Description for facility code"},"default": ""}
												}
											},
											"minItems": 0,
											"maxItems": 32
										}
									}
								},
								"subfrmt": {
									"title": "Proximity Sub Formats",
									"type": "array",
									"format":"grid",
									"description":"Here you can configure the sub formats",
									"options": {"collapsed": true},
									"items": {
										"title": "Sub Format", "type": "string", "enum":["WGND_32UDEM", "WGND_33M", "WGND_33O", "WGND_34IAS", "WGND_34AXA", "WGND_34IND", "WGND_35SIMMONS", "WGND_36S12906", "WGND_36SJOG", "WGND_37MG", "WGND_37A", "WGND_37HUH", "WGND_37CPMC", "WGND_37KAISER96AND96B", "WGND_37CVX1468"]
									},
									"minItems": 0,
									"maxItems": 3
								},
								"dtcipher": {
									"title": "Data Cipher",
									"type": "object",
									"format":"grid",
									"description":"Here you can configure the user pass data cipher",
									"properties": {
										"enabcipher":	{"title":"Enable Ciphering","type":"boolean", "options": { "infoText": "Enables/Disables data ciphering"}},
										"acceptother":	{"title":"Accept Clear/Ciphered Data","type":"boolean", "options": { "infoText": "Options:\n -If ciphering is enabled:\n  --'true' = Accept also clear data\n  --'false' = Reject clear data,\n -If ciphering is disabled:\n  --'true' = Accept also ciphered data\n  --'false' = Reject ciphered data"}},
										"algo":         {"title":"Algorithm","type":"string", "options": { "infoText": "Options:\n'none' = No cipher,\n'rwdt' = AlphaNum raw data cipher"}}
									}
								},
								"payprovsmngr":{"$ref": "#/definitions/payprovsmngr"},
								"printer": {
									"title": "Printer",
									"type": "object",
									"description":"Here you can configure the Printer device",
									"properties": {
										"spectype":		{"title":"Specific Type","type":"integer","minimum":0,"maximum":1,"options": { "infoText": "Options:\n'0' = Not Present,\n'1' =  HengstlerX56"}},
										"basecfg": {
											"title": "Printer Basic Configuration",
											"type": "object",
											"format":"grid",
											"properties": {
												"papertype":   {"title":"Paper Type (0=Roll,1=FanFold)","type":"integer","minimum":0,"maximum":1,"options": {"grid_columns": 4}},
												"pagelen":     {"title":"Page Length (tenth of mm)","type":"integer","minimum":0,"maximum":850,"options": {"grid_columns": 4}},
												"leftmargin":  {"title":"Left Margin (dots)","type":"integer","minimum":0,"maximum":65535,"options": {"grid_columns": 4}},
												"chsize":  	   {"title":"Char Size (dots)","type":"integer","minimum":0,"maximum":255,"options": {"grid_columns": 6}},
												"linepitch":   {"title":"Line Pitch (dot lines)","type":"integer","minimum":0,"maximum":255,"options": {"grid_columns": 6}},
												"linespace":   {"title":"Line Space (dot lines)","type":"integer","minimum":0,"maximum":255,"options": {"grid_columns": 6}},
												"brcdheight":  {"title":"Bar Code Height (dots)","type":"integer","minimum":0,"maximum":255,"options": {"grid_columns": 6}}
											}
										},
										"communication": { "$ref": "#/definitions/communication" }
									}
								},
								"fiscalprinter": {
									"title": "Fiscal Printer",
									"type": "object",
									"format":"grid",
									"description":"Here you can configure the Fiscal Printer device",
									"properties": {
										"spectype":		{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' =  Datecs", "grid_columns": 6}},
										"synctimeperiod":{"title":"Period for fiscal printer time synchronization (in minutes)", 	"type":"integer",	"minimum":0,"maximum":1440, "options": { "infoText": "Valid values:\n0 = Disabled\n[1,1440] = Enabled", "grid_columns": 6}},
										"communication": { "$ref": "#/definitions/communication" }
									}
								},
								"proxyrdrwrtr": {
									"title": "Proximity Card Reader/Writer",
									"type": "object",
									"format":"grid",
									"description":"Here you can configure the Proximity Reader/Writer device",
									"properties": {
										"spectype":	{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' =  Present", "grid_columns": 6}},
										"rdfilter":	{"title":"Read Filter (flag)","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' =  Not Filter,\n'1' = Filter data until two consecutive matching reads occurr", "grid_columns": 6}},
										"communication": { "$ref": "#/definitions/communication" }
									}
								},
								"proxyreaders": {
									"title": "Proximity Card Readers List",
									"type": "array",
									"description":"Here you can configure the Proximity Reader devices",
									"options": {"collapsed": true,"disable_array_add":true,"disable_array_delete":true,"disable_array_reorder":true}, "format": "table",
									"items": {
										"type": "object",
										"properties": {
											"_idx_":    { "type":"integer", "readonly": true},
											"spectype":	{"title":"Specific Type","type":"integer","minimum":0,"maximum":3, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' =  ZeagHub,\n'2' = UhfAt4,\n'3' = DP810"}},
											"rdfilter":	{"title":"Read Filter (ms)","type":"integer","minimum":0,"maximum":10000,"options": { "infoText": "Period (in ms) after a avlid data read in which further read are discarded"}},
											"communication": { "$ref": "#/definitions/communication" }
										}
									}
								},
								"ble": {
									"title": "BLE",
									"type": "object",
									"format":"grid",
									"description":"Here you can configure the Blutooth Low Energy device",
									"properties": {
										"spectype":		{"title":"Specific Type","type":"integer","minimum":0,"maximum":1, "options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present", "grid_columns": 4}},
										"parkbrand":		{"title":"Parking Brand","type":"integer","minimum":0,"maximum":4,"options": { "infoText": "Options:\n'0' = FAAC,\n'1' = ZEAG,\n'2' = DATAPARK,\n'3' = CRT,\n'4' = HUB","grid_columns": 4}},
										"periphmode":		{"title":"Peripheral Mode","type":"integer","minimum":0,"maximum":5, "options": { "infoText": "Options:\n'0' = ENTRANCE,\n'1' = EXIT,\n'2' = APM_QR_ON_SMARTPHONE,\n'3' = APM_QR_ON_APM,\n'4' = APM_ON_PURE_BLE,\n'5' = APM_ON_NFC\n", "grid_columns": 4}},
										"deviceno":		{"title":"Peripheral Device Number","type":"integer","minimum":0,"maximum":1000, "options": { "infoText": "BLE internal peripheral number", "grid_columns": 6}},
										"installationcode": {"title":"Parking Installation Code","type":"string","required":true, "options": { "infoText": "BLE global unique installation code", "grid_columns": 6}},
										"communication":    { "$ref": "#/definitions/communication" }
									}
								},
								"bcreader": {
									"title": "BarCode Reader",
									"type": "object",
									"description":"Here you can configure the Barcode Reader device",
									"properties": {
										"spectype":	{"title":"Specific Type","type":"integer","minimum":0,"maximum":2,"options": { "infoText": "Options:\n'0' = Not Present,\n'1' = GryphonGFS4400,\n'2' = KeyBrdEmu"}},
										"communication": { "$ref": "#/definitions/communication" }
									}
								},
								"ticketunit": {
									"title": "Ticket Unit",
									"type": "object",
									"format":"grid",
									"description":"Here you can configure the Ticket Uint device",
									"properties": {
										"spectype":{"title":"Specific Type","type":"integer","minimum":0,"maximum":1,"options": { "infoText": "Options:\n'0' = Not Present,\n'1' = Present"}},
										"deepinit":{"title":"Deep Init","type": "boolean", "options": { "infoText": "Options:\n'0' = Full Data Load Disabled,\n'1' = Full Data Load Enabled"}},
										"ejectmode":{"title":"Default Eject Mode","type":"integer","minimum":0,"maximum":3,"options": { "infoText": "Options:\n'0' = Front Partial,\n'1' = Front Full,\n'2' = Rear,\n'3' =  Bottom"}},
										"fonts": {
											"title": "Preloaded Fonts",
											"type": "array",
											"options": {"collapsed": true}, "format": "table",
											"items": {
												"type": "object",
												"properties": {
													"_idx_":    { "type":"integer", "readonly": true},
													"id":		{"title":"Internal Font ID","type":"integer","minimum":0,"maximum":99},
													"filename": {"title":"Font File Name","type":"string","pattern":"^.*\\.ttf$"}
												}
											},
											"minItems": 0,
											"maxItems": 50
										},
										"logos": {
											"title": "Preloaded Logos",
											"type": "array",
											"options": {"collapsed": true}, "format": "table",
											"items": {
												"type": "object",
												"properties": {
													"_idx_":    { "type":"integer", "readonly": true},
													"id":		{"title":"Internal Logo ID", "type":"integer","minimum":0,"maximum":99},
													"filename": {"title":"Logo File Name",	 "type":"string","pattern":"^.*\\.pcx$"}
												}
											},
											"minItems": 0,
											"maxItems": 50
										},
										"rois": {
											"title": "Regions Of Iterest",
											"type": "array",
											"options": {"hidden": true}, "format": "table",
											"items": {
												"type": "object",
												"properties": {
													"_idx_":    { "type":"integer", "readonly": true},
													"name":		{"title":"ROI Name","type":"string"},
													"enabled":	{"title":"ROI Enabled/Disabled","type":"boolean", "format": "checkbox"},
													"id":		{"title":"Internal ROI ID","type":"integer","minimum":0,"maximum":99},
													"scanner":	{"title":"Scanner Mode","type":"string","enum":["TOP","BOTTOM"]},
													"bcmaxno":	{"title":"Maximum Number Of Barcode Expected","type":"integer","minimum":1,"maximum":5},
													"pixx":		{"title":"X-Pixel starting from left side","type":"integer","minimum":1,"maximum":630},
													"pixy":		{"title":"Y-Pixel starting from bottomside","type":"integer","minimum":1,"maximum":1022},
													"dimpixsx":	{"title":"X length in pixel","type":"integer","minimum":1,"maximum":630},
													"dimpixsy":	{"title":"Y length in pixel","type":"integer","minimum":1,"maximum":1022},
													"timeout":	{"title":"Research Timeout (ms)","type":"integer","minimum":1,"maximum":5000},
													"barcodes": {
														"title": "Enabled Barcodes",
														"type": "array",
														"options": {"collapsed": true}, "format": "table",
														"items": {
															"type": "object",
															"properties": {
																"_idx_":    { "type":"integer", "readonly": true},
																"type":    { "title": "Barcode Type", "type": "string", "enum": ["DATAMATRIX", "QRCODE", "AZTEC", "PDF", "CODE39", "ITF", "CODABAR", "CODE128", "CODE93", "EAN13"], "default": "DATAMATRIX"},
																"enabled": { "title": "Barcode Enabled/Disabled", "type": "boolean", "default": false }
															}
														},
														"minItems": 0,
														"maxItems": 50
													}
												}
											},
											"minItems": 0,
											"maxItems": 50
										},
										"communication": { "$ref": "#/definitions/communication" }
									}
								}
							}
						}
					}
				}
			}
		}
	}
}

with open('ConfigData_NEW.json') as new:
    base = json.load(new)
with open('ConfigData_ORIG.json') as orig:
    head = json.load(orig)
target = merge(base, head)
with open('ConfigData_merged.json', 'w') as merged:
    json.dump(target, merged, indent=4)

#Create the installation package that will be pushed to the device
print("Creating the update package file...")
with tarfile.open('JPSApps.tar.gz', 'w:gz') as tar:
    tar.add('JPSApps')


#Create the update script that will be pushed to the device
print("Creating the update script file...")
jps.update_script(device.info["appfld"], device.info["webfld"], device.info["workdir"])

#Push the files to the device
print("Uploading the files to the device...")
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(ip, username=device.info["login"], password='')
sftp = client.open_sftp()
try:
    sftp.put("JPSApps.tar.gz", device.info["workdir"] + "/JPSApps.tar.gz")
except:
    sys.exit("Impossible to copy the JPSApps.tar.gz file into the device, the update has failed!")
try:
    sftp.put("_update.sh", device.info["workdir"] + "/_update.sh")
except:
    sys.exit("Impossible to copy the _update.sh file into the device, the update has failed!")
try:
    sftp.put("ConfigData_merged.json", device.info["workdir"] + "/ConfigData_merged.json")
except:
    sys.exit("Impossible to copy the ConfigData_merged.json file into the device, the update has failed!")
client.close()

#Execute the update script
print("Updating...")
client = paramiko.SSHClient()
client.load_system_host_keys()
client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
client.connect(ip, username="root", password='')
try:
    stdin, stdout, stderr = client.exec_command("chmod +x " + device.info["workdir"] + "/_update.sh", get_pty=True)
except:
    jps.post_clean()
    sys.exit("Impossible to execute chmod via ssh, the update has failed!")
try:
    stdin, stdout, stderr = client.exec_command(device.info["workdir"] + "/_update.sh", get_pty=True)
    remote_out = stdout.readlines()
    for line in remote_out:
        print(line)
    if stdout.channel.recv_exit_status() != 0:
        jps.post_clean()
        sys.exit("An error occurred during the update script execution, the update has failed!")
except Exception as e:
    jps.post_clean()
    sys.exit("The execution of the remote update script has failed with the error: " + e)
client.close()

#Take the trash out
jps.post_clean()

print("The update has been completed correctly.")
a = input('Press a key to exit...')
if a:
    sys.exit(0)
