<?xml version='1.0' encoding="UTF-8" ?>
<!--
****************************************************************
DITA to XSL-FO Stylesheet
Module: Frontmatter stylesheet
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

    <!-- 
     function:	Generate front matter
     param:		none
     return:	fo:page-sequence
     note:		Called from dita2fo_main.xsl
     -->
    <xsl:template match="*[contains(@class, ' bookmap/frontmatter ')]" >
        <xsl:if test="descendant::*[contains(@class,' map/topicref ')][@href]
                    | descendant::*[contains(@class,' bookmap/toc ')][not(@href)]
                    | descendant::*[contains(@class,' bookmap/indexlist ')][not(@href)]
                    | descendant::*[contains(@class,' bookmap/figurelist ')][not(@href)]
                    | descendant::*[contains(@class,' bookmap/tablelist ')][not(@href)]">
            <fo:page-sequence>
                <xsl:copy-of select="ahf:getAttributeSet('atsPageSeqFrontmatter')"/>
                <xsl:attribute name="initial-page-number" select="'1'"/>
                
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
                    <xsl:apply-templates mode="PROCESS_FRONTMATTER"/>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <!-- 
        function:	Frontmatter's cover template
        param:		none
        return:	    none
        note:		Call cover generation template
    -->
    <xsl:template match="*[contains(@class, ' bookmap/frontmatter ')]//*[contains(@class,' map/topicref ')][ahf:isCoverTopicRef(.)]" mode="PROCESS_FRONTMATTER" priority="6">
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
        function:	Front matter's child template
        param:		none
        return:	    none
        note:		Call templates using next-match. (2011-09-27 t.makita)
    -->
    <xsl:template match="*[contains(@class, ' bookmap/frontmatter ')]//*[contains(@class,' map/topicref ')]" mode="PROCESS_FRONTMATTER" priority="4">
        <xsl:variable name="topicRef" select="."/>
        <xsl:variable name="topicContent"  as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
    
        <!-- Invoke next priority template -->
        <xsl:next-match/>
        
        <!-- generate fo:index-range-end for metadata -->
        <xsl:call-template name="processIndextermInMetadataEnd">
            <xsl:with-param name="prmTopicRef"     select="$topicRef"/>
            <xsl:with-param name="prmTopicContent" select="$topicContent"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- 
     function:	Frontmatter's general template
     param:		none
     return:	none
     note:		
     -->
    <xsl:template match="*" mode="PROCESS_FRONTMATTER">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="text()" mode="PROCESS_FRONTMATTER"/>
    
    <!-- Ignore topicref level's topicmeta
     -->
    <xsl:template match="*[contains(@class, ' map/topicmeta ')]" mode="PROCESS_FRONTMATTER"/>
    
    <!-- 
     function:	Bookabstract templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/bookabstract ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes080,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
        
    <xsl:template match="*[contains(@class,' bookmap/bookabstract ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
     function:	Colophon templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/colophon ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes080,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/colophon ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
     function:	Booklists templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/booklists ')]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <!-- 
     function:	Abbrevlist
     param:		none
     return:	Automatic abbrevation list generation is not supported.
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/abbrevlist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/abbrevlist ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes082,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
     function:	Bibliolist
     param:		none
     return:	Automatic bibliography generation is not supported.
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/bibliolist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/bibliolist ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes082,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
     function:	Booklist
     param:		none
     return:	Automatic bibliography generation is not supported.
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/booklist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/booklist ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes082,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
    
    <!-- 
     function:	Figure list
     param:		none
     return:	Figurelist content
     note:		Generates automatic figurelist generation
     -->
    <xsl:template match="*[contains(@class,' bookmap/figurelist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    <xsl:template match="*[contains(@class,' bookmap/figurelist ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2" >
        <xsl:choose>
            <xsl:when test="$figureExists">
                <xsl:call-template name="genFigureList"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes087,('%elem','%file'),(name(.),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <!-- 
     function:	Glossary list
     param:		none
     return:	glossary list contents
     note:		
    -->
    <xsl:template match="*[contains(@class,' bookmap/glossarylist ')]" mode="PROCESS_FRONTMATTER" priority="2" >
        <xsl:call-template name="genGlossaryList"/>
    </xsl:template>
    
    <!-- 
     function:	Index
     param:		none
     return:	Index contents
     note:		This template will not be executed because this plug-in treats index in frontmatter as error.
                2012-03-29 t.makita
     -->
    <xsl:template match="*[contains(@class,' bookmap/indexlist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    <xsl:template match="*[contains(@class,' bookmap/indexlist ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="genIndex"/>
    </xsl:template>
    
    <!-- 
     function:	Table list
     param:		none
     return:	Table list content
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/tablelist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    <xsl:template match="*[contains(@class,' bookmap/tablelist ')][not(@href)]" mode="PROCESS_FRONTMATTER" priority="2" >
        <xsl:choose>
            <xsl:when test="$tableExists">
                <xsl:call-template name="genTableList"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinue">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes088,('%elem','%file'),(name(.),string(@xtrf)))"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- 
     function:	Trademark list
     param:		none
     return:	none
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/trademarklist ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/trademarklist ')][not(@href)]" mode="PROCESS_FRONTMATTER" priority="2" >
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes082,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
        
    <!-- 
     function:	Table of content
     param:		none
     return:	toc contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/toc ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/toc ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="genToc"/>
    </xsl:template>
    
    <!-- 
     function:	Dedication templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/dedication ')][empty(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:call-template name="warningContinue">
            <xsl:with-param name="prmMes" select="ahf:replace($stMes080,('%elem','%file'),(name(.),string(@xtrf)))"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="*[contains(@class,' bookmap/dedication ')][exists(@href)]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
        
    <!-- 
     function:	Draftintro templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/draftintro ')]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match/>
    </xsl:template>
    
    <!-- 
     function:	Notices templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/notices ')]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" tunnel="yes" select="$cNoticeTitle"/>
        </xsl:next-match>
    </xsl:template>
    
    <!-- 
     function:	Preface templates
     param:		none
     return:	descendant topic contents
     note:		
     -->
    <xsl:template match="*[contains(@class,' bookmap/preface ')]" mode="PROCESS_FRONTMATTER" priority="2">
        <xsl:next-match>
            <xsl:with-param name="prmDefaultTitle" tunnel="yes" select="$cPrefaceTitle"/>
        </xsl:next-match>
    </xsl:template>
    
    <!-- 
     function:	topicref without @href templates
     param:		none
     return:	descendant topic contents
     note:		Add page-break control.
                2014-09-13 t.makita
                Newly added "processTopicrefWoHrefInFrontmatter" for easy customization.
                2015-05-25 t.makita
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][not(@href)]" mode="PROCESS_FRONTMATTER">
        <xsl:call-template name="processTopicRefWoHrefInFrontmatter"/>
    </xsl:template>
    
    <xsl:template name="processTopicRefWoHrefInFrontmatter">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="level" 
            as="xs:integer"
            select="count($topicRef/ancestor-or-self::*[contains(@class, ' map/topicref ')]
                                                         [not(contains(@class, ' bookmap/frontmatter '))])"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($topicRef,())" as="xs:integer"/>
        
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang">
                <xsl:with-param name="prmAttrSetName" select="'atsBase'"/>
                <xsl:with-param name="prmDoInherit" select="true()"/>
            </xsl:call-template>
            <xsl:copy-of select="ahf:getIdAtts($topicRef,$topicRef,true())"/>
            <xsl:copy-of select="ahf:getLocalizationAtts($topicRef)"/>
            <xsl:call-template name="getFrontmatterTopicBreakAttr">
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
                    <xsl:call-template name="genFrontmatterTitle">
                        <xsl:with-param name="prmLevel" select="$level"/>
                        <xsl:with-param name="prmTopicRef" select="$topicRef"/>
                        <xsl:with-param name="prmTopicContent" select="()"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>

        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]" mode="PROCESS_FRONTMATTER"/>
        
    </xsl:template>
    
    <!-- 
     function:	Process front matter's topicref
     param:		none
     return:	topic contents
     note:		none
     -->
    <xsl:template match="*[contains(@class,' map/topicref ')][@href]" mode="PROCESS_FRONTMATTER">
        <xsl:call-template name="processTopicRefWithHrefInFrontmatter"/>    
    </xsl:template>
    
    <xsl:template name="processTopicRefWithHrefInFrontmatter">
        <xsl:variable name="topicRef" select="."/>
        <!-- get topic from @href -->
        <xsl:variable name="topicContent" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="titleMode" select="ahf:getTitleMode($topicRef,())" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="exists($topicContent)">
                <!-- Process contents -->
                <xsl:apply-templates select="$topicContent" mode="OUTPUT_FRONTMATTER">
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
        
        <!-- Process children. -->
        <xsl:apply-templates select="child::*[contains(@class,' map/topicref ')]" mode="#current"/>
        
    </xsl:template>
    
    <!-- 
     function:	Process frontmatter topic
     param:		prmTopicRef, prmTitleMode
     return:	topic contents
     note:		Changed to output post-note per topic/body. 2011-07-28 t.makita
     -->
    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="OUTPUT_FRONTMATTER">
        <xsl:param name="prmTopicRef"    tunnel="yes" required="yes" as="element()"/>
        <xsl:param name="prmTitleMode"   required="yes" as="xs:integer"/>
        
        <!-- Nesting level in the bookmap 
             topicgroup is skipped in dita2fo_convmerged.xsl.
         -->
        <xsl:variable name="level" 
                      as="xs:integer"
                      select="count($prmTopicRef/ancestor-or-self::*[contains(@class, ' map/topicref ')]
                                                                   [not(contains(@class, ' bookmap/frontmatter '))]
                                                                   )"/>
        <xsl:variable name="isTopLevelTopic" as="xs:boolean" select="empty(ancestor::*[contains(@class,' topic/topic ')])"/>
        <fo:block>
            <xsl:call-template name="getAttributeSetWithLang"/>
            <xsl:call-template name="ahf:getIdAtts"/>
            <xsl:call-template name="ahf:getLocalizationAtts"/>
            <xsl:call-template name="getFrontmatterTopicBreakAttr">
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
                <xsl:when test="ancestor::*[contains(@class, ' topic/topic ')]">
                    <!-- Nested concept, reference, task -->
                    <xsl:call-template name="genSquareBulletTitle">
                        <xsl:with-param name="prmTopicRef" select="$prmTopicRef"/>
                        <xsl:with-param name="prmTopicContent" select="."/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Pointed from bookmap contents -->
                    <xsl:call-template name="genFrontmatterTitle">
                        <xsl:with-param name="prmLevel" select="$level"/>
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
            <xsl:apply-templates select="child::*[contains(@class, ' topic/topic ')]" mode="OUTPUT_FRONTMATTER">
                <xsl:with-param name="prmTitleMode"  select="$prmTitleMode"/>
            </xsl:apply-templates>
        </fo:block>
    </xsl:template>

    <!-- 
     function:	Generate frontmatter topic break attribute
     param:		prmTopicRef, prmTopicContent
     return:	attribute()?
     note:		Changed to output break attribute from topic/title to topic level.
                2014-09-13 t.makita
     -->
    <xsl:template name="getFrontmatterTopicBreakAttr" as="attribute()*">
        <xsl:param name="prmTopicRef" as="element()" required="yes"/>
        <xsl:param name="prmTopicContent" as="element()?" required="yes"/>
        
        <!-- Nesting level in the bookmap -->
        <xsl:variable name="level" 
                      as="xs:integer"
                      select="count($prmTopicRef/ancestor-or-self::*[contains(@class, ' map/topicref ')]
                                                                      [not(contains(@class, ' bookmap/frontmatter '))])"/>
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
        <xsl:choose>
            <xsl:when test="not($isTopLevelTopic)">
                <xsl:sequence select="()"/>
            </xsl:when>
            <xsl:when test="$level eq 1">
                <xsl:choose>
                    <xsl:when test="$pIsWebOutput">
                        <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterBreak1Online')"/>        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterBreak1')"/>        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$level eq 2">    
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterBreak2')"/>        
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="ahf:getAttributeSet('atsFrontmatterBreak3')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
