<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Floating figure module
Copyright © 2009-2012 Antenna House, Inc. All rights reserved.
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
    <!-- This stylesheet expresses an floating image using fig/@float="left/right".
         @float is specialized attribute for fig element.
         Floating image is typically used in task's step by following authoring.
         
         <step>
           <cmd>Command of this step</cmd>
           <info>
             <fig float="left/right" href="...">
               <desc>Description of figure</desc>
               <image placement="break" href="..."/>
             </fig>
           </info>
         </step>
         
         In this case fig is converted into fo:float before <cmd>.
     -->
    <!-- 
     function:  floating figure
     param:     
     return:    fo:float
     note:      This function is experimental.
     -->
    <xsl:template match="*[contains(@class, ' topic/fig ')][ahf:isFloatFig(.)][$pSupportFloatFig]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:variable name="float" as="xs:string" select="string(@float)"/>
        <xsl:choose>
            <xsl:when test="$float eq 'left'">
                <xsl:sequence select="'atsFigFloatLeft'"/>
            </xsl:when>
            <xsl:when test="$float eq 'right'">
                <xsl:sequence select="'atsFigFloatRight'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fig ')][ahf:isFloatFig(.)][$pSupportFloatFig]">
        <fo:float>
            <xsl:attribute name="float" select="string(@float)"/>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:float>
    </xsl:template>

    <!-- 
     function:  Return that the element is floating figure
     param:     prmElement
     return:    xs:boolean
     note:      
     -->
    <xsl:function name="ahf:isFloatFig" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="string($prmElem/@float) = ('left','right')"/>        
    </xsl:function>

    <!-- 
     function:  floating figure group
     param:     
     return:    fo:float
     note:      This function is experimental.
     -->
    <xsl:template match="*[contains(@class, ' topic/figgroup ')][ahf:isFloatFig(.)][$pSupportFloatFig]" mode="MODE_GET_STYLE" as="xs:string*" priority="2">
        <xsl:variable name="float" as="xs:string" select="string(@float)"/>
        <xsl:choose>
            <xsl:when test="$float eq 'left'">
                <xsl:sequence select="'atsFigGroupFloatLeft'"/>
            </xsl:when>
            <xsl:when test="$float eq 'right'">
                <xsl:sequence select="'atsFigGroupFloatRight'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/figgroup ')][ahf:isFloatFig(.)][$pSupportFloatFig]">
        <fo:float>
            <xsl:attribute name="float" select="string(@float)"/>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:float>
    </xsl:template>

</xsl:stylesheet>
