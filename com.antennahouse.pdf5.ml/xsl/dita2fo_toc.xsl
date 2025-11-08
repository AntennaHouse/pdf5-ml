<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: TOC stylesheet
    Copyright © 2009-2012 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 exclude-result-prefixes="xs ahf"
>

    <!-- 
     function:	Generate TOC template
     param:		none
     return:	fo:page-sequence
     note:		Current is booklists/toc
     -->
    <xsl:template name="genToc" >
        <psmi:page-sequence>
            <xsl:choose>
                <xsl:when test="ancestor::*[contains-token(@class, 'bookmap/frontmatter')]">
                    <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqFrontmatter')"/>
                    <xsl:if test="not(preceding-sibling::*) and 
                                  not(parent::*/preceding-sibling::*[contains-token(@class, 'map/topicref')])">
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
                        <xsl:call-template name="genTocMain"/>
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
                        <xsl:call-template name="genTocMain"/>
                    </fo:flow>
                </xsl:otherwise>
            </xsl:choose>
        </psmi:page-sequence>
    </xsl:template>
    
    <!-- 
     function:	Generate TOC template for map
     param:		none
     return:	fo:page-sequence
     note:		
     -->
    <xsl:template name="genMapToc" >
        <fo:page-sequence>
            <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqFrontmatter')"/>
            <xsl:if test="not(preceding-sibling::*) and 
                not(parent::*/preceding-sibling::*[contains-token(@class, 'map/topicref')])">
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
                <xsl:call-template name="genMapTocMain"/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <!-- 
     function:	TOC's main template
     param:		none
     return:	none
     note:		Current is booklists/toc or map
                2012-04-02 t.makita
     -->
    <xsl:template name="genTocMain">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="id" as="xs:string" select="string(ahf:getIdAtts($topicRef,$topicRef,true())[1])"/>
        <xsl:variable name="title" as="xs:string">
            <xsl:choose>
                <xsl:when test="$topicRef/*[contains-token(@class, 'map/topicmeta')]/*[contains-token(@class, 'topic/navtitle')]">
                    <xsl:variable name="navTitle" as="xs:string*">
                        <xsl:apply-templates select="$topicRef/*[contains-token(@class, 'map/topicmeta')]/*[contains-token(@class, 'topic/navtitle')]" mode="TEXT_ONLY"/>
                    </xsl:variable>
                    <xsl:sequence select="string-join($navTitle,'')"/>
                </xsl:when>
                <xsl:when test="$topicRef/@navtitle">
                    <xsl:sequence select="string($topicRef/@navtitle)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$cTocTitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBase')"/>
            <!-- Title -->
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSet('atsFmHeader1')"/>
                <xsl:attribute name="id" select="$id"/>
                <fo:marker marker-class-name="{$cTitleBody}">
                    <fo:inline><xsl:value-of select="$title"/></fo:inline>
                </fo:marker>
                <xsl:value-of select="$title"/>
            </fo:block>
            <!-- Make contents -->
    		<xsl:apply-templates select="$map" mode="MAKE_TOC"/>
        </fo:block>
    </xsl:template>

    <!-- 
     function:	TOC's main template for simple map
     param:		none
     return:	none
     note:		Context item is root
     -->
    <xsl:template name="genMapTocMain">
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet('atsBase')"/>
            <!-- Title -->
            <fo:block>
                <xsl:copy-of select="ahf:getAttributeSet('atsFmHeader1')"/>
                <xsl:attribute name="id" select="$cTocId"/>
                <fo:marker marker-class-name="{$cTitleBody}">
                    <fo:inline><xsl:value-of select="$cTocTitle"/></fo:inline>
                </fo:marker>
                <xsl:value-of select="$cTocTitle"/>
            </fo:block>
            <!-- Make contents -->
            <xsl:apply-templates select="$map" mode="MAKE_TOC"/>
        </fo:block>
    </xsl:template>

    <!-- 
     function:	General templates for TOC
     param:		none
     return:	
     note:		none
     -->
    <xsl:template match="*" mode="MAKE_TOC">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="MAKE_TOC"/>
    <xsl:template match="*[contains-token(@class, 'bookmap/bookmeta')]" mode="MAKE_TOC"/>
    
    
    <!-- Frontmatter -->
    <xsl:template match="*[contains-token(@class, 'bookmap/frontmatter')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2">
        <!--xsl:message>[Frontmatter] $pIncludeFrontmatterToToc=<xsl:value-of select="$pIncludeFrontmatterToToc"/></xsl:message-->
        <xsl:if test="$pIncludeFrontmatterToToc">
            <xsl:apply-templates mode="#current"/>
        </xsl:if>
    </xsl:template>
    
    <!-- Backmatter -->
    <xsl:template match="*[contains-token(@class, 'bookmap/backmatter')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Frontmatter/backmatter contents -->
    
    <!-- Bookabstract -->
    <xsl:template match="*[contains-token(@class, 'bookmap/bookabstract')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match/>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/bookabstract')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Booklists -->
    <xsl:template match="*[contains-token(@class, 'bookmap/booklists')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Abbrevlist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/abbrevlist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/abbrevlist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Bibliolist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/bibliolist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/bibliolist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Booklist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/booklist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/booklist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Figurelist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/figurelist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/figurelist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:if test="$figureExists">
            <xsl:next-match>
                <xsl:with-param name="prmDefaultTitle" select="$cFigureListTitle"/>
                <xsl:with-param name="prmProcessChild" select="false()"/>
            </xsl:next-match>
        </xsl:if>
    </xsl:template>
        
    <!-- Glossarylist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/glossarylist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/glossarylist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:if test="child::*[contains-token(@class, 'map/topicref')][exists(@href)]">
            <xsl:next-match>
                <xsl:with-param name="prmDefaultTitle" select="$cGlossaryListTitle"/>
                <xsl:with-param name="prmProcessChild" select="false()"/>
            </xsl:next-match>
        </xsl:if>
    </xsl:template>
        
    <!-- Indexlist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/indexlist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" select="$cIndexTitle"/>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/indexlist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:if test="$pOutputIndex and ($indextermSortedCount gt 0)">
            <xsl:next-match>
                <xsl:with-param name="prmDefaultTitle" select="$cIndexTitle"/>
                <xsl:with-param name="prmProcessChild" select="false()"/>
            </xsl:next-match>
        </xsl:if>
    </xsl:template>
    
    <!-- Tablelist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/tablelist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" select="$cTableListTitle"/>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/tablelist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:if test="$tableExists">
            <xsl:next-match>
                <xsl:with-param name="prmDefaultTitle" select="$cTableListTitle"/>
                <xsl:with-param name="prmProcessChild" select="false()"/>
            </xsl:next-match>
        </xsl:if>
    </xsl:template>
        
    <!-- Trademarklist -->
    <xsl:template match="*[contains-token(@class, 'bookmap/trademarklist')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmProcessChild" select="false()"/>
        </xsl:next-match>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/trademarklist')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Toc
         Ignore!
         2019-12-27 t.makita
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/toc')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" />
        
    <!-- Colophon -->
    <xsl:template match="*[contains-token(@class, 'bookmap/colophon')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match/>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/colophon')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Dedication -->
    <xsl:template match="*[contains-token(@class, 'bookmap/dedication')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match/>
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/dedication')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
        
    <!-- Draftintro -->
    <xsl:template match="*[contains-token(@class, 'bookmap/draftintro')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
        
    <!-- Notices -->
    <xsl:template match="*[contains-token(@class, 'bookmap/notices')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" select="$cNoticeTitle"/>
        </xsl:next-match>
    </xsl:template>
        
    <!-- Preface -->
    <xsl:template match="*[contains-token(@class, 'bookmap/preface')][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" select="$cPrefaceTitle"/>
        </xsl:next-match>
    </xsl:template>
        
    <!-- Backmatter contents -->
    
    <!-- Amendments -->
    <xsl:template match="*[contains-token(@class, 'bookmap/amendments')][empty(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
    </xsl:template>
    <xsl:template match="*[contains-token(@class, 'bookmap/amendments')][exists(@href)][ahf:isToc(.)]" mode="MAKE_TOC" priority="2" >
        <xsl:next-match/>
    </xsl:template>
    
    <!-- Appendice
         Changed not to generate toc title because appendice is only a wrapper of appendix in bookmap.
         2014-09-15 t.makita
      -->
    <xsl:template match="*[contains-token(@class, 'bookmap/appendices')]" mode="MAKE_TOC" priority="2" >
        <!--xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" select="$cAppendicesTitle"/>
        </xsl:next-match-->
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- Ignore reltable contents -->
    <xsl:template match="*[contains-token(@class, 'map/reltable')]" mode="MAKE_TOC" />
    
    <!-- 
     function:	templates for topicref
     param:		none
     return:	TOC line
     note:		Process all of the map/topicref contents.
                Skip outputclass="coverN" & toc="no".
     -->
    <xsl:template match="*[contains-token(@class, 'map/topicref')][ahf:isCoverTopicRef(.)]" mode="MAKE_TOC" priority="2"/>
    <xsl:template match="*[contains-token(@class, 'map/topicref')][not(ahf:isToc(.))]" mode="MAKE_TOC"/>
            
    <xsl:template match="*[contains-token(@class, 'map/topicref')][ahf:isToc(.)]" mode="MAKE_TOC">
        <xsl:param name="prmDefaultTitle" as="xs:string" required="no" select="''"/>
        <xsl:param name="prmProcessChild" as="xs:boolean" required="no" select="true()"/>
        <xsl:call-template name="makeTocDetailLine">
            <xsl:with-param name="prmDefaultTitle" select="$prmDefaultTitle"/>
            <xsl:with-param name="prmProcessChild" select="$prmProcessChild"/>
        </xsl:call-template>
    </xsl:template>
        
    <!-- Named template for override
         Current context is topicref
      -->
    <xsl:template name="makeTocDetailLine">
        <xsl:param name="prmDefaultTitle" as="xs:string" required="no" select="''"/>
        <xsl:param name="prmProcessChild" as="xs:boolean" required="no" select="true()"/>
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="linkContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="contentId" select="if (empty($linkContent)) then () else ahf:getIdAtts($linkContent,$topicRef,true())" as="attribute()*"/>
        <xsl:variable name="topicRefId" select="ahf:getIdAtts($topicRef,$topicRef,true())" as="attribute()*"/>
        <xsl:variable name="navtitle" select="normalize-space(@navtitle)"/>
        <xsl:variable name="nestedTopicCount" as="xs:integer">
            <xsl:sequence select="count(ancestor-or-self::*[contains-token(@class, 'map/topicref')]
                                                           [not(contains-token(@class, 'bookmap/frontmatter'))]
                                                           [not(contains-token(@class, 'bookmap/backmatter'))]
                                                           [not(contains-token(@class, 'bookmap/booklists'))]
                                                           [not(contains-token(@class, 'bookmap/appendices'))]
                                                           )"/>
        </xsl:variable>
    
        <xsl:variable name="addToc" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$nestedTopicCount gt $cTocNestMax">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:when test="ancestor-or-self::*[contains-token(@class, 'map/topicref')][@toc='no']">
                    <!-- Descendant of toc="no" topicref --> 
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="true()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
    
        <xsl:choose>
            <xsl:when test="not($addToc)">
                <!-- Ignore this element and descendant. -->
            </xsl:when>
            <xsl:otherwise>
                <!-- Make TOC line -->
                <xsl:variable name="title" as="node()*">
                    <xsl:call-template name="ahf:getTitleContent">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmLinkContent" select="$linkContent"/>
                        <xsl:with-param name="prmDefaultTitle" select="$prmDefaultTitle"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="exists($title)">
                    <xsl:call-template name="makeTocLine">
                        <xsl:with-param name="prmId" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="exists($contentId)">
                                    <xsl:sequence select="string($contentId[1])"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="string($topicRefId[1])"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:with-param>
                        <xsl:with-param name="prmLevel" select="$nestedTopicCount"/>
                        <xsl:with-param name="prmTitle" select="$title"/>
                    </xsl:call-template>
                </xsl:if>
                <!-- Navigate to lower level -->
                <xsl:if test="$prmProcessChild">
                    <xsl:apply-templates mode="#current"/>    
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- 
     function:	Get title contents
     param:		prmTopicRef, prmLinkContent
     return:	title inline
     note:		
     -->
    <xsl:template name="ahf:getTitleContent" as="node()*">
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:param name="prmLinkContent" as="element()?"/>
        <xsl:param name="prmDefaultTitle" as="xs:string"/>
    
        <xsl:variable name="titlePrefix" as="node()*">
            <xsl:if test="$pAddNumberingTitlePrefix">
                <xsl:variable name="titlePrefix" as="xs:string">
                    <xsl:call-template name="genTitlePrefix">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:if test="string(normalize-space($titlePrefix))">
                    <fo:inline>
                        <xsl:value-of select="$titlePrefix"/>
                        <xsl:text>&#x00A0;&#x00A0;</xsl:text>
                    </fo:inline>
                </xsl:if>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="titleNode" as="node()*">
            <xsl:choose>
                <xsl:when test="exists($prmLinkContent)">
                    <xsl:apply-templates select="$prmLinkContent/*[contains-token(@class, 'topic/title')]" mode="GET_CONTENTS"/>
                </xsl:when>
                <xsl:when test="$prmTopicRef/*[contains-token(@class, 'map/topicmeta')]/*[contains-token(@class, 'topic/navtitle')]">
                    <xsl:apply-templates select="$prmTopicRef/*[contains-token(@class, 'map/topicmeta')]/*[contains-token(@class, 'topic/navtitle')]" mode="GET_CONTENTS"/>
                </xsl:when>
                <xsl:when test="$prmTopicRef/@navtitle">
                    <fo:inline><xsl:value-of select="string($prmTopicRef/@navtitle)"/></fo:inline>
                </xsl:when>
                <xsl:when test="string($prmDefaultTitle)">
                    <fo:inline><xsl:value-of select="$prmDefaultTitle"/></fo:inline>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="exists($titleNode)">
                <xsl:copy-of select="$titlePrefix"/>
                <xsl:copy-of select="$titleNode"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Make TOC line
     param:		prmId, prmLevel, prmTitle
     return:	TOC line
     note:		The style "atsTocLevelN" (N is $prmLevel) must be defined in style definition file!
     -->
    <xsl:template name="makeTocLine">
        <xsl:param name="prmId"    required="yes" as="xs:string"/>
        <xsl:param name="prmLevel" required="yes" as="xs:integer"/>
        <xsl:param name="prmTitle" required="yes" as="node()*"/>
    
        <fo:block>
            <xsl:copy-of select="ahf:getAttributeSet(concat('atsTocLevel',string($prmLevel)))"/>
            <xsl:choose>
                <xsl:when test="string($prmId)">
                    <fo:basic-link internal-destination="{$prmId}">
                        <xsl:copy-of select="$prmTitle"/>
                    </fo:basic-link>
                    <fo:leader leader-length.optimum="0pt">
                        <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                    </fo:leader>
                    <fo:inline keep-with-next="always">
                        <fo:leader>
                            <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                        </fo:leader>
                    </fo:inline>
                    <fo:basic-link internal-destination="{$prmId}">
                        <fo:page-number-citation ref-id="{$prmId}" />
                    </fo:basic-link>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTocTitleOnly')"/>
                    <fo:inline>
                        <xsl:copy-of select="$prmTitle"/>
                    </fo:inline>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
        <!--
        <xsl:choose>
            <xsl:when test="$prmLevel eq 1">
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLevel1')"/>
                    <xsl:choose>
                        <xsl:when test="string($prmId)">
                            <fo:basic-link internal-destination="{$prmId}">
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:basic-link>
                			<fo:leader leader-length.optimum="0pt">
                                <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                            </fo:leader>
                            <fo:inline keep-with-next="always">
                                <fo:leader>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                                </fo:leader>
                            </fo:inline>
                            <fo:basic-link internal-destination="{$prmId}">
                                <fo:page-number-citation ref-id="{$prmId}" />
                            </fo:basic-link>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsTocTitleOnly')"/>
                            <fo:inline>
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:inline>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <xsl:when test="$prmLevel eq 2">
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLevel2')"/>
                    <xsl:choose>
                        <xsl:when test="string($prmId)">
                            <fo:basic-link internal-destination="{$prmId}">
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:basic-link>
                			<fo:leader leader-length.optimum="0pt">
                                <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                            </fo:leader>
                            <fo:inline keep-with-next="always">
                                <fo:leader>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                                </fo:leader>
                            </fo:inline>
                            <fo:basic-link internal-destination="{$prmId}">
                                <fo:page-number-citation ref-id="{$prmId}" />
                            </fo:basic-link>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsTocTitleOnly')"/>
                            <fo:inline>
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:inline>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <xsl:when test="$prmLevel eq 3">
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLevel3')"/>
                    <xsl:choose>
                        <xsl:when test="string($prmId)">
                            <fo:basic-link internal-destination="{$prmId}">
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:basic-link>
                			<fo:leader leader-length.optimum="0pt">
                                <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                            </fo:leader>
                            <fo:inline keep-with-next="always">
                                <fo:leader>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                                </fo:leader>
                            </fo:inline>
                            <fo:basic-link internal-destination="{$prmId}">
                                <fo:page-number-citation ref-id="{$prmId}" />
                            </fo:basic-link>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsTocTitleOnly')"/>
                            <fo:inline>
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:inline>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLevel4')"/>
                    <xsl:choose>
                        <xsl:when test="string($prmId)">
                            <fo:basic-link internal-destination="{$prmId}">
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:basic-link>
                			<fo:leader leader-length.optimum="0pt">
                                <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                            </fo:leader>
                            <fo:inline keep-with-next="always">
                                <fo:leader>
                                    <xsl:copy-of select="ahf:getAttributeSet('atsTocLeader')"/>
                                </fo:leader>
                            </fo:inline>
                            <fo:basic-link internal-destination="{$prmId}">
                                <fo:page-number-citation ref-id="{$prmId}" />
                            </fo:basic-link>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="ahf:getAttributeSet('atsTocTitleOnly')"/>
                            <fo:inline>
                                <xsl:copy-of select="$prmTitle"/>
                            </fo:inline>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
        -->
    </xsl:template>

</xsl:stylesheet>
