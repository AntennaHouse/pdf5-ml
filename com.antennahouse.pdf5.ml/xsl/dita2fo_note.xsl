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
     function:	note template
     param:	    
     return:	fo:block 
     note:		Treat empty(@type) as @type="note" (2011-11-04 t.makita)
     -->
    <xsl:template match="*[contains(@class, ' topic/note ')]" mode="MODE_GET_STYLE" as="xs:string*">
        <xsl:sequence select="'atsNote'"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' topic/note ')]">
        <xsl:variable name="type" as="xs:string" select="string(@type)"/>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsNoteTitleLine'"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="($type eq 'note') or not(string($type))">
                    <fo:external-graphic>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteNoteIconImage'"/>
                        </xsl:call-template>
                    </fo:external-graphic>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Note_Note'"/>
                    </xsl:call-template>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                </xsl:when>
                <xsl:when test="$type eq 'tip'">
                    <fo:external-graphic>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteTipIconImage'"/>
                        </xsl:call-template>
                    </fo:external-graphic>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Note_Tip'"/>
                    </xsl:call-template>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                </xsl:when>
                <xsl:when test="$type eq 'fastpath'">
                    <fo:external-graphic>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteFastPathIconImage'"/>
                        </xsl:call-template>
                    </fo:external-graphic>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" select="'Note_FastPath'"/>
                    </xsl:call-template>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                </xsl:when>
                <xsl:when test="$type = ('important','restriction','remember','trouble')">
                    <fo:external-graphic>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteImportantIconImage'"/>
                        </xsl:call-template>
                    </fo:external-graphic>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$type eq 'important'"><xsl:sequence select="'Note_Important'"/></xsl:when>
                                <xsl:when test="$type eq 'restriction'"><xsl:sequence select="'Note_Restriction'"/></xsl:when>
                                <xsl:when test="$type eq 'remember'"><xsl:sequence select="'Note_Remember'"/></xsl:when>
                                <xsl:otherwise><xsl:sequence select="'Note_Trouble'"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                </xsl:when>
                <xsl:when test="$type = ('caution','attention','warning','notice','danger')">
                    <fo:external-graphic>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteCautionIconImage'"/>
                        </xsl:call-template>
                    </fo:external-graphic>
                    <xsl:call-template name="getVarValueWithLangAsText">
                        <xsl:with-param name="prmVarName" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$type eq 'caution'"><xsl:sequence select="'Note_Caution'"/></xsl:when>
                                <xsl:when test="$type eq 'attention'"><xsl:sequence select="'Note_Attention'"/></xsl:when>
                                <xsl:when test="$type eq 'warning'"><xsl:sequence select="'Note_Warning'"/></xsl:when>
                                <xsl:when test="$type eq 'notice'"><xsl:sequence select="'Note_Notice'"/></xsl:when>
                                <xsl:otherwise><xsl:sequence select="'Note_Danger'"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                    </xsl:call-template>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                </xsl:when>
                <xsl:when test="$type eq 'other'">
                    <xsl:variable name="otherTitle" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="string(@othertype)">
                                <xsl:sequence select="string(@othertype)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getVarValueWithLang">
                                    <xsl:with-param name="prmVarName" select="'Note_Other'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <fo:external-graphic>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteOtherIconImage'"/>
                        </xsl:call-template>
                    </fo:external-graphic>
                    <xsl:value-of select="$otherTitle"/>
                    <fo:leader>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsNoteLeader'"/>
                        </xsl:call-template>
                    </fo:leader>
                </xsl:when>
            </xsl:choose>
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
    
</xsl:stylesheet>