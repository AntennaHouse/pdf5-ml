<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet 
Module: Static content stylesheet
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
     function:	frontmatter static content template
     param:		none
     return:	fo:block
     note:		current is topicref 
     -->
    <xsl:template name="frontmatterBeforeLeft">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBeforeLeftBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="frontmatterBeforeRight">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionBeforeRightBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="frontmatterAfterLeft">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfterLeftBlock')"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="frontmatterAfterRight">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfterRightBlock')"/>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
        </fo:block>
    </xsl:template>
    
    <!-- 
     function:	part/chapter static content template
     param:		none
     return:	fo:block
     note:		current is topicref 
     -->
    <xsl:template name="chapterBeforeLeft">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBeforeLeftBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="chapterBeforeRight">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionBeforeRightBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="chapterAfterLeft">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfterLeftBlock')"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <!-- Part/chapter title -->
            <xsl:if test="$pAddNumberingTitlePrefix">
                <fo:retrieve-marker retrieve-class-name="{$cTitlePrefix}"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="chapterAfterRight">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfterRightBlock')"/>
            <!-- Part/chapter title -->
            <xsl:if test="$pAddNumberingTitlePrefix">
                <fo:retrieve-marker retrieve-class-name="{$cTitlePrefix}"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
        </fo:block>
    </xsl:template>
    
    <!-- Current context is topicref
         2014-09-14 t.makita
     -->
    <xsl:template name="chapterEndRight">
        <xsl:if test="$pAddThumbnailIndex">
            <xsl:call-template name="genThumbIndex">
                <xsl:with-param name="prmId" select="ahf:generateId(.,())"/>
                <xsl:with-param name="prmClass">
                    <xsl:choose>
                        <xsl:when test="ancestor-or-self::*[contains(@class, ' bookmap/part ')]">
                            <xsl:value-of select="$cClassPart"/>
                        </xsl:when>
                        <xsl:when test="ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]">
                            <xsl:value-of select="$cClassAppendix"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$cClassChapter"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <!-- Genrate thumbnail if this is online PDF.
         2014-09-14 t.makita
     -->
    <xsl:template name="chapterEndLeft">
        <xsl:if test="$pIsWebOutput and $pAddThumbnailIndex">
            <xsl:call-template name="chapterEndRight"/>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	index static content template
     param:		none
     return:	fo:block
     note:		Current context is booklists/indexlist
     -->
    <xsl:template name="indexBeforeLeft">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionBeforeLeftBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="indexBeforeRight">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionBeforeRightBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="indexAfterLeft">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionAfterLeftBlock')"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="indexAfterRight">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionAfterRightBlock')"/>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsIndexRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="indexEndRight">
        <xsl:if test="$pAddThumbnailIndex">
            <xsl:call-template name="genThumbIndex">
                <xsl:with-param name="prmId" select="''"/>
                <xsl:with-param name="prmClass" select="$cClassIndex"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="indexEndLeft">
        <xsl:if test="$pIsWebOutput and $pAddThumbnailIndex">
            <xsl:call-template name="indexEndRight"/>
        </xsl:if>
    </xsl:template>
    
    <!-- 
     function:	backmatter static content template
     param:		none
     return:	fo:block
     note:		current is topicref 
     -->
    <xsl:template name="backmatterBeforeLeft">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBeforeLeftBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="backmatterBeforeRight">
        <!-- No contents, border only -->
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionBeforeRightBlock')"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="backmatterAfterLeft">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfterLeftBlock')"/>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
        </fo:block>
    </xsl:template>
    
    <xsl:template name="backmatterAfterRight">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfterRightBlock')"/>
            <fo:retrieve-marker retrieve-class-name="{$cTitleBody}"/>
            <fo:inline-container>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterRegionAfter_InlineContainer')"/>
            </fo:inline-container>
            <fo:inline>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageNumber')"/>
                <fo:page-number/>
            </fo:inline>
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

</xsl:stylesheet>