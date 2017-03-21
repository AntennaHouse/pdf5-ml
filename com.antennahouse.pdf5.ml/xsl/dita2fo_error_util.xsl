<?xml version="1.0" encoding="UTF-8" ?>
<!--
**************************************************************
DITA to XSL-FO Stylesheet
Error processing Templates
**************************************************************
File Name : dita2fo_error_util.xsl
**************************************************************
Copyright © 2009 2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL : http://www.antennahouse.co.jp/
**************************************************************
-->

<xsl:stylesheet version="2.0" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
 	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf" >
    
    <!--
    ===============================================
     Error processing
    ===============================================
    -->
    <!-- 
     function:	Error Exit routine
     param:		prmMes: message body
     return:	none
     note:		none
    -->
    <xsl:template name="errorExit">
    	<xsl:param name="prmMes" required="yes" as="xs:string"/>
    	<xsl:message terminate="yes"><xsl:value-of select="$prmMes"/></xsl:message>
    </xsl:template>
    
    <!-- 
     function:	Warning display routine
     param:		prmMes: message body
     return:	none
     note:		none
    -->
    <xsl:template name="warningContinue">
    	<xsl:param name="prmMes" required="yes" as="xs:string"/>
    	<xsl:message terminate="no"><xsl:value-of select="$prmMes"/></xsl:message>
    </xsl:template>
    
    <!-- end of stylesheet -->
</xsl:stylesheet>
