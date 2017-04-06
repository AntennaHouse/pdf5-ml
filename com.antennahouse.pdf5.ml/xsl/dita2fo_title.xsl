<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Generate title module.
Copyright © 2009-2011 Antenna House, Inc. All rights reserved.
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
     function:	Get topic title generation mode
     param:		prmTopicRref,prmTopicContent
     return:	cRoundBulletTitleMode, cSquareBulletTitleMode, cNoRestrictionTitleMode
     note:		
     -->
    <xsl:function name="ahf:getTitleMode" as="xs:integer">
        <xsl:param name="prmTopicRef"  as="element()"/>
        <xsl:param name="prmTopicContent"  as="element()?"/>
        
        <!--xsl:variable name="isNoToc" select="boolean($prmTopicRef/@toc='no')"/-->
        <xsl:variable name="isNoToc" select="ahf:isTocNo($prmTopicRef)"/>
        <!--xsl:variable name="hasNoTocAncestor" select="boolean($prmTopicRef/ancestor::*[contains(@class,' map/topicref ')][@toc='no'])"/-->
        <xsl:variable name="hasNoTocAncestor" select="boolean($prmTopicRef/ancestor::*[contains(@class,' map/topicref ')][ahf:isTocNo(.)])"/>
        <xsl:variable name="isNestedTopic" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="empty($prmTopicContent)">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="$prmTopicContent/ancestor::*[contains(@class, ' topic/topic ')]">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$hasNoTocAncestor">
                <xsl:value-of select="$cRoundBulletTitleMode"/>
            </xsl:when>
            <xsl:when test="$isNoToc">
                <xsl:choose>
                    <xsl:when test="$isNestedTopic">
                        <xsl:value-of select="$cRoundBulletTitleMode"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$cSquareBulletTitleMode"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$isNestedTopic">
                        <xsl:value-of select="$cSquareBulletTitleMode"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$cNoRestrictionTitleMode"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- 
     function:	Heading generation template for frontmatter
     param:		prmLevel, prmTopicRef, prmTopicContent
     return:	title contents
     note:		
     -->
    <xsl:template name="genFrontmatterTitle">
        <xsl:param name="prmLevel"        required="yes" as="xs:integer"/>
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        <xsl:param name="prmDefaultTitle" required="no" as="xs:string" tunnel="yes" select="''"/>
        
        <xsl:variable name="attrSetName" as="xs:string">
            <xsl:choose>
                <xsl:when test="$prmLevel eq 1">
                    <xsl:sequence select="'atsFmHeader1'"/>
                </xsl:when>
                <xsl:when test="$prmLevel eq 2">
                    <xsl:sequence select="'atsFmHeader2'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'atsFmHeader3'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($prmTopicContent)">
                <xsl:variable name="titleElement" select="$prmTopicContent/*[contains(@class, ' topic/title ')][1]"/>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="$attrSetName"/>
                        <xsl:with-param name="prmElem" select="$titleElement"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getIdAtts($titleElement,$prmTopicRef,true())"/>
                    <xsl:copy-of select="ahf:getLocalizationAtts($titleElement)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($titleElement)"/>
                    <xsl:call-template name="processIndextermInMetadata">
                        <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:apply-templates select="$titleElement">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicTitleStyle" tunnel="yes" select="$attrSetName"/>
                    </xsl:apply-templates>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="$attrSetName"/>
                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:call-template name="processIndextermInMetadata">
                        <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent"  select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                            <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNavTitleStyle" tunnel="yes" select="$attrSetName"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/@navtitle">
                            <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$prmDefaultTitle"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Heading generation template for backmatter
     param:		prmLevel, prmTopicRef, prmTopicContent
     return:	title contents
     note:		Same as frontmatter
     -->
    <xsl:template name="genBackmatterTitle">
        <xsl:param name="prmLevel"        required="yes" as="xs:integer"/>
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
    
        <xsl:call-template name="genFrontmatterTitle">
            <xsl:with-param name="prmLevel" select="$prmLevel"/>
            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
     function:	Heading generation template for part/chapter
     param:		prmTopicRef, prmTopicContent
     return:	title contents
     note:		
     -->
    <xsl:template name="genChapterTitle">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <!-- Nesting level in the bookmap -->
        <xsl:variable name="level" select="count($prmTopicRef/ancestor-or-self::*[contains(@class, ' map/topicref ')])"/>
        <!-- Title prefix -->
        <xsl:variable name="titlePrefix">
            <xsl:call-template name="genTitlePrefix">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="attrSetName" as="xs:string">
            <xsl:choose>
                <xsl:when test="$level eq 1">
                    <xsl:sequence select="'atsChapterHead1'"/>
                </xsl:when>
                <xsl:when test="$level eq 2">
                    <xsl:sequence select="'atsChapterHead2'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'atsChapterHead3'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($prmTopicContent)">
                <xsl:variable name="titleElement" as="element()" select="$prmTopicContent/child::*[contains(@class, ' topic/title ')][1]"/>
                <xsl:variable name="titleForMarker" as="node()*">
                    <xsl:apply-templates select="$titleElement" mode="GET_CONTENTS">
                        <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="$attrSetName"/>
                        <xsl:with-param name="prmElem" select="$titleElement"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getIdAtts($titleElement,$prmTopicRef,true())"/>
                    <xsl:copy-of select="ahf:getLocalizationAtts($titleElement)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($titleElement)"/>
                    <xsl:if test="($level eq 1) or ($level eq 2)">
                        <xsl:if test="$pAddNumberingTitlePrefix">
                            <fo:marker marker-class-name="{$cTitlePrefix}">
                                <fo:inline><xsl:value-of select="$titlePrefix"/></fo:inline>
                            </fo:marker>
                        </xsl:if>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline>
                                <!-- This fo:marker is used only for making the running header in fo:region-after.
                                     The font-family is assumed serif.
                                     So style name become temporary "atsChapterRegionAfterBlock"
                                     2015-08-22 t.makita
                                     The style of fo:marker is defined at fo:retrieve-marker.
                                     This function call only returns font-family.
                                     2015-08-22 t.makita
                                  -->
                                <xsl:copy-of select="ahf:getFontFamlyWithLang('atsChapterRegionAfterBlock',$titleElement)"/>
                                <xsl:copy-of select="$titleForMarker"/>
                            </fo:inline>
                        </fo:marker>
                    </xsl:if>
                    <xsl:call-template name="processIndextermInMetadata">
                        <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:if test="$pAddNumberingTitlePrefix">
                        <xsl:value-of select="$titlePrefix"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="$titleElement">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicTitleStyle" tunnel="yes" select="$attrSetName"/>
                    </xsl:apply-templates>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="titleForMarker" as="node()*">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                            <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]" mode="GET_CONTENTS">
                                <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/@navtitle">
                            <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="$attrSetName"/>
                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:if test="($level eq 1) or ($level eq 2)">
                        <xsl:if test="$pAddNumberingTitlePrefix">
                            <fo:marker marker-class-name="{$cTitlePrefix}">
                                <fo:inline><xsl:value-of select="$titlePrefix"/></fo:inline>
                            </fo:marker>
                        </xsl:if>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsChapterRegionAfterBlock'"/>
                                    <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                    <xsl:with-param name="prmDoInherit" select="true()"/>
                                    <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                                </xsl:call-template>
                                <xsl:copy-of select="$titleForMarker"/>
                            </fo:inline>
                        </fo:marker>
                    </xsl:if>
                    <xsl:call-template name="processIndextermInMetadata">
                        <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent"  select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:if test="$pAddNumberingTitlePrefix">
                        <xsl:value-of select="$titlePrefix"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                            <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNavTitleStyle" tunnel="yes" select="$attrSetName"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/@navtitle">
                            <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                        </xsl:when>
                    </xsl:choose>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Heading title template
     param:		
     return:	title contents
     note:		
     -->
    <xsl:template match="*[contains(@class, ' topic/title ')]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- 
     function:	Heading generation template for appendix
     param:		prmTopicRef, prmTopicContent
     return:	title contents
     note:		
      -->
    <xsl:template name="genAppendixTitle">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <!-- Nesting level in the bookmap -->
        <xsl:variable name="level" as="xs:integer" select="count($prmTopicRef/ancestor-or-self::*[contains(@class, ' map/topicref ')])"/>
    
        <!-- Title prefix -->
        <xsl:variable name="titlePrefix">
            <xsl:call-template name="genTitlePrefix">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="attrSetName" as="xs:string">
            <xsl:choose>
                <xsl:when test="$level eq 1">
                    <xsl:sequence select="'atsAppendixHead1'"/>
                </xsl:when>
                <xsl:when test="$level eq 2">
                    <xsl:sequence select="'atsAppendixHead2'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="'atsAppendixHead3'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="exists($prmTopicContent)">
                <!--title -->
                <xsl:variable name="titleElement" as="element()" select="$prmTopicContent/child::*[contains(@class, ' topic/title ')][1]"/>
                <xsl:variable name="titleForMarker" as="node()*">
                    <xsl:apply-templates select="$titleElement" mode="GET_CONTENTS">
                        <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="$attrSetName"/>
                        <xsl:with-param name="prmElem" select="$titleElement"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getIdAtts($titleElement,$prmTopicRef,true())"/>
                    <xsl:copy-of select="ahf:getLocalizationAtts($titleElement)"/>
                    <xsl:copy-of select="ahf:getFoStyleAndProperty($titleElement)"/>
                    <xsl:if test="($level eq 1) or ($level eq 2)">
                        <xsl:if test="$pAddNumberingTitlePrefix">
                            <fo:marker marker-class-name="{$cTitlePrefix}">
                                <fo:inline><xsl:value-of select="$titlePrefix"/></fo:inline>
                            </fo:marker>
                        </xsl:if>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsChapterRegionAfterBlock'"/>
                                    <xsl:with-param name="prmElem" select="$titleElement"/>
                                    <xsl:with-param name="prmDoInherit" select="true()"/>
                                    <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                                </xsl:call-template>
                                <xsl:copy-of select="$titleForMarker"/>
                            </fo:inline>
                        </fo:marker>
                    </xsl:if>
                    <xsl:call-template name="processIndextermInMetadata">
                        <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:if test="$pAddNumberingTitlePrefix">
                        <xsl:value-of select="$titlePrefix"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:apply-templates select="$titleElement">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicTitleStyle" tunnel="yes" select="$attrSetName"/>
                    </xsl:apply-templates>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="titleForMarker" as="node()*">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                            <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]" mode="GET_CONTENTS">
                                <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/@navtitle">
                            <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                        </xsl:when>
                    </xsl:choose>
                </xsl:variable>
                <fo:block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="$attrSetName"/>
                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:if test="($level eq 1) or ($level eq 2)">
                        <xsl:if test="$pAddNumberingTitlePrefix">
                            <fo:marker marker-class-name="{$cTitlePrefix}">
                                <xsl:value-of select="$titlePrefix"/>
                            </fo:marker>
                        </xsl:if>
                        <fo:marker marker-class-name="{$cTitleBody}">
                            <fo:inline>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsChapterRegionAfterBlock'"/>
                                    <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                    <xsl:with-param name="prmDoInherit" select="true()"/>
                                    <xsl:with-param name="prmRequiredProperty" tunnel="yes" select="('font-family')"/>
                                </xsl:call-template>
                                <xsl:copy-of select="$titleForMarker"/>
                            </fo:inline>
                        </fo:marker>
                    </xsl:if>
                    <xsl:call-template name="processIndextermInMetadata">
                        <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                    </xsl:call-template>
                    <xsl:if test="$pAddNumberingTitlePrefix">
                        <xsl:value-of select="$titlePrefix"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                            <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                <xsl:with-param name="prmNavTitleStyle" tunnel="yes" select="$attrSetName"/>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/@navtitle">
                            <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                        </xsl:when>
                    </xsl:choose>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
        function:	Heading generation template for appendices
        param:		prmTopicRef, prmTopicContent
        return:	    title contents
        note:		This template is inttended for appendices[not(@href)] element.
                    Deprecated. 2015-01-20 t.makita
    -->
    <!--xsl:template name="genAppendicesTitle">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsAppendixHead1')"/>
            <xsl:copy-of select="ahf:getIdAtts($prmTopicRef,$prmTopicRef,true())"/>
            <xsl:copy-of select="ahf:getLocalizationAtts($prmTopicRef)"/>
            <fo:marker marker-class-name="{$cTitleBody}">
                <xsl:choose>
                    <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                        <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]" mode="GET_CONTENTS">
                            <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                            <xsl:with-param name="prmNeedId"   select="false()"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="$prmTopicRef/@navtitle">
                        <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="ahf:getVarValue('Appendices_Title')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:marker>
            <xsl:call-template name="processIndextermInMetadata">
                <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
            </xsl:call-template>
            <xsl:choose>
                <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                    <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmNeedId"   select="true()"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:when test="$prmTopicRef/@navtitle">
                    <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ahf:getVarValue('Appendices_Title')"></xsl:value-of>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template-->
    
    <!-- 
     function:	Square bullet heading generation 
     param:		prmTopicRef, prmTopicContent
     return:	title contents
     note:		for nested topic/concept/task/reference or toc="no" specified contents
     -->
    <xsl:template name="genSquareBulletTitle">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
    
        <xsl:choose>
            <xsl:when test="exists($prmTopicContent)">
                <xsl:variable name="titleElement" select="$prmTopicContent/child::*[contains(@class, ' topic/title ')][1]"/>
                <fo:list-block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsHeader4List'"/>
                        <xsl:with-param name="prmElem" select="$titleElement"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getIdAtts($titleElement,$prmTopicRef,true())"/>
                    <xsl:copy-of select="ahf:getLocalizationAtts($titleElement)"/>
                    <fo:list-item>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsHeader4ListItem'"/>
                            <xsl:with-param name="prmElem" select="$titleElement"/>
                        </xsl:call-template>
                        <fo:list-item-label end-indent="label-end()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader4Label'"/>
                                    <xsl:with-param name="prmElem" select="$titleElement"/>
                                </xsl:call-template>
                                <xsl:call-template name="processIndextermInMetadata">
                                    <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                                    <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                                </xsl:call-template>
                                <fo:inline>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsHeader4LabelInline'"/>
                                        <xsl:with-param name="prmElem" select="$titleElement"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="getVarValueWithLangAsText">
                                        <xsl:with-param name="prmVarName" select="'Level4_Label_Char'"/>
                                        <xsl:with-param name="prmElem" select="$titleElement"/>
                                    </xsl:call-template>
                                </fo:inline>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader4Body'"/>
                                    <xsl:with-param name="prmElem" select="$titleElement"/>
                                </xsl:call-template>
                                <xsl:copy-of select="ahf:getFoStyleAndProperty($titleElement)"/>
                                <xsl:apply-templates select="$titleElement">
                                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                    <xsl:with-param name="prmTopicTitleStyle" tunnel="yes" select="'atsHeader4Body'"/>
                                </xsl:apply-templates>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsHeader4List'"/>
                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <fo:list-item>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsHeader4ListItem'"/>
                            <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        </xsl:call-template>
                        <fo:list-item-label end-indent="label-end()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader4Label'"/>
                                    <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                </xsl:call-template>
                                <xsl:call-template name="processIndextermInMetadata">
                                    <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                                    <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                                </xsl:call-template>
                                <fo:inline>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsHeader4LabelInline'"/>
                                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="getVarValueWithLangAsText">
                                        <xsl:with-param name="prmVarName" select="'Level4_Label_Char'"/>
                                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                    </xsl:call-template>
                                </fo:inline>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader4Body'"/>
                                    <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                </xsl:call-template>
                                <xsl:choose>
                                    <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                        <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                            <xsl:with-param name="prmNavTitleStyle" tunnel="yes" select="'atsHeader4Body'"/>
                                        </xsl:apply-templates>
                                    </xsl:when>
                                    <xsl:when test="$prmTopicRef/@navtitle">
                                        <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                                    </xsl:when>
                                </xsl:choose>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Round bullet heading generation 
     param:		prmTopicRef, prmTopicContent
     return:	Title contents
     note:
      -->
    <xsl:template name="genRoundBulletTitle">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <xsl:choose>
            <xsl:when test="exists($prmTopicContent)">
                <xsl:variable name="titleElement" select="$prmTopicContent/child::*[contains(@class, ' topic/title ')][1]"/>
                <fo:list-block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsHeader5List'"/>
                        <xsl:with-param name="prmElem" select="$titleElement"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <xsl:copy-of select="ahf:getIdAtts($titleElement,$prmTopicRef,true())"/>
                    <xsl:copy-of select="ahf:getLocalizationAtts($titleElement)"/>
                    <fo:list-item>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsHeader5ListItem'"/>
                            <xsl:with-param name="prmElem" select="$titleElement"/>
                        </xsl:call-template>
                        <fo:list-item-label end-indent="label-end()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader5Label'"/>
                                    <xsl:with-param name="prmElem" select="$titleElement"/>
                                </xsl:call-template>
                                <xsl:call-template name="processIndextermInMetadata">
                                    <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                                    <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                                </xsl:call-template>
                                <fo:inline>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsHeader5LabelInline'"/>
                                        <xsl:with-param name="prmElem" select="$titleElement"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="getVarValueWithLangAsText">
                                        <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                        <xsl:with-param name="prmElem" select="$titleElement"/>
                                    </xsl:call-template>
                                </fo:inline>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader5Body'"/>
                                    <xsl:with-param name="prmElem" select="$titleElement"/>
                                </xsl:call-template>
                                <xsl:copy-of select="ahf:getFoStyleAndProperty($titleElement)"/>
                                <xsl:apply-templates select="$titleElement">
                                    <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                    <xsl:with-param name="prmTopicTitleStyle" tunnel="yes" select="'atsHeader5Body'"/>
                                </xsl:apply-templates>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </xsl:when>
            <xsl:otherwise>
                <fo:list-block>
                    <xsl:call-template name="getAttributeSetWithLang">
                        <xsl:with-param name="prmAttrSetName" select="'atsHeader5List'"/>
                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        <xsl:with-param name="prmDoInherit" select="true()"/>
                    </xsl:call-template>
                    <fo:list-item>
                        <xsl:call-template name="getAttributeSetWithLang">
                            <xsl:with-param name="prmAttrSetName" select="'atsHeader5ListItem'"/>
                            <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                        </xsl:call-template>
                        <fo:list-item-label end-indent="label-end()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader5Label'"/>
                                    <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                </xsl:call-template>
                                <xsl:call-template name="processIndextermInMetadata">
                                    <xsl:with-param name="prmTopicRef"      select="$prmTopicRef"/>
                                    <xsl:with-param name="prmTopicContent" select="$prmTopicContent"/>
                                </xsl:call-template>
                                <fo:inline>
                                    <xsl:call-template name="getAttributeSetWithLang">
                                        <xsl:with-param name="prmAttrSetName" select="'atsHeader5LabelInline'"/>
                                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                    </xsl:call-template>
                                    <xsl:call-template name="getVarValueWithLangAsText">
                                        <xsl:with-param name="prmVarName" select="'Level5_Label_Char'"/>
                                        <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                    </xsl:call-template>
                                </fo:inline>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <fo:block>
                                <xsl:call-template name="getAttributeSetWithLang">
                                    <xsl:with-param name="prmAttrSetName" select="'atsHeader5Body'"/>
                                    <xsl:with-param name="prmElem" select="$prmTopicRef"/>
                                </xsl:call-template>
                                <xsl:choose>
                                    <xsl:when test="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                        <xsl:apply-templates select="$prmTopicRef/*[contains(@class,' map/topicmeta ')]/*[contains(@class,' topic/navtitle ')]">
                                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$prmTopicRef"/>
                                            <xsl:with-param name="prmNavTitleStyle" tunnel="yes" select="'atsHeader5Body'"/>
                                        </xsl:apply-templates>
                                    </xsl:when>
                                    <xsl:when test="$prmTopicRef/@navtitle">
                                        <xsl:value-of select="$prmTopicRef/@navtitle"/>        
                                    </xsl:when>
                                </xsl:choose>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Generate fo:marker from topichead/topicref element
     param:		prmTopicRef (topichead or topicref)
     return:	fo:marker
     note:		Deprecated
     -->
    <xsl:template name="makeMarker">
        <xsl:param name="prmTopicRef"     required="yes" as="element()"/>
        
        <!-- Title prefix -->
        <xsl:variable name="titlePrefix">
            <xsl:call-template name="genTitlePrefix">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
            </xsl:call-template>
        </xsl:variable>
    
        <!-- title -->
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="not($prmTopicRef/@href)">
                    <xsl:value-of select="$prmTopicRef/@navtitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="id" select="substring-after($prmTopicRef/@href, '#')"/>
                    <xsl:variable name="topicContent" select="key('topicById', $id)[1]"/>
                    <xsl:apply-templates select="$topicContent/*[contains(@class, ' topic/title ')]" mode="GET_CONTENTS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:if test="$pAddNumberingTitlePrefix">
            <fo:marker marker-class-name="{$cTitlePrefix}">
                <fo:inline><xsl:value-of select="$titlePrefix"/></fo:inline>
            </fo:marker>
        </xsl:if>
        <fo:marker marker-class-name="{$cTitleBody}">
            <fo:inline><xsl:copy-of select="$title"/></fo:inline>
        </fo:marker>
    </xsl:template>

    <!-- 
     function:	Generate prefix of title
     param:		prmTopicRef
     return:	prefix of title 
     note:		none
     -->
    <xsl:template name="genTitlePrefix" as="xs:string">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        
        <xsl:variable name="prefixPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/frontmatter ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/part ')]">
                            <xsl:sequence select="$cPartTitlePrefix"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/chapter ')]">
                            <xsl:sequence select="$cChapterTitlePrefix"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/appendix ')]">
                            <xsl:sequence select="$cAppendixTitle"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- May be appendice -->
                            <xsl:sequence select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- map -->
                    <xsl:sequence select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="suffixPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/frontmatter ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/part ')]">
                            <xsl:sequence select="$cPartTitleSuffix"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/chapter ')]">
                            <xsl:sequence select="$cChapterTitleSuffix"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/self::*[contains(@class, ' bookmap/appendix ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- May be appendice -->
                            <xsl:sequence select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- map -->
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="numberPart" as="xs:string">
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:choose>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/frontmatter ')]">
                            <xsl:sequence select="''"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/part ')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/chapter ')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]">
                            <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                        </xsl:when>
                        <xsl:when test="$prmTopicRef/ancestor::*[contains(@class, ' bookmap/backmatter ')]">
                            <xsl:value-of select="''"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- May be appendice -->
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <!-- map -->
                    <xsl:sequence select="ahf:genLevelTitlePrefix($prmTopicRef)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="result" select="concat($prefixPart,$numberPart,$suffixPart)"/>
        <xsl:sequence select="$result"/>
    </xsl:template>

    <!-- 
     function:	Generate level of topicref
     param:		prmTopicRef
     return:	xs:string 
     note:		none
     -->
    <xsl:function name="ahf:genLevelTitlePrefix" as="xs:string">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="ancestorOrSelfTopicRef" as="element()*" select="$prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/appendices '))]"/>
        <xsl:variable name="levelString" as="xs:string*" select="ahf:getSibilingTopicrefCount($ancestorOrSelfTopicRef)"/>
        <xsl:sequence select="string-join($levelString,'')"/>
    </xsl:function>

    <!-- 
     function:	Generate level of topicref
     param:		prmTopicRef,prmCutLimit
     return:	xs:string 
     note:		Ancestor or self of $prmTopicref will be cut by $prmCutLevel level.
                This function is used for table & fig numbering title prefix.
                2014-09-16 t.makita
     -->
    <xsl:function name="ahf:genLevelTitlePrefixByCount" as="xs:string">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmCutLimit" as="xs:integer"/>
        <xsl:variable name="ancestorOrSelfTopicRef" as="element()*" select="($prmTopicRef/ancestor-or-self::*[contains(@class,' map/topicref ')][not(contains(@class,' bookmap/appendices '))])[position() le $prmCutLimit]"/>
        <xsl:variable name="levelString" as="xs:string*" select="ahf:getSibilingTopicrefCount($ancestorOrSelfTopicRef)"/>
        <xsl:sequence select="string-join($levelString,'')"/>
    </xsl:function>

    <!-- 
     function:	Get preceding-sibling topicref count
     param:		prmTopicRef
     return:	xs:string* 
     note:		topicref/@toc="no" is not counted.
                Fix topicref counting bug.
                2015-08-07 t.makita
     -->
    <xsl:function name="ahf:getSibilingTopicrefCount" as="xs:string*">
        <xsl:param name="prmTopicRefs" as="element()*"/>
        <xsl:choose>
            <xsl:when test="exists($prmTopicRefs[1])">
                <xsl:variable name="topicRef" as="element()" select="$prmTopicRefs[1]"/>
                <xsl:variable name="precedingCountStr" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$topicRef[contains(@class, ' bookmap/part ')]">
                            <xsl:variable name="partCount" as="xs:integer" select="count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][contains(@class, ' bookmap/part ')][ahf:isToc(.)]|$topicRef)"/>
                            <xsl:variable name="partCountFormat" as="xs:string" select="ahf:getVarValue('Part_Count_Format')"/>
                            <xsl:number format="{$partCountFormat}" value="$partCount"/>
                        </xsl:when>
                        <xsl:when test="$topicRef[contains(@class, ' bookmap/chapter ')][empty(parent::*[contains(@class, ' bookmap/part ')])]">
                            <xsl:variable name="chapterCount" as="xs:integer" select="count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][contains(@class, ' bookmap/chapter ')][ahf:isToc(.)]|$topicRef)"/>
                            <xsl:variable name="chapterCountFormat" as="xs:string" select="ahf:getVarValue('Chapter_Count_Format')"/>
                            <xsl:number format="{$chapterCountFormat}" value="$chapterCount"/>
                        </xsl:when>
                        <xsl:when test="$topicRef[contains(@class, ' bookmap/appendix ')]">
                            <xsl:variable name="appendixCount" select="count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][contains(@class, ' bookmap/appendix ')][ahf:isToc(.)]|$topicRef)"/>
                            <xsl:variable name="appendixCountFormat" as="xs:string" select="ahf:getVarValue('Appendix_Count_Format')"/>
                            <xsl:number format="{$appendixCountFormat}" value="$appendixCount"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="string(count($topicRef/preceding-sibling::*[contains(@class, ' map/topicref ')][ahf:isToc(.)]|$topicRef))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:sequence select="$precedingCountStr"/>
                <xsl:if test="exists($prmTopicRefs[2][ahf:isToc(.)])">
                    <xsl:sequence select="$cTitlePrefixSeparator"/>
                    <xsl:sequence select="ahf:getSibilingTopicrefCount($prmTopicRefs[position() gt 1])"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>