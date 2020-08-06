<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Part, chapter, appendix templates
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
 xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
 exclude-result-prefixes="xs ahf"
 >

    <!-- 
     function:  Generate main content, part, chapter or appendix or map/topicref
     param:     none
     return:    part, chapter contents
     note:      Called from dita2fo_main.xsl
     -->
    <xsl:template match="/*/*[contains(@class, ' map/map ')]
                           /*[contains(@class, ' map/topicref ')]
                             [not(contains(@class, ' bookmap/frontmatter '))]
                             [not(contains(@class, ' bookmap/backmatter '))]
                       | /*/*[contains(@class, ' map/map ')]
                           /*[contains(@class, ' bookmap/appendices ')]
                           /*[contains(@class, ' bookmap/appendix ')]">
        <xsl:call-template name="processChapterMain"/>
    </xsl:template>
    
    <!-- 
     function:  Generate content fo:page-sequence from part, chapter or map/topicref
     param:     none (curent is top-level topicref)
     return:    fo:page-sequence
     note:      FIX: Page number bug. 2011-09-08 t.makita
     -->
    <xsl:template name="processChapterMain">
    
        <fo:page-sequence>
            <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqChapter')"/>
            <xsl:choose>
                <xsl:when test="$isBookMap">
                    <xsl:choose>
                        <xsl:when test="contains(@class, ' bookmap/part ')">
                            <xsl:if test="not(preceding-sibling::*[contains(@class, ' bookmap/part ')])">
                                <xsl:attribute name="initial-page-number" select="'1'"/>
                            </xsl:if>
                        </xsl:when>
                        <xsl:when test="contains(@class, ' bookmap/chapter ') and not(parent::*[contains(@class, ' bookmap/part ')])">
                            <xsl:if test="not(preceding-sibling::*[contains(@class, ' bookmap/chapter ')])">
                                <xsl:attribute name="initial-page-number" select="'1'"/>
                            </xsl:if>
                        </xsl:when>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not(preceding-sibling::*[contains(@class, ' map/topicref ')])">
                        <xsl:attribute name="initial-page-number" select="'1'"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <fo:static-content flow-name="rgnChapterBeforeLeft">
	            <xsl:call-template name="chapterBeforeLeft"/>
            </fo:static-content>
            <fo:static-content flow-name="rgnChapterBeforeRight">
                <xsl:call-template name="chapterBeforeRight"/>
            </fo:static-content>
            <fo:static-content flow-name="rgnChapterAfterLeft">
	            <xsl:call-template name="chapterAfterLeft"/>
            </fo:static-content>
            <fo:static-content flow-name="rgnChapterAfterRight">
                <xsl:call-template name="chapterAfterRight"/>
            </fo:static-content>
            <fo:static-content flow-name="rgnChapterEndRight">
                <xsl:call-template name="chapterEndRight"/>
            </fo:static-content>
            <fo:static-content flow-name="rgnChapterEndLeft">
                <xsl:call-template name="chapterEndLeft"/>
            </fo:static-content>
            <fo:static-content flow-name="rgnChapterBlankBody">
                <xsl:call-template name="makeBlankBlock"/>
            </fo:static-content>
            <fo:flow flow-name="xsl-region-body">
                <xsl:apply-templates select="." mode="PROCESS_TOPICREF"/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
    
    
    <!-- 
     function:  Process topicref
     param:     none
     return:    fo:block
     note:      none
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][@href]" mode="PROCESS_TOPICREF">
    
        <xsl:variable name="topicRef" select="."/>
        <!-- get topic from @href -->
        <xsl:variable name="topicContent" select="ahf:getTopicFromTopicRef($topicRef)" as="element()?"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($topicRef,())" as="xs:integer"/>
        <xsl:variable name="isLandscape" select="ahf:getOutputClass($topicRef) = $ocLandscape"/>
        
        <xsl:choose>
            <xsl:when test="exists($topicContent)">
                <xsl:choose>
                    <xsl:when test="$isLandscape">
                        <!-- Adopt Landscape layout -->
                        <psmi:page-sequence>
                            <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqChapterLnadscape')"/>
                            <xsl:choose>
                                <xsl:when test="$isBookMap">
                                    <xsl:choose>
                                        <xsl:when test="exists($topicRef/ancestor-or-self::*[contains(@class, ' bookmap/part ')])">
                                            <xsl:variable name="part" as="element()" select="$topicRef/ancestor-or-self::*[contains(@class, ' bookmap/part ')][1]"/>
                                            <xsl:variable name="topicRefs" as="element()*" select="$part/descendant-or-self::*[contains(@class,' map/topicref ')][. &lt;&lt; $topicRef]"/>
                                            <xsl:if test="empty($part/preceding-sibling::*[contains(@class, ' bookmap/part ')]) and empty($topicRefs)">
                                                <xsl:attribute name="initial-page-number" select="'1'"/>
                                            </xsl:if>
                                        </xsl:when>
                                        <xsl:when test="contains(@class, ' bookmap/chapter ') and empty(parent::*[contains(@class, ' bookmap/part ')])">
                                            <xsl:variable name="chapter" as="element()" select="$topicRef/ancestor-or-self::*[contains(@class, ' bookmap/chapter ')][1]"/>
                                            <xsl:variable name="topicRefs" as="element()*" select="$chapter/descendant-or-self::*[contains(@class,' map/topicref ')][. &lt;&lt; $topicRef]"/>
                                            <xsl:if test="empty($chapter/preceding-sibling::*[contains(@class, ' bookmap/chapter ')]) and empty($topicRefs)">
                                                <xsl:attribute name="initial-page-number" select="'1'"/>
                                            </xsl:if>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:if test="empty($map/descendant-or-self::*[contains(@class, ' map/topicref ')][exists(@href)][. &lt;&lt; $topicRef])">
                                        <xsl:attribute name="initial-page-number" select="'1'"/>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                            <fo:static-content flow-name="rgnChapterBeforeLeft">
                                <xsl:call-template name="chapterBeforeLeft"/>
                            </fo:static-content>
                            <fo:static-content flow-name="rgnChapterBeforeRight">
                                <xsl:call-template name="chapterBeforeRight"/>
                            </fo:static-content>
                            <fo:static-content flow-name="rgnChapterAfterLeft">
                                <xsl:call-template name="chapterAfterLeft"/>
                            </fo:static-content>
                            <fo:static-content flow-name="rgnChapterAfterRight">
                                <xsl:call-template name="chapterAfterRight"/>
                            </fo:static-content>
                            <fo:static-content flow-name="rgnChapterEndRight">
                                <xsl:call-template name="chapterEndRight"/>
                            </fo:static-content>
                            <fo:static-content flow-name="rgnChapterEndLeft">
                                <xsl:call-template name="chapterEndLeft"/>
                            </fo:static-content>
                            <fo:static-content flow-name="rgnChapterBlankBody">
                                <xsl:call-template name="makeBlankBlock"/>
                            </fo:static-content>
                            <fo:flow flow-name="xsl-region-body">
                                <xsl:apply-templates select="$topicContent" mode="PROCESS_MAIN_CONTENT">
                                    <xsl:with-param name="prmTopicRef"   tunnel="yes" select="$topicRef"/>
                                    <xsl:with-param name="prmTitleMode"  select="$titleMode"/>
                                </xsl:apply-templates>
                            </fo:flow>
                        </psmi:page-sequence>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Process contents -->
                        <xsl:apply-templates select="$topicContent" mode="PROCESS_MAIN_CONTENT">
                            <xsl:with-param name="prmTopicRef"   tunnel="yes" select="$topicRef"/>
                            <xsl:with-param name="prmTitleMode"  select="$titleMode"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    
        <!-- Process children-->
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]" mode="PROCESS_TOPICREF"/>
    
        <!-- generate fo:index-range-end for metadata -->
        <xsl:call-template name="processIndextermInMetadataEnd">
            <xsl:with-param name="prmTopicRef"     select="$topicRef"/>
            <xsl:with-param name="prmTopicContent" select="$topicContent"/>
        </xsl:call-template>
    
    </xsl:template>
    
    <!-- 
     function:  topichead templates
     param:     none
     return:    descendant topic contents
     note:      Add title when $PRM_ADOPT_NAVTITLE='yes'.
                2011-07-26 t.makita
                Add page-break control.
                2014-09-13 t.makita
                Remove $pAdoptNavTitle.
                2015-08-08 t.makita
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][not(@href)]" mode="PROCESS_TOPICREF">
        <xsl:variable name="topicRef" select="." as="element()"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($topicRef,())" as="xs:integer"/>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsBase'"/>
                <xsl:with-param name="prmDoInherit" select="true()"/>
            </xsl:call-template>
            <xsl:copy-of select="ahf:getIdAtts($topicRef,$topicRef,true())"/>
            <xsl:copy-of select="ahf:getLocalizationAtts($topicRef)"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="getChapterTopicBreakAttr">
                <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                <xsl:with-param name="prmTopicContent" select="()"/>
            </xsl:call-template>
            <xsl:call-template name="ahf:getFoStyleAndProperty"/>
            
            <xsl:choose>
                <xsl:when test="$titleMode eq $cRoundBulletTitleMode">
                    <!-- Make round bullet title -->
                    <xsl:call-template name="genRoundBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$titleMode eq $cSquareBulletTitleMode">
                    <!-- Make round bullet title -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$topicRef/ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]">
                    <!-- appendix content -->
                    <xsl:call-template name="genAppendixTitle">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:when>
                <!--xsl:when test="$topicRef[contains(@class, ' bookmap/appendices ')]">
                    <!-\- appendices content -\->
                    <xsl:call-template name="genAppendicesTitle">
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:when-->
                <xsl:otherwise>
                    <!-- Pointed from bookmap contents -->
                    <xsl:call-template name="genChapterTitle">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]" mode="PROCESS_TOPICREF"/>
    
        <!-- generate fo:index-range-end for metadata -->
        <xsl:call-template name="processIndextermInMetadataEnd">
            <xsl:with-param name="prmTopicRef"     select="$topicRef"/>
            <xsl:with-param name="prmTopicContent" select="()"/>
        </xsl:call-template>
    
    </xsl:template>
    
    <!-- 
     function:  Process topic (part, chapter, appendix and nested topic)
     param:     prmTitleMode
     return:    topic contents
     note:      Changed to output post-note per topic/body. 2011-07-28 t.makita
                Apply style and fo attribute in $prmTopicRef if topic is top level.
                2014-09-13 t.makita
                Move page-break control from topic/title to topic level.
                2014-09-13 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="PROCESS_MAIN_CONTENT">
        <xsl:param name="prmTopicRef" tunnel="yes"  required="yes" as="element()"/>
        <xsl:param name="prmTitleMode"   required="yes" as="xs:integer"/>
        
        <xsl:variable name="isTopLevelTopic" as="xs:boolean" select="empty(ancestor::*[contains(@class,' topic/topic ')])"/>
        <xsl:copy-of select="ahf:genChangeBarBeginElem(.)"/>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="getChapterTopicBreakAttr">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                <xsl:with-param name="prmTopicContent" select="."/>
            </xsl:call-template>
            <xsl:if test="$isTopLevelTopic">
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmTopicRef)"/>
            </xsl:if>
            <xsl:call-template name="ahf:getFoStyleAndProperty"/>
            
            <xsl:choose>
                <xsl:when test="$prmTitleMode eq $cRoundBulletTitleMode">
                    <!-- Make round bullet title -->
                    <xsl:call-template name="genRoundBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$prmTitleMode eq $cSquareBulletTitleMode">
                    <!-- Make round bullet title -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/topic ')]">
                    <!-- Nested concept, reference, task -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$prmTopicRef/ancestor-or-self::*[contains(@class, ' bookmap/appendix ')]">
                    <!-- appendix content -->
                    <xsl:call-template name="genAppendixTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Pointed from bookmap contents -->
                    <xsl:call-template name="genChapterTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
    
            <!-- abstract/shortdesc -->
            <xsl:apply-templates select="child::*[contains(@class, ' topic/abstract ')] | child::*[contains(@class, ' topic/shortdesc ')]"/>
            
            <!-- body -->
            <xsl:apply-templates select="child::*[contains(@class, ' topic/body ')]"/>
    		
            <!-- postnote -->
            <xsl:if test="$pDisplayFnAtEndOfTopic">
                <xsl:call-template name="makePostNote">
                    <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                    <xsl:with-param name="prmTopicContent" select="./*[contains(@class,' topic/body ')]"/>
                </xsl:call-template>
            </xsl:if>
            
            <!-- Complement indexterm[@end] for topic -->
            <xsl:call-template name="processIndextermInTopicEnd">
                <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                <xsl:with-param name="prmTopicContent" select="."/>
            </xsl:call-template>
    
            <!-- related-links -->
            <xsl:apply-templates select="child::*[contains(@class,' topic/related-links ')]"/>
    
            <!-- nested concept/reference/task -->
            <xsl:apply-templates select="child::*[contains(@class, ' topic/topic ')]" mode="PROCESS_MAIN_CONTENT">
                <xsl:with-param name="prmTitleMode"  select="$prmTitleMode"/>
            </xsl:apply-templates>
        </fo:block>
        <xsl:copy-of select="ahf:genChangeBarEndElem(.)"/>
    </xsl:template>

    <!-- 
     function:  Generate chapter topic break attribute
     param:     prmTopicRef, prmTopicContent
     return:    attribute()?
     note:      Changed to output break attribute from topic/title to topic level.
                2014-09-13 t.makita
                Add @outputclass page-break control.
                2019-09-14 t.makita
     -->
    <xsl:template name="getChapterTopicBreakAttr" as="attribute()*">
        <xsl:param name="prmTopicRef" required="yes" as="element()"/>
        <xsl:param name="prmTopicContent" required="yes" as="element()?"/>
        
        <!-- Nesting level in the bookmap -->
        <xsl:variable name="level" as="xs:integer" select="count($prmTopicRef/ancestor-or-self::*[contains(@class, ' map/topicref ')])"/>
        <!-- top level topic -->
        <xsl:variable name="isTopLevelTopic" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="empty($prmTopicContent)">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:when test="empty($prmTopicContent/ancestor::*[contains(@class,' topic/topic ')])">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- @outputclass value -->
        <xsl:variable name="outputClassVal" as="xs:string*" select="ahf:getOutputClass($prmTopicRef)"/>

        <xsl:choose>
            <xsl:when test="not($isTopLevelTopic)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="$outputClassVal = $ocBreakNo">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="$outputClassVal = $ocBreakColumn">
                <xsl:copy-of select="ahf:getAttributeSet('atsBreakColumn')"/>        
            </xsl:when>
            <xsl:when test="$outputClassVal = $ocBreakPage">
                <xsl:copy-of select="ahf:getAttributeSet('atsBreakPage')"/>        
            </xsl:when>
            <xsl:when test="$level eq 1">
                <xsl:choose>
                    <xsl:when test="$pIsWebOutput">
                        <xsl:copy-of select="ahf:getAttributeSet('atsChapterBreak1Online')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="ahf:getAttributeSet('atsChapterBreak1')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$level eq 2">    
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterBreak2')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:getAttributeSet('atsChapterBreak3')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
