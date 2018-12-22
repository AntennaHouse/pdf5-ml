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
                          [empty(self::*[contains(@class, ' topic/colspec ')])]
                          " priority="50">
        <xsl:copy-of select="ahf:genChangeBarBeginElem(.)"/>
        <xsl:next-match/>
        <xsl:copy-of select="ahf:genChangeBarEndElem(.)"/>
    </xsl:template>
    
    <!-- 
     function:	Generate fo:chage-bar-begin from ditaval-startprop/revprop/@changebar attribute
     param:		prmElem
     return:	element()?
     note:		
     -->
    <xsl:function name="ahf:genChangeBarBeginElem" as="element()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="ditaValChangeBarStyle" as="xs:string" select="string($prmElem/@change-bar-style)"/>
        <xsl:choose>
            <xsl:when test="string($ditaValChangeBarStyle)">
                <fo:change-bar-begin>
                    <xsl:for-each select="tokenize($ditaValChangeBarStyle, ';')">
                        <xsl:variable name="propDesc" select="normalize-space(string(.))"/>
                        <xsl:choose>
                            <xsl:when test="not(string($propDesc))"/>
                            <xsl:when test="contains($propDesc,':')">
                                <xsl:variable name="propName" as="xs:string">
                                    <xsl:variable name="tempPropName" as="xs:string" select="substring-before($propDesc,':')"/>
                                    <xsl:variable name="axfExt" as="xs:string" select="'axf-'"/>
                                    <xsl:variable name="ahsExt" as="xs:string" select="'ahs-'"/>
                                    <xsl:choose>
                                        <xsl:when test="starts-with($tempPropName,$axfExt)">
                                            <xsl:sequence select="concat('axf:',substring-after($tempPropName,$axfExt))"/>
                                        </xsl:when>
                                        <xsl:when test="starts-with($tempPropName,$ahsExt)">
                                            <xsl:sequence select="''"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:sequence select="$tempPropName"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>                            
                                <xsl:variable name="propValue" as="xs:string" select="normalize-space(substring-after($propDesc,':'))"/>
                                <xsl:attribute name="{$propName}" select="$propValue"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:sequence select="()"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                    <xsl:attribute name="change-bar-class" select="ahf:generateHistoryId($prmElem)"/>
                </fo:change-bar-begin>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="ahf:genChangeBarEndElem" as="element()?">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="ditaValChangeBarStyle" as="xs:string" select="string($prmElem/@change-bar-style)"/>
        <xsl:choose>
            <xsl:when test="string($ditaValChangeBarStyle)">
                <fo:change-bar-end>
                    <xsl:attribute name="change-bar-class" select="ahf:generateHistoryId($prmElem)"/>
                </fo:change-bar-end>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
