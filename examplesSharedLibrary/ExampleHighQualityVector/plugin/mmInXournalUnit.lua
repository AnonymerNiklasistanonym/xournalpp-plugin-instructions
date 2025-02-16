-- Height of a A4 page in xournal units
local a4PageHeightXournal = 842
-- Height of a A4 page in mm
local a4PageHeightMm = 297
-- Conversion factor of 1mm in xournal units
local mmInXournalUnit = a4PageHeightXournal / a4PageHeightMm

return mmInXournalUnit
