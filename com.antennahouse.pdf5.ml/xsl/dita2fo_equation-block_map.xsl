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

    <!-- equation-block/equation-number grouping max level
      -->
    <xsl:variable name="cEquationNumberGroupingLevelMax" as="xs:integer">
        <xsl:choose>
            <xsl:when test="$pAddNumberingTitlePrefix">
                <xsl:sequence select="xs:integer(ahf:getVarValue('Equation_Number_Grouping_Level_Max'))"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if user selects not to add title prefix, the equation number will not be grouped. -->
                <xsl:sequence select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- equation-number Count Map
         Count equation-number that should automatically numbered by tracing map//topicref structure.
         Element:equation-number-count
               This element is generated according to the topicref structure in map.
               This element is also generated even if topicref has no @href.
         Attribute：id⇒topic/@id
               count⇒Count of equation-block/equation-number that should be automatically generated.
         Count condition:
            - Count only equation-number has empty or whitespace-only content.
      -->
    <xsl:variable name="equationNumberCountMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeEquationNumberCount"/>
        </xsl:document>
    </xsl:variable>
    
    <!-- Equation Numbering Map
         Added the attribute @prev-count to $equationNumberCountMap/equation-number-count.
         @prev-count is the total of equation-number before the corresponding topicref. 
      -->
    <xsl:variable name="equationNumberingMap" as="document-node()">
        <xsl:document>
            <xsl:call-template name="makeEquationNumberStartCount"/>
        </xsl:document>
    </xsl:variable>
    
    <!-- 
     function:	make equation-number count map template
     param:		none
     return:	equation-number count node
     note:		
     -->
    <xsl:template name="makeEquationNumberCount" as="element()*">
        <xsl:apply-templates select="$map/*[contains(@class, ' map/topicref ')]" mode="MODE_EQUATION_BLCOK_COUNT"/>
    </xsl:template>
    
    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="MODE_EQUATION_BLCOK_COUNT" as="element()">
        <xsl:variable name="topicRef" as="element()" select="."/>
        <xsl:variable name="targetTopic" as="element()?" select="ahf:getTopicFromTopicRef($topicRef)"/>
        <xsl:variable name="equationNumberCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="exists($targetTopic)">
                    <xsl:variable name="topicEquationNumber" as="element()*">
                        <xsl:call-template name="getTopicEquationNumber">
                            <xsl:with-param name="prmTopic" select="$targetTopic"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:sequence select="count($topicEquationNumber)"/>
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
        <xsl:element name="equation-number-count">
            <xsl:attribute name="id" select="$topicId"/>
            <xsl:attribute name="count" select="$equationNumberCount"/>
            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="#current"/>
        </xsl:element>
    </xsl:template>
    
    <!-- 
     function:	Return equation-number that is descendant of given topic.
     param:		prmTopic
     return:	equation-number elements
     note:		Count only automatic equation-number assign target.
                In the related-links, the referenced topic/shortdesc is inserted automatically.
                It is not counted even if it contains equation-block/equation-number.
     -->
    <xsl:template name="getTopicEquationNumber" as="element()*">
        <xsl:param name="prmTopic" as="element()" required="yes"/>
        <xsl:variable name="equationNumberElem" as="element()*" 
            select="$prmTopic//*[contains(@class,' equation-d/equation-number ')]
                                 [not(ancestor::*[contains(@class,' topic/related-links ')])]
                                 [ahf:hasAutoEquationNumber(.)]"/>
        <xsl:sequence select="$equationNumberElem"/>
    </xsl:template>

    <!-- 
     function:	make equation numbering map template
     param:		none
     return:	equation-number start count node
     note:		
     -->
    <xsl:template name="makeEquationNumberStartCount" as="element()*">
        <xsl:apply-templates select="$equationNumberCountMap//*" mode="MODE_EQUATION_NUMBER_START_COUNT"/>
    </xsl:template>
    
    <xsl:template match="equation-number-count" mode="MODE_EQUATION_NUMBER_START_COUNT" as="element()">
        <xsl:variable name="level" as="xs:integer" select="count(ancestor-or-self::*)"/>
        <xsl:variable name="countTopElem" as="element()?" select="(ancestor-or-self::*)[position() eq $cEquationNumberGroupingLevelMax]"/>
        <xsl:variable name="prevCount" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$cEquationNumberGroupingLevelMax eq 0">
                    <!-- Equation number is not grouped. -->
                    <xsl:sequence select="sum(preceding::*/@count)"/>
                </xsl:when>
                <xsl:when test="$level le $cEquationNumberGroupingLevelMax">
                    <!-- Equation number always starts from 1. -->
                    <xsl:sequence select="0"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- Count equation number with grouping topicref considering $cEquationNumberGroupingLevelMax -->
                    <xsl:variable name="countTragetElem" as="element()*" select="preceding::* except $countTopElem/preceding::*"/>
                    <xsl:sequence select="sum($countTragetElem/@count)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="prev-count" select="string($prevCount)"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
     function:	dump equation numbering map template
     param:		none
     return:	result-document
     note:		
     -->
    <xsl:template name="outputEquationCountMap">
        <xsl:variable name="fileName1" select="'equationNumberCountMap.xml'"/>
        <xsl:result-document href="{$fileName1}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$equationNumberCountMap"/>
        </xsl:result-document>
        <xsl:variable name="fileName2" select="'equationNumberingMap.xml'"/>
        <xsl:result-document href="{$fileName2}" encoding="UTF-8" indent="yes">
            <xsl:copy-of select="$equationNumberingMap"/>
        </xsl:result-document>
    </xsl:template>
    
    <!-- 
     function:	get previous equation number amount
     param:		prmTopic,prmTopicRef
     return:	xs:integer
     note:		
     -->
    <xsl:template name="ahf:getEquationNumberPrevAmount" as="xs:integer">
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
        <xsl:variable name="equationNumberInf" as="element()" select="($equationNumberingMap//*[string(@id) eq $id])[1]"/>
        <xsl:sequence select="xs:integer(string($equationNumberInf/@prev-count))"/>
    </xsl:template>

</xsl:stylesheet>