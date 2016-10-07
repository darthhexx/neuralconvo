local IrcDialogs = torch.class("neuralconvo.IrcDialogs")
local stringx = require "pl.stringx"
local xlua = require "xlua"

local TOTAL_LINES = 542008

local function parsedLines(file, fields)
	local f = assert(io.open(file, 'r'))

  return function()
    local line = f:read("*line")

    if line == nil then
      f:close()
      return
    end

    -- local values = stringx.split(line, " -:-~-:- ")
    local values = stringx.split( line, " +++$+++ ")
    local t = {}

    for i,field in ipairs(fields) do
      t[field] = values[i]
    end

    return t
  end
end

function IrcDialogs:__init(dir)
        self.dir = dir
end

local function progress(c)
	if c % 10000 == 0 then
		xlua.progress(c, TOTAL_LINES)
		collectgarbage()
	end
end

local DATASET_FIELDS = {"conv_id", "character_id", "movie_id", "character","text"}

function IrcDialogs:load()
	local lines = {}
	local conversations = {}
	local conversation = {}
	local count = 0
	local currenConvID = 0

	print("Parsing IRC conversation...")

	for conv in parsedLines(self.dir .. "/cornell_movie_dialogs/movie_lines.txt", DATASET_FIELDS) do
		if prevConvID ~= conv.conv_id then
			if #conversation > 0 then
				table.insert(conversations, conversation)
				conversation = {}
			end
			prevConvID = conv.conv_id
		end
		conv.conv_id = nil
		table.insert(conversation, conv)
		count = count + 1
		progress(count)
	end

 	xlua.progress(TOTAL_LINES, TOTAL_LINES)

	return conversations
end

