<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Typographic elements stylesheet
Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
Antenna House is a trademark of Antenna House, Inc.
URL    : http://www.antennahouse.com/
E-mail : info@antennahouse.com
****************************************************************
-->
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <!-- 
     function:	b template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/b ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsB'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' hi-d/b ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	i template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/i ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsI'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' hi-d/i ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	u template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/u ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsU'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' hi-d/u ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	tt template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/tt ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsTt'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' hi-d/tt ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	sup template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/sup ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSup'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' hi-d/sup ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	sub template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/sub ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSub'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' hi-d/sub ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

    <!-- 
     function:	line-through template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/line-through ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsLineThrough'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' hi-d/line-through ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	line-through template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' hi-d/overline ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsOverLine'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' hi-d/hi-d/overline ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    


</xsl:stylesheet>