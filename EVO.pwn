/*  Elite Vehicle Ownership
 *
 *  (c) Copyright 2016, DarkSkull
 *	Script Version: 1.0
 *
 *
 *	Credits(DO NOT REMOVE THIS):
 *	Y_Less for y_ini
 *	Y_Less for sscanf2
 *	Zeex for ZCMD
 *	Konstantinos, Misiur, AndySedeyn & ThePhenix for helping me fix bugs. 
 *	DarkSkull for this script
 *
 *	You may use this script for your own use.
 *	You're not allowed re-distrbute or re-release this script without proper permissions.
 *
 */

#define FILTERSCRIPT

#include <a_samp>
#include <crashdetect>
#include <YSI\y_ini>
#include <ZCMD>
#include <sscanf2>

#if !defined strcpy
	#define strcpy(%0,%1,%2) strcat((%0[0] = '\0', %0), %1, %2)
#endif

// -------------------------------------------------------------------------
//								COLORS
// -------------------------------------------------------------------------

#define COLOR_RED 0xFF0000FF
#define COLOR_YELLOW 0xFFFF00AA
#define COLOR_ORANGE 0xFFA500FF
#define COLOR_LAWNGREEN 0x7CFC00FF
#define COLOR_DODGERBLUE 0x1E90FFFF

// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
//								SETTINGS
// -------------------------------------------------------------------------

#define USERS_PATH "/EVO/users/%s.ini"
#define VEHICLES_PATH "/EVO/vehicles/%d.ini"
#define MAX_OWNABLE_VEHICLES 5
#define DEFAULT_OWNER "Server"
#define DEFAULT_PLATE "ABC123"
#define DEFAULT_PRICE 50000
#define RESPAWN_TIME 5 
#define TELEPORT_TIME 3

 // -------------------------------------------------------------------------

#define DIALOG_VLIST 733
#define DIALOG_VINFO 734
#define DIALOG_VHELP 735


// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
//                                   ENUMS
// -------------------------------------------------------------------------
enum vInfo {
	vID,
	vModel,
	Float:xSpawn,
	Float:ySpawn,
	Float:zSpawn,
	Float:angleSpawn,
	vCol1,
	vCol2,
	vPaintjob,
	vMod[17],
	vPlate[10],
	vRespawn,
	vOwner[MAX_PLAYER_NAME],
	vPrice,
	bool:Secure,
	bool:isOwned,
	bool:vBuyable,
	bool:vTemp,
	bool:vIsSelling,
	vSellingPrice
}

enum pInfo {
	bool:pAllowed,
	pTotalVehs,
	pVSlot[MAX_OWNABLE_VEHICLES],
	sTo,
	sFrom,
	svID
}
// -------------------------------------------------------------------------
new SellingTimer[MAX_PLAYERS];
new VehicleInfo[MAX_VEHICLES][vInfo];
new bool:vCreated[MAX_VEHICLES] = {false, ...};
new PlayerInfo[MAX_PLAYERS][pInfo];
new teleport_time  = TELEPORT_TIME;

new spoiler[20][0] = {
	{1000},
	{1001},
	{1002},
	{1003},
	{1014},
	{1015},
	{1016},
	{1023},
	{1058},
	{1060},
	{1049},
	{1050},
	{1138},
	{1139},
	{1146},
	{1147},
	{1158},
	{1162},
	{1163},
	{1164}
};
 
new nitro[3][0] = {
    {1008},
    {1009},
    {1010}
};
 
new fbumper[23][0] = {
    {1117},
    {1152},
    {1153},
    {1155},
    {1157},
    {1160},
    {1165},
    {1166},
    {1169},
    {1170},
    {1171},
    {1172},
    {1173},
    {1174},
    {1175},
    {1179},
    {1181},
    {1182},
    {1185},
    {1188},
    {1189},
    {1192},
    {1193}
};
 
new rbumper[22][0] = {
    {1140},
    {1141},
    {1148},
    {1149},
    {1150},
    {1151},
    {1154},
    {1156},
    {1159},
    {1161},
    {1167},
    {1168},
    {1176},
    {1177},
    {1178},
    {1180},
    {1183},
    {1184},
    {1186},
    {1187},
    {1190},
    {1191}
};
 
new exhaust[28][0] = {
    {1018},
    {1019},
    {1020},
    {1021},
    {1022},
    {1028},
    {1029},
    {1037},
    {1043},
    {1044},
    {1045},
    {1046},
    {1059},
    {1064},
    {1065},
    {1066},
    {1089},
    {1092},
    {1104},
    {1105},
    {1113},
    {1114},
    {1126},
    {1127},
    {1129},
    {1132},
    {1135},
    {1136}
};
 
new bventr[2][0] = {
    {1142},
    {1144}
};
 
new bventl[2][0] = {
    {1143},
    {1145}
};
 
new bscoop[4][0] = {
	{1004},
	{1005},
	{1011},
	{1012}
};
 
new rscoop[17][0] = {
    {1006},
    {1032},
    {1033},
    {1035},
    {1038},
    {1053},
    {1054},
    {1055},
    {1061},
    {1067},
    {1068},
    {1088},
    {1091},
    {1103},
    {1128},
    {1130},
    {1131}
};
 
new lskirt[21][0] = {
    {1007},
    {1026},
    {1031},
    {1036},
    {1039},
    {1042},
    {1047},
    {1048},
    {1056},
    {1057},
    {1069},
    {1070},
    {1090},
    {1093},
    {1106},
    {1108},
    {1118},
    {1119},
    {1133},
    {1122},
    {1134}
};
 
new rskirt[21][0] = {
    {1017},
    {1027},
    {1030},
    {1040},
    {1041},
    {1051},
    {1052},
    {1062},
    {1063},
    {1071},
    {1072},
    {1094},
    {1095},
    {1099},
    {1101},
    {1102},
    {1107},
    {1120},
    {1121},
    {1124},
    {1137}
};
 
new hydraulics[1][0] = {
    {1087}
};
 
new cbase[1][0] = {
    {1086}
};
 
new rbbars[4][0] = {
    {1109},
    {1110},
    {1123},
    {1125}
};
 
new fbbars[2][0] = {
    {1115},
    {1116}
};
 
new wheels[17][0] = {
    {1025},
    {1073},
    {1074},
    {1075},
    {1076},
    {1077},
    {1078},
    {1079},
    {1080},
    {1081},
    {1082},
    {1083},
    {1084},
    {1085},
    {1096},
    {1097},
    {1098}
};
 
new lights[2][0] = {
	{1013},
	{1024}
};

new Messages1[][] =
{
       "Please drive carefully.",
       "Enjoy your ride.",
       "Have fun.",
       "Have a good day."
};

new TotalVehicles;

forward public TuneVeh(vehicleid);
forward public PlateSet(vehicleid);
forward public LoadVehicleData(vehicleID, name[], value[]);
forward LoadUser_data(playerid, name[], value[]);
forward public PlayerToggle(playerid);
forward public RespawnVehicle(vehicleid);
forward public TeleportVehicleInfront(playerid, vehicleid);
forward SaveComponent(vehicleid, componentid);
forward public KillSale(playerid, targetid);


// -------------------------------------------------------------------------
// 								FUNCTIONS
//--------------------------------------------------------------------------
new VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
	"Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
	"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
	"Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
	"Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
	"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
	"Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
	"Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
	"Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
	"Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
	"Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
 	"Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
 	"FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
 	"Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
 	"Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
	"Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
	"Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
	"Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
	"Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
	"News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
 	"Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
 	"Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
 	"Tiller", "Utility Trailer"
};

