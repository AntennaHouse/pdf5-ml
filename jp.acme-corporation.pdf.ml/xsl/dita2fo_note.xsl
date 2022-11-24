<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet 
    Module: Note element stylesheet
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
    xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
    xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
    exclude-result-prefixes="xs ahf"
    >
    <!-- 
     function:  Special note template
     param:
     return:    fo:block 
     note:      Testing use only
     -->
    <xsl:template match="*[contains(@class, ' topic/note ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsNote'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/note ')][string(@type) eq 'warning'][ahf:hasOutputClassValue(.,'test')]">
        <xsl:variable name="type" as="xs:string" select="string(@type)"/>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsNoteTitleLine'"/>
            </xsl:call-template>
            <fo:external-graphic>
                <xsl:attribute name="src">
                    <xsl:call-template name="getVarValueWithLang">
                        <xsl:with-param name="prmVarName" select="'Warninng_Icon'"/>
                    </xsl:call-template>
                </xsl:attribute>
            </fo:external-graphic>
            <fo:leader>
                <xsl:call-template name="getAttributeSetWithLang">
                    <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                </xsl:call-template>
            </fo:leader>
        </fo:block>
        <!--Note body -->
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <xsl:apply-templates/>
        </fo:block>
        <!-- line after -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsNoteAfterBlock')"/>
            <xsl:value-of select="'&#x00A0;'"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' topic/ph ')][ahf:hasOutputClassValue(.,'warning-title')]" priority="10">
        <xsl:variable name="warningLiteral" as="xs:string">
            <xsl:call-template name="getVarValueWithLang">
                <xsl:with-param name="prmVarName" select="'Note_Warning'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="$warningLiteral"/>
    </xsl:template>
    
</xsl:stylesheet>