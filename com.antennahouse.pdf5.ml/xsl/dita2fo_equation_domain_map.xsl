<?xml version="1.0" encoding="UTF-8"?>
<!--
    ****************************************************************
    DITA to XSL-FO Stylesheet
    Module: equation-number map stylesheet
    Copyright © 2009-2015 Antenna House, Inc. All rights reserved.
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
    xmlns:m="http://www.w3.org/1998/Math/MathML"
    exclude-result-prefixes="xs ahf"
>

    <!-- External Dependencies
         dita2fo_equation-block_util.xsl
         dita2fo_global.xsl
      -->

    <!-- equation-block grouping max level
      -->
    <xsl:variable name="cEquationBlockGroupingLevelMax" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$pAddNumberingTitlePrefix">
                <xsl:sequence select="xs:integer(ahf:getVarValue('Equation_Block_Grouping_Level_Max'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if user selects not to add title prefix, the equation-block will not be grouped. -->
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- equation-block Count Map
         Count equation-block that should automatically numbered by tracing map//topicref structure.
         Element:equation-block-count
               This element is generated according to the topicref structure in map.
               This element is also generated even if topicref has no @href.
         Attribute：id⇒topic/@id
               count⇒Count of equation-block that equation number should be automatically generated.
         Count condition:
            - If $pNumberEquationBlockUnconditionally is "yes", count all of the equation-block that does not has manually coded equation-number element.
            - If $pExcludeAutoNumberingFromEquationFigure is "yes", exclude equation-block in equation-figure.
            - If $pNumberEquationBlockUnconditionally is "yes", count only equation-block that does not has manually coded equation-number element.
      -->
    <xsl:variable name="equationBlockCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeEquationBlockCount"/>
        </xsl:document>
    </xsl:variable>
    
    <!-- Equation Numbering Map
         Added the attribute @prev-count to $equationNumberCountMap/equation-number-count.
         @prev-count is the total of equation-number before the corresponding topicref. 
      -->
    <xsl:variable name="equationBlockNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeEquationBlockStartCount"/>
        </xsl:document>
    </xsl:variable>
    
    <!-- 
     function:	make equation-block count map template
     param:		none
     return:	equation-block count node
     note:		
     -->
    <xsl:template name="makeEquationBlockCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="MODE_EQUATION_BLCOK_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MODE_EQUATION_BLCOK_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="equationBlockCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="topicEquationCount" as="element()*">
                        <xsl:call-template name="getTopicEquationBlock">
                            <xsl:with-param name="prmTopic" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="count($topicEquationCount)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="topicId" as="xs:string">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="idAttr" as="attribute()*">
                        <xsl:call-template name="ahf:getIdAtts">
                            <xsl:with-param name="prmElement" select="$targetTopic"/>
                            <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="string($idAttr[1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="ahf:generateId">
                        <xsl:with-param name="prmElement" select="$topicRef"/>
                        <xsl:with-param name="prmTopicRef" tunnel="yes" select="$topicRef"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="equation-block-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$equationBlockCount"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:	Return equation-block that is descendant of given topic.
     param:		prmTopic
     return:	equation-block elements
     note:		Count only automatic equation numbering equation-block.
                In the related-links, the referenced topic/shortdesc is inserted automatically.
                It is not counted even if it contains equation-block.
     -->
    <xsl:template name="getTopicEquationBlock" as="element()*">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        <xsl:variable name="equationBlockElem" as="element()*">
            <xsl:choose>
                <xsl:when test="$pNumberEquationBlockUnconditionally and not($pExcludeAutoNumberingFromEquationFigure)">
                    <xsl:sequence select="$prmTopic//*[contains(@class,' equation-d/equation-block ')]
                                                       [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                       [ahf:hasAutoEquationNumber(.) or ahf:hasNoEquationNumber(.)]"/>
                </xsl:when>
                <xsl:when test="$pNumberEquationBlockUnconditionally and $pExcludeAutoNumberingFromEquationFigure">
                    <xsl:variable name="equationBlockCountOutsideEquationFigure" as="element()*" 
                            select="$prmTopic//*[contains(@class,' equation-d/equation-block ')]
                                                 [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                 [ahf:hasNoEquationNumber(.) or ahf:hasAutoEquationNumber(.) ]
                                                 [empty(ancestor::*[contains(@class,' equation-d/equation-figure ')])]"/>
                    <xsl:variable name="equationBlockCountInsideEquationFigure" as="element()*"
                            select="$prmTopic//*[contains(@class,' equation-d/equation-block ')]
                                                 [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                 [ahf:hasEquationNumber(.) and ahf:hasAutoEquationNumber(.) ]
                                                 [exists(ancestor::*[contains(@class,' equation-d/equation-figure ')])]"/>
                    <xsl:sequence select="$equationBlockCountOutsideEquationFigure | $equationBlockCountInsideEquationFigure"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$prmTopic//*[contains(@class,' equation-d/equation-block ')]
                                                       [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                                       [ahf:hasAutoEquationNumber(.)]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable> 
        <xsl:sequence select="$equationBlockElem"/>
    </xsl:template>

    <!-- 
     function:	make equation numbering map template
     param:		none
     return:	equation-number start count node
     note:		
     -->
    <xsl:template name="makeEquationBlockStartCount" as="element()*">
        <xsl:apply-templates select="$equationBlockCountMap/*" mode="MODE_EQUATION_NUMBER_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="equation-block-count" mode="MODE_EQUATION_NUMBER_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $cEquationBlockGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$cEquationBlockGroupingLevelMax eq 0">
                    <!-- Equation number is not grouped. -->
                    <xsl:sequence select="xs:integer(sum(root(current())//*[. &lt;&lt; current()]/@count))"/>
                </xsl:when>
                <xsl:when test="$level le $cEquationBlockGroupingLevelMax">
                    <!-- Equation number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count equation number with grouping topicref considering $cEquationNumberGroupingLevelMax -->
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
     function:	dump equation numbering map template
     param:		none
     return:	result-document
     note:		
     -->
    <xsl:template name="outputEquationCountMap">
        <xsl:variable name="fileName1" select="'equationBlockCountMap.xml'"/>
        <xsl:result-document href="{$fileName1}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$equationBlockCountMap"/>
        </xsl:result-document>
        <xsl:variable name="fileName2" select="'equationBlockNumberingMap.xml'"/>
        <xsl:result-document href="{$fileName2}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$equationBlockNumberingMap"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- 
     function:	get previous equation number amount
     param:		prmTopic,prmTopicRef
     return:	xs:integer
     note:		
     -->
    <xsl:template name="ahf:getEquationBlockPrevAmount" as="xs:integer">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        
        <xsl:variable name="idAttr" as="attribute()*">
            <xsl:call-template name="ahf:getIdAtts">
                <xsl:with-param name="prmElement" select="$prmTopic"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="id" as="xs:string" select="string($idAttr[1])"/>
        <!-- ** DEBUG **
        <xsl:message select="'$equationNumberCountMap=',$equationNumberCountMap"/>
        <xsl:message select="'$equationNumberingMap=',$equationNumberingMap"/>
        <xsl:message select="'[ahf:getEquationNumberPrevAmount] $prmTopic @id=',string($prmTopic/@id),' @oid=',string($prmTopic/@oid)"/>
        <xsl:message select="'[ahf:getEquationNumberPrevAmount] $id=',$id"/>
        <xsl:message select="'[ahf:getEquationNumberPrevAmountt] $idAttr=',$idAttr"/>
        * -->
        <xsl:variable name="equationBlockInf" as="element()" select="($equationBlockNumberingMap//*[string(@id) eq $id])[1]"/>
        <xsl:sequence select="xs:integer(string($equationBlockInf/@prev-count))"/>
    </xsl:template>

</xsl:stylesheet>