public RespawnVehicle(vehicleid) {
	new vid = GetVID(vehicleid);
	if (vCreated[vid]) {
		DestroyVehicle(vehicleid);
		CreateVehicle(VehicleInfo[vid][vModel], VehicleInfo[vid][xSpawn], VehicleInfo[vid][ySpawn], VehicleInfo[vid][zSpawn], VehicleInfo[vid][angleSpawn], VehicleInfo[vid][vCol1], VehicleInfo[vid][vCol2], VehicleInfo[vid][vRespawn]);
		SetVehicleNumberPlate(vehicleid, VehicleInfo[vehicleid][vPlate]);
		SetTimerEx("PlateSet", 1000, false, "i", vehicleid);
		SetTimerEx("TuneVeh", 1000, false, "i", vehicleid);
	}
	return 1;
}

public PlayerToggle(playerid) {
	TogglePlayerControllable(playerid, true);

}

public TuneVeh(vehicleid) {
	new vid = GetVID(vehicleid);
	if(VehicleInfo[vid][vCol1] != -1 && VehicleInfo[vid][vCol2] != -1) {
		ChangeVehicleColor(vehicleid, VehicleInfo[vid][vCol1], VehicleInfo[vid][vCol2]);
	}
	ApplyPaintjob(vehicleid);
	ModVehicle(vehicleid);
} 

public KillSale(playerid, targetid) {
	PlayerInfo[playerid][sTo] = -1;
	new vid = PlayerInfo[playerid][svID];
	PlayerInfo[playerid][svID] = 0;
	PlayerInfo[targetid][sFrom] = -1;
	VehicleInfo[vid][vIsSelling] = false;
	VehicleInfo[vid][vSellingPrice] = 0;

	SendClientMessage(playerid, COLOR_LAWNGREEN, "[SERVER]: Offer timed out.");
	SendClientMessage(targetid, COLOR_LAWNGREEN, "[SERVER]: Offer timed out.");
	return 1;
}

public PlateSet(vehicleid) {
	new Float:xp, Float:yp, Float:zp, Float:anglep;
	GetVehiclePos(vehicleid, xp, yp, zp);
	GetVehicleZAngle(vehicleid, anglep);
	SetVehicleToRespawn(vehicleid);
	SetVehiclePos(vehicleid, xp, yp, zp);
	SetVehicleZAngle(vehicleid, anglep);
	SetTimerEx("TuneVeh", 1000, false, "i", vehicleid);
}

public LoadVehicleData(vehicleID, name[], value[]) {
	INI_Int("model", VehicleInfo[vehicleID][vModel]);
	INI_Float("LocX", VehicleInfo[vehicleID][xSpawn]);
	INI_Float("LocY", VehicleInfo[vehicleID][ySpawn]);
	INI_Float("LocZ", VehicleInfo[vehicleID][zSpawn]);
	INI_Float("LocAngle", VehicleInfo[vehicleID][angleSpawn]);
	INI_Int("color1", VehicleInfo[vehicleID][vCol1]);
	INI_Int("color2", VehicleInfo[vehicleID][vCol2]);
	INI_Int("paintjob", VehicleInfo[vehicleID][vPaintjob]);

	for(new i = 0; i < 17; i++) {
		new cmod[6];
		format(cmod, sizeof(cmod), "mod%d", i);
		INI_Int(cmod, VehicleInfo[vehicleID][vMod][i]);
	}

	INI_String("plate", VehicleInfo[vehicleID][vPlate], 10);
	INI_Int("respawn", VehicleInfo[vehicleID][vRespawn]);
	INI_String("owner", VehicleInfo[vehicleID][vOwner], MAX_PLAYER_NAME);
	INI_Int("price", VehicleInfo[vehicleID][vPrice]);

	INI_Bool("Secure", VehicleInfo[vehicleID][Secure]);
	INI_Bool("owned", VehicleInfo[vehicleID][isOwned]);
	INI_Bool("buyable", VehicleInfo[vehicleID][vBuyable]);
	return 1;
}

public SaveComponent(vehicleid, componentid)
{
    new playerid = GetDriverID(vehicleid);
	if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
	    if (isOwner(playerid, vehicleid) || IsPlayerAdmin(playerid)) {
	    	new vid = GetVID(vehicleid);
			for(new s=0; s<20; s++) {
 				if(componentid == spoiler[s][0]) {
   					VehicleInfo[vehicleid][vMod][0] = componentid;
				}
			}
			for(new s=0; s<4; s++) {
 				if(componentid == bscoop[s][0]) {
   					VehicleInfo[vid][vMod][1] = componentid;
				}
			}
			for(new s=0; s<17; s++) {
 				if(componentid == rscoop[s][0]) {
   					VehicleInfo[vid][vMod][2] = componentid;
				}
			}
			for(new s=0; s<21; s++) {
 				if(componentid == rskirt[s][0]) {
   					VehicleInfo[vid][vMod][3] = componentid;
				}
			}
			for(new s=0; s<21; s++) {
 				if(componentid == lskirt[s][0]) {
   					VehicleInfo[vid][vMod][16] = componentid;
				}
			}
			for(new s=0; s<2; s++) {
 				if(componentid == lights[s][0]) {
   					VehicleInfo[vid][vMod][4] = componentid;
				}
			}
			for(new s=0; s<3; s++) {
 				if(componentid == nitro[s][0]) {
   					VehicleInfo[vid][vMod][5] = componentid;
				}
			}
			for(new s=0; s<28; s++) {
 				if(componentid == exhaust[s][0]) {
   					VehicleInfo[vid][vMod][6] = componentid;
				}
			}
			for(new s=0; s<17; s++) {
 				if(componentid == wheels[s][0]) {
   					VehicleInfo[vid][vMod][7] = componentid;
				}
			}
			for(new s=0; s<1; s++) {
 				if(componentid == cbase[s][0]) {
   					VehicleInfo[vid][vMod][8] = componentid;
				}
			}
			for(new s=0; s<1; s++) {
 				if(componentid == hydraulics[s][0]) {
   					VehicleInfo[vid][vMod][9] = componentid;
				}
			}
			for(new s=0; s<23; s++) {
 				if(componentid == fbumper[s][0]) {
   					VehicleInfo[vid][vMod][10] = componentid;
				}
			}
			for(new s=0; s<22; s++) {
 				if(componentid == rbumper[s][0]) {
   					VehicleInfo[vid][vMod][11] = componentid;
				}
			}
			for(new s=0; s<2; s++) {
 				if(componentid == bventr[s][0]) {
   					VehicleInfo[vid][vMod][12] = componentid;
				}
			}
			for(new s=0; s<2; s++) {
 				if(componentid == bventl[s][0]) {
   					VehicleInfo[vid][vMod][13] = componentid;
				}
			}
			for(new s=0; s<2; s++) {
 				if(componentid == fbbars[s][0]) {
   					VehicleInfo[vid][vMod][15] = componentid;
				}
			}
			for(new s=0; s<4; s++) {
 				if(componentid == rbbars[s][0]) {
   					VehicleInfo[vid][vMod][14] = componentid;
				}
			}

			return 1;
		}
	}
	return 0;
}

public LoadUser_data(playerid,name[],value[])
{
	INI_Bool("allowed", PlayerInfo[playerid][pAllowed]);
	INI_Int("totalvehs", PlayerInfo[playerid][pTotalVehs]);

	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		new vslot[10];
		format(vslot, sizeof(vslot), "slot%d", i);
		INI_Int(vslot, PlayerInfo[playerid][pVSlot][i]);
	}
 	return 1;
}

