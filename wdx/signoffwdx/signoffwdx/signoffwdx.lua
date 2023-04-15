-- signoffwdx.lua (cross-platform)
-- 2023.04.14

require('read_write_csvfile_to_dict')

local CSVDict = {}

local fields = {
  "Signoff By",
  "Reviewed By",
  "Approved By"
}

function ContentGetSupportedField(FieldIndex)
  if fields[FieldIndex + 1] ~= nil then
    return fields[FieldIndex + 1], "", 8
  end
  return "", "", 0
end

function ContentGetDefaultSortOrder(FieldIndex)
  return 1; 
end

function ContentGetDetectString()
  return 'EXT="*"'
end

function ContentGetValue(FileName, FieldIndex, UnitIndex, flags)
  if flags == 1 then return nil end;
  -- hiddenPath = DC.GetActivePanelPath() .. '\\' .. "dblcmd_hidden"
  local sn = debug.getinfo(1).source
  if string.sub(sn, 1, 1) == '@' then sn = string.sub(sn, 2, -1) end
  fname = string.lower(fields[FieldIndex + 1])
  fname = string.gsub(fname, " ", "_")
  local dbName = SysUtils.ExtractFilePath(sn) .. fname .. '.csv'
  if CSVDict[fields[FieldIndex + 1]] == nil then
    CSVDict[fields[FieldIndex + 1]] = ReadCSVFileToDict(dbName)
  else
    if os.getenv('SignOffDB') == 'Read' then
      CSVDict[fields[FieldIndex + 1]] = ReadCSVFileToDict(dbName)
      os.setenv('SignOffDB', 'Done')
    end
  end
  if CSVDict[fields[FieldIndex + 1]][FileName] ~= nil then
    return CSVDict[fields[FieldIndex + 1]][FileName]
  end
  return nil
end

