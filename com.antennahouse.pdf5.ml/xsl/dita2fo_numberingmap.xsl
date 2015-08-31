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
<xsl:stylesheet version="2.0" 
 xmlns:fo="http://www.w3.org/1999/XSL/Format" 
 xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:xs="http://www.w3.org/2001/XMLSchema"
 xmlns:ahf="http://www.antennahouse.com/names/XSLT/Functions/Document"
 exclude-result-prefixes="xs ahf"
>

    <xsl:variable name="cTableGroupingLevelMax" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$pAddNumberingTitlePrefix">
                <xsl:sequence select="xs:integer(ahf:getVarValue('Table_Grouping_Level_Max'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if user selects not to add title prefix, the table number will not be grouped. -->
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
     </xsl:variable>
    
    <xsl:variable name="cFigureGroupingLevelMax" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$pAddNumberingTitlePrefix">
                <xsl:sequence select="xs:integer(ahf:getVarValue('Figure_Grouping_Level_Max'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if user selects not to add title prefix, the figure number will not be grouped. -->
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
     </xsl:variable>
    
    <xsl:variable name="cFootnoteGroupingLevelMax" as="xs:integer">
        <xsl:sequence select="xs:integer(ahf:getVarValue('Footnote_Grouping_Level_Max'))"/>
    </xsl:variable>
    
    
    <!-- Table Numbering Map -->
    <xsl:variable name="tableCountMap">
        <xsl:call-template name="makeTableCount"/>
    </xsl:variable>
    
    <xsl:variable name="tableNumberingMap">
        <xsl:call-template name="makeTableStartCount"/>
    </xsl:variable>
    
    <xsl:variable name="tableExists" as="xs:boolean" select="exists($tableCountMap/tablecount[xs:integer(@count) gt 0])"/>
        
    
    <!-- Figure Numbering Map -->
    <xsl:variable name="figureCountMap">
        <xsl:call-template name="makeFigureCount"/>
    </xsl:variable>
    
    <xsl:variable name="figureNumberingMap">
        <xsl:call-template name="makeFigureStartCount"/>
    </xsl:variable>
    
    <xsl:variable name="figureExists" as="xs:boolean" select="exists($figureCountMap/figurecount[xs:integer(@count) gt 0])"/>
    
    <!-- Footnote Numbering Map -->
    <xsl:variable name="footnoteCountMap">
        <xsl:call-template name="makeFootnoteCount"/>
    </xsl:variable>
    
    <xsl:variable name="footnoteNumberingMap">
        <xsl:call-template name="makeFootnoteStartCount"/>
    </xsl:variable>
    
    
    
    <!-- 
     function:	make table count map template
     param:		none
     return:	table cout node
     note:		count only titled table
     -->
    <xsl:template name="makeTableCount">
        <xsl:apply-templates select="$map//*[contains(@class, ' map/topicref ')][starts-with(@href,'#')][not(ancestor::*[contains(@class,' map/reltable ')])]" mode="TABLE_COUNT">
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="TABLE_COUNT">
        <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' map/topicref ')][(starts-with(@href,'#')) or (contains(@class, ' mapgroup-d/topichead '))])"/>
        <xsl:variable name="targetId" select="substring-after(@href, '#')"/>
        <xsl:variable name="targetTopic" select="key('topicById', $targetId)[1]"/>
        <xsl:variable name="topicId" select="ahf:generateId($targetTopic,.)"/>
        <xsl:variable name="tableCount" select="count($targetTopic//*[contains(@class,' topic/table ')][child::*[contains(@class, ' topic/title ')]])"/>
        <xsl:variable name="isFrontmatter" select="string(boolean(ancestor::*[contains(@class, ' bookmap/frontmatter ')]))"/>
        <xsl:variable name="isBackmatter" select="string(boolean(ancestor::*[contains(@class, ' bookmap/backmatter ')]))"/>
        <!--xsl:variable name="isToc" select="string(boolean((not(@toc)) or (@toc=$cYes)))"/-->
        <xsl:variable name="isToc" select="string(not(ahf:isTocNo(.)))"/>
        <xsl:element name="tablecount">
            <xsl:attribute name="level"         select="string($level)"/>
            <xsl:attribute name="id"            select="$topicId"/>
            <xsl:attribute name="count"         select="string($tableCount)"/>
            <xsl:attribute name="isfrontmatter" select="$isFrontmatter"/>
            <xsl:attribute name="isbackmatter"  select="$isBackmatter"/>
            <xsl:attribute name="istoc"         select="$isToc"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:	make table numbering map template
     param:		none
     return:	table start count node
     note:		none
     -->
    <xsl:template name="makeTableStartCount">
        <xsl:apply-templates select="$tableCountMap/*[1]" mode="TABLE_START_COUNT">
            <xsl:with-param name="prmPreviousAmount" select="0"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="tablecount" mode="TABLE_START_COUNT">
        <xsl:param name="prmPreviousAmount" select="0"/>
    
        <xsl:variable name="previousLevel" select="preceding-sibling::*[1]/@level"/>
        <!--xsl:variable name="previousId" select="preceeding-sibiling::*[1]/@id"/-->
        <xsl:variable name="previousCount" select="preceding-sibling::*[1]/@count"/>
        <xsl:variable name="previousIsFrontmatter" select="preceding-sibling::*[1]/@isfrontmatter"/>
        <xsl:variable name="previousIsBackmatter" select="preceding-sibling::*[1]/@isbackmatter"/>
    
        <xsl:variable name="currentLevel" select="@level"/>
        <xsl:variable name="currentId" select="@id"/>
        <xsl:variable name="currentCount" select="@count"/>
        <xsl:variable name="currentIsFrontmatter" select="@isfrontmatter"/>
        <xsl:variable name="currentIsBackmatter" select="@isbackmatter"/>
        <xsl:variable name="currentIsToc" select="@istoc"/>
    
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::*)">
                <!-- First element -->
                <xsl:element name="tablestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsFrontmatter=$true) and ($currentIsFrontmatter=$true)">
                <!-- element in the frontmatter-->
                <xsl:element name="tablestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsFrontmatter=$true) and ($currentIsFrontmatter=$false)">
                <!-- element after the frontmatter-->
                <xsl:element name="tablestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsBackmatter=$false) and ($currentIsBackmatter=$true)">
                <!-- first element of the backmatter-->
                <xsl:element name="tablestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsBackmatter=$true) and ($currentIsBackmatter=$true)">
                <!-- element in the backmatter-->
                <xsl:element name="tablestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$currentLevel &gt; $cTableGroupingLevelMax">
                        <xsl:element name="tablestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="$currentIsToc = $false">
                        <!--xsl:message>hit toc="no" table previousAmount=<xsl:value-of select="$prmPreviousAmount"/></xsl:message-->
                        <xsl:element name="tablestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise><!--xsl:when test="$currentLevel &lt;= $cTableGroupingLevelMax"-->
                        <xsl:element name="tablestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="TABLE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    
    <!-- 
     function:	make figure count map template
     param:		none
     return:	figure cout node
     note:		count only titled <fig>
     -->
    <xsl:template name="makeFigureCount">
        <xsl:apply-templates select="$map//*[contains(@class, ' map/topicref ')][starts-with(@href,'#')][not(ancestor::*[contains(@class,' map/reltable ')])]" mode="FIGURE_COUNT">
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="FIGURE_COUNT">
        <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' map/topicref ')][(starts-with(@href,'#')) or (contains(@class, ' mapgroup-d/topichead '))])"/>
        <xsl:variable name="targetId" select="substring-after(@href, '#')"/>
        <xsl:variable name="targetTopic" select="key('topicById', $targetId)[1]"/>
        <xsl:variable name="topicId" select="ahf:generateId($targetTopic,.)"/>
        <xsl:variable name="figureCount" select="count($targetTopic//*[contains(@class,' topic/fig ')][child::*[contains(@class, ' topic/title ')]])"/>
        <xsl:variable name="isFrontmatter" select="string(boolean(ancestor::*[contains(@class, ' bookmap/frontmatter ')]))"/>
        <xsl:variable name="isBackmatter" select="string(boolean(ancestor::*[contains(@class, ' bookmap/backmatter ')]))"/>
        <!--xsl:variable name="isToc" select="string(boolean((not(@toc)) or (@toc=$cYes)))"/-->
        <xsl:variable name="isToc" select="string(not(ahf:isTocNo(.)))"/>
        <xsl:element name="figurecount">
            <xsl:attribute name="level"            select="string($level)"/>
            <xsl:attribute name="id"               select="$topicId"/>
            <xsl:attribute name="count"            select="string($figureCount)"/>
            <xsl:attribute name="isfrontmatter"    select="$isFrontmatter"/>
            <xsl:attribute name="isbackmatter"     select="$isBackmatter"/>
            <xsl:attribute name="istoc"            select="$isToc"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:	make figure numbering map template
     param:		none
     return:	figure start count node
     note:		none
     -->
    <xsl:template name="makeFigureStartCount">
        <xsl:apply-templates select="$figureCountMap/*[1]" mode="FIGURE_START_COUNT">
            <xsl:with-param name="prmPreviousAmount" select="0"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="figurecount" mode="FIGURE_START_COUNT">
        <xsl:param name="prmPreviousAmount" select="0"/>
    
        <xsl:variable name="previousLevel" select="preceding-sibling::*[1]/@level"/>
        <!--xsl:variable name="previousId" select="preceeding-sibiling::*[1]/@id"/-->
        <xsl:variable name="previousCount" select="preceding-sibling::*[1]/@count"/>
        <xsl:variable name="previousIsFrontmatter" select="preceding-sibling::*[1]/@isfrontmatter"/>
        <xsl:variable name="previousIsBackmatter" select="preceding-sibling::*[1]/@isbackmatter"/>
    
        <xsl:variable name="currentLevel" select="@level"/>
        <xsl:variable name="currentId" select="@id"/>
        <xsl:variable name="currentCount" select="@count"/>
        <xsl:variable name="currentIsFrontmatter" select="@isfrontmatter"/>
        <xsl:variable name="currentIsBackmatter" select="@isbackmatter"/>
        <xsl:variable name="currentIsToc" select="@istoc"/>
    
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::*)">
                <!-- First element -->
                <xsl:element name="figurestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsFrontmatter=$true) and ($currentIsFrontmatter=$true)">
                <!-- element in the frontmatter-->
                <xsl:element name="figurestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsFrontmatter=$true) and ($currentIsFrontmatter=$false)">
                <!-- element after the frontmatter-->
                <xsl:element name="figurestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsBackmatter=$false) and ($currentIsBackmatter=$true)">
                <!-- first element of the backmatter-->
                <xsl:element name="figurestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsBackmatter=$true) and ($currentIsBackmatter=$true)">
                <!-- element in the backmatter-->
                <xsl:element name="figurestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$currentLevel &gt; $cFigureGroupingLevelMax">
                        <xsl:element name="figurestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="$currentIsToc = $false">
                        <!--xsl:message>hit toc="no" figure previousAmount=<xsl:value-of select="$prmPreviousAmount"/></xsl:message-->
                        <xsl:element name="figurestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise><!--xsl:when test="$currentLevel &lt; $cFigureGroupingLevelMax"-->
                        <xsl:element name="figurestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="FIGURE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    <!-- 
     function:	make footnote count map template
     param:		none
     return:	footnote count node
     note:		
     -->
    <xsl:template name="makeFootnoteCount">
        <xsl:apply-templates select="$map//*[contains(@class, ' map/topicref ')][starts-with(@href,'#')][not(ancestor::*[contains(@class,' map/reltable ')])]" mode="FOOTNOTE_COUNT">
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="FOOTNOTE_COUNT">
        <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' map/topicref ')][(starts-with(@href,'#')) or (contains(@class, ' mapgroup-d/topichead '))])"/>
        <xsl:variable name="targetId" select="substring-after(@href, '#')"/>
        <xsl:variable name="targetTopic" select="key('topicById', $targetId)[1]"/>
        <xsl:variable name="topicId" select="ahf:generateId($targetTopic,.)"/>
        <xsl:variable name="footnoteCount" select="count($targetTopic//*[contains(@class,' topic/fn ')][not(contains(@class,' pr-d/synnote '))][not(@callout)])"/>
        <xsl:variable name="isFrontmatter" select="string(boolean(ancestor::*[contains(@class, ' bookmap/frontmatter ')]))"/>
        <xsl:variable name="isBackmatter" select="string(boolean(ancestor::*[contains(@class, ' bookmap/backmatter ')]))"/>
        <!--xsl:variable name="isToc" select="string(boolean((not(@toc)) or (@toc=$cYes)))"/-->
        <xsl:variable name="isToc" select="string(not(ahf:isTocNo(.)))"/>
        <xsl:element name="footnotecount">
            <xsl:attribute name="level"            select="string($level)"/>
            <xsl:attribute name="id"               select="$topicId"/>
            <xsl:attribute name="count"            select="string($footnoteCount)"/>
            <xsl:attribute name="isfrontmatter"    select="$isFrontmatter"/>
            <xsl:attribute name="isbackmatter"     select="$isBackmatter"/>
            <xsl:attribute name="istoc"            select="$isToc"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:	make footnote numbering map template
     param:		none
     return:	footnote start count nodes
     note:		none
     -->
    <xsl:template name="makeFootnoteStartCount">
        <xsl:apply-templates select="$footnoteCountMap/*[1]" mode="FOOTNOTE_START_COUNT">
            <xsl:with-param name="prmPreviousAmount" select="0"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="footnotecount" mode="FOOTNOTE_START_COUNT">
        <xsl:param name="prmPreviousAmount" select="0"/>
    
        <xsl:variable name="previousLevel" select="preceding-sibling::*[1]/@level"/>
        <!--xsl:variable name="previousId" select="preceeding-sibiling::*[1]/@id"/-->
        <xsl:variable name="previousCount" select="preceding-sibling::*[1]/@count"/>
        <xsl:variable name="previousIsFrontmatter" select="preceding-sibling::*[1]/@isfrontmatter"/>
        <xsl:variable name="previousIsBackmatter" select="preceding-sibling::*[1]/@isbackmatter"/>
    
        <xsl:variable name="currentLevel" select="@level"/>
        <xsl:variable name="currentId" select="@id"/>
        <xsl:variable name="currentCount" select="@count"/>
        <xsl:variable name="currentIsFrontmatter" select="@isfrontmatter"/>
        <xsl:variable name="currentIsBackmatter" select="@isbackmatter"/>
        <xsl:variable name="currentIsToc" select="@istoc"/>
    
        <xsl:choose>
            <xsl:when test="not(preceding-sibling::*)">
                <!-- First element -->
                <xsl:element name="footnotestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsFrontmatter=$true) and ($currentIsFrontmatter=$true)">
                <!-- element in the frontmatter-->
                <xsl:element name="footnotestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsFrontmatter=$true) and ($currentIsFrontmatter=$false)">
                <!-- element after the frontmatter-->
                <xsl:element name="footnotestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsBackmatter=$false) and ($currentIsBackmatter=$true)">
                <!-- first element of the backmatter-->
                <xsl:element name="footnotestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:when test="($previousIsBackmatter=$true) and ($currentIsBackmatter=$true)">
                <!-- element in the backmatter-->
                <xsl:element name="footnotestartcount">
                    <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                    <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                </xsl:element>
                <xsl:if test="following-sibling::*">
                    <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                        <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$currentLevel &gt; $cFootnoteGroupingLevelMax">
                        <xsl:element name="footnotestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="$currentIsToc = $false">
                        <!--xsl:message>hit toc="no" figure previousAmount=<xsl:value-of select="$prmPreviousAmount"/></xsl:message-->
                        <xsl:element name="footnotestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="$prmPreviousAmount"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$prmPreviousAmount+$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise><!--xsl:when test="$currentLevel &lt; $cFigureGroupingLevelMax"-->
                        <xsl:element name="footnotestartcount">
                            <xsl:attribute name="level"><xsl:value-of select="$currentLevel"/></xsl:attribute>
                            <xsl:attribute name="id"><xsl:value-of select="$currentId"/></xsl:attribute>
                            <xsl:attribute name="count"><xsl:value-of select="0"/></xsl:attribute>
                        </xsl:element>
                        <xsl:if test="following-sibling::*">
                            <xsl:apply-templates select="following-sibling::*[1]" mode="FOOTNOTE_START_COUNT">
                                <xsl:with-param name="prmPreviousAmount" select="$currentCount"/>
                            </xsl:apply-templates>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    
    </xsl:template>
    
    
    
    
    <!-- 
     function:	dump tableCountMap, tableNumberingMap template
     param:		none
     return:	dump result
     note:		none
     -->
    <xsl:template name="dumpTableMap">
        <xsl:for-each select="$tableCountMap/*">
            <xsl:message>[dumpTableMap] no=<xsl:value-of select="position()"/> level=<xsl:value-of select="@level"/> id=<xsl:value-of select="@id"/> count=<xsl:value-of select="@count"/> isfronmatter=<xsl:value-of select="@isfrontmatter"/> isbackmatter=<xsl:value-of select="@isbackmatter"/> istoc=<xsl:value-of select="@istoc"/></xsl:message>
        </xsl:for-each>
        <xsl:message>********************************************************************************</xsl:message>
        <xsl:for-each select="$tableNumberingMap/*">
            <xsl:message>[dumpTableMap] no=<xsl:value-of select="position()"/> level=<xsl:value-of select="@level"/> id=<xsl:value-of select="@id"/> count=<xsl:value-of select="@count"/></xsl:message>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	dump figureCountMap, figureNumberingMap template
     param:		none
     return:	dump result
     note:		none
     -->
    <xsl:template name="dumpFigureMap">
        <xsl:for-each select="$figureCountMap/*">
            <xsl:message>[dumpFigureMap] no=<xsl:value-of select="position()"/> level=<xsl:value-of select="@level"/> id=<xsl:value-of select="@id"/> count=<xsl:value-of select="@count"/> isfronmatter=<xsl:value-of select="@isfrontmatter"/> isbackmatter=<xsl:value-of select="@isbackmatter"/> istoc=<xsl:value-of select="@istoc"/></xsl:message>
        </xsl:for-each>
        <xsl:message>********************************************************************************</xsl:message>
        <xsl:for-each select="$figureNumberingMap/*">
            <xsl:message>[dumpFigureMap] no=<xsl:value-of select="position()"/> level=<xsl:value-of select="@level"/> id=<xsl:value-of select="@id"/> count=<xsl:value-of select="@count"/></xsl:message>
        </xsl:for-each>
    </xsl:template>
    
    <!-- 
     function:	dump footnoteCountMap, footnoteNumberingMap template
     param:		none
     return:	dump result
     note:		none
     -->
    <xsl:template name="dumpFootnoteMap">
        <xsl:for-each select="$footnoteCountMap/*">
            <xsl:message>[dumpFootnoteMap] no=<xsl:value-of select="position()"/> level=<xsl:value-of select="@level"/> id=<xsl:value-of select="@id"/> count=<xsl:value-of select="@count"/> isfronmatter=<xsl:value-of select="@isfrontmatter"/> isbackmatter=<xsl:value-of select="@isbackmatter"/> istoc=<xsl:value-of select="@istoc"/></xsl:message>
        </xsl:for-each>
        <xsl:message>********************************************************************************</xsl:message>
        <xsl:for-each select="$footnoteNumberingMap/*">
            <xsl:message>[dumpFootnoteMap] no=<xsl:value-of select="position()"/> level=<xsl:value-of select="@level"/> id=<xsl:value-of select="@id"/> count=<xsl:value-of select="@count"/></xsl:message>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>