public TeleportVehicleInfront(playerid, vehicleid)
{
	new Float:xa, Float:ya, Float:za, Float:facing, Float:distance, string[128];
	new model = GetVehicleModel(vehicleid);

    GetPlayerPos(playerid, xa, ya, za);
    GetPlayerFacingAngle(playerid, facing);

    new Float:size_x,Float:size_y,Float:size_z;
	GetVehicleModelInfo(model, VEHICLE_MODEL_INFO_SIZE, size_x, size_y, size_z);
	
	distance = size_x + 0.5;

  	xa += (distance * floatsin(-facing, degrees));
    ya += (distance * floatcos(-facing, degrees));

	facing += 90.0;
	if(facing > 360.0) facing -= 360.0;

	format(string, sizeof(string), "Your %s has been succesfully teleported to your location.", GetVehicleName(vehicleid));
	SendClientMessage(playerid, COLOR_LAWNGREEN, string);
	return SetVehiclePos(vehicleid, xa, ya, za + (size_z * 0.25));
}

GetVehicleName(vehicleid)
{
	new String[128];
	format(String, sizeof(String),"%s",VehicleNames[GetVehicleModel(vehicleid) - 400]);
	return String;
}



GetSlotFromVehicle(playerid, vehicleid) {
	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		if(PlayerInfo[playerid][pVSlot][i] == vehicleid) return i;
	}
	return -1;
}

IsVehicleOccupied(vehicleid) {

    for(new i =0; i < MAX_PLAYERS; i++)
    {
        if(IsPlayerInVehicle(i,vehicleid)) return true;
            
    }
	return false;
}



Teleport(playerid, Float:x, Float:y, Float:z, Float:angle, interior, virtualworld, bool:ignoreVehicle) {
	if(!ignoreVehicle && IsPlayerInAnyVehicle(playerid) && GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
	    new vehicleid = GetPlayerVehicleID(playerid);
		SetVehiclePos(vehicleid, x, y, z);
		SetVehicleZAngle(vehicleid, angle);
		LinkVehicleToInterior(vehicleid, interior);
		SetVehicleVirtualWorld(vehicleid, virtualworld);
	} else {
	    SetPlayerPos(playerid, x, y, z);
	    SetPlayerFacingAngle(playerid, angle);
	}
	
	SetPlayerInterior(playerid, interior);
	SetPlayerVirtualWorld(playerid, virtualworld);
}

GetVID(vehicleID)
{
	for(new i = 0; i < MAX_VEHICLES; i++) 
	{
		if((vCreated[i]) && (VehicleInfo[i][vID] == vehicleID)) return i; 
	}

	return -1;
}

GetVehicleID(vid) {
	for(new i = 1; i < MAX_VEHICLES; i++) {
		if((vCreated[i]) && (VehicleInfo[vid][vID] == GetVID(i))) return i;
	}
	return -1;
}

IsTempVehicle(vehicleID)
{
	new vehicleid = GetVID(vehicleID);
	if(!vCreated[vehicleid] || VehicleInfo[vehicleid][vTemp]) return true; 

	return false;
}

GetFreeVehicleSlot() {
    for(new i = 1; i < sizeof(vCreated); i ++)
    {
        if(!vCreated[i]) return i;
    }
    return -1;
}

VehiclePath(vehicleid) {
	new path[64];
	format(path, sizeof(path), VEHICLES_PATH, vehicleid);
	return path;
}

UserPath(playerid) {
	new path[64], name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	format(path, sizeof(path), USERS_PATH, name);
	return path;
}

ApplyPaintjob(vehicleid) {
	new vid = GetVID(vehicleid);
	if(VehicleInfo[vid][vPaintjob] != -1) {
		ChangeVehiclePaintjob(vehicleid, VehicleInfo[vid][vPaintjob]);
	}
}

CreateVehicleEx(vehicleModel, Float:vxSpawn, Float:vySpawn, Float:vzSpawn, Float:vangleSpawn, vehicleColor1, vehicleColor2, vehiclePaintjob, vehicleMods[], vehiclePlate[], vehicleRespawn, vehicleOwner[], vehiclePrice, bool:vSecure, bool:vIsOwned, bool:vehicleBuyable) {
	new vehicleid = GetFreeVehicleSlot();
	
	VehicleInfo[vehicleid][vModel] 		= vehicleModel;
	VehicleInfo[vehicleid][xSpawn]  	= vxSpawn;
    VehicleInfo[vehicleid][ySpawn] 		= vySpawn;
    VehicleInfo[vehicleid][zSpawn] 		= vzSpawn;
    VehicleInfo[vehicleid][angleSpawn]  = vangleSpawn;
    VehicleInfo[vehicleid][vCol1] 		= vehicleColor1;
    VehicleInfo[vehicleid][vCol2] 		= vehicleColor2;
    VehicleInfo[vehicleid][vPaintjob] 	= vehiclePaintjob;

    for(new i = 0; i < 17; i++) {
		VehicleInfo[vehicleid][vMod][i] = vehicleMods[i];
	}

    VehicleInfo[vehicleid][vRespawn] 	= vehicleRespawn;

    new buffer2[10];
	strcpy(buffer2, vehiclePlate);
	strcpy(VehicleInfo[vehicleid][vPlate], buffer2, 10);

    new buffer[MAX_PLAYER_NAME];
	strcpy(buffer, vehicleOwner);
	strcpy(VehicleInfo[vehicleid][vOwner], buffer, MAX_PLAYER_NAME);
    
    VehicleInfo[vehicleid][vPrice] 		= vehiclePrice;

    VehicleInfo[vehicleid][Secure]       = vSecure;
    VehicleInfo[vehicleid][isOwned] 	= vIsOwned;
	VehicleInfo[vehicleid][vBuyable] 	= vehicleBuyable;
	
    
    VehicleInfo[vehicleid][vID] 		= CreateVehicle(vehicleModel, vxSpawn, vySpawn, vzSpawn, vangleSpawn, vehicleColor1, vehicleColor2, vehicleRespawn);

	vCreated[vehicleid] 			    	= true;
	VehicleInfo[vehicleid][vTemp]	    	= false;
	VehicleInfo[vehicleid][vIsSelling]		= false;
	VehicleInfo[vehicleid][vSellingPrice]	= 0;
	TotalVehicles++;
	SetVehicleNumberPlate(vehicleid, VehicleInfo[vehicleid][vPlate]);

    SetTimerEx("PlateSet", 1000, false, "i", vehicleid);
    SetTimerEx("TuneVeh", 1000, false, "i", vehicleid);
    
    return vehicleid;
}

stock CreateTempVehicle(model, Float:x, Float:y, Float:z, Float:angle, color1, color2, respawntime) {
	new vehicleid = GetFreeVehicleSlot();
	
	VehicleInfo[vehicleid][vModel] 		= model;
	VehicleInfo[vehicleid][xSpawn]  	= x;
    VehicleInfo[vehicleid][ySpawn] 		= y;
    VehicleInfo[vehicleid][zSpawn] 		= z;
    VehicleInfo[vehicleid][angleSpawn]  = angle;
    VehicleInfo[vehicleid][vCol1] 		= color1;
    VehicleInfo[vehicleid][vCol2] 		= color2;

    VehicleInfo[vehicleid][vPaintjob] 	= -1;

    for(new i = 0; i < 17; i++) {
		VehicleInfo[vehicleid][vMod][i] = -1;
	}

    VehicleInfo[vehicleid][vRespawn] 	= respawntime;

    new buffer2[10];
	strcpy(buffer2, DEFAULT_PLATE);
	strcpy(VehicleInfo[vehicleid][vPlate], buffer2, 10);

    new buffer[MAX_PLAYER_NAME];
	strcpy(buffer, DEFAULT_OWNER);
	strcpy(VehicleInfo[vehicleid][vOwner], buffer, MAX_PLAYER_NAME);
    
    VehicleInfo[vehicleid][vPrice] 		= 0;
    VehicleInfo[vehicleid][Secure] 		= false;

    VehicleInfo[vehicleid][isOwned] 	= false;
	VehicleInfo[vehicleid][vBuyable] 	= false;

	VehicleInfo[vehicleid][vID] 		= CreateVehicle(model, x, y, z, angle, color1, color2, respawntime);

	vCreated[vehicleid] 			    	= true;
	VehicleInfo[vehicleid][vTemp]	    	= true;
	VehicleInfo[vehicleid][vIsSelling]		= false;
	VehicleInfo[vehicleid][vSellingPrice]	= 0
	SetVehicleNumberPlate(vehicleid, VehicleInfo[vehicleid][vPlate]);
	TotalVehicles++;

    SetTimerEx("PlateSet", 1000, false, "i", vehicleid);
    SetTimerEx("TuneVeh", 1000, false, "i", vehicleid);
    
    return vehicleid;
}


