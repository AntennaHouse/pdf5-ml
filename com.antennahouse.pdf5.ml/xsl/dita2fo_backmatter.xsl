<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Backmatter stylesheet
    Copyright © 2009-2011 Antenna House, Inc. All rights reserved.
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
     function:  Generate back matter
     param:     none
     return:    fo:page-sequence
     note:      Called from dita2fo_main.xsl
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/backmatter')]" >
        <xsl:if test="descendant::*[contains-token(@class, 'map/topicref')][@href]
                    | descendant::*[contains-token(@class, 'bookmap/toc')][not(@href)]
                    | descendant::*[contains-token(@class, 'bookmap/indexlist')][not(@href)]
                    | descendant::*[contains-token(@class, 'bookmap/figurelist')][not(@href)]
                    | descendant::*[contains-token(@class, 'bookmap/tablelist')][not(@href)]">
            <fo:page-sequence>
                <xsl:call-template name="getAttributeSet">
                    <xsl:with-param name="prmAttrSetName" select="'atsPageSeqBackmatter'"/>
                </xsl:call-template>
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
                    <xsl:apply-templates mode="PROCESS_BACKMATTER"/>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <!-- 
        function:   Backmatter's cover template
        param:      none
        return:     none
        note:       Call cover generation template
    -->
    <xsl:template match="*[contains-token(@class, 'bookmap/backmatter')]//*[contains-token(@class, 'map/topicref')][ahf:isCoverTopicRef(.)]" mode="PROCESS_BACKMATTER" priority="6">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        
        <xsl:choose>
            <xsl:when test="exists($topicContent)">
                <xsl:call-template name="outputCoverN">
                    <xsl:with-param name="prmTopicContent" select="$topicContent"/>
                    <xsl:with-param name="prmTopicRef" select="$topicRef" tunnel="yes"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                        select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    

    <!-- 
        function:   Back matter's child template
        param:      none
        return:     none
        note:       Call templates using next-match. (2011-09-27 t.makita)
    -->
    <xsl:template match="*[contains-token(@class, 'bookmap/backmatter')]//*[contains-token(@class, 'map/topicref')]" mode="PROCESS_BACKMATTER" priority="4">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
    
        <!-- Invoke next priority template -->
        <xsl:next-match/>
    
        <!-- generate fo:index-range-end for metadata (Except indexlist, booklist, glossarylist, booklist)-->
        <xsl:if test="($topicRef is $lastTopicRef) or ($topicRef &lt;&lt; $lastTopicRef)">
            <xsl:call-template name="processIndextermInMetadataEnd">
                <xsl:with-param name="prmTopicRef"     select="."/>
                <xsl:with-param name="prmTopicContent" select="$topicContent"/>
            </xsl:call-template>
        </xsl:if>
    
    </xsl:template>
    
    <!-- 
     function:  Back matter's general template
     param:     none
     return:    none
     note:		
     -->
    <xsl:template match="*" mode="PROCESS_BACKMATTER">
        <xsl:apply-templates mode="PROCESS_BACKMATTER"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="PROCESS_BACKMATTER"/>
    
    <!-- Ignore topicref level's topicmeta
     -->
    <xsl:template match="*[contains-token(@class, 'map/topicmeta')]" mode="PROCESS_BACKMATTER"/>
    
    <!-- 
     function:  Amendments templates
     param:     none
     return:    descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/amendments')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/amendments')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    <!-- 
     function:  Booklist templates
     param:     none
     return:    descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/booklists')]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
        
    <!-- 
     function:  Abbrevlist
     param:     none
     return:    Automatic abbrevation list generation is not supported.
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/abbrevlist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/abbrevlist')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
    </xsl:template>
        
    <!-- 
     function:  Bibliolist
     param:     none
     return:	Automatic bibliography generation is not supported.
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/bibliolist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/bibliolist')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
    </xsl:template>
        
    <!-- 
     function:  Booklist
     param:     none
     return:    Automatic bibliography generation is not supported.
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/booklist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/booklist')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
    </xsl:template>
        
    <!-- 
     function:  Figure list
     param:     none
     return:    Figurelist content
     note:      Generates automatic figurelist generation
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/figurelist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/figurelist')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2" >
        <xsl:call-template name="genFigureList"/>
    </xsl:template>
        
    <!-- 
     function:  Glossary list
     param:     none
     return:    glossary list contents
     note:		
    -->
    <xsl:template match="*[contains-token(@class, 'bookmap/glossarylist')]" mode="PROCESS_BACKMATTER" priority="2" >
        <xsl:call-template name="genGlossaryList"/>
    </xsl:template>
        
    <!-- 
     function:  Index
     param:     none
     return:    Index contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/indexlist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/indexlist')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:call-template name="genIndex"/>
    </xsl:template>
        
    <!-- 
     function:  Table list
     param:     none
     return:    Table list content
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/tablelist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/tablelist')][not(@href)]" mode="PROCESS_BACKMATTER" priority="2" >
        <xsl:call-template name="genTableList"/>
    </xsl:template>
        
    <!-- 
     function:  Trademark list
     param:     none
     return:    none
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/trademarklist')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/trademarklist')][not(@href)]" mode="PROCESS_BACKMATTER" priority="2" >
    </xsl:template>
        
    <!-- 
     function:  Table of content
     param:     none
     return:    toc contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/toc')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/toc')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:call-template name="genToc"/>
    </xsl:template>
    
    <!-- 
     function:  Colophon templates
     param:     none
     return:    descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/colophon')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/colophon')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
     function:  Dedication templates
     param:     none
     return:    descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/dedication')][empty(@href)]" mode="PROCESS_BACKMATTER" priority="2">
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'bookmap/dedication')][exists(@href)]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    <!-- 
     function:  Notices templates
     param:     none
     return:    descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'bookmap/notices')]" mode="PROCESS_BACKMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    
    <!-- 
     function:  topicref without @href templates
     param:     none
     return:    title and descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains-token(@class, 'map/topicref')][not(@href)]" mode="PROCESS_BACKMATTER">
        <xsl:call-template name="processTopicRefWoHrefInBackmatter"/>
    </xsl:template>
    
    <xsl:template name="processTopicRefWoHrefInBackmatter">
        
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="level" 
            as="xs:integer"
            select="count($topicRef/ancestor-or-self::*[contains-token(@class, 'map/topicref')]
                                                        [not(contains-token(@class, 'bookmap/backmatter'))]
                                                        [not(contains-token(@class, 'bookmap/booklists'))]
                                                        )"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($topicRef,())" as="xs:integer"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsBase'"/>
                <xsl:with-param name="prmDoInherit" select="true()"/>
            </xsl:call-template>
            <xsl:copy-of select="ahf:getIdAtts($topicRef,$topicRef,true())"/>
            <xsl:copy-of select="ahf:getLocalizationAtts($topicRef)"/>
            <xsl:call-template name="getBackmatterTopicBreakAttr">
                <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                <xsl:with-param name="prmTopicContent" select="()"/>
            </xsl:call-template>
            <xsl:copy-of select="ahf:getFoStyleAndProperty($topicRef)"/>
            <!-- title -->
            <xsl:choose>
                <xsl:when test="$titleMode eq $cRoundBulletTitleMode">
                    <!-- Make round bullet title -->
                    <xsl:call-template name="genRoundBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$titleMode eq $cSquareBulletTitleMode">
                    <!-- Make square bullet title -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Pointed from bookmap contents -->
                    <xsl:call-template name="genBackmatterTitle">
                        <xsl:with-param name="prmLevel" select="$level"/>
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>

        <xsl:apply-templates select="child::*[contains-token(@class, 'map/topicref')]" mode="PROCESS_BACKMATTER"/>

    </xsl:template>
    
    <!-- 
     function:  Process backmatter's topicref
     param:     none
     return:    psmi:page-sequence or topic contents
     note:      Support landscape page in backmatter
     -->
    <xsl:template match="*[contains-token(@class, 'map/topicref')][@href]" mode="PROCESS_BACKMATTER">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="isLandscape" select="ahf:getOutputClass($topicRef) = $ocLandscape"/>
        <xsl:choose>
            <xsl:when test="$isLandscape and $pEnableLandscapePage">
                <psmi:page-sequence>
                    <xsl:call-template name="getAttributeSet">
                        <xsl:with-param name="prmAttrSetName" select="'atsPageSeqBackmatterLandscape'"/>
                    </xsl:call-template>
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
                        <xsl:call-template name="processTopicRefWithHrefInBackmatter"/>    
                    </fo:flow>
                </psmi:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="processTopicRefWithHrefInBackmatter"/>    
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:  Process backmatter's topicref main
     param:     none
     return:    topic contents
     note:      none
     -->
    <xsl:template name="processTopicRefWithHrefInBackmatter">
        <xsl:variable name="topicRef" select="."/>
        <!-- get topic from @href -->
        <xsl:variable name="topicContent" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($topicRef,())" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="exists($topicContent)">
                <!-- Process contents -->
                <xsl:apply-templates select="$topicContent" mode="OUTPUT_BACKMATTER">
                    <xsl:with-param name="prmTopicRef"   tunnel="yes" select="$topicRef"/>
                    <xsl:with-param name="prmTitleMode"  select="$titleMode"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" 
                     select="ahf:replace($stMes070,('%href','%file'),(string(@href),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
        <!-- Process children -->
        <xsl:apply-templates select="child::*[contains-token(@class, 'map/topicref')]" mode="#current"/>

    </xsl:template>
    
    <!-- 
     function:  Process backmatter topic
     param:     prmTopicRef, prmTitleMode
     return:    topic contents
     note:      Changed to output post-note per topic/body. 
                2011-07-28 t.makita
                Add page-break control.
                2019-09-14 t.makita
     -->
    <xsl:template match="*[contains-token(@class, 'topic/topic')]" mode="OUTPUT_BACKMATTER">
        <xsl:param name="prmTopicRef"    tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmTitleMode"   required="yes" as="xs:integer"/>
        
        <xsl:variable name="level" 
                      as="xs:integer"
                      select="count($prmTopicRef/ancestor-or-self::*[contains-token(@class, 'map/topicref')]
                                                                   [not(contains-token(@class, 'bookmap/backmatter'))]
                                                                   )"/>
        <xsl:variable name="isTopLevelTopic" as="xs:boolean" select="empty(ancestor::*[contains-token(@class, 'topic/topic')])"/>
        <xsl:copy-of select="ahf:genChangeBarBeginElem(.)"/>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="getBackmatterTopicBreakAttr">
                <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                <xsl:with-param name="prmTopicContent" select="."/>
            </xsl:call-template>
            <xsl:if test="$isTopLevelTopic">
                <xsl:copy-of select="ahf:getFoStyleAndProperty($prmTopicRef)"/>
            </xsl:if>
            <xsl:copy-of select="ahf:getFoStyleAndProperty(.)"/>
            <!-- title -->
            <xsl:choose>
                <xsl:when test="$prmTitleMode eq $cRoundBulletTitleMode">
                    <!-- Make round bullet title -->
                    <xsl:call-template name="genRoundBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$prmTitleMode eq $cSquareBulletTitleMode">
                    <!-- Make square bullet title -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="ancestor::*[contains-token(@class, 'topic/topic')]">
                    <!-- Nested concept, reference, task -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Pointed from bookmap contents -->
                    <xsl:call-template name="genBackmatterTitle">
                        <xsl:with-param name="prmLevel" select="$level"/>
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            
            <!-- abstract/shortdesc -->
            <xsl:apply-templates select="child::*[contains-token(@class, 'topic/abstract')] | child::*[contains-token(@class, 'topic/shortdesc')]"/>
            
            <!-- body -->
            <xsl:apply-templates select="child::*[contains-token(@class, 'topic/body')]"/>
    
            <!-- postnote -->
            <xsl:if test="$pDisplayFnAtEndOfTopic">
                <xsl:call-template name="makePostNote">
                    <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                    <xsl:with-param name="prmTopicContent" select="./*[contains-token(@class, 'topic/body')]"/>
                </xsl:call-template>
            </xsl:if>
            
            <!-- Complement indexterm[@end] for topic -->
            <xsl:call-template name="processIndextermInTopicEnd">
                <xsl:with-param name="prmTopicRef"     select="$prmTopicRef"/>
                <xsl:with-param name="prmTopicContent" select="."/>
            </xsl:call-template>
            
            <!-- related-links -->
            <xsl:apply-templates select="child::*[contains-token(@class, 'topic/related-links')]"/>
            
            <!-- nested concept/reference/task -->
            <xsl:apply-templates select="child::*[contains-token(@class, 'topic/topic')]" mode="OUTPUT_BACKMATTER">
                <xsl:with-param name="prmTitleMode"  select="$prmTitleMode"/>
            </xsl:apply-templates>
        </fo:block>
        <xsl:copy-of select="ahf:genChangeBarEndElem(.)"/>
    </xsl:template>

    <!-- 
     function:  Generate backmatter topic break attribute
     param:     prmTopicRef, prmTopicContent
     return:    attribute()?
     note:      Ported from getFrontmatterTopicBreakAttr template.
                2019-09-14 t.makita
     -->
    <xsl:template name="getBackmatterTopicBreakAttr" as="attribute()*">
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:param name="prmTopicContent" as="element()?" required="yes"/>
        
        <!-- Nesting level in the bookmap -->
        <xsl:variable name="level" 
                      as="xs:integer"
                      select="count($prmTopicRef/ancestor-or-self::*[contains-token(@class, 'map/topicref')]
                                                                    [not(contains-token(@class, 'bookmap/backmatter'))])"/>
        <!-- top level topic -->
        <xsl:variable name="isTopLevelTopic" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="empty($prmTopicContent)">
                    <xsl:sequence select="true()"/>
                </xsl:when>
                <xsl:when test="empty($prmTopicContent/ancestor::*[contains-token(@class, 'topic/topic')])">
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
                        <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterBreak1Online')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterBreak1')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$level eq 2">    
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterBreak2')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:getAttributeSet('atsBackmatterBreak3')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
