<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: User interface elements stylesheet
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
     function:	uicontrol template
     param:	    
     return:	fo:inline
     note:		
     -->
    <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsUiControl'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]" priority="2">
        <xsl:if test="parent::*[contains(@class, ' ui-d/menucascade ')]">
            <!-- Child of menucascade -->
            <xsl:if test="preceding-sibling::*[contains(@class, ' ui-d/uicontrol ')]">
                <!-- preceding uicontrol -->
                <fo:inline>
                    <!-- append '&gt;' -->
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'MenuCascade_Symbol'"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:if>
        </xsl:if>
        <!-- Add prefix and suffix for uicontrol -->
        <fo:inline>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'UiControl_Prefix'"/>
            </xsl:call-template>
            <fo:inline>
                <xsl:call-template name="getAttributeSetWithLang"/>
                <xsl:call-template name="ahf:getUnivAtts"/>
                <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
                <xsl:apply-templates/>
            </fo:inline>
            <xsl:call-template name="getVarValueWithLangAsText">
                <xsl:with-param name="prmVarName" select="'UiControl_Suffix'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	wintitle template
     param:	    
     return:	fo:inline
     note:		
     -->
    <xsl:template match="*[contains(@class, ' ui-d/wintitle ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsWinTitle'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' ui-d/wintitle ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	menucascade template
     param:	    
     return:	fo:inline
     note:		
     -->
    <xsl:template match="*[contains(@class, ' ui-d/menucascade ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsMenuCascade'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' ui-d/menucascade ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:    shortcut template
     param:        
     return:      fo:inline
     note:        shortcut is contained in uicontrol
     -->
    <xsl:template match="*[contains(@class, ' ui-d/shortcut ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsShortcut'"/>
    </xsl:template>    
    
    <xsl:template match="*[contains(@class,' ui-d/shortcut ')]" priority="2">
        <fo:inline>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	screen template
     param:	    
     return:	fo:block
     note:		
     -->
    <xsl:template match="*[contains(@class, ' ui-d/screen ')]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:sequence select="'atsScreen'"/>
    </xsl:template>    

    <xsl:template match="*[contains(@class,' ui-d/screen ')]" priority="2">
        <xsl:variable name="screenAttr" as="attribute()*">
            <xsl:call-template name="getAttributeSetWithLang"/>
        </xsl:variable>
        <fo:block>
            <xsl:copy-of select="$screenAttr"/>
            <xsl:copy-of select="ahf:getDisplayAtts(.,$screenAttr)"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>