LoadVehicle(vehicleID, file[]) {
	INI_ParseFile(file, "LoadVehicleData", .bExtra=true, .extra = vehicleID);

	CreateVehicleEx(VehicleInfo[vehicleID][vModel], VehicleInfo[vehicleID][xSpawn], VehicleInfo[vehicleID][ySpawn], VehicleInfo[vehicleID][zSpawn], VehicleInfo[vehicleID][angleSpawn], VehicleInfo[vehicleID][vCol1], VehicleInfo[vehicleID][vCol2], VehicleInfo[vehicleID][vPaintjob], VehicleInfo[vehicleID][vMod],VehicleInfo[vehicleID][vPlate], VehicleInfo[vehicleID][vRespawn], VehicleInfo[vehicleID][vOwner], VehicleInfo[vehicleID][vPrice], VehicleInfo[vehicleID][Secure], VehicleInfo[vehicleID][isOwned],VehicleInfo[vehicleID][vBuyable]);
}



SaveVehicle(vehicleID) {
	if(!IsTempVehicle(vehicleID)) {
		new INI:dFile = INI_Open(VehiclePath(vehicleID));

		INI_WriteInt(dFile, "model", VehicleInfo[vehicleID][vModel]);
		INI_WriteFloat(dFile, "LocX", VehicleInfo[vehicleID][xSpawn]);
		INI_WriteFloat(dFile, "LocY", VehicleInfo[vehicleID][ySpawn]);
		INI_WriteFloat(dFile, "LocZ", VehicleInfo[vehicleID][zSpawn]);
		INI_WriteFloat(dFile, "LocAngle", VehicleInfo[vehicleID][angleSpawn]);
		INI_WriteInt(dFile, "color1", VehicleInfo[vehicleID][vCol1]);
		INI_WriteInt(dFile, "color2", VehicleInfo[vehicleID][vCol2]);
		INI_WriteInt(dFile, "paintjob", VehicleInfo[vehicleID][vPaintjob]);

		for(new i = 0; i < 17; i++) {
				new cmod[6];
				format(cmod, sizeof(cmod), "mod%d", i);
				INI_WriteInt(dFile ,cmod, VehicleInfo[vehicleID][vMod][i]);
		}

		INI_WriteString(dFile, "plate", VehicleInfo[vehicleID][vPlate]);
		INI_WriteInt(dFile, "respawn", VehicleInfo[vehicleID][vRespawn]);
		INI_WriteString(dFile, "owner", VehicleInfo[vehicleID][vOwner]);
		INI_WriteInt(dFile,"price", VehicleInfo[vehicleID][vPrice]);
		
		INI_WriteBool(dFile, "Secure", VehicleInfo[vehicleID][Secure]);
		INI_WriteBool(dFile, "owned", VehicleInfo[vehicleID][isOwned]);
		INI_WriteBool(dFile, "buyable", VehicleInfo[vehicleID][vBuyable]);
		
		INI_Close(dFile);
	}
	return 1;
}

LoadAllVehicle() {
	new index = 0;
	new loadedveh = 0;
	for(new i = 0; i < MAX_VEHICLES; i++) {
	    if (fexist(VehiclePath(index))) {
	        LoadVehicle(index, VehiclePath(index));
	        loadedveh++;
	    }
	    index++;
	} 
	
	printf("Vehicles Loaded: %d", loadedveh);
}

SaveAllVehicle() {
	new index = 1;
	new savedveh = 0;
	
	for(new i = 1; i <= TotalVehicles; i++) {
	    if (!IsTempVehicle(i)) {
	        SaveVehicle(index);
	        savedveh++;
	    }
	    index++;
	}
	
	printf("Vehicles Saved: %d", savedveh);
}

isVehicleForSale(vehicleid) {
	if (VehicleInfo[vehicleid][vBuyable] && !VehicleInfo[vehicleid][isOwned]) return true;
	
	return false;
}

GetDriverID(vehicleid)
{
    for(new i = 0; i < MAX_PLAYERS; i++)
    {
        if(GetPlayerVehicleID(i) == vehicleid && GetPlayerState(i) == PLAYER_STATE_DRIVER) return i;
    }
    return -1;
}

GetName(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

isOwner(playerid, vehicleid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	new vid = GetVID(vehicleid);
	if(VehicleInfo[vid][isOwned]) {
		if(!strcmp(name, VehicleInfo[vid][vOwner], false, MAX_PLAYER_NAME)) return true;
	}

	return false;
}

ModVehicle(vehicleid)
{
	if(vehicleid <= 0 || vehicleid >= MAX_VEHICLES) return;
	for(new i = 0; i < 17; i++) {
		if(VehicleInfo[vehicleid][vMod][i] != 0) {
			AddVehicleComponent(vehicleid, VehicleInfo[vehicleid][vMod][i]);
		}
	}
}


IsNumeric(const string[]) 
{
    for (new i = 0, j = strlen(string); i < j; i++)
    {
        if (string[i] > '9' || string[i] < '0')
		return 0;
    }
    return true;
}

GetModelVehicle(vname[]) 
{
    for(new i = 0; i < 211; i++)
    {
        if(strfind(VehicleNames[i], vname, true) != -1) return i + 400;
    }
    return -1;
}

DestroyVehicleEx(vehicleid) {
	new vid = GetVID(vehicleid);
	if(vCreated[vid]) {
		if(!IsTempVehicle(vehicleid)) {
			fremove(VehiclePath(VehicleInfo[vid][vID]));
		}
		vCreated[vid] = false;
		VehicleInfo[vid][vTemp] = false;
		DestroyVehicle(vehicleid);
		TotalVehicles--;
	}
	return 1;
}

IsSlotsFull(playerid) {
	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		if(PlayerInfo[playerid][pVSlot][i] == 0) return false;
	}

	return true;
}
GetPlayerFreeSlot(playerid) {
	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		if(PlayerInfo[playerid][pVSlot][i] == 0) return i;
	}

	return -1;
}

SavePlayer(playerid) {
	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File,"data");
    INI_WriteBool(File, "allowed", PlayerInfo[playerid][pAllowed]);
	INI_WriteInt(File, "totalvehs", PlayerInfo[playerid][pTotalVehs]);

	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		new vslot[10];
		format(vslot, sizeof(vslot), "slot%d", i);
		INI_WriteInt(File, vslot, PlayerInfo[playerid][pVSlot][i]);
	}	
	INI_Close(File);
}

GetVehicleSlot(playerid, vehicleid) {
	new vid = GetVID(vehicleid);
	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		if(PlayerInfo[playerid][pVSlot][i] == vid) return i;
	}
	return -1;
}


