<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Table list stylesheet
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
     function:	Generate table list template
     param:		none
     return:	(fo:page-sequence)
     note:      Current is booklists/tablelist		
     -->
    <xsl:template name="genTableList" >
        <xsl:if test="$tableExists">
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
                            <xsl:call-template name="genTableListMain"/>
                        </fo:flow>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqBackmatter')"/>
                        <fo:static-content flow-name="rgnBackmatterBeforeLeft">
                            <xsl:call-template name="backmatterBeforeLeft"/>
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
                            <xsl:call-template name="genTableListMain"/>
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
     note:		current is booklists/tablelist
     -->
    <xsl:template name="genTableListMain">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="id" as="xs:string" select="string(ahf:getIdAtts($topicRef,$topicRef,true())[1])"/>
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBase')"/>
            <!-- Title -->
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSet('atsFmHeader1')"/>
                <xsl:attribute name="id" select="$id"/>
                <fo:marker marker-class-name="{$cTitleBody}">
                    <fo:inline><xsl:copy-of select="$cTableListTitle"/></fo:inline>
                </fo:marker>
                <xsl:value-of select="$cTableListTitle"/>
            </fo:block>
            <!-- Make contents -->
    		<xsl:apply-templates select="$map" mode="MAKE_TABLE_LIST"/>
        </fo:block>
    </xsl:template>
     
    <!-- 
     function:	General templates for figure list
     param:		none
     return:	
     note:		none
     -->
    <xsl:template match="*" mode="MAKE_TABLE_LIST">
        <xsl:apply-templates mode="MAKE_TABLE_LIST"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="MAKE_TABLE_LIST"/>
    <xsl:template match="*[contains(@class, ' bookmap/bookmeta ')]" mode="MAKE_TABLE_LIST"/>
    
    <!-- Frontmatter -->
    <xsl:template match="*[contains(@class,' bookmap/frontmatter ')]" mode="MAKE_TABLE_LIST" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Backmatter -->
    <xsl:template match="*[contains(@class,' bookmap/backmatter ')]" mode="MAKE_TABLE_LIST" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- frontmatter/backmatter contents -->
    
    <xsl:template match="*[contains(@class,' bookmap/booklists ')]" mode="MAKE_TABLE_LIST" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/toc ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!--Ignore TOC -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/figurelist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/tablelist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/abbrevlist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Abbrevlist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/trademarklist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Trademarklist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/bibliolist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Bibliolist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/glossarylist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Glossarylist have topicref child element. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/indexlist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Index line -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/booklist ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Booklist should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/notices ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Notices have topicref child element. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/preface ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Preface has topicref child element. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/dedication ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Dedication should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/colophon ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Colophon should have a href attribute. -->
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/amendments ')][not(@href)]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- Aamendments should have a href attribute. -->
    </xsl:template>
    
    <!-- topicgroup is skipped in dita2fo_convmerged.xsl -->
    <xsl:template match="*[contains(@class,' mapgroup-d/topicgroup ')]" mode="MAKE_TABLE_LIST" priority="2" >
        <!-- topicgroup create group without affecting the hierarchy. -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Ignore reltable contents -->
    <xsl:template match="*[contains(@class,' map/reltable ')]" mode="MAKE_TABLE_LIST" />
    
    <!-- 
     function:	templates for topicref
     param:		none
     return:	Table list line
     note:		Process all of the map/topicref contents.
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][@href]" mode="MAKE_TABLE_LIST">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="topicContent" select="ahf:getTopicFromTopicRef($topicRef)" as="element()?"/>
    
        <xsl:for-each select="$topicContent/descendant::*[contains(@class, ' topic/table ')][child::*[contains(@class, ' topic/title ')]]">
            <xsl:variable name="table" select="."/>
            <xsl:variable name="tableId" select="if (@id) then string(ahf:getIdAtts($table,$topicRef,true())) else ahf:generateId($table,$topicRef)" as="xs:string"/>
            <xsl:variable name="tableTitle" as="node()*">
                <xsl:apply-templates select="$table/*[contains(@class,' topic/title ')]" mode="#current">
                    <xsl:with-param name="prmTopicRef"  tunnel="yes"  select="$topicRef"/>
                    <xsl:with-param name="prmNeedId"    tunnel="yes"  select="false()"/>
                </xsl:apply-templates>
            </xsl:variable>
            <xsl:call-template name="makeTableListLine">
                <xsl:with-param name="prmId"    select="$tableId"/>
                <xsl:with-param name="prmTitle" select="$tableTitle"/>
                <xsl:with-param name="prmTitleElem" select="$table/*[contains(@class,' topic/title ')][1]"/>
            </xsl:call-template>
        </xsl:for-each>
        <!-- Navigate to lower level -->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- 
        function:	Make table title FO
        param:		prmTopicRef, prmNeedId
        return:	    fo:inline * 2
        note:		This template must return exactly 2 <fo:inline> elements.
    -->
    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]" priority="2" mode="MAKE_TABLE_LIST">
        <fo:inline>
            <xsl:call-template name="ahf:getTableTitlePrefix">
                <xsl:with-param name="prmTable" select="parent::*"/>
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
     function:	Make table list line
     param:		prmId, prmTitle
     return:	fo:block
     note:		
     -->
    <xsl:template name="makeTableListLine">
        <xsl:param name="prmId"    required="yes" as="xs:string"/>
        <xsl:param name="prmTitle" required="yes" as="node()*"/>
        <xsl:param name="prmTitleElem" required="yes" as="element()"/>
        
        <fo:list-block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsTableListBlock'"/>
                <xsl:with-param name="prmElem" select="$prmTitleElem"/>
                <xsl:with-param name="prmDoInherit" select="true()"/>
            </xsl:call-template>
            <fo:list-item>
                <xsl:copy-of select="ahf:getAttributeSet('atsTableListItem')"/>
                <fo:list-item-label>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTableListLabel')"/>
                    <fo:block>
                        <fo:basic-link internal-destination="{$prmId}">
                            <xsl:copy-of select="$prmTitle[1]"/>
                        </fo:basic-link>
                    </fo:block>
                </fo:list-item-label>
                <fo:list-item-body>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTableListBody')"/>
                    <fo:block>
                        <fo:basic-link internal-destination="{$prmId}">
                            <xsl:copy-of select="$prmTitle[2]"/>
                        </fo:basic-link>
                        <fo:leader leader-length.optimum="0pt">
                            <xsl:copy-of select="ahf:getAttributeSet('atsTableListLeader')"/>
                        </fo:leader>
                        <fo:inline keep-with-next="always">
                            <fo:leader>
                                <xsl:copy-of select="ahf:getAttributeSet('atsTableListLeader')"/>
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
