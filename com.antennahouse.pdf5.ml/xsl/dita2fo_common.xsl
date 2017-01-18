<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Common templates
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
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf" 
>
    <!-- =======================
          Debug templates
         =======================
     -->
    
    <!-- 
     function:	General template for debug
     param:	    
     return:	debug message
     note:		
     -->
    <xsl:template match="*" priority="-3">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes"
             select="ahf:replace($stMes001,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- =======================
          Text-only templates
         =======================
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
    <xsl:template match="*[contains(@class,' topic/required-cleanup ')]" mode="TEXT_ONLY">
        <xsl:value-of select="$requiredCleanupTitlePrefix"/>
        <xsl:if test="string(@remap)">
            <xsl:value-of select="$requiredCleanupRemap"/>
            <xsl:value-of select="@remap"/>
        </xsl:if>
        <xsl:value-of select="$requiredCleanupTitleSuffix"/>
        <xsl:apply-templates  mode="TEXT_ONLY"/>
    </xsl:template>
    
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
    
    <!-- ========================
          Get contenst as inline
         ========================
     -->
    <!-- 
     function:	Get target contents copy as inline
     param:		none
     return:	fo:inline
     note:		** DOES NOT GENERATE @id & PROCESS INDEXTERM. **
     -->
    <xsl:template match="*" mode="GET_CONTENTS">
        <fo:inline>
            <xsl:copy-of select="ahf:getUnivAtts(.,(),false())"/>
            <xsl:apply-templates>
                <xsl:with-param name="prmTopicRef" tunnel="yes" select="()"/>
                <xsl:with-param name="prmNeedId"   tunnel="yes" select="false()"/>
                <xsl:with-param name="prmGetContent" tunnel="yes" select="true()"/>
            </xsl:apply-templates>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	Generate blank page block
     param:		none
     return:	blank page fo:block
     note:		Use $map/@xml:lang to get style.
     -->
    <xsl:template name="makeBlankBlock">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBlankPageBlock')"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsBlankPageInlineContainerBlock')"/>
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsBlankPageInlineBlock')"/>
                </fo:block>
            </fo:inline-container>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsBlankPageInlineTextBlock')"/>
                <xsl:value-of select="$cBlankPageTitle"/>
            </fo:inline>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsBlankPageInlineContainerBlock')"/>
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsBlankPageInlineBlock')"/>
                </fo:block>
            </fo:inline-container>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	Generate Thumb index 
     param:		prmId, prmClass
     return:	
     note:		Use $map/@xml:lang to get style
     -->
    <xsl:template name="genThumbIndex">
        <xsl:param name="prmId" required="yes" as="xs:string"/>
        <xsl:param name="prmClass" required="yes" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$prmId=''">
                <xsl:for-each select="$thumbIndexMap/*[string(@class) eq $prmClass]">
                    <xsl:call-template name="genThumbIndexMain"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$thumbIndexMap/*[string(@id) eq $prmId]">
                    <xsl:call-template name="genThumbIndexMain"/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Generate Thumb index main
     param:		prmTopicRef (Used to get style by xml:lang)
     return:	Thumb index fo:block
     note:		current context is $thumIndexMap/*
     -->
    <xsl:template name="genThumbIndexMain">
        
        <xsl:variable name="offset" select="concat(string((@index -1) * 10),'mm')"/>
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexBlock')"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexPaddingInlineContainer1')"/>
            </fo:inline-container>
            <fo:inline-container width="{$offset}"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexInlineContainer')"/>
                <fo:block-container>
                    <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexBlockContainer')"/>
                    <fo:block>
                        <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexColor')"/>
                        <xsl:value-of select="@label"/>
                    </fo:block>
                </fo:block-container>
            </fo:inline-container>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexPaddingInlineContainer2')"/>
            </fo:inline-container>
            <fo:inline-container>
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexTitleBlock')"/>
                    <fo:inline>
                        <xsl:copy-of select="ahf:getAttributeSet('atsThumbIndexTitleInline')"/>
                        <xsl:copy-of select="title/node()"/>
                    </fo:inline>
                </fo:block>
            </fo:inline-container>
        </fo:block>
    </xsl:template>
    
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
    
    <!-- =====================================
          indexterm related common template
         ===================================== -->
    <!-- Moved into dita2fo_indexcommon.xsl -->

</xsl:stylesheet>