//--------------------------------------------------------------------------
public OnFilterScriptInit()
{
	print("\n_____________________________________\n");
	print("Loading... Elite Vehicle Ownership by Darkskull\n");
	
	
	LoadAllVehicle();
	print("Loading Completed\n");
	print("_____________________________________\n");
	return 1;
}

public OnFilterScriptExit()
{
    SaveAllVehicle();
    for(new i = 0; i < MAX_VEHICLES; i++) {
    	if(vCreated[i]) {
    		DestroyVehicle(i);
    	}
    }
	return 1;
}

public OnPlayerConnect(playerid)
{
	PlayerInfo[playerid][pAllowed] = false;
	PlayerInfo[playerid][pTotalVehs] = 0;
	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		PlayerInfo[playerid][pVSlot][i] = 0;
	}
	PlayerInfo[playerid][sTo] = -1;
	PlayerInfo[playerid][sFrom] = -1;
	PlayerInfo[playerid][svID] = 0;

	if(fexist(UserPath(playerid)))
	{
		INI_ParseFile(UserPath(playerid), "LoadUser_%s", .bExtra = true, .extra = playerid);
	}
	else
	{
 		new INI:File = INI_Open(UserPath(playerid));
 		INI_SetTag(File,"data");
        INI_WriteBool(File, "allowed", false);
		INI_WriteInt(File, "totalvehs", 0);

		for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
			new vslot[10];
			format(vslot, sizeof(vslot), "slot%d", i);
			INI_WriteInt(File, vslot, 0);
		}	
		INI_Close(File);
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(PlayerInfo[playerid][sTo] != -1) {
		new targetid = PlayerInfo[playerid][sTo];
		new vehicleid = PlayerInfo[playerid][svID];
		SendClientMessage(targetid, COLOR_ORANGE, "[SERVER]: Your offer has timed out because the vehicle owner has left the game.");
		PlayerInfo[targetid][sFrom] = -1;
		PlayerInfo[playerid][svID] = 0;
		VehicleInfo[vehicleid][vIsSelling] = false;
		VehicleInfo[vehicleid][vSellingPrice] = 0;
		KillTimer(SellingTimer[playerid]);
	}
	if(PlayerInfo[playerid][sFrom] != -1) {
		new ownerid = PlayerInfo[playerid][sFrom];
		new vehicleid = PlayerInfo[ownerid][svID];
		SendClientMessage(ownerid, COLOR_ORANGE, "[SERVER]: Your offer has timed out because the client has left the game.");
		PlayerInfo[ownerid][sTo] = -1;
		PlayerInfo[ownerid][svID] = 0;
		VehicleInfo[vehicleid][vIsSelling] = false;
		VehicleInfo[vehicleid][vSellingPrice] = 0;
		KillTimer(SellingTimer[ownerid]);
	}

	new INI:File = INI_Open(UserPath(playerid));
	INI_SetTag(File,"data");
    INI_WriteBool(File, "allowed", false);
	INI_WriteInt(File, "totalvehs", PlayerInfo[playerid][pTotalVehs]);

	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		new vslot[10];
		format(vslot, sizeof(vslot), "slot%d", i);
		INI_WriteInt(File, vslot, PlayerInfo[playerid][pVSlot][i]);
	}	
	INI_Close(File);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	PlayerInfo[playerid][pAllowed] = true;
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	PlayerInfo[playerid][pAllowed] = false;
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	if(!IsTempVehicle(vehicleid)) {
		SetTimerEx("TuneVeh", 500, false, "i", vehicleid);
	}	
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp("/mycommand", cmdtext, true, 10) == 0)
	{
		// Do something here
		return 1;
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	if (!IsTempVehicle(vehicleid)) {
		new vid = GetVID(vehicleid);
		new name[MAX_PLAYER_NAME];
		GetPlayerName(playerid, name, sizeof(name));
		if(VehicleInfo[vid][isOwned]) {
			if(isOwner(playerid, vehicleid)) {
				new msg[128];
				format(msg, sizeof(msg), "[SERVER]: Welcome to your %s, %s. %s", GetVehicleName(vehicleid), name, Messages1[random(sizeof(Messages1))]);
				SendClientMessage(playerid, COLOR_LAWNGREEN, msg);
			} else {
				new msg[128];
				format(msg, sizeof(msg), "[SERVER]: This %s belongs to %s and cannot be purchased.", GetVehicleName(vehicleid), VehicleInfo[vid][vOwner]);
				SendClientMessage(playerid, COLOR_RED, msg);
			}
		} else {
			if(VehicleInfo[vid][vBuyable]) {
				new msg[128];
				format(msg, sizeof(msg), "[SERVER]: This %s is for sale and costs $%d, Type /vbuy to buy this vehicle", GetVehicleName(vehicleid), VehicleInfo[vid][vPrice]);
				SendClientMessage(playerid, COLOR_YELLOW, msg);
			} else {
				new msg[128];
				format(msg, sizeof(msg), "[SERVER]: This %s has been set as unbuyable by the server administrator", GetVehicleName(vehicleid));
				SendClientMessage(playerid, COLOR_RED, msg);
			}
		}
	} else {
		new msg[128];
		format(msg, sizeof(msg), "[SERVER]: This %s is a temporary vehicle and cannot be purchased", GetVehicleName(vehicleid));
		SendClientMessage(playerid, COLOR_ORANGE, msg);
	}
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER) {
		new vehicleid = GetPlayerVehicleID(playerid);
		new vid = GetVID(vehicleid);
		if(VehicleInfo[vid][Secure] && !isOwner(playerid, vehicleid) && !IsPlayerAdmin(playerid)) {
			RemovePlayerFromVehicle(playerid);
			SendClientMessage(playerid, COLOR_DODGERBLUE, "[SERVER]: This vehicle has been secured by its owner and has prohibited anyone from using it.");
		}
	}
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	SaveComponent(vehicleid, componentid);
	new vid = GetVID(vehicleid);
	SaveVehicle(vid);
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	if(!IsTempVehicle(vehicleid)){
		if(isOwner(playerid, vehicleid) || IsPlayerAdmin(playerid)) {
			new vid = GetVID(vehicleid);
			VehicleInfo[vid][vPaintjob] = paintjobid;
			SaveVehicle(vid);
		}
	}
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	if(!IsTempVehicle(vehicleid)){
		if(isOwner(playerid, vehicleid) || IsPlayerAdmin(playerid)) {
			new vid = GetVID(vehicleid);
			VehicleInfo[vid][vCol1] = color1;
			VehicleInfo[vid][vCol2] = color2;
			SaveVehicle(vid);
		}
	}
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	new vid = GetVID(vehicleid);
	if(vCreated[vid]) {
		if(!VehicleInfo[vid][vTemp]) {
			SetTimerEx("TuneVeh", 1000, false, "i", vehicleid);
		}

	}
	return 1;
}

CMD:vcreate(playerid, params[])
{
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not authorized to use that command.");
	new model[32];

	if(sscanf(params, "s[32]", model)) return SendClientMessage(playerid, COLOR_DODGERBLUE, "[USAGE]: /vcreate [VehicleModel]"); 

	new vehModel;
	if(IsNumeric(model)) {
		vehModel = strval(model);
	} else {
	 	vehModel = GetModelVehicle(model);
	}

	if(vehModel < 400 || vehModel > 611) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid Vehicle.");

	new Float:x, Float:y, Float:z, Float:angle, mods[17], vehicleid, string[128]; 
	if(!IsPlayerInAnyVehicle(playerid)) {
		GetPlayerPos(playerid, x, y, z);
		GetPlayerFacingAngle(playerid, angle); 
	} else {
		new tvid = GetPlayerVehicleID(playerid);
		GetVehiclePos(tvid, x, y, z);
		GetVehicleZAngle(tvid, angle);
	}	

	for (new i = 0; i < 17; i++) {
		mods[i] = 0;
	}

	vehicleid = CreateVehicleEx(vehModel, x, y, z, angle, -1, -1, -1, mods, DEFAULT_PLATE, RESPAWN_TIME*60*1000, DEFAULT_OWNER, DEFAULT_PRICE, false, false, true);

	new vid = GetVID(vehicleid);

	format(string, sizeof(string), "[SERVER]: You have succesfully create a(n) %s", GetVehicleName(vehicleid));
	SaveVehicle(vid);
	return 1;
}

