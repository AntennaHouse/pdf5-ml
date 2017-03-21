<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Text mode templates
Copyright © 2009-2017 Antenna House, Inc. All rights reserved.
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
    
    <!-- ======================================================================
          Text-only templates
          Ignore tm and required-cleanup when called from convmerged.xsl's
          glossary sorting.
          2017-03-13 t.makita
         ======================================================================
     -->
    
    <!-- * -->
    <xsl:template match="*" mode="TEXT_ONLY">
        <xsl:apply-templates mode="TEXT_ONLY"/>
    </xsl:template>
    
    <!-- text -->
    <!-- Removed normalization when $prmGetIndextermKey=true().
         2014-09-27 t.makita
     -->
    <xsl:template match="text()" mode="TEXT_ONLY">
        <xsl:param name="prmGetIndextermKey" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:param name="prmGetIndexSeeKey" required="no" tunnel="yes" as="xs:boolean" select="false()"/>
        <xsl:choose>
            <xsl:when test="$prmGetIndextermKey">
                <!--xsl:value-of select="normalize-space(.)"/-->
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="$prmGetIndexSeeKey">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- fn -->
    <xsl:template match="*[contains(@class,' topic/fn ')]" mode="TEXT_ONLY">
    </xsl:template>
    
    <!-- tm -->
    <xsl:template match="*[contains(@class,' topic/tm ')]" mode="TEXT_ONLY">
        <xsl:apply-templates mode="TEXT_ONLY"/>
        <xsl:variable name="tmType" as="xs:string" select="string(@tmtype)"/>
        <xsl:choose>
            <xsl:when test="$tmType eq 'tm'">
                <xsl:variable name="tmSymbolTmText" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Tm_Symbol_Tm_Text'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$tmSymbolTmText"/>
            </xsl:when>
            <xsl:when test="$tmType eq 'reg'">
                <xsl:variable name="tmSymbolRegText" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Tm_Symbol_Reg_Text'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$tmSymbolRegText"/>
            </xsl:when>
            <xsl:when test="$tmType eq 'service'">
                <xsl:variable name="tmSymbolServiceText" as="xs:string">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Tm_Symbol_Service_Text'"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="$tmSymbolServiceText"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- data-about -->
    <xsl:template match="*[contains(@class,' topic/data-about ')]" mode="TEXT_ONLY">
    </xsl:template>
    
    <!-- data -->
    <xsl:template match="*[contains(@class,' topic/data ')]" mode="TEXT_ONLY">
    </xsl:template>
    
    <!-- foreign -->
    <xsl:template match="*[contains(@class,' topic/foreign ')]" mode="TEXT_ONLY">
    </xsl:template>
    
    <!-- unknown -->
    <xsl:template match="*[contains(@class,' topic/unknown ')]" mode="TEXT_ONLY">
    </xsl:template>
    
    <!-- no-topic-nesting -->
    <xsl:template match="*[contains(@class,' topic/no-topic-nesting ')]" mode="TEXT_ONLY">
    </xsl:template>
    
    <!-- indexterm is coded in dita2fo_indexcommon.xsl -->
    
    <!-- required-cleanup -->
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')]" mode="TEXT_ONLY"/>
    
    <!-- state -->
    <xsl:template match="*[contains(@class,' topic/state ')]" mode="TEXT_ONLY">
        <xsl:value-of select="@name"/>
        <xsl:text>=</xsl:text>
        <xsl:value-of select="@value"/>
    </xsl:template>
    
    <!-- boolean -->
    <xsl:template match="*[contains(@class,' topic/boolean ')]" mode="TEXT_ONLY">
        <xsl:value-of select="@state"/>
    </xsl:template>
    
</xsl:stylesheet>
