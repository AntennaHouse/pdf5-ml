<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet 
    Module: Legacy conversion elements stylesheet
    Copyright © 2009-2011 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <!-- 
     function:	required-cleanup template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:variable name="requiredCleanupTitlePrefix" select="ahf:getVarValue('Required_Cleanup_Title_Prefix')"/>
    <xsl:variable name="requiredCleanupRemap"       select="ahf:getVarValue('Required_Cleanup_Remap')"/>
    <xsl:variable name="requiredCleanupTitleSuffix" select="ahf:getVarValue('Required_Cleanup_Title_Suffix')"/>
    
    <xsl:template match="*[contains-token(@class, 'topic/required-cleanup')]">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsRequiredCleanup')"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSet('atsRequiredCleanupTitle')"/>
                <xsl:value-of select="$requiredCleanupTitlePrefix"/>
                <xsl:if test="string(@remap)">
                    <xsl:value-of select="$requiredCleanupRemap"/>
                    <xsl:value-of select="@remap"/>
                </xsl:if>
                <xsl:value-of select="$requiredCleanupTitleSuffix"/>
            </fo:block>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>