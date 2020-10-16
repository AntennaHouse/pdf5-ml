readme.txt for com.antennahouse.pdf5.ml.font-config.change plug-in.

This plug-in enables to change AH Formatter font-config.xml for every DITA-OT building.

Usage:

1. font-config file environment variable
  dita command-line
  --ahf.font.config.env=[AH Formatter font-config.xml environment variable name]
  ant command-line
  -Dahf.font.config.env=[AH Formatter font-config.xml environment variable name]

  The default value="AHF70_64_FONT_CONFIGFILE"

2. font-config.xml path
  dita command-line
  --ahf.font.config.file=[AH Formatter font-config.xml path]
  ant command-line
  -Dahf.font.config.file=[AH Formatter font-config.xml path]

  There is no default value. AHFormatter will adopt installation setting.
