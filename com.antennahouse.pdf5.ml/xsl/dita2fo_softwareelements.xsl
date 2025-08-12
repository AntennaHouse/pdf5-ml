<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet 
    Module: Software elements stylesheet
    Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
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
     function:	msgph template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/msgph ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsMsgPh'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/msgph ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	msgblock template
     param:	    
     return:	fo:block
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/msgblock ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsMsgBlock'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/msgblock ')]" priority="2">
        <xsl:variable name="msgBlockAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:block>
            <xsl:copy-of select="$msgBlockAttr"/>
            <xsl:copy-of select="ahf:getDisplayAtts(.,$msgBlockAttr)"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	msgnum template
     param:
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/msgnum ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsMsgNum'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/msgnum ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    
    <!-- 
     function:	cmdname template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/cmdname ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsCmdName'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/cmdname ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	varname template
     param:	    
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/varname ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsVarName'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/varname ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:  filepath template
     param:
     return:    fo:inline
     note:      none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/filepath ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsFilePath'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' sw-d/filepath ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	userinput template
     param:	    prmTopicRef, prmNeedId
     return:	fo:inline
     note:		none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/userinput ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsUserInput'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/userinput ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:  systemoutput template
     param:	    
     return:    fo:inline
     note:      none
     -->
    <xsl:template match="*[contains(@class, ' sw-d/systemoutput ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsSystemOutput'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' sw-d/systemoutput ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>

</xsl:stylesheet>