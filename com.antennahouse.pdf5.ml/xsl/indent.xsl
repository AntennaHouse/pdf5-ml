<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
  exclude-result-prefixes="xs">
  <xsl:output method="xml" indent="yes"/>
  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:for-each select="@*">
        <xsl:sort select="name()" data-type="text"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
      <xsl:apply-templates/>        
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