CMD:vremove(playerid, params[])
{
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not authorized to use that command.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You need to be in a vehicle to use this command.");
	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle");
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle has been offered to someone. Please wait until the process is completed.");

	DestroyVehicleEx(vehicleid);

	SendClientMessage(playerid, COLOR_LAWNGREEN, "[SERVER]: You have succesfully removed this vehicle.");
	return 1;
}


CMD:rac(playerid, params[]) {
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not authorized to use that command.");
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
    for(new i=1; i < MAX_VEHICLES; i++) {
    	if(vCreated[i]) { 
	    	if(!IsVehicleOccupied(i)) {
		    	RespawnVehicle(i);
			}
		}
	}

	new name[MAX_PLAYER_NAME], string[100];
	GetPlayerName(playerid, name, sizeof(name));
	format(string, sizeof(string), "[SERVER]: All unused vehicle have been respawned by Admin %s", name);
	SendClientMessageToAll(COLOR_DODGERBLUE, string);
	return 1;
}

CMD:vinfo(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You need to be in a vehicle to use this command.");
	new str[256], mainstr[1000], title[256];
	new vehicleid = GetPlayerVehicleID(playerid);
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: No info available as this is a temporary vehicle");
	new vid = GetVID(vehicleid);
	
	format(str, sizeof(str), "{FFD700}Vehicle Model: {FFFFFF}%d\n", GetVehicleModel(vehicleid));
	strcat(mainstr, str, sizeof(mainstr));

	if(VehicleInfo[vid][isOwned]) {
		format(str, sizeof(str), "{FFD700}Owned: {FFFFFF}Yes\n{FFD700}Owner: {FFFFFF}%s\n", VehicleInfo[vid][vOwner]);
		strcat(mainstr, str, sizeof(mainstr));
		if(IsPlayerAdmin(playerid)) {
			format(str, sizeof(str), "{FFD700}Price: {FFFFFF}%d\n", VehicleInfo[vid][vPrice]);
			strcat(mainstr, str, sizeof(mainstr));
		}
	} else {
		format(str, sizeof(str), "{FFD700}Owned: {FFFFFF}No\n");
		strcat(mainstr, str, sizeof(mainstr));
	}

	if(VehicleInfo[vid][vBuyable] && !VehicleInfo[vid][isOwned]) {
		format(str, sizeof(str), "{FFD700}Buyable: {FFFFFF}Yes\n{FFD700}Price: {FFFFFF}%d\n", VehicleInfo[vid][vPrice]);
		strcat(mainstr, str, sizeof(mainstr));
	} else {
		format(str, sizeof(str), "{FFD700}Buyable: {FFFFFF}No\n");
		strcat(mainstr, str, sizeof(mainstr));
	}

	format(str, sizeof(str), "{FFD700}Color 1: {FFFFFF}%i\n{FFD700}Color2: {FFFFFF}%i\n", VehicleInfo[vid][vCol1], VehicleInfo[vid][vCol2]);
	strcat(mainstr, str, sizeof(mainstr));
	if(IsPlayerAdmin(playerid)) {
		format(str, sizeof(str), "{FFD700}Paintjob: {FFFFFF}%i\n{FFD700}Respawn time: {FFFFFF}%i\n", VehicleInfo[vid][vPaintjob], VehicleInfo[vid][vRespawn]);
		strcat(mainstr, str, sizeof(mainstr));
	}
	if(VehicleInfo[vid][Secure]) {
		format(str, sizeof(str), "{FFD700}Secured: {FFFFFF}Yes\n");
		strcat(mainstr, str, sizeof(mainstr));
	} else {
		format(str, sizeof(str), "{FFD700}Secured: {FFFFFF}No\n");
		strcat(mainstr, str, sizeof(mainstr));
	}

	format(title, sizeof(title), "{FFD700}%s's {FFFFFF}info", GetVehicleName(vehicleid));
	return ShowPlayerDialog(playerid, DIALOG_VINFO, DIALOG_STYLE_MSGBOX, title, mainstr, "Okay", "");
}

CMD:vgoto(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not authorized to use that command.");
	new vehicleid;
	if(sscanf(params, "i", vehicleid)) return SendClientMessage(playerid, COLOR_DODGERBLUE, "[USAGE]: /vgoto [Vehicle ID]"); 
	if(vehicleid == INVALID_VEHICLE_ID) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: Invalid Vehicle ID!");
	if(!vCreated[vehicleid]) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: That vehicle doesn't exist!");

	vehicleid = GetVID(vehicleid);
	new Float:x, Float:y, Float:z, virtualworld;
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleVirtualWorld(vehicleid);

	TogglePlayerControllable(playerid, false);
	Teleport(playerid, x, y, z+3.5, 0, 0, virtualworld, true);
	SetTimerEx("PlayerToggle", 800, false, "i", playerid);

	return 1;
}

