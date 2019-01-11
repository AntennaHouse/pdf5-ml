<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Figure list stylesheet
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
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 exclude-result-prefixes="xs ahf"
>

    <!-- 
     function:	Generate figure list template
     param:		none
     return:	(fo:page-sequence)
     note:      Current is booklists/figurelist		
     -->
    <xsl:template name="genFigureList" >
        <xsl:if test="$figureExists">
            <psmi:page-sequence>
                <xsl:choose>
                    <xsl:when test="ancestor::*[contains(@class,' bookmap/frontmatter ')]">
                        <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqFrontmatter')"/>
                        <xsl:if test="not(preceding-sibling::*) and 
                                      not(parent::*/preceding-sibling::*[contains(@class,' map/topicref ')])">
                            <xsl:attribute name="initial-page-number" select="'1'"/>
                        </xsl:if>
                        <fo:static-content flow-name="rgnFrontmatterBeforeLeft">
                            <xsl:call-template name="frontmatterBeforeLeft"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnFrontmatterBeforeRight">
                            <xsl:call-template name="frontmatterBeforeRight"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnFrontmatterAfterLeft">
                            <xsl:call-template name="frontmatterAfterLeft"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnFrontmatterAfterRight">
                            <xsl:call-template name="frontmatterAfterRight"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnFrontmatterBlankBody">
                            <xsl:call-template name="makeBlankBlock"/>
                        </fo:static-content>
                        <fo:flow flow-name="xsl-region-body">
                            <xsl:call-template name="genFigureListMain"/>
                        </fo:flow>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqBackmatter')"/>
                        <fo:static-content flow-name="rgnFrontmatterBeforeLeft">
                            <xsl:call-template name="frontmatterBeforeLeft"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnBackmatterBeforeRight">
                            <xsl:call-template name="backmatterBeforeRight"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnBackmatterAfterLeft">
                            <xsl:call-template name="backmatterAfterLeft"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnBackmatterAfterRight">
                            <xsl:call-template name="backmatterAfterRight"/>
                        </fo:static-content>
                        <fo:static-content flow-name="rgnBackmatterBlankBody">
                            <xsl:call-template name="makeBlankBlock"/>
                        </fo:static-content>
                        <fo:flow flow-name="xsl-region-body">
                            <xsl:call-template name="genFigureListMain">
                            </xsl:call-template>
                        </fo:flow>
                    </xsl:otherwise>
                </xsl:choose>
            </psmi:page-sequence>
        </xsl:if>
    </xsl:template>
    
    
    <!-- 
     function:	Figure list main template
     param:		none
     return:	fo:block
     note:      Current is booklists/figurelist		
     -->
    <xsl:template name="genFigureListMain">
    
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="id" as="xs:string" select="string(ahf:getIdAtts($topicRef,$topicRef,true())[1])"/>
        
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBase')"/>
            <!-- Title -->
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSet('atsFmHeader1')"/>
                <xsl:attribute name="id" select="$id"/>
                <fo:marker marker-class-name="{$cTitleBody}">
                    <fo:inline><xsl:value-of select="$cFigureListTitle"/></fo:inline>
                </fo:marker>
                <xsl:value-of select="$cFigureListTitle"/>
            </fo:block>
            <!-- Make contents -->
    		<xsl:apply-templates select="$map" mode="MAKE_FIGURE_LIST"/>
        </fo:block>
    </xsl:template>
     
    <!-- 
     function:	General templates for figure list
     param:		none
     return:	
     note:		none
     -->
    <xsl:template match="*" mode="MAKE_FIGURE_LIST">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="MAKE_FIGURE_LIST"/>
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]" mode="MAKE_FIGURE_LIST"/>
    
    <!-- Frontmatter -->
    <xsl:template match="*[contains(@class,' bookmap/frontmatter ')]" mode="MAKE_FIGURE_LIST" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Backmatter -->
    <xsl:template match="*[contains(@class,' bookmap/backmatter ')]" mode="MAKE_FIGURE_LIST" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- frontmatter/backmatter contents -->
    
    <!-- booklist is skipped in dita2fo_convmerged.xsl -->
    <xsl:template match="*[contains(@class,' bookmap/booklists ')]" mode="MAKE_FIGURE_LIST" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/toc ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!--Ignore TOC -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/figurelist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/tablelist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/abbrevlist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Abbrevlist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/trademarklist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Trademarklist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/bibliolist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Bibliolist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/glossarylist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Glossarylist have topicref child element. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/indexlist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Indexlist -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/booklist ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Booklist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/notices ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Notices have topicref child element. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/preface ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Preface has topicref child element. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/dedication ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Dedication should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/colophon ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Colophon should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/amendments ')][not(@href)]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- Aamendments should have a href attribute. -->
    </xsl:template>
    
    <!-- topicgroup is skipped in dita2fo_convmerged.xsl -->
    <xsl:template match="*[contains(@class,' mapgroup-d/topicgroup ')]" mode="MAKE_FIGURE_LIST" priority="2" >
        <!-- topicgroup create group without affecting the hierarchy. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Ignore reltable contents -->
    <xsl:template match="*[contains(@class,' map/reltable ')]" mode="MAKE_FIGURE_LIST" />
    
    <!-- 
     function:	templates for topicref
     param:		none
     return:	Figure list line
     note:		Process all of the map/topicref contents.
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][@href]" mode="MAKE_FIGURE_LIST">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
    
        <xsl:for-each select="$topicContent/descendant::*[contains(@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ')]]">
            <xsl:variable name="fig" select="."/>
            <xsl:variable name="figId" select="if (@id) then string(ahf:getIdAtts($fig,$topicRef,true())) else ahf:generateId($fig,$topicRef)" as="xs:string"/>
            <xsl:variable name="figTitle" as="node()*">
                <xsl:apply-templates select="$fig/*[contains(@class,' topic/title ')]" mode="#current">
                    <xsl:with-param name="prmTopicRef"  tunnel="yes"  select="$topicRef"/>
                    <xsl:with-param name="prmNeedId"    tunnel="yes"  select="false()"/>
                </xsl:apply-templates>
            </xsl:variable> 
            <xsl:call-template name="makeFigListLine">
                <xsl:with-param name="prmId"    select="$figId"/>
                <xsl:with-param name="prmTitle" select="$figTitle"/>
                <xsl:with-param name="prmTitleElem" select="$fig/*[contains(@class,' topic/title ')][1]"/>
            </xsl:call-template>
        </xsl:for-each>
        <!-- Navigate to lower level -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- 
        function:	Make figure title FO
        param:		
        return:	    fo:inline * 2
        note:		This template must return exactly 2 <fo:inline> elements.
    -->
    <xsl:template match="*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')]" priority="2" mode="MAKE_FIGURE_LIST">
        <fo:inline>
            <xsl:call-template name="ahf:getFigTitlePrefix">
                <xsl:with-param name="prmFig" select="parent::*"/>
            </xsl:call-template>
            <xsl:text>&#x00A0;</xsl:text>
            <xsl:text>&#x00A0;</xsl:text>
        </fo:inline>
        <fo:inline>
            <xsl:call-template name="ahf:getUnivAtts"/>
            <xsl:apply-templates/>
        </fo:inline>
    </xsl:template>
    
    <!-- 
     function:	Make figure list line
     param:		prmId, prmTitle
     return:	fo:list-block
     note:		Changed to use fo:list-block. 
                2011-09-09 t.makita
                Added $prmTitleElem to apply language specific style for figure title line.
                It is temporary applied only for the style named 'atsFigListBlock'.
                2014-04-08 t.makita
     -->
    <xsl:template name="makeFigListLine">
        <xsl:param name="prmId"    required="yes" as="xs:string"/>
        <xsl:param name="prmTitle" required="yes" as="node()*"/>
        <xsl:param name="prmTitleElem" required="yes" as="element()"/>
        
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsFigListBlock'"/>
                <xsl:with-param name="prmElem" select="$prmTitleElem"/>
                <xsl:with-param name="prmDoInherit" select="true()"/>
            </xsl:call-template>
            <fo:list-item>
                <xsl:copy-of select="ahf:getAttributeSet('atsFigListItem')"/>
                <fo:list-item-label>
                    <xsl:copy-of select="ahf:getAttributeSet('atsFigListLabel')"/>
                    <fo:block>
                        <fo:basic-link internal-destination="{$prmId}">
                            <xsl:copy-of select="$prmTitle[1]"/>
                        </fo:basic-link>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsFigListBody')"/>
                    <fo:block>
                        <fo:basic-link internal-destination="{$prmId}">
                            <xsl:copy-of select="$prmTitle[2]"/>
                        </fo:basic-link>
                        <fo:leader leader-length.optimum="0pt">
                            <xsl:copy-of select="ahf:getAttributeSet('atsFigListLeader')"/>
                        </fo:leader>
                        <fo:inline keep-with-next="always">
                            <fo:leader>
                                <xsl:copy-of select="ahf:getAttributeSet('atsFigListLeader')"/>
                            </fo:leader>
                        </fo:inline>
                        <fo:basic-link internal-destination="{$prmId}">
                            <fo:page-number-citation ref-id="{$prmId}" />
                        </fo:basic-link>
                    </fo:block>
                </fo:list-item-body>
            </fo:list-item>
        </fo:list-block>
    </xsl:template>

</xsl:stylesheet>
