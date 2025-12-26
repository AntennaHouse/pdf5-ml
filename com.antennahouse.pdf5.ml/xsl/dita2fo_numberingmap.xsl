<?xml version='1.0' encoding="UTF-8" ?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: Make a numbering map for figure, table and footnote
    Copyright © 2009-2009 Antenna House, Inc. All rights reserved.
    Antenna House is a trademark of Antenna House, Inc.
    URL    : http://www.antennahouse.com/
    E-mail : info@antennahouse.com
    ****************************************************************
-->
<xsl:stylesheet version="3.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>
    <!-- This module defines table/fig/fn numbering map.
         Ususally numbering depends on bookmap hierarchy.
         The ahf:getNumberingGroupLevel function enables customization for many situations.
     -->
    
    <!-- Table Numbering Map -->
    <xsl:variable name="tableCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeTableCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="tableNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeTableStartCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="tableExists" as="xs:boolean" select="exists($tableCountMap/descendant::table-count[xs:integer(@count) gt 0])"/>
    
    <!-- Figure Numbering Map -->
    <xsl:variable name="figureCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFigureCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="figureNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFigureStartCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="figureExists" as="xs:boolean" select="exists($figureCountMap/descendant::figure-count[xs:integer(@count) gt 0])"/>
    
    <!-- Footnote Numbering Map -->
    <xsl:variable name="footnoteCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFootnoteCount"/>
        </xsl:document>
    </xsl:variable>
    
    <xsl:variable name="footnoteNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeFootnoteStartCount"/>
        </xsl:document>
    </xsl:variable>

    <!-- 
     function:    Define the grouping level accoring to the map hierarchy.
     param:       prmElem（table-count, figure-count, footnote-count)
     return:      Grouping level
     note:        To customize the grouping, override this function.
                  $prmElem varies by caller:
                  - table-count and figure-count in numbering temporary tree
                  - topicref of map
     -->
    
    <xsl:function name="ahf:getFigureNumberingGroupLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getNumberingGroupLevel($prmElem)"/>        
    </xsl:function>

    <xsl:function name="ahf:getTableNumberingGroupLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getNumberingGroupLevel($prmElem)"/>        
    </xsl:function>

    <xsl:function name="ahf:getFootnoteNumberingGroupLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:sequence select="ahf:getNumberingGroupLevel($prmElem)"/>        
    </xsl:function>
    
    <xsl:function name="ahf:getNumberingGroupLevel" as="xs:integer">
        <xsl:param name="prmElem" as="element()"/>
        <xsl:variable name="topElem" as="element()" select="if (root($prmElem)/*[1] is $root) then ($prmElem/ancestor-or-self::* except ($root|$map))[1]  else $prmElem/ancestor-or-self::*[position() eq last()]"/>
        <xsl:choose>
            <xsl:when test="not($pAddNumberingTitlePrefix)">
                <xsl:sequence select="0"/>
            </xsl:when>
            <xsl:when test="$isMap">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="$topElem[contains-token(@class, 'bookmap/part')]">
                <xsl:sequence select="2"/>
            </xsl:when>
            <xsl:when test="$topElem[contains-token(@class, 'bookmap/chapter')]">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="$topElem[contains-token(@class, 'bookmap/appendix')]">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="$topElem[contains-token(@class, 'bookmap/appendices')]">
                <xsl:sequence select="2"/>
            </xsl:when>
            <xsl:when test="$topElem[contains-token(@class, 'bookmap/frontmatter')]">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:when test="$topElem[contains-token(@class, 'bookmap/backmatter')]">
                <xsl:sequence select="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:    make table count map template
     param:       none
     return:      table count node
     note:        count only titled table
     -->
    <xsl:template name="makeTableCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains-token(@class, 'map/topicref')]" mode="MODE_TABLE_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'map/topicref')]" mode="MODE_TABLE_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="tableCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="tables" as="element()*" select="$targetTopic/descendant::*[contains-token(@class, 'topic/table')][exists(*[contains-token(@class, 'topic/title')])]"/>
                    <xsl:sequence select="count($tables)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$targetTopic"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="table-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$tableCount"/>
            <xsl:copy-of select="@class"/>
            <xsl:apply-templates select="*[contains-token(@class, 'map/topicref')]" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:    make table numbering map template
     param:       none
     return:      table start count node
     note:        none
     -->
    <xsl:template name="makeTableStartCount" as="element()*">
        <xsl:apply-templates select="$tableCountMap/*" mode="MODE_TABLE_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="table-count" mode="MODE_TABLE_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="tableGroupingLevelMax" as="xs:integer" select="ahf:getTableNumberingGroupLevel(.)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $tableGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$tableGroupingLevelMax eq 0">
                    <!-- Table number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $tableGroupingLevelMax">
                    <!-- Table number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count table number with grouping topicref considering $cTableGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="root(current())//*[. &lt;&lt; current()] except root(current())//*[. &lt;&lt; $countTopElem]"/>
                    <xsl:sequence select="xs:integer(sum($countTragetElem/@count))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
            <xsl:apply-templates select="*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:    make figure count map template
     param:       none
     return:      figure cout node
     note:        count only outer-most titled <fig>
                  2020-03-22 t.makita
     -->
    <xsl:template name="makeFigureCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains-token(@class, 'map/topicref')]" mode="MODE_FIGURE_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'map/topicref')]" mode="MODE_FIGURE_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="figureCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="figures" as="element()*" select="$targetTopic/descendant::*[contains-token(@class, 'topic/fig')][exists(*[contains-token(@class, 'topic/title')])][empty(ancestor::*[contains-token(@class, 'topic/fig')])][not(ahf:isFloatFigure(.))]"/>
                    <xsl:sequence select="count($figures)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$targetTopic"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="figure-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$figureCount"/>
            <xsl:copy-of select="@class"/>
            <xsl:apply-templates select="*[contains-token(@class, 'map/topicref')]" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:    make figure numbering map template
     param:       none
     return:      figure start count node
     note:        none
     -->
    <xsl:template name="makeFigureStartCount" as="element()*">
        <xsl:apply-templates select="$figureCountMap/*" mode="MODE_FIGURE_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="figure-count" mode="MODE_FIGURE_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="figureGroupingLevelMax" as="xs:integer" select="ahf:getFigureNumberingGroupLevel(.)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $figureGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$figureGroupingLevelMax eq 0">
                    <!-- Figure number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $figureGroupingLevelMax">
                    <!-- Figure number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:when test="$level eq 1">
                    <!-- Top level always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count figure number with grouping topicref considering $cFigureGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="root(current())//*[. &lt;&lt; current()] except root(current())//*[. &lt;&lt; $countTopElem]"/>
                    <xsl:sequence select="xs:integer(sum($countTragetElem/@count))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
            <xsl:apply-templates select="*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:    make footnote count map template
     param:       none
     return:      footnote count node
     note:		
     -->
    <xsl:template name="makeFootnoteCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains-token(@class, 'map/topicref')]" mode="MODE_FOOTNOTE_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains-token(@class, 'map/topicref')]" mode="MODE_FOOTNOTE_COUNT" as="element()*">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="figureCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="footnotes" as="element()*" select="$targetTopic//*[contains-token(@class, 'topic/fn')][not(contains-token(@class, 'pr-d/synnote'))][not(@callout)]"/>
                    <xsl:sequence select="count($footnotes)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$targetTopic"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="footnote-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$figureCount"/>
            <xsl:copy-of select="@class"/>
            <xsl:apply-templates select="*[contains-token(@class, 'map/topicref')]" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:    make footnote numbering map template
     param:       none
     return:      footnote start count nodes
     note:        none
     -->
    <xsl:template name="makeFootnoteStartCount" as="element()*">
        <xsl:apply-templates select="$footnoteCountMap/*" mode="MODE_FOOTNOTE_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="footnote-count" mode="MODE_FOOTNOTE_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="footnoteGroupingLevelMax" as="xs:integer" select="ahf:getFootnoteNumberingGroupLevel(.)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $footnoteGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$footnoteGroupingLevelMax eq 0">
                    <!-- Figure number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $footnoteGroupingLevelMax">
                    <!-- Figure number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:when test="$level eq 1">
                    <!-- Top level always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count figure number with grouping topicref considering $cFigureGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="root(current())//*[. &lt;&lt; current()] except root(current())//*[. &lt;&lt; $countTopElem]"/>
                    <xsl:sequence select="xs:integer(sum($countTragetElem/@count))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
            <xsl:apply-templates select="*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:    dump tableCountMap, tableNumberingMap template
     param:       none
     return:      dump result
     note:        none
     -->
    <xsl:template name="dumpTableMap">
        <xsl:result-document href="tableCountMap.xml" method="xml" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$tableCountMap"/>
        </xsl:result-document>
        <xsl:result-document href="tableNumberingMap.xml" method="xml" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$tableNumberingMap"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- 
     function:     dump figureCountMap, figureNumberingMap template
     param:        none
     return:       dump result
     note:         none
     -->
    <xsl:template name="dumpFigureMap">
        <xsl:result-document href="figureCountMap.xml" method="xml" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$figureCountMap"/>
        </xsl:result-document>
        <xsl:result-document href="figureNumberingMap.xml" method="xml" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$figureNumberingMap"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- 
     function:    dump footnoteCountMap, footnoteNumberingMap template
     param:       none
     return:      dump result
     note:        none
     -->
    <xsl:template name="dumpFootnoteMap">
        <xsl:result-document href="footnoteCountMap.xml" method="xml" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$footnoteCountMap"/>
        </xsl:result-document>
        <xsl:result-document href="footnoteNumberingMap.xml" method="xml" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$footnoteNumberingMap"/>
        </xsl:result-document>
    </xsl:template>

    <!-- 
     function:    get table previous amount
     param:       prmTopicRef
     return:      previous amount of table
     note:        none
     -->
    <xsl:function name="ahf:getTablePreviousAmount" as="xs:integer">
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topicId" as="xs:string" select="ahf:generateId($prmTopic,$prmTopicRef)"/>
        <xsl:variable name="prevAmount" as="xs:string" select="string($tableNumberingMap//*[string(@id) eq $topicId]/@prev-count)"/>
        <xsl:choose>
            <xsl:when test="string($prevAmount)">
                <xsl:sequence select="xs:integer($prevAmount)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinueWithFileInfo">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1604,('%id'),($topicId))"/>
                    <xsl:with-param name="prmElem" select="$prmTopic"/>
                </xsl:call-template>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- 
     function:    get figure previous amount
     param:       prmTopicRef
     return:      previous amount of fig
     note:        none
     -->
    <xsl:function name="ahf:getFigPreviousAmount" as="xs:integer">
        <xsl:param name="prmTopic" as="element()"/>
        <xsl:param name="prmTopicRef" as="element()"/>
        <xsl:variable name="topicId" as="xs:string" select="ahf:generateId($prmTopic,$prmTopicRef)"/>
        <xsl:variable name="prevAmount" as="xs:string" select="string($figureNumberingMap//*[string(@id) eq $topicId]/@prev-count)"/>
        <xsl:choose>
            <xsl:when test="string($prevAmount)">
                <xsl:sequence select="xs:integer($prevAmount)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="warningContinueWithFileInfo">
                    <xsl:with-param name="prmMes" select="ahf:replace($stMes1606,('%id'),($topicId))"/>
                    <xsl:with-param name="prmElem" select="$prmTopic"/>
                </xsl:call-template>
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>