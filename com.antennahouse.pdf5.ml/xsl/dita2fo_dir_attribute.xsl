<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Dir attribute template
Copyright © 2009-2013 Antenna House, Inc. All rights reserved.
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
     function:	@dir attribute processing
     param:	    prmTopicRef, prmNeedId
     return:	fo:bidi-override
     note:	    fo:bidi-override is defined as %inline. If FO processor needs %block context, this template should not work!
                Ex: Child of fo:flow, table elements (colspec,thead,tbody,row,entry,sthead,strow,stentry) are not allowed to generate fo:bidi-override.
                This is checked using ahf:isBidiOverrideAllowedElem() function.
     -->
    <xsl:template match="*[exists(@dir)][ahf:isBidiOverrideAllowedElem(.)]" priority="10">
        <xsl:variable name="dir" as="xs:string" select="string(@dir)"/>
        <xsl:variable name="unicodeBidi" as="xs:string">
            <xsl:choose>
                <xsl:when test="$dir = ('ltr','rtl')">
                    <xsl:sequence select="'embed'"/>
                </xsl:when>
                <xsl:when test="$dir = ('lro','rlo')">
                    <xsl:sequence select="'bidi-override'"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--This case will not occur! -->
                    <xsl:sequence select="'normal'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="direction" as="xs:string">
            <xsl:choose>
                <xsl:when test="$dir = ('ltr','rtl')">
                    <xsl:sequence select="$dir"/>
                </xsl:when>
                <xsl:when test="$dir eq 'lro'">
                    <xsl:sequence select="'ltr'"/>
                </xsl:when>
                <xsl:when test="$dir eq 'rlo'">
                    <xsl:sequence select="'rtl'"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--This case will not occur! -->
                    <xsl:sequence select="'inherit'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:bidi-override unicode-bidi="{$unicodeBidi}" direction="{$direction}">
            <xsl:next-match/>
        </fo:bidi-override>
    </xsl:template>
    
    <!-- 
     function:	Return that generating fo:bidi-override is valid or not.
     param:	    prmElem
     return:	xs:boolaen
     note:	    Element topic sometimes comes as the child of fo:flow. So it is not valid to use @dir for it.
                Another table elements are also invalid.
     -->
    <xsl:function name="ahf:isBidiOverrideAllowedElem" as="xs:boolean">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="class" as="xs:string" select="string($prmElem/@class)"/>
        <xsl:variable name="result" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="contains($class,' topic/colspec ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/thead ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/tbody ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/row ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/entry ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/sthead ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/strow ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/stentry ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="contains($class,' topic/topic ')">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="true()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not($result)">
            <xsl:message select="'[ahf:isBidiOverrideAllowedElem] @dir is not allowed for element=',name($prmElem)"/>
        </xsl:if>
        <xsl:sequence select="$result"/>
    </xsl:function>
    
</xsl:stylesheet>