CMD:vpark(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You need to be the driver of the vehicle to park.");

	new vehicleid = GetPlayerVehicleID(playerid);
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: This is a temporary vehicle and cannot be parked!");

	if(!isOwner(playerid, vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You are not the owner of this vehicle.");
	if(isVehicleForSale(vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You are not the owner of this vehicle.");

	
	new Float:x, Float:y, Float:z, Float:angle;
	new vid = GetVID(vehicleid);
	GetVehiclePos(vehicleid, x, y, z);
	GetVehicleZAngle(vehicleid, angle);

	VehicleInfo[vid][xSpawn] 	 = x;
	VehicleInfo[vid][ySpawn] 	 = y;
	VehicleInfo[vid][zSpawn] 	 = z;
	VehicleInfo[vid][angleSpawn] = angle;

	SendClientMessage(playerid, COLOR_LAWNGREEN, "[SERVER]: You have succesfully parked this vehicle here. It will respawn here in the future.");
	SaveVehicle(vid);
	return 1;
}

CMD:clearmods(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You need to be the driver of the vehicle to remove the mods.");

	new vehicleid = GetPlayerVehicleID(playerid);
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: This is a temporary vehicle and cannot be parked!");

	if(!isOwner(playerid, vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You are not the owner of this vehicle.");
	if(isVehicleForSale(vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[SERVER]: You are not the owner of this vehicle.");

	new vid = GetVID(vehicleid);
	for(new i = 0; i < 17; i++) {
		if(VehicleInfo[vid][vMod][i] != 0) {
			RemoveVehicleComponent(vehicleid, VehicleInfo[vid][vMod][i]);
			VehicleInfo[vid][vMod][i] = 0;
		}
	}

	ChangeVehiclePaintjob(vehicleid, 3);
	VehicleInfo[vid][vPaintjob] = -1;

	SendClientMessage(playerid, COLOR_LAWNGREEN, "[SERVER]: You have removed all the mods from this vehicle.");
	SaveVehicle(vid);
	return 1;
}

CMD:vplate(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be the driver of the vehicle to park.");

	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);

	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle and it's plate cannot be changed.");
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle has been offered to someone. Please wait.");
	if(!isOwner(playerid, vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not the owner of this vehicle");

	new plate[10];
	if(sscanf(params,"s[32]",plate)) return SendClientMessage(playerid,COLOR_DODGERBLUE,"[USAGE]: /vplate [PLATE] ");
	if(strlen(plate) > 9) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Vehicle plate must be a maximum of 9 characters.");

	new buffer[10];
	strcpy(buffer, plate);
	strcpy(VehicleInfo[vid][vPlate], buffer, 10);

	SetVehicleNumberPlate(vehicleid, VehicleInfo[vid][vPlate]);
	RemovePlayerFromVehicle(playerid);
    SaveVehicle(vid);

    SendClientMessage(playerid, COLOR_LAWNGREEN, "[SERVER]: You have succesfully changed this vehicle's plate.");
    SetTimerEx("PlateSet", 3000, false, "i", vehicleid);
	return 1;
}

CMD:vbuy(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be the driver of the vehicle to buy the vehicle.");

	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);

	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle and cannot be purchased.");
	if(isOwner(playerid, vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You already own this vehicle.");
	if(!isVehicleForSale(vid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle is not for sale.");

	if(IsSlotsFull(playerid)) {
		new string[64];
		format(string, sizeof(string), "You already own %d vehicles.", MAX_OWNABLE_VEHICLES);
		return SendClientMessage(playerid, COLOR_RED, string);
	}

	if(VehicleInfo[vid][vPrice] > GetPlayerMoney(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You don't have enough cash to buy this vehicle.");

	new slot = GetPlayerFreeSlot(playerid);

	VehicleInfo[vid][isOwned] = true;
	VehicleInfo[vid][vBuyable] = false;

	new name[MAX_PLAYER_NAME], string[100];
	GetPlayerName(playerid, name, sizeof(name));
	strcpy(VehicleInfo[vid][vOwner], name, MAX_PLAYER_NAME);

	PlayerInfo[playerid][pVSlot][slot] = vid;
	PlayerInfo[playerid][pTotalVehs]++;
	GivePlayerMoney(playerid, -VehicleInfo[vid][vPrice]);

	format(string ,sizeof(string), "[SERVER]: You have succesfully purchased this %s for $%d in Slot %i.", GetVehicleName(vehicleid), VehicleInfo[vid][vPrice], slot+1);
	SendClientMessage(playerid, COLOR_LAWNGREEN, string);
	SaveVehicle(vid);
	SavePlayer(playerid);
	return 1;
}

CMD:vsell(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be the driver of the vehicle to buy the vehicle.");

	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);

	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle and cannot be sold.");
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle has been offered to someone. Please wait");
	if(!isOwner(playerid, vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You don't own this vehicle.");

	new slot = GetVehicleSlot(playerid, vehicleid);

	VehicleInfo[vid][isOwned] = false;
	VehicleInfo[vid][vBuyable] = true;

	strcpy(VehicleInfo[vid][vOwner], DEFAULT_OWNER, MAX_PLAYER_NAME);

	PlayerInfo[playerid][pVSlot][slot] = 0;
	PlayerInfo[playerid][pTotalVehs]--;
	GivePlayerMoney(playerid, VehicleInfo[vid][vPrice]);
	RemovePlayerFromVehicle(playerid);
	new string[128];

	format(string ,sizeof(string), "[ERROR]: You have succesfully sold your %s. $%d has been credited to you.", GetVehicleName(vehicleid), VehicleInfo[vid][vPrice]);
	SendClientMessage(playerid, COLOR_LAWNGREEN, string);
	SaveVehicle(vid);
	SavePlayer(playerid);
	return 1;
}

CMD:vcall(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You already have a vehicle.");

	new slot, string[100];
	format(string, sizeof(string), "USAGE: /vcall [1-%i]", MAX_OWNABLE_VEHICLES);
	if(sscanf(params,"i",slot)) return SendClientMessage(playerid, COLOR_RED, string);

	if(slot < 1 || slot > MAX_OWNABLE_VEHICLES) return SendClientMessage(playerid, COLOR_RED, string);

	slot = slot - 1;

	if(PlayerInfo[playerid][pVSlot][slot] == 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You don't have any vehicle in that slot.");

	new vehicleid = GetVehicleID(PlayerInfo[playerid][pVSlot][slot]);

	if(teleport_time == 0) {
		TeleportVehicleInfront(playerid, vehicleid);
	} else {
		new string2[128];
		SetTimerEx("TeleportVehicleInfront", TELEPORT_TIME*1000, false, "ii", playerid, vehicleid);
		format(string2, sizeof(string2), "[SERVER]: Your %s has been called. It should take about %i seconds to get to you.", GetVehicleName(vehicleid), TELEPORT_TIME);
		SendClientMessage(playerid, COLOR_ORANGE, string2);
	}
	return 1;
}

CMD:vlist(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	new targetid;
	if(!sscanf(params,"u",targetid)) {
		if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid,COLOR_RED,"[ERROR]: That player is not connected");
	} else {
		targetid = playerid;
	}

	new mainstring[MAX_OWNABLE_VEHICLES*50];

	for(new i = 0; i < MAX_OWNABLE_VEHICLES; i++) {
		new string[64], string2[64];
		if(PlayerInfo[targetid][pVSlot][i] == 0) {
			format(string2, sizeof(string2), "<Slot Empty>");
		} else {
			new vehicleid = GetVehicleID(PlayerInfo[targetid][pVSlot][i]);
			new vid = GetVID(vehicleid);
			format(string2, sizeof(string2), "%s {FFD700}(ID:%i)", GetVehicleName(vehicleid), VehicleInfo[vid][vID]);
		}
		
		format(string ,sizeof(string), "{FFD700}Slot %i: {FFFFFF}%s\n", i+1, string2);

		strcat(mainstring, string, sizeof(mainstring));
	}
	new name[MAX_PLAYER_NAME], title[100];
	GetPlayerName(targetid, name, sizeof(name));
	format(title, sizeof(title), "{FFD700}%s's {FFFFFF}Vehicles", name);
	ShowPlayerDialog(playerid, DIALOG_VLIST, DIALOG_STYLE_MSGBOX, title, mainstring, "Okay", "");
	return 1;
}

CMD:vsecure(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be the driver of the vehicle to secure the vehicle");

	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);

	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle.");
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle has been offered to someone. Please wait");
	if(!isOwner(playerid, vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You don't own this vehicle.");

	new string[100], string2[100];
	if(VehicleInfo[vid][Secure]) {
		VehicleInfo[vid][Secure] = false;
		strcpy(string, "is no longer secure.", sizeof(string));
	} else {
		VehicleInfo[vid][Secure] = true;
		strcpy(string, "has been secured.", sizeof(string));
	}

	format(string2, sizeof(string2), "[SERVER]: This %s %s",  GetVehicleName(vehicleid), string);
	SendClientMessage(playerid, COLOR_LAWNGREEN, string2);
	return 1;
}

CMD:vsellto(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be the driver of the vehicle to sell the vehicle.");

	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle is already for sale.");
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle and cannot be sold!");

	if(!isOwner(playerid, vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not the owner of this vehicle.");
	if(isVehicleForSale(vehicleid) && !IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not the owner of this vehicle.");

	if(PlayerInfo[playerid][sTo] != -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are already selling a vehicle, please wait till that process is completed.");

	new targetid, price;
	if(sscanf(params,"ud", targetid, price)) return SendClientMessage(playerid, COLOR_RED, "[USAGE]: /vsellto [playerid] [price]");
	if(targetid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid Player ID.");
	if(targetid == playerid) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You cannot sell the vehicle to yourself.");
	if(!PlayerInfo[targetid][pAllowed] || (PlayerInfo[targetid][sFrom] != -1)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: That player cannot recieve any offers at the moment.");
	if(price < 0) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Invalid Price");

	PlayerInfo[playerid][sTo] = targetid;
	PlayerInfo[playerid][svID] = vid;
	PlayerInfo[targetid][sFrom] = playerid;
	VehicleInfo[vid][vIsSelling] = true;
	VehicleInfo[vid][vSellingPrice] = price;

	SellingTimer[playerid] = SetTimerEx("KillSale", 60000, false, "ii", playerid, targetid);

	new string[256], string2[256];
	format(string, sizeof(string), "[SERVER]: You have decided to sell your %s to %s for $%d. Awaiting conformation from %s. Your request will timeout in 60 seconds.", GetVehicleName(vehicleid), GetName(targetid), price, GetName(targetid));
	format(string2, sizeof(string2), "[SERVER]: %s has decided to sell his %s to you for $%d. Type /vaccept to accept his offer. This request will time out in 60 seconds.", GetName(playerid), GetVehicleName(vehicleid), price);
	SendClientMessage(playerid, COLOR_DODGERBLUE, string);
	SendClientMessage(targetid, COLOR_DODGERBLUE, string2);
	return 1;
}

CMD:vaccept(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(PlayerInfo[playerid][sFrom] == -1) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: No one's selling you any vehicle.");

	new ownerid = PlayerInfo[playerid][sFrom];

	if(IsSlotsFull(playerid)) {
		new string[64];
		format(string, sizeof(string), "[ERROR]: You already own %d vehicles.", MAX_OWNABLE_VEHICLES);
		return SendClientMessage(playerid, COLOR_RED, string);
	}

	new vid = PlayerInfo[ownerid][svID];
	if(VehicleInfo[vid][vSellingPrice] > GetPlayerMoney(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You don't have enough money to accept this offer.");

	new buffer1[MAX_PLAYER_NAME], string[256], string2[256];

	strcpy(buffer1, GetName(playerid), MAX_PLAYER_NAME);
	strcpy(VehicleInfo[vid][vOwner], buffer1, MAX_PLAYER_NAME);

	new pslot = GetPlayerFreeSlot(playerid);
	PlayerInfo[playerid][pVSlot][pslot] = vid;

	new oslot = GetSlotFromVehicle(ownerid, vid);
	PlayerInfo[ownerid][pVSlot][oslot] = 0;

	PlayerInfo[playerid][pTotalVehs]++;
	PlayerInfo[ownerid][pTotalVehs]--;

	GivePlayerMoney(ownerid, VehicleInfo[vid][vSellingPrice]);
	GivePlayerMoney(playerid, -VehicleInfo[vid][vSellingPrice]);
	VehicleInfo[vid][vIsSelling] = false;
	VehicleInfo[vid][vSellingPrice] = 0;

	KillTimer(SellingTimer[ownerid]);

	new vehicleid = GetVehicleID(vid);
	format(string, sizeof(string), "[SERVER]: You have succefully sold your %s to %s.", GetVehicleName(vehicleid), GetName(playerid));
	format(string2, sizeof(string2), "[SERVER]: You have succefully bought a %s from %s, Enjoy your new vehicle.",  GetVehicleName(vehicleid), GetName(ownerid));

	SendClientMessage(ownerid, COLOR_LAWNGREEN, string);
	SendClientMessage(playerid, COLOR_LAWNGREEN, string2);

	SaveVehicle(vid);
	SavePlayer(playerid);
	SavePlayer(ownerid);
	return 1;
}

CMD:vbuyable(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now. ");
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not authorized to use that command..");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle");
	if(VehicleInfo[vid][isOwned]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle is owned by someone.");
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle has been offered to someone.");
	
	new string[15], string2[128];
	if(VehicleInfo[vid][vBuyable]) {
		VehicleInfo[vid][vBuyable] = false;
		strcpy(string, "unbuyable", sizeof(string));
	} else {
		VehicleInfo[vid][vBuyable] = true;
		strcpy(string, "buyable", sizeof(string));
	}

	format(string2, sizeof(string2), "[SERVER]: You have succesfully set this %s as %s", GetVehicleName(vehicleid), string);
	SendClientMessage(playerid, COLOR_LAWNGREEN, string2);
	SaveVehicle(vid);
	return 1;
}

CMD:vsetprice(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not authorized to use that command..");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You need to be in a vehicle to use this command.");
	new vehicleid = GetPlayerVehicleID(playerid);
	new vid = GetVID(vehicleid);
	if(IsTempVehicle(vehicleid)) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This is a temporary vehicle");
	if(VehicleInfo[vid][vIsSelling]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: This vehicle has been offered to someone.");
	
	new price, string[256];
	if(sscanf(params, "d", price)) return SendClientMessage(playerid, COLOR_DODGERBLUE, "[USAGE]: /vsetprice [price]");
	if(price == VehicleInfo[vid][vPrice]){
		new string2[100];
		format(string2, sizeof(string2), "[ERROR]: This cost of this vehicle is already $%d.", VehicleInfo[vid][vPrice]);
		return SendClientMessage(playerid, COLOR_RED, string2);
	}
	if(price < 1) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: Price should be atleast $1");

	VehicleInfo[vid][vPrice] = price;

	format(string, sizeof(string), "[SERVER]: You have succesfully set this %s's price to $%d.", GetVehicleName(vehicleid), price);
	SendClientMessage(playerid, COLOR_LAWNGREEN, string);
	SaveVehicle(vid);
	return 1;
}


CMD:vhelp(playerid, params[]) {
	if(!PlayerInfo[playerid][pAllowed]) return SendClientMessage(playerid, COLOR_RED, "[ERROR]: You are not allowed to use this command right now.");
	new hdialog[1000];
	strcat(hdialog, "{FFD700}/vbuy  - {FFFFFF}buys a vehicle.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vsell - {FFFFFF}sells your vehicle.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vcall - {FFFFFF}calls your vehicle.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vpark - {FFFFFF}parks your vehicle.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vinfo - {FFFFFF}shows vehicle info.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vlist [ID] - {FFFFFF}shows vehicle list.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vplate - {FFFFFF}changes your vehicle plate.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vsellto - {FFFFFF}sells your vehicle to a specific player.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vaccept - {FFFFFF}accepts a vehicle if you've been offered one.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/vsecure - {FFFFFF}secures/unsecures your vehicle.\n", sizeof(hdialog));
	strcat(hdialog, "{FFD700}/clearmods - {FFFFFF}clears your vehicle mods.\n", sizeof(hdialog));

	if(IsPlayerAdmin(playerid)) {
		strcat(hdialog, "\t\t{FFD700}-Admin {FFFFFF}Commands-\n", sizeof(hdialog));
		strcat(hdialog, "{FFD700}/vcreate - {FFFFFF}creates a vehicle.\n", sizeof(hdialog));	
		strcat(hdialog, "{FFD700}/vremove - {FFFFFF}removes a vehicle.\n", sizeof(hdialog));
		strcat(hdialog, "{FFD700}/vbuyable - {FFFFFF}sets a vehicle to buyable/unbuyable.\n", sizeof(hdialog));
		strcat(hdialog, "{FFD700}/vsetprice - {FFFFFF}sets a vehicle price.\n", sizeof(hdialog));
		strcat(hdialog, "{FFD700}/rac - {FFFFFF}respawns all cars.\n", sizeof(hdialog));
		strcat(hdialog, "{FFD700}/vgoto - {FFFFFF}go to a vehicle.\n", sizeof(hdialog));
	}

	ShowPlayerDialog(playerid, DIALOG_VHELP, DIALOG_STYLE_MSGBOX, "{FFD700}Vehicle {FFFFFF}Help", hdialog, "Okay", "");
	return 1;
}