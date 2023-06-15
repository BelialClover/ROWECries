local currentSpecies = 0
local tempSpecies = 0

--require("luacom")

local Game = {
	new = function (self, game)
		self.__index = self
		setmetatable(game, self)
		return game
	end
}

function Game.getParty(game)
	local party = {}
	local monStart = game._party
	local nameStart = game._partyNames
	local otStart = game._partyOt
	for i = 1, emu:read8(game._partyCount) do
		party[i] = game:_readPartyMon(monStart, nameStart, otStart)
		monStart = monStart + game._partyMonSize
		if game._partyNames then
			nameStart = nameStart + game._monNameLength + 1
		end
		if game._partyOt then
			otStart = otStart + game._playerNameLength + 1
		end
	end
	return party
end

function Game.toString(game, rawstring)
	local string = ""
	for _, char in ipairs({rawstring:byte(1, #rawstring)}) do
		if char == game._terminator then
			break
		end
		string = string..game._charmap[char]
	end
	return string
end

function Game.getSpeciesName(game, id)
	if game._speciesIndex then
		local index = game._index
		if not index then
			index = {}
			for i = 0, 255 do
				index[emu.memory.cart0:read8(game._speciesIndex + i)] = i
			end
			game._index = index
		end
		id = index[id]
	end
	local pointer = game._speciesNameTable + (game._speciesNameLength) * id
	return game:toString(emu.memory.cart0:readRange(pointer, game._monNameLength))
end

local GBGameEn = Game:new{
	_terminator=0x50,
	_monNameLength=10,
	_speciesNameLength=10,
	_playerNameLength=10,
}

local GBAGameEn = Game:new{
	_terminator=0xFF,
	_monNameLength=10,
	_speciesNameLength=11,
	_playerNameLength=10,
}

local Generation1En = GBGameEn:new{
	_boxMonSize=33,
	_partyMonSize=44,
}

local Generation2En = GBGameEn:new{
	_boxMonSize=32,
	_partyMonSize=48,
}

local Generation3En = GBAGameEn:new{
	_boxMonSize=80,
	_partyMonSize=100,
}

GBGameEn._charmap = { [0]=
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", " ",
	"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P",
	"Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "(", ")", ":", ";", "[", "]",
	"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p",
	"q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "é", "ʼd", "ʼl", "ʼs", "ʼt", "ʼv",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�", "�",
	"'", "P\u{200d}k", "M\u{200d}n", "-", "ʼr", "ʼm", "?", "!", ".", "ァ", "ゥ", "ェ", "▹", "▸", "▾", "♂",
	"$", "×", ".", "/", ",", "♀", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
}

GBAGameEn._charmap = { [0]=
	" ", "À", "Á", "Â", "Ç", "È", "É", "Ê", "Ë", "Ì", "こ", "Î", "Ï", "Ò", "Ó", "Ô",
	"Œ", "Ù", "Ú", "Û", "Ñ", "ß", "à", "á", "ね", "ç", "è", "é", "ê", "ë", "ì", "ま",
	"î", "ï", "ò", "ó", "ô", "œ", "ù", "ú", "û", "ñ", "º", "ª", "�", "&", "+", "あ",
	"ぃ", "ぅ", "ぇ", "ぉ", "v", "=", "ょ", "が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ",
	"ぞ", "だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ", "ぱ", "ぴ", "ぷ", "ぺ", "ぽ",
	"っ", "¿", "¡", "P\u{200d}k", "M\u{200d}n", "P\u{200d}o", "K\u{200d}é", "�", "�", "�", "Í", "%", "(", ")", "セ", "ソ",
	"タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "â", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "í",
	"ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "⬆", "⬇", "⬅", "➡", "ヲ", "ン", "ァ",
	"ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", "ジ", "ズ", "ゼ",
	"ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", "ビ", "ブ", "ベ", "ボ", "パ", "ピ", "プ", "ペ", "ポ",
	"ッ", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "!", "?", ".", "-", "・",
	"…", "“", "”", "‘", "’", "♂", "♀", "$", ",", "×", "/", "A", "B", "C", "D", "E",
	"F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "Tread8", "U",
	"V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k",
	"l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "▶",
	":", "Ä", "Ö", "Ü", "ä", "ö", "ü", "⬆", "⬇", "⬅", "�", "�", "�", "�", "�", ""
}

function _read16BE(emu, address)
	return (emu:read8(address) << 8) | emu:read8(address + 1)
end

function Generation1En._readBoxMon(game, address, nameAddress, otAddress)
	local mon = {}
	mon.species = emu.memory.cart0:read8(game._speciesIndex + emu:read8(address + 0) - 1)
	mon.hp = _read16BE(emu, address + 1)
	mon.level = emu:read8(address + 3)
	mon.status = emu:read8(address + 4)
	mon.type1 = emu:read8(address + 5)
	mon.type2 = emu:read8(address + 6)
	mon.catchRate = emu:read8(address + 7)
	mon.moves = {
		emu:read8(address + 8),
		emu:read8(address + 9),
		emu:read8(address + 10),
		emu:read8(address + 11),
	}
	mon.otId = _read16BE(emu, address + 12)
	mon.experience = (_read16BE(emu, address + 14) << 8)| emu:read8(address + 16)
	mon.hpEV = _read16BE(emu, address + 17)
	mon.attackEV = _read16BE(emu, address + 19)
	mon.defenseEV = _read16BE(emu, address + 21)
	mon.speedEV = _read16BE(emu, address + 23)
	mon.spAttackEV = _read16BE(emu, address + 25)
	mon.spDefenseEV = mon.spAttackEv
	local iv = _read16BE(emu, address + 27)
	mon.attackIV = (iv >> 4) & 0xF
	mon.defenseIV = iv & 0xF
	mon.speedIV = (iv >> 12) & 0xF
	mon.spAttackIV = (iv >> 8) & 0xF
	mon.spDefenseIV = mon.spAttackIV
	mon.pp = {
		emu:read8(address + 28),
		emu:read8(address + 29),
		emu:read8(address + 30),
		emu:read8(address + 31),
	}
	mon.nickname = game:toString(emu:readRange(nameAddress, game._monNameLength))
	mon.otName = game:toString(emu:readRange(otAddress, game._playerNameLength))
	return mon
end

function Generation1En._readPartyMon(game, address, nameAddress, otAddress)
	local mon = game:_readBoxMon(address, nameAddress, otAddress)
	mon.level = emu:read8(address + 33)
	mon.maxHP = _read16BE(emu, address + 34)
	mon.attack = _read16BE(emu, address + 36)
	mon.defense = _read16BE(emu, address + 38)
	mon.speed = _read16BE(emu, address + 40)
	mon.spAttack = _read16BE(emu, address + 42)
	mon.spDefense = mon.spAttack
	return mon
end

function Generation2En._readBoxMon(game, address, nameAddress, otAddress)
	local mon = {}
	mon.species = emu:read8(address + 0)
	mon.item = emu:read8(address + 1)
	mon.moves = {
		emu:read8(address + 2),
		emu:read8(address + 3),
		emu:read8(address + 4),
		emu:read8(address + 5),
	}
	mon.otId = _read16BE(emu, address + 6)
	mon.experience = (_read16BE(emu, address + 8) << 8)| emu:read8(address + 10)
	mon.hpEV = _read16BE(emu, address + 11)
	mon.attackEV = _read16BE(emu, address + 13)
	mon.defenseEV = _read16BE(emu, address + 15)
	mon.speedEV = _read16BE(emu, address + 17)
	mon.spAttackEV = _read16BE(emu, address + 19)
	mon.spDefenseEV = mon.spAttackEv
	local iv = _read16BE(emu, address + 21)
	mon.attackIV = (iv >> 4) & 0xF
	mon.defenseIV = iv & 0xF
	mon.speedIV = (iv >> 12) & 0xF
	mon.spAttackIV = (iv >> 8) & 0xF
	mon.spDefenseIV = mon.spAttackIV
	mon.pp = {
		emu:read8(address + 23),
		emu:read8(address + 24),
		emu:read8(address + 25),
		emu:read8(address + 26),
	}
	mon.friendship = emu:read8(address + 27)
	mon.pokerus = emu:read8(address + 28)
	local caughtData = _read16BE(emu, address + 29)
	mon.metLocation = (caughtData >> 8) & 0x7F
	mon.metLevel = caughtData & 0x1F
	mon.level = emu:read8(address + 31)
	mon.nickname = game:toString(emu:readRange(nameAddress, game._monNameLength))
	mon.otName = game:toString(emu:readRange(otAddress, game._playerNameLength))
	return mon
end

function Generation2En._readPartyMon(game, address, nameAddress, otAddress)
	local mon = game:_readBoxMon(address, nameAddress, otAddress)
	mon.status = emu:read8(address + 32)
	mon.hp = _read16BE(emu, address + 34)
	mon.maxHP = _read16BE(emu, address + 36)
	mon.attack = _read16BE(emu, address + 38)
	mon.defense = _read16BE(emu, address + 40)
	mon.speed = _read16BE(emu, address + 42)
	mon.spAttack = _read16BE(emu, address + 44)
	mon.spDefense = _read16BE(emu, address + 46)
	return mon
end

function Generation3En._readBoxMon(game, address)
	local mon = {}
	mon.personality = emu:read32(address + 0)
	mon.otId = emu:read32(address + 4)
	mon.nickname = game:toString(emu:readRange(address + 8, game._monNameLength))
	mon.language = emu:read8(address + 18)
	local flags = emu:read8(address + 19)
	mon.isBadEgg = flags & 1
	mon.hasSpecies = (flags >> 1) & 1
	mon.isEgg = (flags >> 2) & 1
	mon.otName = game:toString(emu:readRange(address + 20, game._playerNameLength))
	mon.markings = emu:read8(address + 27)

	local key = mon.otId ~ mon.personality
	local substructSelector = {
		[ 0] = {0, 1, 2, 3},
		[ 1] = {0, 1, 3, 2},
		[ 2] = {0, 2, 1, 3},
		[ 3] = {0, 3, 1, 2},
		[ 4] = {0, 2, 3, 1},
		[ 5] = {0, 3, 2, 1},
		[ 6] = {1, 0, 2, 3},
		[ 7] = {1, 0, 3, 2},
		[ 8] = {2, 0, 1, 3},
		[ 9] = {3, 0, 1, 2},
		[10] = {2, 0, 3, 1},
		[11] = {3, 0, 2, 1},
		[12] = {1, 2, 0, 3},
		[13] = {1, 3, 0, 2},
		[14] = {2, 1, 0, 3},
		[15] = {3, 1, 0, 2},
		[16] = {2, 3, 0, 1},
		[17] = {3, 2, 0, 1},
		[18] = {1, 2, 3, 0},
		[19] = {1, 3, 2, 0},
		[20] = {2, 1, 3, 0},
		[21] = {3, 1, 2, 0},
		[22] = {2, 3, 1, 0},
		[23] = {3, 2, 1, 0},
	}

	local pSel = substructSelector[mon.personality % 24]
	local ss0 = {}
	local ss1 = {}
	local ss2 = {}
	local ss3 = {}

	for i = 0, 2 do
		ss0[i] = emu:read32(address + 32 + pSel[1] * 12 + i * 4) ~ key
		ss1[i] = emu:read32(address + 32 + pSel[2] * 12 + i * 4) ~ key
		ss2[i] = emu:read32(address + 32 + pSel[3] * 12 + i * 4) ~ key
		ss3[i] = emu:read32(address + 32 + pSel[4] * 12 + i * 4) ~ key
	end

	mon.species = ss0[0] & 0xFFFF
	mon.heldItem = ss0[0] >> 16
	mon.experience = ss0[1]
	mon.ppBonuses = ss0[2] & 0xFF
	mon.friendship = (ss0[2] >> 8) & 0xFF

	mon.moves = {
		ss1[0] & 0xFFFF,
		ss1[0] >> 16,
		ss1[1] & 0xFFFF,
		ss1[1] >> 16
	}
	mon.pp = {
		ss1[2] & 0xFF,
		(ss1[2] >> 8) & 0xFF,
		(ss1[2] >> 16) & 0xFF,
		ss1[2] >> 24
	}

	mon.hpEV = ss2[0] & 0xFF
	mon.attackEV = (ss2[0] >> 8) & 0xFF
	mon.defenseEV = (ss2[0] >> 16) & 0xFF
	mon.speedEV = ss2[0] >> 24
	mon.spAttackEV = ss2[1] & 0xFF
	mon.spDefenseEV = (ss2[1] >> 8) & 0xFF
	mon.cool = (ss2[1] >> 16) & 0xFF
	mon.beauty = ss2[1] >> 24
	mon.cute = ss2[2] & 0xFF
	mon.smart = (ss2[2] >> 8) & 0xFF
	mon.tough = (ss2[2] >> 16) & 0xFF
	mon.sheen = ss2[2] >> 24

	mon.pokerus = ss3[0] & 0xFF
	mon.metLocation = (ss3[0] >> 8) & 0xFF
	flags = ss3[0] >> 16
	mon.metLevel = flags & 0x7F
	mon.metGame = (flags >> 7) & 0xF
	mon.pokeball = (flags >> 11) & 0xF
	mon.otGender = (flags >> 15) & 0x1
	flags = ss3[1]
	mon.hpIV = flags & 0x1F
	mon.attackIV = (flags >> 5) & 0x1F
	mon.defenseIV = (flags >> 10) & 0x1F
	mon.speedIV = (flags >> 15) & 0x1F
	mon.spAttackIV = (flags >> 20) & 0x1F
	mon.spDefenseIV = (flags >> 25) & 0x1F
	-- Bit 30 is another "isEgg" bit
	mon.altAbility = (flags >> 31) & 1
	flags = ss3[2]
	mon.coolRibbon = flags & 7
	mon.beautyRibbon = (flags >> 3) & 7
	mon.cuteRibbon = (flags >> 6) & 7
	mon.smartRibbon = (flags >> 9) & 7
	mon.toughRibbon = (flags >> 12) & 7
	mon.championRibbon = (flags >> 15) & 1
	mon.winningRibbon = (flags >> 16) & 1
	mon.victoryRibbon = (flags >> 17) & 1
	mon.artistRibbon = (flags >> 18) & 1
	mon.effortRibbon = (flags >> 19) & 1
	mon.marineRibbon = (flags >> 20) & 1
	mon.landRibbon = (flags >> 21) & 1
	mon.skyRibbon = (flags >> 22) & 1
	mon.countryRibbon = (flags >> 23) & 1
	mon.nationalRibbon = (flags >> 24) & 1
	mon.earthRibbon = (flags >> 25) & 1
	mon.worldRibbon = (flags >> 26) & 1
	mon.eventLegal = (flags >> 27) & 0x1F
	return mon
end

function Generation3En._readPartyMon(game, address)
	local mon = game:_readBoxMon(address)
	mon.status = emu:read32(address + 80)
	mon.level = emu:read8(address + 84)
	mon.mail = emu:read32(address + 85)
	mon.hp = emu:read16(address + 86)
	mon.maxHP = emu:read16(address + 88)
	mon.attack = emu:read16(address + 90)
	mon.defense = emu:read16(address + 92)
	mon.speed = emu:read16(address + 94)
	mon.spAttack = emu:read16(address + 96)
	mon.spDefense = emu:read16(address + 98)
	return mon
end

local gameRBEn = Generation1En:new{
	name="Red/Blue (USA)",
	_party=0xd16b,
	_partyCount=0xd163,
	_partyNames=0xd2b5,
	_partyOt=0xd273,
	_speciesNameTable=0x1c21e,
	_speciesIndex=0x41024,
}

local gameYellowEn = Generation1En:new{
	name="Yellow (USA)",
	_party=0xd16a,
	_partyCount=0xd162,
	_partyNames=0xd2b4,
	_partyOt=0xd272,
	_speciesNameTable=0xe8000,
	_speciesIndex=0x410b1,
}

local gameGSEn = Generation2En:new{
	name="Gold/Silver (USA)",
	_party=0xda2a,
	_partyCount=0xda22,
	_partyNames=0xdb8c,
	_partyOt=0xdb4a,
	_speciesNameTable=0x1b0b6a,
}

local gameCrystalEn = Generation2En:new{
	name="Crystal (USA)",
	_party=0xdcdf,
	_partyCount=0xdcd7,
	_partyNames=0xde41,
	_partyOt=0xddff,
	_speciesNameTable=0x5337a,
}

local gameRubyEn = Generation3En:new{
	name="Ruby (USA)",
	_party=0x3004360,
	_partyCount=0x3004350,
	_speciesNameTable=0x1f716c,
}

local gameRubyEnR1 = Generation3En:new{
	name="Ruby (USA)",
	_party=0x3004360,
	_partyCount=0x3004350,
	_speciesNameTable=0x1f7184,
}

local gameSapphireEn = Generation3En:new{
	name="Sapphire (USA)",
	_party=0x3004360,
	_partyCount=0x3004350,
	_speciesNameTable=0x1f70fc,
}

local gameSapphireEnR1 = Generation3En:new{
	name="Sapphire (USA)",
	_party=0x3004360,
	_partyCount=0x3004350,
	_speciesNameTable=0x1f7114,
}

local gameEmeraldEn = Generation3En:new{
	name="Emerald (USA)",
	_party=0x20244ec,
	_partyCount=0x20244e9,
	_speciesNameTable=0x3185c8,
}

local gameFireRedEn = Generation3En:new{
	name="FireRed (USA)",
	_party=0x2024284,
	_partyCount=0x2024029,
	_speciesNameTable=0x245ee0,
}

local gameFireRedEnR1 = gameFireRedEn:new{
	name="FireRed (USA) (Rev 1)",
	_speciesNameTable=0x245f50,
}

local gameLeafGreenEn = Generation3En:new{
	name="LeafGreen (USA)",
	_party=0x2024284,
	_partyCount=0x2024029,
	_speciesNameTable=0x245ebc,
}

local gameLeafGreenEnR1 = gameLeafGreenEn:new{
	name="LeafGreen (USA)",
	_party=0x2024284,
	_partyCount=0x2024029,
	_speciesNameTable=0x245f2c,
}

gameCodes = {
	["DMG-AAUE"]=gameGSEn, -- Gold
	["DMG-AAXE"]=gameGSEn, -- Silver
	["CGB-BYTE"]=gameCrystalEn,
	["AGB-AXVE"]=gameRubyEn,
	["AGB-AXPE"]=gameSapphireEn,
	["AGB-BPEE"]=gameEmeraldEn,
	["AGB-BPRE"]=gameFireRedEn,
	["AGB-BPGE"]=gameLeafGreenEn,
}

-- These versions have slight differences and/or cannot be uniquely
-- identified by their in-header game codes, so fall back on a CRC32
gameCrc32 = {
	[0x9f7fdd53] = gameRBEn, -- Red
	[0xd6da8a1a] = gameRBEn, -- Blue
	[0x7d527d62] = gameYellowEn,
	[0x84ee4776] = gameFireRedEnR1,
	[0xdaffecec] = gameLeafGreenEnR1,
	[0x61641576] = gameRubyEnR1, -- Rev 1
	[0xaeac73e6] = gameRubyEnR1, -- Rev 2
	[0xbafedae5] = gameSapphireEnR1, -- Rev 1
	[0x9cc4410e] = gameSapphireEnR1, -- Rev 2
}

function printPartyStatus(game, buffer)
	buffer:clear()
	for _, mon in ipairs(game:getParty()) do
		buffer:print(string.format("%-10s (Lv%3i %10s): %3i/%3i\n",
			mon.nickname,
			mon.level,
			game:getSpeciesName(mon.species),
			mon.hp,
			mon.maxHP))
	end
end

function detectGame()
	local checksum = 0
	for i, v in ipairs({emu:checksum(C.CHECKSUM.CRC32):byte(1, 4)}) do
		checksum = checksum * 256 + v
	end
	game = gameCrc32[checksum]
	if not game then
		game = gameCodes[emu:getGameCode()]
	end

	if not game then
		console:error("Unknown game!")
	else
		console:log("Found game: " .. game.name)
		if not partyBuffer then
			partyBuffer = console:createBuffer("Party")
		end
	end
end

--this is the filename of each cry
speciesNames = {
	[0] = ("??????????"),
    [1] = ("bulbasaur"),
    [2] = ("ivysaur"),
    [3] = ("venusaur"),
    [4] = ("charmander"),
    [5] = ("charmeleon"),
    [6] = ("charizard"),
    [7] = ("squirtle"),
    [8] = ("wartortle"),
    [9] = ("blastoise"),
    [10] = ("caterpie"),
    [11] = ("metapod"),
    [12] = ("butterfree"),
    [13] = ("weedle"),
    [14] = ("kakuna"),
    [15] = ("beedrill"),
    [16] = ("pidgey"),
    [17] = ("pidgeotto"),
    [18] = ("pidgeot"),
    [19] = ("rattata"),
    [20] = ("raticate"),
    [21] = ("spearow"),
    [22] = ("fearow"),
    [23] = ("ekans"),
    [24] = ("arbok"),
    [25] = ("pikachu"),
    [26] = ("raichu"),
    [27] = ("sandshrew"),
    [28] = ("sandslash"),
    [29] = ("nidoran♀"),
    [30] = ("nidorina"),
    [31] = ("nidoqueen"),
    [32] = ("nidoran♂"),
    [33] = ("nidorino"),
    [34] = ("nidoking"),
    [35] = ("clefairy"),
    [36] = ("clefable"),
    [37] = ("vulpix"),
    [38] = ("ninetales"),
    [39] = ("jigglypuff"),
    [40] = ("wigglytuff"),
    [41] = ("zubat"),
    [42] = ("golbat"),
    [43] = ("oddish"),
    [44] = ("gloom"),
    [45] = ("vileplume"),
    [46] = ("paras"),
    [47] = ("parasect"),
    [48] = ("venonat"),
    [49] = ("venomoth"),
    [50] = ("diglett"),
    [51] = ("dugtrio"),
    [52] = ("meowth"),
    [53] = ("persian"),
    [54] = ("psyduck"),
    [55] = ("golduck"),
    [56] = ("mankey"),
    [57] = ("primeape"),
    [58] = ("growlithe"),
    [59] = ("arcanine"),
    [60] = ("poliwag"),
    [61] = ("poliwhirl"),
    [62] = ("poliwrath"),
    [63] = ("abra"),
    [64] = ("kadabra"),
    [65] = ("alakazam"),
    [66] = ("machop"),
    [67] = ("machoke"),
    [68] = ("machamp"),
    [69] = ("bellsprout"),
    [70] = ("weepinbell"),
    [71] = ("victreebel"),
    [72] = ("tentacool"),
    [73] = ("tentacruel"),
    [74] = ("geodude"),
    [75] = ("graveler"),
    [76] = ("golem"),
    [77] = ("ponyta"),
    [78] = ("rapidash"),
    [79] = ("slowpoke"),
    [80] = ("slowbro"),
    [81] = ("magnemite"),
    [82] = ("magneton"),
    [83] = ("farfetch'd"),
    [84] = ("doduo"),
    [85] = ("dodrio"),
    [86] = ("seel"),
    [87] = ("dewgong"),
    [88] = ("grimer"),
    [89] = ("muk"),
    [90] = ("shellder"),
    [91] = ("cloyster"),
    [92] = ("gastly"),
    [93] = ("haunter"),
    [94] = ("gengar"),
    [95] = ("onix"),
    [96] = ("drowzee"),
    [97] = ("hypno"),
    [98] = ("krabby"),
    [99] = ("kingler"),
    [100] = ("voltorb"),
    [101] = ("electrode"),
    [102] = ("exeggcute"),
    [103] = ("exeggutor"),
    [104] = ("cubone"),
    [105] = ("marowak"),
    [106] = ("hitmonlee"),
    [107] = ("hitmonchan"),
    [108] = ("lickitung"),
    [109] = ("koffing"),
    [110] = ("weezing"),
    [111] = ("rhyhorn"),
    [112] = ("rhydon"),
    [113] = ("chansey"),
    [114] = ("tangela"),
    [115] = ("kangaskhan"),
    [116] = ("horsea"),
    [117] = ("seadra"),
    [118] = ("goldeen"),
    [119] = ("seaking"),
    [120] = ("staryu"),
    [121] = ("starmie"),
    [122] = ("mr. mime"),
    [123] = ("scyther"),
    [124] = ("jynx"),
    [125] = ("electabuzz"),
    [126] = ("magmar"),
    [127] = ("pinsir"),
    [128] = ("tauros"),
    [129] = ("magikarp"),
    [130] = ("gyarados"),
    [131] = ("lapras"),
    [132] = ("ditto"),
    [133] = ("eevee"),
    [134] = ("vaporeon"),
    [135] = ("jolteon"),
    [136] = ("flareon"),
    [137] = ("porygon"),
    [138] = ("omanyte"),
    [139] = ("omastar"),
    [140] = ("kabuto"),
    [141] = ("kabutops"),
    [142] = ("aerodactyl"),
    [143] = ("snorlax"),
    [144] = ("articuno"),
    [145] = ("zapdos"),
    [146] = ("moltres"),
    [147] = ("dratini"),
    [148] = ("dragonair"),
    [149] = ("dragonite"),
    [150] = ("mewtwo"),
    [151] = ("mew"),
    [152] = ("chikorita"),
    [153] = ("bayleef"),
    [154] = ("meganium"),
    [155] = ("cyndaquil"),
    [156] = ("quilava"),
    [157] = ("typhlosion"),
    [158] = ("totodile"),
    [159] = ("croconaw"),
    [160] = ("feraligatr"),
    [161] = ("sentret"),
    [162] = ("furret"),
    [163] = ("hoothoot"),
    [164] = ("noctowl"),
    [165] = ("ledyba"),
    [166] = ("ledian"),
    [167] = ("spinarak"),
    [168] = ("ariados"),
    [169] = ("crobat"),
    [170] = ("chinchou"),
    [171] = ("lanturn"),
    [172] = ("pichu"),
    [173] = ("cleffa"),
    [174] = ("igglybuff"),
    [175] = ("togepi"),
    [176] = ("togetic"),
    [177] = ("natu"),
    [178] = ("xatu"),
    [179] = ("mareep"),
    [180] = ("flaaffy"),
    [181] = ("ampharos"),
    [182] = ("bellossom"),
    [183] = ("marill"),
    [184] = ("azumarill"),
    [185] = ("sudowoodo"),
    [186] = ("politoed"),
    [187] = ("hoppip"),
    [188] = ("skiploom"),
    [189] = ("jumpluff"),
    [190] = ("aipom"),
    [191] = ("sunkern"),
    [192] = ("sunflora"),
    [193] = ("yanma"),
    [194] = ("wooper"),
    [195] = ("quagsire"),
    [196] = ("umbreon"),
    [197] = ("murkrow"),
    [198] = ("slowking"),
    [199] = ("misdreavus"),
    [200] = ("unown"),
    [201] = ("wobbuffet"),
    [202] = ("girafarig"),
    [203] = ("pineco"),
    [204] = ("forretress"),
    [205] = ("dunsparce"),
    [206] = ("gligar"),
    [207] = ("steelix"),
    [208] = ("snubbull"),
    [209] = ("granbull"),
    [210] = ("qwilfish"),
	[211] = ("qwilfish"),
    [212] = ("scizor"),
    [213] = ("shuckle"),
    [214] = ("heracross"),
    [215] = ("sneasel"),
    [216] = ("teddiursa"),
    [217] = ("ursaring"),
    [218] = ("slugma"),
    [219] = ("magcargo"),
    [220] = ("swinub"),
    [221] = ("piloswine"),
    [222] = ("corsola"),
    [223] = ("remoraid"),
    [224] = ("octillery"),
    [225] = ("delibird"),
    [226] = ("mantine"),
    [227] = ("skarmory"),
    [228] = ("houndour"),
    [229] = ("houndoom"),
    [230] = ("kingdra"),
    [231] = ("phanpy"),
    [232] = ("donphan"),
    [233] = ("porygon2"),
    [234] = ("stantler"),
    [235] = ("smeargle"),
    [236] = ("tyrogue"),
    [237] = ("hitmontop"),
    [238] = ("smoochum"),
    [239] = ("elekid"),
    [240] = ("magby"),
    [241] = ("miltank"),
    [242] = ("blissey"),
    [243] = ("raikou"),
    [244] = ("entei"),
    [245] = ("suicune"),
    [246] = ("larvitar"),
    [247] = ("pupitar"),
    [248] = ("tyranitar"),
    [249] = ("lugia"),
    [250] = ("ho-oh"),
    [251] = ("celebi"),
    [252] = ("treecko"),
    [253] = ("grovyle"),
    [254] = ("sceptile"),
    [255] = ("torchic"),
    [256] = ("combusken"),
    [257] = ("blaziken"),
    [258] = ("mudkip"),
    [259] = ("marshtomp"),
    [260] = ("swampert"),
    [261] = ("poochyena"),
    [262] = ("mightyena"),
    [263] = ("zigzagoon"),
    [264] = ("linoone"),
    [265] = ("wurmple"),
    [266] = ("silcoon"),
    [267] = ("beautifly"),
    [268] = ("cascoon"),
    [269] = ("dustox"),
    [270] = ("lotad"),
    [271] = ("lombre"),
    [272] = ("ludicolo"),
    [273] = ("seedot"),
    [274] = ("nuzleaf"),
    [275] = ("shiftry"),
    [276] = ("taillow"),
    [277] = ("swellow"),
    [278] = ("wingull"),
    [279] = ("pelipper"),
    [280] = ("ralts"),
    [281] = ("kirlia"),
    [282] = ("gardevoir"),
    [283] = ("surskit"),
    [284] = ("masquerain"),
    [285] = ("shroomish"),
    [286] = ("breloom"),
    [287] = ("slakoth"),
    [288] = ("vigoroth"),
    [289] = ("slaking"),
    [290] = ("nincada"),
    [291] = ("ninjask"),
    [292] = ("shedinja"),
    [293] = ("whismur"),
    [294] = ("loudred"),
    [295] = ("exploud"),
    [296] = ("makuhita"),
    [297] = ("hariyama"),
    [298] = ("azurill"),
    [299] = ("nosepass"),
    [300] = ("skitty"),
    [301] = ("delcatty"),
    [302] = ("sableye"),
    [303] = ("mawile"),
    [304] = ("aron"),
    [305] = ("lairon"),
    [306] = ("aggron"),
    [307] = ("meditite"),
    [308] = ("medicham"),
    [309] = ("electrike"),
    [310] = ("manectric"),
    [311] = ("plusle"),
    [312] = ("minun"),
    [313] = ("volbeat"),
    [314] = ("illumise"),
    [315] = ("roselia"),
    [316] = ("gulpin"),
    [317] = ("swalot"),
    [318] = ("carvanha"),
    [319] = ("sharpedo"),
    [320] = ("wailmer"),
    [321] = ("wailord"),
    [322] = ("numel"),
    [323] = ("camerupt"),
    [324] = ("torkoal"),
    [325] = ("spoink"),
    [326] = ("grumpig"),
    [327] = ("spinda"),
    [328] = ("trapinch"),
    [329] = ("vibrava"),
    [330] = ("flygon"),
    [331] = ("cacnea"),
    [332] = ("cacturne"),
    [333] = ("swablu"),
    [334] = ("altaria"),
    [335] = ("zangoose"),
    [336] = ("seviper"),
    [337] = ("lunatone"),
    [338] = ("solrock"),
    [339] = ("barboach"),
    [340] = ("whiscash"),
    [341] = ("corphish"),
    [342] = ("crawdaunt"),
    [343] = ("baltoy"),
    [344] = ("claydol"),
    [345] = ("lileep"),
    [346] = ("cradily"),
    [347] = ("anorith"),
    [348] = ("armaldo"),
    [349] = ("feebas"),
    [350] = ("milotic"),
    [351] = ("castform"),
    [352] = ("kecleon"),
    [353] = ("shuppet"),
    [354] = ("banette"),
    [355] = ("duskull"),
    [356] = ("dusclops"),
    [357] = ("tropius"),
    [358] = ("chimecho"),
    [359] = ("absol"),
    [360] = ("wynaut"),
    [361] = ("snorunt"),
    [362] = ("glalie"),
    [363] = ("spheal"),
    [364] = ("sealeo"),
    [365] = ("walrein"),
    [366] = ("clamperl"),
    [367] = ("huntail"),
    [368] = ("gorebyss"),
    [369] = ("relicanth"),
    [370] = ("luvdisc"),
    [371] = ("bagon"),
    [372] = ("shelgon"),
    [373] = ("salamence"),
    [374] = ("beldum"),
    [375] = ("metang"),
    [376] = ("metagross"),
    [377] = ("regirock"),
    [378] = ("regice"),
    [379] = ("registeel"),
    [380] = ("latias"),
    [381] = ("latios"),
    [382] = ("kyogre"),
    [383] = ("groudon"),
    [384] = ("rayquaza"),
    [385] = ("jirachi"),
    [386] = ("deoxys"),
    [387] = ("turtwig"),
    [388] = ("grotle"),
    [389] = ("torterra"),
    [390] = ("chimchar"),
    [391] = ("monferno"),
    [392] = ("infernape"),
    [393] = ("piplup"),
    [394] = ("prinplup"),
    [395] = ("empoleon"),
    [396] = ("starly"),
    [397] = ("staravia"),
    [398] = ("staraptor"),
    [399] = ("bidoof"),
    [400] = ("bibarel"),
    [401] = ("kricketot"),
    [402] = ("kricketune"),
    [403] = ("shinx"),
    [404] = ("luxio"),
    [405] = ("luxray"),
    [406] = ("budew"),
}

--this is run a lot of times
function detectCry()
	local cryaddress = 0x02000080
	local cryspecies = emu:read16(cryaddress)
	local species = speciesNames[cryspecies]

	if cryspecies == currentSpecies or cryspecies > 407 or cryspecies == 0 or cryspecies == 1 then
		species = speciesNames[0]
	else
		--os.execute("start smplayer " .. script.dir .. "/" .. species .. ".mp3")
		os.execute("start smplayer F:/Github/ROWECries/" .. species .. ".mp3")
		--os.execute("start https://play.pokemonshowdown.com/audio/cries/" .. species .. ".mp3")
		currentSpecies = cryspecies
		wait(6000)
	end
end

function printMonName(species, buffer)
	buffer:clear()
	buffer:print(string.format("%-10s\n", species))
end

function printWelcomeMessage(buffer)
	buffer:clear()
	buffer:print(string.format("Welcome to R.O.W.E. Cries make sure you set up the game correctly."))
end

function updateBuffer()
	if not game or not partyBuffer then
		return
	end
	printPartyStatus(game, partyBuffer)
end

callbacks:add("start", detectGame)
callbacks:add("frame", detectCry)
if emu then
	--this is run first
	if not welcomeBuffer then
		welcomeBuffer = console:createBuffer("Welcome")
	end
	printWelcomeMessage(welcomeBuffer)
end
