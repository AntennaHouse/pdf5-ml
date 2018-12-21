<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Change-bar generation templates
Copyright © 2009-2018 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf" 
>
    <!-- 
     function:	Generate fo:change-bar-begin, fo:change-bar-end defined in .ditaval revprop
     param:	    None
     return:	
     note:		This template precedes any other template
     -->
    <xsl:template match="*[exists(ancestor::*[contains(@class,' topic/topic ')])]
                          [empty(ancestor::*[contains(@class,' topic/prolog ')])]
                          [empty(ancestor::*[contains(@class,' topic/related-links ')])]
                          [empty(self::*[contains(@class,' topic/indexterm ')])]
                          [empty(self::*[contains(@class,' topic/index-base ')])]
                          [empty(self::*[contains(@class,' topic/fn ')])]
                          " priority="30">
        <xsl:variable name="ditaValChangeBarStyle" as="xs:string" select="string(@change-bar-style)"/>
        <xsl:copy-of select="ahf:genChangeBarBeginElem(.,$ditaValChangeBarStyle)"/>
        <xsl:next-match/>
        <xsl:copy-of select="ahf:genChangeBarEndElem(.,$ditaValChangeBarStyle)"/>
    </xsl:template>

</xsl:stylesheet>
